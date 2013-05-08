require_relative '../lib/better-benchmark'

describe "Benchmark::Comparer" do
  context "given two CSV files containing timing data" do
    if ! method_defined? :__dir__
      def __dir__
        File.dirname(File.realpath(__FILE__))
      end
    end

    before :each do
      @comparer = Benchmark::Comparer.new(["#{__dir__}/timings1.csv", "#{__dir__}/timings2.csv"])
    end

    it 'should return a Hash of results keyed on the things tested' do
      results = @comparer.run
      expect( results["foobar"][:improvement] ).to be_within(0.0005).of(-0.004)
      expect( results["foobar"][:significant] ).to be_false
      expect( results["def"][:improvement] ).to be_within(0.01).of(-0.56)
      expect( results["def"][:significant] ).to be_true
    end
  end
end
