# Hybrid_App_Ada Documentation Index

**Version:** 1.0.0<br>
**Date:** November 29, 2025<br>
**SPDX-License-Identifier:** BSD-3-Clause<br>
**License File:** See the LICENSE file in the project root<br>
**Copyright:** © 2025 Michael Gardner, A Bit of Help, Inc.<br>
**Status:** Released

---

## Welcome

Welcome to **Hybrid_App_Ada**, a professional Ada 2022 application starter demonstrating hybrid DDD/Clean/Hexagonal architecture with functional programming principles.

This project showcases:
- **5-Layer Hexagonal Architecture** (Domain, Application, Infrastructure, Presentation, Bootstrap)
- **Static Dispatch Dependency Injection** via Ada generics (zero runtime overhead)
- **Railway-Oriented Programming** with Result monads (no exceptions across boundaries)
- **Presentation Isolation** pattern (Domain is shareable; Presentation cannot access Domain directly)

---

## Quick Navigation

### Getting Started

- **[Quick Start Guide](quick_start.md)** - Get up and running in minutes
  - Installation instructions
  - First build and run
  - Making your first change

### Formal Documentation

- **[Software Requirements Specification (SRS)](formal/software_requirements_specification.md)** - Complete requirements
  - Functional requirements (FR-01 through FR-12)
  - Non-functional requirements (NFR-01 through NFR-06)
  - System constraints and test coverage mapping

- **[Software Design Specification (SDS)](formal/software_design_specification.md)** - Architecture and design
  - 5-layer hexagonal architecture
  - Static dependency injection via generics
  - Railway-oriented programming patterns
  - Component relationships and data flow

- **[Software Test Guide](formal/software_test_guide.md)** - Testing documentation
  - Test organization (unit/integration/e2e)
  - Running tests
  - Writing new tests

### Planning

- **[Roadmap](roadmap.md)** - Future development plans

---

## Architecture Overview

Hybrid_App_Ada implements a **5-layer hexagonal architecture**:

```
┌─────────────────────────────────────────────┐
│  Bootstrap                                  │  Composition Root (wiring)
├─────────────────────────────────────────────┤
│  Presentation                               │  Driving Adapters (CLI)
├─────────────────────────────────────────────┤
│  Application                                │  Use Cases + Ports
├─────────────────────────────────────────────┤
│  Infrastructure                             │  Driven Adapters (Console Writer)
├─────────────────────────────────────────────┤
│  Domain                                     │  Business Logic (ZERO dependencies)
└─────────────────────────────────────────────┘
```

### Key Principles

1. **Domain Isolation**: Domain layer has zero external dependencies
2. **Presentation Boundary**: Presentation cannot access Domain directly (uses Application.Error, Application.Command)
3. **Static Dispatch**: Dependency injection via generics (compile-time, zero overhead)
4. **Railway-Oriented**: Result monads for error handling (no exceptions across boundaries)
5. **Single Project**: Easy Alire deployment

---

## Visual Documentation

### UML Diagrams

Located in `diagrams/` directory:

| Diagram | Description |
|---------|-------------|
| [layer_dependencies.svg](diagrams/layer_dependencies.svg) | 5-layer architecture dependency flow |
| [package_structure.svg](diagrams/package_structure.svg) | Actual package hierarchy |
| [application_error_pattern.svg](diagrams/application_error_pattern.svg) | Re-export pattern for Presentation isolation |
| [error_handling_flow.svg](diagrams/error_handling_flow.svg) | Error propagation through layers |
| [static_dispatch.svg](diagrams/static_dispatch.svg) | Static DI with generics |
| [dynamic_static_dispatch.svg](diagrams/dynamic_static_dispatch.svg) | Static vs dynamic comparison |

All diagrams are generated from PlantUML sources (.puml files) via `make diagrams`.

---

## Project Statistics

### Code Metrics (v1.0.0)

| Metric | Count |
|--------|-------|
| Ada Specification Files (.ads) | 26 |
| Ada Implementation Files (.adb) | 10 |
| Architecture Layers | 5 |
| Build Targets | 30+ |

### Test Coverage

| Test Type | Count | Status |
|-----------|-------|--------|
| Unit Tests | 74 | All Passing |
| Integration Tests | 8 | All Passing |
| E2E Tests | 8 | All Passing |
| **Total** | **90** | **100% Passing** |

### Code Quality

- **Compiler Warnings**: 0
- **Style Violations**: 0
- **Architecture Validation**: Enforced by arch_guard.py
- **Aspect Syntax**: 100% (no obsolescent pragmas)
- **Ada Version**: Ada 2022

