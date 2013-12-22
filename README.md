# TAFunc  - another talib_ruby wrapper and extension README.

TAFunc provides utility extensions for talib_ruby.

## Requirements
* [TA-Lib library](http://ta-lib.org) itself. On Mac, just do ``[sudo] brew install ta-lib``
* activesupport/core_ext (just for underscore method)
* ``talib_ruby`` gem which is modified ver. of 1.0.5 for TaLib::Function.{groups, functions} (see my github repository: https://github.com/mephistobooks/talib-ruby/tree/patch-1217a)
* Ruby 2.0 (I tested in this environment)
*

## Installation


## Description

According to ``ta_abstract.h`` of TA-Lib, there are some ways of wrapping library. Mlamby-san's [indicator](https://github.com/mlamby/indicator), which contains useful extension, takes static code generation approach using [XML at SourceForge]() to get TA method information.

On the contrary, the approach of TAFunc is more dynamic and meta-programming. No xml is needed. No static code generation.


## Usage

```
ma = TaLib::TAFunc.new( :MA ) do |taf|
  taf.param_in_real = ARRAY_OF_HISTORICAL_DATA
  taf.param_opt_in_period = 2
end

ma.call

```

```
result = [1.0, 2.0, 3.0, 4.0].tafunc( :MA ) do |taf|
  taf.param_in_real = ARRAY_OF_HISTORICAL_DATA
  taf.param_opt_in_time_period = 2
end
```


```
TaLib::TAFunc.new( :MACDEXT ).param_attr
TaLib::TAFunc.new( :MACDEXT ).hints
TaLib::TAFunc.groups
TaLib::TAFunc.functions
```

See in ``examples`` directory and test code for details.

## References
* TA-Lib
* TACODE.org is also nice documentation which discribes many of TA methods.
*

## Contributing to TAFunc
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2013 YAMAMOTO, Masayuki. License is MIT. See LICENSE.txt for
further details.

