// ============================================================================
// File: software_design_specification.typ
// Purpose: Software Design Specification for HYBRID_APP_ADA.
// Scope: Real project SDS content using the shared formal Typst core.
// Usage: Compile to PDF as the distribution artifact. The .typ source is the
//   authoritative document source.
// Modification Policy:
//   - Keep shared presentation logic in core.typ.
//   - Keep project-specific design content here.
// Table Ordering:
//   Sort any table whose rows a reader might scan to locate a specific
//   entry — definitions, acronyms, constraints, packages, interfaces,
//   and similar reference tables.  Sort alphabetically by the first
//   column.  Tables with an inherent sequence (requirement IDs within
//   a section, change history, workflow steps) retain their logical order.
// SPDX-License-Identifier: BSD-3-Clause
// ============================================================================

#import "core.typ": formal_doc

#let doc = (
  applies_to: "^2.0",
  authors: ("Michael Gardner",),
  copyright: "© 2026 Michael Gardner, A Bit of Help, Inc.",
  license_file: "See the LICENSE file in the project root",
  project_name: "HYBRID_APP_ADA",
  spdx_license: "BSD-3-Clause",
  status: "Released",
  status_date: "2026-04-26",
  title: "Software Design Specification",
  version: "2.0.1",
)

#let profile = (
  app_role: "cli",
  assurance: "spark-targeted",
  deployment: "native",
  execution: "sequential",
  execution_environment: ("linux", "macos", "windows"),
  library_role: none,
  parallelism: "none",
  platform: ("desktop", "server"),
  processor_architecture: ("amd64", "arm64"),
  variant: "application",
)

#let change_history = (
  (
    version: "2.0.1",
    date: "2025-12-11",
    author: "Michael Gardner",
    changes: "Added Section 6.1 Exception Boundary Specification with required/prohibited patterns and layered enforcement rules.",
  ),
  (
    version: "2.0.0",
    date: "2025-12-08",
    author: "Michael Gardner",
    changes: "Added Result combinators section; Windows CI support; updated test metrics to 109 total tests.",
  ),
  (
    version: "1.0.0",
    date: "2025-11-27",
    author: "Michael Gardner",
    changes: "Initial release.",
  ),
)

#show: formal_doc.with(doc, profile, change_history)

= Introduction

== Purpose

This Software Design Specification (SDS) describes the internal architecture, package structure, key type definitions, data-flow design, build strategy, and design decisions for *HYBRID_APP_ADA*.

== Scope

This document covers:
- the 5-layer application profile of the shared hybrid architecture family,
- package hierarchy and dependency rules,
- key type definitions and contracts,
- static dependency injection via Ada generics,
- exception-boundary enforcement,
- build and deployment choices, and
- SPARK-readiness guidance.

== References

- Software Requirements Specification (SRS).
- `docs/guides/architecture_enforcement.md`.
- Supporting UML diagrams maintained in `docs/diagrams/`.
- Ada 2022 Reference Manual.
- SPARK Reference Manual.

= Architectural Overview

== Architecture Style

*HYBRID_APP_ADA* uses the shared hybrid architecture family. Like the library profile, it preserves the same inner core: *Domain → Application → Infrastructure*. The application profile differs only at the outer boundary, where it uses *Presentation + Bootstrap* instead of the library API pattern.

Benefits of this style include:
- clear separation of concerns,
- testable business logic,
- swappable infrastructure adapters,
- compiler-enforced boundaries, and
- educational value for demonstrating correct use of the architecture.

== Layer Architecture

// Sort rows alphabetically by the first column.
#table(
  columns: (auto, 1fr, auto),
  table.header([*Layer / Boundary*], [*Purpose*], [*Depends On*]),
  [Application], [Use cases, commands, and port definitions.], [Domain],
  [Bootstrap],
  [Composition root that wires the application together through static dependency injection.],
  [All layers],

  [Domain],
  [Pure business concepts, error types, and value objects.],
  [Nothing],

  [Infrastructure],
  [Driven adapters implementing technical concerns and external integration.],
  [Application + Domain],

  [Presentation],
  [Driving adapters and user-interface entry points.],
  [Application only],
)

