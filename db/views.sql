-- PortWatch Database Views
-- v_port_overview: Aggregates port data with routes, distinct backends, domains, open issues, and features

CREATE OR REPLACE VIEW v_port_overview AS
SELECT
    p.id,
    p.id AS "portId",
    p.port,
    p.layer,
    p.protocol,
    p.purpose,
    p."processName",
    p.pid,
    p."listenAddress",
    p."isPublic",
    p."isExpected",
    p."isDocumented",
    p.status,
    p.lifecycle,
    p."lifecycleReason",
    p."targetDate",
    p.owner,
    p."maintenanceFrom",
    p."maintenanceTo",
    p."archivedAt",
    p."archivedBy",
    p."expectedBind",
    p."serverId",
    s.name AS "serverName",
    p."latencyMs",
    p."lastCheckedAt",
    p."lastSeenUpAt",
    p.tags,
    p.notes,
    p."customValues",
    p."createdAt",
    p."updatedAt",
    COALESCE(r_stats.route_count, 0)::integer AS "routeCount",
    COALESCE(r_stats.domains_list, '') AS "domainsList",
    COALESCE(r_stats.backend_count, 0)::integer AS "backendCount",
    COALESCE(i_stats.open_issue_count, 0)::integer AS "openIssueCount",
    COALESCE(i_stats.has_high_issue, false)::boolean AS "hasHighIssue",
    COALESCE(f_stats.features_json, '[]'::json) AS "features"
FROM ports p
LEFT JOIN servers s ON p."serverId" = s.id
LEFT JOIN (
    SELECT
        r."portId",
        COUNT(r.id)::integer AS route_count,
        COUNT(DISTINCT r."backendId")::integer AS backend_count,
        STRING_AGG(DISTINCT r.domain, ', ') AS domains_list
    FROM routes r
    WHERE r."portId" IS NOT NULL AND r."archivedAt" IS NULL
    GROUP BY r."portId"
) r_stats ON p.id = r_stats."portId"
LEFT JOIN (
    SELECT
        i."relatedPortId",
        COUNT(i.id)::integer AS open_issue_count,
        BOOL_OR(i.priority = 'High')::boolean AS has_high_issue
    FROM issues i
    WHERE i.status IN ('open', 'acknowledged') AND i."relatedPortId" IS NOT NULL
    GROUP BY i."relatedPortId"
) i_stats ON p.id = i_stats."relatedPortId"
LEFT JOIN (
    SELECT
        pf."portId",
        json_agg(json_build_object(
            'featureKey', pf."featureKey",
            'enabled', pf.enabled,
            'config', pf.config
        )) AS features_json
    FROM port_features pf
    GROUP BY pf."portId"
) f_stats ON p.id = f_stats."portId";
