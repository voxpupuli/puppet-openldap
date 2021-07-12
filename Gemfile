source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development do
  gem 'ruby-augeas',                 :require => false
  gem 'github_changelog_generator',  :require => false
end

gem 'puppetlabs_spec_helper', '>= 2', '< 4', :require => false
gem 'rake', :require => false
gem 'facter', ENV['FACTER_GEM_VERSION'], :require => false, :groups => [:test]

puppetversion = ENV['PUPPET_VERSION'] || '>= 6.0'
gem 'puppet', puppetversion, :require => false, :groups => [:test]

# vim: syntax=ruby
