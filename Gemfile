# frozen_string_literal: true

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

### Environment variable version overrrides

# Per puppet enterprise, set the versions of critical software.
puppetversion = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'] : '5.5.19'
# 3.11.12 not per available https://rubygems.org/gems/facter/versions
# and <4.0.11 results in 2.5.7 (too old)
# facterversion = ENV.key?('FACTER_VERSION') ? ENV['FACTER_VERSION'] : '~>3.0'

# Select compatible version of rubocop
rubocopversion = RUBY_VERSION < '2.5.0' ? '<2.5.0' : '>=2.5.0'

### Gem requirements
group :puppet do
  # we need > 2 < 4, but this is a big problem right now. Settle for what we can get.
  # gem 'facter', facterversion
  gem 'facter'
  gem 'hiera-eyaml'
  gem 'pdk'
  gem 'puppet', puppetversion
  gem 'puppetlabs_spec_helper', '>= 1.0.0'
  gem 'puppet-syntax', require: false
  gem 'rspec-puppet', '>= 2.6.11'
  gem 'rspec-puppet-facts'
  gem 'semantic_puppet'
  # deps
  # gem 'ruby-curl' # needed to build facter 3.12.2
  # gem 'gettext'  # needed to build facter 3.12.2
end

group :lint do
  gem 'puppet-lint', '>= 1.0.0'
  # http://www.camptocamp.com/en/actualite/getting-code-ready-puppet-4/
  # gem 'puppet-lint-absolute_classname-check'
  gem 'puppet-lint-empty_string-check'
  gem 'puppet-lint-leading_zero-check'
  gem 'puppet-lint-roles_and_profiles-check'
  gem 'puppet-lint-spaceship_operator_without_tag-check'
  gem 'puppet-lint-undef_in_function-check'
  gem 'puppet-lint-unquoted_string-check'
  gem 'puppet-lint-variable_contains_upcase'
end

gem 'ci_reporter_rspec'
gem 'git'
gem 'json_pure'
gem 'kramdown' # for markdown parsing
gem 'metadata-json-lint'
gem 'onceover' # https://puppet.com/blog/use-onceover-start-testing-rspec-puppet
gem 'parallel_tests'
gem 'ruby-pwsh' # for Powershell parsing

# rspec must be v2 for ruby 1.8.7
if RUBY_VERSION >= '1.8.7' && RUBY_VERSION < '1.9'
  gem 'rake', '~> 10.0'
  gem 'rspec', '~> 2.0'
else
  # rubocop requires ruby >= 1.9, but < 2.2.0 need 0.58.0
  gem 'rubocop', rubocopversion
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
end
