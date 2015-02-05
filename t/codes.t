# vim: set ts=2 sts=2 sw=2 expandtab smarttab:
use utf8;
use strict;
use warnings;
use lib 't/lib';
use MarkdownTests;

my $pod_prefix = Pod::Markdown->new->perldoc_url_prefix;

my $have_html_entities = eval { require HTML::Entities; 1 };
my $html_ents = {
  html_encode_chars => 1,
};

my @tests = (
  [I => q<italic>,          q{_italic_}],
  [B => q<bold>,            q{**bold**}],
  [C => q<code>,            q{`code`}],
  [C => q<c*de>,            q{`c*de`}],

  # links tested extensively in t/links.t
  [L => q<link>,             "[link](${pod_prefix}link)"],
  [L => q<star*>,            "[star\\*](${pod_prefix}star*)"],

  # Pod::Simple handles the E<> entirely (Pod::Markdown never sees them).
  [E => q<lt>,              q{<}],
  [E => q<gt>,              q{>}],
  [E => q<verbar>,          q{|}],
  [E => q<sol>,             q{/}],

  [E => q<copy>,            q{©},      'utf-8 copyright'],
  [E => q<copy>,            q{&copy;},  'html copyright', $html_ents],

  [E => q<eacute>,          q{é}],
  [E => q<eacute>,          q{&eacute;}, $html_ents],

  [E => q<0x201E>,          q{„},  'E hex'],
  [E => q<0x201E>,          q{&bdquo;},  'E hex', $html_ents],

  [E => q<075>,             q{=},  'E octal'],
  [E => q<0241>,            q{&iexcl;},  'E octal', $html_ents],

  [E => q<181>,             q{µ},  'E decimal'],
  [E => q<181>,             q{&micro;},  'E decimal', $html_ents],

  # legacy charnames specifically mentioned by perlpodspec
  [E => q<lchevron>,        q{«}],
  [E => q<rchevron>,        q{»}],

  [F => q<file.ext>,        q{`file.ext`}],
  [F => q<file_path.ext>,   q{`file_path.ext`}],
  [S => q<$x ? $y : $z>,    q{$x&nbsp;?&nbsp;$y&nbsp;:&nbsp;$z}],
  [X => q<index>,           q{}],
  [Z => q<>,                q{}],

  #[Q => q<unknown>,         q{Q<unknown>}, 'uknown code (Q<>)' ],
);

plan tests => scalar @tests;

foreach my $test ( @tests ){
SKIP: {
  my ($code, $text, $exp, $desc, $attr) = @$test;
  ($attr, $desc) = ($desc, undef) if ref $desc;

  $desc ||= "$code<$text>";
  $desc .= join ' ', ' (', %$attr, ')' if $attr;

  if( $attr->{html_encode_chars} && !$have_html_entities ){
    skip "HTML::Entities required for: $desc", 1;
  }

  my $parser = Pod::Markdown->new(%{ $attr || {} });
  $parser->output_string(\(my $got));
  # Prefix line to avoid escaping beginning-of-line characters (like `>`).
  my $prefix = 'Code:';
  $parser->parse_string_document("=pod\n\n$prefix $code<<< $text >>>");
  chomp($got);
  is $got, "$prefix $exp", $desc;
}
}
