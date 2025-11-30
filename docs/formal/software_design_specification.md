# Software Design Specification

**Version:** 1.0.0<br>
**Date:** 2025-11-29<br>
**SPDX-License-Identifier:** BSD-3-Clause<br>
**License File:** See the LICENSE file in the project root<br>
**Copyright:** © 2025 Michael Gardner, A Bit of Help, Inc.<br>
**Status:** Released

---

## 1. Introduction

### 1.1 Purpose

This Software Design Specification (SDS) describes the architectural design and detailed design of Hybrid_App_Ada, a professional Ada 2022 application starter demonstrating hexagonal architecture with functional programming principles.

### 1.2 Scope

This document covers:
- Architectural patterns and design decisions
- 5-layer organization and dependencies
- Key components and their responsibilities
- Data flow and error handling strategies
- Design patterns employed
- Static dependency injection implementation

---

## 2. Architectural Design

### 2.1 Architecture Style

Hybrid_App_Ada uses **Hexagonal Architecture** (Ports and Adapters / Clean Architecture).

**Benefits**:
- Clear separation of concerns
- Testable business logic (pure functions)
- Swappable infrastructure (adapters)
- Compiler-enforced boundaries
- Educational value for learning clean architecture

### 2.2 Layer Organization

```
┌─────────────────────────────────────────────────────────┐
│  Bootstrap                                              │
│  (Composition Root - Wires Everything)                  │
│  - Generic instantiations                               │
│  - Port-to-adapter binding                              │
│  - Application entry point                              │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  Presentation                                           │
│  (Driving Adapters - User Interfaces)                   │
│  - CLI commands                                         │
│  - Argument parsing                                     │
│  - Error message formatting                             │
│  - Depends on: Application ONLY (not Domain)            │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│  Application                                            │
│  (Use Cases + Ports)                                    │
│  - Use case orchestration                               │
│  - Inbound ports (use case interfaces)                  │
│  - Outbound ports (infrastructure interfaces)           │
│  - Commands (input DTOs)                                │
│  - Application.Error (re-exports Domain.Error)          │
│  - Format_Greeting (output formatting)                  │
│  - Depends on: Domain                                   │
└─────────────────────────────────────────────────────────┘
                     ↓              ↑
┌──────────────────────┐    ┌──────────────────────────────┐
│  Infrastructure      │    │  Domain                      │
│  (Driven Adapters)   │    │  (Business Logic)            │
│  - Console Writer    │    │  - Value Objects (Person)    │
│  - Adapts external   │    │  - Error types + Result      │
│  - Exception → Result│    │  - Pure functions            │
│  - Depends on:       │    │  - ZERO dependencies         │
│    App + Domain      │    │                              │
└──────────────────────┘    └──────────────────────────────┘
```

### 2.3 Layer Responsibilities

#### Domain Layer
- **Purpose**: Pure business logic, no external dependencies
- **Components**:
  - Value Objects: `Domain.Value_Object.Person`
  - Error types: `Domain.Error.Error_Type`, `Error_Kind`
  - Result monad: `Domain.Error.Result.Generic_Result`
  - Unit type: `Domain.Unit`
- **Rules**:
  - Immutable value objects
  - Validation in constructors
  - Pure functions only (no side effects)
  - No infrastructure dependencies
  - Provides data (Get_Name), not formatting

#### Application Layer
- **Purpose**: Orchestrate domain logic, define port interfaces, format output
- **Components**:
  - Use Cases: `Application.Usecase.Greet`
  - Commands: `Application.Command.Greet`
  - Inbound Ports: Use case interfaces
  - Outbound Ports: `Application.Port.Outbound.Writer`
  - Error Re-export: `Application.Error`
- **Rules**:
  - Stateless use cases
  - Depends on Domain only
  - Defines interfaces for infrastructure
  - Formats output (Format_Greeting)

