# This module sets up supported operating systems to a baseline.
class osbaseline(
  Hash $crons,
  Hash $execs,
  Hash $files,
  Hash $mounts,
  Hash $git_configs,
  Array $classes_contain,
  Array $classes_include,
  Array $classes_exclude,
  Array $packages,
  Array $packages_removed,
) {
  ## CLASS VARIABLES

  # Some specific roles may need to exclude some otherwise baseline
  # class, so we remove exclusions before we contain()/include().
  $_classes_contain = $classes_contain - $classes_exclude
  $_classes_include = $classes_include - $classes_exclude

  ## MANAGED RESOURCES

  contain osbaseline::osfamily

  # Conditionally include packages, but make sure our baseline has run.
  ensure_packages($packages, { require => Class['osbaseline::osfamily']})

  # We need to include or contain our Arrays of classes before creating
  # any other resources (EG file) in order to be able to depend on
  # those classes when declaring the resources.
  $_classes_contain.each |String $c| {
    Class['osbaseline::osfamily'] -> Class[$c]
    contain $c
  }
  $_classes_include.each |String $c| {
    Class['osbaseline::osfamily'] -> Class[$c]
    include $c
  }

  # Conditionally include resources, but make sure our baseline has run
  create_resources('cron', $crons,  { require => Class['osbaseline::osfamily']})
  create_resources('exec', $execs,  { require => Class['osbaseline::osfamily']})
  create_resources('file', $files,  { require => Class['osbaseline::osfamily']})
  create_resources('mount', $mounts,{ require => Class['osbaseline::osfamily']})

  # We need the ability to remove packages, and this should be done
  # before any specific osfamily normalization and we intentionally
  # want to avoid NOT using the package {} resource, so that resource
  # conflicts crop up when needed.  Doing that also
  # ensures that we remove packages before installing $packages,
  # allowing us to upgrade packages eg git-216 -> git-224.
  if !empty($packages_removed) {
    $packages_removed.each |String $p| {
      package { $p :
        ensure => 'absent',
        before => Class['osbaseline::osfamily'],
      }
    }
  }

  # We may need to manage users (eg root) ahead of anything else
  Class['osbaseline::accounts'] -> Class['osbaseline::osfamily']
  contain osbaseline::accounts

  # We may want to manage git variables if we called git
  if defined(Class['git']) {
    create_resources('git::config', $git_configs, {
      scope   => 'system',
      require => Class['osbaseline::osfamily'],
    })
  }
}
