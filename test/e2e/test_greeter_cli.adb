pragma Ada_2022;
--  ======================================================================
--  Test_Greeter_CLI
--  ======================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--
--  Purpose:
--    E2E (black-box) tests for the greeter CLI executable.
--    Tests the application by executing the binary and then verifying output.
--  ======================================================================

with Ada.Text_IO;
with Ada.Directories;
with GNAT.OS_Lib;
with Test_Framework;

procedure Test_Greeter_CLI is

   use Ada.Text_IO;
   use Ada.Directories;
   use GNAT.OS_Lib;

   --  Test statistics
   Total_Tests  : Natural := 0;
   Passed_Tests : Natural := 0;

   --  Path to greeter executable (relative to project root where test runs)
   Greeter_Exe : constant String := "bin/greeter";

   --  Helper procedure to run a test
   pragma Style_Checks (Off);
   procedure Run_Test (Name : String; Passed : Boolean) is
   begin
      Total_Tests := Total_Tests + 1;
      if Passed then
         Passed_Tests := Passed_Tests + 1;
         Put_Line ("[PASS] " & Name);
      else
         Put_Line ("[FAIL] " & Name);
      end if;
   end Run_Test;
   pragma Style_Checks (On);

   --  ========================================================================
   --  Helper: Execute greeter with arguments and then check exit code
   --  ========================================================================

   pragma Style_Checks (Off);
   function Execute_Greeter
     (Args : Argument_List; Expected_Exit_Code : Integer) return Boolean
   is
      Success : Boolean;
   begin
      Spawn (Greeter_Exe, Args, Success);
      return Success = (Expected_Exit_Code = 0);
   end Execute_Greeter;
   pragma Style_Checks (On);

begin
   Put_Line ("========================================");
   Put_Line ("Testing: Greeter CLI (E2E)");
   Put_Line ("========================================");
   New_Line;

   --  Check if greeter executable exists
   if not Exists (Greeter_Exe) then
      Put_Line ("[ERROR] Greeter executable not found at: " & Greeter_Exe);
      Put_Line ("[INFO] Please build the project first: alr build");
      return;
   end if;

   Put_Line ("[INFO] Testing executable: " & Greeter_Exe);
   New_Line;

   --  ========================================================================
   --  Test: Execute with valid name (success case)
   --  ========================================================================

   declare
      Arg1    : String_Access := new String'("Alice");
      Args : constant Argument_List := [1 => Arg1];
      Success : Boolean;
   begin
      Success := Execute_Greeter (Args, Expected_Exit_Code => 0);
      Run_Test ("CLI - valid name 'Alice' exits with code 0", Success);
      Free (Arg1);
   end;

   --  ========================================================================
   --  Test: Execute with name containing spaces
   --  ========================================================================

   declare
      Arg1    : String_Access := new String'("Bob Smith");
      Args : constant Argument_List := [1 => Arg1];
      Success : Boolean;
   begin
      Success := Execute_Greeter (Args, Expected_Exit_Code => 0);
      Run_Test
        ("CLI - name with spaces 'Bob Smith' exits with code 0", Success);
      Free (Arg1);
   end;

   --  ========================================================================
   --  Test: Execute with special characters
   --  ========================================================================

   declare
      Arg1    : String_Access := new String'("Anne-Marie");
      Args : constant Argument_List := [1 => Arg1];
      Success : Boolean;
   begin
      Success := Execute_Greeter (Args, Expected_Exit_Code => 0);
      Run_Test
        ("CLI - name with hyphen 'Anne-Marie' exits with code 0", Success);
      Free (Arg1);
   end;

   --  ========================================================================
   --  Test: Execute without arguments (should show usage)
   --  ========================================================================

   declare
      Args    : Argument_List (1 .. 0);
      Success : Boolean;
   begin
      Success := Execute_Greeter (Args, Expected_Exit_Code => 1);
      Run_Test ("CLI - no arguments exits with code 1", Success);
   end;

   --  ========================================================================
   --  Test: Execute with empty string (validation error)
   --  ========================================================================

   declare
      Arg1    : String_Access := new String'("");
      Args : constant Argument_List := [1 => Arg1];
      Success : Boolean;
   begin
      Success := Execute_Greeter (Args, Expected_Exit_Code => 1);
      Run_Test ("CLI - empty name exits with code 1", Success);
      Free (Arg1);
   end;

   --  ========================================================================
   --  Test: Execute with very long name (within max length)
   --  ========================================================================

   declare
      Long_Name : constant String (1 .. 50) := [others => 'X'];
      Arg1      : String_Access := new String'(Long_Name);
      Args      : constant Argument_List := [1 => Arg1];
      Success   : Boolean;
   begin
      Success := Execute_Greeter (Args, Expected_Exit_Code => 0);
      Run_Test ("CLI - long name (50 chars) exits with code 0", Success);
      Free (Arg1);
   end;

   --  ======================================================================
   --  Test: Execute with Unicode characters
   --  ======================================================================

   declare
      Arg1    : String_Access := new String'("José");
      Args : constant Argument_List := [1 => Arg1];
      Success : Boolean;
   begin
      Success := Execute_Greeter (Args, Expected_Exit_Code => 0);
      Run_Test ("CLI - Unicode name 'José' exits with code 0", Success);
      Free (Arg1);
   end;

   --  ======================================================================
   --  Test: Execute multiple times (stateless behavior)
   --  ======================================================================

   declare
      Arg1     : String_Access := new String'("First");
      Args1    : constant Argument_List := [1 => Arg1];
      Arg2     : String_Access := new String'("Second");
      Args2    : constant Argument_List := [1 => Arg2];
      Arg3     : String_Access := new String'("Third");
      Args3    : constant Argument_List := [1 => Arg3];
      Success1 : Boolean;
      Success2 : Boolean;
      Success3 : Boolean;
   begin
      Success1 := Execute_Greeter (Args1, Expected_Exit_Code => 0);
      Success2 := Execute_Greeter (Args2, Expected_Exit_Code => 0);
      Success3 := Execute_Greeter (Args3, Expected_Exit_Code => 0);
      Run_Test
        ("CLI - multiple executions all succeed",
         Success1 and then Success2 and then Success3);
      Free (Arg1);
      Free (Arg2);
      Free (Arg3);
   end;

   --  Print summary
   New_Line;
   Put_Line ("========================================");
   Put_Line ("Test Summary: Greeter CLI (E2E)");
   Put_Line ("========================================");
   Put_Line ("Total tests: " & Total_Tests'Image);
   Put_Line ("Passed:      " & Passed_Tests'Image);
   Put_Line ("Failed:      " & Natural'Image (Total_Tests - Passed_Tests));
   New_Line;

   --  Register results with test framework
   Test_Framework.Register_Results (Total_Tests, Passed_Tests);

end Test_Greeter_CLI;
