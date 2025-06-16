# AFRX Security Token – Changelog

This document tracks all notable changes to the AFRX smart contract and related documentation.

---

## [v1.2] – June 2025

**README and documentation updates for investor transparency and access.**

### ✏️ Documentation
- Added **Section 7: Proceeds Management and Escrow Strategy** to `README.md`
- Linked Section 7 in the `Project Links` section of `README.md`
- Corrected the **Dividend Distribution FAQ** link in `README.md`
- Clarified public documentation scope in project description
- Linked full documentation repository via banner and external updates

### 🎨 Branding
- Created `branding/` folder to host official AFRX token visual assets
- Added `README.md` in `branding/` outlining usage guidance and contact
- Uploaded mockup image of the AFRX token for investor decks, listings, and integrations
- Updated main `README.md` to embed the token image for visual reference

---

## [v1.1] – May 2025

**Production-ready release with enhanced compliance, dividend distribution, and upgradeability.**

### Added
- Snapshot-based dividend distribution using `ERC20Snapshot`
- Dividend claim and distribution functions with anti-double-claim protection
- 365-day investor lockup enforcement
- Token buyback and burn functionality
- Role-based access control and UUPS proxy upgradeability
- Emergency pause and unpause features
- Dividend Distribution FAQ document added and linked in README

### Documentation
- Added detailed `AFRX_Dividend_FAQ.md` for investor clarity
- Updated `README.md` with contract versions, usage examples, and FAQ link

---

## [v1.0] – Legacy

**Initial smart contract implementation.**

- Basic ERC-1400 token implementation without dividend snapshot functionality
- No buyback, lockup, or upgradeability features
- Limited compliance enforcement

---
