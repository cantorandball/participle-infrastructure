#Wellogram Infrastructure

[Puppet](http://puppetlabs.com/) scripts for building [Wellogram](http://wellogram.com) platform environments which are as follows:

| Name       | Host          |
| ---------- | ------------- | 
| vagrant    | [192.168.33.10](http://192.168.33.10) 
| staging    | [staging.wellogram.com](http://staging.wellogram.com)
| live       | [wellogram.com](https://staging.wellogram.com)

Requirements:

  * [Python](https://www.python.org/) v2.7.
  * [Fabric](http://www.fabfile.org/).
  * [Vagrant](http://www.vagrantup.com/downloads.html).
  * [Puppet](http://puppetlabs.com/).
  * [Hiera](http://projects.puppetlabs.com/projects/hiera).

## Getting started

Firstly, ensure you've created a `./hiera/secrets.yaml` file containing the Django secret key and database password as follows:

    secret_key: <key>
    db_password: <password>

## Test

To test infrastructure run:

    $ vagrant up

This should automatically download, run and bootstrap a virtual image of a deployment environment.

## Bootstrap

First, run the following command to install Puppet and upload and deploy the manifest:

    $ fab <name> bootstrap

Where `<name>` is the platform key as defined in the platform table above.

## Deploy

To deploy the code go the the [wellogram-platform-project](https://github.com/cantorandball/wellogram-platform-project) and run:

    $ fab <name> deploy

You should then be able to view the updated website at its host addresss.

If the manifest changes you can update this by running:

    $ fab <name> provision

Or just run:

    $ vagrant provision
