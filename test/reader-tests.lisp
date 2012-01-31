(cl:in-package #:vacietis.test.reader)
(named-readtables:in-readtable vacietis:vacietis)

(eos:in-suite vacietis.test::vacietis-reader)

(reader-test decimal
  "1234567890;"
  1234567890)

(reader-test float
  "12323.0;"
  12323.0)

(reader-test zero
  "0;"
  0)

(reader-test zero-float
  "0.0;"
  0.0)

(reader-test string1
  "x = \"foo\";"
  (= x "foo"))

(reader-test string2
  "b = \"foo\" \"bar\";"
  (= b "foobar"))

(reader-test string-escape1
  "_FOO = \"foo\\nbar\";"
  (= _FOO "foo
bar"))

(reader-test identifier1
  "_foo;"
  _foo)

(reader-test identifier2
  "bar_foo;"
  bar_foo)

(reader-test identifier3
  "bar_foo99;"
  bar_foo99)

(reader-test int-var1
  "int x;"
  (cl:progn (cl:defparameter x 0)))

;;; function definition

(reader-test simple-function1
  "void foo(int a, int b) {
a + b;
}"
  (vacietis::c-fun foo (a b) ()
    (+ a b)))

(reader-test function0
  "int max(int a, int b)
{
return a > b ? a : b;
}"
  (vacietis::c-fun max (a b) ()
    (return (if (> a b) a b))))

(reader-test function1
  "extern int max(int a, int b)
{
return a > b ? a : b;
}"
  (vacietis::c-fun max (a b) ()
    (return (if (> a b) a b))))

;;; function calls

(reader-test funcall-args0
  "random();"
  (random))

(reader-test funcall-args1
  "foo(1);"
  (foo 1))

(reader-test funcall-args2
  "foo(1,2);"
  (foo 1 2))

(reader-test funcall-args3
  "foo(1,2,3);"
  (foo 1 2 3))

(reader-test funcall-args4
  "foo(1,2,3,4);"
  (foo 1 2 3 4))

(reader-test function-call1
  "printf(\"hello, world\\n\");"
  (printf "hello, world
"))

(reader-test function-call2
  "check_gc_signals_unblocked_or_lose(0);"
  (check_gc_signals_unblocked_or_lose 0))

(reader-test function-call-assign0
  "result = general_alloc(bytes, page_type_flag);"
  (= result (general_alloc bytes page_type_flag)))

;;; expressions

(reader-test number-plus
  "1 + 2;"
  (+ 1 2))

(reader-test foo-plus
  "foo + 2;"
  (+ foo 2))

(reader-test elvis0
  "a ? 1 : 2;"
  (if a 1 2))

(reader-test elvis1
  "a > b ? a : b;"
  (if (> a b) a b))

(reader-test elvis-return
  "return a > b ? a : b;"
  (return (if (> a b) a b)))

(reader-test return1
  "return 1;"
  (return 1))

(reader-test lognot1
  "foo = ~010;"
  (= foo (~ 8)))

(reader-test nequal1
  "foo != 0x10;"
  (!= foo 16))

(reader-test inc1
  "++a;"
  (++ a))

(reader-test inc2
  "a++;"
  (post++ a))

(reader-test dec1
  "--a;"
  (-- a))

(reader-test dec2
  "a--;"
  (post-- a))

(reader-test dec3
  "--foo;"
  (-- foo))

(reader-test op-precedence1
  "a + b + c;"
  (+ a (+ b c)))

(reader-test assign1
  "foo = 1;"
  (= foo 1))

(reader-test assign2
  "foo = 1 + 2;"
  (= foo (+ 1 2)))

(reader-test assign3
  "foo = !2;"
  (= foo (! 2)))

(reader-test assign4
  "foo = ~2;"
  (= foo (~ 2)))

(reader-test multi-line-exp0
  "(SymbolValue(GC_PENDING,th) == NIL) &&
   (SymbolValue(GC_INHIBIT,th) == NIL) &&
   (random() < RAND_MAX/100);"
  (&& (== (SymbolValue GC_PENDING th) NIL)
      (&& (== (SymbolValue GC_INHIBIT th) NIL)
          (< (random) (/ RAND_MAX 100)))))

(reader-test funcall-compare
  "SymbolValue(GC_PENDING,th) == NIL;"
  (== (SymbolValue GC_PENDING th) NIL))

(reader-test funcall-compare-parethesized
  "(SymbolValue(GC_PENDING,th) == NIL);"
  (== (SymbolValue GC_PENDING th) NIL))

(reader-test funcall-lessthan
  "random() < RAND_MAX/100;"
  (< (random) (/ RAND_MAX 100)))

(reader-test multi-exp0
  "(SymbolValue(GC_PENDING,th) == NIL) &&
   (SymbolValue(GC_INHIBIT,th) == NIL);"
  (&& (== (SymbolValue GC_PENDING th) NIL) (== (SymbolValue GC_INHIBIT th) NIL)))

;;; conditionals

(reader-test if-foo1
  "if foo { 1 + 2; }"
  (if foo ((+ 1 2))))

(reader-test if-foo2
  "if foo 1 + 2;"
  (if foo ((+ 1 2))))

(reader-test big-if
  "if ((SymbolValue(GC_PENDING,th) == NIL) &&
        (SymbolValue(GC_INHIBIT,th) == NIL) &&
        (random() < RAND_MAX/100)) {
        SetSymbolValue(GC_PENDING,T,th);
        set_pseudo_atomic_interrupted(th);
        maybe_save_gc_mask_and_block_deferrables(NULL);
    }"
  (if (&& (== (SymbolValue GC_PENDING th) NIL)
          (&& (== (SymbolValue GC_INHIBIT th) NIL)
              (< (random) (/ RAND_MAX 100))))
      ((SetSymbolValue GC_PENDING T th)
       (set_pseudo_atomic_interrupted th)
       (maybe_save_gc_mask_and_block_deferrables NULL))))

(reader-test smaller-if
  "if ((SymbolValue(GC_PENDING,th) == NIL) &&
        (SymbolValue(GC_INHIBIT,th) == NIL) &&
        (random() < RAND_MAX/100)) {
1;
    }"
  (if (&& (== (SymbolValue GC_PENDING th) NIL)
          (&& (== (SymbolValue GC_INHIBIT th) NIL)
              (< (random) (/ RAND_MAX 100))))
      (1)))

;;; casts and pointers

(reader-test cast1
  "(int) foobar;"
  foobar)

(reader-test deref-var
  "*foo;"
  (deref* foo))

(reader-test deref-funcall
  "*foo();"
  (deref* (foo)))

(reader-test deref-assign-cast
  "*access_control_stack_pointer(th) = (int) result;"
  (= (deref* (access_control_stack_pointer th)) result))

(reader-test plus-eql
  "access_control_stack_pointer(th) += 1;"
  (+= (access_control_stack_pointer th) 1))

(reader-test pointer-pointer
  "result = (int *) *access_control_stack_pointer(th);"
  (= result (deref* (access_control_stack_pointer th))))

(reader-test cast-deref
  "(int) *foo();"
  (deref* (foo)))

(reader-test declare-pointer0
  "int *result;"
  (cl:progn (cl:defparameter result 0)))

(reader-test ptr-ptr-cast
  "(int *)((char *)result + bytes);"
  (+ result bytes))

(reader-test ptr-ptr-cast-assign
  "dynamic_space_free_pointer = (int *)((char *)result + bytes);"
  (= dynamic_space_free_pointer (+ result bytes)))

(reader-test cast-ptr-subtract
  "(char *)dynamic_space_free_pointer
                            - (char *)current_dynamic_space;"
  (- dynamic_space_free_pointer current_dynamic_space))

(reader-test funcall-arglist-op1
  "foo(1 - 2);"
  (foo (- 1 2)))

(reader-test funcall-arglist-op2
  "foo(1 - 2, 3 - 4);"
  (foo (- 1 2) (- 3 4)))

(reader-test funcall-arglist-op3
  "foo(1 - 2, 4);"
  (foo (- 1 2) 4))

(reader-test funcall-cast-ptr-subtract
  "set_auto_gc_trigger((char *)dynamic_space_free_pointer
                            - (char *)current_dynamic_space);"
  (set_auto_gc_trigger (- dynamic_space_free_pointer current_dynamic_space)))

(reader-test big-if1
  "if (current_auto_gc_trigger
        && dynamic_space_free_pointer > current_auto_gc_trigger) {
        clear_auto_gc_trigger();
        set_auto_gc_trigger((char *)dynamic_space_free_pointer
                            - (char *)current_dynamic_space);
    }"
  (if (&& current_auto_gc_trigger (> dynamic_space_free_pointer current_auto_gc_trigger))
      ((clear_auto_gc_trigger)
       (set_auto_gc_trigger (- dynamic_space_free_pointer current_dynamic_space)))))

