include upstart
include apt
include participle-base

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

file { "/etc/nginx/sites-enabled/wellogram-platform.conf":
  content => template('nginx/wellogram-platform.conf.erb'),
  mode   => '0644',
  notify => Service['nginx'],
  require => [
        Package['nginx'],
        File['/etc/nginx/ssl/server.key'],
        File['/etc/nginx/ssl/server.pem'],
        File['/etc/nginx/ssl/dhparam.pem'],
        File['/etc/nginx/ssl/trusted_certificate.pem']
  ]
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
  description => "Wellogram Platform",
  user        => 'wellogram-platform',
  group       => 'wellogram-platform',
  chdir       => '/home/wellogram-platform',
  environment => {
     'WELLOGRAM_PLATFORM_SECRET_KEY'  => hiera('secret_key'),
     'WELLOGRAM_PLATFORM_DB_PASSWORD' => hiera('db_password'),
     'DJANGO_SETTINGS_MODULE'         => hiera('django-module'),
     'MEASURES_API_KEY'               => hiera('wellogram-platform-api-key-base64'),
     'MEASURES_API_ENDPOINT'          => hiera('measurements-api-endpoint'),
     'MANDRILL_API_KEY'               => hiera('mandrill_api_key')
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
