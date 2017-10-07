Feature: Repository Setup

  As a tobac user
  I want to create all files and directories relevant for a tobak backup repository
  So I can set up a repository for data backup

  Background:
    Given the test repositories' shall be created as "/tmp/tobak-test/tobak-repo"
#    And the test repository directory is empty
    And the PATH and LIB_DIR variables get printed

#@announce-cmd
@announce-stdout
@announce-stderr

  Scenario: Create repository
    Given an empty test repository directory
    When I run tobak for the test repository with arguments "--init-repo"
    Then in the repository these directories shall exist
      | dir_name     |
      | volumes      |
      | hashes       |
      | hashes/00/00 |
      | hashes/00/ff |
      | hashes/ff/ff |
      | sessions     |
    And in the repository a file named "meta" shall exist
    And the file shall contain "creation_date"
    And the file shall contain "tobak_version"

