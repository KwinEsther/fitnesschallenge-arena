;; FitnessChallenge Arena: Decentralized fitness challenge platform with rewards
;; Enables trainers to create challenges, participants to join, and coaches to validate achievements

(define-data-var head-coach principal tx-sender)
(define-map challenge-board
  { challenge-id: uint }
  {
    trainer: principal,
    entry-fee: uint,
    challenge-name: (string-ascii 50),
    workout-plan: (string-ascii 500),
    duration-days: uint,
    validated: bool
  }
)

(define-map participation-log
  { challenge-id: uint, log-id: uint }
  {
    participant: principal,
    join-date: uint,
    progress: (string-ascii 20)
  }
)

(define-data-var next-challenge-id uint u1)
(define-map log-counter 
  { challenge-id: uint }
  { logs: uint }
)

;; Create a new fitness challenge
(define-public (create-challenge (name-input (string-ascii 50)) (plan-input (string-ascii 500)) (duration-input uint) (fee-input uint))
  (let
    (
      (challenge-id (var-get next-challenge-id))
      (log-id u0)
      (name name-input)
      (plan plan-input)
      (duration duration-input)
      (fee fee-input)
    )
    ;; Input validation
    (asserts! (> fee u0) (err u1))
    (asserts! (> (len name) u0) (err u5))
    (asserts! (> (len plan) u0) (err u6))
    (asserts! (> duration u0) (err u7))
    
    (map-set challenge-board
      { challenge-id: challenge-id }
      {
        trainer: tx-sender,
        entry-fee: fee,
        challenge-name: name,
        workout-plan: plan,
        duration-days: duration,
        validated: false
      }
    )
    (map-set participation-log
      { challenge-id: challenge-id, log-id: log-id }
      {
        participant: tx-sender,
        join-date: challenge-id,
        progress: "created"
      }
    )
    (map-set log-counter 
      { challenge-id: challenge-id }
      { logs: u1 }
    )
    (var-set next-challenge-id (+ challenge-id u1))
    (ok challenge-id)
  )
)

;; Join a fitness challenge
(define-public (join-challenge (challenge-id-input uint))
  (let
    (
      (challenge-id challenge-id-input)
      (challenge-info (unwrap! (map-get? challenge-board { challenge-id: challenge-id }) (err u2)))
      (fee (get entry-fee challenge-info))
      (trainer (get trainer challenge-info))
      (log-data (default-to { logs: u0 } (map-get? log-counter { challenge-id: challenge-id })))
      (log-id (get logs log-data))
      (new-log-id (+ log-id u1))
    )
    ;; Input validation
    (asserts! (> challenge-id u0) (err u8))
    (asserts! (not (is-eq tx-sender trainer)) (err u3))
    
    (try! (stx-transfer? fee tx-sender trainer))
    (map-set participation-log
      { challenge-id: challenge-id, log-id: log-id }
      {
        participant: tx-sender,
        join-date: (var-get next-challenge-id),
        progress: "joined"
      }
    )
    (map-set log-counter 
      { challenge-id: challenge-id }
      { logs: new-log-id }
    )
    (ok true)
  )
)

;; Validate a challenge (head coach only)
(define-public (validate-challenge (challenge-id-input uint))
  (let
    (
      (challenge-id challenge-id-input)
      (challenge-info (unwrap! (map-get? challenge-board { challenge-id: challenge-id }) (err u2)))
      (log-data (default-to { logs: u0 } (map-get? log-counter { challenge-id: challenge-id })))
      (log-id (get logs log-data))
      (new-log-id (+ log-id u1))
    )
    ;; Input validation
    (asserts! (> challenge-id u0) (err u8))
    (asserts! (is-eq tx-sender (var-get head-coach)) (err u4))
    
    (map-set challenge-board
      { challenge-id: challenge-id }
      (merge challenge-info { validated: true })
    )
    (map-set participation-log
      { challenge-id: challenge-id, log-id: log-id }
      {
        participant: (get trainer challenge-info),
        join-date: (var-get next-challenge-id),
        progress: "validated"
      }
    )
    (map-set log-counter 
      { challenge-id: challenge-id }
      { logs: new-log-id }
    )
    (ok true)
  )
)

;; Get challenge details
(define-read-only (get-challenge (challenge-id uint))
  (map-get? challenge-board { challenge-id: challenge-id })
)

;; Get participation log entry
(define-read-only (get-participation-log (challenge-id uint) (log-id uint))
  (map-get? participation-log { challenge-id: challenge-id, log-id: log-id })
)

;; Get total participation logs for a challenge
(define-read-only (get-participation-count (challenge-id uint))
  (let
    (
      (log-data (default-to { logs: u0 } (map-get? log-counter { challenge-id: challenge-id })))
    )
    (get logs log-data)
  )
)