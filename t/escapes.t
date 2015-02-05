# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
use utf8;
use strict;
use warnings;
use lib 't/lib';
use MarkdownTests;

# Escape things that would be interpreted as inline html.

sub escape_ok {
  my ($pod, $markdown, $desc) = @_;

  convert_ok("B<< $pod >>", $markdown,  "$desc: inline html escaped");
  convert_ok("C<< $pod >>", qq{`$pod`}, "$desc: html not escaped in code span");
}

# This was an actual bug report.
escape_ok
  q{--file=<filename>},
  q{**--file=&lt;filename&gt;**},
  'command lines args';

# Use real html tags.
# This is a good example to copy/paste into a markdown processor
# to see how it handles the html.
# For example, github repsects "\<" and "\&" but daringfireball does not.
# That's why we use html entity encoding (more portable).
escape_ok
  q{h&nbsp;=<hr>},
  q{**h&amp;nbsp;=&lt;hr&gt;**},
  'real html';

done_testing;