#### Infrastructure Layer
- **Purpose**: Implement technical concerns, adapt external systems
- **Components**:
  - Adapters: `Infrastructure.Adapter.Console_Writer`
  - Implements outbound ports
- **Rules**:
  - Implements Application port interfaces
  - Catches exceptions at boundaries
  - Converts exceptions to Result errors
  - Depends on Application + Domain

#### Presentation Layer
- **Purpose**: User interface implementation
- **Components**:
  - CLI Commands: `Presentation.Adapter.CLI.Command.Greet`
  - Argument parsing
  - Error formatting
- **Rules**:
  - **Cannot access Domain directly**
  - Uses Application.Error (not Domain.Error)
  - Uses Application.Command (not Domain entities)
  - Depends on Application ONLY

#### Bootstrap Layer
- **Purpose**: Composition root (dependency injection)
- **Components**:
  - `Bootstrap.CLI.Run` - wires everything together
  - Generic instantiations
  - Port-adapter binding
- **Rules**:
  - Only layer that knows about all others
  - Static wiring (compile-time)
  - No business logic

#### Version Package (Cross-Cutting)
- **Purpose**: Application version metadata (outside hexagonal layers)
- **Location**: `src/version/` (own GPR project)
- **Files**:
  - `src/version/hybrid_app_ada.ads` - parent package spec
  - `src/version/hybrid_app_ada-version.ads` - version constants
  - `src/version/version.gpr` - standalone library project
- **Components**:
  - `Version` - full semantic version string (e.g., "1.0.0")
  - `Major`, `Minor`, `Patch` - numeric components
  - `Prerelease`, `Build_Metadata` - optional identifiers
  - `Is_Prerelease`, `Is_Stable`, `Is_Development` - version predicates
- **Generation**: Auto-generated by `release.py prepare <version>` from alire.toml
- **Usage**: Presentation layer withs for CLI help version display

---

## 3. Detailed Design

### 3.1 Domain Layer Design

#### Value Objects

**Domain.Value_Object.Person**:
```ada
--  DESIGN DECISION: Public Record for Generic Instantiation
--  Person is public (not private) to enable generic instantiation:
--    package Person_Result is new Generic_Result (T => Person);
--  Clients MUST use Create for validation.
type Person is record
   Name_Value : Name_Strings.Bounded_String;
end record;

function Create (Name : String) return Person_Result.Result;
function Get_Name (Self : Person) return String;
function Is_Valid_Person (P : Person) return Boolean;
```

**Design Decisions**:
- Public record (required for generic instantiation)
- Validation in `Create` function only
- `Is_Valid_Person` for external validation/debugging
- Returns `Result[Person, Error]`
- Bounded strings (no heap allocation)
- Provides raw data (Get_Name), not formatted output

#### Error Handling

**Domain.Error**:
```ada
type Error_Kind is (Validation_Error, IO_Error);

type Error_Type is record
   Kind    : Error_Kind;
   Message : Bounded_String;
end record;

generic
   type T is private;
package Generic_Result is
   type Result (Is_Success : Boolean) is private;

   function Ok (Value : T) return Result;
   function Error (Kind : Error_Kind; Message : String) return Result;

   function Is_Ok (Self : Result) return Boolean;
   function Value (Self : Result) return T;
   function Error_Info (Self : Result) return Error_Type;
end Generic_Result;
```

**And_Then_Into (Cross-Type Chaining)**:
```ada
--  DESIGN DECISION: Cross-type monadic bind
--  Enables chaining operations that return different Result types
generic
   type T is private;
   type U is private;
   with package Source_Result is new Generic_Result (T => T);
   with package Target_Result is new Generic_Result (T => U);
   with function F (X : T) return Target_Result.Result;
function And_Then_Into (Self : Source_Result.Result) return Target_Result.Result;
```

**Design Decisions**:
- Discriminated record for Result (stack-based)
- No exceptions thrown
- Type-safe access (preconditions on Value/Error_Info)
- Generic package for reuse across types
- And_Then_Into for railway-oriented cross-type chaining

