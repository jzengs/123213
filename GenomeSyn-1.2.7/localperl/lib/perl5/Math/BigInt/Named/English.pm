#!/usr/bin/perl -w

package Math::BigInt::Named::English;

require 5.006001;
use base 'Math::BigInt::Named';
$VERSION = '0.02';

use strict;

sub name
  {
  # output the name of the number
  my ($x) = shift;
  $x = Math::BigInt->new($x) unless ref($x);
 
  my $self = ref($x);

  return '' if $x->is_nan();

  my $index = 0;

  my $ret = '';
  my $y = $x->copy(); my $rem;
  if ($y->sign() eq '-')
    {
    $ret = 'minus ';
    $y->babs();
    }
  if ($y < 1000) 
    {
    return $ret . $self->_triple($y,1,0);
    }
  my $triple;
  while (!$y->is_zero())
    {
    ($y,$rem) = $y->bdiv(1000);
    $ret = $self->_triple($rem,0,$index)
          .' ' . $self->_triple_name($index,$rem) . ' ' . $ret;
    $index++;
    }
  $ret =~ s/\s+$//;	# trailing spaces
  $ret;
  }

my $SMALL = [ qw/ 
  zero
  one
  two
  three
  four
  five
  six
  seven
  eight
  nine
  ten
  eleven
  twelf
  thirteen
  fourteen 
  fifteen
  sixteen
  seventeen
  eighteen
  nineteen
  / ];

my $ZEHN = [ qw /
  ten
  twenty
  thirty
  fourty
  fifty
  sixty
  seventy
  eighty
  ninety
  / ];  

my $HUNDERT = [ qw /
  one
  two
  three
  four
  five
  six
  seven
  eight
  nine
  / ];  

my $TRIPLE = [ qw /
  mi
  bi
  tri
  quadri
  penti
  hexi
  septi
  octi
  / ];

sub _triple_name
  {
  my ($self,$index,$number) = @_;
  
  return '' if $index == 0 || $number->is_zero();
  return 'thousand' if $index == 1;
 
  my $postfix = 'llion'; my $plural = 's';
  if (($index & 1) == 1)
    {
    $postfix = 'lliard';
    }
  $postfix .= $plural unless $number->is_one();
  $index -= 2;
  $TRIPLE->[$index >> 1] . $postfix;
  }

sub _triple
  {
  # return name of a triple (aka >= 0, and <= 1000)
  # input: number 	>= 0, < 1000)
  #        only    	true if triple is the only triple ever ($nr < 1000)
  #	   index	0 for last triple, 1 for thousand, 2 for million etc
  my ($self,$number,$only,$index) = @_;

  return '' if $number->is_zero() && !$only;	# 0 => null, but only for one
  return $SMALL->[$number] if $number < scalar @$SMALL;	# known name

  my $hundert = $number / 100;
  my $rem = $number % 100;
  my $rc = '';
  $rc = "$HUNDERT->[$hundert-1]hundred" if !$hundert->is_zero();

  my $concat = ''; $concat = 'and' if $rc ne ''; 
  return $rc if $rem->is_zero();
  return $rc . $concat . $SMALL->[$rem] if $rem < scalar @$SMALL;
  
  my $zehn; ($zehn,$rem) = $rem->bdiv(10);

  my $last = ''; 
  $last = $HUNDERT->[$rem-1] if !$rem->is_zero(); 	# 31, 32..
  $last = $ZEHN->[$zehn-1].$last if !$zehn->is_zero();  	# 1,2,3..
  
  $rc . $last;
  }

1;

__END__

=head1 NAME

Math::BigInt::Named::English - Math::BigInts that know their name in English

=head1 SYNOPSIS

  use Math::BigInt::Named::English;

  $x = Math::BigInt::Named::English->new($str);

  print $x->name(),"\n";

  print Math::BigInt::Named::English->from_name('one hundredandfive),"\n";

=head1 DESCRIPTION

This is a subclass of Math::BigInt and adds support for named numbers
with their name in English to Math::BigInt::Named.

Usually you do not need to use this directly, but rather go via
L<Math::BigInt::Named>.

=head1 METHODS

=head2 name()

	print Math::BigInt::Name->name( 123 );

Convert a BigInt to a name.

=head2 from_name()
  
	my $bigint = Math::BigInt::Name->from_name('hundertzwanzig');

Create a Math::BigInt::Name from a name string. B<Not yet implemented!>

=head1 BUGS

None know yet. Please see also L<Math::BigInt::Named>.

=head1 LICENSE

This program is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.

=head1 SEE ALSO

L<Math::BigFloat> and L<Math::Big> as well as L<Math::BigInt::BitVect>,
L<Math::BigInt::Pari> and  L<Math::BigInt::GMP>.

The package at
L<http://search.cpan.org/search?dist=Math-BigInt-Named> may
contain more documentation and examples as well as testcases.

=head1 AUTHORS

(C) by Tels http://bloodgate.com/ in late 2001, early 2002, 2007.

Based on work by Chris London Noll.

=cut
