with Interfaces; use Interfaces;
package ISqrt
  with SPARK_Mode => On
is
   subtype I32 is Integer_32;
   subtype I64 is Integer_64;
   subtype Sqrt_Domain is I32 range 0 .. 2**31 - 1;
   subtype Sqrt_Range  is I32 range 0 .. 46340;

   --  Truncated natural square root, binary chop search
   function Sqrt_Binary (X : in Sqrt_Domain) return Sqrt_Range
     with Post => (Sqrt_Binary'Result * Sqrt_Binary'Result) <= X and
                  (I64 (Sqrt_Binary'Result) + 1) *
                  (I64 (Sqrt_Binary'Result) + 1) > I64 (X);


   --  Truncated natural square root, Von Neumann's algorithm
   function Sqrt_VN (X : in Sqrt_Domain) return Sqrt_Range
     with Post => (Sqrt_VN'Result * Sqrt_VN'Result) <= X and
                  (I64 (Sqrt_VN'Result) + 1) *
                  (I64 (Sqrt_VN'Result) + 1) > I64 (X);


   --  As above, instrumented
   function Sqrt_VN2 (X : in Sqrt_Domain) return Sqrt_Range;

end ISqrt;
