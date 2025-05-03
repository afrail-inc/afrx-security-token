// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract AFRXToken is ERC20Capped, AccessControl, ReentrancyGuard, Pausable {
    // Define roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Events
    event TokensIssued(address indexed investor, uint256 amount, string jurisdiction);
    event TokenIssueRejected(address indexed investor, string reason);
    event InvestorWhitelisted(address indexed investor, string jurisdiction);
    event InvestorRemovedFromWhitelist(address indexed investor);
    event JurisdictionAdded(string jurisdiction);
    event JurisdictionRemoved(string jurisdiction);
    event ContractPaused(string reason);
    event ContractUnpaused();

    // Investor Info Struct
    struct InvestorInfo {
        uint256 releaseTime;
        bool isWhitelisted;
        string jurisdiction;
    }

    // Mapping for investor info
    mapping(address => InvestorInfo) private _investors;

    // Mapping for allowed jurisdictions
    mapping(bytes32 => bool) private allowedJurisdictions;

    // Constants
    uint8 public constant TOKEN_DECIMALS = 18;
    uint256 public constant LOCKUP_PERIOD = 180 days; // 6 months

    // Constructor
    constructor()
        ERC20("AfrailX Security Token", "AFRX")
        ERC20Capped(5_770_000_000 * (10 ** TOKEN_DECIMALS))
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    // Minting function
    function issueTokens(address investor, uint256 amount, string memory jurisdiction)
        external
        onlyRole(MINTER_ROLE)
        whenNotPaused
    {
        if (totalSupply() + amount > cap()) {
            emit TokenIssueRejected(investor, "Cap exceeded");
            revert("Cap exceeded");
        }

        if (!_isJurisdictionAllowed(jurisdiction)) {
            emit TokenIssueRejected(investor, "Jurisdiction not allowed");
            revert("Jurisdiction not allowed");
        }

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

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override
        whenNotPaused
    {
        if (from != address(0) && to != address(0)) {
            require(_investors[from].isWhitelisted, "Sender not whitelisted");
            require(_investors[to].isWhitelisted, "Recipient not whitelisted");
            require(block.timestamp >= _investors[from].releaseTime, "Lock-up period not over");
            require(_isJurisdictionAllowed(_investors[to].jurisdiction), "Recipient jurisdiction not allowed");
        }
        super._beforeTokenTransfer(from, to, amount);
    }

    function whitelistInvestor(address investor, string memory jurisdiction)
        external
        onlyRole(ADMIN_ROLE)
    {
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

    function lockupExpiry(address investor) external view returns (uint256) {
        return _investors[investor].releaseTime;
    }

    function isWhitelisted(address investor) external view returns (bool) {
        return _investors[investor].isWhitelisted;
    }

    function investorJurisdiction(address investor) external view returns (string memory) {
        return _investors[investor].jurisdiction;
    }

    function getInvestorInfo(address investor)
        external
        view
        returns (uint256, bool, string memory)
    {
        InvestorInfo memory info = _investors[investor];
        return (info.releaseTime, info.isWhitelisted, info.jurisdiction);
    }

    function _isJurisdictionAllowed(string memory jurisdiction) internal view returns (bool) {
        bytes32 j = keccak256(abi.encodePacked(_normalizeString(jurisdiction)));
        return allowedJurisdictions[j];
    }

    function pause(string memory reason) external onlyRole(ADMIN_ROLE) {
        _pause();
        emit ContractPaused(reason);
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
        emit ContractUnpaused();
    }

    function _normalizeString(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        for (uint256 i = 0; i < bStr.length; i++) {
            // Uppercase letters
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                bStr[i] = bytes1(uint8(bStr[i]) + 32); // to lowercase
            }
        }
        return string(bStr);
    }
}
