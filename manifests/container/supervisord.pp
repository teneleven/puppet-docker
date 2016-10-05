class dockerbridge::container::supervisord inherits dockerbridge::params {

  # global supervisord setup for containers
  class { '::supervisord':
    install_pip    => true,
    install_init   => false,
    service_manage => false,
    executable_ctl => $supervisorctl,
  }

  /* refresh supervisord for each program */
  Supervisord::Program <| |> -> exec { 'reload-supervisord':
    command => $reload_cmd
  }

  /* TODO disable services such as apache/fpm/nginx */
  /* TODO perhaps look into Puppet 4 + data-in-modules */

  if (defined(Class['lamp::server::apache'])) {
    Class['lamp::server::apache'] ~> supervisord::program { 'apache':
      command     => 'apache2ctl -DFOREGROUND',
      autorestart => true,
      killasgroup => true,
      stopasgroup => true,
    }
    Lamp::Server::Apache::Vhost <| |> ~> Supervisord::Program['apache']
  }

  if (defined(Class['lamp::server::nginx'])) {
    Class['lamp::server::nginx'] ~> supervisord::program { 'nginx':
      command     => 'nginx -g "daemon off;"',
      autorestart => true,
    }
    Lamp::Server::Nginx::Vhost <| |> ~> Supervisord::Program['nginx']
  }

  if (defined(Class['lamp::php'])) {
    /* create symlink to php-fpm dependending on available FPM executable */
    exec { "php-fpm-7-link":
      command => 'ln -s /usr/sbin/php-fpm7.0 /usr/sbin/php-fpm',
      onlyif  => 'test -x /usr/sbin/php-fpm7.0',
      unless  => 'test -e /usr/sbin/php-fpm',
      path    => ['/bin', '/usr/bin'],
    }
    exec { "php-fpm-5-link":
      command => 'ln -s /usr/sbin/php5-fpm /usr/sbin/php-fpm',
      onlyif  => 'test -x /usr/sbin/php5-fpm',
      unless  => 'test -x /usr/sbin/php-fpm7.0 || test -e /usr/sbin/php-fpm',
      path    => ['/bin', '/usr/bin'],
    }

    Class['lamp::php'] ~> supervisord::program { 'fpm':
      command     => 'php-fpm -F',
      autorestart => true,
    }
    Php::Extension <| |> ~> Supervisord::Program['fpm']
  }

}
