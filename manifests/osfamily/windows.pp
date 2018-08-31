# Manage Windows OS family
class osbaseline::osfamily::windows(
  Array $packages    = [],
  String $minimum_os = '10',
) {
  ## VALDIATION
  assert_private()
  validate_re($::os['family'], '^windows$', "${::os[name]} unsupported")

  # We don't want to support old OSes
  if versioncmp($::os['release']['major'], $minimum_os) < 0 {
    fail("${::os[name]} ${::os[release][full]} unsupported")
  }

  ## MANAGED RESOURCES
  #include cygwin
  #include chocolatey
}
