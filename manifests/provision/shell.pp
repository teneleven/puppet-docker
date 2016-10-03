define dockerbridge::provision::shell (
  $app_name = $title,
  $env = []
) {

  include ::dockerbridge::params

  exec { "provision-${app_name}":
    command => $::dockerbridge::params::provision_cmd,
    environment => $env,
    path => ['/bin', '/usr/bin']
  }

}
