{ package KindaPerl6::Visitor::ShortCircuit; 
# Do not edit this file - Perl 5 generated by HASH(0x1b09380)
# AUTHORS, COPYRIGHT: Please look at the source file.
use v5;
use strict;
no strict "vars";
use constant KP6_DISABLE_INSECURE_CODE => 0;
use KindaPerl6::Runtime::Perl5::Runtime;
my $_MODIFIED; INIT { $_MODIFIED = {} }
INIT { $_ = ::DISPATCH($::Scalar, "new", { modified => $_MODIFIED, name => "$_" } ); }
do {our $Code_thunk = ::DISPATCH( $::Routine, 'new', { modified => $_MODIFIED, name => '$Code_thunk' } ) ;
;
do { if (::DISPATCH(::DISPATCH(::DISPATCH(  ( $GLOBAL::Code_VAR_defined = $GLOBAL::Code_VAR_defined || ::DISPATCH( $::Routine, "new", )  ) 
, 'APPLY', $::KindaPerl6::Visitor::ShortCircuit )
,"true"),"p5landish") ) { do {our $Code_thunk = ::DISPATCH( $::Routine, 'new', { modified => $_MODIFIED, name => '$Code_thunk' } ) ;
;
} }  else { do {our $Code_thunk = ::DISPATCH( $::Routine, 'new', { modified => $_MODIFIED, name => '$Code_thunk' } ) ;
;
do {::MODIFIED($::KindaPerl6::Visitor::ShortCircuit);
$::KindaPerl6::Visitor::ShortCircuit = ::DISPATCH( ::DISPATCH( $::Class, 'new', ::DISPATCH( $::Str, 'new', 'KindaPerl6::Visitor::ShortCircuit' )
 )
, 'PROTOTYPE',  )
}} } }
; ::DISPATCH( ::DISPATCH( $::KindaPerl6::Visitor::ShortCircuit, 'HOW',  )
, 'add_method', ::DISPATCH( $::Str, 'new', 'visit' )
, ::DISPATCH( $::Code, 'new', { code => sub { 
# emit_declarations
my $pass_thunks; $pass_thunks = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$pass_thunks' } )  unless defined $pass_thunks; INIT { $pass_thunks = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$pass_thunks' } ) }
;
my  $List__ = ::DISPATCH( $::ArrayContainer, 'new', { modified => $_MODIFIED, name => '$List__' } ) ; 
;
my $node; $node = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node' } )  unless defined $node; INIT { $node = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node' } ) }
;
my $node_name; $node_name = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node_name' } )  unless defined $node_name; INIT { $node_name = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$node_name' } ) }
;

