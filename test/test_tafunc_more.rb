require 'helper'


#
require "tafunc_array"


class TestTAFuncMore < Test::Unit::TestCase

  #
  #
  #
  def setup
    @test_func = :MACDEXT
    @testee = TaLib::TAFunc.new( @test_func )
  end

  def teardown
  end

  #
  def test_result
    assert_equal( [], @testee.result )
  end


  #
  def test_array

    #
    tmp = [ 1.0, 2.0, 3.0, 4.0, 5.0 ].tafunc( :MACDEXT ) do |tf|
      tf.param_opt_in_fast_period    = 2
      tf.param_opt_in_fast_ma_type   = 1
      tf.param_opt_in_slow_period    = 3
      tf.param_opt_in_slow_ma_type   = 1
      tf.param_opt_in_signal_period  = 1
      tf.param_opt_in_signal_ma_type = 1
    end

    #
    exp = {
      :start_idx    => 2,
      :num_elements => 3,
      :param_out_macd        => [ 0.5, 0.5, 0.5, nil, nil],
      :param_out_macd_signal => [ 0.5, 0.5, 0.5, nil, nil],
      :param_out_macd_hist   => [ 0.0, 0.0, 0.0, nil, nil],
    }

    assert_equal( exp, tmp )

  end

end
