# Lightning-Fast Apex Test Project Template (SFDX)

This repo is a working Salesforce DX scaffold based on the included template docs. The goal is **fast, deterministic, maintainable tests** by structuring production code for **mocking and dependency injection**.

## Core Principles

- **No database unless unavoidable**
- **Mock before you insert**
- **Unit tests > service tests > integration tests**
- **SeeAllData=false always**
- **Architecture enables speed**

## Folder Structure

```
force-app/main/default/
  classes/
    core/
      interfaces/
      selectors/
      services/
      domain/
      utils/
    test/
      factories/
      mocks/
      unit/
      service/
      integration/
  triggers/
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

## Test Taxonomy

- `Unit_*`: pure mocks, no DML/SOQL
- `Service_*`: minimal DML/SOQL to validate business logic
- `Integration_*`: full stack with triggers/async/callouts (use sparingly)

## CI Guardrails

Run `scripts/ci_guardrails.sh` in CI to enforce:

- No direct selector/service instantiation outside `ProductionServices`
- Warn on direct `http.send` calls (use `IHttpClient` instead)

The guardrail script requires `rg` (ripgrep) to be available in CI.

## Key Files

- `core/services/ServiceRegistry.cls`: central DI/registry used by production and tests
- `core/services/ProductionServices.cls`: where production implementations are wired
- `core/domain/TriggerHandler.cls`: trigger base class
- `core/domain/TriggerRouter.cls`: trigger router for before/after events
- `test/factories/TestDataFactory.cls`: minimal test data helpers
- `test/mocks/*`: mock implementations and base mocks

