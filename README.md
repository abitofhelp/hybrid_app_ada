# Hybrid_App_Ada - Ada 2022 Application Starter

**Version:** 1.0.0
**Date:** November 18, 2025
**Copyright:** © 2025 Michael Gardner, A Bit of Help, Inc.
**License:** BSD-3-Clause

## Overview

A **professional Ada 2022 application starter** demonstrating **hybrid DDD/Clean/Hexagonal architecture** with **functional programming** principles using the `functional` crate for Result monads.

This is a **desktop/enterprise application template** showcasing:
- **5-Layer Hexagonal Architecture** (Domain, Application, Infrastructure, Presentation, Bootstrap)
- **Scripted Cloning/Template Instantiation** (rename entire project in seconds via Python script)
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
│   │   ├── model/                 # Output DTOs
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
├── tests/                         # Test Suite
│   ├── unit/                      # Domain & Application unit tests
│   ├── integration/               # Cross-layer integration tests
│   ├── e2e/                       # End-to-end CLI tests
│   └── common/                    # Shared test framework
│
├── docs/                          # Documentation
│   ├── diagrams/                  # UML diagrams (PlantUML)
│   └── *.md                       # SDS, SRS, Test Guide
│
├── scripts/                       # Automation
│   └── arch_guard.py              # Architecture boundary validation
│
├── tools/                         # Build tools
│   └── puml/                      # PlantUML JAR
│
├── hybrid_app_ada.gpr              # Main project file (single-project)
├── alire.toml                     # Alire manifest
└── Makefile                       # Build automation
```

### Key Architectural Rules

![Application Error Pattern](docs/diagrams/application_error_pattern.svg)

**Critical Boundary Rule:**
> **Presentation is the ONLY outer layer prevented from direct Domain access**

- ✅ **Infrastructure** CAN access `Domain.*` (implements repositories, uses entities)
- ✅ **Application** depends on `Domain.*` (orchestrates domain logic)
- ❌ **Presentation** CANNOT access `Domain.*` (must use `Application.Error`, `Application.Model`, etc.)

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
   Validation_Error     : constant Error_Kind := Domain.Error.Validation_Error;
   Infrastructure_Error : constant Error_Kind := Domain.Error.Infrastructure_Error;
end Application.Error;
```

## Static Dispatch Dependency Injection

![Static vs Dynamic Dispatch](docs/diagrams/dynamic_static_dispatch.svg)

### Most Developers Think: Dynamic Dispatch (Interfaces)

```ada
-- Traditional OOP approach (NOT used in this project)
type Writer_Port is interface;
procedure Write (Self : Writer_Port; Message : String) is abstract;

type Greet_UseCase is record
   Writer : access Writer_Port'Class;  -- ← Heap allocation, vtable lookup
end record;

UC.Writer.Write("Hello");  -- ← Virtual dispatch (runtime overhead)
```

**Cost:** vtable lookup, heap allocation, prevents inlining

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
   return Writer("Hello");  -- ← Direct call (or inlined!)
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
- ✅ **Functional composition** (functions passed as parameters)

