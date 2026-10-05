-- PortWatch Database Views
-- v_port_overview: Aggregates port data with routes, distinct backends, domains, and open issues

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
    p.status,
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
    COALESCE(i_stats.has_high_issue, false)::boolean AS "hasHighIssue"
FROM ports p
LEFT JOIN (
    SELECT
        r."portId",
        COUNT(r.id)::integer AS route_count,
        COUNT(DISTINCT r."backendId")::integer AS backend_count,
        STRING_AGG(DISTINCT r.domain, ', ') AS domains_list
    FROM routes r
    WHERE r."portId" IS NOT NULL
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
) i_stats ON p.id = i_stats."relatedPortId";
