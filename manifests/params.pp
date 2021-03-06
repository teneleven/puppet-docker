class dockerbridge::params (
  $service_provider = 'base',

  /* one of *.pp files in provision subfolder */
  $provision_with = 'docker_compose',

  /* replaces ${project_name} with app's hash key */
  $default_hosts = '${project_name}.docker',

  $docker_prefix         = 'local',  /* for use to commit container after provisioning */
  $docker_compose_suffix = '_web_1', /* for use during provisioning docker-compose container */

  $provision_cmd = 'sh /provision.sh',
  $reload_cmd    = '/usr/bin/supervisorctl reload',

  $puppet_mount   = '/puppet',   /* destination mount on the container */

  /* docker-compose settings */
  $compose_file         = "services.yaml",
  $compose_default      = "services.yaml",
  $compose_dir          = "%{::volume_dir}/devops/apps",
  $compose_fallback_dir = "%{::volume_dir}/devops/apps/default",
) {}
