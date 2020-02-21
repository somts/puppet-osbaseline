# OS family-specific setup
class osbaseline::osfamily(
  Optional[String] $osfamily_class,
) {
  assert_private()

  if undef != $osfamily_class { contain $osfamily_class }
}
