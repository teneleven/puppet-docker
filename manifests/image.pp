/* represents a base container that provisions itself using puppet */
class dockerbridge::image (
  $image_name = 'base',
  $docker_dir = './'
) {
  docker::image { $image_name:
    docker_dir => $docker_dir,
    ensure     => latest,
  }
}
