require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet'
require 'rspec-puppet-facts'
# rubocop:disable Style/MixinUsage
include RspecPuppetFacts
# rubocop:enable Style/MixinUsage

# Add the custom facts to all tests
add_custom_fact :concat_basedir, '/concatdummy'
add_custom_fact :facterversion, '3.11.7'
add_custom_fact :mco_confdir, '/mcodummy'
add_custom_fact :puppet_confdir, '/puppetdummy'
add_custom_fact :puppet_agent_appdata, nil
add_custom_fact :puppet_server, 'puppet.example.com'
add_custom_fact :puppetversion, '5.5.10'
add_custom_fact :virtual, nil

# Add customized Darwin facts
add_custom_fact :has_compiler, nil, confine: 'darwin-16-x86_64'

# Add customized Windows facts
add_custom_fact :archive_windir, 'c:/tmp', confine: [
  'windows-10-x86_64',
  'windows-2016-x86_64'
]
add_custom_fact :choco_install_path, 'c:/programdata/chocolatey', confine: [
  'windows-10-x86_64',
  'windows-2016-x86_64'
]

RSpec.configure do |config|
  # normal rspec-puppet configuration
end

## Shared contexts to cut down on copy/paste testing code
# shared variables for all contexts are defined in the Helpers class above
shared_context 'Unsupported Platform' do
  it 'should complain about being unsupported' do
    should raise_error(Puppet::Error, /unsupported/i)
  end
end
