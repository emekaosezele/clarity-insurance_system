;; Smart Insurance Contract - `smart-insurance.clar`
;;
;; This contract implements a decentralized insurance platform, allowing users to:
;; 1. Add funding to an insurance pool.
;; 2. Purchase customizable insurance policies.
;; 3. Claim payouts for valid insurance policies based on predefined conditions.
;;
;; Key Features:
;; - **Insurance Premium Management**: Allows the contract owner to set and update the insurance premium rate.
;; - **User-Specific Limits**: Enforces maximum funding and insurance limits per user.
;; - **Dynamic Fund Allocation**: Tracks the insurance pool's balance and adjusts based on user interactions.
;; - **Policy Management**: Enables users to purchase policies with specific amounts and premiums, stored securely in the contract.
;; - **Claim Processing**: Facilitates payouts for valid insurance claims, ensuring sufficient funds in the pool.
;;
;; Key Components:
;; - **Constants**: Predefined error codes and roles (e.g., contract owner).
;; - **Data Variables**: Manage global settings (e.g., fund limits, premium rate, pool balance).
;; - **Data Maps**: Track user-specific balances and insurance policy details.
;; - **Functions**:
;;   - Public: Manage funds, purchase policies, process claims, and update contract settings.
;;   - Private: Calculate payouts and update the fund balance.
;;   - Read-Only: Provide insights into contract state (e.g., premiums, balances, limits).
;;
;; Permissions:
;; - Only the contract owner can adjust key parameters (e.g., insurance premiums, fund limits).
;; - Users interact with their own balances and policies, ensuring decentralization and fairness.
;;
;; Safety Measures:
;; - Comprehensive error handling for invalid inputs and unauthorized actions.
;; - Fund limit enforcement to prevent over-allocation or underfunding of the pool.

;; ================================
;; CONSTANTS
;; ================================
;; Defines key constants for ownership, errors, and validation

(define-constant contract-owner tx-sender) ;; Contract owner
(define-constant err-owner-only (err u100)) ;; Error: Action restricted to owner
(define-constant err-not-enough-balance (err u101)) ;; Error: Insufficient balance
(define-constant err-transfer-failed (err u102)) ;; Error: Fund transfer failed
(define-constant err-invalid-amount (err u103)) ;; Error: Invalid amount provided
(define-constant err-invalid-insurance-price (err u104)) ;; Error: Invalid insurance price
(define-constant err-fund-limit-exceeded (err u105)) ;; Error: Funding limit exceeded
(define-constant err-insurance-not-available (err u106)) ;; Error: Insurance not available
(define-constant err-invalid-premium (err u107)) ;; Error: Invalid premium value
(define-constant err-insurance-payout-failed (err u108)) ;; Error: Insurance payout failed

;; ================================
;; DATA VARIABLES
;; ================================
;; Defines variables to manage insurance configurations and balances

(define-data-var insurance-premium uint u500) ;; Default premium percentage (5%)
(define-data-var fund-limit uint u1000000) ;; Maximum funding limit for insurance pool
(define-data-var insurance-fund uint u0) ;; Current insurance pool balance
(define-data-var max-funding-per-user uint u10000) ;; Max funding allowed per user

;; ================================
;; DATA MAPS
;; ================================
;; Maps to manage user balances and policies

(define-map user-funding-balance principal uint) ;; User's funding balance (STX)
(define-map user-insurance-balance principal uint) ;; User's insurance balance (STX)
(define-map insurance-policies 
  {user: principal} 
  {amount: uint, price: uint, is-active: bool}) ;; Insurance policy details

;; ================================
;; PRIVATE FUNCTIONS
;; ================================

;; Calculate insurance payout based on the amount and premium
(define-private (calculate-payout (amount uint))
  (/ (* amount (var-get insurance-premium)) u100))

