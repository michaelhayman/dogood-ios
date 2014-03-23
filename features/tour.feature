Feature:
  As a user
  I want to see a quick overview of the app in a tour
  So I can get started quickly

Scenario:
  Viewing the tour
When I reset the simulator
Given I launch the app
Then I should be on the Home screen

When I touch the "Get Started! button"
Then I should be presented with the Explore screen

Scenario:
  Adding a good when unauthenticated

When I touch the "Add" navigation button
Then I should see the "Sign In" button

