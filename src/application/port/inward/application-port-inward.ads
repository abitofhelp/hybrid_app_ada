pragma Ada_2022;
--  =========================================================================
--  Application.Port.Inward - Parent package for inward/input ports
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--
--  Purpose:
--    Parent package for inward-facing ports (input ports).
--    Inward ports define how external actors invoke the application.
--    In this project, use cases ARE the inward ports.
--
--  Architecture Notes:
--    - Inward ports = Application's PUBLIC API
--    - Called by: Presentation layer (CLI, Web, API)
--    - Examples: Execute use case functions
--    - Flow: Presentation → Inward Port (Use Case) → Domain
--
--  Design Pattern:
--    Use cases themselves serve as inward ports, accepting DTOs
--    (commands) from the presentation layer.
--
--  See Also:
--    Application.Usecase - Use cases implement inward ports
--  =========================================================================

package Application.Port.Inward
  with Pure
is

end Application.Port.Inward;