#### Domain.Error.Result vs Functional.Result

**IMPORTANT**: This project uses TWO different Result types:

| Type | Location | Purpose |
|------|----------|---------|
| `Domain.Error.Result.Generic_Result` | `src/domain/error/` | Domain-owned Result with domain-specific `Error_Type` (Kind + Message) |
| `Functional.Result.Generic_Result` | External `functional` crate | Generic Result for functional patterns, used by Try utilities |

**Why Two Result Types?**

1. **Domain Purity**: `Domain.Error.Result` keeps the domain layer pure with ZERO external dependencies. The domain defines its own error type (`Error_Kind`, `Error_Type`) with bounded strings.

2. **Infrastructure Bridging**: `Functional.Result` (from the `functional` crate) provides utilities like `Try_To_Result_With_Param` for exception handling at infrastructure boundaries.

**Bridging in Infrastructure**:
```ada
-- Infrastructure uses Functional.Try to catch exceptions
function Write_With_Try is new
  Functional.Try.Try_To_Result_With_Param (...);  -- Returns Functional.Result

-- Convert to Domain.Result for rest of system
function To_Domain_Result (FR : Functional_Result.Result) return Domain_Result.Result;

function Write (Message : String) return Unit_Result.Result is
   FR : constant Unit_Functional_Result.Result := Write_With_Try (Message);
begin
   return To_Domain_Result (FR);  -- Bridge at infrastructure boundary
end Write;
```

**Design Principle**: Domain.Error.Result flows through Domain → Application → Presentation. Functional.Result is only used in Infrastructure for exception bridging, then immediately converted to Domain.Result.

### 3.2 Application Layer Design

#### Use Cases

**Application.Usecase.Greet** (Generic):
```ada
generic
   with function Writer (Message : String) return Unit_Result.Result;
package Application.Usecase.Greet is
   function Execute (Cmd : Greet_Command) return Unit_Result.Result;
end Application.Usecase.Greet;
```

**Implementation**:
```ada
--  DESIGN DECISION: Greeting format in Application layer
--  Domain provides data (Get_Name), Application formats output
function Format_Greeting (Name : String) return String is
begin
   return "Hello, " & Name & "!";
end Format_Greeting;

function Execute (Cmd : Greet_Command) return Unit_Result.Result is
   Person_Result : constant Person_Result.Result :=
      Domain.Value_Object.Person.Create (Get_Name (Cmd));
begin
   if Person_Result.Is_Error then
      declare
         Err : constant Error_Type := Person_Result.Error_Info;
      begin
         return Unit_Result.Error
           (Kind    => Err.Kind,
            Message => Error_Strings.To_String (Err.Message));
      end;
   end if;

   declare
      Person  : constant Domain.Value_Object.Person.Person :=
        Person_Result.Value;
      Message : constant String := Format_Greeting (Get_Name (Person));
   begin
      return Writer (Message);
   end;
end Execute;
```

**Design Decisions**:
- Generic package (static dispatch)
- Writer function passed as generic parameter
- Railway-oriented error handling
- Format_Greeting at Application layer (not Domain)
- Domain provides raw data, Application formats

#### Command DTO

**Application.Command.Greet**:
```ada
--  DESIGN DECISION: Larger DTO boundary
--  DTO accepts up to 256 chars; Domain validates and rejects > 100 chars.
--  This boundary isolation allows Domain to shrink constraints independently.
Max_DTO_Name_Length : constant := 256;

package Name_Strings is new
  Ada.Strings.Bounded.Generic_Bounded_Length (Max => Max_DTO_Name_Length);

type Greet_Command is record
   Name : Name_Strings.Bounded_String;
end record;
```

**Design Decisions**:
- DTO has larger bounds than Domain (256 vs 100)
- Allows Domain to change validation independently
- Defense in depth (two validation points)
- No business logic in DTO

#### Application.Error Re-Export Pattern

**Problem**: Presentation cannot access Domain directly

