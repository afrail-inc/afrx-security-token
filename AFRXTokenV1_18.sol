// SPDX-License-Identifier: MIT pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20CappedUpgradeable.sol"; import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol"; import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20SnapshotUpgradeable.sol"; import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol"; import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol"; import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol"; import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol"; import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract AFRXTokenV1_18 is Initializable, ERC20CappedUpgradeable, ERC20BurnableUpgradeable, ERC20SnapshotUpgradeable, PausableUpgradeable, AccessControlUpgradeable, ReentrancyGuardUpgradeable, UUPSUpgradeable { bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE"); bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE"); bytes32 public constant SNAPSHOT_ROLE = keccak256("SNAPSHOT_ROLE"); bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

uint256 public constant LOCKUP_PERIOD = 365 days;
uint8 public constant TOKEN_DECIMALS = 18;

bool public isTestMode;
address public treasury;

struct InvestorInfo {
    uint256 releaseTime;
    bool isWhitelisted;
    string jurisdiction;
}

struct DividendInfo {
    uint256 totalAmount;
    uint256 snapshotId;
    uint256 totalSupplyAtSnapshot;
    uint256 reclaimedAmount;
}

mapping(address => InvestorInfo) private _investors;
mapping(bytes32 => bool) private allowedJurisdictions;
mapping(uint256 => DividendInfo) public dividendInfo;
mapping(uint256 => mapping(address => bool)) public dividendsClaimed;
mapping(uint256 => uint256) public snapshotTimestamps;
uint256 public currentDividendRound;

event TokensIssued(address indexed investor, uint256 amount, string jurisdiction);
event InvestorWhitelisted(address indexed investor, string jurisdiction);
event InvestorRemovedFromWhitelist(address indexed investor);
event JurisdictionAdded(string jurisdiction);
event JurisdictionRemoved(string jurisdiction);
event ContractPaused(string reason);
event ContractUnpaused();
event DividendsAvailable(uint256 indexed roundId, uint256 totalAmount);
event DividendsClaimed(uint256 indexed roundId, address indexed investor, uint256 amount);
event LockupReleased(address indexed investor);
event Upgraded(address indexed newImplementation);
event TestModeToggled(bool status);
event DividendsReclaimed(uint256 indexed roundId, uint256 amount);

modifier onlyWhitelisted(address account) {
    require(_investors[account].isWhitelisted, "Investor not whitelisted");
    _;
}

constructor() initializer {}

function initialize(address admin, address _treasury) public initializer {
    require(_treasury != address(0), "Treasury address required");

    __ERC20_init("Afrail Security Token", "AFRX");
    __ERC20Capped_init(5_770_000_000 * (10 ** TOKEN_DECIMALS));
    __ERC20Burnable_init();
    __ERC20Snapshot_init();
    __Pausable_init();
    __AccessControl_init();
    __ReentrancyGuard_init();
    __UUPSUpgradeable_init();

    treasury = _treasury;

    _grantRole(DEFAULT_ADMIN_ROLE, admin);
    _grantRole(ADMIN_ROLE, admin);
    _grantRole(MINTER_ROLE, admin);
    _grantRole(PAUSER_ROLE, admin);
    _grantRole(SNAPSHOT_ROLE, admin);
    _grantRole(UPGRADER_ROLE, admin);
}

function issueTokens(address investor, uint256 amount, string memory jurisdiction)
    external
    onlyRole(MINTER_ROLE)
    whenNotPaused
{
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

function batchIssueTokens(address[] calldata investors, uint256[] calldata amounts, string[] calldata jurisdictions)
    external
    onlyRole(MINTER_ROLE)
    whenNotPaused
{
    require(investors.length == amounts.length && amounts.length == jurisdictions.length, "Array lengths mismatch");
    for (uint256 i = 0; i < investors.length; ++i) {
        issueTokens(investors[i], amounts[i], jurisdictions[i]);
    }
}

function distributeDividends(uint256 totalAmount) external onlyRole(ADMIN_ROLE) nonReentrant whenNotPaused {
    require(totalSupply() > 0, "No tokens in circulation");
    require(treasury != address(0), "Treasury not set");
    require(balanceOf(treasury) >= totalAmount, "Insufficient treasury balance");

    uint256 snapshotId = _snapshot();
    uint256 snapshotSupply = totalSupply() - balanceOf(address(this));

    _transfer(treasury, address(this), totalAmount);

    dividendInfo[currentDividendRound] = DividendInfo({
        totalAmount: totalAmount,
        snapshotId: snapshotId,
        totalSupplyAtSnapshot: snapshotSupply,
        reclaimedAmount: 0
    });

    snapshotTimestamps[snapshotId] = block.timestamp;

    emit DividendsAvailable(currentDividendRound, totalAmount);
    currentDividendRound++;
}

function claimDividends(uint256 roundId) external nonReentrant whenNotPaused onlyWhitelisted(msg.sender) {
    require(!dividendsClaimed[roundId][msg.sender], "Already claimed");

    DividendInfo storage dividend = dividendInfo[roundId];
    uint256 balance = balanceOfAt(msg.sender, dividend.snapshotId);
    require(balance > 0, "No tokens at snapshot");

    uint256 share = (balance * dividend.totalAmount) / dividend.totalSupplyAtSnapshot;
    require(share > 0, "No dividends to claim");

    dividendsClaimed[roundId][msg.sender] = true;
    _transfer(address(this), msg.sender, share);

    emit DividendsClaimed(roundId, msg.sender, share);
}

function reclaimUnclaimedDividends(uint256 roundId, address to) external onlyRole(ADMIN_ROLE) {
    require(block.timestamp > snapshotTimestamps[dividendInfo[roundId].snapshotId] + 365 days, "Too early to reclaim");
    require(to != address(0), "Invalid address");

    uint256 remaining = balanceOf(address(this));
    dividendInfo[roundId].reclaimedAmount = remaining;
    _transfer(address(this), to, remaining);

    emit DividendsReclaimed(roundId, remaining);
}

function releaseLockup(address investor) external onlyRole(ADMIN_ROLE) {
    _investors[investor].releaseTime = block.timestamp;
    emit LockupReleased(investor);
}

function toggleTestMode(bool status) external onlyRole(ADMIN_ROLE) {
    isTestMode = status;
    emit TestModeToggled(status);
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

function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {
    emit Upgraded(newImplementation);
}

function _isJurisdictionAllowed(string memory jurisdiction) internal view returns (bool) {
    bytes32 j = keccak256(abi.encodePacked(_normalizeString(jurisdiction)));
    return allowedJurisdictions[j];
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

function decimals() public pure override returns (uint8) {
    return TOKEN_DECIMALS;
}

function supportsInterface(bytes4 interfaceId) public view override(AccessControlUpgradeable) returns (bool) {
    return super.supportsInterface(interfaceId);
}

}

