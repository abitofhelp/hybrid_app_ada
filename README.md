# Hybrid_App_Ada - Ada 2022 Application Starter

**Version:** 1.0.0  
**Date:** November 27, 2025  
**Copyright:** © 2025 Michael Gardner, A Bit of Help, Inc.  
**License:** BSD-3-Clause  

## Overview

A **professional Ada 2022 application starter** demonstrating **hybrid DDD/Clean/Hexagonal architecture** with **functional programming** principles using the `functional` crate for Result monads.

This is a **desktop/enterprise application template** showcasing:
- **5-Layer Hexagonal Architecture** (Domain, Application, Infrastructure, Presentation, Bootstrap)
- **Static Dispatch Dependency Injection** via generics (zero runtime overhead)
- **Railway-Oriented Programming** with Result monads (no exceptions across boundaries)
- **Presentation Isolation** pattern (only Domain is shareable across apps)
- **Single-Project Structure** (easy Alire deployment)

## Architecture

### Layer Structure

![Layer Dependencies](docs/diagrams/layer_dependencies.svg)

**5 Layers (Dependency Rule: All dependencies point INWARD)**:

```
hybrid_app_ada/
├── src/
│   ├── domain/                    # Pure Business Logic (ZERO dependencies)
│   │   ├── error/                 # Error types & Result monad
│   │   └── value_object/          # Immutable value objects
│   │
│   ├── application/               # Use Cases & Ports (Depends on: Domain)
│   │   ├── command/               # Input DTOs
│   │   ├── error/                 # Re-exports Domain.Error for Presentation
│   │   ├── port/                  # Port interfaces (in/out)
│   │   └── usecase/               # Use case orchestration
│   │
│   ├── infrastructure/            # Driven Adapters (Depends on: Application + Domain)
│   │   └── adapter/               # Concrete implementations
│   │
│   ├── presentation/              # Driving Adapters (Depends on: Application ONLY)
│   │   └── cli/                   # CLI interface
│   │
│   ├── bootstrap/                 # Composition Root (Depends on: ALL)
│   │   └── cli/                   # CLI wiring
│   │
│   └── greeter.adb                # Main (3 lines - delegates to Bootstrap)
│
├── test/                          # Test Suite
│   ├── unit/                      # Domain & Application unit tests
│   ├── integration/               # Cross-layer integration tests
│   ├── e2e/                       # End-to-end CLI tests
│   └── common/                    # Shared test framework
│
├── docs/                          # Documentation
│   ├── diagrams/                  # UML diagrams (PlantUML)
│   └── formal/                    # SDS, SRS, Test Guide
│
├── scripts/                       # Automation
│   └── arch_guard.py              # Architecture boundary validation
│
├── hybrid_app_ada.gpr             # Main project file (single-project)
├── alire.toml                     # Alire manifest
└── Makefile                       # Build automation
```

### Key Architectural Rules

![Application Error Pattern](docs/diagrams/application_error_pattern.svg)

**Critical Boundary Rule:**
> **Presentation is the ONLY outer layer prevented from direct Domain access**

- ✅ **Infrastructure** CAN access `Domain.*` (implements repositories, uses entities)
- ✅ **Application** depends on `Domain.*` (orchestrates domain logic)
- ❌ **Presentation** CANNOT access `Domain.*` (must use `Application.Error`, `Application.Command`, etc.)

**Why This Matters:**
- Domain is the **only shareable layer** across multiple applications
- Each app has its own Application/Infrastructure/Presentation/Bootstrap
- Prevents tight coupling between UI and business logic
- Allows multiple UIs (CLI, REST, GUI) to share the same Domain

**The Solution:** `Application.Error` re-exports `Domain.Error` types:

```ada
-- Application.Error (facade for Presentation)
with Domain.Error;

package Application.Error is
   -- Re-export Domain error types (zero overhead)
   subtype Error_Type is Domain.Error.Error_Type;
   subtype Error_Kind is Domain.Error.Error_Kind;
   package Error_Strings renames Domain.Error.Error_Strings;

   -- Convenience constants
   Validation_Error : constant Error_Kind := Domain.Error.Validation_Error;
   IO_Error         : constant Error_Kind := Domain.Error.IO_Error;
end Application.Error;
```

## Static Dispatch Dependency Injection

![Static vs Dynamic Dispatch](docs/diagrams/dynamic_static_dispatch.svg)

### This Project Uses: Static Dispatch (Generics)

```ada
-- Compile-time polymorphism (USED in this project)
generic
   with function Writer (Message : String) return Result;
package Application.Usecase.Greet is
   function Execute (...) return Result;
end Application.Usecase.Greet;

-- Implementation
function Execute (...) return Result is
begin
   return Writer("Hello, " & Name & "!");  -- Direct call (or inlined!)
end Execute;
```

**Wiring in Bootstrap:**
```ada
-- Step 1: Wire Infrastructure → Port
package Writer_Port_Instance is new
  Application.Port.Outbound.Writer.Generic_Writer
    (Write => Infrastructure.Adapter.Console_Writer.Write);

-- Step 2: Wire Use Case → Port
package Greet_UseCase_Instance is new
  Application.Usecase.Greet
    (Writer => Writer_Port_Instance.Write_Message);

-- Step 3: Wire Command → Use Case
package Greet_Command_Instance is new
  Presentation.Adapter.CLI.Command.Greet
    (Execute_Greet_UseCase => Greet_UseCase_Instance.Execute);

-- Step 4: Run
return Greet_Command_Instance.Run;
```

