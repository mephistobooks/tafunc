#require 'rubygems'
require 'tafunc'

# init input data
a = Array.new
10.times { |i| a.push i.to_f }

hi = (7..17).inject([]) { |list, i| list << i }
lo = (3..15).inject([]) { |list, i| list << i }
cl = (6..16).inject([]) { |list, i| list << i }

5.times do |k|

  b = Array.new(10)
  l = TaLib::TAFunc.new("ADX")
  #l = TaLib::Function.new("ADX")
  # setup input price
  # open = nil, volume = nil, open_interest = nil
  l.param_in_price_hlc = [nil, hi, lo, cl, nil, nil]

  # setup optional parameter
  l.opt_int(0,k+2);

  # setup output parameter
  l.out_real(0,b);
  l.call(0,9)

  p "k=#{k+2}"
  p b
end
