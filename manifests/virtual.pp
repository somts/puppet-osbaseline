# Manage virtual services like vmtoolds
class osbaseline::virtual(
  Variant[Array,String,Undef] $vmtools_pkg_name,
  Optional[String]            $vmtools_svc_name,
) {
  ## VALIDATION
  assert_private()

  ## MANAGED RESOURCES
  case $::virtual {
    'hyperv': {
      #NOOP -- needs work

    } 'kvm': {
      #NOOP -- needs work

    } 'virtualbox': {
      #NOOP -- needs work and a repo
      # See http://download.virtualbox.org/virtualbox/rpm/el/

    } 'vmware': {
      if undef != $vmtools_pkg_name {
        package { $vmtools_pkg_name :
          notify => Service['vmtoolsd'],
        }
      }
      service { 'vmtoolsd':
        ensure => true,
        enable => true,
        name   => $vmtools_svc_name,
      }

    } 'xenu': {
      #NOOP -- needs work

    } default: {
      #NOOP
    }
  }
}