(reader-test deref-increment
  "*x++;"
  (deref* (post++ x)))

(reader-test no-arg-function
  "void foo() {
a + b;
}"
  (vacietis::c-fun foo () ()
    (+ a b)))

(reader-test labeled-statement1
  "void foo() {
baz: a + b;
}"
  (vacietis::c-fun foo () ()
    baz (+ a b)))

(reader-test sizeof-something
  "int lispobj[20];
result = pa_alloc(ALIGNED_SIZE((1 + words) * sizeof(lispobj)),
                      UNBOXED_PAGE_FLAG);"
  (cl:progn (cl:defparameter lispobj (vacietis::allocate-memory 20)))
  (= result
     (pa_alloc
      (ALIGNED_SIZE
       (* (+ 1 words) 20))
      UNBOXED_PAGE_FLAG)))

(reader-test deref-cast-shift
  "*result = (int) (words << N_WIDETAG_BITS) | type;"
  (= (deref* result)
     (|\|| (<< words N_WIDETAG_BITS) type)))

(reader-test function-vars0
  "void main () {
int x;
}"
  (vacietis::c-fun main () ((x 0))
    ))

(reader-test function-comments0
  "void main () {
/* this is a comment */
int x;
}"
  (vacietis::c-fun main () ((x 0))
    ))

