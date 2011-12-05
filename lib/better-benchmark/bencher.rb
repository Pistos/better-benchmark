module Benchmark
  class Bencher
    DATA_FILE = 'bbench-run-time'

    def print_usage
      puts "#{$0} [-i <iterations>] [-w] [-r <revision 1> -r <revision 2>] [-p <max p-value>] [-d <data tmp dir>] [-e <executable/interpreter>] -- <executable's args...>"
    end

    # @param [Array] argv
    #   The command line arguments passed to the bencher script
    def initialize( argv )
      @iterations = 10
      @executable = 'ruby'

      while argv.any?
        arg = argv.shift
        case arg
        when '-d'
          @data_dir = argv.shift
          begin
            if ! File.stat( @data_dir ).directory?
              $stderr.puts "#{@data_dir} is not a directory."
              exit 3
            end
          rescue Errno::ENOENT
            $stderr.puts "#{@data_dir} does not exist."
            exit 4
          end
        when '-e'
          @executable = argv.shift
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
        when '-w'
          @test_working_copy = true
        when '--'
          @executable_args = argv.dup
          argv.clear
        end
      end

      if ( ! @test_working_copy && ( @r1.nil? || @r2.nil? ) ) || @executable_args.nil?
        print_usage
        exit 2
      end
    end

    def one_run
      system "#{@executable} #{ @executable_args.join(' ') }"  or exit $?.to_i
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
        if @test_working_copy
          system "git stash -q"  or exit $?.to_i
        else
          system "git checkout #{@r1}"  or exit $?.to_i
        end
        times1 << time_one_run

        if @test_working_copy
          system "git stash pop -q"  or exit $?.to_i
        else
          system "git checkout #{@r2}"  or exit $?.to_i
        end
        times2 << time_one_run
      end

      ::Benchmark.report_on(
        ::Benchmark.compare_times( times1, times2, @max_p )
      )
    end
  end
end