# get $self
$self = shift; 
# emit_arguments
my $CAPTURE; $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } )  unless defined $CAPTURE; INIT { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
my  $List__ = ::DISPATCH( $::ArrayContainer, 'new', { modified => $_MODIFIED, name => '$List__' } ) ; 
::DISPATCH_VAR($CAPTURE,"STORE",::CAPTURIZE(\@_));::DISPATCH_VAR( $List__, 'STORE', ::DISPATCH( $CAPTURE, 'array',  )
 )
;do {::MODIFIED($Hash__);
$Hash__ = ::DISPATCH( $CAPTURE, 'hash',  )
};{ my $_param_index = 0;  if ( ::DISPATCH( $GLOBAL::Code_exists,  'APPLY',  ::DISPATCH(  $Hash__, 'LOOKUP',  ::DISPATCH( $::Str, 'new', 'node' )  ) )->{_value}  )  { do {::MODIFIED($node);
$node = ::DISPATCH( $Hash__, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'node' )
 )
} }  elsif ( ::DISPATCH( $GLOBAL::Code_exists,  'APPLY',  ::DISPATCH(  $List__, 'INDEX',  ::DISPATCH( $::Int, 'new', $_param_index )  ) )->{_value}  )  { $node = ::DISPATCH(  $List__, 'INDEX',  ::DISPATCH( $::Int, 'new', $_param_index++ )  );  }  if ( ::DISPATCH( $GLOBAL::Code_exists,  'APPLY',  ::DISPATCH(  $Hash__, 'LOOKUP',  ::DISPATCH( $::Str, 'new', 'node_name' )  ) )->{_value}  )  { do {::MODIFIED($node_name);
$node_name = ::DISPATCH( $Hash__, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'node_name' )
 )
} }  elsif ( ::DISPATCH( $GLOBAL::Code_exists,  'APPLY',  ::DISPATCH(  $List__, 'INDEX',  ::DISPATCH( $::Int, 'new', $_param_index )  ) )->{_value}  )  { $node_name = ::DISPATCH(  $List__, 'INDEX',  ::DISPATCH( $::Int, 'new', $_param_index++ )  );  } } 
# emit_body
do {::MODIFIED($pass_thunks);
$pass_thunks = ::DISPATCH( $::Hash, 'new', [ ::DISPATCH( $::Str, 'new', 'infix:<&&>' )
, ::DISPATCH( $::Int, 'new', 1 )
 ],[ ::DISPATCH( $::Str, 'new', 'infix:<||>' )
, ::DISPATCH( $::Int, 'new', 1 )
 ],[ ::DISPATCH( $::Str, 'new', 'infix:<//>' )
, ::DISPATCH( $::Int, 'new', 1 )
 ],
 )
}; do { if (::DISPATCH(::DISPATCH(do { my $_tmp1 = ::DISPATCH(  ( $GLOBAL::Code_infix_58__60_eq_62_ = $GLOBAL::Code_infix_58__60_eq_62_ || ::DISPATCH( $::Routine, "new", )  ) 
, 'APPLY', $node_name, ::DISPATCH( $::Str, 'new', 'Apply' )
 )
; ::DISPATCH( $_tmp1, "true" )->{_value} ? ::DISPATCH( $pass_thunks, 'LOOKUP', ::DISPATCH( ::DISPATCH( $node, 'code',  )
, 'name',  )
 )
: ::DISPATCH( $::Bit, "new", 0 ) }
,"true"),"p5landish") ) { do {my $left; $left = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$left' } )  unless defined $left; INIT { $left = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$left' } ) }
;
my $right; $right = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$right' } )  unless defined $right; INIT { $right = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$right' } ) }
;
do {::MODIFIED($left);
$left = ::DISPATCH( ::DISPATCH( ::DISPATCH( $node, 'arguments',  )
, 'INDEX', ::DISPATCH( $::Int, 'new', 0 )
 )
, 'emit', $self )
}; do {::MODIFIED($right);
$right = ::DISPATCH( ::DISPATCH( ::DISPATCH( $node, 'arguments',  )
, 'INDEX', ::DISPATCH( $::Int, 'new', 1 )
 )
, 'emit', $self )
}; return(::DISPATCH( $::Apply, 'new', ::DISPATCH( $::NamedArgument, 'new', { _argument_name_ => ::DISPATCH( $::Str, 'new', 'code' )
, value => ::DISPATCH( $node, 'code',  )
 } )
, ::DISPATCH( $::NamedArgument, 'new', { _argument_name_ => ::DISPATCH( $::Str, 'new', 'arguments' )
, value => ::DISPATCH( $::Array, 'new', { _array => [::DISPATCH( $Code_thunk, 'APPLY', $left )
, ::DISPATCH( $Code_thunk, 'APPLY', $right )
] }
 )
 } )
 )
)
} }  else { ::DISPATCH($::Bit, "new", 0) } }
; do { if (::DISPATCH(::DISPATCH(::DISPATCH(  ( $GLOBAL::Code_infix_58__60_eq_62_ = $GLOBAL::Code_infix_58__60_eq_62_ || ::DISPATCH( $::Routine, "new", )  ) 
, 'APPLY', $node_name, ::DISPATCH( $::Str, 'new', 'Lit::Code' )
 )
,"true"),"p5landish") ) { do {do {::MODIFIED( ( $KindaPerl6::Visitor::ShortCircuit::last_pad = $KindaPerl6::Visitor::ShortCircuit::last_pad || ::DISPATCH( $::Scalar, "new", )  ) 
);
 ( $KindaPerl6::Visitor::ShortCircuit::last_pad = $KindaPerl6::Visitor::ShortCircuit::last_pad || ::DISPATCH( $::Scalar, "new", )  ) 
 = ::DISPATCH( $node, 'pad',  )
}} }  else { ::DISPATCH($::Bit, "new", 0) } }
; return($::Undef)
 }, signature => ::DISPATCH( $::Signature, "new", { invocant => $::Undef, array    => ::DISPATCH( $::List, "new", { _array => [ ::DISPATCH( $::Signature::Item, 'new', { sigil  => '$', twigil => '', name   => 'node', value  => $::Undef, has_default    => ::DISPATCH( $::Bit, 'new', 0 )
, is_named_only  => ::DISPATCH( $::Bit, 'new', 0 )
, is_optional    => ::DISPATCH( $::Bit, 'new', 0 )
, is_slurpy      => ::DISPATCH( $::Bit, 'new', 0 )
, is_multidimensional  => ::DISPATCH( $::Bit, 'new', 0 )
, is_rw          => ::DISPATCH( $::Bit, 'new', 0 )
, is_copy        => ::DISPATCH( $::Bit, 'new', 0 )
,  } )
, ::DISPATCH( $::Signature::Item, 'new', { sigil  => '$', twigil => '', name   => 'node_name', value  => $::Undef, has_default    => ::DISPATCH( $::Bit, 'new', 0 )
, is_named_only  => ::DISPATCH( $::Bit, 'new', 0 )
, is_optional    => ::DISPATCH( $::Bit, 'new', 0 )
, is_slurpy      => ::DISPATCH( $::Bit, 'new', 0 )
, is_multidimensional  => ::DISPATCH( $::Bit, 'new', 0 )
, is_rw          => ::DISPATCH( $::Bit, 'new', 0 )
, is_copy        => ::DISPATCH( $::Bit, 'new', 0 )
,  } )
,  ] } ), return   => $::Undef, } )
,  } )
 )
