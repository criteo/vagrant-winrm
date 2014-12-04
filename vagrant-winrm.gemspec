# -*- encoding: utf-8 -*-
require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'vagrant-winrm'
  s.version     = VagrantPlugins::VagrantWinRM::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Baptiste Courtois']
  s.email       = ['b.courtois@criteo.fr']
  s.homepage    = 'https://github.com/criteo/vagrant-winrm/'
  s.summary     = 'A Vagrant 1.6+ plugin extending WinRM communication features.'
  s.description = 'A Vagrant 1.6+ plugin that adds new command to extends WinRM communication features.'
  s.license     = 'Apache 2.0'

  s.required_rubygems_version = '>= 2.0.0'

  s.add_dependency 'minitar', '~> 0.5'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec_junit_formatter'
  s.add_development_dependency 'rspec-core', '~> 3.0'
  s.add_development_dependency 'rspec-expectations', '~> 3.0'
  s.add_development_dependency 'rspec-mocks', '~> 3.0'

  s.add_development_dependency 'bundler', '~> 1.0'

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map { |f| f =~ /^bin\/(.*)/ ? $1 : nil }.compact
  s.require_path = 'lib'
end
