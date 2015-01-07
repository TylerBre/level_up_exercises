Feature: Register a user
  As a user
  I would like to register with my email and a password
  So that I can log in and access additional features

  Background:
    Given I am on the registration page

  @happy
  Scenario: Register a test user
    When I type in my email as "test@test.com"
    And I type in my password as "test1234"
    And I submit the registration form
    Then I should be redirected to the home page

  @bad
  Scenario: User already exists
    When I type my email as "tyler@test.com"
    And I type in my password as "dflasdghjkahsdfg"
    And I submit the registration form
    Then I should see an error message saying "User already exists"
