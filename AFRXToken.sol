// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AFRXToken is ERC20Capped, ERC20Burnable, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    // Events
    event TokensIssued(address indexed investor, uint256 amount, string jurisdiction);
    event InvestorWhitelisted(address indexed investor, string jurisdiction);
    event InvestorRemovedFromWhitelist(address indexed investor);
    event JurisdictionAdded(string jurisdiction);
    event JurisdictionRemoved(string jurisdiction);

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

    // Immutable Constants
    uint256 public immutable TOKEN_DECIMALS = 18;
    uint256 public immutable MAX_SUPPLY = 5_770_000_000 * (10 ** TOKEN_DECIMALS); // 5.77 billion AFRX tokens
    uint256 public immutable LOCKUP_PERIOD = 365 days;

    // Constructor
    constructor() ERC20("AfrailX Security Token", "AFRX") ERC20Capped(MAX_SUPPLY) {}

    // Minting function
    function issueTokens(address investor, uint256 amount, string memory jurisdiction) external onlyOwner {
        require(totalSupply().add(amount) <= cap(), "Cap exceeded");
        require(_isJurisdictionAllowed(jurisdiction), "Jurisdiction not allowed");
        _mint(investor, amount);

        if (_investors[investor].releaseTime == 0) {
            _investors[investor] = InvestorInfo({
                releaseTime: block.timestamp.add(LOCKUP_PERIOD),
                isWhitelisted: true,
                jurisdiction: jurisdiction
            });
        }

        emit TokensIssued(investor, amount, jurisdiction);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        if (from != address(0)) {
            require(_investors[from].isWhitelisted, "Sender not whitelisted");
            require(_investors[to].isWhitelisted, "Recipient not whitelisted");
            require(block.timestamp >= _investors[from].releaseTime, "Lock-up period not yet over");
            require(_isJurisdictionAllowed(_investors[to].jurisdiction), "Recipient jurisdiction not allowed");
        }
        super._beforeTokenTransfer(from, to, amount);
    }

    function whitelistInvestor(address investor, string memory jurisdiction) external onlyOwner {
        require(_isJurisdictionAllowed(jurisdiction), "Jurisdiction not allowed");
        _investors[investor].isWhitelisted = true;
        _investors[investor].jurisdiction = jurisdiction;

        emit InvestorWhitelisted(investor, jurisdiction);
    }

    function removeFromWhitelist(address investor) external onlyOwner {
        _investors[investor].isWhitelisted = false;

        emit InvestorRemovedFromWhitelist(investor);
    }

    function addJurisdiction(string memory jurisdiction) external onlyOwner {
        bytes32 j = keccak256(abi.encodePacked(jurisdiction));
        allowedJurisdictions[j] = true;

        emit JurisdictionAdded(jurisdiction);
    }

    function removeJurisdiction(string memory jurisdiction) external onlyOwner {
        bytes32 j = keccak256(abi.encodePacked(jurisdiction));
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

    function getInvestorInfo(address investor) external view returns (uint256, bool, string memory) {
        InvestorInfo memory info = _investors[investor];
        return (info.releaseTime, info.isWhitelisted, info.jurisdiction);
    }

    function _isJurisdictionAllowed(string memory jurisdiction) internal view returns (bool) {
        bytes32 j = keccak256(abi.encodePacked(jurisdiction));
        return allowedJurisdictions[j];
    }
}
