# DairyTrace: 26–28 October 2026

Required stack: Flutter, Dart, Firebase Authentication, Cloud Firestore.

This is a tight, prioritized MVP target, not a claim that the full PRD is implemented.

## Today — 26 October: reliable source records

- First slice: centre registration, farmer registration, stable IDs, assigned centre, owner-scoped directory, service validation, local Firestore rules, and service tests.
- Next: use registered farmer/centre IDs in new collections; explicit MORNING/EVENING; fat/SNF and configurable thresholds; generated alerts with threshold snapshots.
- Establish roles and cooperative/centre membership with trusted provisioning; enforce access with Rules, not only UI. Initial directory ownership is temporary, not PRD role-based authorization.
- Preserve legacy collections and mark them incomplete for reconciliation until explicitly mapped. Never infer farmer identity solely from name.
- Finish authentication/logout audit. No silent data deletion or alteration.
- Acceptance: register centre → register farmer → record quality/quantity → see saved record and alert; unauthorized access denied.

## Tomorrow — 27 October: traceability and reconciliation

- Create centre/date/session batches, associate compatible collections once, record quality outcomes and testers, trace failed batches to all source records.
- Configure effective-dated prices; preserve rule/version applied to each calculation. Demo values must be labelled, not presented as cooperative policy.
- Farmer-period totals, quantity-weighted fat/SNF (proposed policy), itemized amounts, integer paise/explicit rounding, OPEN → CALCULATING → REVIEW.
- Idempotent recalculation; ambiguous/missing pricing, incomplete legacy records and unresolved quality/payment policy must create review exceptions, not silently become zero pay.
- No automatic farmer deductions for failed batches. Payment eligibility and dispute policy must be agreed before finalization.
- Acceptance: mixed farmers across sessions produce independently checked totals; batch failure traces to every contributor.

## Day after tomorrow — 28 October: accountable completion

- Disputes, resolutions, immutable audit records, authorized corrections, finalized reconciliation snapshots and adjustment workflow.
- Dashboard metrics and a basic export/report from the same underlying records.
- Test data isolation, role checks, cloud persistence, error recovery, duplicate submissions, pricing boundaries, date boundaries, traceability and finalized-period protection.
- Demonstrate the full PRD success path. List deferred PRD details honestly.

## First-slice deployment status

The directory rules are local source changes. Existing deployed rules may reject directory access until reviewed and deployed. Do not open access globally to make the demo work. Validation: four service tests and ten local Firestore emulator checks passed; Android debug build and emulator launch succeeded. Analysis has only the pre-existing unnecessary import notice. Cloud deployment validation remains pending.

## Financial integrity constraint

Client-side Dart calculations can support a review preview, but an untrusted client must not be able to finalize arbitrary payable amounts or forge audit history. Choose and validate a trusted Firebase execution path or enforce a restricted, verifiable write protocol before calling financial finalization complete. Do not silently add an unapproved backend language to the required stack.

## Existing work

Remain on `feature/DT-348-app-audit-stabilization`; preserve original test edits and earlier launch fixes. The branch was three commits behind locally recorded origin/main. Review upstream changes before integrating to avoid duplicate work; no destructive reset or automatic pull into the dirty tree.

Repeat rules tests from mobile: firebase emulators:exec --only firestore --project demo-dairytrace --config firebase.rules-test.json 'node test/firestore/directory_rules.cjs'
