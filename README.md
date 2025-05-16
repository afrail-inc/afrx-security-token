afrx-security-token

Smart contract implementation for the AFRX Security Token, built on the ERC-3643 standard (formerly ERC-1400), incorporating enhanced compliance, upgradeability, and snapshot-based dividend distribution.

Project Links

AFRX Token White Paper (PDF)

Updated AFRX Token White Paper (PDF)


Overview

AFRX is a fully compliant security token issued by Afrail Inc., designed for global investor participation under Regulation D Rule 506(c) and Regulation S. This smart contract incorporates:

On-chain jurisdiction control

Whitelisting/KYC enforcement

Dividend claims by snapshot

Buyback & burn mechanics

UUPS upgradeable proxy architecture


Features

ERC-3643 Compliance (built on ERC-1400 base)

On-chain KYC/AML and jurisdiction whitelisting

365-day lockup enforcement per investor

Snapshot-based dividend distribution (ERC20Snapshot)

Dividend claim function with double-claim protection

Token buyback and burn mechanism

Role-based access control (OpenZeppelin AccessControl)

UUPS upgradeable architecture

Emergency pause/unpause functionality


Smart Contract Architecture

The AFRX Security Token is designed to meet enterprise and regulatory requirements under SEC Regulation D Rule 506(c) and Regulation S.

Token Symbol: AFRX

Token Cap: 5,770,000,000

Standard: ERC-3643

Lockup Period: 365 days

Compliance: Jurisdiction + whitelist-based investor restrictions

Upgradeability: Yes (via UUPS Proxy)

Audit Status: Final audit pending (CertiK); Pre-reviewed by Okiki Omisande (CodeHawks, Immunefi)


Usage Examples

// Claim dividends for a round
AFRXToken.claimDividends(roundId);

// Admin distributes dividends (snapshot is auto-generated)
AFRXToken.distributeDividends(totalAmount);

// Add investor to whitelist
AFRXToken.whitelistInvestor(address, "United States");

// Issue tokens to KYC'd investor
AFRXToken.issueTokens(address, 1000 ether, "United States");

## Contract Versions

- **AFRXToken.sol** – Current production contract (v1.1) with enhanced compliance and dividend distribution.
- **AFRXToken_legacy.sol** – Archived legacy contract retained for historical reference.

Installation

Clone the repository:

git clone https://github.com/afrail-inc/afrx-security-token.git
cd afrx-security-token

License

MIT License

