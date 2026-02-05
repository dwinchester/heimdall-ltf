# Examples

This directory contains the Renewal Readiness case study used to validate DML-less unit testing patterns across trigger,
controller, and batch contexts. The scenario is shared across teams so implementations can be compared consistently.

## In this article

- [Directory breakdown](#directory-breakdown)
- [Running tests](#running-tests)
- [Case study overview](#case-study-overview)
- [Canonical test data contract](#canonical-test-data-contract)
- [CRUD event expectations](#crud-event-expectations-contracted-deltas)
- [Bulkification test pack](#bulkification-test-pack)

## Directory breakdown

The `examples/force-app/main/default` tree contains all sample metadata for the case study. Use the table below to locate
the major pieces quickly.

| Path | Purpose |
|------|---------|
| `classes/` | Apex implementation, supporting services, and tests under `classes/test/...`. |
| `triggers/` | Opportunity and OpportunityLineItem triggers that wire calculation and validation into CRUD events. |
| `objects/` | Custom fields for Account, Opportunity, and OpportunityLineItem. |
| `lwc/renewalReadiness/` | Sample UI component and its Jest test in `__tests__/`. |

## Running tests

### LWC unit tests

Run a single component test from the repo root:

```sh
npm run test:unit -- -- --runTestsByPath "examples/force-app/main/default/lwc/renewalReadiness/__tests__/renewalReadiness.test.js"
```

Run the full LWC test suite:

```sh
npm run test:unit
```

### Apex tests

Deploy the examples to a scratch org or sandbox and run tests with the Salesforce CLI. For a full run:

```sh
sf apex run test --test-level RunLocalTests
```

To iterate faster, target a specific class under `classes/test/...`.

> [!NOTE]
> Apex tests require a connected org. Use a scratch org or sandbox with the example metadata deployed.

## Case study overview

Sales needs a simple "Renewal Readiness" mechanism for Renewal Opportunities. Readiness is recalculated any time an
Opportunity or its line items change, and the UI lets reps mark line items as Confirmed or At Risk with a Risk Reason. A
nightly batch also recalculates any stale renewals to keep the score fresh.

### Objects and fields

The model uses standard objects with minimal custom fields. Accounts track `CustomerPriority__c` plus a summary string
(`RenewalReadinessSummary__c`). Renewal Opportunities carry the health score, status, and last calculation timestamp.
Line items include confirmation and risk indicators, and when an opportunity is Red a Task is created with the subject
"Follow up: At-risk renewal".

### Shared readiness logic

The score starts at 50. Each confirmed line item adds +10 (capped at +30), each risk line item subtracts -15 (capped at
-45), and any risky item with a blank reason adds an extra -10 penalty. Apply the account priority bonus (High +10,
Medium +5, Low +0), then apply the time pressure rule (if `CloseDate <= today + 14 days` and the score is below 60,
subtract 10). Clamp the result to 0..100, map it to Green/Amber/Red, and always stamp `LastReadinessCalc__c = now`. Each
recalculation updates the account summary string to
`"<total renewals> renewals: <#Green> Green, <#Amber> Amber, <#Red> Red"`.

### Required CRUD behaviors

On insert, the system initializes readiness from existing line items, and creates a "Review renewal readiness" Task for
high-priority accounts when `CloseDate` is within 30 days. On update, readiness recalculates when the Opportunity changes
(`CloseDate`, `StageName`, or `Amount`) or when line items change. Validation is enforced before update: if
`RiskFlag__c = true`, `RiskReason__c` must be non-blank. On delete, line item removal triggers recalculation, and if no
remaining risky items exist the at-risk follow-up Task is removed.

### Apex contexts

The implementation covers triggers, an Apex controller, and a batch job. Opportunity triggers run before insert and
before/after update as needed, while OpportunityLineItem triggers validate before update and recalculate after
insert/update/delete. The controller exposes `load(opportunityId)` to return a DTO with score/status and editable line
items, and `save(opportunityId, changes)` to apply edits and return an updated DTO. The nightly batch recalculates stale
renewals where `LastReadinessCalc__c` is null or older than N days.

## Canonical test data contract

### Global assumptions

All dates are anchored to T0 = `Date.today()`. Urgent renewals use `CloseDate = T0 + 7` and non-urgent renewals use
`CloseDate = T0 + 60`. Every opportunity is Type = `Renewal` and `IsClosed = false`.

### Accounts (3)

| Key    | Account Name | CustomerPriority__c |
|--------|--------------|---------------------|
| A_HIGH | A_HIGH       | High                |
| A_MED  | A_MED        | Medium              |
| A_LOW  | A_LOW        | Low                 |

### Opportunities (6)

| Key | Name                    | Account | CloseDate | Purpose |
|-----|-------------------------|---------|-----------|---------|
| O1  | O1_NO_OLIS_URGENT       | A_LOW   | T0+7      | Baseline + urgent penalty |
| O2  | O2_CONFIRMED_CAP        | A_MED   | T0+60     | Confirmed cap + account bonus |
| O3  | O3_RISK_WITH_REASON     | A_HIGH  | T0+60     | Risk with reason + high bonus |
| O4  | O4_RISK_MISSING_REASON  | A_LOW   | T0+60     | Validation path (blank reason) |
| O5  | O5_MIXED_URGENT         | A_HIGH  | T0+7      | Mixed + urgent boundary |
| O6  | O6_DELETE_LAST_RISK     | A_MED   | T0+60     | Delete last risk -> task cleanup |

### OpportunityLineItems (by opportunity)

O1 has no line items. O2 has four confirmed items and no risk. O3 has a single at-risk item with the reason "Pricing
concern", while O4 has a single at-risk item with a blank reason to exercise validation. O5 mixes two confirmed items and
one at-risk item with reason "Legal review", and O6 has a single at-risk item with reason "Waiting for PO".

### Expected readiness results (initial calculation)

| Opp | Expected Score | Expected Status | Notes |
|-----|----------------|----------------|-------|
| O1  | 40             | Red            | Urgent penalty applies |
| O2  | 85             | Green          | Confirmed cap + account bonus |
| O3  | 45             | Red            | Risk + high bonus |
| O4  | blocked        | blocked        | Validation error (blank reason) |
| O5  | 65             | Amber          | No urgent penalty (>= 60) |
| O6  | 40             | Red            | Risk + medium bonus |

### Task expectations (initial calculation)

| Opp | Task exists? | Reason |
|-----|-------------|--------|
| O1  | Yes         | Red |
| O2  | No          | Green |
| O3  | Yes         | Red |
| O4  | No          | Blocked |
| O5  | No          | Amber |
| O6  | Yes         | Red |

### Account summary expectations (initial calculation)

A_LOW excludes the blocked O4 until it validates, resulting in
`"1 renewals: 0 Green, 0 Amber, 1 Red"`. A_MED expects `"2 renewals: 1 Green, 0 Amber, 1 Red"`, and A_HIGH expects
`"2 renewals: 0 Green, 1 Amber, 1 Red"`.

## CRUD event expectations (contracted deltas)

The O4 validation update attempts to save `RiskFlag__c = true` with a blank `RiskReason__c`. The expected outcome is a
validation error with no task creation and no readiness changes committed. The O6 delete-last-risk scenario deletes
`LI_O6_1`, moves O6 to 55 (Amber), removes the task, and updates the A_MED summary to
`"2 renewals: 1 Green, 1 Amber, 0 Red"`. The optional O5 risk removal sets `RiskFlag__c = false` and clears the reason on
`LI_O5_3`, moving O5 to 80 (Green) without creating a task and updating A_HIGH to
`"2 renewals: 1 Green, 0 Amber, 1 Red"`.

## Bulkification test pack

The bulk test pack generates 50 Renewal Opportunities under A_MED (25 urgent at `T0 + 7`, 25 not urgent at `T0 + 60`)
and attaches four line items to each, for 200 total. The patterns are P1 (20 opps with 4 confirmed), P2 (15 opps with 1
risk with reason, 1 confirmed, 2 neutral), P3 (10 opps with 3 risk with reason and 1 neutral), and P4 (5 opps with 2
confirmed, 1 risk with reason, 1 neutral). Bulk operations include inserting all OLIs, toggling `Confirmed__c` on 100
OLIs, and deleting 50 risk OLIs. Assertions check for no duplicate tasks per opportunity, proper parent grouping (each
opp recalculated once per scope), spot-checks per pattern, and correct Red/Amber/Green bucket counts derived from the
patterns plus the urgent rule.
