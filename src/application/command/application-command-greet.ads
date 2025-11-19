pragma Ada_2022;
--  =========================================================================
--  Application.Command.Greet - DTO for greet use case
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--  See LICENSE file in the project root.
--
--  Purpose:
--    Data Transfer Object (DTO) for the greet use case. DTOs cross
--    architectural boundaries and should be simple, serializable data
--    structures with no business logic.
--
--  Educational Notes:
--    - No business logic in DTOs
--    - DTOs are different from domain entities
--    - This separates external API from internal domain model
--    - Crosses boundary: Presentation -> Application
--
--  Mapping to Go:
--    Go: application/port/greet_command.go
--    type GreetCommand struct { Name string }
--
--  See Also:
--    Domain.Value_Object.Person - Domain entity (different from DTO)
--  =========================================================================

with Ada.Strings.Bounded;

package Application.Command.Greet
  with Preelaborate
is

   --  Maximum name length for DTO (matches domain constraint)
   Max_Name_Length : constant := 100;

   --  Bounded string for name in DTO
   package Name_Strings is new
     Ada.Strings.Bounded.Generic_Bounded_Length (Max => Max_Name_Length);

   --  Predicate function for valid names
   --  Ensures name is not empty (checked at runtime when subtype is used)
   --  Note: Max length is enforced by Bounded_String itself
   function Is_Valid_Name (S : Name_Strings.Bounded_String) return Boolean
   is (Name_Strings.Length (S) > 0)
   with Inline;

   --  Subtype with predicate to ensure names are always valid (non-empty)
   --  The Predicate aspect will check this constraint at runtime
   subtype Valid_Name is Name_Strings.Bounded_String
   with Dynamic_Predicate => Is_Valid_Name (Valid_Name);

   --  ========================================================================
   --  Greet_Command DTO
   --  ========================================================================

   --  Data Transfer Object for greet use case.
   --  Simple data structure that crosses presentation -> application
   --  boundary. Uses Valid_Name subtype to ensure name is never empty

   type Greet_Command is record
      Name : Valid_Name;
   end record;

   --  Helper function to create DTO from String
   --  Precondition ensures name is valid before construction
   function Create (Name : String) return Greet_Command
   with Pre => Name'Length > 0 and Name'Length <= Max_Name_Length;

   --  Helper function to extract name as String
   function Get_Name (Cmd : Greet_Command) return String;

end Application.Command.Greet;
