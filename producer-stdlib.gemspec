require File.expand_path('../lib/producer/stdlib/version', __FILE__)

Gem::Specification.new do |s|
  s.name    = 'producer-stdlib'
  s.version = Producer::STDLib::VERSION.dup
  s.summary = 'Provisioning tool'
  s.description = <<-eoh.gsub(/^ +/, '')
    Standard library for producer (gem: producer-core).
  eoh
  s.homepage = 'https://rubygems.org/gems/producer-stdlib'

  s.authors = 'Thibault Jouan'
  s.email   = 'tj@a13.fr'

  s.files = `git ls-files`.split $/

    s.add_dependency 'producer-core', '~> 0.2', '>= 0.2.13'
end
