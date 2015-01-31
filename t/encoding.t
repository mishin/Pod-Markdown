# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
use strict;
use warnings;
use lib 't/lib';
use MarkdownTests;
use File::Temp qw{ tempfile }; # core

# NOTE: All strings in this test file are byte-strings.

sub test_encoding {
  my ($attr, $pod, $exp, $desc) = @_;

  my $parser = Pod::Markdown->new(%$attr);

  # Unlink on exit, but persist file so we can read it independently.
  my ($fh, $outfile) = tempfile('pod2markdown.XXXXXX', TMPDIR => 1, UNLINK => 1);

  # Ignore errors about high-bit chars without =encoding.
  $parser->no_errata_section(1);

  $parser->output_fh($fh);
  $parser->parse_string_document($pod);

  # Flush writes.
  close $fh;

  eq_or_diff slurp_file($outfile), $exp, $desc;
}

foreach my $enc ( 1, 0 ){

  test_encoding(
    {
      output_encoding => 'utf-8',
    },
    ($enc ? "=encoding latin1\n\n" : "") . "=head1 POD\n\n.\xc0\n",
    "# POD\n\n.\xc3\x80\n",
    'latin1 encoded as utf-8 ' . ($enc ? 'with' : 'without') . ' =encoding',
  );

}

test_encoding(
  {
    output_encoding => 'utf-8',
  },
  "=encoding cp1252\n\n=head1 POD\n\n.\x95\n",
  "# POD\n\n.\x{e2}\x{80}\x{a2}\n",
  'cp1252 encoded as utf-8',
);

test_encoding(
  {
    match_encoding => 1
  },
  "=encoding latin1\n\n=head1 POD\n\n.\xa4\n",
  "# POD\n\n.\xa4\n",
  'use input encoding (latin1)',
);

test_encoding(
  {
    match_encoding => 1
  },
  "=encoding utf-8\n\n=head1 POD\n\n.\xc2\xa4\n",
  "# POD\n\n.\xc2\xa4\n",
  'use input encoding (utf-8)',
);

done_testing;
