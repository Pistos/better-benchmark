require 'csv'

module Benchmark
  class Comparer
    def print_usage
      puts "bbench compare [-p <max p-value>] <timings1.csv> <timings2.csv>"
    end

    # @param [Array] argv
    #   The command line arguments passed to the bencher script
    # Expected column layout of the CSV files is:
    # <identifier of thing tested>,<time in fractional seconds>
    def initialize( argv )
      @iterations = 10
      @executable = 'ruby'

      while argv.any?
        arg = argv.shift
        case arg
        when '-p'
          @max_p = argv.shift
        else
          if @file1.nil?
            @file1 = arg
          elsif @file2.nil?
            @file2 = arg
          end
        end
      end

      if @file1.nil? || @file2.nil?
        print_usage
        exit 2
      end

      @timings_before = Hash.new { |h,k| h[k] = Array.new }
      @timings_after = Hash.new { |h,k| h[k] = Array.new }
    end

    def run
      CSV.foreach(@file1) do |row|
        @timings_before[ row[0] ] << row[1].to_f
      end
      CSV.foreach(@file2) do |row|
        @timings_after[ row[0] ] << row[1].to_f
      end

      run_results = Hash.new
      @timings_before.each_key do |thing_tested|
        results = Benchmark.compare_times( @timings_before[thing_tested], @timings_after[thing_tested], @max_p )
        improvement = ( results[:results2][:mean] - results[:results1][:mean] ) / results[:results1][:mean]

        run_results[thing_tested] = { improvement: improvement, significant: results[:significant] }
        puts( "%s\t%+.1f%%\t%s" % [thing_tested, improvement * 100.0, results[:significant] ? '*' : '' ] )
      end

      run_results
    end
  end
end
