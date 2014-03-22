Then(/^I should be on the Home screen$/) do
  check_element_exists "view:'UIButton' marked:'Get Started!'"
end

# When(/^I want todecide to Get Started$/) do
#   touch "view:'UIButton' marked:'Get Started'"
# end

When(/^I want to "(.*?)"$/) do |button_name|
  touch "view:'UIButton' marked:'#{button_name}'"
end

Then(/^I should be presented with the Explore screen$/) do
  wait_for_element_to_exist("view:'UILabel' marked:'Popular'") do
    check_element_exists "view:'UILabel' marked:'Popular'"
  end
end
