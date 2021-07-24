@qtype @qtype_wq @qtype_matchwiris @qtype_matchwiris_alg_play
Feature: A student can answer a Match Wiris question type
  In order to answer the question
  As a student
  I need to match the fields

  Background:
    Given the "wiris" filter is "on"
    Given the "mathjaxloader" filter is "disabled"
    Given the following "users" exist:
      | username | firstname | lastname | email                |
      | student1 | Student   | 1        | student1@example.com |
    And the following "courses" exist:
      | fullname | shortname | format |
      | Course 1 | C1        | weeks  |
    And the following "course enrolments" exist:
      | user     | course | role    |
      | student1 | C1     | student |
    And the following "question categories" exist:
      | contextlevel | reference | name           |
      | Course       | C1        | Default for C1 |
    And the following "questions" exist:
      | questioncategory | qtype      | name             | template        |
      | Default for C1   | matchwiris | Match Wiris      | foursubq        |
      | Default for C1   | matchwiris | Match Formula    | twosubqformula  |
      | Default for C1   | matchwiris | Repeated Answers | repeatedanswers |

  @javascript
  Scenario: A student executes a match wiris question
    Given the following "activities" exist:
      | activity | name   | intro              | course | idnumber |
      | quiz     | Quiz 1 | Quiz 1 description | C1     | quiz1    |
    And quiz "Quiz 1" contains the following questions:
      | question    | page |
      | Match Wiris | 1    |
    When I log in as "student1"
    And I am on "Course 1" course homepage
    And I follow "Quiz 1"
    And I press "Attempt quiz now"
    And I set the field with xpath "//table[@class='answer']//td[@class='control']//select[contains(@id, '1_sub0')]" to "5"
    And I set the field with xpath "//table[@class='answer']//td[@class='control']//select[contains(@id, '1_sub1')]" to "6"
    And I set the field with xpath "//table[@class='answer']//td[@class='control']//select[contains(@id, '1_sub2')]" to "7"
    And I set the field with xpath "//table[@class='answer']//td[@class='control']//select[contains(@id, '1_sub3')]" to "8"
    And I click on "Finish attempt" "button"
    And I click on "Submit all and finish" "button"
    And I click on "//input[@type='button']" "xpath_element"
    Then Generalfeedback should exist

  @javascript
  Scenario: A student executes a match wiris question with formulas and feedback
    Given the following "activities" exist:
      | activity | name   | intro              | course | idnumber |
      | quiz     | Quiz 1 | Quiz 1 description | C1     | quiz1    |
    And quiz "Quiz 1" contains the following questions:
      | question      | page |
      | Match Formula | 1    |
    When I log in as "student1"
    And I am on "Course 1" course homepage
    And I follow "Quiz 1"
    And I press "Attempt quiz now"
    And I set the field with xpath "//table[@class='answer']//td[@class='control']//select[contains(@id, '1_sub0')]" to "2^(1/2)/45"
    And I set the field with xpath "//table[@class='answer']//td[@class='control']//select[contains(@id, '1_sub1')]" to "2·x^2+2/3"
    And I click on "Finish attempt" "button"
    And I click on "Submit all and finish" "button"
    And I click on "//input[@type='button']" "xpath_element"
    Then Generalfeedback should exist
    And Wirisformula should exist

  @javascript @qtype_matchwiris_alg_play
  Scenario: A student executes a match wiris with repeated answers
    Given the following "activities" exist:
      | activity | name   | intro              | course | idnumber |
      | quiz     | Quiz 1 | Quiz 1 description | C1     | quiz1    |
    And quiz "Quiz 1" contains the following questions:
      | question         | page |
      | Repeated Answers | 1    |
    When I log in as "student1"
    And I am on "Course 1" course homepage
    And I follow "Quiz 1"
    And I press "Attempt quiz now"
    And I set the field with xpath "//table[@class='answer']//td[@class='control']//select[contains(@id, '1_sub0')]" to "5"
    And I set the field with xpath "//table[@class='answer']//td[@class='control']//select[contains(@id, '1_sub1')]" to "6"
    And I set the field with xpath "//table[@class='answer']//td[@class='control']//select[contains(@id, '1_sub2')]" to "6"
    And I set the field with xpath "//table[@class='answer']//td[@class='control']//select[contains(@id, '1_sub3')]" to "8"
    And I click on "Finish attempt" "button"
    And I click on "Submit all and finish" "button"
    And I click on "//input[@type='button']" "xpath_element"
    Then Generalfeedback should exist
