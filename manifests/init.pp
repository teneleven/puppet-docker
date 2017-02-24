class dockerbridge (
  $provision  = {},
  $images     = [],
  $run        = [],
  $containers = {},
  $compose    = {},

  $install_docker = false
) inherits dockerbridge::params {

  if ($::is_container) {
    contain dockerbridge::container::setup
  }

  if ($install_docker) {
    if ($::is_container) {
      class { '::docker':
        service_enable => false,
        service_state  => undef,
      }
    }

    contain '::docker'
  }

  if (!empty($images)) {
    $images.each |$key, $val| {
      if (is_hash($val)) {
        create_resources('docker::image', { $key => $val })
      } else {
        $name = $val
        $options = $containers[$name] ? {
          undef   => {},
          default => $containers[$name]
        }

        create_resources('docker::image', { $name => $options })
      }
    }
  }

  if (!empty($run)) {
    $run.each |$name| {
      $options = $containers[$name] ? {
        undef   => {},
        default => $containers[$name]
      }

      create_resources('dockerbridge::run', { $name => { options => $options } })
    }
  }

  if (!empty($compose)) {
    $compose.each |$app_name, $app_type| {
      create_resources('dockerbridge::compose', { $app_name => {
        app_type => $app_type
      } })
    }
  }

  if (!empty($provision)) {
    $provision.each |$app_name, $app| {
      create_resources('::dockerbridge::provision', {
        $app_name => is_hash($app) ? {
          true  => $app,
          false => { 'app' => $app }
        }
      })
    }
  }
}
