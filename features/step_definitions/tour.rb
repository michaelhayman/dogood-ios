Then(/^I should be on the Home screen$/) do
  check_element_exists "view:'UIButton' marked:'Get Started!'"
end

# When(/^I want todecide to Get Started$/) do
#   touch "view:'UIButton' marked:'Get Started'"
# end

When(/^I touch the "(.*?) button"$/) do |button_name|
  touch "view:'UIButton' marked:'#{button_name}'"
end

Then(/^I should be presented with the Explore screen$/) do
  wait_for_element_to_exist("view:'UILabel' marked:'Popular'") do
    check_element_exists "view:'UILabel' marked:'Popular'"
  end
end

When(/^I touch the "(.*?)" navigation button$/) do |button_name|
  sleep 1
  wait_for_element_to_exist("view:'UILabel' marked:'Popular'") do
    touch "view:'UINavigationButton' marked:'#{button_name}'"
  end
end

Then(/^I should see the "Sign In" button$/) do
  wait_for_element_to_exist("view marked:'Sign In'") do
    check_element_exists "view:'UIButton' marked:'Sign In'"
  end
end