;; Update the insurance fund with specified amount
(define-private (update-insurance-fund (amount int))
  (let (
    (current-fund (var-get insurance-fund))
    (new-fund (if (< amount 0)
                 (if (>= current-fund (to-uint (- 0 amount)))
                     (- current-fund (to-uint (- 0 amount)))
                     u0)
                 (+ current-fund (to-uint amount))))
  )
    (asserts! (<= new-fund (var-get fund-limit)) err-fund-limit-exceeded)
    (var-set insurance-fund new-fund)
    (ok true)))

;; ================================
;; PUBLIC FUNCTIONS
;; ================================

;; Set a new insurance premium (Owner only)
(define-public (set-insurance-premium (new-premium uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> new-premium u0) err-invalid-insurance-price)
    (var-set insurance-premium new-premium)
    (ok true)))

;; Update the maximum funding limit per user (Owner only)
(define-public (set-max-funding-limit (new-limit uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> new-limit u0) err-invalid-amount)
    (var-set max-funding-per-user new-limit)
    (ok true)))

;; Add funds to the insurance pool from the user
(define-public (add-funding (amount uint))
  (let (
    (current-balance (default-to u0 (map-get? user-funding-balance tx-sender)))
    (new-balance (+ current-balance amount))
  )
    (asserts! (<= new-balance (var-get max-funding-per-user)) err-fund-limit-exceeded)
    (map-set user-funding-balance tx-sender new-balance)
    (try! (update-insurance-fund (to-int amount)))
    (ok true)))

;; Purchase an insurance policy
(define-public (purchase-insurance (amount uint) (premium uint))
  (let (
    (funding-balance (default-to u0 (map-get? user-funding-balance tx-sender)))
    (new-insurance-balance (+ (default-to u0 (map-get? user-insurance-balance tx-sender)) amount))
  )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= funding-balance amount) err-not-enough-balance)
    (asserts! (<= premium (var-get insurance-premium)) err-invalid-premium)

    ;; Deduct funding and add to insurance
    (map-set user-funding-balance tx-sender (- funding-balance amount))
    (map-set user-insurance-balance tx-sender new-insurance-balance)

    ;; Store insurance policy details
    (map-set insurance-policies {user: tx-sender} {amount: amount, price: premium, is-active: true})

    (ok true)))

;; Payout an insurance claim for a user
(define-public (payout-insurance (user principal) (amount uint))
  (let (
    (user-insurance (default-to {amount: u0, price: u0, is-active: false} (map-get? insurance-policies {user: user})))
    (payout-amount (calculate-payout amount))
    (insurance-fund-balance (var-get insurance-fund))
  )
    (asserts! (get is-active user-insurance) err-insurance-not-available)
    (asserts! (>= insurance-fund-balance payout-amount) err-insurance-payout-failed)

    ;; Update insurance fund and user's balance
    (let (
      (current-insurance-balance (default-to u0 (map-get? user-insurance-balance user)))
      (new-insurance-balance (- current-insurance-balance payout-amount))
    )
      (asserts! (>= current-insurance-balance payout-amount) err-insurance-payout-failed)
      (map-set user-insurance-balance user new-insurance-balance)
    )
    (var-set insurance-fund (- insurance-fund-balance payout-amount))
    (ok true)))

;; ================================
;; READ-ONLY FUNCTIONS
;; ================================

;; Get the current insurance premium
(define-read-only (get-insurance-premium)
  (ok (var-get insurance-premium)))

;; Get the funding balance of a user
(define-read-only (get-funding-balance (user principal))
  (ok (default-to u0 (map-get? user-funding-balance user))))

;; Get the insurance balance of a user
(define-read-only (get-insurance-balance (user principal))
  (ok (default-to u0 (map-get? user-insurance-balance user))))

;; Get the current insurance fund balance
(define-read-only (get-insurance-fund)
  (ok (var-get insurance-fund)))

;; Get the maximum funding allowed per user
(define-read-only (get-max-funding-per-user)
  (ok (var-get max-funding-per-user)))

;; Get the overall funding limit of the insurance pool
(define-read-only (get-fund-limit)
  (ok (var-get fund-limit)))
