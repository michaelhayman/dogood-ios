Feature:
  As a user
  I want to see a quick overview of the app in a tour
  So I can get started quickly

Scenario:
  Viewing the tour
When I reset the simulator
Given I launch the app
Then I should be on the Home screen

When I touch "Get Started!"
Then I should be presented with the Explore screen

