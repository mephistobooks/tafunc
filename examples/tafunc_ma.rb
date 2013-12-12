require "tafunc.rb"


# sample input data.
a = Array.new
10.times { |i| a.push i.to_f }

#
10.times do |k|
        b = Array.new(10)

        l = TaLib::TAFunc.new("MA") do |ma|
          ma.param_in_real = a              # setup input parameter
          ma.param_opt_in_time_period = k+2 # setup optional parameter
          ma.param_out_real = b             # setup output parameter
        end

        l.call( 0, 9 )

        #
        p "k=#{k+2}"
        p b
end

