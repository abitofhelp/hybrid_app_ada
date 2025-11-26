pragma Ada_2022;
--  =========================================================================
--  Presentation.Adapter.CLI - Parent package for CLI presentation adapter
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
--    - Calls: Application use cases
--    - Returns: Exit codes for shell
--
--  Design Pattern:
--    Controller pattern - translates CLI interactions into use case calls.
--
--  See Also:
--    Presentation.Adapter.CLI.Command - CLI command handlers
--  =========================================================================

package Presentation.Adapter.CLI
  with Preelaborate
is

end Presentation.Adapter.CLI;