Detailed architecture guidance is maintained in `docs/guides/`. Supporting UML diagrams are maintained in `docs/diagrams/`.

== Layer Responsibilities

// Sort rows alphabetically by the first column.
#table(
  columns: (auto, 1fr),
  table.header([*Layer*], [*Responsibility*]),
  [Application],
  [Use-case orchestration, command DTOs, port definitions, and output formatting.],

  [Bootstrap],
  [Static composition root that performs generic instantiation and binds ports to adapters.],

  [Domain],
  [Pure business logic, value objects, error types, and result handling with zero external dependencies.],

  [Infrastructure],
  [Adapter implementations, exception-to-result conversion, and interaction with the outside world.],

  [Presentation],
  [User-interface handling, argument parsing, and error formatting through the application boundary.],

  [Version package],
  [Cross-cutting version metadata kept outside the hexagonal layers.],
)

== Dependency Rules

// Sort rows alphabetically by the first column.
#table(
  columns: (auto, 1fr),
  table.header([*Component*], [*May Depend On*]),
  [Application], [Domain only.],
  [Bootstrap], [All layers; Bootstrap is the intentional composition root.],
  [Domain], [Nothing (zero dependencies).],
  [Infrastructure], [Application and Domain.],
  [Presentation],
  [Application only; Presentation shall not depend directly on Domain.],
)

Architecture conformance is enforced through layered controls:
- project/build configuration constraints where applicable,
- active validation using `scripts/arch_guard.py`,
- execution of `scripts/arch_guard.py` during normal developer build workflow, and
- execution of `scripts/arch_guard.py` in CI/CD before non-conforming changes are accepted.

= Package Structure

== Directory Layout

```text
src/
├── hybrid_app_ada.ads              # Root package
├── version/
│   ├── hybrid_app_ada.ads          # Parent package spec
│   └── hybrid_app_ada-version.ads  # Version constants
│
├── domain/
│   ├── domain.ads
│   ├── domain-unit.ads
│   ├── error/
│   │   ├── domain-error.ads
│   │   └── domain-error-result.ads
│   └── value_object/
│       ├── domain-value_object.ads
│       ├── domain-value_object-option.ads
│       └── domain-value_object-person.ads
│
├── application/
│   ├── application.ads
│   ├── error/
│   │   └── application-error.ads
│   ├── command/
│   │   ├── application-command.ads
│   │   └── application-command-greet.ads
│   ├── port/
│   │   ├── application-port.ads
│   │   ├── inbound/
│   │   │   └── application-port-inbound.ads
│   │   └── outbound/
│   │       ├── application-port-outbound.ads
│   │       └── application-port-outbound-writer.ads
│   └── usecase/
│       ├── application-usecase.ads
│       └── application-usecase-greet.ads
│
├── infrastructure/
│   ├── infrastructure.ads
│   └── adapter/
│       ├── infrastructure-adapter.ads
│       └── infrastructure-adapter-console_writer.ads
│
├── presentation/
│   ├── presentation.ads
│   └── adapter/
│       ├── presentation-adapter.ads
│       └── cli/
│           ├── presentation-adapter-cli.ads
│           └── command/
│               ├── presentation-adapter-cli-command.ads
│               └── presentation-adapter-cli-command-greet.ads
│
└── bootstrap/
    ├── bootstrap.ads
    └── cli/
        ├── bootstrap-cli.ads
        └── bootstrap-cli-run.adb
```

== Package Descriptions

=== Domain Layer

// Sort rows alphabetically by the first column.
#table(
  columns: (auto, 1fr, auto),
  table.header([*Package*], [*Purpose*], [*SPARK*]),
  [`Domain`], [Layer root.], [On],
  [`Domain.Error`], [Error type with kind and bounded message.], [On],
  [`Domain.Error.Result`], [Generic Result[T] monad.], [On],
  [`Domain.Unit`], [Unit type for void-like operations.], [On],
  [`Domain.Value_Object`], [Value object root.], [On],
  [`Domain.Value_Object.Option`], [Option[T] monad.], [On],
  [`Domain.Value_Object.Person`], [Person value object.], [On],
)

