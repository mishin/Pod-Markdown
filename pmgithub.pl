=pod
Hi Randy Stauner,

I have problem with getting the correct behavior from Pod::Markdown (or Pod::Markdown::Github) when using brackets < and >. For example:

=cut

use strict;
use warnings;

use Data::Dump;
use Pod::Markdown;

my $str = "=head1 OPTIONS\n\n=over 4\n\n=item B<< --file=<filename> >>\n\nFile name \n\n=back\n";

my $parser = Pod::Markdown->new;
my $markdown;
$parser->output_string( \$markdown );
$parser->parse_string_document($str);

dd $markdown;

=pod

Gives output:

"# OPTIONS\n\n- **--file=<filename>**\n\n    File name \n"

Note that the angle brackets in  <filename> is not escaped with a backslash. This causes Github to believe that it is a HTML tag and therefore it will not be shown. The desired output would be

"# OPTIONS\n\n- **--file=\<filename\>**\n\n    File name \n"
where the brackets < and > should be escaped with a backslash.

Note that I first asked this on stackoverflow.com, here is the link:

http://stackoverflow.com/questions/28496298/escape-angle-brackets-using-podmarkdown

I also contacted the maintainer of Pod::Markdown::Github, Stefan Geneshky, and he recommended me to  file an error report with Pod::Markdown.

Best regards,
Håkon Hægland

=cut
