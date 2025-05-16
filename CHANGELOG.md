AFRX Security Token – Changelog

This changelog outlines the key changes between versions of the AFRX smart contract.


---

[v1.1] – May 2025

Production-ready release. Auditable. Fully compliant.

Added

Snapshot-based dividend distribution system (ERC20Snapshot)

claimDividends() for investor claims with anti-double-claim logic

distributeDividends() with snapshot tracking and round indexing

DividendInfo struct with total amount, snapshot ID, and supply

ReentrancyGuard for all external-facing functions


Compliance & Security

Enforced 365-day lockup for each investor

On-chain KYC/AML and jurisdiction-based investor whitelisting

Role-based access control: ADMIN_ROLE, MINTER_ROLE, PAUSER_ROLE, SNAPSHOT_ROLE, UPGRADER_ROLE

Pausable contract for emergency stops

Upgradeable architecture (UUPS proxy)


Events

Added DividendsAvailable and DividendsClaimed events

Clear logging for token issuance and jurisdiction updates



---

[v1.0] – Legacy

Initial implementation of AFRX.

Limitations

No snapshot-based dividend system

Manual token distributions; incorrect share allocations possible

No buyback or lockup functionality

No upgradeability

Lacked complete jurisdiction enforcement


Purpose

Retained as AFRXToken_legacy.sol for historical reference and audit comparison.

