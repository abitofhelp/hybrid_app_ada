pragma Ada_2022;
--  =========================================================================
--  Presentation.CLI.Command.Greet - Implementation of greet command
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--  =========================================================================

with Ada.Command_Line;
with Ada.Text_IO;
with Application.Error;

package body Presentation.CLI.Command.Greet is

   use Ada.Command_Line;
   use Ada.Text_IO;

   ---------
   -- Run --
   ---------

   function Run return Integer is
      Arg_Count : constant Natural := Ada.Command_Line.Argument_Count;
   begin
      --  Check if user provided exactly one argument (the name)
      if Arg_Count /= 1 then
         Put_Line ("Usage: " & Command_Name & " <name>");
         Put_Line ("Example: " & Command_Name & " Alice");
         return 1;  --  Exit code 1 indicates error

      end if;

      --  Extract the name from command-line arguments
      declare
         Name : constant String := Argument (1);

         --  Create DTO for crossing presentation -> application
         --  boundary
         Cmd : constant Application.Command.Greet.Greet_Command :=
           Application.Command.Greet.Create (Name);

         --  Call the use case (injected via generic parameter)
         --  This is the key architectural boundary:
         --  Presentation -> Application (through input port)
         Result :
           constant Application.Port.Outward.Writer.Unit_Result.Result :=
             Execute_Greet_UseCase (Cmd);
      begin
         --  Handle the result from the use case
         if Application.Port.Outward.Writer.Unit_Result.Is_Ok (Result) then
            --  Success! Greeting was displayed via console port
            --  Use case already wrote to console, just exit cleanly
            return 0;  --  Exit code 0 indicates success

         else
            --  Use case failed - display error to user
            declare
               Error_Info    : constant Application.Error.Error_Type :=
                 Application.Port.Outward.Writer.Unit_Result.Error_Info
                   (Result);
               Error_Message : constant String :=
                 Application.Error.Error_Strings.To_String
                   (Error_Info.Message);
            begin
               --  Display user-friendly error message
               Put_Line ("Error: " & Error_Message);

               --  Add detailed error handling based on Error_Kind
               case Error_Info.Kind is
                  when Application.Error.Validation_Error     =>
                     Put_Line ("Please provide a valid name.");

                  when Application.Error.Infrastructure_Error =>
                     Put_Line ("A system error occurred.");
               end case;

               return 1;  --  Exit code 1 indicates error
            end;
         end if;
      end;
   end Run;

end Presentation.CLI.Command.Greet;
