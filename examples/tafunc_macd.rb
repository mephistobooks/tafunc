require "tafunc.rb"


# sample input data.
a = Array.new
10.times { |i| a.push i.to_f }

#
10.times do |k|
        b   = Array.new(10)
        b_1 = Array.new(10)
        b_2 = Array.new(10)

        l = TaLib::TAFunc.new("MACD") do |ma|
          ma.param_in_real = a              # setup input parameter
          ma.param_opt_in_fast_period   = 2 # setup optional parameter
          ma.param_opt_in_slow_period   = 3 # setup optional parameter
          ma.param_opt_in_signal_period = 1 # setup optional parameter
          ma.param_out_macd = b             # setup output parameter
          ma.param_out_macd_signal = b_1    # setup output parameter
          ma.param_out_macd_hist = b_2      # setup output parameter
        end

        #l.call( 0, 9 )
        #l.call( 0..9 )
        l.call

        #
        p "k=#{k+2}"
        p b
end

