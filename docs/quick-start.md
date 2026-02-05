## Quickstart: Heimdall LTF

Get a new team to a first passing test, then learn the architecture and testing patterns you can copy into your real project.

In this quickstart, you will:

- Connect to a Salesforce org and deploy the framework
- Run Apex tests and (optionally) the LWC example tests
- Create a fast, DML-less unit test using the DI helpers
- Understand the core patterns (triggers, DI, mocks, test taxonomy)

---

## Prerequisites

- Salesforce CLI (`sf`) installed and authenticated
- A Dev Hub (for scratch orgs) or any target org you can deploy to
- Node.js + npm (only for LWC tests in `examples/`)
- Optional: `rg` (ripgrep) to run `scripts/ci_guardrails.sh`

---

## Get the repo and install dev dependencies

From the repo root:

```bash
npm install
```

This is only required for the LWC example tests in `examples/`.

---

## Create or connect to an org

Choose one of the following:

### Use a scratch org

```bash
sf org login web --set-default-dev-hub --alias DevHub
sf org create scratch --definition-file config/project-scratch-def.json --set-default --alias heimdall-ltf
```

Or run the helper script:

```bash
./scripts/setup_scratch_org.sh heimdall-ltf DevHub
```

Note: the script currently skips the core deploy. Run `sf project deploy start --source-dir force-app`
afterward or uncomment the lines in `scripts/setup_scratch_org.sh`.

### Use an existing org

```bash
sf org login web --set-default --alias heimdall-ltf
sf config set target-org=heimdall-ltf
```

---

## Deploy the source

Deploy the framework:

```bash
sf project deploy start --source-dir force-app
```

Deploy the demo package (optional):

```bash
sf project deploy start --source-dir examples/force-app
```

The demo package depends on the framework in `force-app`, so deploy the framework first.

---

## Run the tests

Run all Apex tests:

```bash
sf apex run test --test-level RunLocalTests --result-format human --synchronous
```

Run a single test class (example):

```bash
sf apex run test --tests ExampleIntegrationServiceTest --result-format human
```

Optional: run the LWC example tests:

```bash
npm test -- examples/force-app/main/default/lwc/renewalReadiness/__tests__/renewalReadiness.test.js
```

---

## Create your first fast unit test

Create a DML-less unit test that uses DI and mocks. Prefer the drop-in bootstrap helper:

```apex
@isTest
private class QuickStartExampleTest extends BaseTest {
    @isTest
    static void resolvesMocksAfterReset() {
        TestBootstrap.defaults();

        TestServiceRegistry.registerMock(IHttpClient.class, new MockHttpClient());
        TestServiceRegistry.registerMock(IAsyncEnqueuer.class, new MockAsyncEnqueuer());
        TestServiceRegistry.registerMock(IEventBus.class, new MockEventBus());

        ExampleIntegrationService svc = new ExampleIntegrationService();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com');
        req.setMethod('GET');

        ExampleIntegrationService.ExampleResult result = svc.runExample(
            req,
            new AccountQueueable(),
            new List<SObject> { new Account(Name = 'Test') }
        );

        System.assertEquals(200, result.statusCode);
        assertFastTest();
    }
}
```

Strict mode fails fast if test code attempts DML, callouts, async enqueue, or event publish:

```apex
@isTest
private class StrictModeExampleTest extends BaseTest {
    @isTest
    static void disallowsPlatformSideEffects() {
        TestBootstrap.strict();
        // Test logic here
    }
}
```

Gradual adoption: teams can start permissive and tighten later with a single toggle:

```apex
@isTest
private class StrictnessToggleExampleTest extends BaseTest {
    @isTest
    static void canToggleStrictness() {
        TestBootstrap.setStrictMode(false);
        TestBootstrap.reset();

        TestBootstrap.setStrictMode(true);
        TestBootstrap.reset();
    }
}
```

Run it:

```bash
sf apex run test --tests QuickStartExampleTest --result-format human
```

---

## Key architecture concepts

### Trigger pattern (keep triggers thin)

- Trigger file: `examples/force-app/main/default/triggers/AccountTrigger.trigger`
  - Contains only routing logic.
- Router: `core/domain/TriggerRouter.cls`
  - Dispatches to the correct handler method based on trigger context.
- Handler: `examples/force-app/main/default/classes/demo/domain/AccountTriggerHandler.cls`
  - Contains the business logic for the trigger and resolves dependencies via `ServiceRegistry`.

Intent:

- Triggers remain “dumb entrypoints”
- You can test logic in isolation by mocking dependencies

### Dependency injection (DI) pattern

- Registry: `core/services/ServiceRegistry.cls`
  - Central service locator with lazy bootstrap.
- Production bindings: `core/services/ProductionServices.cls`
  - The only place production implementations should be instantiated and registered.
- Test helpers: `core/services/TestServiceRegistry.cls`
  - Lets tests reset bindings and register mocks.

This is how production code avoids directly calling “hard dependencies” (SOQL, callouts, async, event publishing):

