# Whale Commit-Reveal Orders

A minimal Clarity contract scaffold for commit-reveal order submissions. It stores order commitments on-chain, validates reveal timing and ownership, and forwards revealed orders to a placeholder matching hook.

## What It Includes
- `order-commits` map keyed by a 32-byte `commit-hash`, storing `owner` and `block` height
- Error constants for duplicate commits, missing commits, invalid owners, timing windows, and invalid orders
- Reveal window constants: `MIN_REVEAL_DELAY` and `MAX_REVEAL_DELAY`
- A private `match-order` placeholder that returns `(ok true)`

## Public Functions
- `commit-order(order-hash)`
  - Stores a new commit for the caller if the hash is unused
  - Records the current `burn-block-height`

- `reveal-order(amount, price, is-buy, salt)`
  - Recomputes the commit hash from the reveal payload
  - Verifies the caller owns the commit
  - Enforces the min/max reveal window
  - Validates non-zero `amount` and `price`
  - Deletes the commit and calls `match-order`
