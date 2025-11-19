pragma Ada_2022;
--  =========================================================================
--  Bootstrap.CLI - Implementation of CLI bootstrap
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--  =========================================================================

--  Import all layers
with Infrastructure.Adapter.Console_Writer;
with Application.Port.Outward.Writer;
with Application.Usecase.Greet;
with Presentation.CLI.Command.Greet;

package body Bootstrap.CLI is

   ---------
   -- Run --
   ---------

   function Run return Integer is

      --  =====================================================================
      --  Step 1: Instantiate Writer Port with Infrastructure implementation
      --  =====================================================================

      --  DEPENDENCY INVERSION in action:
      --  - Application.Port.Outward.Writer defines the interface (port)
      --  - Infrastructure.Adapter.Console_Writer provides implementation
      --  - We wire them together here in the composition root

      package Writer_Port_Instance is new
        Application.Port.Outward.Writer.Generic_Writer
          (Write => Infrastructure.Adapter.Console_Writer.Write);

      --  =====================================================================
      --  Step 2: Instantiate Use Case with Writer Port
      --  =====================================================================

      --  The use case receives the Write function through generic
      --  instantiation. This is STATIC DISPATCH - resolved at compile time.

      package Greet_UseCase_Instance is new
        Application.Usecase.Greet
          (Writer => Writer_Port_Instance.Write_Message);

      --  =====================================================================
      --  Step 3: Instantiate Greet Command with Use Case
      --  =====================================================================

      --  Wire the Presentation layer to the Application layer.
      --  The command receives the Execute function from the use case.
      --  Again, static dispatch - zero runtime overhead.

      package Greet_Command_Instance is new
        Presentation.CLI.Command.Greet
          (Execute_Greet_UseCase => Greet_UseCase_Instance.Execute);

   begin
      --  =====================================================================
      --  Step 4: Run the application and return exit code
      --  =====================================================================

      --  Call the Greet Command to start the application.
      --  The command will:
      --  1. Parse command-line arguments
      --  2. Create GreetCommand DTO
      --  3. Call the use case (which calls domain and console port)
      --  4. Return an exit code
      --
      --  Flow of data through the architecture:
      --  1. User runs: ./greeter Alice
      --  2. Greet_Command extracts "Alice" from args
      --  3. Greet_Command creates GreetCommand DTO
      --  4. Greet_Command calls Use_Case.Execute(GreetCommand)
      --  5. Use_Case extracts name from DTO
      --  6. Use_Case calls Domain.Value_Object.Person.Create("Alice")
      --     which validates the name
      --  7. Use_Case gets greeting message from Person
      --  8. Use_Case calls Writer_Port.Write("Hello, Alice!")
      --  9. Writer_Port routes to Console_Writer.Write
      --  10. Console_Writer calls Ada.Text_IO.Put_Line
      --  11. Result flows back through layers:
      --      Writer -> Port -> Use_Case -> Command -> Bootstrap
      --  12. Bootstrap returns exit code to Main

      return Greet_Command_Instance.Run;

   end Run;

end Bootstrap.CLI;
