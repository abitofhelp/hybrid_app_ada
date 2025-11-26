pragma Ada_2022;
--  =========================================================================
--  Bootstrap - Composition root package hierarchy
--  =========================================================================
--  Copyright (c) 2025 Michael Gardner, A Bit of Help, Inc.
--  SPDX-License-Identifier: BSD-3-Clause
--  See LICENSE file in the project root.
--
--  Purpose:
--    Parent package for all bootstrap/composition root packages.
--    This package hierarchy contains the code that wires all layers together.
--
--  Architecture Notes:
--    - Bootstrap is the ONLY place where all layers meet
--    - Bootstrap depends on ALL layers (special case)
--    - All other layers follow the dependency rule (pointing inbound)
--    - Bootstrap performs static dependency injection via generics
--
--  Mapping to Go:
--    Go: bootstrap/ directory
--    Ada: bootstrap/ directory with Bootstrap parent package
--
--  See Also:
--    Bootstrap.CLI - CLI application composition root
--  =========================================================================

package Bootstrap
  with Preelaborate
is

end Bootstrap;
