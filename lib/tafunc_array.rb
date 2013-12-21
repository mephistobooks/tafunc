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
    ret = {}

    #
    tmp = TaLib::TAFunc.new( func ) do |taf|

      raise "Conflicts: # of inputs!" if taf.param_attr( :in ).size != 1

      # inputs.
      taf.param_in_real = self

      # outputs.
      taf.param_out_setting( ret )

      # options.
      yield(taf) if block_given?

    end.call

    # add other call results.
    ret.merge!( { :start_idx => tmp[0], :num_elements => tmp[1], } )

    #
    return ret
  end

end




#### endof filename: tafunc_array.rb
