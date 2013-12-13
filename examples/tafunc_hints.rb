require "tafunc.rb"


#
puts "<TA Genre>"
puts TaLib::TAFunc.groups.join(', ')
TaLib::TAFunc.hints( group: "Statistic Functions" )

#
TaLib::TAFunc.new("MACD").hints


#
