# CHANGELOG

All notable changes to the AFRX Security Token smart contract repository will be documented in this file.

----------

## [v1.18.3] – 2025-07-17

### Added

-   `NOTICE.md` with technical clarification that ERC‑3643 is built on ERC‑20, not ERC‑1400.

### Updated

-   `README.md`: Updated all references from ERC‑1400 to ERC‑20 to reflect accurate token standard architecture.

----------

## [v1.18.2] – 2025-06-24

### Changed

-   Replaced outdated README.md with updated full version including token design breakdown and corrected anchor links.
-   Linked the official AFRX token image (`branding/afrx-token.jpg`) in both image display and internal documentation.
-   Verified internal markdown anchors to ensure all Project Links route correctly to their sections.

----------

## [v1.18.1] – 2025-06-22

### Changed

-   Updated token name in `AFRXTokenV1_18.sol` from "AfrailX Security Token" to "Afrail Security Token" (line 57).
-   No changes to contract logic or functionality.
-   Aligned token metadata with official issuer name: Afrail Inc.

----------

## [v1.18] – 2025-06-22

### Added

-   Full audit-style revision of smart contract using CertiK-style methodology.
-   `AFRXTokenV1_18.sol` introduced with final production-grade compliance features.
-   Improved error handling and input validations across all major functions.
-   `dividendInfo[roundId].reclaimedAmount` to track unclaimed dividend recoveries.
-   `snapshotTimestamps` mapping for reclaim timing logic enforcement.
-   Events for `DividendsReclaimed`, `TestModeToggled`, `Upgraded` added.
-   Role-guarded upgradeability with UUPS implementation and `UPGRADER_ROLE`.

### Changed

-   Migrated prior production contract `AFRXToken.sol` to `contracts-archive` folder.
-   Updated jurisdiction enforcement to use normalized lowercase hashed keys.
-   Whitelisting logic now includes on-chain jurisdiction verification.
-   Token issuance now includes lockup timing enforcement (`LOCKUP_PERIOD`).
-   Enhanced double-claim protection in `claimDividends()` with snapshot balance validation.

### Fixed

-   Redundant logic and poor modularization from previous versions.
-   Snapshot imbalance issue when treasury or contract address skewed supply.
-   Compatibility issues with OpenZeppelin `ERC20Capped` and `Snapshot`.

### Deprecated

-   `AFRXToken.sol` (moved to archive)
-   `AFRXToken_legacy.sol` (retained for historical reference)

----------

## [v1.17] – 2025-06-21

Initial final-stage candidate before CertiK audit pass. Introduced:

-   Structured investor lockup and jurisdiction enforcement.
-   Basic dividend distribution via snapshots.
-   Full OpenZeppelin upgradeable framework.
