
(define-map order-commits { commit-hash: (buff 32) } { owner: principal, block: uint })

(define-constant ERR_ALREADY_COMMITTED u409)
(define-constant ERR_COMMIT_NOT_FOUND u404)
(define-constant ERR_NOT_OWNER u403)
(define-constant ERR_TOO_EARLY u410)
(define-constant ERR_COMMIT_EXPIRED u411)
(define-constant ERR_INVALID_ORDER u412)

(define-constant MIN_REVEAL_DELAY u1)
(define-constant MAX_REVEAL_DELAY u144)

;; Placeholder matching engine hook
(define-private (match-order (amount uint) (price uint) (is-buy bool))
    (ok true)
)

;; 1. Commit (Hide your hand)
(define-public (commit-order (order-hash (buff 32)))
    (begin
        (asserts! (is-none (map-get? order-commits { commit-hash: order-hash })) (err ERR_ALREADY_COMMITTED))
        (ok (map-set order-commits { commit-hash: order-hash } { owner: tx-sender, block: burn-block-height }))
    )
)

;; 2. Reveal & Execute (Show hand)
(define-public (reveal-order (amount uint) (price uint) (is-buy bool) (salt (buff 16)))
    (let (
        (computed-hash (sha256 (unwrap-panic (to-consensus-buff? { amt: amount, prc: price, buy: is-buy, salt: salt }))))
        (commit (unwrap! (map-get? order-commits { commit-hash: computed-hash }) (err ERR_COMMIT_NOT_FOUND)))
        (age (- burn-block-height (get block commit)))
    )
        ;; Verify the hash matches the commit
        (asserts! (is-eq (get owner commit) tx-sender) (err ERR_NOT_OWNER))
        (asserts! (>= age MIN_REVEAL_DELAY) (err ERR_TOO_EARLY))
        (asserts! (<= age MAX_REVEAL_DELAY) (err ERR_COMMIT_EXPIRED))
        (asserts! (> amount u0) (err ERR_INVALID_ORDER))
        (asserts! (> price u0) (err ERR_INVALID_ORDER))
        
        ;; Add to "Matching Engine" order book
        (begin
            (map-delete order-commits { commit-hash: computed-hash })
            (match-order amount price is-buy)
        )
    )
)
