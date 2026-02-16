pragma Ada_2022;
--  =========================================================================
--  Hybrid_App_Ada.Presentation.Adapter.CLI - Parent package for CLI presentation adapter
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--
--  Purpose:
--    Parent package for command-line interface (CLI) presentation logic.
--    Contains CLI-specific controllers and command handlers.
--
--  Architecture Notes:
--    - CLI-specific presentation logic
--    - Handles: Command-line parsing, user output formatting
--    - Calls: Hybrid_App_Ada.Application use cases
--    - Returns: Exit codes for shell
--
--  Design Pattern:
--    Controller pattern - translates CLI interactions into use case calls.
--
--  See Also:
--    Hybrid_App_Ada.Presentation.Adapter.CLI.Command - CLI command handlers
--  =========================================================================

package Hybrid_App_Ada.Presentation.Adapter.CLI
  with Preelaborate
is

end Hybrid_App_Ada.Presentation.Adapter.CLI;
