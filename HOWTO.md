# Demo: Using the Lightning-Fast Apex Template in This Repo

This repository is an SFDX project that demonstrates how to build **fast, deterministic, maintainable Apex tests** by structuring production code for **dependency injection (DI)** and **mocking**.

It includes:
- A thin trigger entrypoint (`AccountTrigger.trigger`)
- A simple trigger framework (`TriggerHandler` + `TriggerRouter`)
- A small DI registry (`ServiceRegistry` + `ProductionServices` + `TestServiceRegistry`)
- Example “platform wrappers” (`IHttpClient`, `IClock`, `IAsyncEnqueuer`, `IEventBus`) for testability
- A test taxonomy (`unit/`, `service/`, `integration/`) that matches the docs in `README.md`

---

### Prerequisites

- Salesforce CLI (`sf`) installed and authenticated
- A Dev Hub (for scratch orgs) or any target org you can deploy to
- Optional for CI guardrails: `rg` (ripgrep) to run `scripts/ci_guardrails.sh`

---

### 1) Create or connect to an org

If you use scratch orgs:

```bash
sf org login web --set-default-dev-hub --alias DevHub
sf org create scratch --definition-file config/project-scratch-def.json --set-default --alias heimdall-ltf
```

Or, if deploying to an existing org:

```bash
sf org login web --set-default --alias heimdall-ltf
sf config set target-org=heimdall-ltf
```

---

### 2) Deploy the source

```bash
sf project deploy start --source-dir force-app
```

---

### 3) Run the tests

Run all Apex tests:

```bash
sf apex run test --test-level RunLocalTests --result-format human --synchronous
```

Run a single test class (example):

```bash
sf apex run test --tests ExampleIntegrationServiceTest --result-format human
```

---

### 4) Understand the architecture (what to copy into your real project)

#### Trigger pattern (keep triggers thin)

- **Trigger file**: `force-app/main/default/triggers/AccountTrigger.trigger`
  - Contains only routing logic.
- **Router**: `core/domain/TriggerRouter.cls`
  - Dispatches to the correct handler method based on trigger context.
- **Handler**: `core/domain/AccountTriggerHandler.cls`
  - Contains the business logic for the trigger and resolves dependencies via `ServiceRegistry`.

The intent is:
- Triggers remain “dumb entrypoints”
- You can test logic in isolation by mocking dependencies

#### Dependency injection (DI) pattern

- **Registry**: `core/services/ServiceRegistry.cls`
  - Central service locator with lazy bootstrap.
- **Production bindings**: `core/services/ProductionServices.cls`
  - The *only* place production implementations should be instantiated and registered.
- **Test helpers**: `core/services/TestServiceRegistry.cls`
  - Lets tests reset bindings and register mocks.

This is how production code avoids directly calling “hard dependencies” (SOQL, callouts, async, event publishing):
- Put the contract in `core/interfaces/*`
- Put the real implementation in `core/utils/*` or `core/selectors/*`
- Register implementations in `ProductionServices.registerAll()`
- Resolve by interface `Type` via `ServiceRegistry.resolve(...)`

---

### 5) Demo scenario: the Account trigger updates Description after insert

In this template, inserting an `Account` runs `AccountTriggerHandler.afterInsert(...)` and updates the record’s `Description`.

To see that end-to-end behavior, run the integration test:
- `force-app/main/default/classes/test/integration/AccountTriggerHandlerIntegrationTest.cls`

That test demonstrates the key idea:
- Reset DI bindings for isolation
- Register a mock selector (`MockAccountSelector`)
- Perform real DML (`insert`)
- Assert the trigger logic used the mock dependency

---

### 6) How to write a fast unit test (mock before you insert)

Unit tests should prefer:
- No DML
- No SOQL
- No async execution
- No callouts

Patterns to copy:
- Extend `BaseTest` (`test/utils/BaseTest.cls`) so every test can:
  - reset the registry
  - enforce fast-test guardrails via `TestLimits`

Example you can follow:
- `test/unit/AccountServiceTest.cls` (constructor injection with a mock selector)
- `test/unit/ExampleIntegrationServiceTest.cls` (register mocks into `ServiceRegistry`)

---

### 6.1) Test rubric (quick decision guide)

- **Unit tests (`test/unit/`)**: no DML or SOQL so they stay deterministic and fast.
- **Service tests (`test/service/`)**: minimal DML/SOQL to validate persistence without full platform noise.
- **Integration tests (`test/integration/`)**: full stack (triggers/async/callouts) to prove wiring works end-to-end.
- **Test utils & mocks (`test/utils/`, `test/mocks/`)**: no DML/SOQL so they are safe to reuse everywhere.

---

### 7) How to add a new dependency (recommended workflow)

When you introduce a new “hard dependency” (SOQL, callout, async, platform API), follow this sequence:

1) Define an interface in `core/interfaces/`
2) Implement it in `core/utils/` (or `core/selectors/` for SOQL)
3) Register it in `ProductionServices.registerAll()`
4) Write unit tests that register a mock via `TestServiceRegistry.registerMock(...)`

This keeps production code testable and makes unit tests fast.

---

### 8) CI guardrails (keep the architecture honest)

This repo includes `scripts/ci_guardrails.sh` to enforce two rules:
- No direct selector/service instantiation outside `ProductionServices`
- Warn when `http.send` is used directly (prefer `IHttpClient`)

Run it locally:

```bash
./scripts/ci_guardrails.sh
```

---

### What to customize next

- Replace the template “Account description update” with your real domain logic
- Add your real interfaces + implementations and wire them in `ProductionServices`
- Keep adding tests in this order:
  - **unit** → **service** → **integration**

