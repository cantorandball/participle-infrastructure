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

upstart::job { 'measurements-api':
  description    => "Capability Measurements API",
  user           => 'measurements-api',
  group          => 'measurements-api',
  chdir          => '/home/measurements-api/measurements-api',
  service_enable => false,
  service_ensure => 'stopped',
  exec           => 'sh /home/measurements-api/measurements-api/bin/measurements-api',
  require        => [
                      File['/home/measurements-api'],
                      File['/home/measurements-api/.ssh/authorized_keys'],
                      Package['nginx']
                    ]
}