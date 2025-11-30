# Software Test Guide

**Version:** 1.0.0<br>
**Date:** 2025-11-29<br>
**SPDX-License-Identifier:** BSD-3-Clause<br>
**License File:** See the LICENSE file in the project root<br>
**Copyright:** © 2025 Michael Gardner, A Bit of Help, Inc.<br>
**Status:** Released

---

## 1. Introduction

### 1.1 Purpose

This Software Test Guide describes the testing approach, test organization, execution procedures, and guidelines for the Hybrid_App_Ada project.

### 1.2 Scope

This document covers:
- Test strategy and organization (unit/integration/e2e)
- Custom test framework design
- Running tests via Make and direct execution
- Writing new tests
- Coverage analysis with GNATcoverage
- Test maintenance procedures

---

## 2. Test Strategy

### 2.1 Testing Levels

Hybrid_App_Ada uses three levels of testing:

**Unit Tests** (74 tests)
- Test individual components in isolation
- Focus on Domain and Application logic
- Pure functions, predictable results
- Fast execution
- Location: `test/unit/`

**Integration Tests** (8 tests)
- Test cross-layer interactions
- Real Infrastructure adapters
- Application use cases with dependencies
- Verify wiring works correctly
- Location: `test/integration/`

**End-to-End Tests** (8 tests)
- Test entire system via CLI
- Black-box testing
- User scenarios
- Exit code verification
- Location: `test/e2e/`

### 2.2 Testing Philosophy

- **Test-Driven**: Tests written alongside or before code
- **Railway-Oriented**: Test both success and error paths
- **Comprehensive**: Cover normal, edge, and error cases
- **Automated**: All tests runnable via `make test-all`
- **Fast**: All 90 tests execute in < 5 seconds
- **Self-Contained**: No external dependencies (custom framework)

---

## 3. Test Organization

### 3.1 Directory Structure

```
test/
├── common/
│   └── test_framework.ads/adb       # Custom test framework
├── unit/
│   ├── test_domain_error_result.adb # Domain Result tests
│   ├── test_domain_person.adb       # Person value object tests
│   ├── test_application_command_greet.adb  # Command DTO tests
│   ├── test_application_usecase_greet.adb  # Use case tests
│   ├── unit_runner.adb              # Unit test runner
│   └── unit_tests.gpr               # Unit tests project
├── integration/
│   ├── test_greet_full_flow.adb     # Full use case integration
│   ├── test_infrastructure_console_writer.adb  # Adapter tests
│   ├── integration_runner.adb       # Integration test runner
│   └── integration_tests.gpr        # Integration tests project
└── e2e/
    ├── test_greeter_cli.adb         # CLI end-to-end tests
    ├── e2e_runner.adb               # E2E test runner
    └── e2e_tests.gpr                # E2E tests project
```

### 3.2 Test Naming Convention

- **Pattern**: `test_<layer>_<component>.adb`
- **Examples**:
  - `test_domain_person.adb` → Tests `Domain.Value_Object.Person`
  - `test_application_usecase_greet.adb` → Tests `Application.Usecase.Greet`
  - `test_infrastructure_console_writer.adb` → Tests `Infrastructure.Adapter.Console_Writer`

---

## 4. Custom Test Framework

### 4.1 Design Rationale

Hybrid_App_Ada uses a **custom lightweight test framework** instead of AUnit:

**Benefits**:
- No external test framework dependency
- Simple, easy to understand (< 100 lines)
- Full control over assertion messages
- Educational value (see how test frameworks work)
- Fast compilation and execution

### 4.2 Framework API

Located in `test/common/test_framework.{ads,adb}`:

```ada
package Test_Framework is
   --  Track test results globally
   procedure Register_Results (Total : Natural; Passed : Natural);

   --  Get aggregate results across all test modules
   function Get_Total_Tests return Natural;
   function Get_Total_Passed return Natural;

   --  Report final summary
   procedure Print_Grand_Total;
end Test_Framework;
```

