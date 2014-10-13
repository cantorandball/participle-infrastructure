include wellogram-firewall

class participle-base {

   exec { "apt-update":
       command => "/usr/bin/apt-get update"
    }

    Exec["apt-update"] -> Package <| |>

    class { 'wellogram-firewall': }

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
      content => hiera('ssl_certificate'),
      mode   => '0600',
      notify => Service['nginx'],
      require => File['/etc/nginx/ssl']
    }

    file { "/etc/nginx/sites-enabled/default":
       require => Package["nginx"],
       ensure  => absent,
       notify  => Service["nginx"]
    }

 }
