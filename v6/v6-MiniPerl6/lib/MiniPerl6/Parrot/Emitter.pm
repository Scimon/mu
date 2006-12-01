use v6-alpha;

class CompUnit {
    has $.name;
    has %.attributes;
    has %.methods;
    has @.body;
    method emit {
        my $a := @.body;
        
        # --- SETUP NAMESPACE
        
        my $s :=   
            '.namespace [ "' ~ $.name ~ '" ] ' ~ Main::newline() ~
            #'.sub "__onload" :load' ~ Main::newline() ~
            #'.end'                ~ Main::newline() ~ Main::newline() ~
            '.sub _ :main'        ~ Main::newline() ~
            '.end'                ~ Main::newline() ~ Main::newline() ~

        # --- SETUP CLASS VARIABLES

            '.sub "_class_vars_"' ~ Main::newline();
        for @$a -> $item {
            if    ( $item.isa( 'Decl' ) )
               && ( $item.decl ne 'has' ) 
            {
                $s := $s ~ $item.emit;
            }
        };
        $s := $s ~
            '.end' ~ Main::newline ~ Main::newline();

        # --- SUBROUTINES AND METHODS

        for @$a -> $item {
            if   $item.isa( 'Sub'    ) 
              || $item.isa( 'Method' )
            {
                $s := $s ~ $item.emit;
            }
        };

        # --- AUTOGENERATED ACCESSORS

        for @$a -> $item {
            if    ( $item.isa( 'Decl' ) )
               && ( $item.decl eq 'has' ) 
            {
                my $name := ($item.var).name;
                $s := $s ~
            '.sub "' ~ $name ~ '" :method'       ~ Main::newline() ~ 
            '  .param pmc val      :optional'    ~ Main::newline() ~
            '  .param int has_val  :opt_flag'    ~ Main::newline() ~
            '  unless has_val goto ifelse'       ~ Main::newline() ~
            '  setattribute self, "' ~ $name ~ '", val' ~ Main::newline() ~
            '  goto ifend'        ~ Main::newline() ~
            'ifelse:'             ~ Main::newline() ~
            '  val = getattribute self, "' ~ $name ~ '"' ~ Main::newline() ~
            'ifend:'              ~ Main::newline() ~
            '  .return(val)'      ~ Main::newline() ~
            '.end'                ~ Main::newline() ~ Main::newline();

            }
        };

        # --- IMMEDIATE STATEMENTS

        $s := $s ~ 
            '.sub _ :anon :load :init :outer("_class_vars_")' ~ Main::newline() ~
            '  .local pmc self'   ~ Main::newline() ~
            '  newclass self, "' ~ $.name ~ '"' ~ Main::newline();
        for @$a -> $item {
            if    ( $item.isa( 'Decl' ) )
               && ( $item.decl eq 'has' ) 
            {
                $s := $s ~ $item.emit;
            };
            if   $item.isa( 'Decl'   ) 
              || $item.isa( 'Sub'    ) 
              || $item.isa( 'Method' )
            {
                # already done - ignore
            }
            else {
                $s := $s ~ $item.emit;
            }
        };
        $s := $s ~ 
            '.end' ~ Main::newline() ~ Main::newline();
        return $s;
    }
}

#  .namespace [ 'Main' ]
#  .sub _ :anon :load :init
#    print "hello"
#  .end


class Val::Int {
    has $.int;
    method emit {
        '  $P0 = new .Integer' ~ Main::newline ~
        '  $P0 = ' ~ $.int ~ Main::newline
    }
}

class Val::Bit {
    has $.bit;
    method emit {
        '  $P0 = new .Integer' ~ Main::newline ~
        '  $P0 = ' ~ $.bit ~ Main::newline
    }
}

class Val::Num {
    has $.num;
    method emit {
        '  $P0 = new .Float' ~ Main::newline ~
        '  $P0 = ' ~ $.num ~ Main::newline
    }
}

