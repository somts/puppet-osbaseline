# This module sets up supported operating systems to a baseline.
class osbaseline(
  Hash $crons,
  Hash $files,
  Hash $mounts,
  Array $classes_contain,
  Array $classes_include,
  Array $classes_exclusions,
  Array $packages,
) {
  contain osbaseline::osfamily

  # Conditionally include classes and packages, but make sure our
  # baseline classes have run, first.
  ensure_packages($packages,        { require => Class['osbaseline::osfamily']})
  create_resources('cron', $crons,  { require => Class['osbaseline::osfamily']})
  create_resources('file', $files,  { require => Class['osbaseline::osfamily']})
  create_resources('mount', $mounts,{ require => Class['osbaseline::osfamily']})

  # Some specific roles may need to exclude some otherwise baseline
  # class, so we remove exclusions before we contain()/include().
  $_classes_contain = $classes_contain - $classes_exclusions
  $_classes_include = $classes_include - $classes_exclusions

  $_classes_contain.each |String $c| {
    Class['osbaseline::osfamily'] -> Class[$c]
    contain $c
  }
  $_classes_include.each |String $c| {
    Class['osbaseline::osfamily'] -> Class[$c]
    include $c
  }
}
