pragma Ada_2022;
--  =========================================================================
--  Presentation.CLI.Command - Parent package for CLI command handlers
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--
--  Purpose:
--    Parent package for CLI command handler implementations.
--    Each command corresponds to a user action (e.g., greet).
--
--  Architecture Notes:
--    - Command handlers receive use cases via generic instantiation
--    - Responsibilities:
--      1. Parse CLI arguments
--      2. Create command DTOs
--      3. Call use case
--      4. Format output for user
--      5. Return exit code
--
--  Design Pattern:
--    Command handler pattern - each CLI command is a separate handler
--    that coordinates between CLI args and use cases.
--
--  See Also:
--    Presentation.CLI.Command.Greet - Greet command handler
--  =========================================================================

package Presentation.CLI.Command
  with Preelaborate
is

end Presentation.CLI.Command;
