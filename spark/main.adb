with Interfaces;  use Interfaces;
with ISqrt;       use ISqrt;
with Ada.Text_IO; use Ada.Text_IO;

procedure Main
is

   procedure Do_Test (X : in Sqrt_Domain);

   procedure Do_Test (X : in Sqrt_Domain)
   is
      T1, T2   : Sqrt_Range;
      OK1, OK2 : Boolean;
   begin
      T1 := Sqrt_Binary (X);

      --  nb - square (T1 + 1) using I64 to avoid
      --  overflow at run-time. Tacky.
      OK1 := ((T1 * T1) <= X) and
            ((I64 (T1) + 1) * (I64 (T1) + 1) > I64 (X));

      T2 := Sqrt_VN (X);
      OK2 := ((T2 * T2) <= X) and
            ((I64 (T2) + 1) * (I64 (T2) + 1) > I64 (X));

      Put ("X =" & X'Img &
             ", Sqrt_Binary (X) =" & T1'Img &
             ", Sqrt_VN (X) =" & T2'Img);

      if OK1 and OK2 and (T1 = T2) then
         Put_Line (" OK");
      else
         Put_Line (" Failed");
         raise Program_Error;
      end if;
   end Do_Test;


   T3 : Sqrt_Range;
begin
   --  Lower bound 0 .. 1024
   for I in Sqrt_Domain range 0 .. 1024 loop
      Do_Test (I);
   end loop;

   --  Upper bound - largest 1024 legal values
   for I in Sqrt_Domain range
     Sqrt_Domain'Last - 1024 .. Sqrt_Domain'Last loop
      Do_Test (I);
   end loop;

   --  "Interesting" boundary values 2**N - 1,
   --  2**N, and 2**N + 1, for N in 11 .. 30
   for I in Sqrt_Domain range 11 .. 30 loop
      Do_Test ((2 ** Natural (I)) - 1);
      Do_Test (2 ** Natural (I));
      Do_Test ((2 ** Natural (I)) + 1);
   end loop;

   Put_Line ("--- Instrumented --- case 1 - 2*31 - 1");
   T3 := Sqrt_VN2 (Sqrt_Domain'Last);
   Put_Line ("X = Sqrt_Domain'Last" &
             ", Sqrt_VN2 (X) =" & T3'Img);

   Put_Line ("--- Instrumented --- case 2 - 65025");
   T3 := Sqrt_VN2 (65025);
   Put_Line ("X = 65025" &
             ", Sqrt_VN2 (X) =" & T3'Img);


   Put_Line ("--- Exhaustive ---");
   for I in Sqrt_Domain loop
      declare
         T1, T2   : Sqrt_Range;
      begin
         T1 := Sqrt_Binary (I);
         T2 := Sqrt_VN (I);
         if I mod 1_000_000 = 0 then
            Put_Line (I'Img);
         end if;
         if T1 /= T2 then
            Put_Line ("Failed at " & I'Img);
            raise Program_Error;
         end if;
      end;
   end loop;

   Put_Line ("Done");
end Main;
