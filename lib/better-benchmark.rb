require 'benchmark'
require 'rsruby'

require 'better-benchmark/comparison-partial'
require 'better-benchmark/bencher'

module Benchmark

  BETTER_BENCHMARK_VERSION = '0.8.0'
  DEFAULT_REQUIRED_SIGNIFICANCE = 0.01

  def self.write_realtime( data_dir, &block )
    t = Benchmark.realtime( &block )
    File.open( "#{data_dir}/#{Bencher::DATA_FILE}", 'w' ) do |f|
      f.print t
    end
  end

  # The number of elements in times1 and times2 should be the same.
  # @param [Array] times1
  #   An Array of elapsed times in float form, measured in seconds
  # @param [Array] times2
  #   An Array of elapsed times in float form, measured in seconds
  # @param [Fixnum] required_significance
  #   The maximum p value needed to declare statistical significance
  def self.compare_times( times1, times2, required_significance = DEFAULT_REQUIRED_SIGNIFICANCE )
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
        wilcox_result[ 'p.value' ] < ( required_significance || DEFAULT_REQUIRED_SIGNIFICANCE )
      ),
    }
  end

  # Options:
  #   :iterations
  #     The number of times to execute the pair of blocks.
  #   :inner_iterations
  #     Used to increase the time taken per iteration.
  #   :required_significance
  #     Maximum allowed p value in order to declare the results statistically significant.
  #   :verbose
  #     Whether to print a dot for each iteration (as a sort of progress meter).
  #
  # To use better-benchmark properly, it is important to set :iterations and
  # :inner_iterations properly.  There are a few things to bear in mind:
  #
  # (1) Do not set :iterations too high.  It should normally be in the range
  # of 10-20, but can be lower.  Over 25 should be considered too high.
  # (2) Execution time for one run of the blocks under test should not be too
  # small (or else random variance will muddle the results).  Aim for at least
  # 1.0 seconds per iteration.
  # (3) Minimize the proportion of any warmup time (and cooldown time) of one
  # block run.
  #
  # In order to achieve these goals, you will need to tweak :inner_iterations
  # based on your situation.  The exact number you should use will depend on
  # the strength of the hardware (CPU, RAM, disk), and the amount of work done
  # by the blocks.  For code blocks that execute extremely rapidly, you may
  # need hundreds of thousands of :inner_iterations.
  def self.compare_realtime( options = {}, &block1 )
    options[ :iterations ] ||= 20
    options[ :inner_iterations ] ||= 1

    if options[ :iterations ] > 30
      warn "The number of iterations is set to #{options[ :iterations ]}.  " +
        "Using too many iterations may make the test results less reliable.  " +
        "It is recommended to increase the number of :inner_iterations instead."
    end

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