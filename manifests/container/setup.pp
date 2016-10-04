class dockerbridge::container::setup inherits dockerbridge::params {

  Service {
    provider => $service_provider
  }

  if ($supervisord) {
    contain dockerbridge::container::supervisord
  }

}
