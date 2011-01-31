#30jan11jir
# (c) Jose I. Romero
(on *Doc)

(de document (Sym Doc)
   (with Sym (=: *Doc Doc)) )

(de help (Sym)
   (with Sym (prinl (: *Doc))) T)

(de sig (Sym)
   (with Sym
      (let Lines (split (chop (: *Doc)) "^J" )
         (while (pop 'Lines)
            (prinl @)) ) ) T )

(document
   'document "(document 'sym docstring) -> docstring

Document a function. By default this function assigns the docstring to a
property called *Doc in sym. Can be overriden to provide functionality such
as document generation and unit testing.

  : (document 'foo \"(foo 'bar) -> any^J^JFoo the bar. Bar must bam baz.\")
  -> \"(foo 'bar) -> any^J^JFoo the bar. Bar must bam baz.\"" )

(document
   'help "(help sym) -> T

Display the documentation of sym.

  : (document 'foo \"(foo 'bar) -> any^J^JFoo the bar. Bar must bam baz.\")
  -> \"(foo 'bar) -> any^J^JFoo the bar. Bar must bam baz.\"
  :  (help 'foo)
  (foo 'bar) -> any
  
  Foo the bar. Bar must bam baz.
  -> T" )

(document
   'sig "(sig 'sym) -> T

Display the signature(s) of 'sym, signatures are separated from the description
body by an empty line.

  : (document 'foo \"(foo 'bar) -> any^J^JFoo the bar. Bar must bam baz.\")
  -> \"(foo 'bar) -> any^J^JFoo the bar. Bar must bam baz.\"
  : (sig 'foo)                                                           
  (foo 'bar) -> any
  -> T" )
