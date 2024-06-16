# SmartContractWallet

## Overview

SmartContractWallet is a Solidity-based smart contract that allows the owner to manage funds, set allowances, and control transactions. Additionally, the contract includes a mechanism for guardians to propose a new owner, which can be approved or rejected by other guardians, ensuring secure and reliable ownership changes.

## Features

-    **Owner Management**: Allows the current owner to manage funds, set allowances, and deny sending permissions.
-    **Guardian Mechanism**: Guardians can propose a new owner and approve or reject the proposed owner.
-    **Allowance Control**: The owner can set and manage allowances for different addresses.
-    **Event Emission**: Emits events for critical actions such as proposing a new owner, changing ownership, setting allowances, denying sending, and making transfers.

## Functions

### Owner and Guardian Functions

-    **proposeNewOwner(address payable newOwner)**: Guardians can propose a new owner.
-    **approveNewOwner()**: Guardians can approve the proposed new owner.
-    **rejectNewOwner()**: Guardians can reject the proposed new owner.
-    **addGuardian(address \_guardian)**: The owner can add a new guardian.
-    **removeGuardian(address \_guardian)**: The owner can remove an existing guardian.
-    **getGuardians()**: Returns the list of current guardians.

### Allowance Functions

-    **setAllowance(address \_from, uint \_amount)**: The owner can set the allowance for an address.
-    **denySending(address \_from)**: The owner can deny sending permissions for an address.

### Transaction Functions

-    **transfer(address payable \_to, uint \_amount, bytes calldata payload)**: Transfers funds from the contract to the specified address with additional data payload.

### Events

-    **OwnerProposed(address indexed newOwner)**: Emitted when a new owner is proposed.
-    **OwnerChanged(address indexed oldOwner, address indexed newOwner)**: Emitted when the owner changes.
-    **AllowanceSet(address indexed \_from, uint \_amount)**: Emitted when an allowance is set.
-    **SendingDenied(address indexed \_from)**: Emitted when sending is denied.
-    **TransferMade(address indexed \_to, uint \_amount)**: Emitted when a transfer is made.
-    **GuardianAdded(address indexed guardian)**: Emitted when a guardian is added.
-    **GuardianRemoved(address indexed guardian)**: Emitted when a guardian is removed.
-    **OwnerApproved(address indexed guardian, address indexed proposedOwner)**: Emitted when a guardian approves a proposed owner.
-    **OwnerRejected(address indexed guardian, address indexed proposedOwner)**: Emitted when a guardian rejects a proposed owner.

## Installation

To compile and deploy the SmartContractWallet, you will need the following:

-    Node.js
-    npm (Node Package Manager)
-    Hardhat (for testing and deploying smart contracts)
-    A Solidity-compatible wallet (e.g., MetaMask)

### Steps

1. Clone the repository:

     ```sh
     git clone https://github.com/ChainTrek/smart-wallet-contract
     cd smart-wallet-contract
     ```

2. Install dependencies:

     ```sh
     npm install
     ```

3. Compile the smart contract:

     ```sh
     npx hardhat compile
     ```

4. Deploy the smart contract:
     ```sh
     npx hardhat run scripts/deploy.js --network <network-name>
     ```

## Testing

To run the unit tests for the SmartContractWallet:

1. Compile the contract:

     ```sh
     npx hardhat compile
     ```

2. Run the tests:
     ```sh
     npx hardhat test
     ```

## Contributing

We welcome contributions to enhance the functionality and security of the SmartContractWallet. Please fork the repository and submit a pull request for review.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
