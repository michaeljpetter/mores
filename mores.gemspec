require_relative 'lib/mores/version'

Gem::Specification.new do |gem|
  gem.name          = 'mores'
  gem.version       = Mores::VERSION
  gem.author        = 'Michael Petter'
  gem.email         = 'michaeljpetter@gmail.com'

  gem.summary       = 'Customary patterns for ruby'
  gem.description   = <<-END
    Mores provides reusable patterns for ruby.
  END
  gem.homepage      = 'http://github.com/michaeljpetter/mores'
  gem.license       = 'MIT'

  gem.platform      = Gem::Platform::RUBY
  gem.files         = Dir.glob %w(lib/**/* Gemfile *.gemspec LICENSE* README*)
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.7'
  gem.add_development_dependency 'rake', '~> 10.0'
  gem.add_development_dependency 'rspec', '~> 3.4'
  gem.add_development_dependency 'rspec-its', '~> 1.2'
end
