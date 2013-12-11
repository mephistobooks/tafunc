#
# filename: tafunc.rb
#
#
require "talib_ruby"
require 'active_support/core_ext'
require 'pp'


# TaLib_ruby structures.
#
#
class Struct
  
  # get structs of TA_*.
  #
  #
  def self.ta_types; self.constants.grep( /TA_.*/ ); end

end


# TaLib_ruby main module.
# class Function is defined in this.
#
module TaLib

  # Table of Input types: { val => :sym }.
  # TA_Input_{Integer,Real,Price}
  #
  #
  def self.input_types
    ret = {}
    self.constants.grep( /^TA_Input/ ).each{|c| ret[const_get(c)] = c }
    return ret
  end

  # Table of optinput types: { val => :sym }.
  # TA_OptInput_{Real,Integer}{Range,List}
  #
  #
  def self.optinput_types
    ret = {}
    self.constants.grep( /^TA_OptInput/ ).each{|c| ret[const_get(c)] = c }
    return ret
  end

  # Table of output types: { val => :sym }.
  # TA_Output_{Integer,Real}
  #
  #
  def self.output_types
    ret = {}
    self.constants.grep( /^TA_Output/ ).each{|c| ret[const_get(c)] = c }
    return ret
  end

  # Table of MA types: { val => :sym }.
  #
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
    # Helper method of in() and ins()
    # ==== Args
    #
    # ==== Return
    #
    
    ##
    # :method: ifs_opts
    # Helper method of Function#opt and Function#opts
    #
    # ==== Args
    #
    # ==== Return
    #
    #
    
    ##
    # :method: ifs_outs
    # Helper method of Function#out and Function#outs
    # ==== Args
    #
    # ==== Return
    #
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
  #
  # ==== Return
  #

  ##

  define_method("ifs_all") {
    ifs.map{|ifname|
      eval("ifs_#{ifname}s")
    }.flatten
  }

  ####

  # Function#groups and Function#functions are defined in talib.c.

end


