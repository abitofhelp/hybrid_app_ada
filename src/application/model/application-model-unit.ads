pragma Ada_2022;
--  =========================================================================
--  Application.Model.Unit - Re-export of Domain.Unit (DEPRECATED)
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--  See LICENSE file in the project root.
--
--  Purpose:
--    DEPRECATED: This package exists for backward compatibility only.
--    New code should use Domain.Unit directly.
--
--    The Unit type has been moved to Domain.Unit where it belongs
--    architecturally (Domain has zero dependencies, any layer can use it).
--
--  Migration:
--    Replace: with Application.Model.Unit;
--    With:    with Domain.Unit;
--
--  See Also:
--    Domain.Unit - Canonical location for Unit type
--  =========================================================================

with Domain.Unit;

package Application.Model.Unit
  with Preelaborate
is

   --  Re-export Domain.Unit types for backward compatibility
   subtype Unit is Domain.Unit.Unit;

   Unit_Value : Domain.Unit.Unit renames Domain.Unit.Unit_Value;

end Application.Model.Unit;
