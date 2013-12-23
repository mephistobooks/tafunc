#
# filename: tafunc.rb
#
#
require "talib_ruby"
require 'active_support/core_ext'
require 'pp'

#require "tafunc_array"


# extension for taLib_ruby structures.
#
#
class Struct

  # get structs of TA_*.
  # ==== Returns
  # array of TA_* structs.
  def self.ta_types; self.constants.grep( /TA_.*/ ); end

end


# talib_ruby main module.
# class Function is defined in this module.
#
module TaLib

  # get value-table for TA_Input_* of TA-Lib.
  # ==== Return
  # Table of Input types: { val => :sym }.
  # TA_Input_{Integer,Real,Price}
  #
  def self.input_types
    ret = {}
    self.constants.grep( /^TA_Input/ ).each{|c| ret[const_get(c)] = c }
    return ret
  end

  # get value-type table for TA_OptInput_* of TA-Lib.
  # ==== Return
  # Table of optinput types: { val => :sym }.
  # TA_OptInput_{Real,Integer}{Range,List}
  #
  def self.optinput_types
    ret = {}
    self.constants.grep( /^TA_OptInput/ ).each{|c| ret[const_get(c)] = c }
    return ret
  end

  # get value-type table for TA_Output_* of TA-Lib.
  # ==== Return
  # Table of output types: { val => :sym }.
  # TA_Output_{Integer,Real}
  #
  def self.output_types
    ret = {}
    self.constants.grep( /^TA_Output/ ).each{|c| ret[const_get(c)] = c }
    return ret
  end

  # get value-type table for TA_MAType_* of TA-Lib
  # ==== Return
  # Table of MA types: { val => :sym }.
  #
  def self.ma_types
    ret = {}
    self.constants.grep( /^TA_MAType_/ ).each{|c| ret[const_get(c)] = c }
    return ret
  end

end