**Solution**:
```ada
with Domain.Error;

package Application.Error is
   subtype Error_Type is Domain.Error.Error_Type;
   subtype Error_Kind is Domain.Error.Error_Kind;
   package Error_Strings renames Domain.Error.Error_Strings;

   Validation_Error : constant Error_Kind := Domain.Error.Validation_Error;
   IO_Error         : constant Error_Kind := Domain.Error.IO_Error;
end Application.Error;
```

**Benefits**:
- Zero overhead (subtype/renames)
- Maintains boundary (Presentation → Application only)
- Type-safe (compile-time verification)

### 3.3 Infrastructure Layer Design

**Infrastructure.Adapter.Console_Writer**:
```ada
--  Internal action that performs the I/O
function Write_Action (Message : String) return Unit is
begin
   Ada.Text_IO.Put_Line (Message);
   return Unit_Value;
end Write_Action;

--  Exception mapper
function Map_Exception (Occ : Exception_Occurrence)
  return Domain.Error.Error_Type
is (Domain.Error.New_Error
    (Kind    => Domain.Error.IO_Error,
     Message => "Console write failed: " & Exception_Message (Occ)));

--  Instantiate parameterized Try bridge
function Write_With_Try is new
  Functional.Try.Try_To_Result_With_Param
    (T             => Unit,
     E             => Domain.Error.Error_Type,
     Param         => String,
     Result_Pkg    => Unit_Functional_Result,
     Map_Exception => Map_Exception,
     Action        => Write_Action);

--  Public Write function
function Write (Message : String) return Unit_Result.Result is
   FR : constant Unit_Functional_Result.Result := Write_With_Try (Message);
begin
   return To_Domain_Result (FR);
end Write;
```

**Design Decisions**:
- Uses Functional.Try.Try_To_Result_With_Param for exception boundary
- Parameterized approach (no module-level state, thread-safe)
- Separates concerns: I/O action vs exception handling
- Implements outbound port signature
- Converts Functional.Result to Domain.Result

### 3.4 Presentation Layer Design

**Presentation.Adapter.CLI.Command.Greet** (Generic):
```ada
generic
   with function Execute_Greet_UseCase (Cmd : Greet_Command)
      return Unit_Result.Result;
package Presentation.Adapter.CLI.Command.Greet is
   function Run return Integer;
end Presentation.Adapter.CLI.Command.Greet;
```

**Design Decisions**:
- Generic (receives use case function)
- Returns exit code (0=success, 1=error)
- Uses Application.Error (not Domain.Error)

### 3.5 Bootstrap Design

**Bootstrap.CLI.Run**:
```ada
function Run return Integer is
   -- Step 1: Wire Infrastructure → Port
   package Writer_Port is new Application.Port.Outbound.Writer.Generic_Writer
     (Write => Infrastructure.Adapter.Console_Writer.Write);

   -- Step 2: Wire Use Case → Port
   package Greet_UseCase is new Application.Usecase.Greet
     (Writer => Writer_Port.Write_Message);

   -- Step 3: Wire Command → Use Case
   package Greet_Command is new Presentation.Adapter.CLI.Command.Greet
     (Execute_Greet_UseCase => Greet_UseCase.Execute);

   -- Step 4: Execute
   return Greet_Command.Run;
end Run;
```

**Design Decisions**:
- All wiring in one place
- Static instantiation (compile-time)
- Clear dependency flow
- No runtime overhead

---

## 4. Design Patterns

### 4.1 Railway-Oriented Programming

**Pattern**: Result monad for error handling
**Purpose**: Avoid exceptions, explicit error paths
**Implementation**: `Domain.Error.Result.Generic_Result`

```
Success Track:  Ok(Value) → Continue → Ok(Result)
Error Track:    Error → Propagate → Error
```

### 4.2 Hexagonal Architecture (Ports and Adapters)

**Pattern**: Decouple business logic from technical details
**Ports**: Interfaces defined in Application layer
**Adapters**: Implementations in Infrastructure/Presentation

