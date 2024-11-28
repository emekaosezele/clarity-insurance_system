;; Smart Insurance Contract
;;
;; Core features:
;; - Add funding to insurance pool
;; - Purchase insurance policies
;; - Process insurance claims

;; ================================
;; CONSTANTS
;; ================================
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-enough-balance (err u101))
(define-constant err-invalid-amount (err u103))

;; ================================
;; DATA VARIABLES
;; ================================
(define-data-var insurance-premium uint u500)
(define-data-var insurance-fund uint u0)
(define-data-var max-funding-per-user uint u10000)

;; ================================
;; DATA MAPS
;; ================================
(define-map user-funding-balance principal uint)
(define-map insurance-policies 
  {user: principal} 
  {amount: uint, is-active: bool})

;; ================================
;; PRIVATE FUNCTIONS
;; ================================
(define-private (calculate-payout (amount uint))
  (/ (* amount (var-get insurance-premium)) u100))

;; ================================
;; PUBLIC FUNCTIONS
;; ================================
(define-public (add-funding (amount uint))
  (let (
    (current-balance (default-to u0 (map-get? user-funding-balance tx-sender)))
    (new-balance (+ current-balance amount))
  )
    (asserts! (<= new-balance (var-get max-funding-per-user)) (err u105))
    (map-set user-funding-balance tx-sender new-balance)
    (var-set insurance-fund (+ (var-get insurance-fund) amount))
    (ok true)))

(define-public (purchase-insurance (amount uint))
  (let (
    (funding-balance (default-to u0 (map-get? user-funding-balance tx-sender)))
  )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= funding-balance amount) err-not-enough-balance)

    (map-set user-funding-balance tx-sender (- funding-balance amount))
    (map-set insurance-policies {user: tx-sender} {amount: amount, is-active: true})
    (ok true)))

;; ================================
;; READ-ONLY FUNCTIONS
;; ================================
(define-read-only (get-funding-balance (user principal))
  (ok (default-to u0 (map-get? user-funding-balance user))))

(define-read-only (get-insurance-fund)
  (ok (var-get insurance-fund)))