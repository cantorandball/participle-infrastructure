#Wellogram Infrastructure

[Puppet](http://puppetlabs.com/) scripts for building [Wellogram](http://wellogram.com) platform environments which are as follows:

| Name       | Application | Host          |
| ---------- | ----------- | ------------- | 
| vagrant    | platform    | [192.168.33.10](https://192.168.33.10) 
| vagrant    | measures    | [192.168.33.11](https://192.168.33.11) 
| staging    | platform    | [staging.wellogram.com](http://staging.wellogram.com)
| staging    | measures    | [178.79.149.144](http://178.79.149.144)
| live       | platform    | [wellogram.com](https://staging.wellogram.com)

Requirements:

  * [Python](https://www.python.org/) v2.7.
  * [Fabric](http://www.fabfile.org/).
  * [Vagrant](http://www.vagrantup.com/downloads.html).
  * [Puppet](http://puppetlabs.com/).
  * [Hiera](http://projects.puppetlabs.com/projects/hiera).
  * [Hiera EYAML](https://github.com/TomPoulton/hiera-eyaml).

## Getting started

Firstly, ensure you've got a copy of the EYAML encryption keys in the `keys` folder. Contact [Ricardo Gladwell](mailto:ricardo@gladwell.me) if you don't have access to these.

## Test

To test infrastructure run:

    $ vagrant up platform
    $ vagrant up measures

This should automatically download, run and bootstrap virtual images of a deployment environments.

## Bootstrap

First, run the following command to install Puppet and upload and deploy the manifest:

    $ fab <name> <application> bootstrap

Where `<name>` is the platform key and `<application>` is the app name, as defined in the platform table above.

## Deploy

To deploy the code go the the [wellogram-platform-project](https://github.com/cantorandball/wellogram-platform-project) and run:

    $ fab <name> deploy

You should then be able to view the updated website at its host addresss.

If the manifest changes you can update this by running:

    $ fab <name> provision

Or just run:

    $ vagrant provision
