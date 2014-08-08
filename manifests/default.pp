include upstart
include apt

exec { "apt-update":
    command => "/usr/bin/apt-get update"
}

Exec["apt-update"] -> Package <| |>

class { 'sudo':
  purge               => false,
  config_file_replace => false,
}

sudo::conf { 'wellogram-platform':
  content  => "wellogram-platform ALL = (root) NOPASSWD: /sbin/start wellogram-platform, NOPASSWD: /sbin/stop wellogram-platform, NOPASSWD: /sbin/restart wellogram-platform, NOPASSWD: /sbin/status wellogram-platform'",
}

class { 'postgresql::server': }

postgresql::server::role { 'wellogram_platform':
  password_hash => postgresql_password('wellogram_platform', hiera('db_password')),
}

postgresql::server::db{ 'wellogram_platform':
  user          => 'wellogram_platform',
  password      => postgresql_password('wellogram_platform', hiera('db_password')),
  grant         => 'all',
}

package { "python-dev":
  ensure => installed
}

package { "python-psycopg2":
  ensure => installed
}

package { "libpq-dev":
  ensure => installed
}

package { "python":
  ensure => installed,
  require => [
                 Package['libpq-dev'],
                 Package['python-psycopg2'],
                 Package['python-dev']
            ]
}

package { "python-pip":
  ensure => installed
}

package { "virtualenvwrapper":
  ensure => installed
}

package { 'nginx':
  ensure => installed
}

service { 'nginx':
  ensure => running,
  require => Package['nginx']
}

file { "/etc/nginx/ssl/":
  ensure => directory,
  mode   => '0644',
  require => Package['nginx']
}

file { "/etc/nginx/ssl/server.key":
  content => hiera('ssl_private_key'),
  mode   => '0600',
  notify => Service['nginx'],
  require => File['/etc/nginx/ssl']
}

file { "/etc/nginx/ssl/server.crt":
  source => "puppet:///modules/nginx/ssl/$env/server.crt",
  mode   => '0600',
  notify => Service['nginx'],
  require => File['/etc/nginx/ssl']
}

file { "/etc/nginx/sites-enabled/wellogram-platform.conf":
  content => template('nginx/wellogram-platform.conf.erb'),
  mode   => '0644',
  notify => Service['nginx'],
  require => [
        Package['nginx'],
        File['/etc/nginx/ssl/server.key'],
        File['/etc/nginx/ssl/server.crt']
  ]
}

file { "/etc/nginx/sites-enabled/default":
    require => Package["nginx"],
    ensure  => absent,
    notify  => Service["nginx"]
}

group { "wellogram-platform":
}

user { "wellogram-platform":
  ensure => present,
  require => Group['wellogram-platform'],
  shell => '/bin/bash'
}

file { "/home/wellogram-platform":
  ensure => directory,
  owner => 'wellogram-platform',
  group => 'wellogram-platform',
  require => User['wellogram-platform']
}

file { "/home/wellogram-platform/.bashrc":
  content => template('wellogram/bashrc.erb'),
  owner => 'wellogram-platform',
  group => 'wellogram-platform',
  mode    => 700
}


file { "/home/wellogram-platform/.ssh":
  ensure => directory,
  owner => 'wellogram-platform',
  group => 'wellogram-platform',
  mode => 0700,
  require => User['wellogram-platform']
}

file { "/home/wellogram-platform/.ssh/authorized_keys":
  ensure => present,
  owner => 'wellogram-platform',
  group => 'wellogram-platform',
  mode => 0600,
  require => User['wellogram-platform']
}

upstart::job { 'wellogram-platform':
  description    => "Wellogram Platform",
  user           => 'wellogram-platform',
  group          => 'wellogram-platform',
  chdir          => '/home/wellogram-platform',
  environment    => {
     'WELLOGRAM_PLATFORM_SECRET_KEY' => hiera('secret_key'),
     'WELLOGRAM_PLATFORM_DB_PASSWORD' => hiera('db_password'),
     'DJANGO_SETTINGS_MODULE' => 'wellogram_platform.settings.staging'
  },
  exec           => '.virtualenvs/wellogram/bin/uwsgi --die-on-term --master --socket=127.0.0.1:8000 --module=wellogram_platform.wsgi:application --processes=3',
  require        => [
                      File['/home/wellogram-platform'],
                      File['/home/wellogram-platform/.ssh/authorized_keys'],
                      Class['postgresql::server'],
                      Package['nginx'],
                      Package['python'],
                      Package['python-pip'],
                      Package['virtualenvwrapper']
                    ]
}
