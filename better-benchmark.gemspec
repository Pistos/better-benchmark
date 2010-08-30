#!/usr/bin/env ruby

require 'rubygems'

spec = Gem::Specification.new do |s|
    s.name = 'better-benchmark'
    s.version = '0.8.0'
    s.summary = 'Statistically correct benchmarking for Ruby.'
    s.description = 'Statistically correct benchmarking for Ruby.'
    s.homepage = 'http://github.com/Pistos/better-benchmark'
    s.add_dependency 'rsruby'
    s.requirements << 'The R project: http://www.r-project.org/'
    s.rubyforge_project = 'better-benchmark'
    s.executables = [ 'bbench' ]

    s.authors = [ 'Pistos' ]
    s.email = 'betterbenchmark dot pistos at purepistos dot net'

    s.files = [
        'README',
        'LICENCE',
        'example.rb',
        'run-example',
        'lib/better-benchmark.rb',
        'bin/bbench',
    ]
    s.extra_rdoc_files = [ 'README', 'LICENCE', ]
end

if $PROGRAM_NAME == __FILE__
    Gem::Builder.new( spec ).build
end
