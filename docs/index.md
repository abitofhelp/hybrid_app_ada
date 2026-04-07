# Hybrid Application Documentation

**Version:** 2.0.1  
**Date:** December 10, 2025  
**SPDX-License-Identifier:** BSD-3-Clause<br>
**License File:** See the LICENSE file in the project root<br>
**Copyright:** © 2025 Michael Gardner, A Bit of Help, Inc.<br>  
**Status:** Released  

---

## Overview

Shared documentation for hybrid application projects implementing hexagonal architecture patterns with functional error handling in Ada 2022 and Go.

**Key Capabilities:**

- DDD/Clean/Hexagonal architecture (5-layer) demonstration
- Functional error handling via Result monad
- Domain layer designed with SPARK compatibility in mind (not yet proven)
- Static dependency injection via generics (zero runtime overhead)
- Cross-platform: Linux, macOS, BSD, Windows, Embedded

---

## Quick Navigation

### Getting Started

- **[Quick Start Guide](quick_start.md)** - Installation, first build, and running the application
- **[Build Profiles](guides/build_profiles.md)** - Configure for different targets

### Formal Documentation

- **[Software Requirements Specification](formal/software_requirements_specification.md)** - Functional and non-functional requirements
- **[Software Design Specification](formal/software_design_specification.md)** - Architecture and detailed design
- **[Software Test Guide](formal/software_test_guide.md)** - Testing strategy and execution

### Developer Guides

- **[Architecture Enforcement](guides/architecture_enforcement.md)** - Layer dependency rules
- **[Error Handling Strategy](guides/error_handling_strategy.md)** - Result monad patterns

---

## Architecture

Hybrid applications implement a 5-layer hexagonal architecture:

```text
┌─────────────────────────────────────────────────────────┐
│                       Bootstrap                          │
│           (Composition Root - wires everything)          │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                      Presentation                        │
│       CLI Adapter (driving - calls Application)          │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                      Application                         │
│   Use Cases + Inbound/Outbound Ports + Commands          │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                    Infrastructure                        │
│     Driven Adapters (implements outbound ports)          │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                        Domain                            │
│   Entities + Value Objects + Business Rules (PURE)       │
└─────────────────────────────────────────────────────────┘
```

**Design Principles:**

- Dependencies flow inward (toward Domain)
- Domain layer has zero external dependencies
- Presentation accesses Application only (never Domain directly)
- Infrastructure implements ports defined in Application
- Bootstrap wires all layers at composition root
- Static DI via generics (compile-time resolution)

---

## Diagrams

### Language-Agnostic

- [Application Architecture](diagrams/application_architecture.svg)

### Ada Examples

- [API Re-export Pattern (Ada)](diagrams/ada/api_reexport_pattern_ada.svg)
- [Application Error Pattern (Ada)](diagrams/ada/application_error_pattern_ada.svg)
- [Dynamic Static Dispatch (Ada)](diagrams/ada/dynamic_static_dispatch_ada.svg)
- [Error Handling Flow (Ada)](diagrams/ada/error_handling_flow_ada.svg)
- [Package Structure (Ada)](diagrams/ada/package_structure_ada.svg)
- [Static Dispatch (Ada)](diagrams/ada/static_dispatch_ada.svg)
- [Three Package API (Ada)](diagrams/ada/three_package_api_ada.svg)

### Go Examples

- [API Re-export Pattern (Go)](diagrams/go/api_reexport_pattern_go.svg)
- [Application Error Pattern (Go)](diagrams/go/application_error_pattern_go.svg)
- [Dynamic Static Dispatch (Go)](diagrams/go/dynamic_static_dispatch_go.svg)
- [Error Handling Flow (Go)](diagrams/go/error_handling_flow_go.svg)
- [Package Structure (Go)](diagrams/go/package_structure_go.svg)
- [Static Dispatch (Go)](diagrams/go/static_dispatch_go.svg)
- [Three Package API (Go)](diagrams/go/three_package_api_go.svg)

---

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| **Linux** | Full | Fully supported |
| **macOS** | Full | Primary development platform |
| **BSD** | Full | Fully supported |
| **Windows** | Full | Windows 11+ |
| **Embedded** | Stub | Custom adapter required |

---

## What's New in v2.0.0

**Breaking Changes:**
- Upgraded to functional ^3.0.0 with new Result combinator APIs

**New Features:**
- Windows CI support (GitHub Actions)
- Result combinators: Bimap, Ensure, With_Context, Fallback, Recover, Tap
- Enhanced error handling capabilities

**Test Coverage:**
- 85 unit tests
- 16 integration tests
- 8 e2e tests
- **Total: 109 tests** (all passing)

---

## Need Help?

- Check the [Quick Start Guide](quick_start.md) for common issues
- Review the [Software Test Guide](formal/software_test_guide.md) for testing help
- See [Error Handling Strategy](guides/error_handling_strategy.md) for Result monad usage
- See [Architecture Enforcement](guides/architecture_enforcement.md) for layer rules

---

**License:** BSD-3-Clause  
**Copyright:** © 2025 Michael Gardner, A Bit of Help, Inc.  
