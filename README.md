# Better Benchmark

Statistically correct benchmarking for Ruby.

## Dependencies

The R Project: http://www.r-project.org/
rsruby: http://web.kuicr.kyoto-u.ac.jp/~alexg/rsruby/

## Usage

### Comparing code blocks

result = Benchmark.compare_realtime {
  do_something_one_way
}.with {
  do_it_another_way
}
Benchmark.report_on result

See also example.rb for a more comprehensive example.

### Comparing git revisions

#### With a test script (recommended)

To test two revisions of a library, create a simple runner script:

    # runner.rb
    require 'mylib'

    class TestQuick
      def initialize
        # initialization...
      end

      def run
        Benchmark.write_realtime( '/home/pistos/tmp' ) do
          5000.times do
            # do something with your lib
          end
        end
      end
    end

    t = TestQuick.new
    t.run

Then run the bbench script, passing two git revisions:

    bbench -r 6e84dd5 -r ed1e7c6 -d ~/tmp -- -Ilib test-quick.rb

#### Without altering or writing new code

You can also test two revisions by running some already-existing script,
such as a file in your test suite:

    bbench -r 6e84dd5 -r ed1e7c6 -- -Itest -Ilib test/test_something.rb

Be aware, however, that this may produce unnecessarily variant timings due to
wide variance in the startup time of the Ruby interpreter and script.

## Interpretation

Considering two "things under test", U1 and U2:

### Example 1

    Set 1 mean: 0.216 s
    Set 1 std dev: 0.023
    Set 2 mean: 0.187 s
    Set 2 std dev: 0.020
    p.value: 0.00287947346770876
    W: 88.0
    The difference (-13.5%) IS statistically significant.

This means that the results permit us to conclude that the U2 performs 13.5%
faster than U1.

### Example 2

    Set 1 mean: 10.968 s
    Set 1 std dev: 4.294
    Set 2 mean: 9.036 s
    Set 2 std dev: 3.581
    p.value: 0.217562623135379
    W: 67.0
    The difference (-17.6%) IS NOT statistically significant.

This means that the results do not permit us to conclude anything; neither that
U1 performs faster than U2, nor that U2 performs faster than U1, nor even that
their performance is equivalent.

## Help, etc.

irc.freenode.net#mathetes or http://webchat.freenode.net?channels=mathetes .

## Repository

git clone git://github.com/Pistos/better-benchmark.git
