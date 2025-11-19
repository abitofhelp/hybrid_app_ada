pragma Ada_2022;
--  ======================================================================
--  E2E_Runner - Main test runner for E2E tests
--  ======================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--
--  Purpose:
--    Runs all E2E tests and reports cumulative results.
--  ======================================================================

with Ada.Command_Line;
with Ada.Text_IO;
with Test_Framework;

--  Import all test procedures
with Test_Greeter_CLI;

procedure E2E_Runner is

   use Ada.Text_IO;
   use Ada.Command_Line;

   Total  : Natural;
   Passed : Natural;

begin
   Put_Line ("");
   Put_Line ("========================================");
   Put_Line ("     SIMPLE_HYBRID E2E TEST SUITE");
   Put_Line ("========================================");
   Put_Line ("");

   --  Reset test framework before running tests
   Test_Framework.Reset;

   --  Run all E2E test procedures
   --  Each test registers its results with Test_Framework

   Test_Greeter_CLI;

   --  Get cumulative results
   Total  := Test_Framework.Grand_Total_Tests;
   Passed := Test_Framework.Grand_Total_Passed;

   --  Print grand summary
   Put_Line ("");
   Put_Line ("========================================");
   Put_Line ("        GRAND TOTAL - ALL E2E TESTS");
   Put_Line ("========================================");
   Put_Line ("Total tests:  " & Total'Image);
   Put_Line ("Passed:       " & Passed'Image);
   Put_Line ("Failed:       " & Natural'Image (Total - Passed));

   --  Print professional color-coded summary and get exit status
   declare
      Exit_Code : constant Integer :=
        Test_Framework.Print_Category_Summary ("E2E TESTS", Total, Passed);
   begin
      Set_Exit_Status (if Exit_Code = 0 then Success else Failure);
   end;

end E2E_Runner;
