// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Groth16Verifier.sol"; // zk-SNARK Verifier contract generated via Circom
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@thirdweb-dev/contracts/extension/Permissions.sol"; // Thirdweb extension for roles

/**
 * @title QuantumSpectra
 * @dev QuantumSpectra contract for processing zk-SNARK proof-backed transactions with batch rollup capabilities.
 * Includes role-based access, zk-SNARK proof verification, and verifier reward distribution.
 */
contract QuantumSpectra is ReentrancyGuard, Permissions {
    Groth16Verifier private verifier;

    uint256 public verifierRewardPool;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");

    /**
     * @dev Sets the Verifier contract address and assigns the ADMIN role to the deployer.
     * @param _verifier The address of the Verifier contract.
     */
    constructor(address _verifier) {
        require(_verifier != address(0), "Verifier address cannot be zero");
        verifier = Groth16Verifier(_verifier);
        _setupRole(ADMIN_ROLE, msg.sender); // Assign ADMIN_ROLE to the deployer
    }

    struct Proof {
        uint[2] a;
        uint[2][2] b;
        uint[2] c;
        uint256[33] input; 
    }

    struct Transaction {
        address sender;
        address recipient;
        uint amount;
        string encryptedMessage;
        string proofStatus;
        uint256 timestamp;
    }

    struct BatchTransaction {
        address verifier;
        uint totalTransactions;
        uint totalAmount;
        string proofStatus;
        uint256 timestamp;
    }

    mapping(address => Transaction[]) private transactions;
    mapping(address => BatchTransaction[]) private rollupTransactions;
    mapping(address => uint256) private nonces;

    event TransactionSent(
        address indexed sender,
        address indexed recipient,
        uint amount,
        string encryptedMessage,
        string proofStatus,
        uint256 timestamp
    );

    event BatchTransactionProcessed(
        address indexed verifier,
        uint totalTransactions,
        uint totalAmount,
        string proofStatus,
        uint256 timestamp
    );

    event VerifierRewardPaid(
        address indexed verifier,
        uint amount,
        uint256 timestamp
    );

    modifier proofValid(Proof memory proof) {
        require(verifyProof(proof), "Invalid zk-SNARK proof: verification failed.");
        _;
    }

    function verifyProof(Proof memory proof) public view onlyRole(ADMIN_ROLE) returns (bool) {
        return verifier.verifyProof(proof.a, proof.b, proof.c, proof.input);
    }

    function sendTransaction(
        address recipient,
        uint amount,
        string memory encryptedMessage,
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint256[33] memory input
    ) public nonReentrant proofValid(Proof(a, b, c, input)) {
        require(amount > 0, "Amount must be greater than zero.");

        nonces[msg.sender]++;
      
        transactions[msg.sender].push(Transaction(
            msg.sender,
            recipient,
            amount,
            encryptedMessage,
            "Valid zk-SNARK proof",
            block.timestamp
        ));

        emit TransactionSent(
            msg.sender,
            recipient,
            amount,
            encryptedMessage,
            "Valid zk-SNARK proof",
            block.timestamp
        );
    }

    function processBatchTransaction(
        address[] memory recipients,
        uint[] memory amounts,
        string[] memory encryptedMessages,
        Proof[] memory proofs
    ) public nonReentrant onlyRole(VERIFIER_ROLE) {
        require(recipients.length == amounts.length, "Mismatched arrays.");
        require(recipients.length == proofs.length, "Mismatched arrays.");

        uint totalAmount = 0;
        for (uint i = 0; i < recipients.length; i++) {
            require(amounts[i] > 0, "Amount must be greater than zero.");
            require(verifyProof(proofs[i]), "Invalid zk-SNARK proof.");

            totalAmount += amounts[i];
            emit TransactionSent(
                msg.sender,
                recipients[i],
                amounts[i],
                encryptedMessages[i],
                "Valid zk-SNARK proof",
                block.timestamp
            );
        }

        emit BatchTransactionProcessed(
            msg.sender,
            recipients.length,
            totalAmount,
            "Valid zk-SNARK proof",
            block.timestamp
        );

        payVerifierReward(msg.sender, totalAmount);
    }

    function getNonce(address user) public view onlyRole(ADMIN_ROLE) returns (uint256) {
        return nonces[user];
    }

    function getTransactions(address user) public view onlyRole(ADMIN_ROLE) returns (Transaction[] memory) {
        return transactions[user];
    }

    function getRollupTransactions(address verifierAddress) public view onlyRole(ADMIN_ROLE) returns (BatchTransaction[] memory) {
        return rollupTransactions[verifierAddress];
    }

    function payVerifierReward(address verifierAddress, uint totalAmount) internal onlyRole(ADMIN_ROLE) {
        uint reward = totalAmount / 100; // Verifier gets 1% of the total batch amount as reward
        require(verifierRewardPool >= reward, "Insufficient funds in reward pool.");

        verifierRewardPool -= reward;

        (bool success, ) = verifierAddress.call{value: reward}("");
        require(success, "Transfer failed.");

        emit VerifierRewardPaid(verifierAddress, reward, block.timestamp);
    }

    function fundRewardPool() public payable onlyRole(ADMIN_ROLE) {
        verifierRewardPool += msg.value;
    }

    function grantRole(bytes32 role, address account) public override onlyRole(ADMIN_ROLE) {
        super.grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public override onlyRole(ADMIN_ROLE) {
        super.revokeRole(role, account);
    }

    receive() external payable {
        revert("Contract does not accept Ether directly.");
    }

    fallback() external payable {
        revert("Contract does not accept Ether directly.");
    }
}
