package Pugs::Emitter::Perl6::Perl5;

# p6-ast to perl5 emitter

use strict;
use warnings;
use Data::Dumper;
$Data::Dumper::Indent = 1;

sub _mangle_var {
    my $s = shift;
    # globals
    return '$::_EXCL_' if $s eq '$!';  

    substr($s,1)   =~ s/ ([^a-zA-Z0-9_:]) / '_'.ord($1).'_' /xge;
    return $s;
}

sub _not_implemented {
    my ( $n, $what ) = @_;
    return "die q(not implemented $what: " . Dumper( $n ) . ")";
}

sub emit {
    my ($grammar, $ast) = @_;
    # runtime parameters: $grammar, $string, $state, $arg_list
    # rule parameters: see Runtime::Rule.pm
    return _emit( $ast, '' );
        #"do{\n" .
        #_emit( $ast, '    ' ) . "\n" .
        #"}";
}

sub _emit {
    my $n = $_[0];
    #die "_emit: ", Dumper( $n ); 
    #warn "fixity: $n->{fixity}\n" if exists $n->{fixity};
    
    # 'undef' example: parameter list, in a sub call without parameters
    return ''
        unless defined $n;
    
    die "unknown node: ", Dumper( $n )
        unless ref( $n ) eq 'HASH';
        
    return $n->{bareword} 
        if exists $n->{bareword};
        
    return $n->{code} 
        if exists $n->{code};
        
    return $n->{int} 
        if exists $n->{int};
        
    return $n->{num} 
        if exists $n->{num};
        
    return _mangle_var( $n->{scalar} )
        if exists $n->{scalar};
        
    return $n->{array} 
        if exists $n->{array};
        
    return $n->{hash} 
        if exists $n->{hash};
        
    return '"' . $n->{double_quoted} . '"' 
        if exists $n->{double_quoted};
            
    return '\'' . $n->{single_quoted} . '\'' 
        if exists $n->{single_quoted};
            
    return 'qw(' . $n->{angle_quoted} . ')' 
        if exists $n->{angle_quoted};
            
    return assoc_list( $n )
        if exists $n->{assoc}  && $n->{assoc}  eq 'list';
        
    if ( exists $n->{fixity} ) {
        return infix( $n )
            if $n->{fixity} eq 'infix';
        return prefix( $n )
            if $n->{fixity} eq 'prefix';
        return postfix( $n )
            if $n->{fixity} eq 'postfix';
        return circumfix( $n )
            if $n->{fixity} eq 'circumfix';
        return postcircumfix( $n )
            if $n->{fixity} eq 'postcircumfix';
    }
    
    return statement( $n )
        if ref $n->{op1} && exists $n->{op1}{stmt};

    return default( $n );
}

sub assoc_list {
    my $n = $_[0];
    # print "list emit_rule: ", Dumper( $n );

    if ( $n->{op1} eq ';' ||
         $n->{op1} eq ',' ) {
        return join ( $n->{op1} . "\n", 
            map { _emit( $_ ) } @{$n->{list}} 
        );
    }
    
    return _not_implemented( $n->{op1}, "list-op" );
}

sub _emit_parameter_binding {
    my $n = $_[0];
    
    # no parameters
    return ''
        if  ! defined $n ||
            @$n == 0;
    
    # XXX - $n should be hashref?
    #warn "parameter list: ",Dumper $n->[0];
    
    my $param = _emit( $n->[0] );
    return "my ($param) = \@_;\n";
        
    #if ( @$n == 1 ) {
    #    # just one parameter
    #    my $param = _emit( $n->[0] );
    #    return "my $param = \$_[0];\n";
    #}
    #
    #return " # XXX - " . (scalar @$n) . " parameters\n";
}

