#!/usr/bin/env ruby

require 'better-benchmark'

def report( result )
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

NUM_INNER_ITERATIONS = 500000

# Provide two blocks of code to compare.  For example, two blocks that
# accomplish the same thing, but differ in implementation.  For optimal
# results, the amount of time to execute a single iteration should be large
# enough to adequately diminish the significance of any startup and stoppage
# time of one iteration.  The number of benchmark iterations should not be
# too large; better to increase the amount of work done per iteration.

result = Benchmark.compare_realtime(
  :iterations => 20,
  :verbose => true
) { |iteration|
  NUM_INNER_ITERATIONS.times do
    if 1 < 2
      x = 'foo'
    else
      x = 'bar'
    end
  end
}.with { |iteration|
  NUM_INNER_ITERATIONS.times do
    x = ( 1 < 2 ? 'foo' : 'bar' )
  end  
}
report result

