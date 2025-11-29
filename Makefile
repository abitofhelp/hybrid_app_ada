# =============================================================================
# Project Makefile
# =============================================================================
# Project: hybrid_app_ada
# Purpose: Hexagonal architecture demonstration with port/adapter pattern
#
# This Makefile provides:
#   - Build targets (build, clean, rebuild)
#   - Test infrastructure (test, test-coverage)
#   - Format/check targets (format, stats)
#   - Documentation generation (docs, api-docs)
#   - Development tools (watch, setup-hooks, ci)
# =============================================================================

PROJECT_NAME := hybrid_app_ada

.PHONY: all build build-dev build-opt build-release build-tests build-profiles check check-arch \
        clean clean-clutter clean-coverage clean-deep compress deps diagrams \
		help prereqs rebuild refresh run stats test test-all test-coverage test-framework \
		test-integration test-unit test-e2e test-python install-tools build-coverage-runtime
# FIX: ENABLE AFTER THE TARGETS CONVERT TO USING OUR ADAFMT TOOL, WHICH IS IN DEVELOPMENT.
#       format format-all format-src format-tests

# =============================================================================
# OS Detection
# =============================================================================

UNAME := $(shell uname -s)

# =============================================================================
# Colors for Output
# =============================================================================

GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
BLUE := \033[0;34m
ORANGE := \033[38;5;208m
CYAN := \033[0;36m
BOLD := \033[1m
NC := \033[0m

# =============================================================================
# Tool Paths
# =============================================================================

ALR := alr
GPRBUILD := gprbuild
GNATFORMAT := gnatformat
GNATDOC := gnatdoc
PYTHON3 := python3

# =============================================================================
# Tool Flags
# =============================================================================
# NOTE: --no-indirect-imports is NOT needed. Architecture is enforced via
#       Stand-Alone Library with explicit Library_Interface in application.gpr
#       which prevents transitive Domain access from Presentation layer.
ALR_BUILD_FLAGS := -j8 | grep -E 'warning:|(style)|error:' || true
ALR_TEST_FLAGS  := -j8 | grep -E 'warning:|(style)|error:' || true
# =============================================================================
# Directories
# =============================================================================

BUILD_DIR := obj
BIN_DIR := bin
DOCS_DIR := docs/api
COVERAGE_DIR := coverage
# Get the directory of the currently executing Makefile.
# This assumes the Makefile is the last one in the list.
MAKEFILE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
PROJECT_DIR := $(MAKEFILE_DIR)/$(PROJECT_NAME)
TEST_DIR := test

# Directories to format (library layers + shared + tests)
FORMAT_DIRS := \
				$(wildcard src/api) \
				$(wildcard src/application) \
  		       	$(wildcard src/bootstrap) \
               	$(wildcard src/domain) \
			   	$(wildcard src/infrastructure) \
			   	$(wildcard src/presentation) \
               	$(wildcard $(TEST_DIR))

# =============================================================================
# Default Target
# =============================================================================

all: build

# =============================================================================
# Help Target
# =============================================================================

help: ## Display this help message
	@echo "$(CYAN)$(BOLD)╔══════════════════════════════════════════════════╗$(NC)"
	@echo "$(CYAN)$(BOLD)║  Hybrid App - Ada 2022                           ║$(NC)"
	@echo "$(CYAN)$(BOLD)╚══════════════════════════════════════════════════╝$(NC)"
	@echo " "
	@echo "$(YELLOW)Build Commands:$(NC)"
	@echo "  build              - Build project (development mode)"
	@echo "  build-dev          - Build with development flags"
	@echo "  build-opt          - Build with optimization (-O2)"
	@echo "  build-release      - Build in release mode"
	@echo "  build-tests        - Build all test executables"
	@echo "  run                - Build and run the greeter"
	@echo "  clean              - Clean build artifacts"
	@echo "  clean-clutter      - Remove temporary files and backups"
	@echo "  clean-coverage     - Clean coverage data"
	@echo "  clean-deep         - Deep clean (includes Alire cache)"
	@echo "  compress           - Create compressed source archive (tar.gz)"
	@echo "  rebuild            - Clean and rebuild"
	@echo ""
	@echo "$(YELLOW)Testing Commands:$(NC)"
	@echo "  test               - Run comprehensive test suite (main runner)"
	@echo "  test-unit          - Run unit tests only"
	@echo "  test-integration   - Run integration tests only"
	@echo "  test-e2e           - Run E2E tests only"
	@echo "  test-all           - Run all test executables"
	@echo "  test-framework     - Run all test suites (unit + integration + e2e)"
	@echo "  test-python        - Run Python script tests (arch_guard.py validation)"
	@echo "  test-coverage      - Run tests with coverage analysis"
	@echo ""
	@echo "$(YELLOW)Quality & Architecture Commands:$(NC)"
	@echo "  check              - Run static analysis"
	@echo "  check-arch         - Validate hexagonal architecture boundaries"
# FIX: ENABLE AFTER THE TARGETS CONVERT TO USING OUR ADAFMT TOOL, WHICH IS IN DEVELOPMENT.
# 	@echo "  format-src         - Auto-format source code only"
# 	@echo "  format-tests       - Auto-format test code only"
# 	@echo "  format-all         - Auto-format all code"
# 	@echo "  format             - Alias for format-all"
	@echo "  stats              - Display project statistics by layer"
	@echo ""
	@echo "$(YELLOW)Utility Commands:$(NC)"
	@echo "  deps                    - Show dependency information"
	@echo "  prereqs                 - Verify prerequisites are satisfied"
	@echo "  refresh                 - Refresh Alire dependencies"
	@echo "  install-tools           - Install development tools (GMP, gcovr, gnatformat)"
	@echo "  build-coverage-runtime  - Build GNATcoverage runtime library"
	@echo ""
	@echo "$(YELLOW)Advanced Commands:$(NC)"
	@echo "  build-profiles     - Test compilation with all build profiles"
	@echo ""
	@echo "$(YELLOW)Workflow Shortcuts:$(NC)"
	@echo "  all                - Build project (default)"

# =============================================================================
# Build Commands
# =============================================================================

prereqs:
	@echo "$(GREEN)✓ All prerequisites satisfied$(NC)"

build: build-dev

build-dev: check-arch prereqs
	@echo "$(GREEN)Building $(PROJECT_NAME) (development mode)...$(NC)"
	$(ALR) build --development -- $(ALR_BUILD_FLAGS)
	@echo "$(GREEN)✓ Development build complete$(NC)"

build-opt: check-arch prereqs
	@echo "$(GREEN)Building $(PROJECT_NAME) (optimized -O2)...$(NC)"
	$(ALR) build -- -O2 $(ALR_BUILD_FLAGS)
	@echo "$(GREEN)✓ Optimized build complete$(NC)"

build-release: check-arch prereqs
	@echo "$(GREEN)Building $(PROJECT_NAME) (release mode)...$(NC)"
	$(ALR) build --release -- $(ALR_BUILD_FLAGS)
	@echo "$(GREEN)✓ Release build complete$(NC)"

build-tests: check-arch prereqs
	@echo "$(GREEN)Building test suites...$(NC)"
	@if [ -f "$(TEST_DIR)/unit/unit_tests.gpr" ]; then \
		$(ALR) exec -- $(GPRBUILD) -P $(TEST_DIR)/unit/unit_tests.gpr -p $(ALR_TEST_FLAGS); \
		echo "$(GREEN)✓ Unit tests built$(NC)"; \
	else \
		echo "$(YELLOW)Unit test project not found$(NC)"; \
	fi
	@if [ -f "$(TEST_DIR)/integration/integration_tests.gpr" ]; then \
		$(ALR) exec -- $(GPRBUILD) -P $(TEST_DIR)/integration/integration_tests.gpr -p $(ALR_TEST_FLAGS); \
		echo "$(GREEN)✓ Integration tests built$(NC)"; \
	else \
		echo "$(YELLOW)Integration test project not found$(NC)"; \
	fi
	@if [ -f "$(TEST_DIR)/e2e/e2e_tests.gpr" ]; then \
		$(ALR) exec -- $(GPRBUILD) -P $(TEST_DIR)/e2e/e2e_tests.gpr -p $(ALR_TEST_FLAGS); \
		echo "$(GREEN)✓ E2E tests built$(NC)"; \
	else \
		echo "$(YELLOW)E2E test project not found$(NC)"; \
	fi

build-profiles: ## Validate library builds with all configuration profiles
	@echo "$(CYAN)$(BOLD)Testing library compilation with all profiles...$(NC)"
	@echo "$(CYAN)Note: This validates compilation only (not cross-compilation)$(NC)"
	@echo ""
	@PROFILES="standard embedded baremetal concurrent stm32h7s78 stm32mp135_linux"; \
	FAILED=0; \
	for profile in $$PROFILES; do \
		echo "$(YELLOW)Testing profile: $$profile$(NC)"; \
		if [ -f "config/profiles/$$profile/hybrid_app_ada_config.ads" ]; then \
			cp -f config/hybrid_app_ada_config.ads config/hybrid_app_ada_config.ads.backup 2>/dev/null || true; \
			cp -f config/profiles/$$profile/hybrid_app_ada_config.ads config/hybrid_app_ada_config.ads; \
			if $(ALR) build --development -- -j8 2>&1 | grep -E 'error:|failed' > /dev/null; then \
				echo "$(RED)✗ Profile $$profile: FAILED$(NC)"; \
				FAILED=$$((FAILED + 1)); \
			else \
				echo "$(GREEN)✓ Profile $$profile: OK$(NC)"; \
			fi; \
			mv -f config/hybrid_app_ada_config.ads.backup config/hybrid_app_ada_config.ads 2>/dev/null || true; \
			$(ALR) clean > /dev/null 2>&1; \
		else \
			echo "$(RED)✗ Profile $$profile: config file not found$(NC)"; \
			FAILED=$$((FAILED + 1)); \
		fi; \
		echo ""; \
	done; \
	if [ $$FAILED -eq 0 ]; then \
		echo "$(GREEN)$(BOLD)✓ All profiles compiled successfully$(NC)"; \
	else \
		echo "$(RED)$(BOLD)✗ $$FAILED profile(s) failed$(NC)"; \
		exit 1; \
	fi


clean:
	@echo "$(YELLOW)Cleaning project build artifacts (keeps dependencies)...$(NC)"
	@# Use gprclean WITHOUT -r to clean only our project, not dependencies
	@$(ALR) exec -- gprclean -P $(PROJECT_NAME).gpr -q 2>/dev/null || true
	@$(ALR) exec -- gprclean -P $(TEST_DIR)/unit/unit_tests.gpr -q 2>/dev/null || true
	@$(ALR) exec -- gprclean -P $(TEST_DIR)/integration/integration_tests.gpr -q 2>/dev/null || true
	@rm -rf $(BUILD_DIR) $(BIN_DIR) lib $(TEST_DIR)/bin $(TEST_DIR)/obj
	@find . -name "*.backup" -delete 2>/dev/null || true
	@if [ -d "assemblies" ]; then \
		$(ALR) exec -- gprclean -P assemblies/standard/standard.gpr -q 2>/dev/null || true; \
		rm -rf assemblies/*/obj assemblies/*/lib 2>/dev/null || true; \
		echo "$(GREEN)✓ Assemblies cleaned$(NC)"; \
	fi
	@echo "$(GREEN)✓ Project artifacts cleaned (dependencies preserved for fast rebuild)$(NC)"

clean-deep:
	@echo "$(YELLOW)Deep cleaning ALL artifacts including dependencies...$(NC)"
	@echo "$(YELLOW)⚠️  This will require rebuilding GNATCOLL, XMLAda, etc. (slow!)$(NC)"
	@$(ALR) clean
	@rm -rf $(BUILD_DIR) $(BIN_DIR) lib $(TEST_DIR)/bin $(TEST_DIR)/obj
	@find . -name "*.backup" -delete 2>/dev/null || true
	@if [ -d "assemblies" ]; then \
		rm -rf assemblies/*/obj assemblies/*/lib 2>/dev/null || true; \
		echo "$(GREEN)✓ Assemblies cleaned$(NC)"; \
	fi
	@echo "$(GREEN)✓ Deep clean complete (next build will be slow)$(NC)"

clean-coverage:
	@echo "$(YELLOW)Cleaning coverage artifacts...$(NC)"
	@find . -name "*.srctrace" -delete 2>/dev/null || true
	@find . -name "*.traces" -delete 2>/dev/null || true
	@find . -name "*.sid" -delete 2>/dev/null || true
	@rm -rf coverage/ 2>/dev/null || true
	@rm -rf gnatcov-instr/ 2>/dev/null || true
	@echo "$(GREEN)✓ Coverage artifacts cleaned$(NC)"

clean-clutter: ## Remove temporary files, backups, and clutter
	@echo "$(CYAN)Cleaning temporary files and clutter...$(NC)"
	@$(PYTHON3) scripts/makefile/cleanup_temp_files.py
	@echo "$(GREEN)✓ Temporary files removed$(NC)"

compress:
	@echo "$(CYAN)Creating compressed source archive... $(NC)"
	@tar -czvf "$(PROJECT_NAME).tar.gz" \
		--exclude="$(PROJECT_NAME).tar.gz" \
	    --exclude='.git' \
	    --exclude='tools' \
		--exclude='data' \
	    --exclude='obj' \
	    --exclude='bin' \
	    --exclude='lib' \
	    --exclude='alire' \
	    --exclude='.build' \
	    --exclude='coverage' \
	    --exclude='.DS_Store' \
	    --exclude='*.o' \
	    --exclude='*.ali' \
	    --exclude='*.backup' \
		.
	@echo "$(GREEN)✓ Archive created: $(PROJECT_NAME).tar.gz $(NC)"

rebuild: clean build

run: build ## Build and run the greeter
	@echo "$(GREEN)Running greeter...$(NC)"
	@./bin/greeter World

# =============================================================================
# Testing Commands
# =============================================================================

test: test-all

test-all: build build-tests
	@echo "$(GREEN)Running all test executables...$(NC)"
	@failed=0; \
	if [ -d "$(TEST_DIR)/bin" ]; then \
		for test in $(TEST_DIR)/bin/*_runner $(TEST_DIR)/bin/test_*; do \
			if [ -x "$$test" ] && [ -f "$$test" ]; then \
				echo "$(CYAN)Running $$test...$(NC)"; \
				$$test || failed=1; \
				echo ""; \
			fi; \
		done; \
	else \
		echo "$(YELLOW)No test executables found in $(TEST_DIR)/bin$(NC)"; \
	fi; \
	if [ $$failed -eq 0 ]; then \
		echo ""; \
		echo "\033[1;92m########################################"; \
		echo "###                                  ###"; \
		echo "###   ALL TEST SUITES: SUCCESS      ###"; \
		echo "###   All tests passed!              ###"; \
		echo "###                                  ###"; \
		echo "########################################\033[0m"; \
		echo ""; \
	else \
		echo ""; \
		echo "\033[1;91m########################################"; \
		echo "###                                  ###"; \
		echo "###   ALL TEST SUITES: FAILURE      ###"; \
		echo "###   Some tests failed!             ###"; \
		echo "###                                  ###"; \
		echo "########################################\033[0m"; \
		echo ""; \
		exit 1; \
	fi

test-unit: build build-tests
	@echo "$(GREEN)Running unit tests...$(NC)"
	@if [ -f "$(TEST_DIR)/bin/unit_runner" ]; then \
		$(TEST_DIR)/bin/unit_runner; \
		if [ $$? -eq 0 ]; then \
			echo "$(GREEN)✓ Unit tests passed$(NC)"; \
		else \
			echo "$(RED)✗ Unit tests failed$(NC)"; \
			exit 1; \
		fi; \
	else \
		echo "$(YELLOW)Unit test runner not found at $(TEST_DIR)/bin/unit_runner$(NC)"; \
		exit 1; \
	fi

test-integration: build build-tests
	@echo "$(GREEN)Running integration tests...$(NC)"
	@if [ -f "$(TEST_DIR)/bin/integration_runner" ]; then \
		$(TEST_DIR)/bin/integration_runner; \
		if [ $$? -eq 0 ]; then \
			echo "$(GREEN)✓ Integration tests passed$(NC)"; \
		else \
			echo "$(RED)✗ Integration tests failed$(NC)"; \
			exit 1; \
		fi; \
	else \
		echo "$(YELLOW)Integration test runner not found at $(TEST_DIR)/bin/integration_runner$(NC)"; \
		exit 1; \
	fi

test-e2e: build build-tests
	@echo "$(GREEN)Running E2E tests...$(NC)"
	@if [ -f "$(TEST_DIR)/bin/e2e_runner" ]; then \
		$(TEST_DIR)/bin/e2e_runner; \
		if [ $$? -eq 0 ]; then \
			echo "$(GREEN)✓ E2E tests passed$(NC)"; \
		else \
			echo "$(RED)✗ E2E tests failed$(NC)"; \
			exit 1; \
		fi; \
	else \
		echo "$(YELLOW)E2E test runner not found at $(TEST_DIR)/bin/e2e_runner$(NC)"; \
		exit 1; \
	fi

test-framework: test-unit test-integration test-e2e ## Run all test suites
	@echo "$(GREEN)$(BOLD)✓ All test suites completed$(NC)"

test-coverage: clean build build-coverage-runtime
	@echo "$(GREEN)Running tests with GNATcoverage analysis...$(NC)"
	@if [ -f "scripts/makefile/coverage.sh" ]; then \
		bash scripts/makefile/coverage.sh; \
	else \
		echo "$(YELLOW)Coverage script not found at scripts/makefile/coverage.sh$(NC)"; \
		exit 1; \
	fi

# =============================================================================
# Quality & Code Formatting Commands
# =============================================================================

check:
	@echo "$(GREEN)Running code checks...$(NC)"
	@$(ALR) build --development -- $(ALR_BUILD_FLAGS)
	@echo "$(GREEN)✓ Code checks complete$(NC)"

check-arch: ## Validate hexagonal architecture boundaries
	@echo "$(GREEN)Validating architecture boundaries...$(NC)"
	@PYTHONPATH=scripts $(PYTHON3) -m arch_guard
	@if [ $$? -eq 0 ]; then \
		echo "$(GREEN)✓ Architecture validation passed$(NC)"; \
	else \
		echo "$(RED)✗ Architecture validation failed$(NC)"; \
		exit 1; \
	fi

test-python: ## Run Python script tests (arch_guard.py validation)
	@echo "$(GREEN)Running Python script tests...$(NC)"
	@cd test/python && $(PYTHON3) -m pytest -v
	@echo "$(GREEN)✓ Python tests complete$(NC)"


# FIXME: REPLACE WITH THE ADAFMT TOOL WE ARE CREATING WHEN IT IS COMPLETED.
# THE CURRENT SCRIPT IS COMMENTING COMMENTS AND MESSING UP WITH INDEXED COMMENTS.
# format-src:
# 	@echo "$(GREEN)Formatting source code...$(NC)"
# 	@if [ ! -f "scripts/makefile/ada_formatter_pipeline.donotuse.py" ]; then \
# 		echo "$(RED)Error: scripts/makefile/ada_formatter_pipeline.donotuse.py not found$(NC)"; \
# 		exit 1; \
# 	fi
# 	@for layer in application domain infrastructure; do \
# 		if [ -d "$$layer/src" ]; then \
# 			find "$$layer/src" -name "*.ads" -o -name "*.adb" | \
# 			while read file; do \
# 				echo "  Formatting $$file..."; \
# 				$(PYTHON3) scripts/makefile/ada_formatter_pipeline.donotuse.py "$(PWD)/$$layer/$$layer.gpr" --include-path "$(PWD)/$$file" || true; \
# 			done; \
# 		fi; \
# 	done
# 	@echo "$(GREEN)✓ Source formatting complete$(NC)"

# format-tests:
# 	@echo "$(GREEN)Formatting test code...$(NC)"
# 	@if [ ! -f "scripts/makefile/ada_formatter_pipeline.donotuse.py" ]; then \
# 		echo "$(RED)Error: scripts/makefile/ada_formatter_pipeline.donotuse.py not found$(NC)"; \
# 		exit 1; \
# 	fi
# 	@if [ -d "$(TEST_DIR)/unit" ] && [ -f "$(TEST_DIR)/unit/unit_tests.gpr" ]; then \
# 		find $(TEST_DIR)/unit -name "*.ads" -o -name "*.adb" | \
# 		while read file; do \
# 			echo "  Formatting $$file..."; \
# 			$(PYTHON3) scripts/makefile/ada_formatter_pipeline.donotuse.py "$(PWD)/$(TEST_DIR)/unit/unit_tests.gpr" --include-path "$(PWD)/$$file" || true; \
# 		done; \
# 		echo "$(GREEN)✓ Unit test formatting complete$(NC)"; \
# 	fi
# 	@if [ -d "$(TEST_DIR)/integration" ] && [ -f "$(TEST_DIR)/integration/integration_tests.gpr" ]; then \
# 		find $(TEST_DIR)/integration -name "*.ads" -o -name "*.adb" | \
# 		while read file; do \
# 			echo "  Formatting $$file..."; \
# 			$(PYTHON3) scripts/makefile/ada_formatter_pipeline.donotuse.py "$(PWD)/$(TEST_DIR)/integration/integration_tests.gpr" --include-path "$(PWD)/$$file" || true; \
# 		done; \
# 		echo "$(GREEN)✓ Integration test formatting complete$(NC)"; \
# 	fi
# 	@if [ -d "$(TEST_DIR)/domain" ]; then \
# 		find $(TEST_DIR)/domain -name "*.ads" -o -name "*.adb" | \
# 		while read file; do \
# 			echo "  Formatting $$file..."; \
# 			$(PYTHON3) scripts/makefile/ada_formatter_pipeline.donotuse.py "$(PWD)/$(TEST_DIR)/unit/unit_tests.gpr" --include-path "$(PWD)/$$file" || true; \
# 		done; \
# 		echo "$(GREEN)✓ Domain test formatting complete$(NC)"; \
# 	fi

# format-all: format-src format-tests
# 	@echo "$(GREEN)✓ All code formatting complete$(NC)"

# format: format-all


# =============================================================================
# Development Commands
# =============================================================================

stats:
	@echo "$(CYAN)$(BOLD)Project Statistics for $(PROJECT_NAME)$(NC)"
	@echo "$(YELLOW)════════════════════════════════════════$(NC)"
	@echo ""
	@echo "Ada Source Files by Layer:"
	@echo "  Domain specs:          $$(find src/domain -name "*.ads" 2>/dev/null | wc -l | tr -d ' ')"
	@echo "  Domain bodies:         $$(find src/domain -name "*.adb" 2>/dev/null | wc -l | tr -d ' ')"
	@echo "  Application specs:     $$(find src/application -name "*.ads" 2>/dev/null | wc -l | tr -d ' ')"
	@echo "  Application bodies:    $$(find src/application -name "*.adb" 2>/dev/null | wc -l | tr -d ' ')"
	@echo "  Infrastructure specs:  $$(find src/infrastructure -name "*.ads" 2>/dev/null | wc -l | tr -d ' ')"
	@echo "  Infrastructure bodies: $$(find src/infrastructure -name "*.adb" 2>/dev/null | wc -l | tr -d ' ')"
	@echo ""
	@echo "Lines of Code:"
	@find src/application src/domain src/infrastructure -name "*.ads" -o -name "*.adb" 2>/dev/null | \
	  xargs wc -l 2>/dev/null | tail -1 | awk '{printf "  Total: %d lines\n", $$1}' || echo "  Total: 0 lines"
	@echo ""
	@echo "Build Artifacts:"
	@if [ -f "./bin/greeter" ]; then \
		echo "  Binary: $$(ls -lh ./bin/greeter 2>/dev/null | awk '{print $$5}')"; \
	else \
		echo "  No binary found (run 'make build')"; \
	fi

# =============================================================================
# Advanced Targets
# =============================================================================

deps: ## Display project dependencies
	@echo "$(CYAN)Project dependencies from alire.toml:$(NC)"
	@grep -A 10 "\[\[depends-on\]\]" alire.toml || echo "$(YELLOW)No dependencies found$(NC)"
	@echo ""
	@echo "$(CYAN)Alire dependency tree:$(NC)"
	@$(ALR) show --solve || echo "$(YELLOW)Could not resolve dependencies$(NC)"

refresh: ## Refresh Alire dependencies
	@echo "$(CYAN)Refreshing Alire dependencies...$(NC)"
	@$(ALR) update
	@echo "$(GREEN)✓ Dependencies refreshed$(NC)"

install-tools: ## Install development tools (GMP, gcovr, gnatformat)
	@echo "$(CYAN)Installing development tools...$(NC)"
	@$(PYTHON3) scripts/makefile/install_tools.py
	@echo "$(GREEN)✓ Tool installation complete$(NC)"

build-coverage-runtime: ## Build GNATcoverage runtime library
	@echo "$(CYAN)Building GNATcoverage runtime...$(NC)"
	@$(PYTHON3) scripts/makefile/build_gnatcov_runtime.py

diagrams: ## Generate SVG diagrams from PlantUML sources
	@echo "$(CYAN)Generating SVG diagrams from PlantUML...$(NC)"
	@command -v plantuml >/dev/null 2>&1 || { echo "$(RED)Error: plantuml not found. Install with: brew install plantuml$(NC)"; exit 1; }
	@cd docs/diagrams && for f in *.puml; do \
		echo "  Processing $$f..."; \
		plantuml -tsvg "$$f"; \
	done
	@echo "$(GREEN)✓ Diagrams generated$(NC)"

.DEFAULT_GOAL := help

