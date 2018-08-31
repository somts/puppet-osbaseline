# Class to manage OS-specific aspects of Debian family members.
class osbaseline::osfamily::debian(
  String $minimum_os,
) {
  ## VALDIATION
  assert_private()
  validate_re($::os['family'], '^Debian$', "${::os[family]} unsupported")

  # We don't want to support old OSes
  if versioncmp($::os['release']['major'], $minimum_os) < 0 {
    fail("${::os[name]} ${::os[release][full]} unsupported")
  }

  ## MANAGED RESOURCES
  # Manage this OS family's package manager(s)
  contain apt
}
