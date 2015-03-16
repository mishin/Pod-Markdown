# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
use utf8;
use strict;
use warnings;
use lib 't/lib';
use MarkdownTests;

# Escape things that would be interpreted as inline html.

sub escape_ok {
  my ($pod, $markdown, $desc, %opts) = @_;
  my $verbatim = $opts{verbatim} || $pod;

  convert_ok("B<< $pod >>", $markdown,  "$desc: inline html escaped");
  convert_ok("C<< $pod >>", qq{`$verbatim`}, "$desc: html not escaped in code span");
}

# This was an actual bug report.
escape_ok
  q{--file=<filename>},
  q{**--file=&lt;filename>**},
  'command lines args';

# Use real html tags.
# This is a good example to copy/paste into a markdown processor
# to see how it handles the html.
# For example, github repsects "\<" and "\&" but daringfireball does not.
# That's why we use html entity encoding (more portable).
escape_ok
  q{h&nbsp;=<hr>},
  q{**h&amp;nbsp;=&lt;hr>**},
  'real html';

# Ensure that two pod "strings" still escape the < and & properly.
# Use S<> since it counts as an event (and therefore creates two separate
# "handle_text" calls) but does not produce boundary characters (the text
# inside and around the S<> will have no characters between them).
escape_ok
  q{the <S<cmp>E<gt> operator and S<&>foobar; and eol &},
  q{**the &lt;cmp> operator and &amp;foobar; and eol &**},
  '< and & are escaped properly even as separate pod strings',
  verbatim => q{the <cmp> operator and &foobar; and eol &};

# Don't undo it for literal ones that happen to be at the end of strings.
escape_ok
  q{literal &amp; and &lt;},
  q{**literal &amp;amp; and &amp;lt;**},
  'literal entity from pod at end of string stays amp-escaped';


done_testing;
