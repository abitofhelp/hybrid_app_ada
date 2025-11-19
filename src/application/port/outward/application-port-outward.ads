pragma Ada_2022;
--  =========================================================================
--  Application.Port.Outward - Parent package for outward/output ports
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--
--  Purpose:
--    Parent package for outward-facing ports (output ports).
--    Outward ports define what external services the application needs.
--
--  Architecture Notes:
--    - Outward ports = Application's REQUIRED dependencies
--    - Implemented by: Infrastructure layer (adapters)
--    - Application DEFINES the interface it needs
--    - Infrastructure CONFORMS to that interface
--    - This achieves DEPENDENCY INVERSION (dependencies point inward)
--
--  Design Pattern:
--    - Application: "I need something that can Write(message)"
--    - Infrastructure: "I have a ConsoleWriter that implements Write"
--    - Bootstrap: Wires them together via generic instantiation
--
--  See Also:
--    Application.Port.Outward.Writer - Writer output port
--    Infrastructure.Adapter - Implementations of output ports
--  =========================================================================

package Application.Port.Outward
  with Pure
is

end Application.Port.Outward;
