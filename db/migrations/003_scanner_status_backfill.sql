-- Migration 003: Scanner status data backfill (QA bugs BUG-014 / BUG-016)
--
-- BUG-014: failed TCP probes used to store a fabricated latency value
--          (measured up to the timeout). The scanner now writes NULL for
--          failed checks; this backfills the historical rows.
-- BUG-016: ports that are down/unknown used to keep the stale bind address,
--          process and latency from their last successful probe. The scanner
--          now clears them on a failed probe; this backfills the ports table.
--
-- 'slow' ports keep their bind/latency: they ARE listening.

UPDATE port_checks
SET "latencyMs" = NULL
WHERE status = 'down' AND "latencyMs" IS NOT NULL;

UPDATE ports
SET "listenAddress" = NULL,
    "processName" = NULL,
    pid = NULL,
    "latencyMs" = NULL
WHERE status IN ('down', 'unknown')
  AND ("listenAddress" IS NOT NULL OR "processName" IS NOT NULL OR pid IS NOT NULL OR "latencyMs" IS NOT NULL);
