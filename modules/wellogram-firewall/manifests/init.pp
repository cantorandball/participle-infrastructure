class wellogram-firewall {

    resources { "firewall":
        purge => true
    }

    Firewall {
        before  => Class['wellogram-firewall::post'],
        require => Class['wellogram-firewall::pre'],
    }

    class { ['wellogram-firewall::pre', 'wellogram-firewall::post']: }

    class { 'firewall': }

}