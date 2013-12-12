require 'helper'

class TestTafunc < Test::Unit::TestCase
#  should "probably rename this file and start testing for real" do
#    flunk "hey buddy, you should probably rename this file and start testing for real"
#  end
  #
  #
  def setup
    @test_func = :MACD
    @testee = TaLib::TAFunc.new( @test_func )
  end

  def teardown
  end

  def test_new
    
    #
    assert_nothing_raised { taf = TaLib::TAFunc.new( "MACD" ) }

    #
    assert_nothing_raised { taf = TaLib::TAFunc.new( :MACD ) }

    #
    assert_raise( RuntimeError ) { taf = TaLib::TAFunc.new( "" ) }


  end


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

  def test_talib
    
    assert_equal( Module, TaLib.class )

    exp = {
      0=>:TA_Input_Price,
      1=>:TA_Input_Real,
      2=>:TA_Input_Integer,
    }
    assert_equal( exp, TaLib.input_types )

    exp = {
      0=>:TA_OptInput_RealRange,
      1=>:TA_OptInput_RealList,
      2=>:TA_OptInput_IntegerRange,
      3=>:TA_OptInput_IntegerList,
    }
    assert_equal( exp, TaLib.optinput_types )

    exp = {
      0=>:TA_Output_Real,
      1=>:TA_Output_Integer,
    }
    assert_equal( exp, TaLib.output_types )

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
    assert_equal( 3, ret.size )
    ret.size.times do |i|
      exp_param_name = [ "optInFastPeriod",
                         "optInSlowPeriod",
                         "optInSignalPeriod" ][i]
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
    assert_equal( 7, ret.size )

  end

  def test_tafunc
    ret = @testee

  end

end
