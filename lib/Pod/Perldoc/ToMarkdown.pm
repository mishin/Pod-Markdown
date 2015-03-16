use strict;
use warnings;

package Pod::Perldoc::ToMarkdown;

use parent qw(Pod::Markdown);

sub parse_from_file {
  # Skip over SUPER's overwrite and go back to grandpa's method.
  Pod::Simple::parse_from_file(@_);
}

1;

=for test_synopsis
1;
__END__

=head1 SYNOPSIS

  perldoc -o Markdown Some::Module

=head1 DESCRIPTION

Pod::Perldoc expects a Pod::Parser compatible module,
however Pod::Markdown did not historically provide an entirely Pod::Parser
compatible interface.

=cut