class Val::Buf {
    has $.buf;
    method emit {
        '  $P0 = new .String' ~ Main::newline ~
        '  $P0 = \'' ~ $.buf ~ '\'' ~ Main::newline
    }
}

class Val::Undef {
    method emit {
        '  $P0 = new .Undef' ~ Main::newline
    }
}

class Val::Object {
    has $.class;
    has %.fields;
    method emit {
        die 'Val::Object - not used yet';
        # 'bless(' ~ %.fields.perl ~ ', ' ~ $.class.perl ~ ')';
    }
}

class Lit::Seq {
    has @.seq;
    method emit {
        die 'Lit::Seq - not used yet';
        # '(' ~ (@.seq.>>emit).join('') ~ ')';
    }
}

class Lit::Array {
    has @.array;
    method emit {
        my $a := @.array;
        my $s := 
            '  save $P1' ~ Main::newline() ~
            '  $P1 = new .ResizablePMCArray' ~ Main::newline();
        for @$a -> $item {
            $s := $s ~ $item.emit;
            $s := $s ~ 
            '  push $P1, $P0' ~ Main.newline;
        };
        my $s := $s ~ 
            '  $P0 = $P1' ~ Main::newline() ~
            '  restore $P1' ~ Main::newline();
        return $s;
    }
}

class Lit::Hash {
    has @.hash;
    method emit {
        my $a := @.hash;
        my $s := 
            '  save $P1' ~ Main::newline() ~
            '  save $P2' ~ Main::newline() ~
            '  $P1 = new .Hash' ~ Main::newline();
        for @$a -> $item {
            $s := $s ~ ($item[0]).emit;
            $s := $s ~ 
            '  $P2 = $P0' ~ Main.newline;
            $s := $s ~ ($item[1]).emit;
            $s := $s ~ 
            '  set $P1[$P2], $P0' ~ Main.newline;
        };
        my $s := $s ~ 
            '  $P0 = $P1'   ~ Main::newline() ~
            '  restore $P2' ~ Main::newline() ~
            '  restore $P1' ~ Main::newline();
        return $s;
    }
}

class Lit::Code {
    method emit {
        die 'Lit::Code - not used yet';
    }
}

class Lit::Object {
    has $.class;
    has @.fields;
    method emit {
        # ::Type( 'value' => 42 )
        my $fields := @.fields;
        my $str := '';        
        $str := 
            '  save $P1' ~ Main::newline() ~
            '  save $S2' ~ Main::newline() ~
            '  $P1 = new "' ~ $.class ~ '"' ~ Main::newline();
        for @$fields -> $field {
            $str := $str ~ 
                ($field[0]).emit ~ 
                '  $S2 = $P0'    ~ Main::newline() ~
                ($field[1]).emit ~ 
                '  setattribute $P1, $S2, $P0' ~ Main::newline();
        };
        $str := $str ~ 
            '  $P0 = $P1'   ~ Main::newline() ~
            '  restore $S2' ~ Main::newline() ~
            '  restore $P1' ~ Main::newline();
        $str;
    }
}

class Index {
    has $.obj;
    has $.index;
    method emit {
        my $s := 
            '  save $P1'  ~ Main::newline();
        $s := $s ~ $.obj.emit;
        $s := $s ~ 
            '  $P1 = $P0' ~ Main.newline();
        $s := $s ~ $.index.emit;
        $s := $s ~ 
            '  $P0 = $P1[$P0]' ~ Main.newline();
        my $s := $s ~ 
            '  restore $P1' ~ Main::newline();
        return $s;
    }
}

class Lookup {
    has $.obj;
    has $.index;
    method emit {
        my $s := 
            '  save $P1'  ~ Main::newline();
        $s := $s ~ $.obj.emit;
        $s := $s ~ 
            '  $P1 = $P0' ~ Main.newline;
        $s := $s ~ $.index.emit;
        $s := $s ~ 
            '  $P0 = $P1[$P0]' ~ Main.newline;
        my $s := $s ~ 
            '  restore $P1' ~ Main::newline();
        return $s;
    }
}

