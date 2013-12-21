require "tafunc.rb"


# sample input data.
#a = Array.new
#10.times { |i| a.push i.to_f }
a = [ 1.0, 2.0, 3.0, 4.0,  5.0, 0.0, 0.0, 3.0, 4.0, ]
#a = [ 1.0, 1.0, 2.0, 3.0, 5.0,  1.0, 1.0, 2.0, 3.0, 5.0, ]

#
5.times do |k|
  b   = Array.new(10)
  b_1 = Array.new(10)
  b_2 = Array.new(10)

  l = TaLib::TAFunc.new("MACDEXT") do |macd|
    macd.param_in_real = a              # setup input parameter
    macd.param_opt_in_fast_period   = k+2 # setup optional parameter
    macd.param_opt_in_fast_ma_type= TaLib::TA_MAType_EMA
    macd.param_opt_in_slow_period   = k+3 # setup optional parameter
    macd.param_opt_in_slow_ma_type= TaLib::TA_MAType_EMA
    macd.param_opt_in_signal_period = k+1 # setup optional parameter
    macd.param_opt_in_signal_ma_type= TaLib::TA_MAType_EMA
    macd.param_out_macd = b             # setup output parameter
    macd.param_out_macd_signal = b_1    # setup output parameter
    macd.param_out_macd_hist = b_2      # setup output parameter
  end

  ret = l.call

  #
  p "k=#{k+2}"
  #p " BegIdx:#{ret[:start_idx].to_s}, #oE:#{ret[:num_elements].to_s}"
  p ret
  puts "MACD #{b.map{|e| (e.nil?)? nil : sprintf("%.2f",e.to_s.to_f) }}"
  puts "sign #{b_1.map{|e| (e.nil?)? nil : sprintf("%.2f",e.to_s.to_f) }}"
  puts "hist #{b_2.map{|e| (e.nil?)? nil : sprintf("%.2f",e.to_s.to_f) }}"

end

