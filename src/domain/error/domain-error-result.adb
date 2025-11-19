pragma Ada_2022;
--  =========================================================================
--  Domain.Error.Result - Implementation of Result monad
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--  =========================================================================

package body Domain.Error.Result is

   package body Generic_Result is

      ----------
      -- Ok --
      ----------

      function Ok (Value : T) return Result is
      begin
         return (State => Ok_State, Success_Value => Value);
      end Ok;

      -----------
      -- Error --
      -----------

      function Error (Kind : Error_Kind; Message : String) return Result is
         use Error_Strings;
      begin
         return
           (State       => Error_State,
            Error_Value =>
              (Kind => Kind, Message => To_Bounded_String (Message)));
      end Error;

      -----------
      -- Is_Ok --
      -----------

      function Is_Ok (Self : Result) return Boolean is
      begin
         return Self.State = Ok_State;
      end Is_Ok;

      --------------
      -- Is_Error --
      --------------

      function Is_Error (Self : Result) return Boolean is
      begin
         return Self.State = Error_State;
      end Is_Error;

      -----------
      -- Value --
      -----------

      function Value (Self : Result) return T is
      begin
         return Self.Success_Value;
      end Value;

      ----------------
      -- Error_Info --
      ----------------

      function Error_Info (Self : Result) return Error_Type is
      begin
         return Self.Error_Value;
      end Error_Info;

   end Generic_Result;

end Domain.Error.Result;
