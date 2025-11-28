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

_No unreleased changes._

---

## [1.0.0] - 2025-11-28

_First stable release - Professional Ada 2022 application starter template._

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
- Code coverage support with GNATcoverage RTS
- PlantUML diagram generation tooling
- Example greeter application demonstrating all patterns
- **And_Then_Into**: Cross-type Result monad chaining for transforming Result[T] to Result[U]
- **Map_Error combinator**: Error transformation in `Domain.Error.Result`
- **SPARK readiness assessment**: New Section 10 in Software Design Specification
- **Domain vs Functional Result documentation**: Clarified two Result types in SDS
- **Purpose comments**: Added to 8 Ada package bodies
- **Test fixture headers**: Documented expected violations in test fixtures

### Changed
- Renamed test directory from `tests/` to `test/` (Ada standard convention)
- Enhanced Makefile test-all target with professional bordered success/failure indicators
- **Format_Greeting moved to Application layer**: Greeting format logic relocated from Domain to Application
- **Command DTO boundary isolation**: `Max_DTO_Name_Length := 256` separate from Domain's 100-character limit
- **Documentation regenerated**: Complete documentation refresh per agent standards
- **Release scripts refactored**: Modular adapter pattern for multi-language support
- **cleanup_temp_files.py enhanced**: Now supports both Ada and Go projects
- **Makefile cleanup**: Removed non-existent examples targets
- **Script Organization**: Reorganized scripts into purpose-driven subdirectories
- **GNATcoverage Runtime**: Automated runtime build from sources

### Removed
- **Application.Model.Unit**: Eliminated unused model package
- **Obsolete documentation guides**: architecture_mapping.md, ports_mapping.md
- **Deprecated release helper scripts** (replaced by adapter pattern)
- Deleted tzif-specific scripts not applicable to hybrid_app_ada

### Fixed
- **Release script improvements**:
  - Fixed validator false positives for tree-context file references
  - Use `make build-release` instead of `make build` for production builds
  - Use `make test-all` for comprehensive test execution
  - Handle UTF-8 encoding errors in colorized command output
  - Skip pattern templates in file reference checks
  - Check test files in proper subdirectories
- **Code Quality**: Resolved all compiler warnings and style violations (357 automated fixes)
- **Code Safety**: Eliminated unsafe code in Infrastructure.Adapter.Console_Writer
- **Architecture Validation**: Fixed path detection in `arch_guard.py`
- **Build System**: Corrected Makefile FORMAT_DIRS syntax

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
- 5 UML diagrams documenting architecture
- Software Design Specification
- Software Requirements Specification
- Software Test Guide
- Quick Start Guide

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
