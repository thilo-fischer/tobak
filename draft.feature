Given an empty dir "$TESTDEST/"
And a file "foo.txt"
And the content of this file is "some text"
When I invoke '''tobak --destination="$TESTDEST/" --timestamp="date-and-time" foo.txt'''
And hash_var contains the hash of "foo.txt"
Then a file "$TESTDEST/sources/misc/date-and-time/foo.txt" shall exist
And the content of this file shall be "some text"
And a file "$TESTDEST/hashes/**/#{hash_var}" shall exist
And the content of this file shall be "some text"
And a file "$TESTDEST/meta/**/#{hash_var}" shall exist
And the content of this file shall be "..."

Given an empty dir "$TESTDEST/"
And a file "foo.txt"
And the content of this file is "some text"
And a file "bar.txt"
And the content of this file is "some text"
When I invoke '''tobak --destination="$TESTDEST/" --timestamp="date-and-time" foo.txt bar.txt'''
And hash_var contains the hash of "foo.txt"
Then a file "$TESTDEST/sources/misc/date-and-time/foo.txt" shall exist
And the content of this file shall be "some text"
And a file "$TESTDEST/sources/misc/date-and-time/bar.txt" shall exist
And the content of this file shall be "some text"
And a file "$TESTDEST/hashes/**/#{hash_var}" shall exist
And the content of this file shall be "some text"
And a file "$TESTDEST/meta/**/#{hash_var}" shall exist
And the content of this file shall be "..."

Given an empty dir "$TESTDEST/"
And a file "foo.txt"
And the content of this file is "some text"
And a file "bar.txt"
And the content of this file is "another text"
When I invoke '''tobak --destination="$TESTDEST/" --timestamp="date-and-time" foo.txt bar.txt'''
And hash_var1 contains the hash of "foo.txt"
And hash_var2 contains the hash of "bar.txt"
Then a file "$TESTDEST/sources/misc/date-and-time/foo.txt" shall exist
And the content of this file shall be "some text"
And a file "$TESTDEST/sources/misc/date-and-time/bar.txt" shall exist
And the content of this file shall be "another text"
And a file "$TESTDEST/hashes/**/#{hash_var1}" shall exist
And the content of this file shall be "some text"
And a file "$TESTDEST/hashes/**/#{hash_var2}" shall exist
And the content of this file shall be "another text"
And a file "$TESTDEST/meta/**/#{hash_var1}" shall exist
And the content of this file shall be "..."
And a file "$TESTDEST/meta/**/#{hash_var2}" shall exist
And the content of this file shall be "..."