# variables can be:
# $.var   - inside a method - parrot 'attribute'
# $.var   - inside a class  - parrot 'global' (does parrot have class attributes?)
# my $var - inside a sub or method   - parrot 'lexical' 
# my $var - inside a class  - parrot 'global'
# parameters - parrot subroutine parameters - fixed by storing into lexicals

class Var {
    has $.sigil;
    has $.twigil;
    has $.name;
    method emit {
           ( $.twigil eq '.' )
        ?? ( 
             '  $P0 = getattribute self, \'' ~ $.name ~ '\'' ~ Main::newline() 
           )
        !! (
             '  $P0 = find_lex \'' ~ self.full_name ~ '\'' ~ Main::newline() 
           )
    };
    method name {
        $.name
    };
    method full_name {
        # Normalize the sigil here into $
        # $x    => $x
        # @x    => $List_x
        # %x    => $Hash_x
        # &x    => $Code_x
        my $table := {
            '$' => '$',
            '@' => '$List_',
            '%' => '$Hash_',
            '&' => '$Code_',
        };
           ( $.twigil eq '.' )
        ?? ( 
             $.name 
           )
        !!  (    ( $.name eq '/' )
            ??   ( $table{$.sigil} ~ 'MATCH' )
            !!   ( $table{$.sigil} ~ $.name )
            )
    };
}

class Bind {
    has $.parameters;
    has $.arguments;
    method emit {
        if $.parameters.isa( 'Lit::Array' ) {

            #  [$a, [$b, $c]] := [1, [2, 3]]

            my $a := $.parameters.array;
            my $b := $.arguments.array;
            my $str := '';
            my $i := 0;
            for @$a -> $var {
                my $bind := ::Bind( 'parameters' => $var, 'arguments' => ($b[$i]) );
                $str := $str ~ ' ' ~ $bind.emit ~ '';
                $i := $i + 1;
            };
            return $str ~ $.parameters.emit ~ '';
        };
        if $.parameters.isa( 'Lit::Hash' ) {

            #  {:$a, :$b} := { a => 1, b => [2, 3]}

            # XXX TODO - this is *not* right

            my $a := $.parameters.hash;
            my $b := $.arguments.hash;
            my $str := '';
            my $i := 0;
            for @$a -> $var {
                my $bind := ::Bind( 'parameters' => $var[0], 'arguments' => ($b[$i])[1] );
                $str := $str ~ ' ' ~ $bind.emit ~ '';
                $i := $i + 1;
            };
            return $str ~ $.parameters.emit ~ '';
        };
        if $.parameters.isa( 'Var' ) {
            return
                $.arguments.emit ~
                '  store_lex \'' ~ $.parameters.full_name ~ '\', $P0' ~ Main::newline();
        };
        if $.parameters.isa( 'Decl' ) {
            return
                $.arguments.emit ~
                '  store_lex \'' ~ (($.parameters).var).full_name ~ '\', $P0' ~ Main::newline();
        };
        if $.parameters.isa( 'Lookup' ) {
            my $param := $.parameters;
            my $obj   := $param.obj;
            my $index := $param.index;
            return
                $.arguments.emit ~
                '  save $P2'  ~ Main::newline() ~
                '  $P2 = $P0' ~ Main::newline() ~
                '  save $P1'  ~ Main::newline() ~
                $obj.emit     ~
                '  $P1 = $P0' ~ Main::newline() ~
                $index.emit   ~
                '  $P1[$P0] = $P2' ~ Main::newline() ~
                '  restore $P1' ~ Main::newline() ~
                '  restore $P2' ~ Main::newline();
        };
        die "Not implemented binding: " ~ $.parameters ~ Main::newline() ~ $.parameters.emit;
    }
}

class Proto {
    has $.name;
    method emit {
        ~$.name
    }
}

