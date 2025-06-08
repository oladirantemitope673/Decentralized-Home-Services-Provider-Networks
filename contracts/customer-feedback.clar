;; Customer Feedback Contract
;; Collects and manages customer reviews and ratings

;; Constants
(define-constant err-not-found (err u500))
(define-constant err-unauthorized (err u501))
(define-constant err-already-reviewed (err u502))
(define-constant err-invalid-rating (err u503))
(define-constant err-booking-not-completed (err u504))

;; Data Variables
(define-data-var next-review-id uint u1)

;; Data Maps
(define-map reviews
  { review-id: uint }
  {
    booking-id: uint,
    customer: principal,
    provider-id: uint,
    rating: uint,
    title: (string-ascii 100),
    content: (string-ascii 1000),
    helpful-votes: uint,
    created-block: uint,
    verified: bool
  }
)

(define-map booking-reviews
  { booking-id: uint }
  { review-id: uint }
)

(define-map provider-reviews
  { provider-id: uint, review-id: uint }
  { active: bool }
)

(define-map review-votes
  { review-id: uint, voter: principal }
  { helpful: bool }
)

(define-map provider-reputation
  { provider-id: uint }
  {
    total-reviews: uint,
    total-rating: uint,
    average-rating: uint,
    reputation-score: uint,
    last-updated: uint
  }
)

;; Public Functions

;; Submit a review for completed service
(define-public (submit-review (booking-id uint) (provider-id uint) (rating uint) (title (string-ascii 100)) (content (string-ascii 1000)))
  (let
    (
      (review-id (var-get next-review-id))
      (existing-review (map-get? booking-reviews { booking-id: booking-id }))
    )
    (asserts! (is-none existing-review) err-already-reviewed)
    (asserts! (and (>= rating u1) (<= rating u5)) err-invalid-rating)
    ;; Would verify booking is completed and customer is tx-sender

    (map-set reviews
      { review-id: review-id }
      {
        booking-id: booking-id,
        customer: tx-sender,
        provider-id: provider-id,
        rating: rating,
        title: title,
        content: content,
        helpful-votes: u0,
        created-block: block-height,
        verified: true
      }
    )

    (map-set booking-reviews
      { booking-id: booking-id }
      { review-id: review-id }
    )

    (map-set provider-reviews
      { provider-id: provider-id, review-id: review-id }
      { active: true }
    )

    (var-set next-review-id (+ review-id u1))

    ;; Update provider reputation
    (update-provider-reputation provider-id rating)
    (ok review-id)
  )
)

;; Vote on review helpfulness
(define-public (vote-helpful (review-id uint) (helpful bool))
  (let
    (
      (review (unwrap! (map-get? reviews { review-id: review-id }) err-not-found))
      (existing-vote (map-get? review-votes { review-id: review-id, voter: tx-sender }))
    )
    ;; Allow vote updates
    (map-set review-votes
      { review-id: review-id, voter: tx-sender }
      { helpful: helpful }
    )

    ;; Update helpful votes count (simplified - would need proper counting)
    (if helpful
      (map-set reviews
        { review-id: review-id }
        (merge review { helpful-votes: (+ (get helpful-votes review) u1) })
      )
      true
    )
    (ok true)
  )
)

;; Report inappropriate review
(define-public (report-review (review-id uint) (reason (string-ascii 200)))
  (let
    (
      (review (unwrap! (map-get? reviews { review-id: review-id }) err-not-found))
    )
    ;; Would implement reporting mechanism
    ;; For now, just verify review exists
    (ok true)
  )
)

;; Private Functions

;; Update provider reputation based on new review
(define-private (update-provider-reputation (provider-id uint) (new-rating uint))
  (let
    (
      (current-rep (default-to
        { total-reviews: u0, total-rating: u0, average-rating: u0, reputation-score: u0, last-updated: u0 }
        (map-get? provider-reputation { provider-id: provider-id })
      ))
      (new-total-reviews (+ (get total-reviews current-rep) u1))
      (new-total-rating (+ (get total-rating current-rep) new-rating))
      (new-average (/ new-total-rating new-total-reviews))
      (new-reputation-score (calculate-reputation-score new-average new-total-reviews))
    )
    (map-set provider-reputation
      { provider-id: provider-id }
      {
        total-reviews: new-total-reviews,
        total-rating: new-total-rating,
        average-rating: new-average,
        reputation-score: new-reputation-score,
        last-updated: block-height
      }
    )
  )
)

;; Calculate reputation score based on average rating and review count
(define-private (calculate-reputation-score (average-rating uint) (review-count uint))
  (let
    (
      (base-score (* average-rating u20)) ;; Convert 1-5 to 20-100
      (volume-bonus (if (>= review-count u10) u10 (/ review-count u1)))
    )
    (+ base-score volume-bonus)
  )
)

;; Read-only Functions

;; Get review by ID
(define-read-only (get-review (review-id uint))
  (map-get? reviews { review-id: review-id })
)

;; Get review for booking
(define-read-only (get-booking-review (booking-id uint))
  (match (map-get? booking-reviews { booking-id: booking-id })
    booking-review (map-get? reviews { review-id: (get review-id booking-review) })
    none
  )
)

;; Get provider reputation
(define-read-only (get-provider-reputation (provider-id uint))
  (map-get? provider-reputation { provider-id: provider-id })
)

;; Check if user voted on review
(define-read-only (get-user-vote (review-id uint) (voter principal))
  (map-get? review-votes { review-id: review-id, voter: voter })
)

;; Get total reviews count
(define-read-only (get-total-reviews)
  (- (var-get next-review-id) u1)
)

;; Check if provider has minimum reputation
(define-read-only (has-minimum-reputation (provider-id uint) (min-score uint))
  (match (map-get? provider-reputation { provider-id: provider-id })
    reputation (>= (get reputation-score reputation) min-score)
    false
  )
)
