# Manage OS baseline resources
class osbaseline::resources {
  ## VALIDATION
  assert_private("Must only be called by ${module_name}/init.pp")

  ## CLASS VARIABLES

  # Some specific roles may need to exclude some otherwise baseline
  # class, so we remove exclusions before we contain()/include().
  $classes_contain = $osbaseline::classes_contain - $osbaseline::classes_exclude
  $classes_include = $osbaseline::classes_include - $osbaseline::classes_exclude

  ## MANAGED RESOURCES

  if $facts['virtual'] == 'vmware' { contain 'openvmtools' }

  # Conditionally ensure packages, but make sure our baseline has run.
  ensure_packages($osbaseline::packages)

  # Conditionally include resources, but make sure our baseline has run
  create_resources('exec', $osbaseline::execs)
  create_resources('file', $osbaseline::files)

  case $facts['kernel'] {
    'Darwin', 'FreeBSD', 'Linux': {
      create_resources('cron', $osbaseline::crons)
      create_resources('mount', $osbaseline::mounts)
    } 'windows': {
      create_resources('registry::value', $osbaseline::registryvalues)
      create_resources('registry_key', $osbaseline::registry_keys)
      create_resources('registry_value', $osbaseline::registry_values)
    } default: {
      #NOOP
    }
  }

  # We need to include or contain our Arrays of classes before creating
  # any other resources (EG file) in order to be able to depend on
  # those classes when declaring the resources.
  $classes_contain.each |String $c| { contain $c }
  $classes_include.each |String $c| { include $c }

  # We may want to manage git variables if we called git
  if defined(Class['git']) {
    create_resources('git::config', $osbaseline::git_configs, {
      scope   => 'system',
    })
  }
}
