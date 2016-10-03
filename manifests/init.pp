class dockerbridge (
  $provision  = {},
  $images     = [],
  $run        = [],
  $containers = {},

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

  if (!empty($provision)) {
    $provision.each |$app_name, $app| {
      $app_default_hosts = regsubst($default_hosts, '\$\{project_name\}', $app_name, 'GI')

      create_resources('::dockerbridge::provision', {
        $app_name => is_hash($app) ? {
          true  => $app,
          false => {
            'type'  => $app,
            'hosts' => any2array($app_default_hosts)
          }
        }
      })
    }
  }

  if (!empty($images)) {
    $images.each |$name| {
      $options = $containers[$name] ? {
        undef   => {},
        default => $containers[$name]
      }

      create_resources('docker::image', { $name => $options })
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
}
