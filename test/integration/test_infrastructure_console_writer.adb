pragma Ada_2022;
--  ======================================================================
--  Test_Infrastructure_Console_Writer
--  ======================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--
--  Purpose:
--    Integration test for Infrastructure.Adapter.Console_Writer.
--    Tests adapter implementation and then exception handling.
--  ======================================================================

with Ada.Text_IO;
with Infrastructure.Adapter.Console_Writer;
with Application.Port.Outward.Writer;
with Test_Framework;

procedure Test_Infrastructure_Console_Writer is

   use Ada.Text_IO;
   use Application.Port.Outward.Writer;

   --  Test statistics
   Total_Tests  : Natural := 0;
   Passed_Tests : Natural := 0;

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

begin
   Put_Line ("========================================");
   Put_Line ("Testing: Infrastructure.Console_Writer");
   Put_Line ("========================================");
   New_Line;

   --  ========================================================================
   --  Test: Write simple message
   --  ========================================================================

   declare
      Result : constant Unit_Result.Result :=
        Infrastructure.Adapter.Console_Writer.Write ("Test message");
   begin
      Run_Test
        ("Write simple message - Is_Ok",
         Unit_Result.Is_Ok (Result));
   end;

   --  ========================================================================
   --  Test: Write empty message
   --  ========================================================================

   declare
      Result : constant Unit_Result.Result :=
        Infrastructure.Adapter.Console_Writer.Write ("");
   begin
      Run_Test
        ("Write empty message - Is_Ok",
         Unit_Result.Is_Ok (Result));
   end;

   --  ========================================================================
   --  Test: Write message with special characters
   --  ========================================================================

   declare
      Result : constant Unit_Result.Result :=
        Infrastructure.Adapter.Console_Writer.Write
          ("Special: !@#$%^&*()");
   begin
      Run_Test
        ("Write special chars - Is_Ok",
         Unit_Result.Is_Ok (Result));
   end;

   --  ========================================================================
   --  Test: Write message with Unicode
   --  ========================================================================

   declare
      Result : constant Unit_Result.Result :=
        Infrastructure.Adapter.Console_Writer.Write ("Unicode: José María");
   begin
      Run_Test
        ("Write Unicode - Is_Ok",
         Unit_Result.Is_Ok (Result));
   end;

   --  ========================================================================
   --  Test: Write long message
   --  ========================================================================

   declare
      Long_Message : constant String (1 .. 500) := [others => 'X'];
      Result       : constant Unit_Result.Result :=
        Infrastructure.Adapter.Console_Writer.Write (Long_Message);
   begin
      Run_Test
        ("Write long message - Is_Ok",
         Unit_Result.Is_Ok (Result));
   end;

   --  ========================================================================
   --  Test: Multiple writes don't interfere
   --  ========================================================================

   declare
      Result1 : constant Unit_Result.Result :=
        Infrastructure.Adapter.Console_Writer.Write ("Message 1");
      Result2 : constant Unit_Result.Result :=
        Infrastructure.Adapter.Console_Writer.Write ("Message 2");
      Result3 : constant Unit_Result.Result :=
        Infrastructure.Adapter.Console_Writer.Write ("Message 3");
   begin
      Run_Test
        ("Multiple writes - all Ok",
         Unit_Result.Is_Ok (Result1)
         and then Unit_Result.Is_Ok (Result2)
         and then Unit_Result.Is_Ok (Result3));
   end;

   --  ========================================================================
   --  Test: Write newline characters
   --  ========================================================================

   declare
      Result : constant Unit_Result.Result :=
        Infrastructure.Adapter.Console_Writer.Write
          ("Line 1" & ASCII.LF & "Line 2");
   begin
      Run_Test
        ("Write with newline - Is_Ok",
         Unit_Result.Is_Ok (Result));
   end;

   --  ========================================================================
   --  Test: Write tab characters
   --  ========================================================================

   declare
      Result : constant Unit_Result.Result :=
        Infrastructure.Adapter.Console_Writer.Write
          ("Col1" & ASCII.HT & "Col2");
   begin
      Run_Test
        ("Write with tab - Is_Ok",
         Unit_Result.Is_Ok (Result));
   end;

   --  Print summary
   New_Line;
   Put_Line ("========================================");
   Put_Line ("Test Summary: Infrastructure.Console_Writer");
   Put_Line ("========================================");
   Put_Line ("Total tests: " & Total_Tests'Image);
   Put_Line ("Passed:      " & Passed_Tests'Image);
   Put_Line ("Failed:      " & Natural'Image (Total_Tests - Passed_Tests));
   New_Line;

   --  Register results with test framework
   Test_Framework.Register_Results (Total_Tests, Passed_Tests);

end Test_Infrastructure_Console_Writer;
