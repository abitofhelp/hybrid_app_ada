// ============================================================================
// File: software_test_guide.typ
// Purpose: Software Test Guide for HYBRID_APP_ADA.
// Scope: Real project test strategy, organization, execution, traceability,
//   framework, and maintenance guidance for the application profile.
// Usage: This is an authoritative Typst source document. The generated PDF is
//   the distribution artifact.
// Modification Policy:
//   - Edit this file for project-specific STG content.
//   - Keep shared presentation logic in core.typ.
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
  title: "Software Test Guide",
  project_name: "HYBRID_APP_ADA",
  authors: ("Michael Gardner",),
  version: "2.1.0",
  status: "Released",
  status_date: "2025-12-14",
  spdx_license: "BSD-3-Clause",
  license_file: "See the LICENSE file in the project root",
  copyright: "© 2025 Michael Gardner, A Bit of Help, Inc.",
)

#let profile = (
  variant: "application",
  library_role: none,
  app_role: "cli",
  assurance: "spark-targeted",
  execution: "sequential",
  parallelism: "none",
  platform: ("desktop", "server"),
  execution_environment: ("linux", "macos", "windows"),
  processor_architecture: ("amd64", "arm64"),
  deployment: "native",
)

#let change_history = (
  (
    version: "2.1.0",
    date: "2025-12-14",
    author: "Michael Gardner",
    changes: "Remove hardcoded metrics per documentation standards; metrics now in CHANGELOG.",
  ),
  (
    version: "2.0.0",
    date: "2025-12-09",
    author: "Michael Gardner",
    changes: "Complete regeneration for v2.0.0; added combinator and platform coverage guidance.",
  ),
  (
    version: "1.0.0",
    date: "2025-11-29",
    author: "Michael Gardner",
    changes: "Initial release.",
  ),
)

#show: formal_doc.with(doc, profile, change_history)

#set heading(numbering: "1.1.")

// Supporting architecture guidance is maintained in docs/guides/.
// Supporting UML diagrams are maintained in docs/diagrams/.

= Introduction

== Purpose

This Software Test Guide (STG) describes the testing approach, test organization, execution procedures, and maintenance guidance for *HYBRID_APP_ADA*.

== Scope

This document covers:
- unit, integration, and end-to-end testing
- custom test framework design and usage
- test execution through `make` targets and direct commands
- architecture validation tests
- coverage analysis guidance
- maintenance procedures for the test suite

== References

- Software Requirements Specification (SRS)
- Software Design Specification (SDS)
- `docs/guides/architecture_enforcement.md`

= Test Strategy

== Testing Levels

// Sort rows alphabetically by the first column.
#table(
  columns: (auto, auto, 1fr),
  table.header([Level], [Location], [Purpose]),
  [End-to-End Tests], [`test/e2e/`], [Test the full application through the CLI as a black-box interface.],
  [Integration Tests], [`test/integration/`], [Test cross-layer interactions with real adapters and wiring.],
  [Unit Tests], [`test/unit/`], [Test individual components in isolation, especially Domain and Application logic.],
)

See CHANGELOG for current test counts per release.

== Testing Philosophy

- *Test-Driven:* tests are written alongside or before implementation where practical.
- *Railway-Oriented:* both success and error paths are exercised.
- *Comprehensive:* normal, edge, and error cases are all represented.
- *Automated:* all tests are runnable through `make test-all`.
- *Self-Contained:* no external test framework dependency is required.
- *Fast Feedback:* the suite is intended to support frequent local execution during development.

= Test Organization

== Directory Structure

```text
test/
├── common/
│   └── test_framework.ads/adb       # Custom test framework
├── unit/
│   ├── test_domain_error_result.adb
│   ├── test_domain_person.adb
│   ├── test_application_command_greet.adb
│   ├── test_application_usecase_greet.adb
│   ├── unit_runner.adb
│   └── unit_tests.gpr
├── integration/
│   ├── test_greet_full_flow.adb
│   ├── test_infrastructure_console_writer.adb
│   ├── integration_runner.adb
│   └── integration_tests.gpr
└── e2e/
    ├── test_greeter_cli.adb
    ├── e2e_runner.adb
    └── e2e_tests.gpr
```

== Naming Conventions

// Sort rows alphabetically by the first column.
#table(
  columns: (auto, auto, 1fr),
  table.header([Element], [Convention], [Example]),
  [Framework file], [`test_framework.ads/adb`], [`test/common/test_framework.ads`],
  [Project file], [`<category>_tests.gpr`], [`e2e_tests.gpr`],
  [Runner], [`<category>_runner.adb`], [`integration_runner.adb`],
  [Test file], [`test_<layer>_<component>.adb`], [`test_application_usecase_greet.adb`],
)

== Architectural Coverage Intent

