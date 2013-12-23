require 'helper'

class TestTAFunc < Test::Unit::TestCase

  #
  #
  #
  def setup
    
    # TA-Lib's MACD has a bug when signal_period = 1.
    # so DO NOT USE.
    #@test_func = :MACD
    @test_func = :MACDEXT
    @testee    = TaLib::TAFunc.new( @test_func )

  end

  def teardown
  end

  # test for initialize function(tafunc) object.
  #
  #
  def test_new

    # inputs.
    attr_in = @testee.param_attr( :in )
    assert_equal( [:param_in_real], attr_in )
    assert_equal( nil, @testee.param_in_real )  # check initial value.

    # options.
    attr_opt = @testee.param_attr( :opt )
    assert_equal( [:param_opt_in_fast_period,
     :param_opt_in_fast_ma_type,
     :param_opt_in_slow_period,
     :param_opt_in_slow_ma_type,
     :param_opt_in_signal_period,
     :param_opt_in_signal_ma_type], attr_opt )

    # outputs.
    attr_out = @testee.param_attr( :out )
    assert_equal( [:param_out_macd,
                   :param_out_macd_signal,
                   :param_out_macd_hist], attr_out )
    assert_equal( nil, @testee.param_out_macd )
    assert_equal( nil, @testee.param_out_macd_signal )
    assert_equal( nil, @testee.param_out_macd_hist )

    #
    tmp = [0.0, 1.0, 2.0]
    assert_raise(RuntimeError){ @testee.param_in_real( tmp ) }

    #
    #pp @testee.singleton_methods
    @testee.param_in_real = tmp
    assert_equal( tmp, @testee.param_in_real )

    ret = @testee.param_out_setting
    assert_equal( [nil,nil,nil], @testee.param_out_macd )
    assert_equal( { :param_out_macd        => [nil,nil,nil],
                    :param_out_macd_signal => [nil,nil,nil],
                    :param_out_macd_hist   => [nil,nil,nil],
                  }, ret )


  end

  # ==== ATTENTION
  # Don't use MACD. It has a bug when signal_period = 1.
  #
  def test_new_1

    #
    assert_nothing_raised { TaLib::TAFunc.new( "MACD" ) }

    #
    assert_nothing_raised { TaLib::TAFunc.new( :MACD ) }

    #
    e = assert_raise( RuntimeError ) { TaLib::TAFunc.new( [:MACD] ) }
    assert_equal( 0, e.message =~ /Type error for the function name:/ )

    #
    e = assert_raise( RuntimeError ) { taf = TaLib::TAFunc.new( "" ) }

    #
    e = assert_raise( RuntimeError ) { taf = TaLib::TAFunc.new( "nonamef" ) }
    assert_equal( false, e.message.match(/^no such function: nonamef/i).nil? )


  end

  #
  #
  #
  def test_struct_ta_types
    exp = [
      :TA_RealRange,
      :TA_IntegerRange,
      :TA_RealDataPair,
      :TA_IntegerDataPair,
      :TA_RealList,
      :TA_IntegerList,
      :TA_InputParameterInfo,
      :TA_OptInputParameterInfo,
      :TA_OutputParameterInfo,
    ]
    assert_equal( exp, Struct.ta_types )
    #assert_equal( exp, Struct::TA_RealRange.to_s )
    #assert_equal( false, Struct::TA_InputParameterInfo.new )

  end

  #
  #
  #
  def test_talib_module

    assert_equal( Module, TaLib.class )

    #
    exp = {
      0=>:TA_Input_Price,
      1=>:TA_Input_Real,
      2=>:TA_Input_Integer,
    }
    assert_equal( exp, TaLib.input_types )

    #
    exp = {
      0=>:TA_OptInput_RealRange,
      1=>:TA_OptInput_RealList,
      2=>:TA_OptInput_IntegerRange,
      3=>:TA_OptInput_IntegerList,
    }
    assert_equal( exp, TaLib.optinput_types )

    #
    exp = {
      0=>:TA_Output_Real,
      1=>:TA_Output_Integer,
    }
    assert_equal( exp, TaLib.output_types )

    #
    exp = {
      0=>:TA_MAType_SMA,
      1=>:TA_MAType_EMA,
      2=>:TA_MAType_WMA,
      3=>:TA_MAType_DEMA,
      4=>:TA_MAType_TEMA,
      5=>:TA_MAType_TRIMA,
      6=>:TA_MAType_KAMA,
      7=>:TA_MAType_MAMA,
      8=>:TA_MAType_T3,
    }
    assert_equal( exp, TaLib.ma_types )

  end

  def test_function_class

    #
    ret = TaLib::TAFunc.groups
    exp = [
      "Math Operators",
      "Math Transform",
      "Overlap Studies",
      "Volatility Indicators",
      "Momentum Indicators",
      "Cycle Indicators",
      "Volume Indicators",
      "Pattern Recognition",
      "Statistic Functions",
      "Price Transform",
    ]
    assert_equal( 10, ret.size )
    assert_equal( exp, ret )
    assert_equal( TaLib::Function.groups, ret )

    #
    ret = TaLib::TAFunc.functions
    exp = {
      "Math Operators"        => 11,
      "Math Transform"        => 15,
      "Overlap Studies"       => 17,
      "Volatility Indicators" =>  3,
      "Momentum Indicators"   => 30,
      "Cycle Indicators"      =>  5,
      "Volume Indicators"     =>  3,
      "Pattern Recognition"   => 61,
      "Statistic Functions"   =>  9,
      "Price Transform"       =>  4,
    }
    exp.keys.each do |grp|

      assert_equal( exp[grp], ret[grp].size )

    end

    assert_equal( 158, ret.values.flatten.size )
    #assert_equal( exp.values.inject(0){|r,i| r + i},
    #              ret.values.flatten.size )
    assert_equal( TaLib::Function.functions.keys, TaLib::Function.groups )
  end

  # test for function_{find,exists?}, group_of_function.
  def test_function_function
    # function_find, exists?.
    ret = TaLib::Function.function_find( :macdext )
    assert_equal( "MACDEXT", ret )

    ret = TaLib::Function.function_exists?( :MACDEXT )
    assert_equal( true, ret )

    ret = TaLib::Function.function_exists?( :macdext )
    assert_equal( true, ret )

    ret = TaLib::Function.function_exists?( "MACDEXT" )
    assert_equal( true, ret )

    ret = TaLib::Function.function_exists?( "macdext" )
    assert_equal( true, ret )

    ret = TaLib::Function.function_exists?( "MACDEXTfooobarrr" )
    assert_equal( false, ret )

    #
    ret = TaLib::Function.group_of_function( :MACDEXT )
    assert_equal( "Momentum Indicators", ret )

  end


  def test_function

    #
    assert_equal( @test_func.to_s, @testee.name )

    #
    ret = @testee.ifs_ins
    assert_equal( 1, ret.size )
    assert_equal( Struct::TA_InputParameterInfo, ret[0].class )
    assert_equal(        1, ret[0].type )
    assert_equal( "inReal", ret[0].param_name )
    assert_equal(        0, ret[0].flags )

    #
    ret = @testee.ifs_opts
    assert_equal( 6, ret.size )
    ret.size.times do |i|
      exp_param_name = [ "optInFastPeriod",
                         "optInFastMAType",
                         "optInSlowPeriod",
                         "optInSlowMAType",
                         "optInSignalPeriod",
                         "optInSignalMAType", ][i]
      assert_equal( Struct::TA_OptInputParameterInfo, ret[i].class )
      assert_equal( exp_param_name, ret[i].param_name )
    end

    ret = @testee.ifs_outs
    assert_equal( 3, ret.size )
    ret.size.times do |i|
      exp_param_name = [ "outMACD",
                         "outMACDSignal",
                         "outMACDHist" ][i]
      assert_equal( Struct::TA_OutputParameterInfo, ret[i].class )
      assert_equal( exp_param_name, ret[i].param_name )

    end

    #
    ret = @testee.ifs_all
    assert_equal( 10, ret.size )

  end

  def test_tafunc_new

    assert_nothing_raised { macd = TaLib::TAFunc.new( :MA ) }
    assert_equal( "MA", TaLib::TAFunc.new("ma").name )


  end

  def test_tafunc

    #
    ret = TaLib::TAFunc.instance_methods.grep(/^param_(in|opt|out)$/)
    assert_equal([:param_in, :param_opt, :param_out], ret)

    # in case that the function is MACD.
    exp = [
      :param_in_real,
      :param_in_real=,
      :param_opt_in_fast_period,
      :param_opt_in_fast_period=,
      :param_opt_in_fast_ma_type,
      :param_opt_in_fast_ma_type=,
      :param_opt_in_slow_period,
      :param_opt_in_slow_period=,
      :param_opt_in_slow_ma_type,
      :param_opt_in_slow_ma_type=,
      :param_opt_in_signal_period,
      :param_opt_in_signal_period=,
      :param_opt_in_signal_ma_type,
      :param_opt_in_signal_ma_type=,
      :param_out_macd,
      :param_out_macd=,
      :param_out_macd_signal,
      :param_out_macd_signal=,
      :param_out_macd_hist,
      :param_out_macd_hist=,
    ]
    ret = @testee.singleton_methods.grep(/^param_/)
    assert_equal(exp, ret)
    ret = @testee.param_methods
    assert_equal(exp, ret)

    ret = @testee.param_methods( :in )
    assert_equal( [:param_in_real, :param_in_real=], ret )

    ret = @testee.param_attr( :in )
    assert_equal( [:param_in_real], ret )

    ret = @testee.param_attr( :opt )
    assert_equal( [:param_opt_in_fast_period,
                   :param_opt_in_fast_ma_type,
                   :param_opt_in_slow_period,
                   :param_opt_in_slow_ma_type,
                   :param_opt_in_signal_period,
                   :param_opt_in_signal_ma_type,
    ], ret )

    #ret = @testee.param_methods( :in, :type )
    #assert_equal([:param_in_real], ret)


    #
    assert_equal( nil, @testee.param_in_real )
    assert_equal( [1,2,3], @testee.param_in_real=[1,2,3] )
    assert_equal( [1,2,3], @testee.param_in_real )
    assert_equal( :TA_Input_Real, @testee.param_in_real(:type) )

    h   = {}
    ret = @testee.param_out_setting( h )
    assert_equal( { }, h )

    ret = @testee.param_out_setting( h, force_mode: true )
    assert_equal( { :param_out_macd        =>[nil, nil, nil],
                    :param_out_macd_signal =>[nil, nil, nil],
                    :param_out_macd_hist   =>[nil, nil, nil], }, h )

  end

  def test_tafunc_call

    #
    e = assert_raise( RuntimeError ){ @testee.call }
    assert_equal( 0, e.message =~ /No setting of param_in_/ )

    #
    tmp = [ 1.0, 2.0, 3.0, 4.0, 5.0 ]
    @testee.param_in_real = tmp
    #@testee.param_opt_in_fast_period = 3
    assert_equal( tmp, @testee.param_in_real )
    e = assert_raise( RuntimeError ){ @testee.call }
    assert_equal( 0, e.message =~ /unsuccess return code TA_CallFunc/ )

    #
    @testee.param_out_macd        = Array.new(@testee.param_in_real.size)
    @testee.param_out_macd_signal = Array.new(@testee.param_in_real.size)
    @testee.param_out_macd_hist   = Array.new(@testee.param_in_real.size)
    assert_nothing_raised{ @testee.call }
    assert_nothing_raised{ @testee.call(0,4) }
    assert_nothing_raised{ @testee.call(1..3) }
    assert_nothing_raised{ @testee.call(1...3) }
    assert_raise( RuntimeError ){ @testee.call(1,8) }
    assert_raise( RuntimeError ){ @testee.call(1..8) }
    assert_raise( RuntimeError ){ @testee.call(1...8) }
    assert_raise( RuntimeError ){ @testee.call(4,0) }
    assert_nothing_raised{ @testee.call(tmp) }

  end

  # case without param_in_real.
  def test_tafunc_call_1

    #
    tmp = [ 1.0, 2.0, 3.0, 4.0, 5.0 ]

    #
    @testee.param_out_macd        = Array.new(tmp)
    @testee.param_out_macd_signal = Array.new(tmp)
    @testee.param_out_macd_hist   = Array.new(tmp)
    assert_nothing_raised{ @testee.call(tmp) }

  end

  # MACD test with TA_MACDEXT.
  #
  def test_tafunc_macd

    #
    tmp = [ 1.0, 2.0, 3.0, 4.0, 5.0 ]
    @testee.param_in_real        = tmp
    @testee.param_opt_in_fast_period   = 2  # MA of tmp by 2 periods.
    @testee.param_opt_in_slow_period   = 3  # MA of tmp by 3 periods.
    @testee.param_opt_in_signal_period = 1  # MA of MACD by 1 period. (Signal=MACD)
    [ :param_opt_in_fast_ma_type=,
      :param_opt_in_slow_ma_type=,
      :param_opt_in_signal_ma_type=, ].each {|param|
      @testee.send( param, TaLib::TA_MAType_EMA )
    }

    # .
    output_size = tmp.size + [ @testee.param_opt_in_fast_period,
                               @testee.param_opt_in_slow_period,
                               @testee.param_opt_in_signal_period ].max
    #
    @testee.param_out_macd        = Array.new( output_size )
    @testee.param_out_macd_signal = Array.new( output_size )
    @testee.param_out_macd_hist   = Array.new( output_size )

    #
    tmp = [nil, nil, nil, nil, nil, nil, nil, nil]
    @testee.param_out_macd        = tmp.dup
    @testee.param_out_macd_signal = tmp.dup
    @testee.param_out_macd_hist   = tmp.dup

    assert_equal( tmp, @testee.param_out_macd )

    #
    ret_call = nil
    assert_nothing_raised{ ret_call = @testee.call(0, 4) }
    
    # start_idx, num_elements.
    assert_equal( [2, 3], [ret_call[:start_idx], ret_call[:num_elements]] )

    #
    assert_equal( [0.5, 0.5, 0.5],
                  @testee.param_out_macd[ 0..(ret_call[:num_elements]-1)] )
    assert_equal( @testee.param_out_macd,
                  @testee.param_out_macd_signal )
    assert_equal( [0.0, 0.0, 0.0],
                  @testee.param_out_macd_hist[0..(ret_call[:num_elements]-1)] )
  end

  def test_tafunc_macd_1

    #
    tmp = [ 1.0, 2.0, 3.0, 4.0, 5.0, 0.0, 0.0 ]
    @testee.param_in_real        = tmp
    @testee.param_opt_in_fast_period   = 2  # MA of tmp by 2 periods.
    @testee.param_opt_in_slow_period   = 3  # MA of tmp by 3 periods.
    @testee.param_opt_in_signal_period = 1  # MA of MACD by 1 period. (Signal=MACD)
    [ :param_opt_in_fast_ma_type=,
      :param_opt_in_slow_ma_type=,
      :param_opt_in_signal_ma_type=, ].each {|param|
      @testee.send( param, TaLib::TA_MAType_EMA )
    }

    #
    output_size = tmp.size

    #
    @testee.param_out_macd        = Array.new( output_size )
    @testee.param_out_macd_signal = Array.new( output_size )
    @testee.param_out_macd_hist   = Array.new( output_size )

    #
    tmp = [nil, nil, nil, nil, nil, nil, nil]
    assert_equal( tmp, @testee.param_out_macd )

    #
    run_start_idx = 0
    run_end_idx   = 6

    ret_call = nil
    assert_nothing_raised{
      ret_call = @testee.call(run_start_idx, run_end_idx) }
    
    # start_idx, num_elements.
    assert_equal( { :param_out_macd=>
                      [0.5, 0.5, 0.5, -0.5, -0.5, nil, nil],
                    :param_out_macd_signal=>
                      [0.5, 0.5, 0.5, -0.5, -0.5, nil, nil],
                    :param_out_macd_hist=>
                      [0.0, 0.0, 0.0, 0.0, 0.0, nil, nil],
                    :start_idx    => 2,
                    :num_elements => 5, }, ret_call )

    #
    assert_equal( [0.5, 0.5, 0.5, -0.5, -0.5],
                 @testee.param_out_macd[ 0..(ret_call[:num_elements]-1)] )
    assert_equal( [0.5, 0.5, 0.5, -0.5, -0.5],
                  @testee.param_out_macd_signal[ 0..(ret_call[:num_elements]-1)] )
    assert_equal( [0.0, 0.0, 0.0, 0.0, 0.0 ],
                 @testee.param_out_macd_hist[ 0..(ret_call[:num_elements]-1)] )

  end


end
