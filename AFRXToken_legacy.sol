// SPDX-License-Identifier: MIT
// AFRXToken_legacy.sol
// Archived legacy version of the AFRX Security Token smart contract.
// Note: Superseded by AFRXToken.sol v1.1 due to enhancements in compliance and dividend distribution mechanisms.

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol"; import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol"; import "@openzeppelin/contracts/security/Pausable.sol"; import "@openzeppelin/contracts/access/AccessControl.sol"; import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol"; import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol"; import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract AFRXToken is Initializable, ERC20Capped, ERC20Burnable, Pausable, AccessControl, ReentrancyGuard, ERC20Snapshot, UUPSUpgradeable { bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE"); bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE"); bytes32 public constant SNAPSHOT_ROLE = keccak256("SNAPSHOT_ROLE"); bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

uint256 public constant LOCKUP_PERIOD = 365 days;
uint8 public constant TOKEN_DECIMALS = 18;
string private constant TOKEN_NAME = "AfrailX Security Token";
string private constant TOKEN_SYMBOL = "AFRX";

struct InvestorInfo {
    uint256 releaseTime;
    bool isWhitelisted;
    string jurisdiction;
}

mapping(address => InvestorInfo) private _investors;
mapping(bytes32 => bool) private allowedJurisdictions;

event TokensIssued(address indexed investor, uint256 amount, string jurisdiction);
event TokenIssueRejected(address indexed investor, string reason);
event InvestorWhitelisted(address indexed investor, string jurisdiction);
event InvestorRemovedFromWhitelist(address indexed investor);
event JurisdictionAdded(string jurisdiction);
event JurisdictionRemoved(string jurisdiction);
event ContractPaused(string reason);
event ContractUnpaused();
event DividendsDistributed(uint256 totalAmount);
event BuybackExecuted(uint256 amount);

modifier onlyWhitelisted(address account) {
    require(_investors[account].isWhitelisted, "Investor not whitelisted");
    _;
}

constructor() ERC20(TOKEN_NAME, TOKEN_SYMBOL) ERC20Capped(5_770_000_000 * (10 ** TOKEN_DECIMALS)) {}

function initialize(address admin) public initializer {
    _grantRole(DEFAULT_ADMIN_ROLE, admin);
    _grantRole(ADMIN_ROLE, admin);
    _grantRole(MINTER_ROLE, admin);
    _grantRole(PAUSER_ROLE, admin);
    _grantRole(SNAPSHOT_ROLE, admin);
    _grantRole(UPGRADER_ROLE, admin);
}

function issueTokens(address investor, uint256 amount, string memory jurisdiction) external onlyRole(MINTER_ROLE) whenNotPaused {
    require(totalSupply() + amount <= cap(), "Cap exceeded");
    require(_isJurisdictionAllowed(jurisdiction), "Jurisdiction not allowed");

    _mint(investor, amount);

    if (_investors[investor].releaseTime == 0) {
        _investors[investor] = InvestorInfo({
            releaseTime: block.timestamp + LOCKUP_PERIOD,
            isWhitelisted: true,
            jurisdiction: _normalizeString(jurisdiction)
        });
    }

    emit TokensIssued(investor, amount, jurisdiction);
}

function batchIssueTokens(address[] calldata investors, uint256[] calldata amounts, string[] calldata jurisdictions) external onlyRole(MINTER_ROLE) whenNotPaused {
    require(investors.length == amounts.length && amounts.length == jurisdictions.length, "Array lengths mismatch");
    for (uint256 i = 0; i < investors.length; ++i) {
        issueTokens(investors[i], amounts[i], jurisdictions[i]);
    }
}

function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Snapshot) whenNotPaused {
    if (from != address(0) && to != address(0)) {
        require(_investors[from].isWhitelisted, "Sender not whitelisted");
        require(_investors[to].isWhitelisted, "Recipient not whitelisted");
        require(block.timestamp >= _investors[from].releaseTime, "Lock-up not over");
        require(_isJurisdictionAllowed(_investors[to].jurisdiction), "Recipient jurisdiction not allowed");
    }
    super._beforeTokenTransfer(from, to, amount);
}

function whitelistInvestor(address investor, string memory jurisdiction) external onlyRole(ADMIN_ROLE) {
    require(_isJurisdictionAllowed(jurisdiction), "Jurisdiction not allowed");
    _investors[investor].isWhitelisted = true;
    _investors[investor].jurisdiction = _normalizeString(jurisdiction);
    emit InvestorWhitelisted(investor, jurisdiction);
}

function removeFromWhitelist(address investor) external onlyRole(ADMIN_ROLE) {
    _investors[investor].isWhitelisted = false;
    emit InvestorRemovedFromWhitelist(investor);
}

function addJurisdiction(string memory jurisdiction) external onlyRole(ADMIN_ROLE) {
    bytes32 j = keccak256(abi.encodePacked(_normalizeString(jurisdiction)));
    allowedJurisdictions[j] = true;
    emit JurisdictionAdded(jurisdiction);
}

function removeJurisdiction(string memory jurisdiction) external onlyRole(ADMIN_ROLE) {
    bytes32 j = keccak256(abi.encodePacked(_normalizeString(jurisdiction)));
    allowedJurisdictions[j] = false;
    emit JurisdictionRemoved(jurisdiction);
}

function distributeDividends(uint256 totalAmount) external onlyRole(ADMIN_ROLE) nonReentrant whenNotPaused {
    require(totalSupply() > 0, "No tokens in circulation");
    _mint(address(this), totalAmount);
    for (uint256 i = 0; i < getRoleMemberCount(DEFAULT_ADMIN_ROLE); i++) {
        address investor = getRoleMember(DEFAULT_ADMIN_ROLE, i);
        if (balanceOf(investor) > 0) {
            uint256 share = (balanceOf(investor) * totalAmount) / totalSupply();
            _transfer(address(this), investor, share);
        }
    }
    emit DividendsDistributed(totalAmount);
}

function executeBuyback(uint256 amount) external onlyRole(ADMIN_ROLE) whenNotPaused {
    require(balanceOf(msg.sender) >= amount, "Insufficient tokens");
    _burn(msg.sender, amount);
    emit BuybackExecuted(amount);
}

function _normalizeString(string memory str) internal pure returns (string memory) {
    bytes memory bStr = bytes(str);
    for (uint256 i = 0; i < bStr.length; i++) {
        if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
            bStr[i] = bytes1(uint8(bStr[i]) + 32);
        }
    }
    return string(bStr);
}

function pause(string memory reason) external onlyRole(PAUSER_ROLE) {
    _pause();
    emit ContractPaused(reason);
}

function unpause() external onlyRole(PAUSER_ROLE) {
    _unpause();
    emit ContractUnpaused();
}

function snapshot() external onlyRole(SNAPSHOT_ROLE) {
    _snapshot();
}

function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}

// Required overrides
function decimals() public pure override returns (uint8) {
    return TOKEN_DECIMALS;
}

function supportsInterface(bytes4 interfaceId) public view override(AccessControl) returns (bool) {
    return super.supportsInterface(interfaceId);
}

}

