with Ada.Text_IO; use Ada.Text_IO;

package body ISqrt
  with SPARK_Mode => On
is
   subtype U32 is Unsigned_32;
   subtype U64 is Unsigned_64;


   -----------------
   -- Sqrt_Binary --
   -----------------

   function Sqrt_Binary
     (X : in Sqrt_Domain)
      return Sqrt_Range
   is
      subtype Upper_Guess is I32 range 0 .. Sqrt_Range'Last + 1;
      Lower  : Sqrt_Range;
      Upper  : Upper_Guess;
      Middle : Sqrt_Range;
   begin
      Lower := 0;
      Upper := Upper_Guess'Last;

      loop
         pragma Loop_Invariant ((Lower * Lower) <= X and
                                (I64 (Upper) * I64 (Upper)) > I64 (X));

         exit when Lower + 1 = Upper;
         Middle := (Lower + Upper) / 2;
         if (Middle * Middle) > X then
            Upper := Middle;
         else
            Lower := Middle;
         end if;
      end loop;
      return Lower;
   end Sqrt_Binary;

   ----------------------
   -- Sqrt_Von_Neumann --
   ----------------------

--  Algorithm from Warren'a "Hacker's Delight" Figure 11.4
--  int isqrt4(unsigned x) {
--     unsigned m, y, b;
--     m = 0x40000000;
--     y = 0;
--     while(m != 0) {              // Do 16 times.
--        b = y | m;
--        y = y >> 1;
--        if (x >= b) {
--           x = x - b;
--           y = y | m;
--        }
--        m = m >> 2;
--     }
--     return y;
--  }

   function Sqrt_VN
     (X : in Sqrt_Domain)
      return Sqrt_Range
   is
      subtype U32 is Unsigned_32;
      subtype Bit_Number is Natural range 0 .. 15;
      UX, M, Y, B : U32;
   begin
      UX := U32 (X);
      M  := 16#4000_0000#;
      Y  := 0;

      for I in reverse Bit_Number loop
         B := Y + M;

         if (UX >= B) then
            UX := UX - B;
            Y  := (Y / 2) + M;
         else
            Y := Y / 2;
         end if;

         pragma Loop_Invariant (UX <= U32 (X));
         pragma Loop_Invariant (M = (2**(2 * I)));
         pragma Loop_Invariant (Y < (2**(I + 16)));
         pragma Loop_Invariant (2**I - 1 <= 32767);

         --  At this point, Y contains the (16-I) correct
         --  most-significant bits of the answer, and I
         --  least-significant bits whose values are currently
         --  unknown. If we assume the unknown bits are all
         --  zero, then then value must be just right or
         --  too small, so...

         --  2*I LSBs of Y are all zero
         pragma Loop_Invariant (2**(2 * I) /= 0);
         pragma Loop_Invariant (Y mod (2**(2 * I)) = 0);

         --  Shifting Y right by I bits yields a 16-bit value
         --  that is less than or equal to Sqrt_Range'Last
         pragma Loop_Invariant (Shift_Right (Y, I) <= U32 (Sqrt_Range'Last));

         pragma Loop_Invariant (I32 (Shift_Right (Y, I)) *
                                I32 (Shift_Right (Y, I)) <= X);

         --  Similarly, if we set all the unknown least-significant
         --  bits to one (with value 2**I-1), and add another one,
         --  then that value must be too big so...
         pragma Loop_Invariant (2**I - 1 in 0 .. 32767);
         pragma Loop_Invariant
            (I64 (Shift_Right (Y, I)) + I64 (2**I - 1) + 1 >= 1);
         pragma Loop_Invariant
            (I64 (Shift_Right (Y, I)) + I64 (2**I - 1) + 1 <= 79108);
         pragma Loop_Invariant
            ((I64 (Shift_Right (Y, I)) + I64 (2**I - 1) + 1) *
             (I64 (Shift_Right (Y, I)) + I64 (2**I - 1) + 1) > I64 (X));

         M := M / 4;
      end loop;

      --  I=0 means we have "no unknown bits", so
      --  substitute I=0 into the loop invariant and simplify to get:
      pragma Assert (I32 (Y) * I32 (Y) <= X);
      pragma Assert
         ((I64 (Y) + 1) *
          (I64 (Y) + 1) > I64 (X));

      return Sqrt_Range (Y);
   end Sqrt_VN;

   function Sqrt_VN2
     (X : in Sqrt_Domain)
      return Sqrt_Range
     with SPARK_Mode => Off
   is
      package U32IO is new Ada.Text_IO.Modular_IO (U32);
      use U32IO;

      UX, M, Y, B : U32;
   begin
      UX := U32 (X);
      M  := 16#4000_0000#;
      Y  := 0;

      for I in reverse Natural range 0 .. 15 loop
         B := Y or M;
         Y := Y / 2;

         Put ("UX = ");
         Put (UX, Base => 16, Width => 12);
         Put (", B = ");
         Put (B, Base => 16, Width => 12);
         Put (", M = ");
         Put (M, Base => 16, Width => 12);
         Put (", Y = ");
         Put (Y, Base => 16, Width => 12);

         if (UX >= B) then
            UX := UX - B;
            Y  := Y or M;
         end if;
         M := M / 4;

         Put (", New Y = ");
         Put (Y, Base => 16, Width => 12);
         Put (", New M = ");
         Put (M, Base => 16, Width => 12);
         New_Line;

         Put ("At the Inv, I = ");
         Put (U32 (I));
         Put (", Y = ");
         Put (Y, Base => 16, Width => 12);
         Put (", X = ");
         Put (U32 (X), Base => 16, Width => 12);
         New_Line;

         pragma Loop_Invariant (Shift_Right (Y, I) *
                                Shift_Right (Y, I) <= U32 (X));

         pragma Loop_Invariant
            ((Shift_Right (U64 (Y), I) + U64 (2**I - 1) + 1) *
             (Shift_Right (U64 (Y), I) + U64 (2**I - 1) + 1) > U64 (X));

      end loop;

      return Sqrt_Range (Y);
   end Sqrt_VN2;

end ISqrt;
