# Hybrid Application Quick Start Guide

**Version:** 2.0.1  
**Date:** December 10, 2025  
**SPDX-License-Identifier:** BSD-3-Clause<br>
**License File:** See the LICENSE file in the project root<br>
**Copyright:** © 2025 Michael Gardner, A Bit of Help, Inc.<br>  
**Status:** Released  

---

## Table of Contents

- [Installation](#installation)
- [First Build](#first-build)
- [Running the Application](#running-the-application)
- [Understanding the Architecture](#understanding-the-architecture)
- [Making Your First Change](#making-your-first-change)
- [Error Handling](#error-handling)
- [Running Tests](#running-tests)
- [Build Targets](#build-targets)
- [Common Issues](#common-issues)
- [Next Steps](#next-steps)

---

## Installation

### Using Alire (Recommended)

```bash
# Clone the repository
git clone --recurse-submodules https://github.com/abitofhelp/hybrid_app_ada.git
cd hybrid_app_ada

# Build with Alire (automatically fetches dependencies)
alr build

# Or use make
make build
```

### Prerequisites

- **Alire** 2.0+ (Ada package manager)
- **GNAT** 14+ (via Alire toolchain)
- **Make** (for convenience targets)
- **Python 3** (for architecture validation)
- **Java 11+** (optional, for PlantUML diagram generation)

#### Installing Alire

```bash
# macOS (Homebrew)
brew install alire

# Linux - download from https://alire.ada.dev/docs/#installation
# Visit: https://github.com/alire-project/alire/releases

# Verify installation
alr --version
```

### Verify Installation

```bash
# Check that the executable was built
ls -lh bin/greeter

# Run the application
./bin/greeter World
# Output: Hello, World!
```

**Success!** You've built your first hexagonal architecture application in Ada 2022.

---

## First Build

The project uses both Alire and Make for building:

### Using Make (Recommended)

```bash
# Development build (with debug symbols)
make build

# Or explicit development mode
make build-dev

# Optimized build (O2)
make build-opt

# Release build
make build-release
```

### Using Alire Directly

```bash
# Development build
alr build --development

# Release build
alr build --release
```

**Build Output:**
- Executable: `bin/greeter`
- Object files: `obj/`
- Library artifacts: `lib/`

---

## Running the Application

The Hybrid_App_Ada starter includes a simple greeter application demonstrating all architectural layers:

### Basic Usage

```bash
# Greet a person
./bin/greeter Alice
# Output: Hello, Alice!

# Name with spaces (use quotes)
./bin/greeter "Bob Smith"
# Output: Hello, Bob Smith!

# Show usage
./bin/greeter
# Output: Usage: greeter <name>
# Exit code: 1
```

### Error Handling Example

```bash
# Empty name triggers validation error
./bin/greeter ""
# Output: Error: Name cannot be empty
# Exit code: 1
```

**Key Points:**
- All errors return via Result monad (no exceptions)
- Exit code 0 = success, 1 = error
- Validation happens in Domain layer
- Greeting format happens in Application layer
- Errors propagate through Application to Presentation

---

## Understanding the Architecture

Hybrid_App_Ada demonstrates **5-layer hexagonal architecture**:

### Layer Overview

```text
+-------------------------------------------------+
|  Bootstrap (Composition Root)                    |  <- Wires everything together
+-------------------------------------------------+
|  Presentation (CLI)                              |  <- User interface (Application ONLY)
+-------------------------------------------------+
|  Application (Use Cases + Ports)                 |  <- Orchestration layer
+-------------------------------------------------+
|  Infrastructure (Adapters)                       |  <- Technical implementations
+-------------------------------------------------+
|  Domain (Business Logic)                         |  <- Pure business rules (ZERO dependencies)
+-------------------------------------------------+
```

### Key Architectural Principles

1. **Domain has zero dependencies** - Pure business logic (validation, value objects)
2. **Presentation cannot access Domain** - Must use Application layer (Application.Error, Application.Command)
3. **Static dependency injection** - Via generics (compile-time wiring)
4. **Railway-oriented programming** - Result monads for error handling
5. **Single-project structure** - Easy to deploy via Alire

### Request Flow Example

```text
User Input ("Alice")
    |
    v
Presentation.Adapter.CLI.Command.Greet (parses input)
    |
    v
Application.UseCase.Greet (creates Person, formats greeting)
    |
    v
Domain.Value_Object.Person (validates name)
    |
    v
Infrastructure.Adapter.Console_Writer (output)
    |
    v
Result[Unit] (success or error)
    |
    v
Exit Code (0 or 1)
```

### Layer Responsibilities

| Layer | Responsibilities | Dependencies |
|-------|------------------|--------------|
| Domain | Business logic, validation | NONE |
| Application | Use cases, ports, formatting | Domain |
| Infrastructure | Adapters (driven) | App + Domain |
| Presentation | UI (driving) | Application ONLY |
| Bootstrap | DI wiring | ALL |

### Responsibility Separation

- **Domain**: Provides data (Get_Name) and validates business rules
- **Application**: Formats output (Format_Greeting), orchestrates use cases
- **Infrastructure**: Implements technical concerns (console I/O)
- **Presentation**: Handles user interaction, maps errors to messages

---

## Making Your First Change

Let's modify the greeting format:

### Step 1: Locate the Application Logic

The greeting format is in the Application layer:

```bash
# File: src/application/usecase/application-usecase-greet.adb
```

Find the `Format_Greeting` function:

```ada
function Format_Greeting (Name : String) return String is
begin
   return "Hello, " & Name & "!";
end Format_Greeting;
```

### Step 2: Modify Greeting Format

Change the format, for example:

```ada
function Format_Greeting (Name : String) return String is
begin
   return "Greetings, " & Name & "!";
end Format_Greeting;
```

### Step 3: Rebuild and Test

```bash
# Rebuild
make rebuild

# Run tests to ensure nothing broke
make test-all

# Test manually
./bin/greeter Alice
# Output: Greetings, Alice!
```

**Best Practice**: Always run tests after making changes. This project has 109 tests ensuring correctness.

---

## Error Handling

Hybrid_App_Ada uses the Result monad pattern - no exceptions are raised.

### Pattern 1: Check Success/Failure

```ada
Result : constant Unit_Result.Result := Greet (Cmd);

if Unit_Result.Is_Ok (Result) then
   --  Success path
   Put_Line ("Operation succeeded");
else
   --  Error path
   Put_Line ("Operation failed");
end if;
```

### Pattern 2: Extract Error Info

```ada
Result : constant Person_Result.Result := Person.Create ("");

if Result.Is_Error then
   declare
      Info : constant Error_Type := Person_Result.Error_Info (Result);
   begin
      Put_Line ("Error kind: " & Info.Kind'Image);
      Put_Line ("Message: " & Error_Strings.To_String (Info.Message));
   end;
end if;
```

### Error Kinds

| Kind | Description |
|------|-------------|
| `Validation_Error` | Input validation failed (empty name, too long) |
| `Parse_Error` | Malformed data or parsing failure |
| `Not_Found_Error` | Requested resource not found |
| `IO_Error` | Infrastructure I/O operation failed |
| `Internal_Error` | Unexpected internal error (bug) |

### New in v2.0.0: Result Combinators

The functional ^3.0.0 upgrade brings powerful new combinators:

```ada
-- Bimap: Transform both Ok and Error values
Result.Bimap (Ok_Fn => To_Upper, Error_Fn => Add_Context);

-- Ensure: Add validation postconditions
Result.Ensure (Is_Valid'Access, "Validation failed");

-- With_Context: Add error context
Result.With_Context ("While processing user input");

-- Fallback: Provide default on error
Result.Fallback (Default_Value);

-- Recover: Convert errors to Ok values
Result.Recover (Error_To_Value'Access);

-- Tap: Side effects without changing Result
Result.Tap (Log_Success'Access);
```

**Why No Exceptions?**

- Explicit error paths enforced by compiler
- SPARK compatible for formal verification
- Deterministic timing (no stack unwinding)
- Errors are values that can be passed and transformed

---

## Running Tests

### Test Organization

| Test Type | Count | Location |
|-----------|-------|----------|
| Unit Tests | 85 | `test/unit/` |
| Integration Tests | 16 | `test/integration/` |
| E2E Tests | 8 | `test/e2e/` |
| **Total** | **109** | |

### All Tests

```bash
make test-all
```

### Specific Test Suites

```bash
# Unit tests only
make test-unit

# Integration tests only
make test-integration

# E2E tests only
make test-e2e
```

### Expected Output

```text
########################################
###                                  ###
###   ALL TEST SUITES: SUCCESS      ###
###   All 109 tests passed!          ###
###                                  ###
########################################
```

### Running Individual Tests

```bash
# Run unit test runner (all unit tests)
./test/bin/unit_runner

# Run individual test
./test/bin/test_domain_person
```

### Test Coverage

Hybrid_App_Ada supports code coverage analysis using GNATcoverage.

#### First-Time Setup

Before running coverage analysis for the first time, you need to build the GNATcoverage runtime library:

```bash
# Build the coverage runtime (one-time setup)
make build-coverage-runtime

# This will:
# - Locate your GNATcoverage installation
# - Build the runtime library from sources
# - Install it to external/gnatcov_rts/
```

#### Running Coverage Analysis

```bash
# Run tests with GNATcoverage analysis
make test-coverage

# View coverage report
# Coverage reports generated in coverage/ directory
# - coverage/index.html - HTML coverage report
# - coverage/*.xcov - Detailed coverage files
```

**Test Framework**: Custom lightweight framework (no AUnit dependency) located in `test/common/test_framework.{ads,adb}`

---

## Build Targets

### Building

```bash
make build              # Development build (default)
make build-dev          # Explicit development mode
make build-opt          # Optimized build (O2)
make build-release      # Release build
make rebuild            # Clean and rebuild
```

### Testing

```bash
make test               # Run all tests (alias)
make test-all           # Run entire test suite
make test-unit          # Unit tests only
make test-integration   # Integration tests only
make test-e2e           # E2E tests only
make test-coverage      # Tests with coverage analysis
```

### Quality & Architecture

```bash
make check              # Run static analysis
make check-arch         # Validate architecture boundaries
make stats              # Show project statistics
make diagrams           # Regenerate UML diagrams
```

### Cleaning

```bash
make clean              # Clean build artifacts
make clean-deep         # Deep clean (slow rebuild)
make clean-coverage     # Clean coverage data
```

### Utilities

```bash
make deps               # Show dependency information
make prereqs            # Verify prerequisites
make help               # Show all available targets
```

---

## Common Issues

### Q: Build fails with "Ada_2022 not supported"

**A:** You need GNAT FSF 13+ or GNAT Pro:

```bash
gnatls -v
```

### Q: "functional" dependency not found

**A:** Alire should fetch dependencies automatically:

```bash
alr update
alr build
```

### Q: Architecture validation warnings appear

**A:** The `make check-arch` validates layer boundaries. These are warnings, not errors:

```bash
make check-arch
```

### Q: Where are the test executables?

**A:** Test executables are in `test/bin/`:

```bash
ls -lh test/bin/
# Output:
# unit_runner
# test_domain_error_result
# test_domain_person
# test_application_command_greet
# test_application_usecase_greet
# test_greet_full_flow
# test_infrastructure_console_writer
# test_greeter_cli
```

### Q: How do I run a single test?

**A:** Execute the test directly:

```bash
./test/bin/test_domain_person
```

---

## Next Steps

### Explore the Architecture

- **[Software Design Specification](formal/software_design_specification.md)** - Deep dive into architecture
- **[Architecture Diagrams](diagrams/)** - Visual documentation
- **[Application Architecture](diagrams/application_architecture.svg)** - See dependency flow

### Read the Source Code

Start with the wiring in Bootstrap:

```bash
# See how all layers are wired together
cat src/bootstrap/cli/bootstrap-cli.adb
```

Then explore each layer:

```bash
# Domain (pure business logic)
ls src/domain/

# Application (use cases and ports)
ls src/application/

# Infrastructure (adapters)
ls src/infrastructure/

# Presentation (CLI)
ls src/presentation/

# Bootstrap (composition root)
ls src/bootstrap/
```

### Study the Test Suite

```bash
# See how tests are organized
ls -R test/

# Read test framework
cat test/common/test_framework.ads
```

### Understand Error Handling

- See how Result monads replace exceptions
- Study error propagation patterns
- Learn the Application.Error re-export pattern
- Experiment with new v2.0.0 combinators

### Learn Dependency Injection

- **[Static Dispatch (Ada)](diagrams/ada/static_dispatch_ada.svg)** - Generic-based DI pattern
- **[Static vs Dynamic (Ada)](diagrams/ada/dynamic_static_dispatch_ada.svg)** - Pattern comparison
- See Bootstrap wiring examples
- Understand compile-time polymorphism

### Add Your Own Use Case

Follow the pattern:

1. **Domain**: Create value objects/entities (`src/domain/`)
2. **Application**: Define command, use case, ports (`src/application/`)
3. **Infrastructure**: Implement adapters (`src/infrastructure/`)
4. **Presentation**: Create CLI command (`src/presentation/`)
5. **Bootstrap**: Wire everything together (`src/bootstrap/`)
6. **Tests**: Add unit/integration/e2e tests (`test/`)

---

## Documentation Index

- **[Main Documentation Hub](index.md)** - All documentation links
- **[Software Requirements Specification](formal/software_requirements_specification.md)** - Requirements
- **[Software Design Specification](formal/software_design_specification.md)** - Architecture
- **[Software Test Guide](formal/software_test_guide.md)** - Testing guide

---

## Support

For questions, issues, or contributions:

- **Issues**: [GitHub Issues](https://github.com/abitofhelp/hybrid_app_ada/issues)
- **Documentation**: See `docs/` directory

---

**License:** BSD-3-Clause  
**Copyright:** © 2025 Michael Gardner, A Bit of Help, Inc.  

See [LICENSE](../LICENSE) for full license text.