class Call {
    has $.invocant;
    has $.hyper;
    has $.method;
    has @.arguments;
    has $.hyper;
    method emit {
        if     ($.method eq 'perl')
            || ($.method eq 'yaml')
            || ($.method eq 'say' )
            || ($.method eq 'join')
            || ($.method eq 'chars')
            || ($.method eq 'isa')
        {
            if ($.hyper) {
                return
                    '[ map { Main::' ~ $.method ~ '( $_, ' ~ ', ' ~ (@.arguments.>>emit).join('') ~ ')' ~ ' } @{ ' ~ $.invocant.emit ~ ' } ]';
            }
            else {
                return
                    'Main::' ~ $.method ~ '(' ~ $.invocant.emit ~ ', ' ~ (@.arguments.>>emit).join('') ~ ')';
            }
        };

        my $meth := $.method;
        if  $meth eq 'postcircumfix:<( )>'  {
             $meth := '';
        };

        my $call := '->' ~ $meth ~ '(' ~ (@.arguments.>>emit).join('') ~ ')';
        if ($.hyper) {
            return '[ map { $_' ~ $call ~ ' } @{ ' ~ $.invocant.emit ~ ' } ]';
        };

        # TODO - arguments
        #$.invocant.emit ~
        #'  $P0.' ~ $meth ~ '()' ~ Main.newline;

        my @args := @.arguments;
        my $str := '';
        my $ii := 10;
        for @args -> $arg {
            $str := $str ~ '  save $P' ~ $ii ~ Main::newline();
            $ii := $ii + 1;
        };
        my $i := 10;
        for @args -> $arg {
            $str := $str ~ $arg.emit ~
                '  $P' ~ $i ~ ' = $P0' ~ Main::newline();
            $i := $i + 1;
        };
        $str := $str ~ '  $P0 = ' ~ $.invocant.emit ~ Main::newline() ~
            '  $P0 = $P0.' ~ $meth ~ '('; 
        #$str := $str ~ '  ' ~ $.code ~ '(';
        $i := 0;
        my @p;
        for @args -> $arg {
            @p[$i] := '$P' ~ ($i+10);
            $i := $i + 1;
        };
        $str := $str ~ @p.join(', ') ~ ')' ~ Main::newline();
        for @args -> $arg {
            $ii := $ii - 1;
            $str := $str ~ '  restore $P' ~ $ii ~ Main::newline();
        };
        return $str;
    }
}