**Benefits:**
- ✅ **Zero runtime overhead** (compile-time resolution)
- ✅ **Full inlining** (compiler can optimize across boundaries)
- ✅ **Stack allocation** (no heap required)
- ✅ **Type-safe** (verified at compile time)

## Error Handling: Railway-Oriented Programming

![Error Handling Flow](docs/diagrams/error_handling_flow.svg)

**NO EXCEPTIONS across layer boundaries.** All errors propagate via Result monad:

```ada
-- Use case returns Result
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

## Building

### Prerequisites

- **GNAT FSF 13+** or **GNAT Pro** (Ada 2022 support)
- **Alire 2.0+** package manager
- **Java 11+** (for PlantUML diagram generation, optional)

### Build Commands

```bash
# Build the project
make build
# or
alr build

# Run the application
./bin/greeter Alice

# Clean artifacts
make clean

# Rebuild from scratch
make rebuild

# Run tests
make test-unit           # Unit tests (74)
make test-integration    # Integration tests (8)
make test-e2e            # E2E tests (8)
make test-all            # All tests (90)

# Code quality
make check-arch          # Validate architecture boundaries
make diagrams            # Regenerate UML diagrams
make stats               # Code statistics
```

## Usage

```bash
# Greet a person
./bin/greeter Alice
# Output: Hello, Alice!

# Name with spaces
./bin/greeter "Bob Smith"
# Output: Hello, Bob Smith!

# No arguments (shows usage)
./bin/greeter
# Output: Usage: greeter <name>
# Exit code: 1

# Empty name (validation error)
./bin/greeter ""
# Output: Error: Name cannot be empty
# Exit code: 1
```

## Exit Codes

- **0**: Success
- **1**: Failure (validation error, infrastructure error, or missing arguments)

## Testing

Tests use a custom lightweight test framework (no AUnit dependency):

| Test Type     | Count | Location              | Purpose                              |
|---------------|-------|-----------------------|--------------------------------------|
| Unit          | 74    | `test/unit/`          | Domain & Application logic           |
| Integration   | 8     | `test/integration/`   | Cross-layer interactions             |
| E2E           | 8     | `test/e2e/`           | Full system via CLI (black-box)      |
| **Total**     | **90**|                       | **100% passing**                     |

```bash
# Run all tests
make test-all

# Run specific test level
make test-unit
make test-integration
make test-e2e
```

## Dependencies

Managed by Alire (`alire.toml`):

```toml
[dependencies]
functional = "^1.0.0"  # Result/Option/Either monads
```

## Architecture Validation

**Automated boundary enforcement:**

```bash
make check-arch
```

The `scripts/arch_guard.py` script validates:
- ✅ Presentation → Application only (no Domain access)
- ✅ Infrastructure → Application + Domain
- ✅ Application → Domain only
- ✅ Domain has zero dependencies
- ✅ All pragmas converted to aspects

## Documentation

- **[Documentation Index](docs/index.md)** - Complete documentation overview
- **[Quick Start Guide](docs/quick_start.md)** - Get started in minutes
- **[Software Requirements Specification](docs/formal/software_requirements_specification.md)**
- **[Software Design Specification](docs/formal/software_design_specification.md)**
- **[Software Test Guide](docs/formal/software_test_guide.md)**
- **[Roadmap](docs/roadmap.md)** - Future plans
- **[CHANGELOG](CHANGELOG.md)** - Release history

### Diagrams

- `docs/diagrams/layer_dependencies.svg` - 5-layer architecture
- `docs/diagrams/application_error_pattern.svg` - Re-export pattern
- `docs/diagrams/package_structure.svg` - Actual packages
- `docs/diagrams/error_handling_flow.svg` - Error propagation
- `docs/diagrams/static_dispatch.svg` - Static DI with generics
- `docs/diagrams/dynamic_static_dispatch.svg` - Static vs dynamic comparison

## Code Standards

This project follows:
- **Ada Agent** (`~/.claude/agents/ada.md`)
- **Architecture Agent** (`~/.claude/agents/architecture.md`)
- **Functional Agent** (`~/.claude/agents/functional.md`)
- **Testing Agent** (`~/.claude/agents/testing.md`)

### Key Standards Applied

1. **Aspects over Pragmas:** `with Pure` not `pragma Pure`
2. **Contracts:** Pre/Post conditions on all public operations
3. **No Heap:** Domain uses bounded strings
4. **Immutability:** Value objects immutable after creation
5. **Pure Functions:** Domain logic has no side effects
6. **Result Monads:** No exceptions across boundaries
7. **Static Dispatch:** Generics for dependency injection

## Project Status

✅ **Completed:**
- Single-project structure (easy Alire deployment)
- Result monad error handling (Domain.Error.Result)
- Static dependency injection via generics
- Application.Error re-export pattern
- Architecture boundary validation (arch_guard.py)
- Comprehensive documentation with UML diagrams
- Test framework (unit/integration/e2e - 90 tests)
- Aspect syntax (not pragmas)
- Makefile automation

## License

BSD-3-Clause - See LICENSE file in project root.

## Author

Michael Gardner
A Bit of Help, Inc.
https://github.com/abitofhelp
