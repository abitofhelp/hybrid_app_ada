pragma Ada_2022;
--  =========================================================================
--  Hybrid_App_Ada.Application.Port.Outbound - Parent package for outbound/output ports
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--
--  Purpose:
--    Parent package for outbound-facing ports (output ports).
--    Outbound ports define what external services the application needs.
--
--  Architecture Notes:
--    - Outbound ports = Hybrid_App_Ada.Application's REQUIRED dependencies
--    - Implemented by: Hybrid_App_Ada.Infrastructure layer (adapters)
--    - Hybrid_App_Ada.Application DEFINES the interface it needs
--    - Hybrid_App_Ada.Infrastructure CONFORMS to that interface
--    - This achieves DEPENDENCY INVERSION (dependencies point inward)
--
--  Design Pattern:
--    - Hybrid_App_Ada.Application: "I need something that can Write(message)"
--    - Hybrid_App_Ada.Infrastructure: "I have a ConsoleWriter that implements Write"
--    - Hybrid_App_Ada.Bootstrap: Wires them together via generic instantiation
--
--  See Also:
--    Hybrid_App_Ada.Application.Port.Outbound.Writer - Writer output port
--    Hybrid_App_Ada.Infrastructure.Adapter - Implementations of output ports
--  =========================================================================

package Hybrid_App_Ada.Application.Port.Outbound
  with Pure
is

end Hybrid_App_Ada.Application.Port.Outbound;
