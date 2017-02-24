/**
 * Run a container using docker::run
 * If puppet_dir fact is set, also mounts the puppet dir using the puppet_dir fact
 */
define dockerbridge::run (
  $options      = {},        /* docker options */
  $puppet_mount = undef,

  $default_hostname = $title,
  $default_image    = 'base',
  $default_env      = ['FACTER_is_container=1'],
) {
  include ::dockerbridge::params

  $real_puppet_mount = $puppet_mount ? {
    default => $puppet_mount,
    undef   => $::dockerbridge::params::puppet_mount
  }

  $default_options = {
    hostname                  => $default_hostname,
    image                     => $default_image,
    remove_container_on_start => true,
    remove_container_on_stop  => true,
  }

  $volumes = $options['volumes'] ? {
    default => concat(["${::puppet_dir}:${real_puppet_mount}"], $options['volumes']),
    undef   => ["${::puppet_dir}:${real_puppet_mount}"]
  }

  $env = $options['env'] ? {
    default => concat($default_env, $options['env']),
    undef   => $default_env
  }

  create_resources('::docker::run', { $title => merge(
    $default_options,
    $options,
    { volumes => $volumes },
    { env => $env }
  ) })

  if ($options['depends']) {
    Docker::Run[$options['depends']] -> Docker::Run[$title]
  }

  /* TODO look into straight exec instead of depending on garethr::docker, in order to lessen need for sudo */
  /* $cidfile = "/var/run/${service_prefix}${sanitised_title}.cid" */

  /* exec { "run ${title} with docker": */
  /*   command     => "${docker_command} run -d ${docker_run_flags} --name ${sanitised_title} --cidfile=${cidfile} --restart=\"${restart}\" ${image} ${command}", */
  /*   unless      => "${docker_command} ps --no-trunc -a | grep `cat ${cidfile}`", */
  /*   environment => 'HOME=/root', */
  /*   path        => ['/bin', '/usr/bin'], */
  /*   timeout     => 0 */
  /* } */
}
