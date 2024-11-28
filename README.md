# Clarity Insurance System

## Overview

This **Smart Insurance System** is a decentralized insurance platform that allows users to interact with an insurance pool to manage funds, purchase insurance policies, and make claims for payouts. Built on the Stacks blockchain using **Clarity 2.0**, this contract ensures transparency, security, and decentralized control. It provides a robust mechanism for users to participate in a communal insurance pool with customizable policies and transparent fund management.

---

## Key Features

### 🔒 Core Functionalities
- Add funding to a shared insurance pool.
- Purchase customizable insurance policies.
- Claim payouts for valid insurance policies.
- Dynamic fund allocation and management.
- Comprehensive error handling and safety measures.

### 🛡️ Key Capabilities
- **Insurance Premium Management**: Set and adjust insurance premiums.
- **User-Specific Funding Limits**: Control how much a user can fund into the insurance pool.
- **Policy Purchase and Management**: Users can purchase insurance policies and manage them.
- **Claim Processing**: Payout claims based on the user's insurance policy.
- **Fund Allocation Tracking**: Track total pool balance and individual user contributions.

---

## Components

### Constants

- **Contract Owner**: Only the contract owner can update key parameters like the premium rate and funding limits.
- **Error Codes**: A variety of error codes are defined to handle scenarios like insufficient balance, invalid premium, or funding limits being exceeded.

### Data Variables

- **Insurance Premium Rate**: Default rate for insurance premiums.
- **Maximum Fund Limit**: The maximum amount that can be held in the insurance pool.
- **Current Insurance Pool Balance**: The total balance available in the insurance pool.
- **User Funding Limits**: The maximum contribution limit for each user to the insurance pool.

### Data Maps

- **User Funding Balance**: Tracks how much each user has contributed to the insurance pool.
- **User Insurance Balance**: Tracks the amount of coverage each user has purchased.
- **Insurance Policies**: Stores details about each user's insurance policy, including insured amount, premium rate, and policy status.

---

## Contract Architecture

### Technical Specifications

#### Permissions
- **Contract Owner**: 
  - Adjust insurance premiums.
  - Set global fund limits.
  - Manage contract parameters.

- **Users**: 
  - Add funds to the pool.
  - Purchase insurance policies.
  - Submit claims within defined limits.

#### Error Handling
The contract implements comprehensive error management with specific error codes:
- **`err-owner-only`**: Prevents unauthorized access.
- **`err-not-enough-balance`**: Ensures the user has sufficient balance to perform actions.
- **`err-transfer-failed`**: Manages fund transfer issues.
- **`err-invalid-amount`**: Validates input amounts.
- **`err-fund-limit-exceeded`**: Prevents exceeding funding limits.

---

## Contract Functions

### Public Functions
These are the main functions that users and the contract owner can invoke:
- **`set-insurance-premium (new-premium uint)`**: Allows the owner to update the insurance premium rate.
- **`set-max-funding-limit (new-limit uint)`**: Allows the owner to set a new maximum funding limit per user.
- **`add-funding (amount uint)`**: Allows users to add funds to the insurance pool, subject to their maximum limit.
- **`purchase-insurance (amount uint, premium uint)`**: Allows users to purchase an insurance policy with a specified amount and premium rate.
- **`payout-insurance (user principal, amount uint)`**: Allows users to claim payouts on their insurance policies if conditions are met.

### Private Functions
These functions are internal and used to manage data:
- **`calculate-payout (amount uint)`**: Calculates the payout amount for a claim based on the user's insurance policy.
- **`update-insurance-fund (amount int)`**: Updates the insurance pool balance by adding or subtracting funds, ensuring the balance does not exceed the maximum fund limit.

### Read-Only Functions
These functions provide insights into the current state of the contract:
- **`get-insurance-premium`**: Returns the current insurance premium rate.
- **`get-funding-balance (user principal)`**: Returns the funding balance of a user.
- **`get-insurance-balance (user principal)`**: Returns the insurance balance of a user.
- **`get-insurance-fund`**: Returns the current balance of the insurance pool.
- **`get-max-funding-per-user`**: Returns the maximum funding allowed per user.
- **`get-contract-owner`**: Returns the contract owner's address.
- **`has-active-policy? (user principal)`**: Checks if a user has an active insurance policy.

---

## Security Considerations

- **Strict Access Controls**: Only the contract owner can modify key parameters like the premium rate and funding limits.
- **Fund Limit Mechanisms**: Users cannot fund the pool beyond their allowed limit, ensuring fair participation.
- **Granular Error Handling**: The contract is designed to handle various error conditions, preventing invalid actions.
- **Prevent Unauthorized Manipulations**: The contract prevents users from altering other users’ balances or claiming payouts without valid policies.

---

## Limitations

- **Single Contract Owner Model**: The contract follows a single-owner structure, meaning that only one address has the ability to manage key parameters.
- **Fixed Premium Calculation**: Premiums are set statically by the owner and do not adjust dynamically.
- **No Advanced Claim Verification**: Currently, claims are processed based on predefined conditions, without integrating external verification mechanisms.

---

## Potential Improvements

- **Multi-Signature Ownership**: Introduce a multi-signature model for contract ownership, allowing more than one entity to control key parameters.
- **Dynamic Premium Calculation**: Implement logic to dynamically adjust premiums based on external factors or the pool’s health.
- **Advanced Claim Verification**: Integrate external oracles to verify claims and ensure payouts are based on real-world events.
- **Enhanced Policy Customization**: Enable users to customize insurance policies beyond basic parameters like insured amount and premium rate.

---

## Deployment Requirements

### Prerequisites
- **Stacks Blockchain**: A decentralized platform built for smart contracts and dApps.
- **Clarinet Development Environment**: A toolset for building, testing, and deploying Clarity smart contracts.
- **Stacks Wallet with STX Tokens**: A wallet to interact with the Stacks blockchain.

### Installation
1. Clone the repository.
2. Install Clarinet.
3. Configure your development environment.
4. Deploy the smart contract.

---

## Usage Examples

### Adding Funds
```clarity
(add-funding u1000)  ;; Add 1000 STX to the insurance pool
```

### Purchasing Insurance
```clarity
(purchase-insurance u500 u50)  ;; Purchase policy with 500 STX, 50% premium
```

### Claiming Insurance
```clarity
(payout-insurance tx-sender u300)  ;; Process a 300 STX insurance claim
```

---

## Contributing
1. Fork the repository.
2. Create your feature branch.
3. Commit your changes.
4. Push to the branch.
5. Create a new Pull Request.

---

## Support
For issues, questions, or contributions, please open a GitHub issue or contact the maintainers.
```

### Changes made:
1. **Overview**: Combined details about the use of **Clarity 2.0** and added reference to communal insurance pools.
2. **Key Features**: Enhanced clarity of core functionalities like dynamic fund allocation and customizable policies.
3. **Contract Architecture**: Emphasized the use of data maps and constants.
4. **Security Considerations**: Highlighted granular error handling and preventing unauthorized manipulations.
5. **Limitations**: Added a more detailed explanation of contract restrictions.
6. **Potential Improvements**: Suggested improvements like multi-signature ownership and dynamic premium calculation.
7. **Deployment Requirements**: Kept the details for installation and prerequisites.
