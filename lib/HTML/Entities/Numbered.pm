package HTML::Entities::Numbered;

use strict;
use HTML::Entities ();
use vars qw($VERSION @EXPORT %DECIMALS %ENTITIES);
use base qw(Exporter);
@EXPORT = qw(name2decimal name2hex decimal2name hex2name);

$VERSION = '0.01';

BEGIN {
    for my $name (keys %HTML::Entities::entity2char) {
	$DECIMALS{$name} = ord($HTML::Entities::entity2char{$name});
    }
    unless ($] > 5.007) { # import extra table
	require HTML::Entities::Numbered::Extra;
	%DECIMALS = (
	    %DECIMALS,
	    %HTML::Entities::Numbered::Extra::EXTRA_DECIMALS,
	);
    }
    %ENTITIES = reverse %DECIMALS;
}

sub name2decimal {
    my $content = shift;
    $content =~ s/(&[a-z0-9]+;)/_convert2num($1, '&#%d;')/ieg;
    return $content;
}

sub name2hex {
    my $content = shift;
    $content =~ s/(&[a-z0-9]+;)/_convert2num($1, '&#x%X;')/ieg;
    return $content;
}

sub decimal2name {
    my $content = shift;
    $content =~ s/(&#\d+;)/_convert2name($1)/ieg;
    return $content;
}

sub hex2name {
    my $content = shift;
    $content =~ s/(&#x[a-f0-9]+;)/_convert2name($1)/ieg;
    return $content;
}

sub _convert2num {
    my($reference, $format) = @_;
    my($name) = $reference =~ /^&([a-z0-9]+);$/i;
    return exists $DECIMALS{$name} ?
	sprintf($format, $DECIMALS{$name}) : $reference;
}

sub _convert2name {
    my $reference = shift;
    my($is_hex, $decimal) = $reference =~ /^&#(x?)([a-f0-9]+);$/i;
    $decimal = sprintf('%d', ($is_hex ? hex($decimal) : $decimal));
    return exists $ENTITIES{$decimal} ?
	sprintf('&%s;', $ENTITIES{$decimal}) : $reference;
}

1;
__END__

=head1 NAME

HTML::Entities::Numbered - Conversion of numbered HTML entities

=head1 SYNOPSIS

 use HTML::Entities::Numbered;
 
 $html = 'Hi Honey<b>&hearts;</b>';
 
 # convert named HTML entities to numbered (decimal)
 $decimal = name2decimal($html);    # Hi Honey<b>&#9829;</b>
 
 # to numbered (hexadecimal)
 $hex     = name2hex($html);        # Hi Honey<b>&#x2665;</b>
 
 $content    = 'Copyright &#169; Larry Wall';
 
 # convert numbered HTML entities (decimal) to named
 $name1   = decimal2name($content); # Copyright &copy; Larry Wall
 
 $content    = 'Copyright &#xA9; Larry Wall';
 # convert numbered HTML entitites (hexadecimal) to named
 $name2   = hex2name($content);     # Copyright &copy; Larry Wall

=head1 DESCRIPTION

HTML::Entities::Numbered is a subclass of L<HTML::Entities>. It is a
content conversion filter for named HTML entities (symbols,
mathmetical symbols, Greek letters, Latin letters, etc.).
When an argument of C<name2decimal()> or C<name2hex()> contains some
B<nameable> HTML entities, they will be replaced to numbered HTML
entities. By the same token, when an argument of C<decimal2name()> or
C<hex2name()> contains some B<nameable> numbered HTML entities, they
will be replaced to named HTML entities.

The entities hash table is imported from L<HTML::Entities>. However,
this module doesn't work correctly for earlier releases of Perl 5.7.0.
If this module is used with the older, it will be exported extra hash
table from L<HTML::Entities::Numbered::Extra> for conversion
correctness.

This bay be also useful for making XML (corrects the undefined entity
references).

=head1 FUNCTIONS

Following all functions are exported by default.

=over 4

=item * name2decimal

Some included named HTML entities in argument of C<name2decimal()>
will be replaced to decimal numbered HTML entities.

=item * name2hex

Some included named HTML entities in argument of C<name2decimal()>
will be replaced to hexadecimal numbered HTML entities.

=item * decimal2name

Some include decimal numbered HTML entities in argument of
C<decimal2name()> will be replaced to named HTML entities
(If they're nameable).

=item * hex2name

Some include hexadecimal numbered HTML entities in argument of
C<decimal2name()> will be replaced to named HTML entities
(If they're nameable).

=back

If you'd prefer not to import them functions into the caller's
namespace, you can call them as below:

 use HTML::Entities::Numbered ();
 
 $decimal = HTML::Entities::Numbered::name2decimal($str);
 $hex     = HTML::Entities::Numbered::name2hex($str);
 $named1  = HTML::Entities::Numbered::decimal2name($str);
 $named2  = HTML::Entities::Numbered::hex2name($str);

=head1 AUTHOR

Koichi Taniguchi E<lt>taniguchi@livedoor.jpE<gt>

=head1 COPYRIGHT

Copyright (c) 2004 Koichi Taniguchi. Japan. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<HTML::Entities>,
L<http://www.w3.org/TR/REC-html40/sgml/entities.html>

=cut
