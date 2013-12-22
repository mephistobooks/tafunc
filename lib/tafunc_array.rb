#
# filename: tafunc_array.rb
#
#

require "tafunc"


#module TaLib; end
#class  TaLib::TAFunc; end

# define Array#tafunc.
# ==== Args
#
# ==== Return
#
class Array

  def tafunc( func )

    #
    #ret = {}
    ret = nil

    #
    ret = TaLib::TAFunc.new( func ) do |taf|

      raise "Conflicts: # of inputs!" if taf.param_attr( :in ).size != 1

      # inputs.
      taf.param_in_real = self

      # outputs.
      taf.param_out_setting

      # options.
      yield(taf) if block_given?

    end.call

    #
    return ret
  end

end




#### endof filename: tafunc_array.rb