=== Application Layer

// Sort rows alphabetically by the first column.
#table(
  columns: (auto, 1fr, auto),
  table.header([*Package*], [*Purpose*], [*SPARK*]),
  [`Application`], [Layer root.], [On],
  [`Application.Command.Greet`], [Greeting command DTO.], [On],
  [`Application.Error`],
  [Re-exports Domain.Error for Presentation consumption.],
  [On],

  [`Application.Port.Outbound.Writer`],
  [Writer outbound port definition.],
  [On],

  [`Application.Usecase.Greet`], [Greeting use case.], [On],
)

=== Infrastructure Layer

// Sort rows alphabetically by the first column.
#table(
  columns: (auto, 1fr, auto),
  table.header([*Package*], [*Purpose*], [*SPARK*]),
  [`Infrastructure`], [Layer root.], [Off],
  [`Infrastructure.Adapter.Console_Writer`],
  [Console output adapter implementing the Writer port.],
  [Off],
)

=== Presentation and Bootstrap

// Sort rows alphabetically by the first column.
#table(
  columns: (auto, 1fr, auto),
  table.header([*Package*], [*Purpose*], [*SPARK*]),
  [`Bootstrap.CLI.Run`],
  [Static composition root that wires adapters, ports, and use cases.],
  [Off],

  [`Hybrid_App_Ada.Version`],
  [Version information for CLI display and release metadata.],
  [Off],

  [`Presentation.Adapter.CLI.Command.Greet`],
  [CLI command adapter that parses arguments and maps results to exit codes.],
  [Off],
)

= Type Definitions

== Domain Types

=== Error_Kind

```ada
type Error_Kind is (Validation_Error, IO_Error);
```

=== Error_Type

```ada
type Error_Type is record
   Kind    : Error_Kind;
   Message : Error_Strings.Bounded_String;
end record;
```

=== Result (Generic)

```ada
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

=== Person Value Object

```ada
Max_Name_Length : constant := 100;
package Person_Strings is new Ada.Strings.Bounded.Generic_Bounded_Length
  (Max => Max_Name_Length);

type Person is record
   Name_Value : Person_Strings.Bounded_String;
end record;

function Create (Name : String) return Person_Result.Result;
function Get_Name (Self : Person) return String;
function Is_Valid_Person (P : Person) return Boolean;
```

Design decisions:
- public record required for generic instantiation,
- validation only through `Create`,
- immutable value semantics,
- bounded strings avoid heap allocation.

== Application Types

=== Greet_Command DTO

```ada
Max_DTO_Name_Length : constant := 256;
package Greet_Strings is new
  Ada.Strings.Bounded.Generic_Bounded_Length (Max => Max_DTO_Name_Length);

type Greet_Command is record
   Name : Greet_Strings.Bounded_String;
end record;
```

This boundary intentionally allows a larger DTO size than the Domain validation limit, so the Domain may evolve independently while maintaining defense in depth.

=== Application.Error Re-Export Pattern

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

This preserves the Presentation → Application boundary while still exposing the domain-owned error model through a zero-overhead re-export.

= Component Design

== Domain Layer Design

The Domain layer owns value objects, error types, the generic result monad, and pure validation logic. It is designed for SPARK compatibility and zero external dependencies.

== Application Layer Design

=== Greeting Use Case

```ada
generic
   with function Writer (Message : String) return Unit_Result.Result;
package Application.Usecase.Greet is
   function Execute (Cmd : Greet_Command) return Unit_Result.Result;