### 4.3 Static Dependency Injection

**Pattern**: Generic packages with function parameters
**Wiring**: Bootstrap instantiates all generics
**Benefits**: Compile-time resolution, zero overhead, type-safe

### 4.4 Application Service Re-Export

**Pattern**: Facade pattern for layer boundaries
**Purpose**: Presentation cannot access Domain
**Implementation**: Application.Error re-exports Domain.Error

### 4.5 Value Object Pattern

**Pattern**: Immutable domain primitives with validation
**Implementation**: `Domain.Value_Object.Person`
**Benefits**: Type safety, validated at construction, immutable

### 4.6 DTO Boundary Isolation

**Pattern**: DTOs have larger bounds than Domain validation
**Purpose**: Allow Domain to change independently
**Implementation**: Command.Max_DTO_Name_Length (256) vs Domain.Max_Name_Length (100)

---

## 5. Data Flow

### 5.1 Request Flow (Success Path)

```
User: ./bin/greeter Alice
    ↓
main (greeter.adb): calls Bootstrap.CLI.Run
    ↓
Bootstrap.CLI.Run: wires dependencies, calls Presentation
    ↓
Presentation.Adapter.CLI.Command.Greet.Run: parses args, creates Greet_Command
    ↓
Application.Usecase.Greet.Execute: validates via Domain, formats greeting
    ↓
Domain.Value_Object.Person.Create: validates "Alice" → Ok(Person)
    ↓
Application.Usecase.Greet: Format_Greeting("Alice") → "Hello, Alice!"
    ↓
Infrastructure.Adapter.Console_Writer.Write: outputs "Hello, Alice!"
    ↓
Returns: Ok(Unit) → exit code 0
```

### 5.2 Error Flow

```
User: ./bin/greeter ""
    ↓
Domain.Value_Object.Person.Create: validates empty string
    ↓
Returns: Error(Validation_Error, "Name cannot be empty")
    ↓
Application.Usecase.Greet: checks Is_Error → propagates
    ↓
Presentation: pattern matches Error_Kind via Application.Error
    ↓
Displays: "Error: Name cannot be empty"
    ↓
Returns: exit code 1
```

---

## 6. Concurrency Design

### 6.1 Thread Safety

- **Domain**: Stateless, pure functions → inherently thread-safe
- **Application**: Stateless use cases → thread-safe
- **Infrastructure**: Adapters may have state (future consideration)
- **Presentation**: Single-threaded CLI (current design)

### 6.2 Future Concurrency Support

For concurrent use cases (v2.0+):
- Use Ada tasks with protected objects
- Ravenscar profile for safety-critical systems
- Port abstraction supports multiple implementations

---

## 7. Performance Design

### 7.1 Zero Overhead Abstractions

- **Static Dispatch**: Generics compiled to direct calls (no vtable)
- **Result Monad**: Stack-based discriminated record (no heap)
- **Bounded Strings**: Domain uses fixed-size buffers (no allocation)
- **Pure Functions**: Compiler can optimize aggressively

### 7.2 Memory Management

- **No Heap in Domain**: All bounded types
- **Stack Allocation**: Result values, commands
- **No Garbage Collection**: Deterministic cleanup

---

## 8. Security Design

### 8.1 Input Validation

- All validation in Domain layer
- Early rejection of invalid inputs
- Type-safe boundaries (compiler-enforced)
- DTO boundary provides defense in depth

### 8.2 Error Information

- No sensitive data in error messages
- Structured error types
- Safe for display to users

---

## 9. Build and Deployment

### 9.1 Project Structure

```
hybrid_app_ada/
├── hybrid_app_ada.gpr     # Main project file (single project)
├── alire.toml            # Alire manifest
├── Makefile              # Build automation
└── src/                  # All sources in one tree
```

**Design Decision**: Single-project structure (not aggregate)
**Benefits**: Simple deployment, Alire-compatible, fast builds

---

