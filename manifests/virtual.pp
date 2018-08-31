# Manage virtual services like vmtoolds
class osbaseline::virtual(
  Variant[Array,String,Undef] $vmtools_pkg_name,
  Optional[String]            $vmtools_svc_name,
) {
  ## VALIDATION
  assert_private()

  ## MANAGED RESOURCES
  case $::virtual {
    'vmware': {
      package { $vmtools_pkg_name : }
      ~> service { 'vmtoolsd':
        ensure => true,
        enable => true,
        name   => $vmtools_svc_name,
      }
    } default: {
      #NOOP
    }
  }
}
