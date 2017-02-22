define dockerbridge::provision (
  $target = $title,
  $app    = undef,
  $hosts  = [],

  $extra_options = {}
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
  if ($dockerbridge::params::provision_with == 'docker') {
    dockerbridge::run { $title:
      app_type => $app,
      options  => { env => [
        "FACTER_project_name=${title}",
        "FACTER_app_type=${app}",
        "FACTER_app_hosts=${host_str}",
        "FACTER_app_target=${target}",
      ]}
    }
  } elsif ($dockerbridge::params::provision_with == 'docker_compose') {
    dockerbridge::compose { $title:
      app_type => $app,
      env      => ["COMPOSE_APP_TARGET=${target}", "COMPOSE_APP_TYPE=${app}", "COMPOSE_APP_HOSTS=${host_str}"]
    }
  }

  if ($dockerbridge::params::provision_with == 'shell') {
    $provision_args = merge({
      env       => ["FACTER_project_name=${title}", "FACTER_app_type=${app}", "FACTER_app_hosts=${host_str}", "FACTER_app_target=${target}"],
    }, $extra_options)
  } else {
    $provision_args = $extra_options
  }

  # this does the actual provisioning
  create_resources("dockerbridge::provision::${dockerbridge::params::provision_with}", { $title => $provision_args })

}