# more Util extensions for TaLib::Function.
#
#
class TaLib::TAFunc < TaLib::Function

  PPREFIX = "param_"
  tmph = {
    "in"  => ["int","real","price"],
    "opt" => ["int","real"],
    "out" => ["int","real"],
  }

  private
  # defines parameter methods of each Function, dynamically.
  # ==== Args
  #
  # ==== Return
  #
  def __define_ifmethods

    # in
    self.ifs_ins.each {|e|
      case
        when TaLib.input_types[e.type].to_s =~ /Price/
          # This is NG: self.class.class_eval { ... }.
          # Because same instance methods are re-difined on TAFunc when
          # we do TAFunc.new multiple times.
          #
          # So, we have to create singleton-methods on each object of
          # TAFunc by ``self.singleton_class.instance_eval``.
          #
          self.singleton_class.instance_eval do
            define_method( PPREFIX+e.param_name.underscore ) {|val|
              eval("in_price( ifs_ins.index(e), val )")
            }
            define_method( PPREFIX+e.param_name.underscore+'=' ) {|val|
              eval("#{PPREFIX+e.param_name.underscore}(val)")
            }
          end
        when TaLib.input_types[e.type].to_s =~ /Integer/
          self.singleton_class.instance_eval do
            define_method( PPREFIX+e.param_name.underscore ) {|val|
              eval("in_int( ifs_ins.index(e), val )")
            }
            define_method( PPREFIX+e.param_name.underscore+'=' ) {|val|
              eval("#{PPREFIX+e.param_name.underscore}(val)")
            }
          end
        when TaLib.input_types[e.type].to_s =~ /Real/
          self.singleton_class.instance_eval do
            define_method( PPREFIX+e.param_name.underscore ) {|val|
              #
              eval("in_real( ifs_ins.index(e), val )")
            }
            define_method( PPREFIX+e.param_name.underscore+'=' ) {|val|
              eval("#{PPREFIX+e.param_name.underscore}(val)")
            }
          end
        else
          raise "Initialization error #{TaLib.input_types[e.type]} #{e}!"
      end
    }

    # opt
    self.ifs_opts.each {|e|
      case
        when TaLib.optinput_types[e.type].to_s =~ /Integer/
          self.singleton_class.instance_eval do
            define_method( PPREFIX+e.param_name.underscore ) {|val|
              eval("opt_int( ifs_opts.index(e), val )")
            }
            define_method( PPREFIX+e.param_name.underscore+'=' ) {|val|
              eval("#{PPREFIX+e.param_name.underscore}(val)")
            }
          end
        when TaLib.optinput_types[e.type].to_s =~ /Real/
          self.singleton_class.instance_eval do
            define_method( PPREFIX+e.param_name.underscore ) {|val|
              eval("opt_real( ifs_opts.index(e), val )")
            }
            define_method( PPREFIX+e.param_name.underscore+'=' ) {|val|
              eval("#{PPREFIX+e.param_name.underscore}(val)")
            }
          end
        else
          raise "Initialization error #{TaLib.optinput_types[e.type]} #{e}!"
      end
    }

    # out
    self.ifs_outs.each {|e|
      case
        when TaLib.output_types[e.type].to_s =~ /Integer/
          #self.class.class_eval {
          self.singleton_class.instance_eval do
            define_method( PPREFIX+e.param_name.underscore ) {|val|
              eval("out_int( ifs_outs.index(e), val )")
            }
            define_method( PPREFIX+e.param_name.underscore+'=' ) {|val|
              eval("#{PPREFIX+e.param_name.underscore}(val)")
            }
          end
        when TaLib.output_types[e.type].to_s =~ /Real/
          self.singleton_class.instance_eval do
            define_method( PPREFIX+e.param_name.underscore ) {|val|
              eval("out_real( ifs_outs.index(e), val )")
            }
            define_method( PPREFIX+e.param_name.underscore+'=' ) {|val|
              eval("#{PPREFIX+e.param_name.underscore}(val)")
            }
          end
        else
          raise "Initialization error #{TaLib.output_types[e.type]} #{e}!"
      end
    }
  end

  public
  def initialize( func )
    func = func.to_s if func.class == Symbol
    if func.class != String
      raise "Type error: #{func}! Should be in String."
    end

    super( func )

    #
    @param_in  = {}
    @param_opt = {}
    @param_out = {}

    # define method for the function: func.
    __define_ifmethods
  end

  # current parameter values of each object of Function.
  # ==== See Also
  # * ifs_all/ifs_ins/ifs_opts/ifs_outs.
  # * TAFunc.#hints
  attr_reader :param_in, :param_opt, :param_out


  #alias :in_int_orig :in_int
  #alias :in_real_orig :in_real
  #alias :in_price_orig :in_price

  #alias :opt_int_orig :opt_int
  #alias :opt_real_orig :opt_real

  #alias :out_int_orig :out_int
  #alias :out_real_orig :out_real

  tmph.keys.each{|k|
    tmph[k].each{|v|
      unless self.method_defined?( "#{k}_#{v}_orig".to_sym )
        then alias_method( "#{k}_#{v}_orig".to_sym, "#{k}_#{v}".to_sym )
        else raise "Error in re-defining at #{self.to_s}: #{k}_#{v}!"
      end
    }
  }

  private
  def __param_in_record( idx, val )
    @param_in[idx] = { val: val,
      type: TaLib.input_types[ifs_ins[idx].type] }
  end
  def __param_opt_record( idx, val )
    @param_opt[idx] = { val: val,
      type: TaLib.optinput_types[ifs_opts[idx].type] }
  end
  def __param_out_record( idx, val )
    @param_out[idx] = { val: val,
      type: TaLib.output_types[ifs_outs[idx].type] }
  end

  public
  #
  #
  #
  tmph.keys.each{|k|
    tmph[k].each{|v|
      define_method( k+"_"+v ) {|idx,val|
        # attention: val must be lvalue when out_*.
        eval("__param_#{k}_record( idx, val )")
        eval("#{k}_#{v}_orig(idx, val)")
      }
    }
  }

  #def in_int( idx, val )
  #  __in_param_record( idx, val )
  #  in_int_orig(idx, val)
  #end
  #def in_real( idx, val )
  #  #__in_param_record( idx, val, TaLib::TA_Input_Real )
  #  __in_param_record( idx, val )
  #  in_real_orig(idx, val)
  #end
  #def in_price( idx, val )
  #  __in_param_record( idx, val )
  #  in_price_orig(idx, val)
  #end

  #def opt_int( idx, val )
  #  __opt_param_record( idx, val )
  #  opt_int_orig(idx, val)
  #end
  #def opt_real( idx, val )
  #  __opt_param_record( idx, val )
  #  opt_real_orig(idx, val)
  #end

  #def out_int( idx, val )
  #  __out_param_record( idx, val )
  #  out_int_orig(idx, val)
  #end
  #def out_real( idx, val )
  #  __out_param_record( idx, val )
  #  out_real_orig(idx, val)
  #end

  # Wrapper of the class method: hints.
  # ==== See Also
  # * self.hints
  def hints( verbose: false, group: "all", function: name )
    self.class.hints( verbose: verbose, group: group, function: function )
  end

  # self.hints provides the information about TA-Lib function.
  # The information of them are extracted from talib itself.
  # ==== ATTENTION
  # library (talib_ruby) must support TaLib::Function.{groups,functions}.
  # ==== Args
  # verbose: :: parameter name only when false, or entire structs.
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
      when group.class == Array
        group_list = group
      when group.class == String
        group_list = [group]
      else
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
