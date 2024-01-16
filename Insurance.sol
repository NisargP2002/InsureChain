// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InsurancePlatform {
    address public owner;
    uint256 public premiumAmount;
    uint256 public coverageAmount;
    uint256 public policyDuration;
    mapping(address => uint256) public policyHolders;
    mapping(address => bool) public hasClaimed;

    event PolicyPurchased(address indexed buyer, uint256 amount, uint256 expiration);
    event ClaimFiled(address indexed claimant, uint256 amount);
    event TransferToPolicyHolder(address indexed policyHolder, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyPolicyHolder() {
        require(policyHolders[msg.sender] > 0, "Only policyholder can call this function");
        _;
    }

    modifier hasNotClaimed() {
        require(!hasClaimed[msg.sender], "Claim already filed");
        _;
    }

    constructor(
        uint256 _premiumAmount,
        uint256 _coverageAmount,
        uint256 _policyDurationDays
    ) {
        owner = msg.sender;
        premiumAmount = _premiumAmount;
        coverageAmount = _coverageAmount;
        policyDuration = _policyDurationDays * 1 minutes;
    }

    receive() external payable {
        // This function is called when Ether is sent directly to the contract
        // It transfers the received Ether to the owner and deducts it from the owner's balance
        payable(owner).transfer(msg.value);
    }

    function purchasePolicy() external payable {
        require(msg.value == premiumAmount * 1 ether, "Incorrect premium amount sent");
        require(policyHolders[msg.sender] == 0, "Policy already purchased");

        // Transfer the premium amount in Ether to the owner
        payable(owner).transfer(msg.value);

        uint256 expirationTimestamp = block.timestamp + policyDuration;
        policyHolders[msg.sender] = expirationTimestamp;

        emit PolicyPurchased(msg.sender, msg.value, expirationTimestamp);
    }

    function transferToPolicyHolder(address policyHolder) external onlyOwner payable {
        require(policyHolders[policyHolder] > 0, "Invalid policyholder address");

        // Deduct the coverageAmount in Ether from the owner's external wallet
        // require(owner.balance >= coverageAmount * 1 ether, "Insufficient funds in owner's wallet");

        // Transfer the coverageAmount in Ether to the policyholder
        payable(policyHolder).transfer(2 ether);

        emit TransferToPolicyHolder(policyHolder, 2 ether);
    }

}