The test organization reflects the same hybrid architecture family used by the application itself:
- Domain and Application are heavily exercised through unit tests.
- Infrastructure wiring is validated through integration tests.
- Presentation and Bootstrap are validated through end-to-end execution.
- `scripts/arch_guard.py` validates direct dependency rules during developer workflow and CI/CD.

= Custom Test Framework

== Framework Overview

The custom lightweight framework in `test/common/test_framework.ads` provides:
- result registration and aggregation
- per-category summary output
- grand total reporting across categories
- deterministic pass/fail reporting without external dependencies

== Framework Usage Pattern

```ada
procedure Test_My_Component is
   Total_Tests  : Natural := 0;
   Passed_Tests : Natural := 0;

   procedure Run_Test (Name : String; Passed : Boolean) is
   begin
      Total_Tests := Total_Tests + 1;
      if Passed then
         Passed_Tests := Passed_Tests + 1;
      end if;
   end Run_Test;

begin
   Run_Test ("Feature works", Condition);
   Test_Framework.Register_Results (Total_Tests, Passed_Tests);
end Test_My_Component;
```

== Rationale

A custom framework keeps the project self-contained, simple to understand, and aligned with the educational purpose of the starter while still supporting repeatable automated testing.

= Test Execution

== Primary Commands

```bash
make test-all
make test-unit
make test-integration
make test-e2e
```

== Direct Execution

Test categories may also be executed through the relevant GPR project and runner executable when direct troubleshooting is needed.

== Expected Behavior

- unit tests validate isolated logic and data handling
- integration tests validate wiring and adapter behavior
- e2e tests validate complete user-visible CLI behavior and exit codes

= Test Details

== Unit Tests

=== Domain Tests

- `test_domain_error_result.adb` — tests `Domain.Error.Result`
- `test_domain_person.adb` — tests `Domain.Value_Object.Person`

=== Application Tests

- `test_application_command_greet.adb` — tests command DTO behavior
- `test_application_usecase_greet.adb` — tests the greet use case with controlled dependencies

=== Combinator Tests

The application test suite should include coverage for Result-monad combinators and related functional control-flow helpers where those abstractions are part of the design.

== Integration Tests

- `test_greet_full_flow.adb` — tests the complete greeting flow through real wiring
- `test_infrastructure_console_writer.adb` — tests console-writer adapter behavior

== End-to-End Tests

- `test_greeter_cli.adb` — tests the application through its CLI boundary
- verifies end-to-end user scenarios and exit codes
- stdout detail validation is primarily handled in lower-level tests where appropriate

== Architecture Validation Tests

`scripts/arch_guard.py` validates direct dependency rules for the application architecture profile. This validation is run during normal developer workflow and again in CI/CD.

= Coverage and Quality Gates

== Coverage Expectations

Coverage analysis may be performed with GNATcoverage or equivalent tooling appropriate to the host environment. Exact target values are maintained outside this guide when they change frequently.

== Success Criteria

A healthy test run should demonstrate:
- passing unit tests
- passing integration tests
- passing e2e tests
- passing architecture validation
- no unresolved regressions in supported paths

== Platform Considerations

Platform-specific test behavior, if any, shall be documented explicitly in project CHANGELOG or supporting guides rather than embedded as stale metrics here.

= Writing New Tests

== Adding a New Unit or Integration Test

- create the test source using the naming convention
- add the executable to the relevant GPR file
- register results through the shared framework
- place the test in the category that best reflects the behavior under test

== Adding a New End-to-End Test

- validate a user-visible scenario through the CLI boundary
- focus on observable behavior and exit status
- avoid duplicating fine-grained validation already covered in lower-level tests

== Regression Tests

When defects are fixed, add or update tests so the corrected behavior is permanently covered.

= Traceability

== Requirements to Test Categories

// Sort rows alphabetically by the first column.
#table(
  columns: (auto, 1fr),
  table.header([Requirement Area], [Primary Test Coverage]),
  [Application use cases and DTO behavior], [Unit tests and integration tests],
  [Architecture boundary enforcement], [`scripts/arch_guard.py`],
  [Domain validation and Result handling], [Unit tests],
  [Infrastructure adapter behavior], [Integration tests],
  [Presentation / CLI behavior], [End-to-end tests],
)

== Detailed Traceability

A detailed requirement-to-test mapping may be expanded project-locally as requirements stabilize or as additional verification evidence is needed.

= Test Maintenance

== When to Update the Suite

- when new packages or features are added
- when public CLI behavior changes
- when bug fixes require regression protection
- when architecture rules or boundaries change
- when test tooling or execution targets change

== Maintenance Guidelines

- keep test names descriptive
- keep tests independent where practical
- reset mock or shared state between test cases
- prefer deterministic behavior over timing-sensitive assertions
- avoid pushing volatile count metrics into this guide

== Continuous Integration

The full validation path should run in CI/CD, including:
- build
- unit tests
- integration tests
- e2e tests
- architecture validation