### 4.3 Example Test

```ada
pragma Ada_2022;
with Ada.Text_IO;
with Domain.Value_Object.Person;
with Test_Framework;

procedure Test_Domain_Person is
   use Ada.Text_IO;
   use Domain.Value_Object.Person;

   Total_Tests  : Natural := 0;
   Passed_Tests : Natural := 0;

   procedure Run_Test (Name : String; Passed : Boolean) is
   begin
      Total_Tests := Total_Tests + 1;
      if Passed then
         Passed_Tests := Passed_Tests + 1;
         Put_Line ("[PASS] " & Name);
      else
         Put_Line ("[FAIL] " & Name);
      end if;
   end Run_Test;

begin
   Put_Line ("Testing: Domain.Value_Object.Person");

   --  Test successful creation
   declare
      Result : constant Person_Result.Result := Create ("Alice");
   begin
      Run_Test ("Create valid name - Is_Ok",
                Person_Result.Is_Ok (Result));
      if Person_Result.Is_Ok (Result) then
         Run_Test ("Create valid name - Get_Name correct",
                   Get_Name (Person_Result.Value (Result)) = "Alice");
      end if;
   end;

   --  Test validation error
   declare
      Result : constant Person_Result.Result := Create ("");
   begin
      Run_Test ("Create empty name - Is_Error",
                Person_Result.Is_Error (Result));
   end;

   --  Register results with framework
   Test_Framework.Register_Results (Total_Tests, Passed_Tests);
end Test_Domain_Person;
```

---

## 5. Running Tests

### 5.1 Quick Start

```bash
# Run all 90 tests
make test-all

# Run specific test level
make test-unit          # 74 unit tests
make test-integration   # 8 integration tests
make test-e2e           # 8 e2e tests
```

### 5.2 Make Targets

**Test Execution**:
```bash
make test               # Alias for test-all
make test-all           # Run all test executables
make test-unit          # Unit tests only
make test-integration   # Integration tests only
make test-e2e           # E2E tests only
```

**Build and Test**:
```bash
make build              # Build main project
make test-all           # Build tests and run
```

**Coverage**:
```bash
make build-coverage-runtime  # One-time setup
make test-coverage           # Run with GNATcoverage analysis
```

### 5.3 Direct Execution

```bash
# Run unit test runner (all unit tests)
./test/bin/unit_runner

# Run individual test executable
./test/bin/test_domain_person
./test/bin/test_domain_error_result
./test/bin/test_application_command_greet
./test/bin/test_application_usecase_greet

# Run integration tests
./test/bin/test_greet_full_flow
./test/bin/test_infrastructure_console_writer

# Run E2E tests
./test/bin/test_greeter_cli
```

### 5.4 Expected Output

**Success**:
```
========================================
Testing: Domain.Value_Object.Person
========================================

[PASS] Create valid name - Is_Ok
[PASS] Create valid name - Get_Name correct
[PASS] Create empty name - Is_Error
[PASS] Create empty name - error kind is Validation_Error
[PASS] Create empty name - error message contains 'empty'

========================================
Test Summary: Domain.Value_Object.Person
========================================
Total tests:  22
Passed:       22
Failed:       0
```

**Grand Total**:
```
========================================
        GRAND TOTAL - ALL UNIT TESTS
========================================
Total tests:   74
Passed:        74
Failed:        0

########################################
###                                  ###
###    UNIT TESTS: SUCCESS
###    All  74 tests passed!
###                                  ###
########################################
```

---

## 6. Writing New Tests

### 6.1 Unit Test Template

