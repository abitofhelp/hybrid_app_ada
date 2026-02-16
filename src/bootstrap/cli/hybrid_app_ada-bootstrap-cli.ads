pragma Ada_2022;
--  =========================================================================
--  Hybrid_App_Ada.Bootstrap.CLI - CLI application composition root
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--
--  Purpose:
--    Composition root for the CLI application. This is where ALL layers
--    are wired together via generic instantiation (static DI).
--
--  Architecture Notes:
--    - This is the ONLY place where all layers meet
--    - Depends on: Hybrid_App_Ada.Domain, Hybrid_App_Ada.Application, Hybrid_App_Ada.Infrastructure, Hybrid_App_Ada.Presentation
--    - Performs STATIC DEPENDENCY INJECTION via generic instantiation
--    - Zero runtime overhead - all wiring resolved at compile time
--
--  Wiring Flow:
--    1. Hybrid_App_Ada.Infrastructure.Console_Writer implements Writer port signature
--    2. Instantiate Hybrid_App_Ada.Application.Usecase.Greet with Console_Writer
--    3. Instantiate Hybrid_App_Ada.Presentation.Adapter.CLI.Command.Greet with use case
--    4. Execute the wired command
--
--  Design Pattern:
--    Composition Root pattern - centralized dependency wiring.
--    All dependencies flow inbound, bootstrap connects them.
--
--  See Also:
--    Hybrid_App_Ada.Bootstrap - Parent package
--    Hybrid_App_Ada.Domain, Hybrid_App_Ada.Application, Hybrid_App_Ada.Infrastructure, Hybrid_App_Ada.Presentation - Layers being wired
--  =========================================================================

package Hybrid_App_Ada.Bootstrap.CLI is

   --  =====================================================================
   --  Run: Composition root entry point
   --  =====================================================================
   --
   --  Responsibilities:
   --  1. Instantiate all generic packages (Writer Port, Use Case, Command)
   --  2. Wire dependencies together (static dependency injection)
   --  3. Execute the CLI application
   --  4. Return exit code to caller
   --
   --  Returns:
   --    Integer exit code (0 = success, non-zero = error)

   function Run return Integer;

end Hybrid_App_Ada.Bootstrap.CLI;
