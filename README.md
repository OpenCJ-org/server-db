# server-db
OpenCJ databasing

## Challenge catalogue and awards

Apply `migrations/009-challenges.sql` to the existing CoD4 database before deploying the Challenges scripts. This additive migration creates the catalogue and one completion per player/challenge; it does not replace existing game tables.

Definitions and eligibility rules are maintained in `server-gsc/opencj/challenges.gsc`. Keep each challenge key stable: completions refer to it permanently. A missing `routeName` leaves a challenge visible but unlinked. Startup refreshes catalogue metadata and backfills qualifying finalized runs. Removing a definition deactivates it without deleting earned completions. Rank thresholds are cumulative tier point totals, not stored player levels.
