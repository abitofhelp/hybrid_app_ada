pragma Ada_2022;
--  =========================================================================
--  Hybrid_App_Ada.Application.Port.Inbound - Parent package for inbound/input ports
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--
--  Purpose:
--    Parent package for inbound-facing ports (input ports).
--    Inbound ports define how external actors invoke the application.
--    In this project, use cases ARE the inbound ports.
--
--  Architecture Notes:
--    - Inbound ports = Hybrid_App_Ada.Application's PUBLIC API
--    - Called by: Hybrid_App_Ada.Presentation layer (CLI, Web, API)
--    - Examples: Execute use case functions
--    - Flow: Hybrid_App_Ada.Presentation → Inbound Port (Use Case) → Hybrid_App_Ada.Domain
--
--  Design Pattern:
--    Use cases themselves serve as inbound ports, accepting DTOs
--    (commands) from the presentation layer.
--
--  See Also:
--    Hybrid_App_Ada.Application.Usecase - Use cases implement inbound ports
--  =========================================================================

package Hybrid_App_Ada.Application.Port.Inbound
  with Pure
is

end Hybrid_App_Ada.Application.Port.Inbound;
