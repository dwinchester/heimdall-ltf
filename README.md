# Lightning-Fast Apex Test Project Template (SFDX)

This repo is a working Salesforce DX scaffold focused on **fast, deterministic, maintainable Apex tests**. The architecture favors **dependency injection** and **thin triggers**, isolating platform dependencies behind interfaces so tests can use mocks and avoid DML/SOQL wherever possible. 

> The name "Heimdall" nods to the vigilant guardian in Norse myth, reflecting the project goal of guarding test speed and determinism; LTF stands for Lightning Test Framework.

## Core Principles

- **No database unless unavoidable**
- **Mock before you insert**
- **Unit tests > service tests > integration tests**
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
      utils/       Concrete platform adapters
    test/
      factories/   Minimal test data helpers
      mocks/       Mock implementations of interfaces
      unit/        Pure unit tests (no DML/SOQL)
      service/     Light DML/SOQL tests
      integration/ Full-stack trigger + async tests
  triggers/        Thin trigger entrypoints
```

## How to Use

- **Production code**:
  - Wrap external dependencies in `core/interfaces/*`
  - Put all SOQL in `core/selectors/*`
  - Put business logic in `core/services/*`
  - Resolve dependencies via `ServiceRegistry`
- **Tests**:
  - Register mocks with `TestServiceRegistry.registerMock(...)`
  - Prefer unit tests that avoid DML/SOQL entirely
  - Extend `BaseTest` to reset the registry and enforce speed budgets

## Trigger Pattern (Thin Entrypoints)

- `triggers/AccountTrigger.trigger` is a minimal entrypoint that delegates to the domain handler.
- `core/domain/TriggerRouter.cls` dispatches to the correct handler method based on the trigger context.
- `core/domain/TriggerHandler.cls` defines the base interface for trigger lifecycle methods.
- `core/domain/AccountTriggerHandler.cls` contains the business logic and resolves dependencies via `ServiceRegistry`.

The example `afterInsert` flow collects Ids, queries via a selector, and performs bulk-safe updates. It highlights the need for recursion/idempotency handling in real systems.

## Dependency Injection and Service Registry

The DI strategy is a lightweight service locator that resolves implementations by interface `Type`:

- `core/services/ServiceRegistry.cls` stores bindings and lazily bootstraps production services via `ProductionServices.registerAll()`.
- `core/services/ProductionServices.cls` is the composition root that wires interfaces to concrete implementations.
- `core/services/TestServiceRegistry.cls` resets bindings and allows tests to register mocks.

This keeps production code from directly instantiating selectors, callout clients, async enqueuers, or event publishers.

## Interfaces (Contracts)

The `core/interfaces` folder defines small, testable contracts for platform dependencies:

- `IAccountSelector`: SOQL access for Account records.
- `IHttpClient`: HTTP callout abstraction.
- `IAsyncEnqueuer`: `System.enqueueJob` wrapper.
- `IEventBus`: `EventBus.publish` wrapper.
- `IClock`: `System.now()` wrapper.
- `IQueueableJob`: queueable work that can run synchronously in tests.

## Implementations (Selectors + Utils)

Concrete implementations live in `core/selectors` and `core/utils` and are registered in `ProductionServices`:

- `AccountSelector` executes SOQL for `Account` data access.
- `HttpClient`, `SystemAsyncEnqueuer`, `SystemEventBus`, and `SystemClock` delegate to platform APIs.
- `AccountQueueable` implements both `Queueable` and `IQueueableJob` so business logic can be executed synchronously in tests.
- `NoopQueueableJob` is a safe placeholder implementation.

## Services (Business Logic)

Service classes are intentionally thin and rely on DI:

- `AccountService` demonstrates constructor injection of an `IAccountSelector`.
- `ExampleIntegrationService` resolves `IHttpClient`, `IAsyncEnqueuer`, and `IEventBus` and orchestrates a callout + queueable enqueue + event publish. It returns a small summary object (`ExampleResult`) to make orchestration testable.

## Tests and Test Taxonomy

The test structure mirrors the documented taxonomy:

- `test/unit/` contains fast unit tests that avoid DML/SOQL by using mocks.
- `test/service/` exercises real DML/SOQL but remains lightweight.
- `test/integration/` validates end-to-end behavior (trigger + DI + async) and is used sparingly.

Common utilities:

- `test/utils/BaseTest.cls` resets DI bindings and enforces fast test budgets.
- `test/utils/TestLimits.cls` asserts tight governor limits (DML, SOQL, CPU) to keep tests fast.
- `test/factories/TestDataFactory.cls` provides minimal, predictable test data helpers.

Mocks in `test/mocks` provide test doubles for each interface, including `MockAccountSelector`, `MockHttpClient`, `MockAsyncEnqueuer`, `MockEventBus`, `MockQueueable`, and `FixedClock`.

## Example Flows in Tests

Representative tests illustrate the intended testing strategies:

- `AccountServiceTest` uses constructor injection with `MockAccountSelector` (pure unit).
- `ExampleIntegrationServiceTest` registers mocks in `ServiceRegistry` and asserts orchestration behavior.
- `AccountTriggerHandlerIntegrationTest` registers a mock selector and verifies trigger execution paths with real DML.
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

## Key Files

- `core/services/ServiceRegistry.cls`: central DI/registry used by production and tests
- `core/services/ProductionServices.cls`: where production implementations are wired
- `core/domain/TriggerHandler.cls`: trigger base class
- `core/domain/TriggerRouter.cls`: trigger router for before/after events
- `test/factories/TestDataFactory.cls`: minimal test data helpers
- `test/mocks/*`: mock implementations and base mocks

