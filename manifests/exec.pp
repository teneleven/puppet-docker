/**
 * Run something in a container using docker::exec
 */
define dockerbridge::exec (
  $container = $title,

  /* docker::exec options */
  $options   = {}
) {
  include ::dockerbridge

  create_resources('::docker::exec', { "exec-${title}" => merge({
    container     => $container,
    sanitise_name => false,
  }, $options)})
}
