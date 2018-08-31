# OS family-specific setup
class osbaseline::osfamily(
  Optional[String] $osfamily_class,
) {
  assert_private()

  if undef != $osfamily_class {
    contain $osfamily_class

    # Conditionally manage virtual machine settings if we are managing
    # a known OS.
    Class[$osfamily_class] -> Class[osbaseline::virtual]
    contain osbaseline::virtual
  }
}
