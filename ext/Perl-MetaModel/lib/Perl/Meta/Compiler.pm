
use v6;

class Perl::Meta::Compiler;

method compileAll ($self: Perl::Meta::Class $class) returns Void {
    $self.:compileClass($class);
    for $class.allSubclasses() -> $subclass {
        $self.:compileClass($subclass);
    }
}

method compile ($self: Perl::Meta::Class $class) returns Void {
    $self.:compileClass($class);
}

method :analyzeClass ($self: Perl::Meta::Class $class) returns Void {
    # flatten the roles into the class
    $self.:flattenRoles($class) if $class.hasRoles();
    return $class;
}

method :flattenRoles ($self: Perl::Meta::Class $class) returns Void {
    my @roles = $class.roles();
    for @roles -> $role {
        # make sure all super-roles are compiled
    }
}

my $DEBUG = 1;

method :compileClass ($self: Perl::Meta::Class $class) returns Void {
    my $meta = $self.:analyzeClass($class);
    my $class_code = 'class ' ~ $meta.name();
    $class_code ~= ' is ' ~ $meta.superclass().name() if $meta.superclass().defined;
    my $properties = '';
    for $meta.properties().kv() -> $label, $prop {
        $properties ~= '    has ' 
                              ~ $prop.type().name()  ~ ' ' 
                              ~ $prop.type().sigil() ~ '.' 
                              ~ $label
                              ~ ($prop.trait() ?? ' is ' ~ $prop.trait() :: '') ~ 
                              ";\n"; 
    } 
    my $methods = '
    method meta returns Perl::Meta::Class { $meta }

    method isa ($self: Str $class) returns Bool {  
        $self.meta().isATypeOf($class);
    }
    
    method can ($self: Str $method_label) returns Bool {
        $self.meta().isMethodSupported($method_label);
    }
    ';
    for $meta.methodLabels() -> $label {
        $methods ~= '
    method ' ~ $label ~ ' ($self: *@args) returns Any {
        return $self.meta().invokeMethod("' ~ $label ~ '", $self, @args);
    }
    ';
    }
    $class_code ~= " \{\n\n" ~ $properties ~ $methods ~ "\n}"; 
    say "evaling class (\n$class_code\n)\n" if $DEBUG;
    eval $class_code;
}

=pod

=head1 NAME

Perl::Meta::Compiler

=head1 SYNOPSIS

  use Perl::Meta::Compiler;
  
  my $c = Perl::Meta::Compiler.new();
  $c.compileAll($class_hierarchy);

=head1 DESCRIPTION

This currently only handles compiling class properties and some 
built in methods. I need to work out how to alias methods to 
code structures.

=head1 METHODS

=over 4

=item B<compileAll ($self: Perl::Meta::Class $class) returns Void>

=item B<compile ($self: Perl::Meta::Class $class) returns Void>

=back

=head1 AUTHORS

Stevan Little E<lt>stevan@iinteractive.comE<gt>

=cut
