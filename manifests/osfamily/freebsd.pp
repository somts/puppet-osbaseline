# Class to manage OS-specific aspects of FreeBSD family members.
class osbaseline::osfamily::freebsd(
  String $minimum_os,
) {
  ## VALDIATION
  assert_private()
  validate_re($::os['family'], '^FreeBSD$', "${::os[family]} unsupported")

  # We don't want to support old OSes
  if versioncmp($::os['release']['major'], $minimum_os) < 0 {
    fail("${::os[name]} ${::os[release][full]} unsupported")
  }

  ## MANAGED RESOURCES
  contain pkgng
}