## 10. SPARK Readiness Assessment

### 10.1 Overview

This project is designed with SPARK verification as a future goal. While not currently using SPARK_Mode, the architecture follows SPARK-compatible patterns where possible.

### 10.2 Layer-by-Layer Assessment

| Layer | SPARK Readiness | Notes |
|-------|-----------------|-------|
| **Domain** | ✅ HIGH | Pure functions, no side effects, bounded types, value semantics |
| **Application** | ⚠️ MEDIUM | Mostly pure, but uses generic formal functions (SPARK 2014+ compatible) |
| **Infrastructure** | ❌ LOW | Uses Ada.Text_IO, exception handling, runtime tags |
| **Presentation** | ❌ LOW | Uses Ada.Command_Line, Text_IO, dynamic strings |
| **Bootstrap** | ⚠️ MEDIUM | Static wiring via generics, but instantiates non-SPARK layers |

### 10.3 SPARK-Compatible Components

**Domain Layer** (recommended for SPARK verification):
- `Domain.Value_Object.Person` - Bounded strings, validation, pure functions
- `Domain.Value_Object.Option.Generic_Option` - Pure functional monad
- `Domain.Error.Result.Generic_Result` - Pure Result monad
- `Domain.Error.Error_Type` - Simple bounded record
- `Domain.Unit` - Unit type (trivially SPARK-compatible)

**Application Layer** (mostly compatible):
- `Application.Command.Greet` - Simple DTO with bounded string
- `Application.Usecase.Greet` - Pure orchestration (via generic formal)

### 10.4 Non-SPARK Components

**Infrastructure** (SPARK-incompatible by design):
- `Infrastructure.Adapter.Console_Writer` - Uses `Ada.Text_IO`, exception handlers
- Uses `Functional.Try.Try_To_Result_With_Param` - Exception boundary wrapper

**Presentation** (SPARK-incompatible by design):
- `Presentation.Adapter.CLI.Command.Greet` - Uses `Ada.Command_Line`, `Ada.Text_IO`

### 10.5 Future SPARK Integration

To enable SPARK verification:

1. **Add SPARK_Mode aspects** to Domain packages:
   ```ada
   package Domain.Value_Object.Person
      with SPARK_Mode => On
   is
   ```

2. **Add contracts** (Pre/Post) to all public functions:
   ```ada
   function Create (Name : String) return Person_Result.Result
      with Pre => Name'Length > 0 and Name'Length <= Max_Name_Length;
   ```

3. **Explicitly mark Infrastructure as SPARK_Mode => Off**:
   ```ada
   package Infrastructure.Adapter.Console_Writer
      with SPARK_Mode => Off
   is
   ```

4. **Run GNATprove** on Domain layer to prove absence of runtime errors.

### 10.6 Design Decisions for SPARK

The following design decisions support future SPARK verification:

- **Bounded Strings in Domain**: Avoids dynamic memory (heap), enabling static analysis
- **Pure Functions**: No global state in Domain, easier to reason about
- **Result Monad over Exceptions**: Explicit error handling, no exception propagation
- **Discriminated Records**: Stack-allocated, deterministic memory
- **Immutable Value Objects**: No aliasing concerns

---

## 11. Testing Strategy

### 11.1 Test Organization

```
test/
├── unit/               # Domain + Application logic (74 tests)
├── integration/        # Cross-layer tests (8 tests)
├── e2e/                # Full system tests (8 tests)
└── common/             # Test framework
```

**Total Tests**: 90

### 11.2 Testing Approach

- **Unit**: Test Domain in isolation (pure functions)
- **Integration**: Test Application with real Infrastructure
- **E2E**: Test via CLI (black-box testing)

---

**Document Control**:
- Version: 1.0.0
- Last Updated: 2025-11-27
- Status: Released
- Copyright © 2025 Michael Gardner, A Bit of Help, Inc.
- License: BSD-3-Clause
- SPDX-License-Identifier: BSD-3-Clause
