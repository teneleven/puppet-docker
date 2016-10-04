define dockerbridge::provision::docker_compose (
  $app_name = $title,
  $container_name = undef /* by default uses $app_name + $dockerbridge::params::docker_compose_suffix */
) {

  include ::dockerbridge
  include ::dockerbridge::params

  dockerbridge::provision::docker { $app_name:
    container => $container_name ? {
      undef   => "${app_name}${::dockerbridge::params::docker_compose_suffix}",
      default => $container_name
    }
  }

}