```ada
pragma Ada_2022;
with Ada.Text_IO;
with Your.Component;
with Test_Framework;

procedure Test_Your_Component is
   use Ada.Text_IO;
   use Your.Component;

   Total_Tests  : Natural := 0;
   Passed_Tests : Natural := 0;

   procedure Run_Test (Name : String; Passed : Boolean) is
   begin
      Total_Tests := Total_Tests + 1;
      if Passed then
         Passed_Tests := Passed_Tests + 1;
         Put_Line ("[PASS] " & Name);
      else
         Put_Line ("[FAIL] " & Name);
      end if;
   end Run_Test;

begin
   Put_Line ("Testing: Your.Component");

   --  Test case 1: Success scenario
   declare
      Result : constant Result_Type := Some_Function (Valid_Input);
   begin
      Run_Test ("Valid input - Is_Ok", Is_Ok (Result));
   end;

   --  Test case 2: Error scenario
   declare
      Result : constant Result_Type := Some_Function (Invalid_Input);
   begin
      Run_Test ("Invalid input - Is_Error", Is_Error (Result));
   end;

   --  Register with framework
   Test_Framework.Register_Results (Total_Tests, Passed_Tests);
end Test_Your_Component;
```

### 6.2 Integration Test Template

```ada
pragma Ada_2022;
with Ada.Text_IO;
with Application.Usecase.Your_UseCase;
with Infrastructure.Adapter.Your_Adapter;
with Test_Framework;

procedure Test_Your_UseCase_Integration is
   use Ada.Text_IO;

   Total_Tests  : Natural := 0;
   Passed_Tests : Natural := 0;

   procedure Run_Test (Name : String; Passed : Boolean) is
   begin
      Total_Tests := Total_Tests + 1;
      if Passed then
         Passed_Tests := Passed_Tests + 1;
         Put_Line ("[PASS] " & Name);
      else
         Put_Line ("[FAIL] " & Name);
      end if;
   end Run_Test;

begin
   Put_Line ("Testing: Your Use Case Integration");

   --  Test with real infrastructure
   declare
      Cmd    : constant Your_Command := Create ("test_data");
      Result : constant Unit_Result.Result := Execute (Cmd);
   begin
      Run_Test ("Full flow succeeds", Unit_Result.Is_Ok (Result));
   end;

   Test_Framework.Register_Results (Total_Tests, Passed_Tests);
end Test_Your_UseCase_Integration;
```

### 6.3 Adding Tests to GPR Files

**Unit Tests** (`test/unit/unit_tests.gpr`):
```gprbuild
project Unit_Tests is
   for Main use (
      "unit_runner.adb",
      "test_domain_error_result.adb",
      "test_domain_person.adb",
      "test_application_command_greet.adb",
      "test_application_usecase_greet.adb",
      "test_your_new_component.adb"  -- Add new test here
   );
end Unit_Tests;
```

---

## 7. Test Coverage

### 7.1 Coverage Goals

- **Target**: > 90% line coverage
- **Critical Code**: 100% coverage for error handling paths
- **Domain Layer**: Near 100% coverage (pure functions, easy to test)

### 7.2 Running Coverage Analysis

```bash
# First-time setup: build GNATcoverage runtime
make build-coverage-runtime

# Generate coverage report
make test-coverage

# Coverage data generated in coverage/ directory
# - coverage/index.html - HTML report
# - coverage/*.xcov - Detailed coverage files
```

### 7.3 Interpreting Results

Coverage report shows:
- Lines executed vs total
- Branches taken
- Functions covered
- Per-file statistics

---

## 8. Test Maintenance

### 8.1 When to Update Tests

- **New Features**: Add tests before implementing
- **Bug Fixes**: Add regression test first
- **Refactoring**: Ensure tests still pass
- **Requirements Change**: Update affected tests

### 8.2 Test Quality Guidelines

- **One Assertion Per Test Case**: Clear failure messages
- **Descriptive Names**: Test names explain what's being verified
- **Arrange-Act-Assert**: Structure tests clearly
- **No Business Logic**: Tests should be simple
- **Fast Execution**: Avoid slow operations

### 8.3 Debugging Failed Tests

