pragma Ada_2022;
--  =========================================================================
--  Presentation.CLI.Command.Greet - CLI command for greet use case
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--  See LICENSE file in the project root.
--
--  Purpose:
--    Presentation layer command handler for greet use case.
--    This is the PRESENTATION layer - the outer shell handling UI concerns.
--
--  Architecture Notes:
--    - Handles user interface concerns (CLI args, output formatting)
--    - Calls APPLICATION layer use cases (through input ports)
--    - Does NOT depend on Infrastructure or Domain directly
--    - Does NOT contain business logic (delegates to use case)
--
--  Dependency Flow:
--    Greet_Command -> Application.Greet_UseCase
--    (calls use case)
--
--  Generic Parameter for Dependency Inversion:
--    - Takes Execute function from use case as parameter
--    - Bootstrap wires concrete use case instance to this command
--    - Command doesn't know about Infrastructure
--
--  Mapping to Go:
--    Go: presentation/cli/greet_command.go (GreetCommand struct)
--    Ada: presentation/presentation-greet_command.ads (generic package)
--
--  Why Generic?
--    - Allows static dispatch (zero runtime overhead)
--    - Maintains dependency direction (Presentation ->
--      Application)
--
--  See Also:
--    Application.Usecase.Greet - Use case this command calls
--  =========================================================================

with Application.Port.Outward.Writer;
with Application.Command.Greet;

--  ========================================================================
--  Generic Greet Command Package
--  ========================================================================

--  Takes the use case Execute function as a generic parameter.
--  This is the APPLICATION INPUT PORT pattern:
--  - Presentation calls Application through the input port (Execute)
--  - Application doesn't know about Presentation

generic
   with
     function Execute_Greet_UseCase
       (Cmd : Application.Command.Greet.Greet_Command)
        return Application.Port.Outward.Writer.Unit_Result.Result;
package Presentation.CLI.Command.Greet is

   --  ======================================================================
   --  Run: Execute the CLI controller logic
   --  ======================================================================

   --  Responsibilities:
   --  1. Parse command-line arguments
   --  2. Extract the name parameter
   --  3. Create GreetCommand DTO
   --  4. Call the use case with the DTO
   --  5. Handle the result and display appropriate messages
   --  6. Return exit code (0 = success, non-zero = error)
   --
   --  CLI Usage: greeter <name>
   --  Example: ./greeter Alice
   --
   --  This is where presentation concerns live:
   --  - CLI argument parsing
   --  - User-facing error messages
   --  - Exit code mapping

   function Run return Integer;

end Presentation.CLI.Command.Greet;
