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
  exec           => '/usr/bin/java -Djava.awt.headless=true -Xms1g -Xmx1g -XX:PermSize=128m -XX:MaxPermSize=128m -cp lib:lib/joda-time-2.3.jar:lib/jetty-io-9.1.3.v20140225.jar:lib/paranamer-2.6.jar:lib/joda-convert-1.6.jar:lib/scala-compiler-2.11.0.jar:lib/jackson-annotations-2.3.0.jar:lib/scala-xml_2.11-1.0.2.jar:lib/slf4j-api-1.7.7.jar:lib/scalatra_2.11-2.3.0.jar:lib/scalap-2.11.0.jar:lib/grizzled-slf4j_2.11-1.0.2.jar:lib/json4s-jackson_2.11-3.2.9.jar:lib/juniversalchardet-1.0.3.jar:lib/jetty-server-9.1.3.v20140225.jar:lib/jetty-xml-9.1.3.v20140225.jar:lib/jetty-http-9.1.3.v20140225.jar:lib/scalatra-common_2.11-2.3.0.jar:lib/jetty-plus-9.1.3.v20140225.jar:lib/scala-library-2.11.1.jar:lib/scalate-util_2.11-1.7.0.jar:lib/jetty-util-9.1.3.v20140225.jar:lib/logback-classic-1.0.6.jar:lib/json4s-core_2.11-3.2.10.jar:lib/jetty-webapp-9.1.3.v20140225.jar:lib/jackson-core-2.3.1.jar:lib/jetty-jndi-9.1.3.v20140225.jar:lib/jackson-databind-2.3.1.jar:lib/javax.servlet-api-3.1.0.jar:lib/scalate-core_2.11-1.7.0.jar:lib/jetty-servlet-9.1.3.v20140225.jar:lib/json4s-ast_2.11-3.2.10.jar:lib/scalatra-scalate_2.11-2.3.0.jar:lib/jetty-security-9.1.3.v20140225.jar:lib/scala-parser-combinators_2.11-1.0.1.jar:lib/scalatra-json_2.11-2.3.0.jar:lib/logback-core-1.0.6.jar:lib/rl_2.11-0.4.10.jar:lib/scala-reflect-2.11.0.jar:lib/mime-util-2.1.3.jar ScalatraLauncher',
  require        => [
                      File['/home/measurements-api'],
                      File['/home/measurements-api/.ssh/authorized_keys'],
                      Package['nginx']
                    ]
}