# -*- encoding: utf-8 -*-
require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'vagrant-winrm'
  s.version     = VagrantPlugins::VagrantWinRM::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Baptiste Courtois']
  s.email       = ['b.courtois@criteo.fr']
  s.homepage    = 'https://gitlab.criteois.lan/ruby-gems/vagrant-winrm/'
  s.summary     = 'A Vagrant 1.6+ plugin extending WinRM communication features.'
  s.description = 'A Vagrant 1.6+ plugin that adds new command to extends WinRM communication features.'
  s.license     = 'Apache 2.0'

  s.required_rubygems_version = '>= 1.3.6'

  s.add_dependency 'vagrant', '>= 0.6.0'
  s.add_development_dependency 'bundler', '>= 1.0.0'

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
