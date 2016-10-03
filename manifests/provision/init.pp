define dockerbridge::provision (
  $type  = undef,
  $hosts = []
) {

  include dockerbridge::params

  if (is_array($hosts)) {
    $host_str = join($hosts, ',')
  } elsif (is_string($hosts)) {
    $host_str = $hosts
  } else {
    fail('Invalid hosts type passed to dockerbridge::provision')
  }

  /* start container first, if we're using docker */
  if ($dockerbridge::params::provision_with == 'docker') {
    dockerbridge::run { $title:
      type => $type,
      options  => { env => [
        "FACTER_project_name=${title}",
        "FACTER_type=${type}",
        "FACTER_app_hosts=${host_str}"
      ]}
    }
  } elsif ($dockerbridge::params::provision_with == 'docker_compose') {
    dockerbridge::compose { $title:
      type => $type,
      env      => ["COMPOSE_type=${type}", "COMPOSE_APP_HOSTS=${host_str}"]
    }
  }

  if ($dockerbridge::params::provision_with == 'shell') {
    $provision_args = merge({
      env       => ["FACTER_project_name=${title}", "FACTER_type=${type}", "FACTER_app_hosts=${host_str}"],
    }, $extra_options)
  } else {
    $provision_args = $extra_options
  }

  notice("Provisioning ${title}...")

  create_resources("dockerbridge::provision::${dockerbridge::params::provision_with}", { $title => $provision_args })

}
