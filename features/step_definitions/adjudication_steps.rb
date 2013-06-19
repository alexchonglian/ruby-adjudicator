require 'parser/state_parser'
require 'parser/order_parser'

Given /^current state "([^"]*)"$/ do |currentstate|
  sp = Diplomacy::StateParser.new gamestate
  sp.parse_units_by_power(currentstate)
  
  adjudicator.map.areas[:Tri].should_not be_nil
end

When /^I adjudicate a set of "([^"]*)"$/ do |orderblob|
  # read orders
  op = Diplomacy::OrderParser.new gamestate, orders
  op.parse_orders(orderblob)

  # adjudicate orders
  new_state, @adjudicated_orders = adjudicator.resolve!(gamestate, orders)
end

Then /^the "([^"]*)" should be correct\.$/ do |adjudication|
  adjudication.length.should == @adjudicated_orders.length
  @actual_adjudication = ''
  
  # check orders
  adjudication.length.times do |index|
    @actual_adjudication << status_to_s(@adjudicated_orders[index].resolution)
    case adjudication[index]
    when 'S'
      @adjudicated_orders[index].resolution.should == Diplomacy::SUCCESS
    when 'F'
      [Diplomacy::FAILURE, Diplomacy::INVALID].member?(@adjudicated_orders[index].resolution).should be_true
    when 'I'
      @adjudicated_orders[index].resolution.should == Diplomacy::INVALID
    end
  end
end

After do |scenario|
  puts "Actual adjudication (until failed assertion): #{@actual_adjudication}" if scenario.failed?
end

