# "install" OS family-specific package managers/custom repos
class osbaseline::package_manager {
  ## VALIDATION
  assert_private("Must only be called by ${module_name}/init.pp")

  ## MANAGED RESOURCES
  case $facts['os']['family'] {
    'Darwin': {
      if $osbaseline::manage_package_manager {
        class { 'homebrew':
          user => $osbaseline::user_homebrew,
        }
      }
    } 'Debian': {
      if $osbaseline::manage_package_manager {
        contain 'apt'
      }
    } 'FreeBSD': {
      if $osbaseline::manage_package_manager {
        contain 'pkgng'
      }
    } 'RedHat': {
      if $osbaseline::manage_package_manager {
        contain 'yum'
      }

      # Install EPEL before we manage yum and potentailly change where
      # we download the data from. Other packages have a dependency on
      # the package it being installed.
      if !empty($osbaseline::package_epel) {
        $before =  defined(Class['yum']) ? {
          true    => Class['yum'],
          default =>  undef,
        }
        create_resources('package', $osbaseline::package_epel, {
          before => $before,
        })
      }
    } 'windows': {
      if $osbaseline::manage_package_manager {
        contain 'chocolatey' # Manage this OS family's package manager(s)
      }
    } default: {
      #NOOP
    }
  }
}