end Application.Usecase.Greet;
```

`Execute` validates the command via the Domain, formats the greeting through `Format_Greeting`, and delegates output through the outbound Writer port.

=== Format_Greeting Placement

A deliberate design decision places greeting formatting in the Application layer, not the Domain. The Domain provides data (`Get_Name`); the Application decides how that data is rendered for use by the application boundary.

== Infrastructure Layer Design

`Infrastructure.Adapter.Console_Writer` performs console I/O, catches exceptions through `Functional.Try.Try_To_Result_With_Param`, maps them to domain errors, and converts `Functional.Result` values back into `Domain.Error.Result` values before returning to the rest of the system.

== Presentation Layer Design

`Presentation.Adapter.CLI.Command.Greet` receives a use-case function as a generic formal, parses arguments, invokes the application boundary, formats errors using `Application.Error`, and returns an exit code.

== Bootstrap Design

`Bootstrap.CLI.Run` acts as the composition root. It:
- wires Infrastructure to the outbound Writer port,
- wires the use case to the port,
- wires the CLI command adapter to the use case, and
- executes the command.

All dependency injection is static and resolved at compile time.

= Design Patterns

// Sort rows alphabetically by the first column.
#table(
  columns: (auto, 1fr),
  table.header([*Pattern*], [*Use in HYBRID_APP_ADA*]),
  [Application Service Re-Export],
  [Application.Error re-exports Domain.Error to preserve boundaries.],

  [DTO Boundary Isolation],
  [Commands allow larger bounds than domain validation to support independent evolution.],

  [Hexagonal Architecture],
  [Ports defined in Application; adapters in Infrastructure and Presentation.],

  [Railway-Oriented Programming],
  [Result-monad based error handling using `Domain.Error.Result.Generic_Result`.],

  [Static Dependency Injection],
  [Ada generics wire ports to implementations in Bootstrap.],

  [Value Object Pattern],
  [Immutable, validated domain primitives such as `Person`.],
)

== Exception Boundary Specification

This project uses a layered exception-boundary strategy consistent with the shared hybrid architecture family.

// Sort rows alphabetically by the first column.
#table(
  columns: (auto, auto, auto, 1fr),
  table.header(
    [*Layer*], [*Functional.Try*], [*Manual `exception`*], [*Rationale*]
  ),
  [Application],
  [N/A],
  [Forbidden],
  [Use-case orchestration through Result types only.],

  [Bootstrap], [Optional], [Allowed], [Startup and wiring may fail fast.],
  [Domain],
  [N/A],
  [Forbidden],
  [Core logic and value semantics; runtime exceptions indicate bugs.],

  [Infrastructure],
  [Required],
  [Forbidden],
  [Boundary to external systems and I/O.],

  [Main / entry point], [Optional], [Allowed], [Top-level clean exit handling.],
  [Presentation],
  [Required],
  [Forbidden],
  [Boundary to user input and UI concerns.],

  [Test], [Optional], [Allowed], [Tests may validate exceptional scenarios.],
)

Required pattern:
- Presentation and Infrastructure boundaries shall use `Functional.Try` wrappers.
- Manual exception handlers are prohibited in Presentation and Infrastructure.
- Domain and Application shall not contain `exception` handling logic.

Core philosophy:
- if an exception occurs in Domain or Application, it indicates a bug, missing validation, or incomplete contracts,
- such failures should be corrected, not normalized into routine runtime handling.

Validation enforcement:
- `scripts/arch_guard.py` validates direct dependency rules as part of local developer workflow and CI/CD,
- project/build configuration provides complementary boundary enforcement where applicable.

= Data Flow

== Success Path

```text
User CLI input
  -> main / Bootstrap.CLI.Run
  -> Presentation.Adapter.CLI.Command.Greet
  -> Application.Usecase.Greet.Execute
  -> Domain.Value_Object.Person.Create
  -> Application.Format_Greeting
  -> Infrastructure.Adapter.Console_Writer.Write
  -> exit code 0
```

== Error Path

```text
Invalid user input
  -> Domain validation fails
  -> Domain.Error.Result propagated upward
  -> Presentation formats Application.Error for the user
  -> exit code 1
