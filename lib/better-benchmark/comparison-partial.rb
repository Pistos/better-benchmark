module Benchmark
  class ComparisonPartial
    # @param options [Hash] @see Benchmark.compare_realtime
    def initialize( block, options )
      @block1 = block
      @options = options
    end

    def with( &block2 )
      times1 = []
      times2 = []

      (1..@options[:iterations]).each do |iteration|
        if @options[:verbose]
          $stdout.print "."; $stdout.flush
        end

        times1 << Benchmark.realtime do
          @options[:inner_iterations].times do |i|
            @block1.call( iteration )
          end
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
