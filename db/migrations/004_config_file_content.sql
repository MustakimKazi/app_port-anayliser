-- Migration 004: Config file content storage (Phase 2)
--
-- Config Files get a full detail view where the nginx config text is
-- pasted/stored manually (no generator). Content is optional: existing
-- rows keep content = NULL and the UI shows a "Paste your nginx config"
-- empty state.

ALTER TABLE config_files ADD COLUMN IF NOT EXISTS content TEXT;