---

## Directory Structure

```
hybrid_app_ada/
├── src/
│   ├── domain/                 # Pure business logic (ZERO dependencies)
│   │   ├── error/              # Result monad, error types
│   │   └── value_object/       # Immutable value objects (Person, Option)
│   ├── application/            # Use cases + ports
│   │   ├── command/            # Input DTOs (Greet_Command)
│   │   ├── error/              # Re-exports Domain.Error for Presentation
│   │   ├── port/               # Port interfaces (inbound/outbound)
│   │   └── usecase/            # Use case orchestration
│   ├── infrastructure/         # Driven adapters
│   │   └── adapter/            # Console writer implementation
│   ├── presentation/           # Driving adapters
│   │   └── adapter/cli/        # CLI commands
│   ├── bootstrap/              # Composition root
│   │   └── cli/                # CLI wiring
│   └── greeter.adb             # Main (3 lines)
├── test/
│   ├── unit/                   # Domain + Application tests
│   ├── integration/            # Cross-layer tests
│   ├── e2e/                    # Full system tests
│   └── common/                 # Test framework
├── docs/
│   ├── formal/                 # SRS, SDS, Test Guide
│   ├── diagrams/               # UML diagrams (.puml, .svg)
│   └── *.md                    # Other documentation
├── scripts/
│   └── arch_guard.py           # Architecture validation
├── hybrid_app_ada.gpr          # Main project file
├── alire.toml                  # Alire manifest
├── Makefile                    # Build automation
└── README.md                   # Project overview
```

---

## Key Features

### Static Dependency Injection

Uses **generics** instead of interfaces for dependency injection:

```ada
-- Port definition (generic function signature)
generic
   with function Writer (Message : String) return Result;
package Application.Usecase.Greet is
   function Execute (...) return Result;
end Application.Usecase.Greet;

-- Wiring in Bootstrap (compile-time resolution)
package Greet_UseCase is new Application.Usecase.Greet
  (Writer => Console_Writer.Write);
```

**Benefits**:
- Zero runtime overhead (no vtable lookups)
- Full inlining potential
- Stack allocation (no heap)
- Compile-time type safety

### Railway-Oriented Programming

All errors propagate via **Result monad** (no exceptions):

```ada
function Execute (Cmd : Greet_Command) return Unit_Result.Result is
   Person_Result : constant Person_Result.Result :=
      Domain.Value_Object.Person.Create(Get_Name(Cmd));
begin
   if Person_Result.Is_Error then
      return Unit_Result.Error(
         Kind => Person_Result.Error_Info.Kind,
         Message => Error_Strings.To_String(Person_Result.Error_Info.Message));
   end if;

   -- Format greeting at application layer, then write
   return Writer(Format_Greeting(Get_Name(Person_Result.Value)));
end Execute;
```

### Application.Error Re-Export Pattern

**Problem**: Presentation cannot access Domain directly
**Solution**: Application re-exports Domain.Error for Presentation

```ada
-- Application.Error (zero-overhead facade)
package Application.Error is
   subtype Error_Type is Domain.Error.Error_Type;
   subtype Error_Kind is Domain.Error.Error_Kind;
   package Error_Strings renames Domain.Error.Error_Strings;
end Application.Error;
```

---

## Build System

### Make Targets

**Building**:
```bash
make build              # Development build
make build-release      # Release build
make rebuild            # Clean + build
```

**Testing**:
```bash
make test-all           # Run all tests
make test-unit          # Unit tests only
make test-integration   # Integration tests
make test-e2e           # E2E tests
```

**Quality**:
```bash
make check-arch         # Architecture validation
make diagrams           # Regenerate UML diagrams
make stats              # Project statistics
```

---

## Dependencies

### Runtime Dependencies

- **functional** (^1.0.0): Result/Option/Either monads for functional error handling

### Build Requirements

- **GNAT**: FSF 13+ or GNAT Pro (Ada 2022 support)
- **Alire**: 2.0+ package manager
- **Make**: GNU Make for build automation
- **Python 3**: For tooling (arch_guard.py)
- **PlantUML**: For diagram generation (optional)

---

## Support

- **GitHub Issues**: [https://github.com/abitofhelp/hybrid_app_ada/issues](https://github.com/abitofhelp/hybrid_app_ada/issues)
- **Documentation**: This directory

---

## License

Hybrid_App_Ada is licensed under the **BSD-3-Clause License**.

Copyright © 2025 Michael Gardner, A Bit of Help, Inc.

See [LICENSE](../LICENSE) for full license text.

---

**Last Updated**: 2025-11-27
