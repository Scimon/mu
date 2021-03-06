use strict;

=head2 $::Array

=head3 Parents:

=head3 Attributes:

none

=head3 Methods:

=over

=item new

=item eager

=item INDEX

=item elems

=item push

=item pop

=item shift

=item unshift

=item sort

=item map

=cut

$::Array = KindaPerl6::Runtime::Perl5::MOP::make_class(
    proto => $::Array,
    name=> 'Array',
    parents => [ ],
    methods=>
    {

    new => sub {
            my ( $proto, $param ) = @_;
            my $self = {
                %{ $proto },
                _value => { _array => [ ] },
            };
            if ($param) {

                my $index = 0;

                my $add_parameter;
                $add_parameter = sub {
                    my $p = $_[0];
                    if ( exists $p->{_roles}{array_container} ) {
                        #warn "STORE \@Array to \@Array:   ", ::DISPATCH( $p, "perl" )->{_value};
                        my $list = $p->{_value}{cell};   # ::DISPATCH( $p, 'FETCH' );
                        #warn "List:   ", ::DISPATCH( $list, "perl" )->{_value};
                        $add_parameter->( $_ )
                            for @{ $list->{_value}{_array} };
                    }
                    elsif ( ::DISPATCH( $p, 'does', $::List )->{_value} ) {
                        #warn "List:   ", ::DISPATCH( $p, "perl" )->{_value};
                        my $list = ::DISPATCH( $p, 'eager' );
                        #warn "List:   ", ::DISPATCH( $list, "perl" )->{_value};
                        $add_parameter->( $_ )
                            for @{ $list->{_value}{_array} };
                    }
                    else {
                        #warn "  Push: ", ::DISPATCH( $p, "perl" )->{_value};
                        #::DISPATCH( $array, 'push', $p );
                        ::DISPATCH_VAR(
                                ::DISPATCH( $self, 'INDEX', $index ),
                                'STORE',
                                $p,
                            );
                        $index++;
                    }
                };
                $add_parameter->( $_ )
                    for @{ $param->{_array} };

            }
            return $self;
        },
    values => sub {
            ::DISPATCH( $::List, 'new',
                    { _array => [  @{$_[0]{_value}{_array}}  ], }
            );
    },
    FETCH => sub { @_ },
    eager => sub { @_ },
    INDEX=>sub {
            my $self = shift;
            return $self
                unless @_;
            my $key
                = ref( $_[0] )
                ? ::DISPATCH( ::DISPATCH( $_[0], "Int" ), "p5landish" )
                : $_[0];
            return $self->{_value}{_array}[$key]
                if exists $self->{_value}{_array}[$key];
            return ::DISPATCH(
                $::ContainerProxy,
                "new",
                sub {
                        if ( ! exists $self->{_value}{_array}[$key] ) {
                            $self->{_value}{_array}[$key] = ::DISPATCH( $::Container, 'new' );
                        }
                        $self->{_value}{_array}[$key];
                    },
            );
        },
    elems =>sub {
            ::DISPATCH($::Int, "new", scalar @{ $_[0]{_value}{_array} } );
        },
    push =>sub {
            my $self = shift;
            my @param = map {
                my $v = ::DISPATCH( $::Scalar, "new" );
                ::DISPATCH_VAR( $v, 'STORE', ::DISPATCH( $_, 'FETCH' ) );
                $v;
            } @_;
            ::DISPATCH($::Int, 'new',
                    ( push @{ $self->{_value}{_array} }, @param )
                );
        },
    pop =>sub {
            my $self = shift;
            pop @{ $self->{_value}{_array} };
        },

    shift =>sub {
            my $self = shift;
            shift @{ $self->{_value}{_array} }, @_;  # XXX process List properly
        },
    unshift =>sub {
            my $self = shift;
            my @param = map { ::DISPATCH( $_, 'FETCH' ) } @_;
            ::DISPATCH($::Int, 'new', unshift @{ $self->{_value}{_array} }, @param);
        },
    sort =>sub {
            my $sub = $_[1];
            ::DISPATCH( $::List, 'new',
                    { _array => [
                            sort {
                                ::DISPATCH(
                                        $sub,
                                        "APPLY",
                                        $a, $b
                                    )->{_value};
                            } @{$_[0]{_value}{_array}}
                        ],
                    }
            );
        },
    map =>sub {
            local $_;
            my $sub = $_[1];
            # arity: http://en.wikipedia.org/wiki/Arity, the number of arguments a function takes
            my $arity = ::DISPATCH( ::DISPATCH( $sub, 'signature' ), 'arity' )->{_value};
            #print "Array.map arity: $arity\n";
            my $result = ::DISPATCH( $::List, 'new' );
            my @list = @{$_[0]{_value}{_array}};
            my @params;
            while ( @list ) {
                if ( $arity ) {
                    @params = splice( @list, 0, $arity );
                }
                else {
                    $_ = shift @list;   # ???
                }
                push @{ $result->{_value}{_array} },
                    ::DISPATCH(
                        $sub,
                        "APPLY",
                        @params,
                    );
            };
            $result;
        },
});

1;

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

=cut
