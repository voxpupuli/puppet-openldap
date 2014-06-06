source 'https://rubygems.org'
 
group :development, :test do
  gem 'beaker-rspec', '> 2.0',  :require => false
  gem 'puppetlabs_spec_helper', :require => false
  gem 'puppet-lint',            :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end
