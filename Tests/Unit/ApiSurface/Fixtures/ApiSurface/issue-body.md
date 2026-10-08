## Auto-fixable  (tick, then comment /apply-drift)  (5)

- [ ] `RES-ENUM-STALE:TestPolicy:Mode`
      csdl:beta/testPolicy/mode, missing member(s): enforce
- [ ] `RES-ENUM-STALE:TestPolicy:State`
      csdl:beta/testPolicy/state, missing member(s): disabled, reportOnly
- [ ] `RES-PROP-MISSING:TestGroup:NewName`
      csdl:beta/testGroup/newName, Edm.String
- [ ] `RES-PROP-MISSING:TestPolicy:NewFlag`
      csdl:beta/testPolicy/newFlag, Edm.Boolean
- [ ] `VND-ENUM-MEMBER-ADDED:beta:testPolicy:state`
      csdl:beta/testPolicy/state, new member(s): reportOnly

<details>
<summary>Everything that is not auto-fixable</summary>

## Needs a decision  (2)

- `RES-PROP-ORPHANED:TestPolicy:Invented`
      dsc:TestPolicy/Invented, declared String, not offered by the vendor type
- `RES-TYPE-MISMATCH:TestGroup:Priority`
      csdl:beta/testGroup/priority, declared UInt32, vendor Edm.Int64

## Graph shim, regenerate to fix  (0)

None.

## Intune settings catalog, regenerate to fix  (0)

None.

## Read-only, suggested for no implementation  (1)

- `RES-PROP-READONLY:TestPolicy:CreatedDateTime`
      csdl:beta/testPolicy/createdDateTime, Edm.DateTimeOffset

## Coverage gaps  (1)

Resources: 1 compared, 1 skipped. Undeclared vendor properties: 7.

## Graph nouns with full CRUD and no resource  (0)

None.

## Cmdlets no resource calls any more  (0)

None.

## Vendor changes since Microsoft.Graph.Authentication 2.34.0 -> 2.35.1  (1)

- `VND-TYPE-PROP-ADDED:beta:testPolicy:extraField`
      csdl:beta/testPolicy/extraField

## Newer dependency versions available  (1)

Major (1)
- `VND-NEWER-VERSION:Az.Resources`
      9.0.1 -> 10.1.0

## Unaccepted breaking findings, oldest 2026-07-01  (2)

- `RES-PROP-ORPHANED:TestPolicy:Invented`  first seen 2026-08-10
- `RES-TYPE-MISMATCH:TestGroup:Priority`  first seen 2026-07-01

</details>