# Util extension for default TaLib::Function by open-class.
#
#
class TaLib::Function

  # class methods Function.groups and Function.functions are defined
  # in talib.c of talib_ruby.

  # :nodoc:
  # ==== Return
  # { :group => group_in_which_function_exists,
  #   :function => name_of_function }
  private
  def self.__group_of_function( func )
    func = func.to_s if func.class != String
    ret = { :group => nil, :function => nil, }

    self.functions.each do |k,v|
      if tmp = v.grep(/^#{func}$/i).first
        then ret[:group] = k; ret[:function] = tmp; break
      end
    end
    return ret
  end

  public
  # find func from hash.
  # ==== Args
  # func :: name of function which you want to search from the table.
  #         (Symbol can match with String. So you can use also Symbol)
  # ==== Return
  # String :: function name found.
  # nil :: no such function.
  def self.function_find( func )
    return __group_of_function( func )[:function]
  end

  # check if a function is existed.
  # ==== Args
  # func :: name of function which you want to search from the table.
  # ==== Return
  # true :: there exists
  # false :: no such function.
  def self.function_exists?( func )
    return not(self.function_find(func).nil?)
  end

  public
  # get the group of specified function.
  #
  def self.group_of_function( func )
    return __group_of_function( func )[:group]
  end


  ####
  
  # TA Function name.
  attr_reader :name if defined?( name ).nil?  # @name

  ####

  # the interfaces of each TA function.
  # Define ifs_ins, ifs_outs, and ifs_opts with
  # TaLib::Function#{in[s],out[s],opt[s]}.
  #
  ifs = ["in","out","opt"]
  ifs.each do |funcif|

    ##
    # :method: ifs_ins
    # Helper method of Function#{in,ins}.
    # ==== Args
    # none.
    # ==== Return
    # input interface (parameters) of current Function object.
    # ex. [#<struct Struct::TA_InputParameterInfo type=1,
    # param_name="inReal", flags=0>]
    # type corresponds to TaLib.input_type[type].
    #

    ##
    # :method: ifs_opts
    # Helper method of Function#{opt,opts}
    # ==== Args
    # none.
    # ==== Return
    # option interface (parameters) of current Function object.

    ##
    # :method: ifs_outs
    # Helper method of Function#{out,outs}
    # ==== Args
    # none.
    # ==== Return
    # output interface (parameters) of current Function object.
    #

    ##

    define_method("ifs_#{funcif}s") {
      eval("self.#{funcif}s.times.map {|i| self.#{funcif}(i) }")
    }
  end

  ##
  # :method: ifs_all
  # list all of ifs_ins, ifs_outs, ifs_opts.
  # ==== Args
  # none.
  # ==== Return
  # Array of current object (an instance of Function) interfaces.

  ##

  define_method("ifs_all") {
    ifs.map{|ifname|
      eval("ifs_#{ifname}s")
    }.flatten
  }

  ####

  # Function#call(idx1,idx2) is defined.

end


# more Util extensions for TaLib::Function.
#
#
class TaLib::TAFunc < TaLib::Function

  # :nodoc:
  PPREFIX = "param_"
  table_for_param = {
    "in"  => ["int","real","price"],
    "opt" => ["int","real"],
    "out" => ["int","real"],
  }
  table_for_param_regex = {
    "in"  => ["Price","Integer","Real"],
    "opt" => ["Integer","Real"],
    "out" => ["Integer","Real"],
  }
  def etype_attr
    {
    "in"  => { 0 => "price",
               1 => "real",
               2 => "int", },
    "opt" => { 0 => "real",
               1 => "real",
               2 => "int",
               3 => "int", },
    "out" => { 0 => "real",
               1 => "int",  },
    }
  end

  private
  # generate interface methods (parameters) of each Function, dynamically.
  # (used only by #initialize)
  #
  # generated methods are param_in_*, param_opt_*, param_out_*. These are
  # due to each Function's specification.
  #
  # ex. for MACDEXT, param_in_real (getter), and param_in_real= (setter)
  # are generated as input parameter. This is singleton methods.
  #
  # To see the generated methods, use #param_methods, #param_attr or
  # something.
  # ==== Args
  # none.
  # ==== Return
  # none.
  # ==== TODO
  # * hove to change ( wh = :val ) interface for getter?
  #   (maybe confused to setter.)
  def __define_ifmethods

    #
    types = {
      :ifs_ins  => :input_types,
      :ifs_opts => :optinput_types,
      :ifs_outs => :output_types,
    }
    types_dir = {
      :ifs_ins  => 'in',
      :ifs_opts => 'opt',
      :ifs_outs => 'out',
    }

    # param_accessors generator.
    #
    #
    types.each do |ifs_method, type_method|
      send(ifs_method).each do |e|
        case
          when TaLib.send(type_method)[e.type].to_s =~ /(Price)|(Integer)|(Real)/
            idx = send(ifs_method).index(e)
            typ = etype_attr[types_dir[ifs_method]][e.type]

            define_singleton_method( PPREFIX+
                                     e.param_name.underscore ) {|wh=:val|
              unless wh =~ /^(val)|(type)$/ # :sym matches "sym".
                raise "#{__method__} is getter and cannot recognaize"+
                      " the argument: #{wh}"
              end

              #
              (send("param_"+types_dir[ifs_method])[idx].nil?)? nil : \
                send("param_"+types_dir[ifs_method])[idx][wh]
            }
            if typ =~ /Price/i
              then
              # define param_in_price_hlc= , etc.
              #
              #
                #define_singleton_method( PPREFIX+
                #     e.param_name.underscore+'=') {|vo,vh,vl,vc,vv,voi|
                define_singleton_method( PPREFIX+
                     e.param_name.underscore+'=') {|vv|
                  #pp vv

                  #
                  vv.each do |v_e|
                    if v_e.nil? or v_e==[]
                      next
                    elsif v_e.class != Array
                      then raise "#{__method__} error!"+
                        " #{v_e.to_s}(#{v_e.class.to_s}) must be array."
                    end
                  end if vv.class == Array

                  # in_price,
                  send( types_dir[ifs_method]+"_"+typ,
                        idx,
                        { :open   => vv[0],
                          :high   => vv[1],
                          :low    => vv[2],
                          :close  => vv[3],
                          :volume => vv[4],
                          :oi     => vv[5], } )
                }

              else
                define_singleton_method( PPREFIX+
                                     e.param_name.underscore+'=') {|v|
                  send( types_dir[ifs_method]+"_"+typ, idx, v )
                }

            end

          else
            raise "Initialization error #{TaLib.input_types[e.type]} #{e}!"
        end
      end

    end

#    # accessor generator
#    # for input parameter of the current TA function.
#    self.ifs_ins.each {|e|
#      case
#        when TaLib.input_types[e.type].to_s =~ /(Price)|(Integer)|(Real)/
#          #
#          # This is NG: self.class.class_eval { ... }.
#          # Because same instance methods are re-difined on TAFunc when
#          # we do TAFunc.new multiple times.
#          #
#          # So, we have to create singleton-methods on each object of
#          # TAFunc by ~~``self.singleton_class.instance_eval``~~.
#          #
#          #
#          idx = ifs_ins.index(e)
#          typ = etype_attr['in'][e.type]
#
#          define_singleton_method( PPREFIX+
#                                   e.param_name.underscore ) {|wh=:val|
#            #idx = ifs_ins.index(e)
#            unless wh =~ /^(val)|(type)$/ # :sym matches "sym".
#              raise "#{__method__} is getter and cannot recognaize"+
#                    " the argument: #{wh}"
#            end
#
#            (@param_in[idx].nil?)? nil : @param_in[idx][wh]
#          }
#          define_singleton_method( PPREFIX+
#                                   e.param_name.underscore+'=') {|v|
#            #eval("in_price( ifs_ins.index(e), v )")
#            #eval("in_#{etype_attr['in'][e.type]}( ifs_ins.index(e), v )")
#            #puts "#{__method__}: #{idx}, #{v}"
#            #puts "raw method: in_#{etype_attr['in'][e.type]}"
#
#            send("in_"+typ, idx, v )
#          }
#        else
#          raise "Initialization error #{TaLib.input_types[e.type]} #{e}!"
#      end
#    }
#
#    # accessor generator
#    # for option parameter of current TA function.
#    self.ifs_opts.each {|e|
#      case
#        when TaLib.optinput_types[e.type].to_s =~ /(Integer)|(Real)/
#          idx = ifs_opts.index(e)
#          typ = etype_attr['opt'][e.type]
#
#          define_singleton_method( PPREFIX+
#                                   e.param_name.underscore ) {|wh=:val|
#            unless wh =~ /^(val)|(type)$/ # :sym matches "sym".
#              raise "#{__method__} is getter and cannot recognaize"+
#                    " the argument: #{wh}"
#            end
#
#            (@param_opt[idx].nil?)? nil : @param_opt[idx][wh]
#          }
#          define_singleton_method( PPREFIX+
#                                   e.param_name.underscore + '=' ) {|v|
#              #eval("opt_int( ifs_opts.index(e), v )")
#              send( "opt_"+typ, idx, v )
#          }
#        else
#          raise "Initialization error #{TaLib.optinput_types[e.type]} #{e}!"
#      end
#    }
#
#    # accessor generator
#    # for output parameter of current TA function.
#    self.ifs_outs.each {|e|
#      case
#        when TaLib.output_types[e.type].to_s =~ /(Integer)|(Real)/
#          idx = ifs_outs.index(e)
#          typ = etype_attr['out'][e.type]
#
#          define_singleton_method( PPREFIX+
#                                   e.param_name.underscore ) {|wh=:val|
#            unless wh =~ /^(val)|(type)$/ # :sym matches "sym".
#              raise "#{__method__} is getter and cannot recognaize"+
#                    " the argument: #{wh}"
#            end
#
#            (@param_out[idx].nil?)? nil : @param_out[idx][wh]
#          }
#          define_singleton_method( PPREFIX+
#                                   e.param_name.underscore + '=' ) {|v|
#            #eval("out_int( ifs_outs.index(e), v )")
#            send( "out_"+typ, idx, v )
#          }
#        else
#          raise "Initialization error #{TaLib.output_types[e.type]} #{e}!"
#      end
#    }
  end

  public
  # get defined singleton methods of param_{in,opt,out}_*.
  #
  #
  def param_methods( kind = "(in|opt|out)" )
    kind = kind.to_s if kind.class == Symbol
    self.singleton_methods.grep(/^param_#{kind}_.+$/)
  end
  def param_attr( kind = "(in|opt|out)" )
    self.param_methods( kind ).grep(/[^=]$/)
  end


  public
  #
  # ==== Args
  # func :: The function name.
  #
  def initialize( func, arr_in: [], arr_out: [] )
    func = func.to_s if func.class == Symbol
    func_renamed = self.class.function_find( func )
    case
      when func.class != String
        raise "Type error for the function name: #{func.class}(#{func})!"+
              " This should be in String."
      when TaLib::Function.function_exists?( func ) == false
        raise "No such function: #{func}!"+
              " Choose one of"+
              " #{TaLib::Function.functions.values.flatten.join(' ')}."
    end

    #
    super( func_renamed )

    # for recording parameter setting.
    # { idx => { :val => some_val,
    #            :type => type_name, }
    #
    @param_in  = {}
    @param_opt = {}
    @param_out = {}

    # define method for the function: func.
    # for example, param_in_real, param_opt_in_fast_period methods, etc.
    #
    __define_ifmethods

    # this must be after __define_ifmethods because we want to use
    # generated interface methods in yield block.
    #
    yield self if block_given?

  end

  public
  # current parameter values of each object of Function.
  # for @param_in, @param_opt, @param_out.
  # ==== See Also
  # * TaLib::Function#ifs_all/ifs_ins/ifs_opts/ifs_outs.
  # * TaLib::TAFunc.#hints
  attr_reader :param_in, :param_opt, :param_out

  private
  #alias :in_int_orig :in_int
  #alias :in_real_orig :in_real
  #alias :in_price_orig :in_price

  #alias :opt_int_orig :opt_int
  #alias :opt_real_orig :opt_real

  #alias :out_int_orig :out_int
  #alias :out_real_orig :out_real

  table_for_param.keys.each{|k|
    table_for_param[k].each{|v|
      unless self.method_defined?( "#{k}_#{v}_orig".to_sym )
        then alias_method( "#{k}_#{v}_orig".to_sym, "#{k}_#{v}".to_sym )
        else raise "Error in re-defining at #{self.to_s}:"+
          " #{k}_#{v}_orig already exists!"
      end
    }
  }

  private
  def __param_in_record( idx, val )
    @param_in[idx] = {
      val: val,
      type: TaLib.input_types[ifs_ins[idx].type], }
  end
  def __param_opt_record( idx, val )
    @param_opt[idx] = { val: val,
      type: TaLib.optinput_types[ifs_opts[idx].type], }
  end
  def __param_out_record( idx, val )
    @param_out[idx] = { val: val,
      type: TaLib.output_types[ifs_outs[idx].type], }
  end

  public
  ##
  # wrap the original {in,opt,out}_{int,real,price} to record values.
  # For example,
  #   def in_real( idx, val )
  #     __in_param_record( idx, val )
  #     in_real_orig(idx, val)
  #   end
  #
  #
  ##
  table_for_param.keys.each{|k|
    table_for_param[k].each{|v|
      if v == 'price'
        then define_method( k+"_"+v ) {|idx,val|
               # attention: val must be lvalue when out_*.
               eval("__param_#{k}_record( idx, val )")
               eval("#{k}_#{v}_orig(idx,"+
                    " val[:open], val[:high], val[:low], val[:close],"+
                    " val[:volume], val[:oi] )")
             }

        # real or int
        else define_method( k+"_"+v ) {|idx,val|
               # attention: val must be lvalue when out_*.
               eval("__param_#{k}_record( idx, val )")
               eval("#{k}_#{v}_orig(idx, val)")
             }
      end
    }
  }

  ####
  public
  # wrap Function#call to accept various kinds of args.
  # ==== Args
  # *r :: range of input array in several ways:
  #       no args: from pram_in_*
  #       m, n: direct indexes
  #       m..n: range object
  #       array: array
  # ==== Return
  # due to the function.
  def call( *r )
    m, n = nil, nil

    # specifies m and n, simulation range in input data.
    case
      when r.size == 0  # no args.
        raise "No setting of param_in_* for #{name}!" if @param_in[0].nil?
        m, n = 0, @param_in[0][:val].size-1
      when r.first.class == Range   # Range is given.
        m, n = r.first.first, r.first.last
      when r.size == 2              # 2 indexes are given.
        #puts "couple of index."
        m, n = r.first, r.last
      when r.first.class == Array   # Array is given.
        #puts "array."
        self.param_in_real = r.first if @param_in[0].nil?
        m, n = 0, r.first.size-1
      else
        raise "Strange args: #{r}! Should be in one of Nothing,"+
              " two indexes, Array or Range."
    end

    #puts "idx: #{m}, #{n}"
    param_size = case @param_in[0][:type]
                   when :TA_Input_Price
                     [ @param_in[0][:val][:open],
                       @param_in[0][:val][:high],
                       @param_in[0][:val][:low],
                       @param_in[0][:val][:close],
                     ].map{|e| (e.nil?)? 0 : e.size }.max
                    when :TA_Input_Real
                      self.param_in_real.size
                    when :TA_Input_Integer
                      raise "Not yet implemented."
                    else
                      raise "Strange type for input parameter:"+
                        " #{@param_in[0][:type]}."
                    end

    case
      when m > n
        raise "calculation range(#{m},#{n}) is currently not supported!"
      when n >= param_size
        raise "#{n} is too big!"+
          " less than or equal to #{self.param_in_real.size-1}"
    end

    #
    tmp = super( m, n )
    ret = param_out_setting
    ret.merge!( { :start_idx => tmp[0], :num_elements => tmp[1], } )

    #
    return ret

  end

  # auto prepare output arrays.
  # ==== Requirements
  # all in-parameters have already been set.
  # ==== Args
  # h :: output hash to be set.
  # force_mode: :: force to create new array for output (default: false)
  # ==== Return
  # h :: { :output_parameter1 => [ nil, nil, ... ],
  #        :output_parameter2 => [ nil, nil, ... ], }
  # ==== TODO
  # * currently tested only MA, MACDEXT.
  #
  def param_out_setting( h = {}, force_mode: false )


    # get output attributes (arrays to prepare).
    tmp = self.param_attr( :out )

    # prepare arrays and set them.
    tmp.each{|a|
      #
      if force_mode or self.send( a ).nil?
        then h[a] = Array.new( self.param_in_real.size )
             self.send( (a.to_s+'=').to_sym, h[a] )
        else h[a] = self.send( a )  # call getter.
      end
    }

    return h
  end

  ####

  # Wrapper of the class method: hints.
  # ==== See Also
  # * self.hints
  def hints( verbose: false, group: "all", function: name )
    self.class.hints( verbose: verbose, group: group, function: function )
  end

  # self.hints provides the information about TA-Lib function.
  # The information of them are extracted from talib library itself.
  # ==== ATTENTION
  # library (talib_ruby) must support TaLib::Function.{groups,functions}.
  # ==== Args
  # verbose: :: parameter name only when false, or entire structs when true.
  # group: :: group name of functions.
  # function: :: name of function.
  # ==== Description
  # * one of group or function should be specified.
  # * these args can be String, Array of String, or "all"
  # *
  # ==== Return
  #
  def self.hints( verbose: false, group: "all", function: "all" )
    group_list = nil
    case
      when group == "all"
        group_list = self.groups
      when group.class == String
        group_list = [group]
      when group.class == Array
        group_list = group
      else
        raise "Type error #{group.class} for group!"+
          " Please specify group in String or Array of String."
    end

    func_list = nil
    tmp = self.functions
    case
      when function == "all"
        func_list = tmp.values.flatten
      when function.class == Array
        func_list = function
        group_list = []
        func_list.each{|f|
          group_list.push( tmp.keys.map{|e|
            (tmp[e].grep(f).size>0)? e : nil }.compact )
        }
        group_list.flatten!
      when function.class == String
        func_list  = [function]
        group_list = tmp.keys.map{|e|
                       (tmp[e].grep(function).size>0)? e : nil
                     }.compact
      else
    end

    #
    group_list = group_list.sort.uniq
    func_list  = func_list.sort.uniq
    #pp group_list
    #pp func_list

    #
    group_list.each{|grp|
      puts "==== #{grp} ===="
      self.functions[grp].each{|func|
        #puts func
        if func_list.grep(func).size > 0
          tmp = self.new(func)

          puts "<#{func}>"
          puts "inputs:"
          if verbose
            then pp tmp.ifs_ins
            else tmp.ifs_ins.each{|e|
              puts PPREFIX+e.param_name.underscore }
          end
          puts ""

          puts "options:"
          if verbose
            then pp tmp.ifs_opts
            else tmp.ifs_opts.each{|e|
              puts PPREFIX+e.param_name.underscore }
          end
          puts ""

          puts "outputs:"
          if verbose
            then pp tmp.ifs_outs
            else tmp.ifs_outs.each{|e|
              puts PPREFIX+e.param_name.underscore }
          end
          puts ""

          puts ""
        end
      }
    }

  end


end



#### endof filename: tafunc.rb
