Feature: Log in
  As a User
  I would like to log in
  So that I may have access to additional functionality

  Background:
    Given I am on the login page

  @happy
  Scenario: Log in test user
    When I type in my email as "test@test.com"
    And I type in my password as "test1234"
    And I submit the login form
    Then I should be redirected to the home page

  @sad
  Scenario: Invalid password for test user
    When I type in my email as "test@test.com"
    And I type in my password as "dflasdghjkahsdfg"
    And I submit the login form
    Then I should see an error message saying "Incorrect password"

  @bad
  Scenario: Can't find user
      When I type in my email as "sa;ldkfasl;kdfj"
      And I type in my password as "dflasdghjkahsdfg"
      And I submit the login form
      Then I should see an error message saying "User not found"