class Apply {
    has $.code;
    has @.arguments;
    my $label := 100;
    method emit {

        my $code := $.code;

        if $code eq 'say'        {
            return
                (@.arguments.>>emit).join( '  print $P0' ~ Main::newline ) ~
                '  print $P0' ~ Main::newline ~
                '  print "\n"' ~ Main::newline
        };
        if $code eq 'print'      {
            return
                (@.arguments.>>emit).join( '  print $P0' ~ Main::newline ) ~
                '  print $P0' ~ Main::newline 
        };
        if $code eq 'array'      { return 'TODO @{' ~ (@.arguments.>>emit).join(' ')    ~ '}' };

        if $code eq 'prefix:<~>' { 
            return 
                (@.arguments[0]).emit ~
                '  $S0 = $P0'    ~ Main::newline() ~
                '  $P0 = $S0'    ~ Main::newline();
        };
        if $code eq 'prefix:<!>' {  
            return 
                ( ::If( cond      => @.arguments[0],
                        body      => [ ::Val::Bit( bit => 0 ) ],
                        otherwise => [ ::Val::Bit( bit => 1 ) ] 
                ) ).emit;
        };
        if $code eq 'prefix:<?>' {  
            return 
                ( ::If( cond      => @.arguments[0],
                        body      => [ ::Val::Bit( bit => 1 ) ],
                        otherwise => [ ::Val::Bit( bit => 0 ) ] 
                ) ).emit;
        };

        if $code eq 'prefix:<$>' { return 'TODO ${' ~ (@.arguments.>>emit).join(' ')    ~ '}' };
        if $code eq 'prefix:<@>' { return 'TODO @{' ~ (@.arguments.>>emit).join(' ')    ~ '}' };
        if $code eq 'prefix:<%>' { return 'TODO %{' ~ (@.arguments.>>emit).join(' ')    ~ '}' };

        if $code eq 'infix:<~>'  { 
            return 
                (@.arguments[0]).emit ~
                '  $S0 = $P0'    ~ Main::newline() ~
                '  save $S0'     ~ Main::newline() ~
                (@.arguments[1]).emit ~
                '  $S1 = $P0'    ~ Main::newline() ~
                '  restore $S0'  ~ Main::newline() ~
                '  $S0 = concat $S0, $S1' ~ Main::newline ~
                '  $P0 = $S0'    ~ Main::newline();
        };
        if $code eq 'infix:<+>'  { 
            return 
                '  save $P1'        ~ Main::newline ~
                (@.arguments[0]).emit ~
                '  $P1 = $P0'       ~ Main::newline ~
                (@.arguments[1]).emit ~
                '  $P0 = $P1 + $P0' ~ Main::newline ~
                '  restore $P1'     ~ Main::newline
        };
        if $code eq 'infix:<->'  { 
            return 
                '  save $P1'        ~ Main::newline ~
                (@.arguments[0]).emit ~
                '  $P1 = $P0'       ~ Main::newline ~
                (@.arguments[1]).emit ~
                '  $P0 = $P1 - $P0' ~ Main::newline ~
                '  restore $P1'     ~ Main::newline
        };

        if $code eq 'infix:<&&>' {  
            return 
                ( ::If( cond => @.arguments[0],
                        body => [@.arguments[1]],
                        otherwise => [ ]
                ) ).emit;
        };

        if $code eq 'infix:<||>' {  
            return 
                ( ::If( cond => @.arguments[0],
                        body => [ ],
                        otherwise => [@.arguments[1]] 
                ) ).emit;
        };

        if $code eq 'infix:<eq>' { 
            $label := $label + 1;
            my $id := $label;
            return
                (@.arguments[0]).emit ~
                '  $S0 = $P0'    ~ Main::newline() ~
                '  save $S0'     ~ Main::newline() ~
                (@.arguments[1]).emit ~
                '  $S1 = $P0'    ~ Main::newline() ~
                '  restore $S0'  ~ Main::newline() ~
                '  if $S0 == $S1 goto eq' ~ $id ~ Main::newline ~
                '  $P0 = 0'      ~ Main::newline();
                '  goto eq_end' ~ $id ~ Main::newline() ~
                'eq' ~ $id ~ ':' ~ Main::newline() ~
                '  $P0 = 1'      ~ Main::newline() ~
                'eq_end'  ~ $id ~ ':'  ~ Main::newline();
        };
        if $code eq 'infix:<ne>' { 
            $label := $label + 1;
            my $id := $label;
            return
                (@.arguments[0]).emit ~
                '  $S0 = $P0'    ~ Main::newline() ~
                '  save $S0'     ~ Main::newline() ~
                (@.arguments[1]).emit ~
                '  $S1 = $P0'    ~ Main::newline() ~
                '  restore $S0'  ~ Main::newline() ~
                '  if $S0 == $S1 goto eq' ~ $id ~ Main::newline ~
                '  $P0 = 1'      ~ Main::newline();
                '  goto eq_end' ~ $id ~ Main::newline() ~
                'eq' ~ $id ~ ':' ~ Main::newline() ~
                '  $P0 = 0'      ~ Main::newline() ~
                'eq_end'  ~ $id ~ ':'  ~ Main::newline();
        };
        if $code eq 'infix:<==>' { return 'TODO ('  ~ (@.arguments.>>emit).join(' == ') ~ ')' };

        if $code eq 'infix:<!=>' { return 'TODO ('  ~ (@.arguments.>>emit).join(' != ') ~ ')' };

        if $code eq 'ternary:<?? !!>' { 
            return 
                ( ::If( cond => @.arguments[0],
                        body => [@.arguments[1]],
                        otherwise => [@.arguments[2]] 
                ) ).emit;
        };

        if $code eq 'defined'  { 
            return 
                (@.arguments[0]).emit ~
                '  $I0 = defined $P0' ~ Main::newline() ~
                '  $P0 = $I0' ~ Main::newline();
        };

        if $code eq 'substr'  { 
            return 
                (@.arguments[0]).emit ~
                '  $S0 = $P0'    ~ Main::newline() ~
                '  save $S0'     ~ Main::newline() ~
                (@.arguments[1]).emit ~
                '  $I0 = $P0'    ~ Main::newline() ~
                '  save $I0'     ~ Main::newline() ~
                (@.arguments[2]).emit ~
                '  $I1 = $P0'    ~ Main::newline() ~
                '  restore $I0'  ~ Main::newline() ~
                '  restore $S0'  ~ Main::newline() ~
                '  $S0 = substr $S0, $I0, $I1' ~ Main::newline() ~
                '  $P0 = $S0'    ~ Main::newline();
        };

        #(@.arguments.>>emit).join('') ~
        #'  ' ~ $.code ~ '( $P0 )' ~ Main::newline();
        
        my @args := @.arguments;
        my $str := '';
        my $ii := 10;
        for @args -> $arg {
            $str := $str ~ '  save $P' ~ $ii ~ Main::newline();
            $ii := $ii + 1;
        };
        my $i := 10;
        for @args -> $arg {
            $str := $str ~ $arg.emit ~
                '  $P' ~ $i ~ ' = $P0' ~ Main::newline();
            $i := $i + 1;
        };
        $str := $str ~ '  $P0 = ' ~ $.code ~ '(';
        $i := 0;
        my @p;
        for @args -> $arg {
            @p[$i] := '$P' ~ ($i+10);
            $i := $i + 1;
        };
        $str := $str ~ @p.join(', ') ~ ')' ~ Main::newline();
        for @args -> $arg {
            $ii := $ii - 1;
            $str := $str ~ '  restore $P' ~ $ii ~ Main::newline();
        };
        return $str;
    }
}

