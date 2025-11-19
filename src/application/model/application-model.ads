pragma Ada_2022;
--  =========================================================================
--  Application.Model - Parent package for application models/types
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--
--  Purpose:
--    Parent package for application-specific model types and DTOs.
--    Contains types that cross architectural boundaries or are used
--    across multiple use cases.
--
--  Architecture Notes:
--    - Part of the APPLICATION layer
--    - Depends on Domain layer only
--    - Contains cross-cutting application types (like Unit)
--
--  See Also:
--    Application.Model.Unit - Unit type for Result with no value
--  =========================================================================

package Application.Model
  with Pure
is

end Application.Model;
