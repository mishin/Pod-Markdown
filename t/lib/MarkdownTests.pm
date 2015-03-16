use strict;
use warnings;

package # no_index
  MarkdownTests;

use Test::More 0.88;  # done_testing
use Test::Differences;
use Pod::Markdown ();

use Exporter ();
our @ISA = qw(Exporter);
our @EXPORT = (
  qw(
    convert_ok
    io_string
    eq_or_diff
    slurp_file
    warning
    with_locale
    with_latin1_locale
    with_utf8_locale
  ),
  @Test::More::EXPORT
);

sub import {
  my $class = shift;
  Test::More::plan(@_) if @_;
  @_ = ($class);
  strict->import;
  warnings->import;
  goto &Exporter::import;
}

sub diag_xml {
  diag_with('Pod::Simple::DumpAsXML', @_);
}

sub diag_text {
  diag_with('Pod::Simple::DumpAsText', @_);
}

sub diag_with {
  my ($class, $pod) = @_;
  $class =~ /[^a-zA-Z0-9:]/ and die "Invalid class name '$class'";
  eval "require $class" or die $@;
  my $parser = $class->new;
  $parser->output_string(\(my $got));
  $parser->parse_string_document("=pod\n\n$pod\n");
  diag $got;
}

sub convert_ok {
  my ($pod, $exp, $desc, %opts) = @_;
  my $parser = Pod::Markdown->new;

  diag_xml($pod)  if $opts{diag_xml};
  diag_text($pod) if $opts{diag_text};

  $opts{init}->($parser) if $opts{init};

  $parser->output_string(\(my $got));
  $parser->parse_string_document("=pod\n\n$pod\n\n=cut\n");

  chomp for ($got, $exp);

  eq_or_diff($got, $exp, $desc);
}

{ package # no_index
    MarkdownTests::IOString;
  use Symbol ();
  sub new {
    my $class = ref($_[0]) || $_[0];
    my $s = $_[1];
    my $self = Symbol::gensym;
    tie *$self, $class, $self;
    *$self->{lines} = [map { "$_\n" } split /\n/, $s ];
    $self;
  }
  sub READLINE { shift @{ *{$_[0]}->{lines} } }
  sub TIEHANDLE {
    my ($class, $s) = @_;
    bless $s, $class;
  }
  { no warnings 'once'; *getline = \&READLINE; }
}

sub io_string {
  MarkdownTests::IOString->new(@_);
}

sub slurp_file {
  my $path = shift;
  open(my $fh, '<', $path)
    or die "Failed to open $path: $!";
  slurp_fh($fh)
}
sub slurp_fh { my $fh = shift; local $/; <$fh>; }

sub with_locale {
  my ($desc, $locales, $sub) = @_;
  $locales = [ $locales ] unless ref $locales;

  local %ENV = %ENV;
  delete $ENV{$_}
    for ( qw( LANG LANGUAGE ), grep { /^LC_/ } keys %ENV );

  my $locale;
  foreach my $loc ( @$locales ){
    # Quiet the warnings;
    #local $ENV{PERL_BADLANG} = 0;
    # Is POSIX locale_h portable?
    0 == system { $^X } $^X, '-MPOSIX=locale_h',
      -e => 'setlocale(LC_ALL,shift) or exit 1', $loc
        and $locale = $loc, last;
  }

  SKIP: {
    skip "Cannot find locale for '$desc'", 1
      unless $locale;

    $ENV{LC_ALL} = $locale;
    $sub->($locale);
  }
}

sub with_utf8_locale {
  with_locale(utf8 => 'en_US.UTF-8' => @_);
}

sub with_latin1_locale {
  # Is there a more reliable way to set a latin1 locale?
  with_locale(latin1 => [qw( en_US.ISO8859-1 en_US )], @_);
}

# Similar interface to Test::Fatal;
sub warning (&) { ## no critic (Prototypes)
  my @warnings;
  local $SIG{__WARN__} = sub { push @warnings, $_[0] };
  $_[0]->();
  pop @warnings;
}

1;