**Trade-off:**
- ❌ Fixed at compile time (can't swap implementations at runtime)
- This is perfect for most applications where wiring is known upfront

## Error Handling: Railway-Oriented Programming

![Error Handling Flow](docs/diagrams/error_handling_flow.svg)

**NO EXCEPTIONS across layer boundaries.** All errors propagate via Result monad:

```ada
-- Domain defines Result[T] monad
generic
   type T is private;
package Domain.Error.Result.Generic_Result is
   type Result is private;

   function Ok (Value : T) return Result;
   function Error (Kind : Error_Kind; Message : String) return Result;

   function Is_Ok (Self : Result) return Boolean;
   function Value (Self : Result) return T;  -- Pre: Is_Ok
   function Error_Info (Self : Result) return Error_Type;  -- Pre: Is_Error
end Generic_Result;
```

**Usage Pattern:**

```ada
-- 1. Use case returns Result
function Execute (Cmd : Greet_Command) return Unit_Result.Result is
   Person_Result : constant Person_Result.Result :=
      Domain.Value_Object.Person.Create(Cmd.Name);
begin
   if Person_Result.Is_Error then
      return Unit_Result.Error(
         Kind => Person_Result.Error_Info.Kind,
         Message => Person_Result.Error_Info.Message);
   end if;

   -- Happy path continues...
   return Writer(Greeting_Message(Person_Result.Value));
end Execute;

-- 2. Presentation handles result
Result := Execute_Greet_UseCase(Cmd);
if Unit_Result.Is_Ok(Result) then
   return 0;  -- Success
else
   Error_Info := Unit_Result.Error_Info(Result);
   Put_Line("Error: " & Application.Error.Error_Strings.To_String(Error_Info.Message));
   return 1;  -- Failure
end if;
```

**Error Flow:**
1. **Domain:** Validates, returns `Error` variant if invalid
2. **Application:** Orchestrates, propagates errors upward
3. **Infrastructure:** Catches exceptions at boundaries, converts to `Error` with `Try_To_Result`
4. **Presentation:** Pattern matches on `Error_Kind`, displays user-friendly messages

## File Naming Conventions

### Standard Ada/GNAT Practice

**Hyphenated filenames** directly map to package hierarchies:

```
Package Name                          File Name
────────────────────────────────────────────────────────────────────
Domain.Value_Object.Person         → domain-value_object-person.ads
Application.Command.Greet          → application-command-greet.ads
Infrastructure.Adapter.Console_Writer → infrastructure-adapter-console_writer.ads
```

**Why this is standard:**
- **Zero configuration** - GNAT automatically maps filenames to packages
- **Universal compatibility** - Works on all filesystems (Windows, Linux, macOS)
- **Tool support** - IDEs, linters, and Alire expect this convention
- **95%+ adoption** - Nearly all Ada code uses hyphenated naming

### Directory Organization

While using hyphenated filenames, we organize into **logical subdirectories**:

```
src/
├── domain/
│   ├── error/
│   │   ├── domain-error.ads
│   │   └── domain-error-result.ads
│   └── value_object/
│       └── domain-value_object-person.ads
├── application/
│   ├── command/
│   │   └── application-command-greet.ads
│   ├── error/
│   │   └── application-error.ads          # ← Re-exports Domain.Error
│   └── usecase/
│       └── application-usecase-greet.ads
└── ...
```

**Combines:**
- Standard Ada naming (hyphenated files)
- Architectural clarity (subdirectories by layer/concern)

## Key Design Patterns

### 1. Minimal Entry Point

**Main (greeter.adb)** - Only 3 lines:

```ada
with Ada.Command_Line;
with Bootstrap.CLI;

procedure Greeter is
   Exit_Code : Integer;
begin
   Exit_Code := Bootstrap.CLI.Run;
   Ada.Command_Line.Set_Exit_Status (Exit_Code);
end Greeter;
```

All application logic lives in Bootstrap.CLI.Run, which handles:
- CLI argument parsing
- Dependency injection (generic instantiation)
- Application execution
- Error handling
- Exit code mapping

### 2. Result Monad Pattern

**Railway-Oriented Programming:**
- Ok track: Successful computation continues
- Error track: Error propagates (short-circuit)
- Forces explicit error handling at compile time
- No exceptions thrown across boundaries

### 3. Application.Error Re-export Pattern

**Problem:** Presentation cannot access Domain directly
**Solution:** Application re-exports Domain types for Presentation use
**Implementation:** Subtypes and renames (zero overhead)

### 4. Static Dependency Injection

**Pattern:** Generic packages with function parameters
**Wiring:** Bootstrap instantiates all generics
**Benefit:** Compile-time resolution (zero runtime cost)

### 5. Ada 2022 Features

- **Aspects** (`with Pure`, `with Preelaborate` - not obsolescent pragmas)
- **Contracts** (`Pre`, `Post` aspects for design-by-contract)
- **Bounded Strings** (no heap allocation in domain layer)
- **Expression Functions** (pure domain logic)
- **Discriminated Records** (Result type implementation)

## Building

### Prerequisites

- **GNAT FSF 13+** or **GNAT Pro** (Ada 2022 support)
- **Alire 2.0+** package manager
- **Java 11+** (for PlantUML diagram generation)

### Build Commands

```bash
# Build the project
make build
# or
alr build

# Run the application
make run NAME="Alice"

# Run specific targets
./bin/greeter Alice

# Clean artifacts
make clean

# Rebuild from scratch
make rebuild

# Run tests
make test-unit           # Unit tests
make test-integration    # Integration tests
make test-e2e            # E2E tests
make test-all            # All tests

# Code quality
make check-arch          # Validate architecture boundaries
make format              # Format code (gnatformat)
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

| Test Type     | Location              | GPR File                 | Purpose                              |
|---------------|-----------------------|--------------------------|--------------------------------------|
| Unit          | `tests/unit/`         | `unit_tests.gpr`         | Domain & Application logic           |
| Integration   | `tests/integration/`  | `integration_tests.gpr`  | Cross-layer interactions             |
| E2E           | `tests/e2e/`          | `e2e_tests.gpr`          | Full system via CLI (black-box)      |

```bash
# Run all tests
make test-all

# Run specific test level
make test-unit
make test-integration
make test-e2e
```

**Test Framework:** Located in `tests/common/test_framework.{ads,adb}`

## Dependencies

Managed by Alire (`alire.toml`):

```toml
[dependencies]
functional = "^1.0.0"  # Result/Option/Either monads
```

**Note:** No AUnit dependency - we use a custom lightweight test framework.

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

- **Diagrams:** `docs/diagrams/*.svg` (generated from PlantUML)
  - layer_dependencies.svg - 5-layer architecture
  - application_error_pattern.svg - Re-export pattern
  - package_structure.svg - Actual packages
  - error_handling_flow.svg - Error propagation
  - static_dispatch.svg - Static DI with generics
  - dynamic_static_dispatch.svg - Static vs dynamic comparison
- **SDS:** `docs/software_design_specification.md`
- **SRS:** `docs/software_requirements_specification.md`
- **Test Guide:** `docs/software_test_guide.md`
- **Quick Start:** `docs/quick_start.md`

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
4. **Immutability:** Proper use of limited types
5. **Pure Functions:** Domain logic has no side effects
6. **Result Monads:** No exceptions across boundaries
7. **Static Dispatch:** Generics for dependency injection

## Comparison with OOP Patterns

| Aspect                  | Traditional OOP              | This Project (Functional)          |
|-------------------------|------------------------------|------------------------------------|
| **Error Handling**      | Exceptions                   | Result monad (railway-oriented)    |
| **Dependency Injection**| Interfaces (dynamic dispatch)| Generics (static dispatch)         |
| **String Handling**     | Unbounded strings            | Bounded strings (no heap)          |
| **Memory Model**        | Heap allocation              | Stack allocation (no heap)         |
| **Polymorphism**        | Runtime (vtable)             | Compile-time (generics)            |
| **Performance**         | Virtual dispatch overhead    | Zero overhead (inlined)            |
| **Flexibility**         | Runtime flexibility          | Compile-time fixed                 |

## Project Status

✅ **Completed:**
- Single-project structure (easy Alire deployment)
- Result monad error handling (Domain.Error.Result)
- Static dependency injection via generics
- Application.Error re-export pattern
- Architecture boundary validation (arch_guard.py)
- Comprehensive documentation with UML diagrams
- Test framework (unit/integration/e2e structure)
- Aspect syntax (not pragmas)
- Makefile automation

## Learning Resources

- [Ada 2022 Reference Manual](https://www.adaic.org/ada-resources/standards/)
- [Alire Package Manager](https://alire.ada.dev/)
- [Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture/)
- [Railway-Oriented Programming](https://fsharpforfunandprofit.com/rop/)
- [Functional Crate](https://github.com/abitofhelp/functional)

## License

BSD-3-Clause - See LICENSE file in project root.

## Author

Michael Gardner
A Bit of Help, Inc.
https://github.com/abitofhelp
