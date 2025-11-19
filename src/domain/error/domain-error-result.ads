pragma Ada_2022;
--  =========================================================================
--  Domain.Error.Result - Generic Result monad for error handling
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--
--  Purpose:
--    Result[T] monad for railway-oriented programming. This is the core
--    functional error handling primitive for the entire application.
--
--  Architecture Notes:
--    - Generic over success type T
--    - Uses Domain.Error.Error_Type for all errors
--    - Pure domain implementation (no external dependencies)
--    - Enables functional composition and error propagation
--
--  Usage:
--    with Domain.Error.Result;
--
--    package String_Result is new Domain.Error.Result.Generic_Result
--      (T => String);
--
--    R : String_Result.Result := String_Result.Ok ("success");
--    if String_Result.Is_Ok (R) then
--       Value := String_Result.Value (R);
--    end if;
--
--  Design Pattern:
--    Railway-Oriented Programming:
--    - Ok track: Successful computation continues
--    - Error track: Error propagates (short-circuit)
--    - Forces explicit error handling at compile time
--
--  See Also:
--    Domain.Error - Error types used by this monad
--  =========================================================================

package Domain.Error.Result
  with Preelaborate
is

   --  ========================================================================
   --  Generic Result Type: Either monad for T or Error_Type
   --  ========================================================================

   --  This generic package must be instantiated for each success type T
   --  Example: package String_Result is new Generic_Result (T => String);
   --
   --  Flow:
   --  1. Operations that can fail return Result[T] instead of raising
   --  2. Caller checks Is_Ok/Is_Error before extracting value
   --  3. Forces explicit error handling at compile time

   generic
      type T is private;  --  The success value type
   package Generic_Result is

      --  Opaque result type - internal representation hidden
      type Result is private;

      --  Constructors
      function Ok (Value : T) return Result
      with Inline;

      function Error (Kind : Error_Kind; Message : String) return Result
      with Inline;

      --  Query functions
      function Is_Ok (Self : Result) return Boolean
      with Inline;

      function Is_Error (Self : Result) return Boolean
      with Inline;

      --  Value extraction (caller must check Is_Ok/Is_Error first)
      function Value (Self : Result) return T
      with Pre => Is_Ok (Self), Inline;

      function Error_Info (Self : Result) return Error_Type
      with Pre => Is_Error (Self), Inline;

   private

      --  Internal representation: discriminated record (tagged union pattern)
      type Result_State is (Ok_State, Error_State);

      type Result (State : Result_State := Error_State) is record
         case State is
            when Ok_State =>
               Success_Value : T;

            when Error_State =>
               Error_Value : Error_Type;
         end case;
      end record;

   end Generic_Result;

end Domain.Error.Result;
