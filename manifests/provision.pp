define dockerbridge::provision (
  $target = $title,
  $path   = $title,
  $app    = undef,
  $hosts  = [],

  $extra_options = {},

  # facts to either prefix with FACTER_ (if provisioning with shell or docker) or COMPOSE_ (if provisioning with docker-compose)
  $env = [],

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

  if (!empty($env)) {
    $env_facts = $env
  } else {
    /* fill in some helpful default facts */
    $env_facts = [
        "project_name=${title}",
        "app_type=${app}",
        "app_hosts=${host_str}",
        "app_target=${target}",
        "app_path=${path}",
    ]
  }

  $facter_facts = $env_facts.map |$var| {
    $parts = split($var, '=')
    $fact  = upcase($parts[0])
    $val   = $parts[1]
    "FACTER_${fact}=${val}"
  }
  $compose_facts = $env_facts.map |$var| {
    $parts = split($var, '=')
    $fact  = upcase($parts[0])
    $val   = $parts[1]
    "COMPOSE_${fact}=${val}"
  }

  /* start container first, if we're using docker */
  if ($provision_with == 'docker') {
    dockerbridge::run { $title:
      /* app_type => $app, */
      options  => { env => $facter_facts }
    }
  } elsif ($provision_with == 'docker_compose') {
    dockerbridge::compose { $title:
      app_name => $target,
      app_type => $app,
      env      => $compose_facts,
    }
  }

  if ($provision_with == 'shell') {
    $provision_args = merge({
      env      => $facter_facts,
    }, $extra_options)
  } else {
    $provision_args = $extra_options
  }

  # this does the actual provisioning
  create_resources("dockerbridge::provision::${provision_with}", { $title => $provision_args })

}
