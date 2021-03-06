# coding: utf-8
require_relative 'lib/scrum_lint/version'

Gem::Specification.new do |spec|
  spec.name    = 'scrum_lint'
  spec.version = ScrumLint::VERSION
  spec.authors = ['Robert Fletcher']
  spec.email   = ['robert@chalkschools.com']

  spec.summary  = 'Toolkit to help manage a very specific Trello workflow'
  spec.homepage = 'https://github.com/ChalkSchools/scrum-lint'
  spec.license  = 'MIT'

  spec.files         = `git ls-files lib util`.split($RS)
  spec.files        += %w(README.md LICENSE.txt CODE_OF_CONDUCT.md)
  spec.bindir        = 'exe'
  exe_files = `git ls-files exe`.split($RS).map { |f| File.basename(f) }
  spec.executables   = exe_files
  spec.require_paths = %w(lib)

  spec.required_ruby_version = '>= 2.1'

  spec.add_dependency 'launchy', '~> 2.4.3'
  spec.add_dependency 'rainbow', '~> 2.1.0'
  spec.add_dependency 'ruby-trello', '~> 1.4'
  spec.add_dependency 'octokit', '~> 4.3.0'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'byebug', '~> 8.2'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.37.1'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.3.1'
  spec.add_development_dependency 'simplecov', '~> 0.11.2'
  spec.add_development_dependency 'webmock', '~> 1.24.0'
end
