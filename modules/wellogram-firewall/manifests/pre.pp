class wellogram-firewall::pre {

  Firewall {
    require => undef,
  }
 
  firewall { '000 accept all icmp':
    proto   => 'icmp',
    action  => 'accept',
  }->

  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->

  firewall { '002 accept related established rules':
    proto   => 'all',
    state   => ['RELATED', 'ESTABLISHED'],
    action  => 'accept',
  }->

  firewall { '003 allow SSH access':
    port   => 22,
    proto  => tcp,
    action => accept,
  }->

  firewall { '004 allow HTTP access':
    port   => 80,
    proto  => tcp,
    action => accept,
  }->

  firewall { '005 allow HTTPS access':
    port   => 443,
    proto  => tcp,
    action => accept,
  }

}
