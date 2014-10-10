include participle-base
include java7
include upstart

class { 'sudo':
  purge               => false,
  config_file_replace => false,
}

sudo::conf { 'measurements-api':
  content  => "measurements-api ALL = (root) NOPASSWD: /sbin/start measurements-api, NOPASSWD: /sbin/stop measurements-api, NOPASSWD: /sbin/restart measurements-api, NOPASSWD: /sbin/status measurements-api'",
}

group { "measurements-api":
}

user { "measurements-api":
  ensure => present,
  require => Group['measurements-api'],
  shell => '/bin/bash'
}

file { "/home/measurements-api":
  ensure => directory,
  owner => 'measurements-api',
  group => 'measurements-api',
  require => User['measurements-api']
}

file { "/home/measurements-api/.ssh":
  ensure => directory,
  owner => 'measurements-api',
  group => 'measurements-api',
  mode => 0700,
  require => User['measurements-api']
}

file { "/home/measurements-api/.ssh/authorized_keys":
  ensure => present,
  owner => 'measurements-api',
  group => 'measurements-api',
  mode => 0600,
  require => User['measurements-api']
}

file { "/etc/nginx/sites-enabled/wellogram-platform.conf":
  content => template('nginx/measurements-api.conf.erb'),
  mode   => '0644',
  notify => Service['nginx'],
  require => [
        Package['nginx'],
        File['/etc/nginx/ssl/server.key'],
        File['/etc/nginx/ssl/server.crt']
  ]
}

package { "unzip":
  ensure => installed
}

file { "/etc/participle":
  ensure => directory,
  owner => 'measurements-api',
  group => 'measurements-api'
}

file { "/etc/participle/measurement-api/":
  ensure => directory,
  owner => 'measurements-api',
  group => 'measurements-api',
  require => [
        File['/etc/participle/']
  ]
}

file { "/etc/participle/measurement-api/api-keys.properties":
  content => template('measurements-api/api-keys.properties.erb'),
  mode   => '0400',
  owner => 'measurements-api',
  group => 'measurements-api',
  require => [
        File['/etc/participle/measurement-api/']
  ]
}

$db_password = hiera('db_password')

class { 'postgresql::server': }

postgresql::server::role { 'measurements_api':
  password_hash => postgresql_password('measurements_api', $db_password),
}

postgresql::server::db{ 'measurements_api':
  user          => 'measurements_api',
  password      => postgresql_password('measurements_api', $db_password),
  grant         => 'all',
}

upstart::job { 'measurements-api':
  description    => "Capability Measurements API",
  user           => 'measurements-api',
  group          => 'measurements-api',
  chdir          => '/home/measurements-api/measurements-api',
  environment    => {
     'MEASUREMENTS_API_KEYS_LOCATION' => '/etc/participle/measurement-api/api-keys.properties',
     'MEASUREMENTS_API_DB_PASS' => "'${db_password}'"
  },
  service_enable => false,
  service_ensure => 'stopped',
  exec           => 'sh /home/measurements-api/measurements-api/bin/measurements-api',
  require        => [
                      File['/home/measurements-api'],
                      File['/home/measurements-api/.ssh/authorized_keys'],
                      File['/etc/participle/measurement-api/api-keys.properties'],
                      Package['nginx'],
                      Class['postgresql::server']
                    ]
}

sudo::conf { 'cmt-admin':
  content  => "cmt-admin ALL = (root) NOPASSWD: /sbin/start cmt-admin, NOPASSWD: /sbin/stop cmt-admin, NOPASSWD: /sbin/restart cmt-admin, NOPASSWD: /sbin/status cmt-admin'",
}

group { "cmt-admin":
}

user { "cmt-admin":
  ensure => present,
  require => Group['cmt-admin'],
  shell => '/bin/bash'
}

file { "/home/cmt-admin":
  ensure => directory,
  owner => 'cmt-admin',
  group => 'cmt-admin',
  require => User['cmt-admin']
}

file { "/home/cmt-admin/.ssh":
  ensure => directory,
  owner => 'cmt-admin',
  group => 'cmt-admin',
  mode => 0700,
  require => User['cmt-admin']
}

file { "/home/cmt-admin/.ssh/authorized_keys":
  ensure => present,
  owner => 'cmt-admin',
  group => 'cmt-admin',
  mode => 0600,
  require => User['cmt-admin']
}

$cmt_admin_api_key = hiera('cmt-admin-api-key')

upstart::job { 'cmt-admin':
  description    => "Capability Measurements Tool Admin",
  user           => 'cmt-admin',
  group          => 'cmt-admin',
  chdir          => '/home/cmt-admin/cmt-admin',
  environment    => {
     'MEASUREMENTS_API_KEY' => "'${cmt_admin_api_key}'"
  },
  service_enable => false,
  service_ensure => 'stopped',
  exec           => '/home/cmt-admin/cmt-admin/bin/cmt-admin',
  require        => [
                      File['/home/cmt-admin'],
                      File['/home/cmt-admin/.ssh/authorized_keys'],
                      Package['nginx']
                    ]
}