sub default {
    my $n = $_[0];
    #warn "emit: ", Dumper( $n );
    
    if ( exists $n->{END} ) {
        return "END {\n" . _emit( $n->{END} ) . "\n }";
    }
    
    if ( exists $n->{bare_block} ) {
        return  "{\n" . _emit( $n->{bare_block} ) . "\n }\n";
    }

    if ( $n->{op1} eq 'call' ) {
        # warn "call: ",Dumper $n;
        if ( $n->{sub}{bareword} eq 'use' ) {
            # use v6-pugs
            if ( exists $n->{param}{cpan_bareword} ) {
                if ( $n->{param}{cpan_bareword} eq 'v6-pugs' ) {
                    return " # use v6-pugs\n";
                }
            }
            #warn "call: ",Dumper $n;
            if ( $n->{param}{sub}{bareword} eq 'v5' ) {
                return "warn 'use v5 - not implemented'";
            }
            if ( $n->{param}{sub}{bareword} eq 'v6' ) {
                return " # use v6\n";
            }
            # use module::name 'param'
            return "use " . _emit( $n->{param} );
        }
        return " " . $n->{sub}{bareword} . " '', " . _emit( $n->{param}, '  ' ) 
            if $n->{sub}{bareword} eq 'print' ||
               $n->{sub}{bareword} eq 'warn';
        return " print '', " . _emit( $n->{param}, '  ' ) . ";\n" .
            " print " . '"\n"'
            if $n->{sub}{bareword} eq 'say';
        return ' ' . $n->{sub}{bareword} . '(' . _emit( $n->{param}, '  ' ) . ')';
    }
    
    if ( $n->{op1} eq 'method_call' ) {    
        if ( $n->{method}{bareword} eq 'print' ||
             $n->{method}{bareword} eq 'warn' ) {
            return " print '', " . _emit( $n->{self}, '  ' );
        }
        if ( $n->{method}{bareword} eq 'say' ) {
            return " print '', " . _emit( $n->{self}, '  ' ) . ', "\n"';
        }
        #warn "method_call: ", Dumper( $n );
        
        # "autobox"
        
        if ( exists $n->{self}{code} ) {
            # &code.goto;
            return 
                " \@_ = (" . _emit( $n->{param}, '  ' ) . ");\n" .
                " " . _emit( $n->{method}, '  ' ) . " " .
                    _emit( $n->{self}, '  ' );
        }
        
        if ( exists $n->{self}{scalar} ) {
            # $scalar.++;
            return 
                " Pugs::Runtime::Perl6::Scalar::" . _emit( $n->{method}, '  ' ) . 
                "(" . _emit( $n->{self}, '  ' ) .
                ", " . _emit( $n->{param}, '  ' ) . ")" ;
        }
        
        # normal methods
        
        return " " . $n->{sub}{bareword} .
            '(' .
            join ( ";\n", 
                map { _emit( $_ ) } @{$n->{param}} 
            ) .
            ')';
    }

    return _not_implemented( $n, "syntax" );
}

sub statement {
    my $n = $_[0];
    #warn "statement: ", Dumper( $n );
    
    if ( $n->{op1}{stmt} eq 'if'     || 
         $n->{op1}{stmt} eq 'unless' ) {
        return  " " . $n->{op1}{stmt} . 
                '(' . _emit( $n->{exp1} ) . ')' .
                " {\n" . _emit( $n->{exp2} ) . "\n }\n" .
                " else" .
                " {\n" . _emit( $n->{exp3} ) . "\n }";
    }

    if ( $n->{op1}{stmt} eq 'sub' ) {
        #warn "sub: ",Dumper $n;
        return  " " . $n->{op1}{stmt} . 
                ' ' . $n->{name}{bareword} . 
                " {\n" . 
                    _emit_parameter_binding( $n->{signature} ) .
                    _emit( $n->{block} ) . 
                "\n }";
    }

    if ( $n->{op1}{stmt} eq 'for' ) {
        #warn "sub: ",Dumper $n;
        if ( exists $n->{exp2}{pointy_block} ) {
            return  " " . $n->{op1}{stmt} . 
                    ' my ' . _emit( $n->{exp2}{signature} ) . '' . 
                    ' (' . _emit( $n->{exp1} ) . ')' . 
                    " {\n" . 
                        # _emit_parameter_binding( $n->{signature} ) .
                        _emit( $n->{exp2}{pointy_block} ) . 
                    "\n }";
        }
        return  " " . $n->{op1}{stmt} . 
                ' (' . _emit( $n->{exp1} ) . ')' . 
                " {\n" . 
                    # _emit_parameter_binding( $n->{signature} ) .
                    _emit( $n->{exp2} ) . 
                "\n }";
    }

    return _not_implemented( $n, "statement" );
}