class Return {
    has $.result;
    method emit {
        $.result.emit ~ 
        '  .return( $P0 )' ~ Main::newline();
    }
}

class If {
    has $.cond;
    has @.body;
    has @.otherwise;
    my $label := 100;
    method emit {
        $label := $label + 1;
        my $id := $label;
        return
            $.cond.emit ~ 
            '  unless $P0 goto ifelse' ~ $id ~ Main::newline() ~
                (@.body.>>emit).join('') ~ 
            '  goto ifend' ~ $id ~ Main::newline() ~
            'ifelse' ~ $id ~ ':' ~ Main::newline() ~
                (@.otherwise.>>emit).join('') ~ 
            'ifend'  ~ $id ~ ':'  ~ Main::newline();
    }
}

class For {
    has $.cond;
    has @.body;
    has @.topic;
    my $label := 100;
    method emit {
        my $cond := $.cond;
        $label := $label + 1;
        my $id := $label;
        if   $cond.isa( 'Var' )
          && $cond.sigil ne '@'
        {
            $cond := ::Lit::Array( array => [ $cond ] );
        };
        return
            '' ~ 
            $cond.emit ~
            '  save $P1' ~ Main::newline() ~
            '  save $P2' ~ Main::newline() ~
            '  $P1 = new .Iterator, $P0' ~ Main::newline() ~
            ' test_iter'  ~ $id ~ ':' ~ Main::newline() ~
            '  unless $P1 goto iter_done'  ~ $id ~ Main::newline() ~
            '  $P2 = shift $P1' ~ Main::newline() ~
            '  store_lex \'' ~ $.topic.full_name ~ '\', $P2' ~ Main::newline() ~
            (@.body.>>emit).join('') ~
            '  goto test_iter'  ~ $id ~ Main::newline() ~
            ' iter_done'  ~ $id ~ ':' ~ Main::newline() ~
            '  restore $P2' ~ Main::newline() ~
            '  restore $P1' ~ Main::newline() ~
            ''; 
    }
}

