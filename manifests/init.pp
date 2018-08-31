# This module sets up supported operating systems to a baseline.
class osbaseline(
  Hash $crons,
  Hash $files,
  Hash $mounts,
  Array $classes_contain,
  Array $classes_include,
  Array $packages,
) {
  contain osbaseline::osfamily

  # Conditionally include classes and packages, but make sure our
  # baseline classes have run, first.
  ensure_packages($packages,        { require => Class['osbaseline::osfamily']})
  create_resources('cron', $crons,  { require => Class['osbaseline::osfamily']})
  create_resources('file', $files,  { require => Class['osbaseline::osfamily']})
  create_resources('mount', $mounts,{ require => Class['osbaseline::osfamily']})

  $classes_contain.each |String $c| {
    Class['osbaseline::osfamily'] -> Class[$c]
    contain $c
  }
  $classes_include.each |String $c| {
    Class['osbaseline::osfamily'] -> Class[$c]
    include $c
  }
}
