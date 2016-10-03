class dockerbridge::params (
  $service_provider = 'base',
  $supervisord      = true,
  $supervisorctl    = '/usr/bin/supervisorctl',

  /* one of *.pp files in provision subfolder */
  $provision_with = 'docker_compose',

  /* replaces ${project_name} with app's hash key */
  $default_hosts = '%{project_name}.docker'
)
