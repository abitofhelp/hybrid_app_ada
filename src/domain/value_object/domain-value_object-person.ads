pragma Ada_2022;
--  =========================================================================
--  Domain.Value_Object.Person - Person value object for the greeter domain
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--  See LICENSE file in the project root.
--
--  Purpose:
--    Defines the Person value object representing a person's name.
--    Value object: immutable, validated at construction, uses bounded strings.
--    Returns Result type for validation (no exceptions).
--
--  Usage:
--    Result := Create ("Alice");
--    if Person_Result.Is_Ok (Result) then
--       Person := Person_Result.Value (Result);
--       Message := Greeting_Message (Person);
--    end if;
--
--  Design Notes:
--    - Value object pattern: immutable after creation
--    - Smart constructor (Create) enforces validation
--    - Uses bounded strings (memory safe, no heap allocation)
--    - Returns Result type (no exceptions)
--    - Pure domain logic - ZERO external dependencies
--
--  See Also:
--    Domain.Error.Result - Result type for error handling
--  =========================================================================

with Ada.Strings.Bounded;
with Domain.Error.Result;

package Domain.Value_Object.Person
  with Preelaborate
is

   --  Maximum name length (reasonable limit for person names)
   Max_Name_Length : constant := 100;

   --  Bounded string for name storage (no dynamic allocation)
   package Name_Strings is new
     Ada.Strings.Bounded.Generic_Bounded_Length (Max => Max_Name_Length);

   --  ========================================================================
   --  Person Value Object
   --  ========================================================================

   --  Person Value Object (public record - validation enforced via
   --  smart constructor). We expose the record publicly to allow generic
   --  instantiation. Clients should ONLY create via Create function to
   --  ensure validation.
   type Person is record
      Name_Value : Name_Strings.Bounded_String;
   end record;

   --  Instantiate Result type for Person
   package Person_Result is new
     Domain.Error.Result.Generic_Result (T => Person);

   --  Validation function - used internally by Create
   function Is_Valid_Person (P : Person) return Boolean;

   --  ========================================================================
   --  Smart Constructor: Validates and creates Person
   --  ========================================================================

   --  This is the RECOMMENDED way to create a Person (validates input)
   --  Validation rules:
   --   1. Name must not be empty
   --   2. Name must not exceed Max_Name_Length
   --   3. Name is trimmed (leading/trailing whitespace removed)
   --
   --  Returns: Result[Person] - Ok if valid, Error if validation fails
   function Create (Name : String) return Person_Result.Result
   with
     Post =>
       (if Name'Length = 0 or Name'Length > Max_Name_Length
        then Person_Result.Is_Error (Create'Result)
        else
          (Person_Result.Is_Ok (Create'Result)
           and then Name_Strings.Length
                      (Person_Result.Value (Create'Result).Name_Value)
                    > 0));

   --  ========================================================================
   --  Accessors
   --  ========================================================================

   --  Get the string representation of the person's name
   --  Contract: Result is never empty (enforced by Create validation)
   function Get_Name (Self : Person) return String
   with
     Inline,
     Post =>
       Get_Name'Result'Length > 0
       and Get_Name'Result'Length <= Max_Name_Length;

   --  Generate a greeting message for this person
   --  Pure domain logic - no side effects
   --  Contract: Result always starts with "Hello, " and ends with "!"
   function Greeting_Message (Self : Person) return String
   with
     Inline,
     Post =>
       Greeting_Message'Result'Length > 9
       and then Greeting_Message'Result
                  (Greeting_Message'Result'First
                   .. Greeting_Message'Result'First + 6)
                = "Hello, "
       and then Greeting_Message'Result (Greeting_Message'Result'Last) = '!';

end Domain.Value_Object.Person;
