define dockerbridge::provision (
  $target = $title,
  $path   = $title,
  $app    = undef,
  $hosts  = [],

  $extra_options = {},

  $provision_with = $dockerbridge::params::provision_with,
) {

  include dockerbridge::params

  if (empty($hosts)) {
    $host_str = regsubst(join(any2array($dockerbridge::params::default_hosts), ','), '\$\{project_name\}', $title, 'GI')
  } elsif (is_array($hosts)) {
    $host_str = join($hosts, ',')
  } elsif (is_string($hosts)) {
    $host_str = $hosts
  } else {
    fail('Invalid hosts type passed to dockerbridge::provision')
  }

  /* start container first, if we're using docker */
  if ($provision_with == 'docker') {
    dockerbridge::run { $title:
      /* app_type => $app, */
      options  => { env => [
        "FACTER_project_name=${title}",
        "FACTER_app_type=${app}",
        "FACTER_app_hosts=${host_str}",
        "FACTER_app_target=${target}",
        "FACTER_app_path=${path}",
      ]}
    }
  } elsif ($provision_with == 'docker_compose') {
    dockerbridge::compose { $title:
      app_name => $target,
      app_type => $app,
      env      => ["COMPOSE_APP_TARGET=${target}", "COMPOSE_APP_TYPE=${app}", "COMPOSE_APP_HOSTS=${host_str}", "COMPOSE_APP_PATH=${path}"]
    }
  }

  if ($provision_with == 'shell') {
    $provision_args = merge({
      env       => ["FACTER_project_name=${title}", "FACTER_app_type=${app}", "FACTER_app_hosts=${host_str}", "FACTER_app_target=${target}", "FACTER_app_path=${path}"],
    }, $extra_options)
  } else {
    $provision_args = $extra_options
  }

  # this does the actual provisioning
  create_resources("dockerbridge::provision::${provision_with}", { $title => $provision_args })

}
