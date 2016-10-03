define dockerbridge::compose (
  $app_name = $title,
  $app_type = undef,
  $env      = []
) {

  include ::dockerbridge
  include ::dockerbridge::image

  $compose_fallback_dir = $dockerbridge::compose_fallback_dir ? {
    undef   => "${dockerbridge::compose_dir}",
    default => "${dockerbridge::compose_fallback_dir}",
  }

  $compose_app_name_path = "${dockerbridge::compose_dir}/${app_name}/${dockerbridge::compose_file}"
  $compose_app_type_path = "${dockerbridge::compose_dir}/${app_type}/${dockerbridge::compose_file}"
  $compose_app_type_fallback_path = "${compose_fallback_dir}/${app_type}/${dockerbridge::compose_file}"
  $compose_fallback_path = "${compose_fallback_dir}/${dockerbridge::compose_default}"

  $compose_environment = $env ? {
    undef => ["COMPOSE_PROJECT_NAME=${app_name}", "COMPOSE_APP_TYPE=${app_type}"],
    default => concat(["COMPOSE_PROJECT_NAME=${app_name}"], $env)
  }

  /* compose app_name */
  exec { "compose-name-${app_name}":
    command     => "docker-compose -f ${compose_app_name_path} up -d",
    provider    => 'shell',
    environment => $compose_environment,
    onlyif      => "/usr/bin/test -e ${compose_app_name_path}",
    require     => Class[dockerbridge::image]
  }

  if $app_type {
    /* compose app_type */
    exec { "compose-type-${app_name}-${app_type}":
      command     => "docker-compose -f ${compose_app_type_path} up -d",
      provider    => 'shell',
      environment => $compose_environment,
      unless      => "/usr/bin/test -e ${compose_app_name_path}",
      onlyif      => "/usr/bin/test -e ${compose_app_type_path}",
      require     => Class[dockerbridge::image]
    }

    /* compose app_type fallback */
    exec { "compose-type-fallback-${app_name}-${app_type}":
      command     => "docker-compose -f ${compose_app_type_path} up -d",
      provider    => 'shell',
      environment => $compose_environment,
      unless      => "/usr/bin/test -e ${compose_app_name_path} || /usr/bin/test -e ${compose_app_type_path}",
      onlyif      => "/usr/bin/test -e ${compose_app_type_fallback_path}",
      require     => Class[dockerbridge::image]
    }
  }

  /* compose fallback (if app_name doesn't exist) */
  exec { "compose-default-${app_name}":
    command     => "docker-compose -f ${compose_fallback_path} up -d",
    provider    => 'shell',
    environment => $compose_environment,
    unless      => "/usr/bin/test -e ${compose_app_name_path} || /usr/bin/test -e ${compose_app_type_path} || /usr/bin/test -e ${compose_app_type_fallback_path}",
    require     => Class[dockerbridge::image]
  }

}
