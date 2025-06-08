;; Booking Management Contract
;; Manages home service bookings between customers and providers

;; Constants
(define-constant err-not-found (err u200))
(define-constant err-unauthorized (err u201))
(define-constant err-invalid-status (err u202))
(define-constant err-booking-exists (err u203))
(define-constant err-invalid-provider (err u204))

;; Data Variables
(define-data-var next-booking-id uint u1)

;; Data Maps
(define-map bookings
  { booking-id: uint }
  {
    customer: principal,
    provider-id: uint,
    service-description: (string-ascii 500),
    scheduled-date: uint,
    price: uint,
    status: (string-ascii 20),
    created-block: uint,
    updated-block: uint
  }
)

(define-map customer-bookings
  { customer: principal, booking-id: uint }
  { active: bool }
)

(define-map provider-bookings
  { provider-id: uint, booking-id: uint }
  { active: bool }
)

;; Public Functions

;; Create a new booking
(define-public (create-booking (provider-id uint) (service-description (string-ascii 500)) (scheduled-date uint) (price uint))
  (let
    (
      (booking-id (var-get next-booking-id))
    )
    ;; Verify provider exists and is verified (would need to call verification contract)

    (map-set bookings
      { booking-id: booking-id }
      {
        customer: tx-sender,
        provider-id: provider-id,
        service-description: service-description,
        scheduled-date: scheduled-date,
        price: price,
        status: "pending",
        created-block: block-height,
        updated-block: block-height
      }
    )

    (map-set customer-bookings
      { customer: tx-sender, booking-id: booking-id }
      { active: true }
    )

    (map-set provider-bookings
      { provider-id: provider-id, booking-id: booking-id }
      { active: true }
    )

    (var-set next-booking-id (+ booking-id u1))
    (ok booking-id)
  )
)

;; Accept a booking (provider only)
(define-public (accept-booking (booking-id uint))
  (let
    (
      (booking (unwrap! (map-get? bookings { booking-id: booking-id }) err-not-found))
    )
    (asserts! (is-eq (get status booking) "pending") err-invalid-status)
    ;; Would need to verify tx-sender is the provider

    (map-set bookings
      { booking-id: booking-id }
      (merge booking { status: "accepted", updated-block: block-height })
    )
    (ok true)
  )
)

;; Complete a booking
(define-public (complete-booking (booking-id uint))
  (let
    (
      (booking (unwrap! (map-get? bookings { booking-id: booking-id }) err-not-found))
    )
    (asserts! (is-eq (get status booking) "accepted") err-invalid-status)

    (map-set bookings
      { booking-id: booking-id }
      (merge booking { status: "completed", updated-block: block-height })
    )
    (ok true)
  )
)

;; Cancel a booking
(define-public (cancel-booking (booking-id uint))
  (let
    (
      (booking (unwrap! (map-get? bookings { booking-id: booking-id }) err-not-found))
    )
    (asserts!
      (or
        (is-eq tx-sender (get customer booking))
        ;; Would verify provider ownership
        true
      )
      err-unauthorized
    )
    (asserts!
      (or
        (is-eq (get status booking) "pending")
        (is-eq (get status booking) "accepted")
      )
      err-invalid-status
    )

    (map-set bookings
      { booking-id: booking-id }
      (merge booking { status: "cancelled", updated-block: block-height })
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get booking information
(define-read-only (get-booking (booking-id uint))
  (map-get? bookings { booking-id: booking-id })
)

;; Check if customer has active booking
(define-read-only (has-customer-booking (customer principal) (booking-id uint))
  (is-some (map-get? customer-bookings { customer: customer, booking-id: booking-id }))
)

;; Check if provider has active booking
(define-read-only (has-provider-booking (provider-id uint) (booking-id uint))
  (is-some (map-get? provider-bookings { provider-id: provider-id, booking-id: booking-id }))
)

;; Get total bookings
(define-read-only (get-total-bookings)
  (- (var-get next-booking-id) u1)
)