; do {::MODIFIED($Code_thunk);
$Code_thunk = ::DISPATCH( $::Code, 'new', { code => sub { my  $List__ = ::DISPATCH( $::ArrayContainer, 'new', { modified => $_MODIFIED, name => '$List__' } ) ; 
;
my $value; $value = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$value' } )  unless defined $value; INIT { $value = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$value' } ) }
;
my $pad; $pad = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$pad' } )  unless defined $pad; INIT { $pad = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$pad' } ) }
;
my $CAPTURE; $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } )  unless defined $CAPTURE; INIT { $CAPTURE = ::DISPATCH( $::Scalar, 'new', { modified => $_MODIFIED, name => '$CAPTURE' } ) }
my  $List__ = ::DISPATCH( $::ArrayContainer, 'new', { modified => $_MODIFIED, name => '$List__' } ) ; 
::DISPATCH_VAR($CAPTURE,"STORE",::CAPTURIZE(\@_));::DISPATCH_VAR( $List__, 'STORE', ::DISPATCH( $CAPTURE, 'array',  )
 )
;do {::MODIFIED($Hash__);
$Hash__ = ::DISPATCH( $CAPTURE, 'hash',  )
};{ my $_param_index = 0;  if ( ::DISPATCH( $GLOBAL::Code_exists,  'APPLY',  ::DISPATCH(  $Hash__, 'LOOKUP',  ::DISPATCH( $::Str, 'new', 'value' )  ) )->{_value}  )  { do {::MODIFIED($value);
$value = ::DISPATCH( $Hash__, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'value' )
 )
} }  elsif ( ::DISPATCH( $GLOBAL::Code_exists,  'APPLY',  ::DISPATCH(  $List__, 'INDEX',  ::DISPATCH( $::Int, 'new', $_param_index )  ) )->{_value}  )  { $value = ::DISPATCH(  $List__, 'INDEX',  ::DISPATCH( $::Int, 'new', $_param_index++ )  );  }  if ( ::DISPATCH( $GLOBAL::Code_exists,  'APPLY',  ::DISPATCH(  $Hash__, 'LOOKUP',  ::DISPATCH( $::Str, 'new', 'pad' )  ) )->{_value}  )  { do {::MODIFIED($pad);
$pad = ::DISPATCH( $Hash__, 'LOOKUP', ::DISPATCH( $::Str, 'new', 'pad' )
 )
} }  elsif ( ::DISPATCH( $GLOBAL::Code_exists,  'APPLY',  ::DISPATCH(  $List__, 'INDEX',  ::DISPATCH( $::Int, 'new', $_param_index )  ) )->{_value}  )  { $pad = ::DISPATCH(  $List__, 'INDEX',  ::DISPATCH( $::Int, 'new', $_param_index++ )  );  } } ::DISPATCH( $::Sub, 'new', ::DISPATCH( $::NamedArgument, 'new', { _argument_name_ => ::DISPATCH( $::Str, 'new', 'block' )
, value => ::DISPATCH( $::Lit::Code, 'new', ::DISPATCH( $::NamedArgument, 'new', { _argument_name_ => ::DISPATCH( $::Str, 'new', 'pad' )
, value => ::DISPATCH(  ( $COMPILER::Code_inner_pad = $COMPILER::Code_inner_pad || ::DISPATCH( $::Routine, "new", )  ) 
, 'APPLY',  ( $KindaPerl6::Visitor::ShortCircuit::last_pad = $KindaPerl6::Visitor::ShortCircuit::last_pad || ::DISPATCH( $::Scalar, "new", )  ) 
 )
 } )
, ::DISPATCH( $::NamedArgument, 'new', { _argument_name_ => ::DISPATCH( $::Str, 'new', 'body' )
, value => ::DISPATCH( $::Array, 'new', { _array => [$value] }
 )
 } )
, ::DISPATCH( $::NamedArgument, 'new', { _argument_name_ => ::DISPATCH( $::Str, 'new', 'sig' )
, value => ::DISPATCH( $::Sig, 'new', ::DISPATCH( $::NamedArgument, 'new', { _argument_name_ => ::DISPATCH( $::Str, 'new', 'invocant' )
, value => $::Undef } )
, ::DISPATCH( $::NamedArgument, 'new', { _argument_name_ => ::DISPATCH( $::Str, 'new', 'positional' )
, value => ::DISPATCH( $::Array, 'new', { _array => [] }
 )
 } )
 )
 } )
 )
 } )
 )
 }, signature => ::DISPATCH( $::Signature, "new", { invocant => $::Undef, array    => ::DISPATCH( $::List, "new", { _array => [ ::DISPATCH( $::Signature::Item, 'new', { sigil  => '$', twigil => '', name   => 'value', value  => $::Undef, has_default    => ::DISPATCH( $::Bit, 'new', 0 )
, is_named_only  => ::DISPATCH( $::Bit, 'new', 0 )
, is_optional    => ::DISPATCH( $::Bit, 'new', 0 )
, is_slurpy      => ::DISPATCH( $::Bit, 'new', 0 )
, is_multidimensional  => ::DISPATCH( $::Bit, 'new', 0 )
, is_rw          => ::DISPATCH( $::Bit, 'new', 0 )
, is_copy        => ::DISPATCH( $::Bit, 'new', 0 )
,  } )
, ::DISPATCH( $::Signature::Item, 'new', { sigil  => '$', twigil => '', name   => 'pad', value  => $::Undef, has_default    => ::DISPATCH( $::Bit, 'new', 0 )
, is_named_only  => ::DISPATCH( $::Bit, 'new', 0 )
, is_optional    => ::DISPATCH( $::Bit, 'new', 0 )
, is_slurpy      => ::DISPATCH( $::Bit, 'new', 0 )
, is_multidimensional  => ::DISPATCH( $::Bit, 'new', 0 )
, is_rw          => ::DISPATCH( $::Bit, 'new', 0 )
, is_copy        => ::DISPATCH( $::Bit, 'new', 0 )
,  } )
,  ] } ), return   => $::Undef, } )
,  } )
}}
; 1 }
