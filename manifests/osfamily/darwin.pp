# Class to manage OS-specific aspects of Darwin family members.
class osbaseline::osfamily::darwin(
  String $minimum_os,
  String $homebrew_user,
) {
  ## VALDIATION
  assert_private()
  validate_re($::os['family'], '^Darwin$', "${::os[family]} unsupported")

  # We don't want to support old OSes
  if versioncmp($::os['release']['major'], $minimum_os) < 0 {
    fail("${::os[name]} ${::os[release][full]} unsupported")
  }

  class { 'homebrew': user => $homebrew_user }
}
