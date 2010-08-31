module Benchmark
  class Bencher
    DATA_FILE = 'bbench-run-time'

    def print_usage
      puts "#{$0} [-i <iterations>] -r <revision 1> -r <revision 2> [-p <max p-value>] [-d <data tmp dir>] -- <ruby args...>"
    end

    # @param [Array] argv
    #   The command line arguments passed to the bencher script
    def initialize( argv )
      @iterations = 10

      while argv.any?
        arg = argv.shift
        case arg
        when '-d'
          @data_dir = argv.shift
          if ! Dir.exists?( @data_dir )
            $stderr.puts "#{@data_dir} does not exist."
            exit 3
          end
          if ! File.directory?( @data_dir )
            $stderr.puts "#{@data_dir} is not a directory."
            exit 4
          end
        when '-i'
          @iterations = argv.shift.to_i
        when '-p'
          @max_p = argv.shift
        when '-r'
          if @r1.nil?
            @r1 = argv.shift
          else
            @r2 = argv.shift
          end
        when '--'
          @ruby_args = argv.dup
          argv.clear
        end
      end

      if @r1.nil? || @r2.nil? || @ruby_args.nil?
        print_usage
        exit 2
      end
    end

    def one_run
      system "ruby #{ @ruby_args.join(' ') }"  or exit $?
    end

    def time_one_run
      if @data_dir
        one_run
        File.read( "#{@data_dir}/#{DATA_FILE}" ).to_f
      else
        t0 = Time.now
        one_run
        Time.now.to_f - t0.to_f
      end
    end

    def run
      times1 = []
      times2 = []

      @iterations.times do
        system "git checkout #{@r1}"  or exit $?
        times1 << time_one_run

        system "git checkout #{@r2}"  or exit $?
        times2 << time_one_run
      end

      ::Benchmark.report_on(
        ::Benchmark.compare_times( times1, times2, @max_p )
      )
    end
  end
end