# Manage Windows OS family
class osbaseline::osfamily::windows(
  Array $packages    = [],
  String $minimum_os = '10',
  Hash $registry_keys,
  Hash $registry_values,
  Hash $registryvalues,
) {
  ## VALDIATION
  assert_private()
  validate_re($::os['family'], '^windows$', "${::os[name]} unsupported")

  # We don't want to support old OSes
  if versioncmp($::os['release']['major'], $minimum_os) < 0 {
    fail("${::os[name]} ${::os[release][full]} unsupported")
  }

  ## MANAGED RESOURCES
  create_resources('registry_key', $registry_keys)
  create_resources('registry_value', $registry_values)
  create_resources('registry::value', $registryvalues)
  include chocolatey
}
