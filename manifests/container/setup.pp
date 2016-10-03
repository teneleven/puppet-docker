class dockerbridge::container::setup inherits dockerbridge::params {

  Service {
    provider => $service_provider
  }

  if ($supervisord) {

    # global supervisord setup for containers
    class { 'supervisord':
      install_pip    => true,
      install_init   => false,
      service_manage => false,
      executable_ctl => $supervisorctl,
    }

    /* TODO refresh supervisord for each program ?? */
    /* Supervisord::Program <| |> -> exec { 'reload-supervisord': */
    /*   command => "${supervisorctl} reload", */
    /* } */

  }

}
