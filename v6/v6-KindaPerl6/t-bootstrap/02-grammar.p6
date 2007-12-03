use KindaPerl6::Runtime::Perl5::Runtime;
use KindaPerl6::Grammar::Quote;
use KindaPerl6::Grammar;
use KindaPerl6::Ast;

say "1..4";
my $count=0;
sub ok($ok) {
    $count = $count + 1;
    if ($ok) {
        say "ok $count";
    } else {
        say "not ok $count";
    }
}

# digits

say "# ** now testing: <digits>";
$_ = '123';
my $MATCH = KindaPerl6::Grammar.digits();
say "# ",($MATCH.perl);
say "# ",($MATCH.Str);
ok( $MATCH.Str eq '123');

# val_int

say "# ** now testing: <val_int>";
$_ = '123';
my $MATCH = KindaPerl6::Grammar.val_int();
say "# ",($MATCH.perl);
say "# ",($MATCH.Str);
ok( $MATCH.Str eq "Val::Int.new(int => '123')");

# simple term

say "# ** now testing: <term>";
$_ = '...';
my $MATCH = KindaPerl6::Grammar.term();
say "# ",($MATCH.perl);
say "# ",($MATCH.Str);
ok( $MATCH.Str eq "Apply.new(arguments => [  ], code => Var.new(namespace => [  ], name => 'die', twigil => '', sigil => '&'))");

# simple term

say "# ** now testing: <term>";
$_ = 'Inf';
my $MATCH = KindaPerl6::Grammar.term();
say "# ",($MATCH.perl);
say "# ",($MATCH.Str);
ok( $MATCH.Str eq "   Inf   ");;


#term

say "# ** now testing: <term>";
$_ = '123';
my $MATCH = KindaPerl6::Grammar.term();
say "# ",($MATCH.perl);
say "# ",($MATCH.Str);
ok( $MATCH.Str eq '123');



=begin

=head1 AUTHORS

The Pugs Team E<lt>perl6-compiler@perl.orgE<gt>.

=head1 SEE ALSO

The Perl 6 homepage at L<http://dev.perl.org/perl6>.

The Pugs homepage at L<http://pugscode.org/>.

=head1 COPYRIGHT

Copyright 2007 by Flavio Soibelmann Glock and others.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=end