```

= Concurrency Design

== Thread Safety

- Domain: stateless and pure; inherently thread-safe.
- Application: stateless orchestration; thread-safe.
- Infrastructure: adapters may carry state in future variants.
- Presentation: current CLI design is single-threaded.

== Future Concurrency Support

Potential future extensions may use Ada tasks and protected objects, including Ravenscar-oriented designs for stricter targets. The port abstraction keeps this path open without changing the core architecture.

= Performance and Memory Design

== Zero-Overhead Abstractions

- static dispatch through generics,
- stack-based discriminated Result values,
- bounded strings in the Domain,
- pure functions that are friendly to optimization.

== Memory Management

- no heap allocation in the Domain,
- stack allocation for result values and commands,
- deterministic cleanup without garbage collection.

= Security Design

== Input Validation

All input validation is enforced through the Domain layer, with the command DTO boundary providing defense in depth.

== Error Information

Error messages are structured and bounded. They are intended to be safe for user display and should not contain sensitive information.

= Build and Deployment

== Project Structure

```text
hybrid_app_ada/
├── hybrid_app_ada.gpr
├── alire.toml
├── Makefile
└── src/
```

Design decision:
- single-project structure rather than an aggregate, to keep deployment simple, Alire-compatible, and fast to build.

== Platform Support

#table(
  columns: (auto, auto, 1fr),
  table.header([*Platform*], [*Status*], [*Notes*]),
  [Linux], [Full], [Fully supported.],
  [macOS], [Full], [Primary development platform.],
  [Windows], [Full], [Supported through CI and runtime validation.],
  [BSD], [Manual], [Builds may succeed but are not CI-covered.],
  [Embedded], [Planned], [Would require custom adapters.],
)

= SPARK Readiness Assessment

== Overview

The project is designed with future SPARK verification in mind. The architecture follows SPARK-compatible patterns where practical, even though the full application is not a pure SPARK system.

== Layer Assessment

// Sort rows alphabetically by the first column.
#table(
  columns: (auto, auto, 1fr),
  table.header([*Layer*], [*SPARK Readiness*], [*Notes*]),
  [Application], [Medium], [Mostly pure orchestration and generic formals.],
  [Bootstrap], [Medium], [Static wiring, but instantiates non-SPARK layers.],
  [Domain], [High], [Pure functions, bounded types, no side effects.],
  [Infrastructure], [Low], [Uses Text_IO and boundary exception handling.],
  [Presentation], [Low], [Uses command-line and UI concerns.],
)

== SPARK-Compatible Components

Recommended SPARK targets include:
- `Domain.Value_Object.Person`,
- `Domain.Value_Object.Option.Generic_Option`,
- `Domain.Error.Result.Generic_Result`,
- `Domain.Error.Error_Type`, and
- `Application.Command.Greet` plus much of `Application.Usecase.Greet`.

== Future SPARK Integration

Future SPARK work would add explicit `SPARK_Mode` aspects, contracts on public functions, explicit `SPARK_Mode => Off` markers for non-SPARK layers, and GNATprove runs over the Domain-first core.

= Testing Strategy

== Test Organization

```text
test/
├── unit/         # Domain + Application logic
├── integration/  # Cross-layer tests
├── e2e/          # Full system tests
└── common/       # Test framework
```

Current metrics:
- 85 unit tests,
- 16 integration tests,
- 8 end-to-end tests,
- 109 total tests.

== Testing Approach

- Unit tests focus on Domain and Application logic.
- Integration tests exercise cross-layer collaboration.
- End-to-end tests validate the application through the CLI boundary.

= Version 2.0.0 Enhancements

== Result Combinator Patterns

Version 2.0.0 adopted the richer combinator set from `functional` 3.0.0, including:
- `Bimap`,
- `Ensure`,
- `With_Context`,
- `Fallback`,
- `Recover`, and
- `Tap`.

These improve expressiveness without changing the underlying Result-oriented design.

== Windows CI Support

Version 2.0.0 also formalized Windows CI/runtime support as part of the platform matrix.
