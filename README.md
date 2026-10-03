# server-db
OpenCJ databasing

## Challenge catalogue and awards

Apply `migrations/009-challenges.sql` to the existing CoD4 database before deploying the Challenges scripts. This additive migration creates the catalogue and one completion per player/challenge; it does not replace existing game tables.

Definitions and eligibility rules are maintained in `server-gsc/opencj/challenges.gsc`. Keep each challenge key stable: completions refer to it permanently. A missing `routeName` leaves a challenge visible but unlinked. Startup refreshes catalogue metadata and backfills qualifying finalized runs. Removing a definition deactivates it without deleting earned completions. Rank thresholds are cumulative tier point totals, not stored player levels.

## Shop preview

Apply `migrations/010-shop-purchases.sql` before deploying the Shop menu. It adds ownership and historical spending without modifying challenge awards. Available points are the active challenge total minus the sum of prices actually paid, clamped to zero if challenge values decrease. Purchased items remain owned after repricing or retirement.

Apply `migrations/011-shop-equipment.sql` for transactional purchase handling and saved equipment. The initial catalogue in `server-gsc/opencj/shop.gsc` remains preview-only: every item is unavailable. Real items need a registered cosmetic resource and server-side availability before sales can be enabled.

Shop purchase safety: `shopBuyOrEquip` serializes requests per player inside one transaction, checks the live database catalogue and challenge balance, and records ownership, paid price and equipment together. Its unique ownership key prevents duplicate charges across servers. Equipment is keyed by the base weapon (or `player` for player models), independently of display categories. Owned items remain usable if challenge thresholds or catalogue prices change. The server-ext MySQL wrapper must drain stored-procedure results before reusing connections.
