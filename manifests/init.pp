# This module sets up supported operating systems to a baseline.
# It is intended to run as (one of) the first thing in Puppet in 
# order to do things like ensure certain packages/accounts/etc
# exists before higher level configuration management is done.
class osbaseline(
  Array[String] $classes_contain,
  Array[String] $classes_exclude,
  Array[String] $classes_include,
  Array[String] $packages,
  Array[String] $packages_removed,
  Array[String] $realize_accounts_groups,
  Array[String] $realize_accounts_users,
  Hash $crons,
  Hash $execs,
  Hash $files,
  Hash $git_configs,
  Hash $mounts,
  Hash $registry_keys,
  Hash $registry_values,
  Hash $registryvalues,
  Optional[String] $minimum_os,
  Optional[String] $user_homebrew,
  Hash $package_epel,
  Boolean $manage_package_manager,
) {
  ## VALIDATION

  # Optionally don't support old OSes
  if $minimum_os and
  versioncmp($facts['os']['release']['major'], $minimum_os) < 0 {
    fail("${facts['os']['name']} ${facts['os']['release']['full']} unsupported")
  }

  ## MANAGED RESOURCES

  # We may need to manage users (eg root) ahead of anything else
  Class['osbaseline::accounts']
  -> Class['osbaseline::package_manager']
  -> Class['osbaseline::resources']

  contain 'osbaseline::accounts'
  contain 'osbaseline::package_manager'
  contain 'osbaseline::resources'

  # We need the ability to remove packages, and this should be done
  # before any specific osfamily normalization and we intentionally
  # want to avoid NOT using the package {} resource, so that resource
  # conflicts crop up when needed.  Doing that also
  # ensures that we remove packages before installing $packages,
  # allowing us to upgrade packages eg git-216 -> git-224.
  if !empty($packages_removed) {
    package { $packages_removed :
      ensure => 'absent',
      before => Class['osbaseline::package_manager'],
    }
  }
}
