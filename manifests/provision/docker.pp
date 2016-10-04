define dockerbridge::provision::docker (
  $app_name  = $title,
  $container = $title,

  $exec_options     = {},
  $commit_container = true
) {

  include ::dockerbridge
  include ::dockerbridge::params

  /* provision */
  dockerbridge::exec { "provision-${app_name}":
    container => $container,
    options   => merge({
      command => $::dockerbridge::params::provision_cmd
    }, $exec_options)
  } -> dockerbridge::exec { "reload-${app_name}":
    container => $container,
    options   => {
      command => $::dockerbridge::params::reload_cmd
    }
  }

  if ($commit_container) {
    Dockerbridge::Exec["provision-${app_name}"] -> dockerbridge::commit { $container:
      tag => "${::dockerbridge::params::docker_prefix}:${app_name}"
    }
  }

}
