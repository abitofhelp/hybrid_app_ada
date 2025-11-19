pragma Ada_2022;
--  =========================================================================
--  Application.Model.Unit - Unit type for Result with no meaningful value
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--  See LICENSE file in the project root.
--
--  Purpose:
--    Unit type for operations that return Result but no meaningful value.
--    Represents "void" or "no value" in the Result monad. Used for
--    operations with side effects (like Console.Write).
--
--  Architecture Notes:
--    - Application layer depends on Domain only
--    - Allows consistent Result[Unit] return type instead of procedures
--    - Similar to () in Rust, void in C, or Unit in Scala
--
--  Usage:
--    function Write (Message : String) return Unit_Result.Result;
--    Result := Write ("Hello");
--    if Unit_Result.Is_Ok (Result) then...
--
--  See Also:
--    Domain.Result - Result type definition
--  =========================================================================

package Application.Model.Unit
  with Preelaborate
is

   --  ========================================================================
   --  Unit Type: Represents "no meaningful value"
   --  ========================================================================

   --  Used when we need Result[T] but T carries no information
   type Unit is null record;

   --  Singleton instance for convenience
   Unit_Value : constant Unit := (null record);

end Application.Model.Unit;
