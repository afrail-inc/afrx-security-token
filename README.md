# AFRX Security Token

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Built with Solidity](https://img.shields.io/badge/built%20with-Solidity-363636)
![ERC-3643](https://img.shields.io/badge/ERC--3643-Compliant-brightgreen)

<p align="center">
  <img src="https://github.com/afrail-inc/afrx-security-token/raw/main/branding/afrx-token.jpg" alt="AFRX Token" width="200"/>
</p>

Smart contract implementation for the **AFRX Security Token**, built on the [ERC-3643](https://tokeny.com/erc3643/) standard (ERC-20 base), incorporating enhanced compliance, upgradeability, and snapshot-based dividend distribution.

> 📌 **Important Notice:** Please see [NOTICE.md](./NOTICE.md) for technical clarification on ERC‑3643 vs ERC‑1400.

## Project Links

- [AFRXTokenV1_18.sol (Production Contract)](https://github.com/afrail-inc/afrx-security-token/blob/main/AFRXTokenV1_18.sol)
- [AFRXToken.sol (Archived Prior Version)](https://github.com/afrail-inc/afrx-security-token/blob/main/archived-contracts/AFRXToken.sol)
- [AFRXToken_legacy.sol (Older Archived Contract)](https://github.com/afrail-inc/afrx-security-token/blob/main/docs/AFRXToken_legacy.sol)
- [AFRX Token White Paper (PDF)](https://github.com/afrail-inc/afrx-security-token/blob/main/docs/AFRX_Token_White_Paper.pdf)
- [Updated AFRX Token White Paper (PDF)](https://github.com/afrail-inc/afrx-security-token/blob/main/docs/Updated_AFRX_White_Paper_v1_4_May2025.pdf)
- [AFRX Security Token – Official Token Design](#afrx-security-token--official-token-design)
- [CHANGELOG.md](https://github.com/afrail-inc/afrx-security-token/blob/main/CHANGELOG.md)
- [AFRX Dividend Distribution FAQ](https://github.com/afrail-inc/afrx-security-token/blob/main/docs/AFRX_Dividend_FAQ.md)
- [SECURITY.md](https://github.com/afrail-inc/afrx-security-token/blob/main/SECURITY.md)
- [Section 7: Proceeds Management and Escrow Strategy](#-section-7-proceeds-management-and-escrow-strategy)
- [AFRX Branding Assets](https://github.com/afrail-inc/afrx-security-token/tree/main/branding)

## Overview

AFRX is a fully compliant security token issued by Afrail Inc., designed for global investor participation under **Regulation D Rule 506(c)** and **Regulation S**. This smart contract incorporates:

- On-chain jurisdiction control  
- Whitelisting/KYC enforcement  
- Dividend claims by snapshot  
- Buyback & burn mechanics  
- UUPS upgradeable proxy architecture  

## Features

- ERC-3643 Compliance (built on ERC-20 base)  
- On-chain KYC/AML and jurisdiction whitelisting  
- 365-day lockup enforcement per investor  
- Snapshot-based dividend distribution (`ERC20Snapshot`)  
- Dividend claim function with double-claim protection  
- Token buyback and burn mechanism  
- Role-based access control (`AccessControl`)  
- UUPS upgradeable architecture  
- Emergency pause/unpause functionality  

## Smart Contract Architecture

The AFRX Security Token is designed to meet enterprise and regulatory requirements under SEC Regulation D Rule 506(c) and Regulation S.

- **Token Symbol:** AFRX  
- **Token Cap:** 5,770,000,000  
- **Standard:** ERC-3643  
- **Lockup Period:** 365 days  
- **Compliance:** Jurisdiction + whitelist-based investor restrictions  
- **Upgradeability:** Yes (via UUPS Proxy)  
- **Audit Status:** Final audit pending (CertiK); Pre-reviewed by Okiki Omisande (CodeHawks, Immunefi)

## AFRX Security Token – Official Token Design

This image represents the official token design for the AFRX Security Token, issued by Afrail Inc. under the ERC-3643 standard. The design is not just symbolic — it encapsulates the token’s core attributes of compliance, programmability, and real-world equity backing.

**🔍 Token Design Breakdown:**

Central Symbol (Modified **“a”** with Tail and Square Dot)
The stylized central emblem is a unique take on the lowercase "a", referencing **Afrail Inc.** as the issuer.

The vertical tail suggests directional innovation — **mobility** and **movement**.

The square dot beneath the tail represents **precision**, **order**, and **finality** — hallmarks of smart contract determinism and regulatory clarity.

**Text Engraving:**

Top Arc: **AFRX SECURITY TOKEN ERC-3643**: This reinforces the token’s regulatory compliance as a tokenized security, adhering to globally recognized standards for permissioned tokens with KYC/AML layers.

Bottom Arc: **BACKED BY REAL EQUITY IN AFRAIL INC**: This line affirms that AFRX is not a utility token or speculative cryptocurrency. Each token is linked to actual equity held in Afrail Inc., providing *intrinsic value* and *real ownership*.

Side Stars (at 9 and 3 o’clock)
The symmetrical stars symbolize stability and compliance — referencing dual oversight: one by the issuer (Afrail Inc.), the other by regulatory frameworks. Their positioning balances the circular theme, reinforcing the idea of completeness and trust.

**Gold Finish:**
The gold coloration is deliberate — symbolizing:

- Asset-backing
- Investor-grade security
- Long-term value
  
It visually separates AFRX from typical volatile tokens by emphasizing trust, regulation, and real equity.

**🛍 Purpose and Usage:**

This token design should appear in all:

- ✅ Official investor materials
- ✅ Product whitepapers
- ✅ Regulatory filings (visual representation)
- ✅ Press releases
- ✅ Token dashboards or portals (where graphical representations are supported)

## 🔐 Section 7: Proceeds Management and Escrow Strategy

All cash proceeds from the sale of AFRX Security Tokens will be paid directly into a regulated **Escrow Account** upon commencement of token production and sale. This structure ensures:

- ✅ Transparency  
- ✅ Investor protection  
- ✅ Regulatory and compliance assurance  

Afrail Inc. **will not have access to these funds** until a minimum capital raise threshold is met.

### 🎯 Minimum Raise Requirement

To unlock funds from the escrow:

- **Target Raise:** $4.039 billion USD  
- **Minimum Threshold (10%):** $403.9 million USD  

Once 10% is raised and verified, Afrail Inc. may begin drawing down funds in accordance with an approved use-of-funds schedule.

### 🏗️ Bridge Financing for Early Operations

Before reaching 10%, Afrail Inc. will pursue **short-term, low-interest loans backed by the escrow balance**, for:

- 🏙️ Pre-engineering in **South Florida**  
- 🌍 Site preparation in **Northern Namibia**

This enables early progress while maintaining responsible financial safeguards.

### ✅ Benefits of This Structure

- ⚖️ **Investor Assurance:** No premature access to capital  
- 🔐 **Compliance:** Aligned with security token regulatory best practices  
- 🚀 **Readiness:** Enables engineering momentum with escrow-backed credibility

## Contract Versions

- **AFRXToken.sol** – Current production contract (v1.1) with enhanced compliance and dividend distribution.  
- **AFRXToken_legacy.sol** – Archived legacy contract retained for historical reference.  

## Installation

```solidity
// Claim dividends for a round  
AFRXToken.claimDividends(roundId);

// Admin distributes dividends (snapshot is auto-generated)  
AFRXToken.distributeDividends(totalAmount);

// Add investor to whitelist  
AFRXToken.whitelistInvestor(address, "United States");

// Issue tokens to KYC'd investor  
AFRXToken.issueTokens(address, 1000 ether, "United States");
```

## License

MIT License  

Copyright (c) 2025 Afrail Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Clone the repository

```bash
git clone https://github.com/afrail-inc/afrx-security-token.git
cd afrx-security-token
```