sub infix {
    my $n = $_[0];
    # print "infix: ", Dumper( $n );
    
    if ( $n->{op1}{op} eq '~' ) {
        return _emit( $n->{exp1} ) . ' . ' . _emit( $n->{exp2} );
    }
    
    if ( $n->{op1}{op} eq ':=' ) {
        #warn "bind: ", Dumper( $n );
        return " tie " . _emit( $n->{exp1} ) . 
            ", 'Pugs::Runtime::Perl6::Scalar::Alias', " .
            "\\" . _emit( $n->{exp2} );
    }

    if ( exists $n->{exp2}{bare_block} ) {
        # $a = { 42 } 
        return " " . _emit( $n->{exp1} ) . ' ' . 
            $n->{op1}{op} . ' ' . "sub " . _emit( $n->{exp2} );
    }

    return _emit( $n->{exp1} ) . ' ' . 
        $n->{op1}{op} . ' ' . _emit( $n->{exp2} );
}

sub circumfix {
    my $n = $_[0];
    # print "infix: ", Dumper( $n );
    
    if ( $n->{op1}{op} eq '(' &&
         $n->{op2}{op} eq ')' ) {
        return '()'
            unless defined  $n->{exp1};
        return '(' . _emit( $n->{exp1} ) . ')';
    }
    
    return _not_implemented( $n, "circumfix" );
}

sub postcircumfix {
    my $n = $_[0];
    # print "postcircumfix: ", Dumper( $n );
    
    if ( $n->{op1}{op} eq '[' &&
         $n->{op2}{op} eq ']' ) {
        #return '()'
        #    unless defined  $n->{exp1};
        return _emit( $n->{exp1} ) . '[' . _emit( $n->{exp2} ) . ']';
    }
    
    return _not_implemented( $n, "postcircumfix" );
}

sub prefix {
    my $n = $_[0];
    # print "prefix: ", Dumper( $n );
    
    if ( $n->{op1}{op} eq 'my' ||
         $n->{op1}{op} eq 'our' ) {
        return $n->{op1}{op} . ' ' . _emit( $n->{exp1} );
    }
    if ( $n->{op1}{op} eq 'try' ) {
        return 'eval ' . _emit( $n->{exp1} ) . "; " . 
            _mangle_var( '$!' ) . " = \$@;";
    }
    if ( $n->{op1}{op} eq 'eval' ) {
        return 
            'do { ' . 
            'use Pugs::Compiler::Perl6; ' . # XXX - load at start
            'local $@; ' .
            'my @result; ' .    # XXX - test want()
            # call Perl::Tidy here? - see v6.pm ???
            'my $p6 = Pugs::Compiler::Perl6->compile( ' . _emit( $n->{exp1} ) . ' ); ' .
            'eval $p6->{perl5}; ' .
            _mangle_var( '$!' ) . ' = $@; ' .
            '@result }';  # /do
    }
    if ( $n->{op1}{op} eq '++' ||
         $n->{op1}{op} eq '--' ||
         $n->{op1}{op} eq '+'  ) {
        return $n->{op1}{op} . _emit( $n->{exp1} );
    }
    
    return _not_implemented( $n, "prefix" );
}

sub postfix {
    my $n = $_[0];
    # print "postfix: ", Dumper( $n );

    if ( $n->{op1}{op} eq '++' ||
         $n->{op1}{op} eq '--' ) {
        return _emit( $n->{exp1} ) . $n->{op1}{op};
    }
    
    return _not_implemented( $n, "postfix" );
}

1;
