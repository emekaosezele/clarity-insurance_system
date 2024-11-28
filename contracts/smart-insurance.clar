;; Smart Insurance Contract
;;
;; Enhanced features:
;; - Configurable insurance premium
;; - User-specific funding and insurance limits
;; - Detailed policy and fund management

;; ================================
;; CONSTANTS
;; ================================
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-enough-balance (err u101))
(define-constant err-invalid-amount (err u103))
(define-constant err-fund-limit-exceeded (err u105))
(define-constant err-insurance-not-available (err u106))

;; ================================
;; DATA VARIABLES
;; ================================
(define-data-var insurance-premium uint u500) ;; Default 5% premium
(define-data-var fund-limit uint u500000) ;; Moderate pool limit
(define-data-var insurance-fund uint u0)
(define-data-var max-funding-per-user uint u10000)

;; ================================
;; DATA MAPS
;; ================================
(define-map user-funding-balance principal uint)
(define-map user-insurance-balance principal uint)
(define-map insurance-policies 
  {user: principal} 
  {amount: uint, price: uint, is-active: bool})

;; ================================
;; PRIVATE FUNCTIONS
;; ================================
(define-private (calculate-payout (amount uint))
  (/ (* amount (var-get insurance-premium)) u100))

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
(define-public (set-insurance-premium (new-premium uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> new-premium u0) (err u104))
    (var-set insurance-premium new-premium)
    (ok true)))

(define-public (add-funding (amount uint))
  (let (
    (current-balance (default-to u0 (map-get? user-funding-balance tx-sender)))
    (new-balance (+ current-balance amount))
  )
    (asserts! (<= new-balance (var-get max-funding-per-user)) err-fund-limit-exceeded)
    (map-set user-funding-balance tx-sender new-balance)
    (try! (update-insurance-fund (to-int amount)))
    (ok true)))

(define-public (purchase-insurance (amount uint) (premium uint))
  (let (
    (funding-balance (default-to u0 (map-get? user-funding-balance tx-sender)))
    (new-insurance-balance (+ (default-to u0 (map-get? user-insurance-balance tx-sender)) amount))
  )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= funding-balance amount) err-not-enough-balance)
    (asserts! (<= premium (var-get insurance-premium)) (err u107))

    (map-set user-funding-balance tx-sender (- funding-balance amount))
    (map-set user-insurance-balance tx-sender new-insurance-balance)
    (map-set insurance-policies {user: tx-sender} {amount: amount, price: premium, is-active: true})
    (ok true)))

(define-public (payout-insurance (user principal) (amount uint))
  (let (
    (user-insurance (default-to {amount: u0, price: u0, is-active: false} (map-get? insurance-policies {user: user})))
    (payout-amount (calculate-payout amount))
    (insurance-fund-balance (var-get insurance-fund))
  )
    (asserts! (get is-active user-insurance) err-insurance-not-available)
    (asserts! (>= insurance-fund-balance payout-amount) (err u108))

    (let (
      (current-insurance-balance (default-to u0 (map-get? user-insurance-balance user)))
      (new-insurance-balance (- current-insurance-balance payout-amount))
    )
      (asserts! (>= current-insurance-balance payout-amount) (err u108))
      (map-set user-insurance-balance user new-insurance-balance)
    )
    (var-set insurance-fund (- insurance-fund-balance payout-amount))
    (ok true)))

;; ================================
;; READ-ONLY FUNCTIONS
;; ================================
(define-read-only (get-insurance-premium)
  (ok (var-get insurance-premium)))

(define-read-only (get-funding-balance (user principal))
  (ok (default-to u0 (map-get? user-funding-balance user))))

(define-read-only (get-insurance-balance (user principal))
  (ok (default-to u0 (map-get? user-insurance-balance user))))

(define-read-only (get-insurance-fund)
  (ok (var-get insurance-fund)))