class Decl {
    has $.decl;
    has $.type;
    has $.var;
    method emit {
        my $decl := $.decl;
        my $name := $.var.name;
           ( $decl eq 'has' )
        ?? ( '  addattribute self, "' ~ $name ~ '"' ~ Main::newline() )
        !! #$.decl ~ ' ' ~ $.type ~ ' ' ~ $.var.emit;
           ( '  $P0 = new .Undef' ~ Main::newline ~
             '  .lex \'' ~ ($.var).full_name ~ '\', $P0' ~ Main::newline() 
           );
    }
}

class Sig {
    has $.invocant;
    has $.positional;
    has $.named;
    method emit {
        ' print \'Signature - TODO\'; die \'Signature - TODO\'; '
    };
    method invocant {
        $.invocant
    };
    method positional {
        $.positional
    }
}

class Method {
    has $.name;
    has $.sig;
    has @.block;
    method emit {
        my $sig := $.sig;
        my $invocant := $sig.invocant;
        my $pos := $sig.positional;
        my $str := '';
        my $i := 0;
        for @$pos -> $field {
            $str := $str ~ 
                '  $P0 = params[' ~ $i ~ ']' ~ Main::newline() ~
                '  .lex \'' ~ $field.full_name ~ '\', $P0' ~ Main::newline();
            $i := $i + 1;
        };
        return          
            '.sub "' ~ $.name ~ '" :method :outer("_class_vars_")' ~ Main::newline() ~
            '  .param pmc params  :slurpy'  ~ Main::newline() ~
            '  .lex \'' ~ $invocant.full_name ~ '\', self' ~ Main::newline() ~
            $str ~
            (@.block.>>emit).join('') ~ 
            '.end' ~ Main::newline ~ Main::newline();
    }
}

class Sub {
    has $.name;
    has $.sig;
    has @.block;
    method emit {
        my $sig := $.sig;
        my $invocant := $sig.invocant;
        my $pos := $sig.positional;
        my $str := '';
        my $i := 0;
        for @$pos -> $field {
            $str := $str ~ 
                '  $P0 = params[' ~ $i ~ ']' ~ Main::newline() ~
                '  .lex \'' ~ $field.full_name ~ '\', $P0' ~ Main::newline();
            $i := $i + 1;
        };
        return          
            '.sub "' ~ $.name ~ '" :outer("_class_vars_")' ~ Main::newline() ~
            '  .param pmc params  :slurpy'  ~ Main::newline() ~
            $str ~
            (@.block.>>emit).join('') ~ 
            '.end' ~ Main::newline ~ Main::newline();
    }
}

class Do {
    has @.block;
    method emit {
        # TODO - create a new lexical pad
        (@.block.>>emit).join('') 
    }
}

class Use {
    has $.mod;
    method emit {
        '  .include "' ~ $.mod ~ '"' ~ Main::newline()
    }
}

=begin

=head1 NAME

MiniPerl6::Perl5::Emit - Code generator for MiniPerl6-in-Perl5

=head1 SYNOPSIS

    $program.emit  # generated Perl5 code

=head1 DESCRIPTION

This module generates Perl5 code for the MiniPerl6 compiler.

=head1 AUTHORS

The Pugs Team E<lt>perl6-compiler@perl.orgE<gt>.

=head1 SEE ALSO

The Perl 6 homepage at L<http://dev.perl.org/perl6>.

The Pugs homepage at L<http://pugscode.org/>.

=head1 COPYRIGHT

Copyright 2006 by Flavio Soibelmann Glock, Audrey Tang and others.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=end
