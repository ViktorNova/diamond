require "helper"

class Diamond::SequenceParametersTest < Minitest::Test

  context "SequenceParameters" do

    setup do
      @sequence = Diamond::Sequence.new
      @params = Diamond::SequenceParameters.new(@sequence, 128) { @sequence.mark_changed }
    end

    context "#rate=" do

      setup do
        @sequence.expects(:mark_changed).times(7)
      end

      teardown do
        @sequence.unstub(:mark_changed)
      end

      should "set rate" do
        @params.rate = 16
        assert_equal 16, @params.rate
      end

      should "scale gate down" do
        @params.rate = 16
        @params.gate = 50
        assert_equal 16, @params.rate
        assert_equal 50, @params.gate

        @params.rate = 8
        assert_equal 8, @params.rate
        assert_equal 25, @params.gate
      end

      should "scale gate up" do
        @params.rate = 8
        @params.gate = 50
        assert_equal 8, @params.rate
        assert_equal 50, @params.gate

        @params.rate = 16
        assert_equal 16, @params.rate
        assert_equal 100, @params.gate
      end

    end

    context "#range=" do

      setup do
        @sequence.expects(:mark_changed).times(2)
      end

      teardown do
        @sequence.unstub(:mark_changed)
      end

      should "set range" do
        @params.range = 4
        assert_equal 4, @params.range

        @params.range += 1
        assert_equal 5, @params.range
      end

    end

    context "#interval=" do

      setup do
        @sequence.expects(:mark_changed).once
      end

      teardown do
        @sequence.unstub(:mark_changed)
      end

      should "set interval" do
        refute_equal 7, @params.interval
        @params.interval = 7
        assert_equal 7, @params.interval
      end

    end

    context "#gate=" do

      setup do
        @sequence.expects(:mark_changed).times(3)
      end

      teardown do
        @sequence.unstub(:mark_changed)
      end

      should "set gate" do
        refute_equal 125, @params.gate
        @params.gate = 125
        assert_equal 125, @params.gate
      end

      should "constrain gate to what rate and resolution allow for" do
        @params.rate = 16
        @params.gate = 10
        assert_equal 13, @params.gate
      end

    end

    context "#pattern_offset=" do

      setup do
        @sequence.expects(:mark_changed).once
      end

      teardown do
        @sequence.unstub(:mark_changed)
      end

      should "set pattern offset" do
        refute_equal 5, @params.pattern_offset
        @params.pattern_offset = 5
        assert_equal 5, @params.pattern_offset
      end

    end

    context "#constrain" do

      should "constrain max only" do
        assert_equal 40, @params.send(:constrain, 50, :max => 40)
        assert_equal 30, @params.send(:constrain, 30, :max => 40)
      end

      should "constain min only" do
        assert_equal 40, @params.send(:constrain, 30, :min => 40)
        assert_equal 50, @params.send(:constrain, 50, :min => 40)
      end

      should "constrain to min and max" do
        assert_equal 10, @params.send(:constrain, 5, :min => 10, :max => 100)
        assert_equal 100, @params.send(:constrain, 500, :min => 10, :max => 100)
        assert_equal 50, @params.send(:constrain, 50, :min => 10, :max => 100)
      end

      should "constrain to range" do
        assert_equal 10, @params.send(:constrain, 5, :range => 10..100)
        assert_equal 100, @params.send(:constrain, 500, :range => 10..100)
        assert_equal 50, @params.send(:constrain, 50, :range => 10..100)
      end

    end
  end
end