- Put the contract in `core/interfaces/*`
- Put the real implementation in `core/infrastructure/*` or `core/selectors/*`
- Register implementations in `ProductionServices.registerAll()`
- Resolve by interface `Type` via `ServiceRegistry.resolve(...)`

The DML wrapper follows the same pattern:

- Interface: `core/interfaces/IRecordMutator.cls`
- Implementation: `core/infrastructure/SystemRecordMutator.cls`
- Test double: `test/mocks/MockRecordMutator.cls`

---

## Demo scenario

In this template, inserting an `Account` runs `AccountTriggerHandler.afterInsert(...)` and updates the record’s `Description`. The demo lives in `examples/`.

Demo-specific bindings (like `IAccountSelector`) are registered in `DemoServices`.

To see the end-to-end behavior, run the integration test:

- `examples/force-app/main/default/classes/test/integration/AccountTriggerHandlerIntegrationTest.cls`

That test demonstrates the key idea:

- Reset DI bindings for isolation
- Register a mock selector (`MockAccountSelector`)
- Perform real DML (`insert`)
- Assert the trigger logic used the mock dependency

---

## Test taxonomy (quick decision guide)

- Unit tests (`test/unit/`): no DML or SOQL so they stay deterministic and fast.
- Service tests (`test/service/`): minimal DML/SOQL to validate persistence without full platform noise.
- Integration tests (`test/integration/`): full stack (triggers/async/callouts) to prove wiring works end-to-end.
- Test helpers & mocks (`test/helpers/`, `test/mocks/`): no DML/SOQL so they are safe to reuse everywhere.

Examples to copy:

- `examples/force-app/main/default/classes/test/unit/AccountServiceTest.cls` (constructor injection with a mock selector)
- `examples/force-app/main/default/classes/test/unit/ExampleIntegrationServiceTest.cls` (register mocks into `ServiceRegistry`)
- `examples/force-app/main/default/classes/test/unit/RecordMutatorTest.cls` (record mutator wiring without DML)
- `force-app/main/default/classes/test/unit/RecordMutatorDmlTest.cls` (record mutator behavior with real DML)

---

## Add a new dependency (recommended workflow)

When you introduce a new “hard dependency” (SOQL, callout, async, platform API), follow this sequence:

1. Define an interface in `core/interfaces/`
2. Implement it in `core/infrastructure/` (or `core/selectors/` for SOQL)
3. Register it in `ProductionServices.registerAll()`
4. Write unit tests that register a mock via `TestServiceRegistry.registerMock(...)`

This keeps production code testable and makes unit tests fast.

---

## Core vs optional interfaces (what must be mocked)

Core interfaces are assumed by the framework and should be safe to resolve in tests.
Optional interfaces are app-specific and only needed where you use them.

Core interfaces (provided by `core/interfaces`):

- `IHttpClient` (callouts)
- `IAsyncEnqueuer` (queueable enqueue)
- `IEventBus` (platform events)
- `IClock` (time)
- `IQueueableJob` (syncable queueable work)
- `IRecordMutator` (DML)

Optional interfaces (examples only, used when you adopt them in your app):

- `IAccountSelector`
- `IOpportunitySelector`

Minimum mocking guidance:

- Unit tests: mock any interface your code resolves, plus any optional interfaces used by triggers.
- Service/integration tests: you can use real implementations selectively, but register mocks to avoid callouts/async/events unless you explicitly test those paths.

---

## Seed recipes (minimal setup)

These examples are intended to be copied into real projects with minimal setup.

Trigger recipe (thin trigger + handler + integration test):

- Handler: `examples/force-app/main/default/classes/demo/domain/AccountTriggerHandler.cls`
- Trigger: `examples/force-app/main/default/triggers/AccountTrigger.trigger`
- Integration test: `examples/force-app/main/default/classes/test/integration/AccountTriggerHandlerIntegrationTest.cls`

Service recipe (pure service composition):

- Service: `examples/force-app/main/default/classes/demo/services/OpportunityPipelineService.cls`
- Unit test: `examples/force-app/main/default/classes/test/unit/OpportunityPipelineServiceTest.cls`

Integration recipe (callout + async + event orchestration):

- Service: `examples/force-app/main/default/classes/demo/services/ExampleIntegrationService.cls`
- Unit test: `examples/force-app/main/default/classes/test/unit/ExampleIntegrationServiceTest.cls`

Each test starts with `TestBootstrap.defaults()` and registers only what it needs.

---

## CI guardrails

This repo includes `scripts/ci_guardrails.sh` to enforce two rules:

- No direct selector/service instantiation outside `ProductionServices`
- Warn when `http.send` is used directly (prefer `IHttpClient`)

Run it locally:

```bash
./scripts/ci_guardrails.sh
```

---

## Troubleshooting

- Confirm the target org: `sf org display --target-org heimdall-ltf`
- Re-run deploy if metadata is missing: `sf project deploy start --source-dir force-app`
- If demo deploy fails, make sure `force-app` succeeded first

---

## Next steps

- Replace the template “Account description update” with your real domain logic
- Add your real interfaces + implementations and wire them in `ProductionServices`
- Keep adding tests in this order: unit &rarr; service &rarr; integration
