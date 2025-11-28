# Changelog

**Version:** 1.0.0  
**Date:** November 28, 2025  
**SPDX-License-Identifier:** BSD-3-Clause  
**License File:** See the LICENSE file in the project root.  
**Copyright:** (c) 2025 Michael Gardner, A Bit of Help, Inc.  
**Status:** Released  


**Project:** Hybrid_App_Ada - Ada 2022 Application Starter
**SPDX-License-Identifier:** BSD-3-Clause
**License File:** See the LICENSE file in the project root.
**Copyright:** © 2025 Michael Gardner, A Bit of Help, Inc.  

All notable changes to Hybrid_App_Ada will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- **And_Then_Into**: Cross-type Result monad chaining for transforming Result[T] to Result[U]
  - Enables clean functional composition across type boundaries
  - Follows railway-oriented programming principles
  - Located in `Domain.Error.Result` package
- **Map_Error combinator**: Error transformation in `Domain.Error.Result`
  - Allows transforming error types while preserving success values
  - Completes the railway-oriented programming API
- **SPARK readiness assessment**: New Section 10 in Software Design Specification
  - Layer-by-layer SPARK compatibility analysis
  - Documents SPARK-compatible vs non-SPARK components
  - Future SPARK integration guide
- **Domain vs Functional Result documentation**: Clarified two Result types in SDS
  - `Domain.Error.Result` for domain purity (zero external dependencies)
  - `Functional.Result` for infrastructure exception bridging
  - Documents bridging pattern in Infrastructure layer
- **Purpose comments**: Added to 8 Ada package bodies
  - bootstrap-cli.adb, application-command-greet.adb, application-usecase-greet.adb
  - infrastructure-adapter-console_writer.adb, domain-value_object-option.adb
  - domain-value_object-person.adb, domain-error-result.adb
  - presentation-adapter-cli-command-greet.adb
- **Test fixture headers**: Documented expected violations in test fixtures
  - error_with_unbounded_string.ads (UNBOUNDED_STRING_IN_ERROR)
  - app_imports_test.ads (TEST_CODE_IN_PRODUCTION)
  - domain_with_pragma.ads (PRAGMA_VS_ASPECT)

### Changed
- **Format_Greeting moved to Application layer**: Greeting format logic relocated from Domain to Application
  - Domain now only validates and stores person name (pure business logic)
  - Application layer handles presentation formatting via `Format_Greeting` function
  - Better separation of concerns per DDD principles
- **Command DTO boundary isolation**: `Max_DTO_Name_Length := 256` separate from Domain's 100-character limit
  - DTOs can accept larger inputs; Domain enforces business validation
  - Clear architectural boundary between external input and domain constraints
- **Documentation regenerated**: Complete documentation refresh per agent standards
  - All formal documents (SRS, SDS, Test Guide) updated
  - PlantUML diagrams and SVGs regenerated
  - README.md and docs/index.md refreshed
- **Release scripts refactored**: Modular adapter pattern for multi-language support
  - New `scripts/release/adapters/` with base.py, ada.py, go.py
  - Unified release.py supporting Go and Ada projects
  - Replaced monolithic helper scripts
- **cleanup_temp_files.py enhanced**: Now supports both Ada and Go projects
  - Added Go patterns (.test, coverage.out, .coverprofile, vendor/)
  - Added Ada patterns (.ali, .gcda, .gcno, .gcov)
  - Moved to scripts/makefile/ directory
- **Makefile cleanup**: Removed non-existent examples targets
  - Removed build-examples, examples, run-examples, test-examples
  - No examples directory exists in this project

### Removed
- **Application.Model.Unit**: Eliminated unused model package
  - Unit type now comes directly from Functional library
  - Simplified application layer structure
- **Obsolete documentation guides**:
  - `docs/guides/architecture_mapping.md`
  - `docs/guides/ports_mapping.md`
- **Deprecated release helper scripts** (replaced by adapter pattern):
  - `scripts/release/generate_version.py`
  - `scripts/release/sync_versions.py`
  - `scripts/release/validate_release.py`

### Fixed
- **Release script improvements**:
  - Fixed validator false positives for tree-context file references
  - Use `make build-release` instead of `make build` for production builds
  - Use `make test-all` for comprehensive test execution
  - Handle UTF-8 encoding errors in colorized command output (ANSI escape codes)
  - Skip pattern templates like `test_<layer>_<component>.adb` in file reference checks
  - Check test files in `test/unit/`, `test/integration/`, `test/e2e/` subdirectories
  - Recognize tree roots (e.g., `test/`) and skip subdirectory validation for rooted trees
- **Code Quality**: Resolved all compiler warnings and style violations (357 automated fixes)
  - Fixed array aggregate syntax to Ada 2022 standard (`[]` for aggregates)
  - Fixed array constraint syntax (kept `()` for type constraints)
  - Removed unused with/use clauses across test suite
  - Fixed long lines exceeding 80 characters (proper line breaks at logical points)
  - Updated short-circuit operators (`and` → `and then`, `or` → `or else`)
  - Standardized comment separator lines to 79 characters