```bash
# Run single test for debugging
./test/bin/test_domain_person

# Add debug output (temporarily)
Ada.Text_IO.Put_Line ("Debug: Value = " & Value'Image);

# Use gdb for step-through debugging
gdb ./test/bin/test_domain_person
```

---

## 9. Testing Patterns

### 9.1 Testing Result Monads

```ada
--  Test success path
declare
   Result : constant Person_Result.Result := Create ("Alice");
begin
   Run_Test ("Success - Is_Ok", Person_Result.Is_Ok (Result));
   if Person_Result.Is_Ok (Result) then
      Run_Test ("Success - correct value",
                Get_Name (Person_Result.Value (Result)) = "Alice");
   end if;
end;

--  Test error path
declare
   Result : constant Person_Result.Result := Create ("");
begin
   Run_Test ("Error - Is_Error", Person_Result.Is_Error (Result));
   if Person_Result.Is_Error (Result) then
      declare
         Err : constant Error_Type := Person_Result.Error_Info (Result);
      begin
         Run_Test ("Error - correct kind",
                   Err.Kind = Validation_Error);
      end;
   end if;
end;
```

### 9.2 Testing with Mock Writers

```ada
--  Capture the last written message for testing
Last_Written_Message : Unbounded_String;

function Mock_Writer_Success (Message : String) return Unit_Result.Result is
begin
   Last_Written_Message := To_Unbounded_String (Message);
   return Unit_Result.Ok (Unit_Value);
end Mock_Writer_Success;

--  Instantiate use case with mock
package Greet_UseCase_Test is new Application.Usecase.Greet
  (Writer => Mock_Writer_Success);

--  Test
declare
   Cmd    : constant Greet_Command := Create ("Alice");
   Result : constant Unit_Result.Result := Greet_UseCase_Test.Execute (Cmd);
begin
   Run_Test ("Execute - Is_Ok", Unit_Result.Is_Ok (Result));
   Run_Test ("Execute - message written",
             To_String (Last_Written_Message) = "Hello, Alice!");
end;
```

---

## 10. Test Statistics

### 10.1 Current Test Metrics (v1.0.0)

**Test Count**:
- Total: 90 tests
  - Unit: 74 (82%)
  - Integration: 8 (9%)
  - E2E: 8 (9%)
- Pass Rate: 100%

**Coverage by Layer**:
- Domain Layer: High (pure functions, fully tested)
- Application Layer: High (use cases covered)
- Infrastructure Layer: Adequate (integration tests)
- Presentation Layer: Good (E2E tests)
- Bootstrap Layer: Verified (E2E tests)

**Execution Time**:
- Unit tests: < 1 second
- Integration tests: < 1 second
- E2E tests: < 2 seconds
- Total: < 5 seconds (all 90 tests)

---

## 11. Troubleshooting

### 11.1 Common Issues

**Q: Tests fail to compile**

A: Ensure you've built the main project first:
```bash
make build
```
Tests depend on the built libraries.

**Q: Test runner not found**

A: Test executables are in `test/bin/`:
```bash
ls test/bin/
```

**Q: All tests fail with similar errors**

A: Rebuild all:
```bash
make clean
make build
make test-all
```

**Q: Coverage target fails**

A: Ensure GNATcoverage runtime is built:
```bash
make build-coverage-runtime
make test-coverage
```

---

## 12. Continuous Integration

### 12.1 CI Testing Strategy

All tests run on every commit:

```bash
# CI pipeline equivalent
make clean
make build
make test-all
make check-arch
```

### 12.2 Success Criteria

All must pass:
- ✅ Zero build warnings
- ✅ All 90 tests pass (100% pass rate)
- ✅ Architecture validation passes
- ✅ Exit code 0 from test runners

---

**Document Control**:
- Version: 1.0.0
- Last Updated: 2025-11-27
- Status: Released
- Copyright © 2025 Michael Gardner, A Bit of Help, Inc.
- License: BSD-3-Clause
- SPDX-License-Identifier: BSD-3-Clause
