pragma Ada_2022;
--  =========================================================================
--  Hybrid_App_Ada.Presentation - Root package for presentation layer
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--
--  Purpose:
--    Root package for the presentation layer containing user interfaces
--    (CLI, Web, API, etc.). This is the OUTERMOST layer users interact with.
--
--  Architecture Notes:
--    - Part of the PRESENTATION layer (outermost)
--    - Handles UI concerns: argument parsing, formatting, error display
--    - Calls application layer use cases (through inbound ports)
--    - Does NOT contain business logic (delegates to application)
--    - Does NOT depend on Hybrid_App_Ada.Infrastructure (only Hybrid_App_Ada.Application)
--
--  Design Pattern:
--    Hybrid_App_Ada.Presentation layer in Clean Architecture / Hexagonal Architecture.
--    Thin layer that translates user actions into use case calls.
--
--  See Also:
--    Hybrid_App_Ada.Presentation.Adapter - Driving adapters (CLI, REST, etc.)
--    Hybrid_App_Ada.Presentation.Adapter.CLI - Command-line interface implementation
--    Hybrid_App_Ada.Application.Usecase - Use cases called by presentation
--  =========================================================================

package Hybrid_App_Ada.Presentation
  with Preelaborate
is

end Hybrid_App_Ada.Presentation;
