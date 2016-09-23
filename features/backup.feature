Feature: File Backup

  As an ordinary computer user
  I want to have copies of all my personal files from several resources in a common backup repository
  So I can easily backup and archive my data in a central place without much redundancy

#@announce-cmd
#@announce-stdout
#@announce-stderr

  Scenario: FIXME Background:
    Given the testing repositories' root will be "/tmp/tobak-test/repo-root"
    And a virtual resource "resource01" can be found at "/tmp/tobak-test/resource01"
    And a virtual resource "resource02" can be found at "/tmp/tobak-test/resource02"
    And a virtual resource "resourceVol"  can be found at "/tmp/tobak-test/resourceVol"
    And the virtual resource has these volumes:
      | volume_name |
      | volume01    |
      | volume02    |

  Scenario: Create repository
    Given an empty test repositories directory
    When I successfully run `tobak --destination="#{@destination}"`
    Then these directories shall exist
      | dir_name     |
      | resources    |
      | hashes       |
      | hashes/00/00 |
      | hashes/00/ff |
      | hashes/ff/ff |
      | sessions     |
    And a file named "meta" shall exist
    And the file shall contain "creation_date"
    And the file shall contain "tobak_version"

  Scenario: Add single file to repository
    Given a fresh target repository
    And a clean recource directory "resource01"
    And the directory contains
      #| file_name   | owner | permissions | content
      | file_name   | content      |
      | file01.txt | Hello World! |
    When I successfully run `tobak --destination="#{@destination}" --tag=tag01 --resource-name=res01 --autoresroot file01.txt`
    #And I remember the time when the program finishes
    Then a file named "resources/res01/tag01/content/file01.txt" shall exist
    And the file shall contain "Hello World!"
    And a file named "resources/res01/tag01/cmeta/file01.txt" shall exist
    And the file shall contain "XXX"
    And a directory named "resources/res01/tag01/meta" shall exist
    And the directory shall contain a file "resource"
    And the file shall contain "res01"
    And the directory shall contain a symlink "session" to "sessions/tag01/meta"
    And a directory named "resources/res01/tag01/log" shall exist
    And the directory shall contain
      | file_name | is_empty | contains               |
      | general   | false    | finished.*#{Date.year} |
      | warnings  | true     |                        |
      | errors    | true     |                        |
      | summary   | false    | 1 new files            |
    And the directory shall contain a symlink "session" to "sessions/tag01/log"
    And a file named "hashes/*/*/*/file" shall exist
    And the file shall contain "Hello World!"
    And the file shall be identical to "resources/res01/tag01/content/file01.txt"
    And a file named "hashes/*/*/*/instances" shall exist
    And the file shall contain "res01/tag01//file01.txt"
    And a directory named "sessions/tag01/resources" shall exist
    And the directory shall contain a symlink "res01" to "resources/res01/tag01"
    #And a file named "sessions/tag01/meta" shall exist
    #And the file shall contain ""
    And a file named "sessions/tag01/log" shall exist
    And the file shall contain "1 new file"
    And the file shall contain "finished.*#{Date.year}"

  Scenario: Add identical file twice form different resources

  Scenario: Add two files with same content (but different file attributes) from different resources

  Scenario: Add all files from one repository

  Scenario: Add all files form one volume

  Scenario: Add all volumes form one repository

  Scenario: Update plain resource