(reader-test function-comments1
  "void main () {
/* this is a comment */
int x;
// this is another comment
}"
  (vacietis::c-fun main () ((x 0))
    ))

(reader-test while0
  "while (fahr <= upper) {
celsius = 5 * (fahr-32) / 9;
printf(\"%d\t%d\n\", fahr, celsius);
fahr = fahr + step;
}"
  (while (<= fahr upper)
    (= celsius (* 5 (/ (- fahr 32) 9)))
    (printf "%dt%dn" fahr celsius)
    (= fahr (+ fahr step))))

(reader-test multiple-declaration0
  "int x, y;"
  (cl:progn (cl:defparameter x 0) (cl:defparameter y 0)))

(reader-test k&r-pg9
  "void main()
{
printf(\"hello, world\\n\");
}
"
  (vacietis::c-fun main () ()
    (printf "hello, world
")))

(reader-test k&r-pg12
  "void main()
{
int fahr, celsius;
int lower, upper, step;
lower = 0;
upper = 300;
step = 20;
/* lower limit of temperature scale */
/* upper limit */
/* step size */
fahr = lower;
while (fahr <= upper) {
celsius = 5 * (fahr-32) / 9;
printf(\"%d\t%d\n\", fahr, celsius);
fahr = fahr + step;
}
}
"
  (vacietis::c-fun main () ((step 0) (upper 0) (lower 0) (celsius 0) (fahr 0))
    (= lower 0)
    (= upper 300)
    (= step 20)
    (= fahr lower)
    (while (<= fahr upper)
      (= celsius (* 5 (/ (- fahr 32) 9)))
      (printf "%dt%dn" fahr celsius)
      (= fahr (+ fahr step)))))

(reader-test k&r-pg16
  "void main()
{
int fahr;
for (fahr = 0; fahr <= 300; fahr = fahr + 20)
printf(\"%3d %6.1f\\n\", fahr, (5.0/9.0)*(fahr-32));
}
"
  (vacietis::c-fun main () ((fahr 0))
    (for (() (= fahr 0) (<= fahr 300) (= fahr (+ fahr 20)))
      (printf "%3d %6.1f
"
                 fahr (* (/ 5.0 9.0) (- fahr 32))))))

(reader-test c99-style-for-init
  "for (int x = 0; x < 10; x++)
x++;"
  (for (((x 0)) (cl:progn (= x 0)) (< x 10) (post++ x))
    (post++ x)))

(reader-test c99-style-for1
  "for (int x = 0; x < 10; x++) foobar += x;"
  (for (((x 0)) (cl:progn (= x 0)) (< x 10) (post++ x))
    (+= foobar x)))

(reader-test k&r-pg18
  "void main()
{
int c;
c = getchar();
while (c != EOF) {
  putchar(c);
  c = getchar();
}
}
"
  (vacietis::c-fun main () ((c 0))
    (= c (getchar))
    (while (!= c EOF)
      (putchar c)
      (= c (getchar)))))

(reader-test var-declare-and-initialize0
  "int x = 1;"
  (cl:progn (cl:defparameter x 1)))

(reader-test modulo0
  "1 % 2;"
  (% 1 2))

(reader-test h&s-while1
  "int pow(int base, int exponent)
{
    int result = 1;
    while (exponent > 0) {
        if ( exponent % 2 ) result *= base;
        base *= base;
        exponent /= 2;
    }
    return result;
}"
  (vacietis::c-fun pow (base exponent) ((result 0))
    (cl:progn (= result 1))
    (while (> exponent 0)
      (if (% exponent 2) ((*= result base)))
      (*= base base)
      (/= exponent 2))
    (return result)))

(reader-test empty-label
  "int main () { end:; }"
  (vacietis::c-fun main () ()
    end
    cl:nil))

(reader-test h&s-while2
  "while ( *char_pointer++ );"
  (while (deref* (post++ char_pointer))
    cl:nil))

(reader-test h&s-while3
  "while ( *dest_pointer++ = *source_pointer++ );"
  (while (= (deref* (post++ dest_pointer)) (deref* (post++ source_pointer)))
    cl:nil))

(reader-test just-return
  "return;"
  (return cl:nil))

(reader-test array-of-ints0
  "int foobar[];"
  (cl:progn (cl:defparameter foobar 0)))

(reader-test array-of-pointers-to-int0
  "int *foobar[];"
  (cl:progn (cl:defparameter foobar 0)))

(reader-test array-of-pointers-to-int1
  "int *foobar[5];"
  (cl:progn (cl:defparameter foobar (vacietis::allocate-memory 5))))

(reader-test array-of-ints1
  "int foobar[5];"
  (cl:progn (cl:defparameter foobar (vacietis::allocate-memory 5))))

(reader-test pointer-to-int0
  "int *x;"
  (cl:progn (cl:defparameter x 0)))

(reader-test char-literal0
  "char foobar[] = \"Foobar\";"
  (cl:progn (cl:defparameter foobar "Foobar")))

(reader-test declaration-initialization0
  "int x = 1 + 2;"
  (cl:progn (cl:defparameter x (+ 1 2))))

(reader-test declare-two-ints0
  "int x, y;"
  (cl:progn (cl:defparameter x 0)
            (cl:defparameter y 0)))

(reader-test declare-two-ints-initialize0
  "int x = 1, y;"
  (cl:progn (cl:defparameter x 1)
            (cl:defparameter y 0)))

(reader-test declare-two-ints-initialize1
  "int x, y = 1;"
  (cl:progn (cl:defparameter x 0)
            (cl:defparameter y 1)))

(reader-test declare-two-ints-initialize2
  "int x = 1, y = 2;"
  (cl:progn (cl:defparameter x 1)
            (cl:defparameter y 2)))

(reader-test declare-two-ints-initialize3
  "int x = 1 + 2, y;"
  (cl:progn (cl:defparameter x (+ 1 2))
            (cl:defparameter y 0)))

(reader-test declare-two-ints-initialize4
  "int x, y = 1 + 2;"
  (cl:progn (cl:defparameter x 0)
            (cl:defparameter y (+ 1 2))))

(reader-test declare-two-ints-initialize5
  "int x = 1 + 2, y = 3 + 4;"
  (cl:progn (cl:defparameter x (+ 1 2))
            (cl:defparameter y (+ 3 4))))

(reader-test declare-two-ints-initialize6
  "int x = foo(), y;"
  (cl:progn (cl:defparameter x (foo))
            (cl:defparameter y 0)))

(reader-test declare-two-ints-initialize7
  "int x = foo(1 + 2), y;"
  (cl:progn (cl:defparameter x (foo (+ 1 2)))
            (cl:defparameter y 0)))

(reader-test declare-two-ints-initialize8
  "int x, y = foo(1 + 2);"
  (cl:progn (cl:defparameter x 0)
            (cl:defparameter y (foo (+ 1 2)))))

(reader-test declare-two-ints-initialize9
  "int x = 3 + 4, y = foo(1 + 2);"
  (cl:progn (cl:defparameter x (+ 3 4))
            (cl:defparameter y (foo (+ 1 2)))))

(reader-test declare-two-ints-initialize10
  "int x = bar(3 + 4), y = foo(1 + 2);"
  (cl:progn (cl:defparameter x (bar (+ 3 4)))
            (cl:defparameter y (foo (+ 1 2)))))

(reader-test declare-deref0
  "int *x[], *y[] = foo;"
  (cl:progn (cl:defparameter x 0) (cl:defparameter y foo)))

(reader-test declare-deref1
  "int *x[], *y[] = 4;"
  (cl:progn (cl:defparameter x 0) (cl:defparameter y 4)))

(reader-test declare-deref2
  "int *x[], *y = 4;"
  (cl:progn (cl:defparameter x 0) (cl:defparameter y 4)))

(reader-test declare-deref3
  "int *x[], *y;"
  (cl:progn (cl:defparameter x 0) (cl:defparameter y 0)))

(reader-test declare-deref4
  "int *x[], y;"
  (cl:progn (cl:defparameter x 0) (cl:defparameter y 0)))

(reader-test declare-deref5
  "int x[], y;"
  (cl:progn (cl:defparameter x 0) (cl:defparameter y 0)))

(reader-test declare-two-chars-initialize0
  "char source_pointer[] = \"foobar\", dest_pointer[7];"
  (cl:progn
    (cl:defparameter source_pointer "foobar")
    (cl:defparameter dest_pointer (vacietis::allocate-memory 7))))

(reader-test aref0
  "x[5];"
  ([] x 5))

(reader-test aref1
  "x[1 + 2];"
  ([] x (+ 1 2)))

(reader-test h&s-static-short
  "static short s;"
  (cl:progn (cl:defparameter s 0)))

(reader-test h&s-declaration-multiple-initialization
  "void main() {
static short s;
auto short *sp = &s + 3, *msp = &s - 3;
}"
  (vacietis::c-fun main () ((msp 0) (sp 0) (s 0))
    (cl:progn
      (= sp (+ (mkptr& s) 3))
      (= msp (- (mkptr& s) 3)))))

(reader-test preprocessor-define-template-noargs
  "#define getchar()  getc(stdin)
getchar();"
  cl:nil (getc stdin))

(reader-test simple-struct1
  "struct complex {
double real;
double imag;
};"
  (vacietis::c-struct complex real imag))

(reader-test simple-struct-decl
  "struct complex { double real; double imag; } x, y;"
  (cl:progn (vacietis::c-struct complex real imag)
            (cl:progn (cl:defparameter x (vacietis::allocate-memory 2))
                      (cl:defparameter y (vacietis::allocate-memory 2)))))

(reader-test struct-forward-declaration
  "struct cell;"
  (vacietis::c-struct cell))

;; (reader-test function-returning-pointer-to-int
;;   "int *foo();"
;;   nil)
;; declaration, should be ignored?

;; (reader-test array-of-array-of-ints
;;   "int foobar[5][5];")

;; (reader-test pointer-to-array-of-ints0
;;   "int (*foobar)[];"
;;   (cl:progn (cl:defparameter foobar 0)))

;; (reader-test pointer-to-array-of-ints1
;;   "int (*foobar)[5];"
;;   (cl:progn (cl:defparameter foobar 0)))

;; (reader-test unclosed-string
;;   "\"foo")