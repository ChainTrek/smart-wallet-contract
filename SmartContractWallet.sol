// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

/// @title SmartContractWallet
/// @notice This contract allows the owner to manage funds and guardians to propose a new owner
contract SmartContractWallet {
    address payable public owner;
    address payable public proposedOwner;

    mapping(address => uint) public allowance;
    mapping(address => bool) public isAllowedToSend;
    mapping(address => bool) public guardians;
    address[] public guardiansList;

    uint public guardiansResetCount;
    uint public constant confirmationsFromGuardiansForReset = 3;
    uint public approvalCount;
    uint public rejectionCount;

    mapping(address => bool) public hasApproved;
    mapping(address => bool) public hasRejected;

    /// @notice Emitted when a new owner is proposed
    /// @param newOwner The address of the proposed new owner
    event OwnerProposed(address indexed newOwner);

    /// @notice Emitted when the owner changes
    /// @param oldOwner The address of the old owner
    /// @param newOwner The address of the new owner
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    /// @notice Emitted when allowance is set
    /// @param _from The address for which the allowance is set
    /// @param _amount The amount of allowance
    event AllowanceSet(address indexed _from, uint _amount);

    /// @notice Emitted when sending is denied
    /// @param _from The address for which sending is denied
    event SendingDenied(address indexed _from);

    /// @notice Emitted when a transfer is made
    /// @param _to The address to which the amount is transferred
    /// @param _amount The amount transferred
    event TransferMade(address indexed _to, uint _amount);

    /// @notice Emitted when a guardian is added
    /// @param guardian The address of the added guardian
    event GuardianAdded(address indexed guardian);

    /// @notice Emitted when a guardian is removed
    /// @param guardian The address of the removed guardian
    event GuardianRemoved(address indexed guardian);

    /// @notice Emitted when a guardian approves a proposed owner
    /// @param guardian The address of the guardian
    event OwnerApproved(address indexed guardian, address indexed proposedOwner);

    /// @notice Emitted when a guardian rejects a proposed owner
    /// @param guardian The address of the guardian
    event OwnerRejected(address indexed guardian, address indexed proposedOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner, aborting");
        _;
    }

    modifier onlyGuardian() {
        require(guardians[msg.sender], "You are not a guardian, aborting");
        _;
    }

    constructor() {
        owner = payable(msg.sender);
    }

    /// @notice Propose a new owner
    /// @param newOwner The address of the proposed new owner
    function proposeNewOwner(address payable newOwner) external onlyGuardian {
        if (proposedOwner != newOwner) {
            proposedOwner = newOwner;
            guardiansResetCount = 0;
            approvalCount = 0;
            rejectionCount = 0;

            // Reset approvals and rejections
            for (uint i = 0; i < guardiansList.length; i++) {
                hasApproved[guardiansList[i]] = false;
                hasRejected[guardiansList[i]] = false;
            }
        }

        guardiansResetCount++;

        emit OwnerProposed(newOwner);

        if (guardiansResetCount >= confirmationsFromGuardiansForReset) {
            address payable oldOwner = owner;
            owner = proposedOwner;
            proposedOwner = payable(address(0));

            emit OwnerChanged(oldOwner, owner);
        }
    }

    /// @notice Approve the proposed owner
    function approveNewOwner() external onlyGuardian {
        require(proposedOwner != address(0), "No proposed owner to approve");
        require(!hasApproved[msg.sender], "Guardian has already approved");

        hasApproved[msg.sender] = true;
        approvalCount++;

        emit OwnerApproved(msg.sender, proposedOwner);

        if (approvalCount > guardiansList.length / 2) {
            address payable oldOwner = owner;
            owner = proposedOwner;
            proposedOwner = payable(address(0));

            emit OwnerChanged(oldOwner, owner);
        }
    }

    /// @notice Reject the proposed owner
    function rejectNewOwner() external onlyGuardian {
        require(proposedOwner != address(0), "No proposed owner to reject");
        require(!hasRejected[msg.sender], "Guardian has already rejected");

        hasRejected[msg.sender] = true;
        rejectionCount++;

        emit OwnerRejected(msg.sender, proposedOwner);

        if (rejectionCount > guardiansList.length / 2) {
            proposedOwner = payable(address(0));
            guardiansResetCount = 0;
            approvalCount = 0;
            rejectionCount = 0;

            // Reset approvals and rejections
            for (uint i = 0; i < guardiansList.length; i++) {
                hasApproved[guardiansList[i]] = false;
                hasRejected[guardiansList[i]] = false;
            }
        }
    }

    /// @notice Set allowance for an address
    /// @param _from The address for which the allowance is set
    /// @param _amount The amount of allowance
    function setAllowance(address _from, uint _amount) external onlyOwner {
        allowance[_from] = _amount;
        isAllowedToSend[_from] = true;

        emit AllowanceSet(_from, _amount);
    }

    /// @notice Deny sending for an address
    /// @param _from The address for which sending is denied
    function denySending(address _from) external onlyOwner {
        isAllowedToSend[_from] = false;

        emit SendingDenied(_from);
    }

    /// @notice Add a new guardian
    /// @param _guardian The address to be added as a guardian
    function addGuardian(address _guardian) external onlyOwner {
        require(!guardians[_guardian], "Address is already a guardian");
        guardians[_guardian] = true;
        guardiansList.push(_guardian);

        emit GuardianAdded(_guardian);
    }

    /// @notice Remove an existing guardian
    /// @param _guardian The address to be removed from the guardians
    function removeGuardian(address _guardian) external onlyOwner {
        require(guardians[_guardian], "Address is not a guardian");
        guardians[_guardian] = false;

        for (uint i = 0; i < guardiansList.length; i++) {
            if (guardiansList[i] == _guardian) {
                guardiansList[i] = guardiansList[guardiansList.length - 1];
                guardiansList.pop();
                break;
            }
        }

        emit GuardianRemoved(_guardian);
    }

    /// @notice Get the list of current guardians
    /// @return The list of current guardians
    function getGuardians() external view returns (address[] memory) {
        return guardiansList;
    }

    /// @notice Transfer funds from the contract
    /// @param _to The address to which the amount is transferred
    /// @param _amount The amount transferred
    /// @param payload Additional data for the transfer
    /// @return The data returned from the transfer call
    function transfer(address payable _to, uint _amount, bytes calldata payload) external returns (bytes memory) {
        require(_amount <= address(this).balance, "Can't send more than the contract owns, aborting");

        if (msg.sender != owner) {
            require(isAllowedToSend[msg.sender], "You are not allowed to send any transactions, aborting");
            require(allowance[msg.sender] >= _amount, "You are trying to send more than you are allowed, aborting");
            allowance[msg.sender] -= _amount;
        }

        (bool success, bytes memory returnData) = _to.call{value: _amount}(payload);
        require(success, "Transaction failed, aborting");

        emit TransferMade(_to, _amount);

        return returnData;
    }

    receive() external payable {}
}
