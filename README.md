# Lightning-Fast Apex Test Project Template (SFDX)

This repo is a working Salesforce DX scaffold focused on **fast, deterministic, maintainable Apex tests**. The architecture favors **dependency injection** and **thin triggers**, isolating platform dependencies behind interfaces so tests can use mocks and avoid DML/SOQL wherever possible. 

> The name "Heimdall" nods to the vigilant guardian in Norse myth, reflecting the project goal of guarding test speed and determinism; LTF stands for Lightning Test Framework.

Start here: see the [Quick Start](docs/quick-start.md) for a copy/paste setup and your first DML-less unit test.

## Core Principles

- **No database unless unavoidable**
- **Mock before you insert**
- **Unit tests > service tests > integration tests**
- **Unit tests avoid DML/SOQL; higher tiers use only what's needed**
- **SeeAllData=false always**
- **Architecture enables speed**

## Source Layout (force-app)

```
force-app/main/default/
  classes/
    core/
      domain/      Trigger framework + domain handlers
      interfaces/  Contracts for platform dependencies
      selectors/   SOQL access layer
      services/    Business services + DI registry
      infrastructure/ Concrete platform adapters
    test/
      factories/   Minimal test data helpers
      mocks/       Mock implementations of interfaces
      unit/        Pure unit tests (no DML/SOQL)
      service/     Light DML/SOQL tests
      integration/ Full-stack trigger + async tests
  triggers/        Thin trigger entrypoints
```

Example/demo code lives in a separate package directory:

```
examples/force-app/main/default/
  classes/   Demo selectors/services/handlers + tests
  triggers/  Demo triggers (Account example)
```

## How to Use

- **Production code**:
  - Wrap external dependencies in `core/interfaces/*`
  - Put all SOQL in `core/selectors/*` (framework only when generic)
  - Put business logic in `core/services/*`
  - Resolve dependencies via `ServiceRegistry`
- **Tests**:
  - Register mocks with `TestServiceRegistry.registerMock(...)`
  - Prefer unit tests that avoid DML/SOQL entirely
  - Extend `BaseTest` to reset the registry and enforce speed budgets

## Trigger Pattern (Thin Entrypoints)

- `examples/force-app/main/default/triggers/AccountTrigger.trigger` is a minimal entrypoint that delegates to the domain handler.
- `core/domain/TriggerRouter.cls` dispatches to the correct handler method based on the trigger context.
- `core/domain/TriggerHandler.cls` defines the base interface for trigger lifecycle methods.
- `examples/force-app/main/default/classes/demo/domain/AccountTriggerHandler.cls` contains the business logic and resolves dependencies via `ServiceRegistry`.

The example `afterInsert` flow (now under `examples/`) collects Ids, queries via a selector, and performs bulk-safe updates. It highlights the need for recursion/idempotency handling in real systems.

## Dependency Injection and Service Registry

The DI strategy is a lightweight service locator that resolves implementations by interface `Type`:

- `core/services/ServiceRegistry.cls` stores bindings and lazily bootstraps production services via `ProductionServices.registerAll()`.
- `core/services/ProductionServices.cls` is the composition root that wires interfaces to concrete implementations.
- `core/services/TestServiceRegistry.cls` resets bindings and allows tests to register mocks.

This keeps production code from directly instantiating selectors, callout clients, async enqueuers, or event publishers.

## Interfaces (Contracts)

The `core/interfaces` folder defines small, testable contracts for platform dependencies:

- `IHttpClient`: HTTP callout abstraction.
- `IAsyncEnqueuer`: `System.enqueueJob` wrapper.
- `IEventBus`: `EventBus.publish` wrapper.
- `IClock`: `System.now()` wrapper.
- `IQueueableJob`: queueable work that can run synchronously in tests.
- `IRecordMutator`: DML abstraction for insert/update/delete operations.

## Implementations (Selectors + Utils)

Concrete implementations live in `core/selectors` and `core/infrastructure` and are registered in `ProductionServices`:

