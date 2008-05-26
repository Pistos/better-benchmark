require 'benchmark'
require 'rsruby'

module Benchmark
  
  class ComparisonPartial
    def initialize( block, options )
      @block1 = block
      @options = options
    end
    
    def with( &block2 )
      times1 = []
      times2 = []
      
      (1..@options[ :iterations ]).each do |iteration|
        if @options[ :verbose ]
          $stdout.print "."; $stdout.flush
        end
        
        times1 << Benchmark.realtime { @block1.call( iteration ) }
        times2 << Benchmark.realtime { block2.call( iteration ) }
      end
      
      r = RSRuby.instance
      wilcox_result = r.wilcox_test( times1, times2 )
  
      {
        :results1 => {
          :times => times1,
          :mean => r.mean( times1 ),
          :stddev => r.sd( times1 ),
        },
        :results2 => {
          :times => times2,
          :mean => r.mean( times2 ),
          :stddev => r.sd( times2 ),
        },
        :p => wilcox_result[ 'p.value' ],
        :W => wilcox_result[ 'statistic' ][ 'W' ],
        :significant => (
          wilcox_result[ 'p.value' ] < @options[ :required_significance ]
        ),
      }
    end
    alias to with
  end
  
  def self.compare_realtime( options = {}, &block1 )
    options[ :iterations ] ||= 20
    options[ :required_significance ] ||= 0.01
    
    ComparisonPartial.new( block1, options )
  end
  
  def self.report_on( result )
    puts
    puts( "Set 1 mean: %.3f s" % [ result[ :results1 ][ :mean ] ] )
    puts( "Set 1 std dev: %.3f" % [ result[ :results1 ][ :stddev ] ] )
    puts( "Set 2 mean: %.3f s" % [ result[ :results2 ][ :mean ] ] )
    puts( "Set 2 std dev: %.3f" % [ result[ :results2 ][ :stddev ] ] )
    puts "p.value: #{result[ :p ]}"
    puts "W: #{result[ :W ]}"
    puts(
      "The difference (%+.1f%%) %s statistically significant." % [
        ( ( result[ :results2 ][ :mean ] - result[ :results1 ][ :mean ] ) / result[ :results1 ][ :mean ] ) * 100,
        result[ :significant ] ? 'IS' : 'IS NOT'
      ]
    )
  end
end