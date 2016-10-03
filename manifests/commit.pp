define dockerbridge::commit (
  $container = $title,
  $tag       = undef # defaults to $dockerbridge::params::docker_prefix/$container
) {

  $real_tag = $tag ? {
    undef   => "${dockerbridge::params::docker_prefix}/${container}",
    default => $tag
  }

  /* commit container */
  exec { "commit-${container}":
    command  => "docker commit ${container} ${real_tag}",
    provider => 'shell',
    path     => ['/bin', '/usr/bin']
  }

}
