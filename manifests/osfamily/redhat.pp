# Class to manage OS-specific aspects of RedHat family members.
class osbaseline::osfamily::redhat(
  String $minimum_os,
) {
  ## VALDIATION
  assert_private()
  validate_re($::os['family'], '^RedHat$', "${::os[family]} unsupported")

  # We don't want to support old OSes
  if versioncmp($::os['release']['major'], $minimum_os) < 0 {
    fail("${::os[name]} ${::os[release][full]} unsupported")
  }

  ## MANAGED RESOURCES

  # Manage this OS family's package manager(s)
  include epel
  contain yum

  # we need this installed for IUS, but epel module does not install.
  ensure_packages(['epel-release'],{
    before  => Class['epel'],
    require => Class['yum'],
  })
}