- `HttpClient`, `SystemAsyncEnqueuer`, `SystemEventBus`, and `SystemClock` delegate to platform APIs.
- `SystemRecordMutator` delegates to `Database.insert/update/delete`.
- `NoopQueueableJob` is a safe placeholder implementation.

## Services (Business Logic)

Service classes are intentionally thin and rely on DI. The demo service examples live under `examples/` (see below).

## Examples Package

The `examples/` package contains the Account demo that showcases selectors, triggers, and orchestration:

- It depends on the framework code in `force-app`.
- `demo/interfaces/IAccountSelector`, `demo/selectors/AccountSelector`
- `demo/services/DemoServices` registers demo-specific bindings
- `demo/domain/AccountTriggerHandler` + `triggers/AccountTrigger.trigger`
- `demo/services/AccountService`, `demo/services/AccountQueueable`, `demo/services/ExampleIntegrationService`
- Tests in `examples/force-app/main/default/classes/test/*`

## Tests and Test Taxonomy

The test structure mirrors the documented taxonomy for the framework. Demo tests live under `examples/`.

- `test/unit/` contains fast unit tests that avoid DML/SOQL by using mocks.
- `test/service/` exercises real DML/SOQL but remains lightweight.
- `test/integration/` validates end-to-end behavior (trigger + DI + async) and is used sparingly.

Common utilities:

- `test/helpers/BaseTest.cls` resets DI bindings and enforces fast test budgets.
- `test/helpers/BaseTest.cls` also includes `assertSlowTest()` for DML-heavy tests.
- `test/helpers/TestLimits.cls` asserts tight governor limits (DML, SOQL, CPU) to keep tests fast.
- `examples/force-app/main/default/classes/test/factories/TestDataFactory.cls` provides minimal, predictable test data helpers for the demo.

Mocks in `test/mocks` provide test doubles for each interface, including `MockHttpClient`, `MockAsyncEnqueuer`, `MockEventBus`, `MockQueueable`, `FixedClock`, and `MockRecordMutator`.

## Example Flows in Tests

Representative tests illustrate the intended testing strategies (framework tests in `force-app`, demo tests in `examples/`):

- `examples/force-app/main/default/classes/test/unit/AccountServiceTest.cls` exercises constructor injection with a demo selector.
- `examples/force-app/main/default/classes/test/unit/ExampleIntegrationServiceTest.cls` shows DI orchestration with platform mocks.
- `examples/force-app/main/default/classes/test/integration/AccountTriggerHandlerIntegrationTest.cls` verifies the demo trigger end-to-end.
- `RecordMutatorDmlTest` validates `SystemRecordMutator` with real DML.
- `HttpCalloutMockTest` shows platform `HttpCalloutMock` usage when not mocking `IHttpClient`.
- `QueueableExecutionTest` demonstrates `Test.startTest/stopTest` to flush async execution.

## Test Taxonomy (Quick Reference)

- `Unit_*`: pure mocks, no DML/SOQL
- `Service_*`: minimal DML/SOQL to validate business logic
- `Integration_*`: full stack with triggers/async/callouts (use sparingly)

## CI Guardrails

Run `scripts/ci_guardrails.sh` in CI to enforce:

- No direct selector/service instantiation outside `ProductionServices`
- Warn on direct `Http.send` calls (use `IHttpClient` instead)

The guardrail script requires `rg` (ripgrep) to be available in CI.

## Git Hooks (Husky)

This repo uses Husky to enforce lightweight checks on GitHub-bound changes:

- `pre-commit`: runs `lint-staged` (Prettier on staged files, ESLint on LWC/Aura JS).
- `pre-push`: runs `npm test` and `scripts/ci_guardrails.sh`.

## Key Files

- `core/services/ServiceRegistry.cls`: central DI/registry used by production and tests
- `core/services/ProductionServices.cls`: where production implementations are wired
- `core/domain/TriggerHandler.cls`: trigger base class
- `core/domain/TriggerRouter.cls`: trigger router for before/after events
- `test/factories/TestDataFactory.cls`: minimal test data helpers
- `test/mocks/*`: mock implementations and base mocks

