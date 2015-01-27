module Benchmark
  class ComparisonPartial
    # @param options [Hash] @see Benchmark.compare_realtime
    def initialize( block, options )
      @block1 = block
      @options = options

      @options[:iterations] ||= 20
      @options[:inner_iterations] ||= 1
      @options[:warmup_iterations] ||= 0

      if @options[:iterations] > 30
        warn "The number of iterations is set to #{@options[:iterations]}.  " +
        "Using too many iterations may make the test results less reliable.  " +
        "It is recommended to increase the number of :inner_iterations instead."
      end
    end

    def with( &block2 )
      times1 = []
      times2 = []

      (1..@options[:iterations]).each do |iteration|
        if @options[:verbose]
          $stdout.print "."; $stdout.flush
        end

        @options[:warmup_iterations].times do |i|
          @block1.call( iteration )
        end
        times1 << Benchmark.realtime do
          @options[:inner_iterations].times do |i|
            @block1.call( iteration )
          end
        end

        @options[:warmup_iterations].times do |i|
          block2.call( iteration )
        end
        times2 << Benchmark.realtime do
          @options[:inner_iterations].times do |i|
            block2.call( iteration )
          end
        end
      end

      ::Benchmark.compare_times( times1, times2, @options[:required_significance] )
    end
    alias to with
  end
end
