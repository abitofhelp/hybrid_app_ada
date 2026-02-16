pragma Ada_2022;
--  =========================================================================
--  Greeter_Main - Main Program Entry Point
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--
--  Purpose:
--    Main program entry point for the greeter CLI application.
--    Delegates all work to Hybrid_App_Ada.Bootstrap.CLI composition root.
--
--  Architecture:
--    Hybrid DDD/Clean/Hexagonal Architecture with 5 layers:
--    1. Hybrid_App_Ada.Domain - Pure business logic (innermost, zero dependencies)
--    2. Hybrid_App_Ada.Application - Use cases and ports (depends on Hybrid_App_Ada.Domain only)
--    3. Hybrid_App_Ada.Infrastructure - Adapters implementing output ports
--    4. Hybrid_App_Ada.Presentation - User interfaces (CLI, Web, etc.)
--    5. Hybrid_App_Ada.Bootstrap - Composition root wiring all layers together
--
--  Design Principles:
--    - Dependency Inversion: Dependencies point inbound toward Hybrid_App_Ada.Domain
--    - Static DI: Generic instantiation for zero-runtime-cost injection
--    - Railway-Oriented Programming: Result monad for error handling
--    - Ports & Adapters: Hybrid_App_Ada.Application defines interfaces,Hybrid_App_Ada.Infrastructure conform
--
--  Main Responsibilities:
--    - Entry point (kept minimal)
--    - Delegates to Hybrid_App_Ada.Bootstrap.CLI.Run
--    - Sets OS exit code
--
--  See Also:
--    Hybrid_App_Ada.Bootstrap.CLI - Composition root that wires all layers
--  =========================================================================

with Ada.Command_Line;
with Hybrid_App_Ada.Bootstrap.CLI;

procedure Greeter_Main is

   --  Exit code to return to OS (0 = success, non-zero = error)
   Exit_Code : Integer;

begin
   --  ======================================================================
   --  Hybrid_App_Ada.Bootstrap and run the CLI application
   --  ======================================================================

   --  Call Hybrid_App_Ada.Bootstrap.CLI to:
   --  1. Instantiate all generic packages (dependency injection)
   --  2. Wire all layers together
   --  3. Execute the application
   --  4. Return exit code

   Exit_Code := Hybrid_App_Ada.Bootstrap.CLI.Run;

   --  ======================================================================
   --  Set the OS exit code and return
   --  ======================================================================

   Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Exit_Status (Exit_Code));

end Greeter_Main;
