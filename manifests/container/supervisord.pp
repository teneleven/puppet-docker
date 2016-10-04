class dockerbridge::container::supervisord inherits dockerbridge::params {

    # global supervisord setup for containers
    class { 'supervisord':
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
      Class['lamp::php'] ~> supervisord::program { 'fpm':
        command     => 'php5-fpm -F',
        autorestart => true,
      }
      Php::Extension <| |> ~> Supervisord::Program['fpm']
    }

}
