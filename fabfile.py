# coding=UTF-8

import os

from time import strftime
from fabric.api import env, local, run, put
from fabric.context_managers import cd, prefix
from fabric.contrib import django
from fabric.contrib.files import append, exists
from fabric.decorators import task


@task
def staging():
    env.site = 'staging.wellogram.com'
    env.hosts = [env.site]
    env.user =  'root'
    env.use_ssh_config = True
    env.platform = 'staging'


@task
def live():
    env.user =  'root'
    env.use_ssh_config = True
    env.platform = 'live'


@task
def vagrant():
    env.platform = 'vagrant'
    env.user = 'vagrant'


@task
def platform():
    env.application = 'platform'

    if(env.platform is 'vagrant'):
        env.hosts = ['192.168.33.10']
        # use vagrant ssh key
        result = local('vagrant ssh-config {} | grep IdentityFile'.format(env.application), capture=True)
        env.key_filename = result.split()[1]
    elif(env.platform is 'live'):
        env.hosts = ['wellogram.com']
    elif(env.platform is 'staging'):
        env.hosts = ['staging.wellogram.com']

    env.deploy_user = 'wellogram-platform'


@task
def measures():
    env.application = 'measures'

    if(env.platform is 'vagrant'):
        env.hosts = ['192.168.33.11']
        # use vagrant ssh key
        result = local('vagrant ssh-config {} | grep IdentityFile'.format(env.application), capture=True)
        env.key_filename = result.split()[1]
    elif(env.platform is 'staging'):
        env.hosts = ['178.79.149.144']

    env.deploy_user = 'measurements-api'


@task
def cmtadmin():
    measures()

    env.deploy_user = 'cmt-admin'


def read_key_file(key_file):
    key_file = os.path.expanduser(key_file)
    if not key_file.endswith('pub'):
        raise RuntimeWarning('Trying to push non-public part of key pair')
    with open(key_file) as f:
        return f.read()


@task
def bootstrap():
    if(env.platform != 'vagrant'):
        install_puppet()
    provision()
    authorise()


@task
def authorise():
    key = read_key_file('~/.ssh/id_rsa.pub')
    append('/home/{}/.ssh/authorized_keys'.format(env.deploy_user), key, use_sudo=True)


def install_puppet():
    run("apt-get update")
    run("apt-get -y install ruby-full build-essential")
    run("sudo gem install puppet hiera hiera-eyaml --no-rdoc --no-ri", pty=True)


@task
def provision():
    if(env.platform != 'vagrant'):
        run_puppet()


def run_puppet():
    if(exists('/tmp/puppet') is not True):
        run('mkdir /tmp/puppet')

    put('./', '/tmp/puppet')

    with cd("/tmp/puppet"):
        with prefix("export FACTER_env={}".format(env.platform)):
            with prefix("export FACTER_application={}".format(env.application)):
                output = run("puppet apply --modulepath '/tmp/puppet/modules:/etc/puppet/modules' --hiera_config=/tmp/puppet/hiera.yaml --manifestdir /tmp/puppet/manifests --detailed-exitcodes /tmp/puppet/manifests/{}.pp".format(env.application), warn_only=True)
            if(output.return_code == 1):
                raise SystemExit()
    