- **Code Safety**: Eliminated unsafe code in Infrastructure.Adapter.Console_Writer
  - Removed module-level mutable state and `Unchecked_Access` usage
  - Migrated to safe parameterized Functional.Try pattern
  - Enhanced Functional library with `Try_To_Result_With_Param` and `Try_To_Option_With_Param`
  - Added backwards-compatible child packages for existing tests
  - All 83 Functional library tests passing, all 90 hybrid_app_ada tests passing
- **Architecture Validation**: Fixed path detection in `arch_guard.py` after script reorganization
- **Build System**: Corrected Makefile FORMAT_DIRS syntax (missing backslash continuation)

### Changed
- **Script Organization**: Reorganized scripts into purpose-driven subdirectories
  - Created `scripts/makefile/` for Makefile-related scripts
  - Created `scripts/release/` for release automation
  - Updated all Makefile paths accordingly
- **GNATcoverage Runtime**: Automated runtime build from sources
  - Created `build_gnatcov_runtime.py` for reproducible builds
  - Removed vendored runtime with hardcoded paths
  - Added `make build-coverage-runtime` target
  - Updated coverage workflow documentation

### Removed
- Deleted tzif-specific scripts not applicable to hybrid_app_ada:
  - `check_tzif_parser.py`
  - `generate_version_ada.py`
  - `compare_tzif_versions.py`
  - `test_parser.py`
  - `generate_tzdata_version.py`

### Added
- 5-layer hexagonal architecture (Domain, Application, Infrastructure, Presentation, Bootstrap)
- Static dispatch dependency injection via generics (zero runtime overhead)
- Railway-oriented programming with Result monads (functional error handling)
- Application.Error re-export pattern (Presentation isolation from Domain)
- Single-project structure (simplified from aggregate project)
- Comprehensive UML diagrams (5 PlantUML diagrams with SVG generation)
- Architecture validation script (arch_guard.py enforces layer boundaries)
- **Comprehensive test suite with 90 tests achieving 90%+ code coverage**:
  - 74 unit tests (Domain + Application layers, 100% coverage)
  - 8 integration tests (cross-layer flows with real components)
  - 8 E2E tests (black-box CLI binary testing)
- **Professional test framework** (test/common/test_framework):
  - Color-coded test output (bright green success, bright red failure)
  - `Print_Category_Summary` function for consistent, professional test reporting
  - Exit code integration for CI/CD pipelines
  - Reusable test helpers eliminating code duplication
- **Test organization by architectural layer**:
  - test/unit/ - Unit tests with unit_tests.gpr
  - test/integration/ - Integration tests with integration_tests.gpr
  - test/e2e/ - E2E tests with e2e_tests.gpr
- Professional documentation (SDS, SRS, Test Guide, Quick Start)
- Makefile with comprehensive build/test/coverage targets and color-coded test summaries
- Code coverage support with vendored GNATcoverage RTS
- PlantUML diagram generation tooling
- Example greeter application demonstrating all patterns

### Changed
- Renamed test directory from `tests/` to `test/` (Ada standard convention)
- Enhanced Makefile test-all target with professional bordered success/failure indicators

### Architecture Patterns
- **Static Dependency Injection**: Generic packages with function parameters (compile-time DI)
- **Result Monad**: Railway-oriented error handling (no exceptions across boundaries)
- **Presentation Isolation**: Only Domain layer is shareable across apps
- **Minimal Entry Point**: Main delegates to Bootstrap.CLI.Run (3 lines)
- **Ports & Adapters**: Application defines ports, Infrastructure implements adapters

### Technical Details
- Ada 2022 with aspects (not obsolescent pragmas)
- Bounded strings (no heap allocation in domain)
- Pre/Post contracts on all public operations
- Pure domain logic with zero dependencies
- Functional composition via generics

### Documentation
- README with architecture overview and static dispatch explanation
- 5 UML diagrams:
  - Layer dependencies with architectural rules
  - Application.Error re-export pattern
  - Package structure by layer
  - Error handling flow (railway-oriented)
  - Static vs dynamic dispatch comparison
- Software Design Specification
- Software Requirements Specification
- Software Test Guide
- Quick Start Guide

---

## [1.0.0] - TBD

_First stable release - Professional Ada 2022 application starter template._

Coming soon: First stable release demonstrating hybrid DDD/Clean/Hexagonal architecture with functional programming principles in Ada 2022.

---

## Release Notes Format

Each release will document changes in these categories:

- **Added** - New features
- **Changed** - Changes to existing functionality
- **Deprecated** - Soon-to-be-removed features
- **Removed** - Removed features
- **Fixed** - Bug fixes
- **Security** - Security vulnerability fixes

---

## License & Copyright

- **License**: BSD-3-Clause
- **Copyright**: © 2025 Michael Gardner, A Bit of Help, Inc.
- **SPDX-License-Identifier**: BSD-3-Clause
