
class EmitSBCL {

  method new_emitter($ignore,$compiler,$ignore2,$filename) {
    self.new('compiler',$compiler,'filename',$filename);
  };

  has $.compiler;
  has $.filename;

  method tidy($source) {
    if $source.re_matchp('^CompUnit\(') { private_tidy($source) }
    else { $source }
  }

  method prelude_lexical () {
    "";
  };

  method prelude_oo () {
   '';
  };
  method prelude ($n) {
  '#|
#fasl=`dirname $0`/`basename $0 .lisp`.fasl
#[ $fasl -ot $0 ] && sbcl --noinform --eval "(compile-file \"$0\")" --eval "(quit)"
#exec sbcl --noinform --load $fasl --end-toplevel-options "$@"
exec sbcl --noinform --load $0 --eval "(quit)" --end-toplevel-options "$@"
|#

;;------------------------------------------------------------------------------
;; Multi-methods - avoid generic-function congruence restrictions.
;; http://www.lispworks.com/documentation/HyperSpec/Body/07_fd.htm

(defvar *maximum-number-of-dispatch-affecting-variables* 10)

(defun n-variable-names (n &optional l)
  (cond ((= 0 n) l)
        (t (n-variable-names (1- n) (cons (gensym) l)))))

(defmacro fc (func &rest args)
  `(ap ,func (list ,@args)))

(defgeneric ap (func args))
(defmethod ap (func args)
  (apply func args))
(defmethod ap ((func standard-generic-function) args)
  (let* ((n (1+ *maximum-number-of-dispatch-affecting-variables*))
         (len (length args))
         (pad-args (make-list (max 0 (- n len))))
         (real-args (subseq args 0 (min n len)))
         (dispatch-args (concatenate \'list real-args pad-args)))
    (apply func (cons args dispatch-args))))
         
(defmacro dg (name sig)
  (declare (ignore sig))
  (let* ((n (1+ *maximum-number-of-dispatch-affecting-variables*))
         (vars (n-variable-names n)))
    `(defgeneric ,name (args ,@vars))))

(defun parameters-in-lambda-list (sig)
  (let ((pred (lambda(e) (case e
                               (&optional t)
                               (&rest t)
                               ))))
    (remove-if pred sig))) ;X should stop at &aux, etc.

(defmacro dm (name sig &rest body)
  (let* ((n (1+ *maximum-number-of-dispatch-affecting-variables*))
         (n-1 (1- n))
         (vars (parameters-in-lambda-list sig))
         (len (length vars))
         (real-vars (subseq vars 0 (min n-1 len)))
         (bounds-var (list (if (find \'&rest sig)
                               (gensym)
                             `(,(gensym) ,(class-of nil)))))
         (pad-vars (n-variable-names (max 0 (- n-1 len))))
         (dispatch-vars (concatenate \'list real-vars bounds-var pad-vars))
         (typeless-sig (map \'list (lambda (p) (if (listp p) (car p) p)) sig))
         )
    `(defmethod ,name (args ,@dispatch-vars)
       (declare (ignore ,@pad-vars))
       (destructuring-bind ,typeless-sig args
         ,@body))))

;;------------------------------------------------------------------------------

(defmacro pkg-init-flag-name (pkg) `(concatenate \'string ,pkg "/initialized"))
(defmacro pkg-clsname (pkg) `(find-symbol (concatenate \'string ,pkg "/cls")))
(defmacro pkg-co (pkg) `(find-symbol (concatenate \'string ,pkg "::/co")))
(defmacro pkg-super (pkg) `(find-symbol (concatenate \'string ,pkg "::/super")))
(defmacro pkg-slots (pkg) `(find-symbol (concatenate \'string ,pkg "::/slots")))
  
(defun cls-sync-definition (pkg)
  (let ((def 
   `(defclass
     ,(pkg-clsname pkg)
     ,(symbol-value (pkg-super pkg))
     ,(symbol-value (pkg-slots pkg)))))
  (eval def)))

(defun pkg-declare (kind pkg base)
  (unless (find-symbol (pkg-init-flag-name pkg))
    (set (intern (pkg-init-flag-name pkg)) t)
    (when (equal kind "class")
      (intern (concatenate \'string pkg "/cls"))
      (set (intern (concatenate \'string pkg "::/super")) (if base (list base) nil))
      (set (intern (concatenate \'string pkg "::/slots")) nil)
      (cls-sync-definition pkg)
      (set (intern (concatenate \'string pkg "::/co"))
        (make-instance (pkg-clsname pkg)))
      )))

(defun cls-has (pkg new-slot-specifier)
  (let ((slots-symbol (pkg-slots pkg)))
    (set slots-symbol (nconc (symbol-value slots-symbol) (list new-slot-specifier)))
    (cls-sync-definition pkg)))

(defun cls-is (pkg new-super-pkg)
  (let ((pkg-super-symbol (pkg-super pkg))
        (new-super-name (pkg-clsname new-super-pkg)))
    (assert pkg-super-symbol)
    (assert new-super-name)
    (if (not (equal new-super-pkg "Any"))
      (set pkg-super-symbol (cons new-super-name (symbol-value pkg-super-symbol)))
      (cls-sync-definition pkg))))

;;------------------------------------------------------------------------------

(make-package "M")

(defclass |Any/cls| () ())

(dg |M::new| (cls &rest argl))

(dm |M::new| ((cls |Any/cls|) &rest argl)
  (declare (ignorable argl))
  (make-instance cls))

 ;;Array.new is defined here to a avoid cyclic dependency on *@args.
(pkg-declare "class" "Array" \'|Any/cls|)
(eval \'(dm |M::new| ((cls |Array/cls|) &rest argl)
  (declare (ignorable cls))
  (let ((inst (make-instance \'|Array/cls|)))
    (setf (slot-value inst \'|Array::._native_|)
          (make-array (length argl) :adjustable t :initial-contents argl))
    inst))
)

;; Hack until Str, Int, Num, etc are p6 objects.
(eval \'(dm |M::Str| ((s string) &rest argl) (declare (ignorable argl)) s))
(eval \'(dm |M::Str| ((n number) &rest argl) (declare (ignorable argl)) (write-to-string n)))

;; Muffle warnings at compile and runtimes.

;(declaim (sb-ext:muffle-conditions style-warning))
(declaim (sb-ext:muffle-conditions warning))

;(defparameter sb-ext:*muffled-warnings* style-warning) ;In sbcl-1.0.20 .
(if (find-symbol "sb-ext:*muffled-warnings*") ;In sbcl-1.0.20
;  (eval(read-from-string "(defparameter sb-ext:*muffled-warnings* style-warning)"))
 nil) 

;;------------------------------------------------------------------------------
';
  };

  method e($x) {
    my $ref = $x.WHAT;
    if $ref eq 'Undef' { $x }
    elsif $ref eq 'Str' || $ref eq 'Int' || $ref eq 'Num' { $x }
    elsif $ref eq 'Array' { $x.map(sub($ae){$.e($ae)}) }
    else {$x.callback(self)}
  };


  method cb__CompUnit ($n) {
    $n.do_all_analysis();
    temp $whiteboard::in_package = [];
    temp $whiteboard::emit_pairs_inline = 0;
    temp $whiteboard::compunit_footer = [];
    my $decls = $n.notes<lexical_variable_decls>;
    my $code = "(let (\n";
    $decls.map(sub($d){if $d.scope eq 'my' {
      #$code = $code ~ $.e($d.var)~" "; #X SubDecl :/
      # ~$d.twigil~ not included because STD_red is using 0 as false,
      #   and the 0 is mutating into a '0'.  Switch to undef?
      $code = $code ~ $.qsym($d.sigil~$d.name)~" ";
    }});
    $code = $code ~")\n";
    my $stmts = $.e($n.statements);
    my $foot = $whiteboard::compunit_footer.join("\n");
    $code ~ $stmts.join("\n")~$foot~"\n)\n";
  };
  method cb__Block ($n) {
    temp $whiteboard::emit_pairs_inline = 0;
    #'# '~$.e($n.notes<lexical_variable_decls>).join(" ")~"\n"~
    "(progn\n"~$.e($n.statements).join("\n")~')'
  };

  method cb__Use ($n) {
    my $module = $.e($n.module_name);
    my $expr = $.e($n.expr);
    if $module eq 'v6-alpha' { "" }
    elsif $module eq 'v6' { "" }
    elsif $module eq 'lib' {
      my $name = $n.expr.buf;
      if $.compiler.hook_for_use_lib($name) { "" }
      else { "" }
    }
    elsif $.compiler.hook_for_use($module,$expr) { "" }
    else {
      "use " ~$module;
    }
  };
  method cb__ClosureTrait ($n) {
    temp $whiteboard::emit_pairs_inline = 0;
    $n.kind~'{'~$.e($n.block)~'}'
  };

  method cb__PackageDecl ($n) {
    my $in_package = [$whiteboard::in_package.flatten,$n.name];
    my $kind = $n.kind;
    my $name = $in_package.join('::');
    my $base = "'"~$.classname_from_package_name("Any");
    if $name eq 'Any' { $base = 'nil' }
    if $name eq 'Object' { $base = 'nil' }
    if $name eq 'Junction' { $base = 'nil' }
    my $head = "\n(pkg-declare \""~$kind~"\" \""~$name~"\" "~$base~")\n";
    my $foot = "\n";
    if $n.block {
      temp $whiteboard::in_package = $in_package; # my()
      $head ~ $.e($n.traits||[]).join("\n") ~ $.e($n.block) ~ $foot;
    } else {
      $whiteboard::in_package = $in_package; # not my()
      $whiteboard::compunit_footer.unshift($foot);
      $head ~ $.e($n.traits||[]).join("\n") ~ "\n"
    }
  };
  method cb__Trait ($n) {
    if ($n.verb eq 'is' or $n.verb eq 'does') {
      my $pkgname = $whiteboard::in_package.join('::');
      my $super = $whiteboard::in_package.splice(0,-1).join('::');
      if $super { $super = $super ~'::' }
      $super = $super ~ $.e($n.expr);
      "\n(cls-is "~$.qstr($pkgname)~" "~$.qstr($super)~")\n"
    } else {
      say "ERROR: Emitting p5 for Trait verb "~$n.verb~" has not been implemented.\n";
      "***Trait***"
    }
  };

  method do_VarDecl_has ($n,$default) {
    my $name = $.e($n.var.name);
    my $pkg = $whiteboard::in_package.join('::')||'Main';
    my $cls = $.classname_from_package_name($pkg);
    my $slotname = '|'~$pkg~'::.'~$name~'|';
    my $accname = '|M::'~$name~'|';
    my $code = ('(eval \'(dm '~$accname~' ((self '~$cls~'))'~
                ' (cl:slot-value self \''~$slotname~')))'~"\n"~
                '(eval \'(dm (cl:setf '~$accname~') (v (self '~$cls~'))'~
                ' (cl:setf (cl:slot-value self \''~$slotname~') v)))'~"\n");
    my $slot_specifier = '('~$slotname;
    if $default {
      $slot_specifier = $slot_specifier ~ " :initform "~$default;
    }
    $slot_specifier = $slot_specifier ~')';
    $code = $code ~ "(cls-has \""~$pkg~"\" '"~$slot_specifier~")\n\n";
    $code;
  };

  method emit_array ($contents) {
    "(fc #'|M::new| |Array::/co| "~$contents~')'
  }

  method cb__VarDecl ($n) {
    temp $whiteboard::emit_pairs_inline = 0;
    my $pre_a = "(fc #'|M::new| |Array::/co| ";
    my $pre_h = "(fc #'|M::new| |Hash::/co| ";
    if ($n.scope eq 'has') {
      my $default = "";
      my $default_expr = $.e($n.default_expr);
      if $default_expr {
        $default = $default_expr;
      } else {
        if ($n.var.sigil eq '$') { $default = 'nil' }#X
        if ($n.var.sigil eq '@') { $default = $pre_a~')' }
        if ($n.var.sigil eq '%') { $default = $pre_h~')' }
      }
      self.do_VarDecl_has($n,$default);
    } else {
      my $default = "";
      if $n.default_expr {
        if (not($n.var.sigil eq '$') &&
            $n.default_expr.isa('IRx1::Apply') &&
            ($n.default_expr.function eq 'circumfix:( )' ||
             $n.default_expr.function eq 'infix:,'))
        {
          my $pre = ''; my $post = '';
          if $n.is_array { $pre = $pre_a; $post = ')' }
          if $n.is_hash  { $pre = $pre_h; $post = ')' }
          temp $whiteboard::emit_pairs_inline = 1;
          $default = ''~$pre~$.e($n.default_expr)~$post;
        } else {
          $default = ''~$.e($n.default_expr);
        }
      } else {
        if ($n.var.sigil eq '@') { $default = ''~$pre_a~')' }
        if ($n.var.sigil eq '%') { $default = ''~$pre_h~')' }
      }
      if ($n.is_context) { # BOGUS
        my $name = $.e($n.var);
        $name.re_sub_g('^(.)::','$1');
        ("{package main; use vars '"~$name~"'};"~
         'local'~' '~$.e($n.var)~$default)
      }
      elsif ($n.is_temp) {
        my $var = $n.var;
        my $nam = $.encode_varname($var.sigil,$var.twigil,$var.bare_name);
        my $pkg = $n.var.package;
        ("\{ package "~$pkg~"; use vars '"~$nam~"'};"~
        'local'~' '~$.e($n.var)~$default)
      }
      elsif $default {
        '(setq '~$.e($n.var)~' '~$default~')'
      }
      else {
        $.e($n.var)
      }
    }
  };


  method multimethods_using_hack ($n,$name,$param_types) {
    my $name = $.e($n.name);
    my $param_types = $n.multisig.parameters.map(sub($p){
      my $types = $.e($p.type_constraints);
        if $types {
          if $types.elems != 1 { die("unsupported: parameter with !=1 type constraint.") }
          $types[0];
        } else {
          undef;
        }
    });
    my $type0 = $param_types[0];
    if not($type0) {
      die("implementation limitation: a multi method's first parameter must have a type: "~$name~"\n");
    }
    my $stem = '_mmd__'~$name~'__';
    my $branch_name = $stem~$type0;
    my $setup_name = '_reset'~$stem;
    my $code = "";
    $code = $code ~
    '
{ my $setup = sub {
    my @meths = __PACKAGE__->meta->compute_all_applicable_methods;
    my $h = {};
    for my $m (@meths) {
      next if not $m->{name} =~ /^'~$stem~'(\w+)/;
      my $type = $1;
      $h->{$type} = $m->{code}{q{&!body}};
    };
    my $s = eval q{sub {
      my $ref = ref($_[1]) || $_[1]->WHAT;
      my $f = $h->{$ref}; goto $f if $f;
      Carp::croak "multi method '~$name~' cant dispatch on type: ".$ref."\n";
    }};
    die $@ if $@;
    eval q{{no warnings; *'~$name~' = $s;}};
    die $@ if $@;
    goto &'~$name~';
  };
  eval q{{no warnings; *'~$setup_name~' = $setup;}};
  die $@ if $@;
  eval q{{no warnings; *'~$name~' = $setup;}};
  die $@ if $@;
};
';
    'sub '~$branch_name~'{my $self=CORE::shift;'~$.e($n.multisig)~$.e($n.block)~'}' ~ $code;
  };
  method multi_using_CM ($n,$is_method,$f_emitted) {
    my $name = $.e($n.name);
    my $enc_name = $.mangle_function_name($name);
    my $param_types = $n.multisig.parameters.map(sub($p){
      my $types = $.e($p.type_constraints);
      if $types {
        if $types.elems != 1 { die("unsupported: parameter with !=1 type constraint.") }
        $types[0];
      } else {
        'Any'
      }
    });
    if $is_method {
      $param_types.unshift('Any');
    }
    my $sig = $param_types.map(sub($t){
      # XXX C::M needs to be modified to work on both INTEGER and Int. :(
      if $t eq 'Any' { '*' }
      elsif $t eq 'Int' { '#' }
      elsif $t eq 'Num' { '#' }
      elsif $t eq 'Str' { '$' }
      else { $t }
    }).join(' ');
    'Class::Multimethods::multimethod '~$enc_name~
    ' => split(/\s+/'~",'"~$sig~"') => "~ $f_emitted ~';';
  };
  method cb__MethodDecl ($n) {
    my $body;
    if $n.traits && $n.traits[0].expr && $n.traits[0].expr eq 'cl' {
      $body = $n.block.statements[0].buf;
    }
    else {
      $body = $.e($n.block);
    }
    my $cls = $.classname_from_package_name($n.notes<crnt_package>||'Main');
    my $enc_name = $.qsym('M::'~$.e($n.name));
    my $sig = $.e($n.multisig);
    '(eval \'(dm '~$enc_name~' ((self '~$cls~') '~$sig~' (block __f__ '~$body~')))';
  };
  method classname_from_package_name($pkg) {
    '|'~$pkg~'/cls|';
  }
  method classobject_from_package_name($pkg) {
    '|'~$pkg~'::/co|';
  }


  method cb__SubDecl ($n) {
    temp $whiteboard::emit_pairs_inline = 0;
    my $name = $n.name;
    if $name { $name = $.e($name) } else { $name = "" }
    my $sig = $n.multisig;
    if $sig { $sig = $.e($sig) } else { $sig = "" }
    my $body;
    if $n.traits && $n.traits[0].expr && $n.traits[0].expr eq 'cl' {
      $body = $n.block.statements[0].buf;
    } else {
      $body = $.e($n.block);
    }
    if $n.plurality && $n.plurality eq 'multi' {
      my $ef = 'sub {'~$sig~$body~'}';
      self.multi_using_CM($n,0,$ef);
    } else {
      my $most = '('~$sig~' (block __f__ '~$body~')';
      if $n.scope eq 'our' {
        my $pkg = $n.notes<crnt_package>;
        my $enc_name = $.qsym($pkg~'::&'~$name);
        '(defparameter '~$enc_name~' (lambda '~$most~'))';
      }
      elsif $name {
        my $enc_name = $.qsym('&'~$name);
        '(setq '~$enc_name~' (lambda '~$most~'))';
      }
      else {
        '(lambda '~$most~')';
      }
    }
  };
  method cb__Signature ($n) {
    if ($n.parameters.elems == 0) { ")" }
    else {
      temp $whiteboard::signature_inits = "";
      my $pl = $.e($n.parameters).join(" ");
      ''~$pl~")"~$whiteboard::signature_inits~"\n";
    }
  };
  method cb__Parameter ($n) {
    my $enc = $.e($n.param_var);
    my $par = $enc;
    if $n.type_constraints {
      my $typ = $.classname_from_package_name($n.type_constraints[0]);
      $par = '('~$par~' '~$typ~')';
    }
    if $n.quant && $n.quant eq '*' {
      my $init = "\n (setq "~$enc~" (ap #'|M::new| (cons |Array::/co| "~$enc~")))";
      $whiteboard::signature_inits = $whiteboard::signature_inits~$init;
      " &rest "~$enc;
    } else {
      $par;
    }
  };
  method cb__ParamVar ($n) {
    my $s = $n.sigil;
    my $t = '';
    my $dsn = $.e($n.name);
    $.encode_varname($s,$t,$dsn);
  };

  method cb__Call ($n) {
    my $g;
    temp $whiteboard::emit_pairs_inline = 0;
    my $method = $.e($n.method);
    my $invocant = $.e($n.invocant);
    if ($method eq 'postcircumfix:< >') {
      $invocant~'->'~"{'"~$.e($n.capture)~"'}";
    }
    elsif $g = $method.re_groups('postcircumfix:(.*)') {
      my $op = $g[0];
      my $arg = $.e($n.capture);
      $op.re_gsub(' ',$arg);
      $invocant~'->'~$op;
    } else {
      if $invocant.re_matchp('^[A-Z]\w*$') {
        $invocant = ""~$.classobject_from_package_name($invocant);
      }
      my $meth = $.fqsym('M::'~$.e($n.method));
      '(fc '~$meth~' '~$invocant~' '~$.e($n.capture)~')'
    }
  };
  method fqsym ($name) {
     "#'|"~$name.re_gsub('\|','\\|')~'|';
  }
  method qsym ($name) {
     "|"~$name.re_gsub('\|','\\|')~'|';
  }
  method qstr ($str) {
     '"'~$str.re_gsub('\\\\','\\\\\\\\').re_gsub('"','\"')~'"'
  }

  method cb__Apply ($n) {
    my $g;
    # temp $whiteboard::emit_pairs_inline = 0; #XXX depends on function :/
    my $fun = $.e($n.function);
    if $n.notes<lexical_bindings>{'&'~$fun} {
       my $fe = $.qsym('&'~$fun);
       my $decl = $n.notes<lexical_bindings>{'&'~$fun};
       if $decl.scope eq 'our' {
         $fe = $.qsym($decl.notes<crnt_package>~'::&'~$fun);
       }
       return '(fc '~$fe~' '~$.e($n.capture)~')'
    }
    if $g = $fun.re_groups('^infix:(.+)$') {
      my $op = $g[0];
      my $args = $n.capture.arguments;
      if $args.elems == 1 && $args[0].isa('IRx1::Apply') && $args[0].function eq 'infix:,' {
        $args = $args[0].capture.arguments;
      }
      my $a = $.e($args);
      my $l = $a[0];
      my $r = $a[1];
      if ($op eq ',') {
        my $s = $a.shift;
        while $a.elems { $s = $s ~" "~ $a.shift }
        return $s;
      }
      if ($op eq '=') {
        # assignment to field.
        if $args[0].isa("IRx1::Var") {
          my $t = $args[0].twigil;
          if ($t && $t eq '.') {
            return $l~'('~$r~')'
          }
        }
        if ($args[0].isa("IRx1::Call") &&
            $args[0].capture.arguments.elems == 0)
        {
          return $.e($args[0].invocant)~'->'~$.e($args[0].method)~'('~$r~')'
        }
      }
    }
    elsif $g = $fun.re_groups('^prefix:(.+)$') {
      #my $op = $g[0];
      #my $a = $.e($n.capture.arguments);
      #my $x = $a[0];
      #if $op eq '?' {return '(('~$x~')?1:0)'}
    }
    elsif $g = $fun.re_groups('^statement_prefix:(.+)$') {
      my $op = $g[0];
      if $op eq 'do' {
        return '(progn '~$.e($n.capture.arguments[0])~')'
      #} elsif $op eq 'try' {
      #  return 'eval{'~$.e($n.capture)~'}'
      #} elsif $op eq 'gather' {
      #  return 'gather'~$.e($n.capture)~''
      } else {
        die $fun~': unimplemented';
      }
    }
    elsif $g = $fun.re_groups('^postfix:(.+)$') {
      my $op = $g[0];
      my $a = $.e($n.capture.arguments);
      my $x = $a[0];
      if $op.re_matchp('^(\+\+)$') {
        return "(setq "~$x~" (+ 1 "~$x~"))"
      }
    }
    elsif $g = $fun.re_groups('^circumfix:(.+)') {
      my $op = $g[0];
      if $op eq '< >' {
        my $s = $n.capture.arguments[0];
        my $words = $s.split(/\s+/);
        if $words.elems == 0 {
          return $.emit_array('');
        } else {
          return $.emit_array('"'~$words.join('" "')~'"');
        }
      }
    }
    elsif ($fun eq 'self') {
      return 'self'
    }
    elsif ($fun eq 'next') {
      return '(return-from __l__)'
    }
    elsif ($fun eq 'last') {
      return '(return)'
    }
    elsif ($fun eq 'return') {
      return '(return-from __f__'~$.e($n.capture)~')';
    }
    elsif $fun eq 'eval' {
      my $env = ''; #XXX harder in CL
      return '(fc |GLOBAL::&eval| '~$.e($n.capture)~' '~$env~')'
    }

    if $fun.re_matchp('^\w') {
      my $fe = $.qsym('GLOBAL::&'~$fun);
      return '(fc '~$fe~' '~$.e($n.capture)~')'
    }
    else {
       return  '(fc '~$fun~' '~$.e($n.capture)~')';
    }
  };
  method cb__Capture ($n) {
    # temp $whiteboard::emit_pairs_inline = 0; XXX?
    my $a = $.e($n.arguments||[]).join(" ");
    if $n.invocant {
      my $inv = $.e($n.invocant);
      if $a { $inv~" "~$a }
      else { $inv }
    }
    else { $a }
  };

  method cb__For ($n) {
    my $e = $.e($n.expr);
    if $n.expr.WHAT ne 'IRx1::Apply' { $e = '(fc #\'|M::values| '~$e~')' };
    my $b = $.e($n.block);
    if $n.block.WHAT eq 'IRx1::SubDecl' { $b = '('~$b~' _)' };
    '(loop for |$_| in '~$e~"\n do (block __l__ \n"~$b~"\n))"
  };
  method cb__Cond ($n) {
    my $els = '';
    if $n.default { $els = "(t \n"~$.e($n.default)~"\n)" }
    my $clauses = $.e($n.clauses);
    my $first = $clauses.shift;
    my $first_test = $first[0];
    if $n.invert_first_test { $first_test = "(not "~$first_test~")" }
    ('(cond ('~$first_test~"\n"~$first[1]~")\n"
    ~$clauses.map(sub($e){'('~$e[0]~"\n"~$e[1]~"\n)"}).join("")
    ~$els~")\n")
  };
  method cb__Loop ($n) {
    '(loop while '~$.e($n.pretest)~" do (block __l__ \n"~$.e($n.block)~"\n))"
  };

  method encode_varname($s,$t,$dsn) {
    my $t1 = $t.re_gsub('\|','\\|');
    my $dsn1 = $dsn.re_gsub('\|','\\|');
    if $t eq '*' {
      '|'~'GLOBAL::'~$s~$dsn1~'|'
    } else {
      '|'~$s~$t1~$dsn1~'|'
    }
  };

  method cb__Var ($n) {
    my $s = $n.sigil;
    my $t = $n.twigil||'';
    if $n.is_context { $t = '+' }
    my $dsn = $.e($n.name);
    my $v = $s~$t~$dsn;
    if $v eq '$?PACKAGE' || $v eq '$?MODULE' || $v eq '$?CLASS' {
      my $pkgname = $whiteboard::in_package.join('::'); # XXX should use $n notes instead.
      $pkgname = $pkgname || 'Main';
      "'"~$pkgname~"'"
    } elsif $v eq '$?FILE' {
      "'"~$.filename~"'"
    } elsif $v eq '$?LINE' {
      '0' # XXX $n notes needs to provide this.
    } elsif $v eq '$?PERLVER' {
      "'elf / "~ primitive_runtime_version() ~ " / " ~ $.WHAT ~"'"
    } else {
      $.encode_varname($s,$t,$dsn);
    }
  };
  method cb__NumInt ($n) {
    $.e($n.text)
  };
  method cb__Hash ($n) {
    temp $whiteboard::emit_pairs_inline = 1;
    '(fc #\'|M::new| |Hash::/co| '~$.e($n.hash||[]).join(" ")~')'
  };
  method cb__Buf ($n) {
    my $s = $n.buf;
    $.qstr($.translate_string($s));
  };
  method cb__Rx ($n) {
    my $pat = $n.pat || '';
    'qr/'~$pat~'/'
  };
  method cb__Pair($n) {
    if $whiteboard::emit_pairs_inline {
      temp $whiteboard::emit_pairs_inline = 0;
      ' '~$.e($n.key)~' '~$.e($n.value)~' '
    } else {
       "(fc #\'|M::new| |Pair::/co| 'key' "~$.e($n.key)~" 'value' "~$.e($n.value)~")"
    }
  };

  method translate_string($s) {
    $s.re_gsub('~','~~').re_gsub('\\\\n','~%').re_gsub('\\\\t',"\t").re_gsub('\\\\','\\\\\\\\')
  }

};

if not($*emitter0) { $*emitter0 = EmitSBCL.new}
$*emitter1 = EmitSBCL.new;
