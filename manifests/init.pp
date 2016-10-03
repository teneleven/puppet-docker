class dockerbridge (
  $apps = {}
) inherits dockerbridge::params {

  if ($::is_container) {
    contain dockerbridge::container
  } elsif (!empty($apps)) {
    $apps.each |$app_name, $app| {
      $app_default_hosts = regsubst($default_hosts, '\$\{project_name\}', $app_name, 'GI')

      create_resources('::dockerbridge::provision', {
        $app_name => is_hash($app) ? {
          true  => $app,
          false => {
            'type'  => $app,
            'hosts' => any2array($app_default_hosts)
          }
        }
      })
    }
  }

}
