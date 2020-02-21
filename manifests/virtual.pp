# Manage virtual services with openvmtools. This only manages VMs
# running on vmware.
class osbaseline::virtual {
  ## VALIDATION
  assert_private()

  ## MANAGED RESOURCES
  case $::kernel {
    'FreeBSD', 'Linux': {
      contain openvmtools

    } default: {
      #NOOP
    }
  }
}
