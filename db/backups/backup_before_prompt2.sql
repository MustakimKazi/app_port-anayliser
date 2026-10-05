--
-- PostgreSQL database dump
--

\restrict hPC1poLcc0sOVNPLTaAAqKvkcIUIEXxd7oGeXdTR2uMXHT92AUvHg0wcsdbhde8

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alert_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alert_logs (
    id text NOT NULL,
    "ruleId" text,
    title text NOT NULL,
    message text NOT NULL,
    channel text NOT NULL,
    status text DEFAULT 'sent'::text NOT NULL,
    "sentAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.alert_logs OWNER TO postgres;

--
-- Name: alert_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alert_rules (
    id text NOT NULL,
    name text NOT NULL,
    "eventType" text NOT NULL,
    threshold integer,
    channels text[] DEFAULT ARRAY['log'::text],
    "isEnabled" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.alert_rules OWNER TO postgres;

--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_log (
    id text NOT NULL,
    "userId" text,
    username text NOT NULL,
    action text NOT NULL,
    entity text NOT NULL,
    "entityId" text,
    "beforeState" jsonb,
    "afterState" jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.audit_log OWNER TO postgres;

--
-- Name: backends; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.backends (
    id text NOT NULL,
    "serverId" text,
    host text NOT NULL,
    port integer NOT NULL,
    label text,
    notes text,
    status text DEFAULT 'unknown'::text NOT NULL,
    "latencyMs" double precision,
    "lastCheckedAt" timestamp(3) without time zone,
    "customValues" jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.backends OWNER TO postgres;

--
-- Name: config_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.config_files (
    id text NOT NULL,
    filename text NOT NULL,
    status text DEFAULT 'active'::text NOT NULL,
    description text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.config_files OWNER TO postgres;

--
-- Name: custom_field_values; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.custom_field_values (
    id text NOT NULL,
    "fieldId" text NOT NULL,
    "entityType" text NOT NULL,
    "entityId" text NOT NULL,
    "valueText" text,
    "valueJson" jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.custom_field_values OWNER TO postgres;

--
-- Name: custom_fields; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.custom_fields (
    id text NOT NULL,
    "entityType" text NOT NULL,
    name text NOT NULL,
    key text NOT NULL,
    "fieldType" text NOT NULL,
    options jsonb,
    required boolean DEFAULT false NOT NULL,
    "defaultValue" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.custom_fields OWNER TO postgres;

--
-- Name: issues; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.issues (
    id text NOT NULL,
    "issueNum" integer,
    priority text DEFAULT 'Medium'::text NOT NULL,
    title text NOT NULL,
    observed text NOT NULL,
    recommendation text NOT NULL,
    status text DEFAULT 'open'::text NOT NULL,
    "relatedPortId" text,
    "relatedRouteId" text,
    source text DEFAULT 'imported'::text NOT NULL,
    "autoKey" text,
    assignee text,
    comments jsonb,
    "resolvedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.issues OWNER TO postgres;

--
-- Name: port_checks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.port_checks (
    id text NOT NULL,
    "targetType" text NOT NULL,
    "targetId" text NOT NULL,
    "targetName" text,
    "checkedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status text NOT NULL,
    "latencyMs" double precision,
    error text,
    "checkType" text NOT NULL
);


ALTER TABLE public.port_checks OWNER TO postgres;

--
-- Name: ports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ports (
    id text NOT NULL,
    port integer NOT NULL,
    layer text DEFAULT 'http'::text NOT NULL,
    protocol text DEFAULT 'HTTP'::text NOT NULL,
    purpose text,
    "processName" text,
    pid integer,
    "listenAddress" text,
    "isPublic" boolean DEFAULT true NOT NULL,
    "isExpected" boolean DEFAULT true NOT NULL,
    status text DEFAULT 'unknown'::text NOT NULL,
    "latencyMs" double precision,
    "lastCheckedAt" timestamp(3) without time zone,
    "lastSeenUpAt" timestamp(3) without time zone,
    tags text[] DEFAULT ARRAY[]::text[],
    notes text,
    "customValues" jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.ports OWNER TO postgres;

--
-- Name: routes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.routes (
    id text NOT NULL,
    "rowNum" integer,
    domain text NOT NULL,
    "domainRaw" text,
    "isCatchAll" boolean DEFAULT false NOT NULL,
    "portId" text,
    "portNum" integer,
    "portRaw" text,
    protocol text DEFAULT 'HTTP'::text NOT NULL,
    path text DEFAULT '/'::text NOT NULL,
    paths text[] DEFAULT ARRAY[]::text[],
    action text DEFAULT 'Proxy'::text NOT NULL,
    "targetRaw" text,
    "targetType" text DEFAULT 'unknown'::text NOT NULL,
    "backendId" text,
    "staticRoot" text,
    "redirectCode" integer,
    "configFileId" text,
    notes text,
    flags jsonb,
    "customValues" jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.routes OWNER TO postgres;

--
-- Name: saved_views; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saved_views (
    id text NOT NULL,
    "userId" text,
    name text NOT NULL,
    page text NOT NULL,
    "filterJson" jsonb NOT NULL,
    "isShared" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.saved_views OWNER TO postgres;

--
-- Name: servers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.servers (
    id text NOT NULL,
    name text NOT NULL,
    host text NOT NULL,
    kind text DEFAULT 'backend'::text NOT NULL,
    "groupLabel" text,
    notes text,
    tags text[] DEFAULT ARRAY[]::text[],
    "customValues" jsonb,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.servers OWNER TO postgres;

--
-- Name: settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.settings (
    id text DEFAULT 'global'::text NOT NULL,
    "scanIntervalSec" integer DEFAULT 30 NOT NULL,
    "tcpTimeoutMs" integer DEFAULT 3000 NOT NULL,
    "slowThresholdMs" integer DEFAULT 1500 NOT NULL,
    "concurrencyLimit" integer DEFAULT 20 NOT NULL,
    "retentionDays" integer DEFAULT 90 NOT NULL,
    "telegramConfig" jsonb,
    "slackDiscordWebhook" text,
    "smtpConfig" jsonb,
    "genericWebhook" text,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.settings OWNER TO postgres;

--
-- Name: status_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.status_events (
    id text NOT NULL,
    "targetType" text NOT NULL,
    "targetId" text NOT NULL,
    "targetName" text NOT NULL,
    "fromStatus" text NOT NULL,
    "toStatus" text NOT NULL,
    at timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    details jsonb
);


ALTER TABLE public.status_events OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id text NOT NULL,
    username text NOT NULL,
    "passwordHash" text NOT NULL,
    role text DEFAULT 'admin'::text NOT NULL,
    email text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: v_port_overview; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_port_overview AS
 SELECT p.id,
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
    COALESCE(r_stats.route_count, 0) AS "routeCount",
    COALESCE(r_stats.domains_list, ''::text) AS "domainsList",
    COALESCE(r_stats.backend_count, 0) AS "backendCount",
    COALESCE(i_stats.open_issue_count, 0) AS "openIssueCount",
    COALESCE(i_stats.has_high_issue, false) AS "hasHighIssue"
   FROM ((public.ports p
     LEFT JOIN ( SELECT r."portId",
            (count(r.id))::integer AS route_count,
            (count(DISTINCT r."backendId"))::integer AS backend_count,
            string_agg(DISTINCT r.domain, ', '::text) AS domains_list
           FROM public.routes r
          WHERE (r."portId" IS NOT NULL)
          GROUP BY r."portId") r_stats ON ((p.id = r_stats."portId")))
     LEFT JOIN ( SELECT i."relatedPortId",
            (count(i.id))::integer AS open_issue_count,
            bool_or((i.priority = 'High'::text)) AS has_high_issue
           FROM public.issues i
          WHERE ((i.status = ANY (ARRAY['open'::text, 'acknowledged'::text])) AND (i."relatedPortId" IS NOT NULL))
          GROUP BY i."relatedPortId") i_stats ON ((p.id = i_stats."relatedPortId")));


ALTER VIEW public.v_port_overview OWNER TO postgres;

--
-- Data for Name: alert_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alert_logs (id, "ruleId", title, message, channel, status, "sentAt") FROM stdin;
aed83960-3e6a-4ce0-b473-09b3d80893d1	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8090 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.405Z	log	simulated	2026-10-05 05:13:31.406
939d513d-93aa-4dab-a40d-b50a2e773de8	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.200:8096 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.405Z	log	simulated	2026-10-05 05:13:31.406
41c3bafc-060a-47b7-87d8-5644ecf37d8e	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:5050 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.404Z	log	simulated	2026-10-05 05:13:31.406
2957cc04-06d3-4328-b993-f34d3f693488	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8333 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.405Z	log	simulated	2026-10-05 05:13:31.406
e161110b-7d3e-4f40-9fac-e23a3dafae0d	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:5000 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.406Z	log	simulated	2026-10-05 05:13:31.407
e8143570-8a7f-4d65-afb9-4c7f38aa9b1d	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8989 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.406Z	log	simulated	2026-10-05 05:13:31.407
c2e17caf-bd1d-4b1e-8bbd-1d75ab180cc1	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.200:8786 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.408Z	log	simulated	2026-10-05 05:13:31.409
f035ef83-e527-4c6e-be2e-aee38ae44220	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8082 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.409Z	log	simulated	2026-10-05 05:13:31.409
87fa6646-28a5-46df-9d3e-43e2bee9445d	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:9011 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.407Z	log	simulated	2026-10-05 05:13:31.408
bc628f48-bf79-4bc3-aea5-0dc58f74909d	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.200:8080 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.409Z	log	simulated	2026-10-05 05:13:31.409
f06d9c79-5f35-4be0-8b92-69f9b56cd58e	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:3010 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.410Z	log	simulated	2026-10-05 05:13:31.411
940a8626-dc82-48f8-b92a-79424085eef6	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.200:8096 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.413Z	webhook	simulated	2026-10-05 05:13:31.414
ca3818af-56b9-4567-b70d-8ab4475c176c	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8333 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.413Z	webhook	simulated	2026-10-05 05:13:31.414
de852ed4-c501-49a7-a1ea-d6d2d343e492	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:5050 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.413Z	webhook	simulated	2026-10-05 05:13:31.413
f1e535b0-5fa6-4c27-8d88-e390e556d7b4	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:5000 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.413Z	webhook	simulated	2026-10-05 05:13:31.414
a4461f0c-4334-4ab1-a112-25bd27d24180	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8989 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.413Z	webhook	simulated	2026-10-05 05:13:31.414
d7de5725-3b5d-4f74-a335-ffeb32ae9a3f	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.200:8080 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.415Z	webhook	simulated	2026-10-05 05:13:31.416
bc11b89e-241d-4cc5-9a49-0f226ba4ed08	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.200:8786 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.415Z	webhook	simulated	2026-10-05 05:13:31.416
957cc6e4-14e2-4425-a544-9cc67caa9de6	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8090 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.415Z	webhook	simulated	2026-10-05 05:13:31.417
9ae0a324-c812-41b1-88d0-9c0e7ff45061	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8082 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.416Z	webhook	simulated	2026-10-05 05:13:31.417
0448fc68-622e-47ef-9135-2305846bdd10	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:9011 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.415Z	webhook	simulated	2026-10-05 05:13:31.417
d90e361b-83a0-4379-904a-aeba59c6264a	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:3010 is DOWN	Status changed from up to down on 2026-10-05T05:13:31.415Z	webhook	simulated	2026-10-05 05:13:31.417
3bd0b81b-0404-4e84-b312-86ab14563344	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.200:8096 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.417Z	log	simulated	2026-10-05 05:15:01.418
b3a48461-57ac-4ade-a0ec-f0316c45692c	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.200:8786 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.424Z	log	simulated	2026-10-05 05:15:01.425
703f3a62-270e-4516-b15c-df95b6ac5fef	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.200:8096 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.423Z	webhook	simulated	2026-10-05 05:15:01.425
df188fb3-dccc-4625-88ce-661bdec33f89	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8333 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.429Z	log	simulated	2026-10-05 05:15:01.43
145e76de-4e08-463a-ad22-807647a46d46	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.200:8786 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.429Z	webhook	simulated	2026-10-05 05:15:01.429
9beb45af-c465-4223-a41e-c365dbd95df5	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8333 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.431Z	webhook	simulated	2026-10-05 05:15:01.432
1b2898c6-ed6b-44f2-887f-8ce37dac4e96	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8090 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.431Z	log	simulated	2026-10-05 05:15:01.432
dbfaec32-387e-48f5-baf1-23d1983c45ab	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8090 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.433Z	webhook	simulated	2026-10-05 05:15:01.434
e8806d8c-54f7-46cc-b43b-068ce450eddf	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:9011 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.452Z	log	simulated	2026-10-05 05:15:01.452
d052efaf-7584-4c88-96d9-e35c2db7216c	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:5000 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.452Z	log	simulated	2026-10-05 05:15:01.453
9f7c3a69-c14d-431c-9890-6a601bf0167b	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.200:8080 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.452Z	log	simulated	2026-10-05 05:15:01.453
c4f328ef-b20a-47dd-b228-3f1a399c2ca5	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:3010 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.452Z	log	simulated	2026-10-05 05:15:01.453
86f07562-8878-4e5d-8f5c-6360ed74981d	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:5050 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.452Z	log	simulated	2026-10-05 05:15:01.453
eecc4375-ec43-480e-b864-dfd0563eaf00	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8082 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.453Z	log	simulated	2026-10-05 05:15:01.454
6baea0ec-823a-44f3-b253-fe9ae3c591b6	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:5000 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.455Z	webhook	simulated	2026-10-05 05:15:01.455
5113ee47-f082-4d64-a66d-cc453db19225	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:9011 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.455Z	webhook	simulated	2026-10-05 05:15:01.456
7e7c7b63-0247-4482-9dd6-a4f969cc9651	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8989 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.454Z	log	simulated	2026-10-05 05:15:01.455
48438223-1fbe-451d-964a-4875e16727df	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:3010 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.455Z	webhook	simulated	2026-10-05 05:15:01.456
4ee87aaa-58be-43e5-a49f-beaa5449c8ec	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:5050 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.456Z	webhook	simulated	2026-10-05 05:15:01.456
91b739f4-ca33-41af-892b-83257d37e1e3	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.200:8080 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.456Z	webhook	simulated	2026-10-05 05:15:01.456
3bceb861-579a-4f77-8ed7-981a1ba0926a	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8989 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.457Z	webhook	simulated	2026-10-05 05:15:01.458
348f9b2d-5cc4-4f62-8ade-75a905642ef0	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8082 is DOWN	Status changed from up to down on 2026-10-05T05:15:01.457Z	webhook	simulated	2026-10-05 05:15:01.458
0e21c4a7-9a18-4755-bf89-b0355c6040b2	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8333 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.868Z	log	simulated	2026-10-05 05:26:41.868
73508607-e3bf-4415-844c-62dcb1ad03fa	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:5000 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.867Z	log	simulated	2026-10-05 05:26:41.868
93405def-d513-4f33-8a4c-50dc7a52cc0e	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8333 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.873Z	webhook	simulated	2026-10-05 05:26:41.874
e5fd7390-6dbe-462c-bb29-f8ca7bad3f1c	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.200:8080 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.874Z	log	simulated	2026-10-05 05:26:41.875
17a6adf4-fbef-4dfb-a58c-8c9bba40a2c3	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:5000 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.873Z	webhook	simulated	2026-10-05 05:26:41.874
6f23a8d3-d768-4278-a25e-4b17e28ce718	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.200:8096 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.874Z	log	simulated	2026-10-05 05:26:41.874
53e01c47-9cdd-4137-868f-43cf005732b8	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:3010 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.874Z	log	simulated	2026-10-05 05:26:41.874
02a9aa04-39c6-490c-8eb7-f30fbed33a65	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8090 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.874Z	log	simulated	2026-10-05 05:26:41.874
ef898d4b-63ca-496c-8a57-742318ece676	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:9011 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.874Z	log	simulated	2026-10-05 05:26:41.875
f3672ba6-c54b-43a8-943a-bd7cde516e89	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.200:8080 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.876Z	webhook	simulated	2026-10-05 05:26:41.876
77c31295-d1fa-471a-8ce0-eb1c8e194cb9	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8090 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.877Z	webhook	simulated	2026-10-05 05:26:41.877
12780aba-da0f-4e99-a6e4-7383a6b03651	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.200:8096 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.876Z	webhook	simulated	2026-10-05 05:26:41.877
52af9bf4-783f-453a-ab41-af995f64411b	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8082 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.877Z	log	simulated	2026-10-05 05:26:41.878
45f37a1d-3d66-4020-96af-4286e7698dd1	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:3010 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.877Z	webhook	simulated	2026-10-05 05:26:41.877
35678da1-9fa3-49a1-bb93-3654c729e041	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8989 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.877Z	log	simulated	2026-10-05 05:26:41.878
e044106e-5b85-48c6-88a3-717b325cc411	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:9011 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.880Z	webhook	simulated	2026-10-05 05:26:41.88
f1ba6f77-aa46-4150-8650-231e1a32c457	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8082 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.880Z	webhook	simulated	2026-10-05 05:26:41.88
96a903fc-5682-43bc-978d-102a30d08e1a	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:8989 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.880Z	webhook	simulated	2026-10-05 05:26:41.881
2c4dae58-edc9-48fd-980a-ccafe192075b	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.200:8786 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.880Z	log	simulated	2026-10-05 05:26:41.881
50d6983e-5c77-435a-b253-20dddb59742a	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:5050 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.881Z	log	simulated	2026-10-05 05:26:41.881
2c358f48-dfcb-4e5e-b9c1-6ab98c1cf94c	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.200:8786 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.881Z	webhook	simulated	2026-10-05 05:26:41.882
3a1e37d2-7cdc-4fbf-8cf9-7a9ea58f85a8	1cd5448c-ae44-43fa-b621-156f2e961ebc	Alert: 10.0.0.100:5050 is DOWN	Status changed from up to down on 2026-10-05T05:26:41.882Z	webhook	simulated	2026-10-05 05:26:41.882
\.


--
-- Data for Name: alert_rules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alert_rules (id, name, "eventType", threshold, channels, "isEnabled", "createdAt", "updatedAt") FROM stdin;
1cd5448c-ae44-43fa-b621-156f2e961ebc	Port Down Alert	down_duration	1	{log,webhook}	t	2026-10-05 04:56:20.677	2026-10-05 04:56:20.677
fad3a6a3-de11-4ff0-93ef-0673256da686	Undocumented Listening Port	undocumented_port	0	{log}	t	2026-10-05 04:56:20.682	2026-10-05 04:56:20.682
ca8556b7-0554-4bd8-8162-fef8f1ef0820	Certificate Expiring Soon (< 14 days)	cert_expiry	14	{log,webhook}	t	2026-10-05 04:56:20.684	2026-10-05 04:56:20.684
36a48b48-602d-4059-a626-4f978e1c4a56	High Priority Issue Auto-Detected	high_issue	0	{log}	t	2026-10-05 04:56:20.692	2026-10-05 04:56:20.692
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_log (id, "userId", username, action, entity, "entityId", "beforeState", "afterState", "createdAt") FROM stdin;
\.


--
-- Data for Name: backends; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.backends (id, "serverId", host, port, label, notes, status, "latencyMs", "lastCheckedAt", "customValues", "createdAt", "updatedAt") FROM stdin;
f060df71-9a9e-4de5-9298-a00f4facba0b	1503e4e3-ca1b-4bb5-add0-ee911baf81b3	localhost	6875	localhost:6875	Runs on this nginx server itself	down	1	2026-10-05 06:18:52.332	\N	2026-10-05 04:56:19.939	2026-10-05 06:18:52.333
971176aa-5d7b-4ba8-a804-5496eeb5ebc8	1503e4e3-ca1b-4bb5-add0-ee911baf81b3	localhost	8020	localhost:8020	Runs on this nginx server itself	down	2	2026-10-05 06:18:52.332	\N	2026-10-05 04:56:19.944	2026-10-05 06:18:52.333
70069108-249c-4a7e-b962-1f00c3416dbb	1503e4e3-ca1b-4bb5-add0-ee911baf81b3	localhost	3001	localhost:3001	Runs on this nginx server itself	up	2	2026-10-05 06:18:52.332	\N	2026-10-05 04:56:19.93	2026-10-05 06:18:52.333
f818583c-c73b-4ce9-bbf5-1601cb636f9e	1503e4e3-ca1b-4bb5-add0-ee911baf81b3	localhost	8080	localhost:8080	Runs on this nginx server itself	down	1	2026-10-05 06:18:52.332	\N	2026-10-05 04:56:19.95	2026-10-05 06:18:52.332
47012dbc-c20f-4924-9007-6448b27e32cd	1503e4e3-ca1b-4bb5-add0-ee911baf81b3	localhost	4100	localhost:4100	Runs on this nginx server itself	down	2	2026-10-05 06:18:52.332	\N	2026-10-05 04:56:19.936	2026-10-05 06:18:52.333
1341092e-90ea-4bc4-8007-385460b87942	\N	$jellyfin (variable)	8096	$jellyfin (variable):8096		down	1	2026-10-05 06:18:52.331	\N	2026-10-05 04:56:19.969	2026-10-05 06:18:52.332
24582c1a-a546-46a6-a89e-2a80fe8ef43c	1503e4e3-ca1b-4bb5-add0-ee911baf81b3	localhost	8088	localhost:8088	Runs on this nginx server itself	down	1	2026-10-05 06:18:52.331	\N	2026-10-05 04:56:19.952	2026-10-05 06:18:52.332
0c959eb9-7b7e-4565-b414-1923670acc19	f308c74d-c257-4589-b650-7f8e9e994521	10.0.0.200	8080	10.0.0.200:8080	Backend server B	up	354	2026-10-05 06:18:52.684	\N	2026-10-05 04:56:19.992	2026-10-05 06:18:52.685
3c13e9b8-dded-4acd-99a2-eec56dea599e	b5b99142-0282-4401-8a11-65a5b1a8beaa	10.0.0.100	3010	10.0.0.100:3010	Backend server A	up	354	2026-10-05 06:18:52.684	\N	2026-10-05 04:56:19.971	2026-10-05 06:18:52.685
a830ee9a-87da-4280-9ec7-e547ef244051	b5b99142-0282-4401-8a11-65a5b1a8beaa	10.0.0.100	8989	10.0.0.100:8989	Backend server A	up	355	2026-10-05 06:18:52.685	\N	2026-10-05 04:56:19.985	2026-10-05 06:18:52.686
d53359f8-0936-4edd-bac6-65298f541aca	b5b99142-0282-4401-8a11-65a5b1a8beaa	10.0.0.100	8333	10.0.0.100:8333	Backend server A	up	355	2026-10-05 06:18:52.685	\N	2026-10-05 04:56:19.982	2026-10-05 06:18:52.686
4a338faf-033a-47a3-b5ff-4cf6b3d44a29	0fec72ab-c1e8-4a3c-9122-0227baf33b5e	192.168.1.222	8082	192.168.1.222:8082	Backend server D (LAN)	down	3000	2026-10-05 06:18:55.331	\N	2026-10-05 04:56:20.011	2026-10-05 06:18:55.331
dc188d16-4828-4521-b0a1-63a42113fd9c	0fec72ab-c1e8-4a3c-9122-0227baf33b5e	192.168.1.222	82	192.168.1.222:82	Backend server D (LAN)	down	3001	2026-10-05 06:18:55.331	\N	2026-10-05 04:56:20.006	2026-10-05 06:18:55.331
cc5b42fa-768d-4952-95ac-1dfbc0e3061a	1503e4e3-ca1b-4bb5-add0-ee911baf81b3	localhost	8555	localhost:8555	Runs on this nginx server itself	down	1	2026-10-05 06:18:52.332	\N	2026-10-05 04:56:19.955	2026-10-05 06:18:52.332
319957bc-1b42-4760-a62f-f99702ed7287	1503e4e3-ca1b-4bb5-add0-ee911baf81b3	localhost	8556	localhost:8556	Runs on this nginx server itself	down	1	2026-10-05 06:18:52.332	\N	2026-10-05 04:56:19.957	2026-10-05 06:18:52.332
7288259e-9538-4b21-b7eb-36339e423ad7	1503e4e3-ca1b-4bb5-add0-ee911baf81b3	localhost	7000	localhost:7000	Runs on this nginx server itself	up	1	2026-10-05 06:18:52.331	\N	2026-10-05 04:56:19.941	2026-10-05 06:18:52.332
bc543403-17de-4254-8b46-4c2234f6a578	84183fa2-9430-466d-8b44-a2958f9c233b	192.168.1.221	4001	192.168.1.221:4001	Backend server C (LAN)	down	3000	2026-10-05 06:18:55.33	\N	2026-10-05 04:56:20.001	2026-10-05 06:18:55.331
f983d605-e989-4489-aa32-cf13fa3859b4	0fec72ab-c1e8-4a3c-9122-0227baf33b5e	192.168.1.222	8080	192.168.1.222:8080	Backend server D (LAN)	down	3001	2026-10-05 06:18:55.331	\N	2026-10-05 04:56:20.009	2026-10-05 06:18:55.331
6a2f9668-696a-42bf-8c49-3429fc393581	b5b99142-0282-4401-8a11-65a5b1a8beaa	10.0.0.100	8082	10.0.0.100:8082	Backend server A	up	355	2026-10-05 06:18:52.686	\N	2026-10-05 04:56:19.978	2026-10-05 06:18:52.686
a7a3748e-e607-4880-9c19-c642e6557535	b5b99142-0282-4401-8a11-65a5b1a8beaa	10.0.0.100	8090	10.0.0.100:8090	Backend server A	up	355	2026-10-05 06:18:52.686	\N	2026-10-05 04:56:19.98	2026-10-05 06:18:52.686
1cbb503f-01dd-4427-bab5-30006e1fe60b	f308c74d-c257-4589-b650-7f8e9e994521	10.0.0.200	8786	10.0.0.200:8786	Backend server B	up	348	2026-10-05 06:18:52.686	\N	2026-10-05 04:56:19.997	2026-10-05 06:18:52.687
bc194eb2-5992-40e4-b518-6d96933dffb9	b5b99142-0282-4401-8a11-65a5b1a8beaa	10.0.0.100	5000	10.0.0.100:5000	Backend server A	up	348	2026-10-05 06:18:52.686	\N	2026-10-05 04:56:19.973	2026-10-05 06:18:52.687
0de000ed-8f0d-4886-8432-02a6ae7436be	84183fa2-9430-466d-8b44-a2958f9c233b	192.168.1.221	8180	192.168.1.221:8180	Backend server C (LAN)	down	3000	2026-10-05 06:18:55.335	\N	2026-10-05 04:56:20.004	2026-10-05 06:18:55.336
137e2e5e-b96f-4e8a-aaff-1dca0da29923	84183fa2-9430-466d-8b44-a2958f9c233b	192.168.1.221	3011	192.168.1.221:3011	Backend server C (LAN)	down	3001	2026-10-05 06:18:55.336	\N	2026-10-05 04:56:19.999	2026-10-05 06:18:55.337
c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	0fec72ab-c1e8-4a3c-9122-0227baf33b5e	192.168.1.222	8787	192.168.1.222:8787	Backend server D (LAN)	down	3000	2026-10-05 06:18:55.337	\N	2026-10-05 04:56:20.013	2026-10-05 06:18:55.337
89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	1503e4e3-ca1b-4bb5-add0-ee911baf81b3	localhost	9000	localhost:9000	Runs on this nginx server itself	down	0	2026-10-05 06:18:52.335	\N	2026-10-05 04:56:19.96	2026-10-05 06:18:52.336
85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	1503e4e3-ca1b-4bb5-add0-ee911baf81b3	localhost	9001	localhost:9001	Runs on this nginx server itself	down	0	2026-10-05 06:18:52.336	\N	2026-10-05 04:56:19.962	2026-10-05 06:18:52.336
a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	1503e4e3-ca1b-4bb5-add0-ee911baf81b3	localhost	8078	localhost:8078	Runs on this nginx server itself	down	0	2026-10-05 06:18:52.336	\N	2026-10-05 04:56:19.947	2026-10-05 06:18:52.337
cd45c8d5-3d4a-4596-8d54-99526d9c5daf	1503e4e3-ca1b-4bb5-add0-ee911baf81b3	localhost	9006	localhost:9006	Runs on this nginx server itself	down	0	2026-10-05 06:18:52.337	\N	2026-10-05 04:56:19.965	2026-10-05 06:18:52.337
4b6d69ef-36a2-453a-bae1-02a7500c4225	1503e4e3-ca1b-4bb5-add0-ee911baf81b3	localhost	9020	localhost:9020	Runs on this nginx server itself	down	0	2026-10-05 06:18:52.337	\N	2026-10-05 04:56:19.967	2026-10-05 06:18:52.338
262738e7-53aa-4415-a3f1-2265f3ba9773	b5b99142-0282-4401-8a11-65a5b1a8beaa	10.0.0.100	9011	10.0.0.100:9011	Backend server A	up	350	2026-10-05 06:18:52.685	\N	2026-10-05 04:56:19.987	2026-10-05 06:18:52.685
79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	f308c74d-c257-4589-b650-7f8e9e994521	10.0.0.200	3100	10.0.0.200:3100	Backend server B	down	350	2026-10-05 06:18:52.685	\N	2026-10-05 04:56:19.99	2026-10-05 06:18:52.686
af946847-9d32-403e-9910-eaaeeb0d5081	f308c74d-c257-4589-b650-7f8e9e994521	10.0.0.200	8096	10.0.0.200:8096	Backend server B	up	347	2026-10-05 06:18:52.686	\N	2026-10-05 04:56:19.995	2026-10-05 06:18:52.686
8aeb84e7-f0d3-4577-8edb-34823b3e8e47	b5b99142-0282-4401-8a11-65a5b1a8beaa	10.0.0.100	5050	10.0.0.100:5050	Backend server A	up	347	2026-10-05 06:18:52.685	\N	2026-10-05 04:56:19.975	2026-10-05 06:18:52.686
\.


--
-- Data for Name: config_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.config_files (id, filename, status, description, "createdAt", "updatedAt") FROM stdin;
8d29aff6-91c7-4a3a-ad00-c175239226c4	akhbar.mahdibagh.net.conf	active	akhbar.mahdibagh.net	2026-10-05 04:56:19.843	2026-10-05 05:46:01.226
c5a4b892-5937-4bce-a69e-5e15c40c6426	app.schoolsecurity.uz.conf	active	app.schoolsecurity.uz	2026-10-05 04:56:19.845	2026-10-05 05:46:01.227
b4c1aa4e-ffc9-4ddc-8dcb-0b208d201fee	ban.leadows.com.conf	active	ban.leadows.com (server_name _)	2026-10-05 04:56:19.847	2026-10-05 05:46:01.228
f4fd77fd-c085-4c27-9a7b-0bff29f2aaf6	books.leadows.conf	active	books.leadows.com	2026-10-05 04:56:19.849	2026-10-05 05:46:01.229
692412a3-4697-4c61-a8f4-2ec2fc4b7ad9	bugs.leadows.com.conf	active	bugs.leadows.com	2026-10-05 04:56:19.851	2026-10-05 05:46:01.23
61b68799-9f31-4972-b110-86115f96efac	demoshop.leadows.com.conf	active	demoshop.leadows.com	2026-10-05 04:56:19.853	2026-10-05 05:46:01.231
0dab4bbf-5d9e-422a-9134-a8a69073a96c	docs.mahdibagh.org.conf	active	docs.mahdibagh.org	2026-10-05 04:56:19.854	2026-10-05 05:46:01.232
1915484d-41bb-4754-8f3d-1f4c2ffba90a	doks.leadows.com.conf	active	doks.leadows.com	2026-10-05 04:56:19.856	2026-10-05 05:46:01.233
5ff25a60-7c1b-4342-9dd9-940294d62c5d	emr.mahdibagh.org.conf	active	emr.mahdibagh.org	2026-10-05 04:56:19.858	2026-10-05 05:46:01.234
7a9a564e-e596-42a5-9cc2-5123f3724c9a	ems-staging.leadows.com.conf	active	ems-staging.leadows.com	2026-10-05 04:56:19.86	2026-10-05 05:46:01.235
867d3d2a-f9fc-4018-bfd1-0d74b85a7d7e	ems.leadows.com.conf	active	ems.leadows.com	2026-10-05 04:56:19.862	2026-10-05 05:46:01.235
0eff45cb-6f1f-4500-ba00-7b33fb18ce98	hub.leadows.com.conf	active	hub.leadows.com	2026-10-05 04:56:19.864	2026-10-05 05:46:01.236
e22d8e26-fb98-425d-ab2c-af892d0b88a0	khabar.mahdibagh.net.conf	active	khabar.mahdibagh.net	2026-10-05 04:56:19.866	2026-10-05 05:46:01.237
af18d98c-4870-4b2d-8cd0-5184f9ccbdea	leadowserp.com.conf	active	leadowserp.com, www.leadowserp.com, leadowserp.leadows.com	2026-10-05 04:56:19.867	2026-10-05 05:46:01.238
ec51f9dd-5cfc-4c89-8f89-8e958a3475e8	mahdibagh.org.conf	active	www.mahdibagh.org, mbyc.mahdibagh.org	2026-10-05 04:56:19.869	2026-10-05 05:46:01.238
e7489e9f-5a1c-4696-a074-2a216ef4a3ad	mbapp.mahdibagh.net.conf	active	mbapp.mahdibagh.net	2026-10-05 04:56:19.871	2026-10-05 05:46:01.239
2069eca7-2d93-4e54-8b52-322e186a481f	mbc.leadows.com.conf	active	mbc.leadows.com	2026-10-05 04:56:19.873	2026-10-05 05:46:01.24
159b52db-7492-4a66-a82f-51ef03debd41	mm.leadows.com.conf	active	mm.leadows.com (server_name _)	2026-10-05 04:56:19.875	2026-10-05 05:46:01.241
b98f3007-7d8e-4a6b-a363-fd629fec2ad0	myneuron.leadows.conf	active	myneuron.leadows.com	2026-10-05 04:56:19.877	2026-10-05 05:46:01.242
90c0e851-6b36-46d9-90fc-1e33010653b9	primary.leadowserp.com.conf	active	primary.leadowserp.com	2026-10-05 04:56:19.878	2026-10-05 05:46:01.243
445418ff-4f39-43d9-ae07-263919d25422	publisher.khabar.mahdibagh.net.conf	active	publisher.khabar.mahdibagh.net	2026-10-05 04:56:19.88	2026-10-05 05:46:01.244
fcd17c96-acda-44e8-81ad-507540c939c2	punekar.leadows.conf	active	punekar.leadows.com	2026-10-05 04:56:19.882	2026-10-05 05:46:01.244
ac902460-3145-4f10-9643-bb62bd7c2755	rag.leadows.com.conf	active	rag.leadows.com	2026-10-05 04:56:19.884	2026-10-05 05:46:01.245
4d95c5e1-b23e-4679-8159-a011c2a2c9e8	restaurant.leadows.conf	active	restaurant.leadows.com	2026-10-05 04:56:19.886	2026-10-05 05:46:01.246
a7e4f698-03d5-4fc3-ad28-283caf50890c	schoolbus.leadows.com.conf	active	schoolbus.leadows.com	2026-10-05 04:56:19.888	2026-10-05 05:46:01.247
eb5d465b-e2dd-40b3-9bfc-b75f5b437dbe	schoolsecurity.uz.conf	active	www.schoolsecurity.uz, schoolsecurity.uz, api.schoolsecurity.uz	2026-10-05 04:56:19.889	2026-10-05 05:46:01.248
0135aeec-54a3-4c98-a112-95fd24be807a	staging.leadowserp.com.conf	active	staging.leadowserp.com	2026-10-05 04:56:19.891	2026-10-05 05:46:01.249
04c468a8-f556-43db-bbf5-17e84e8f8e1c	stub_status.conf	active	localhost	2026-10-05 04:56:19.893	2026-10-05 05:46:01.249
1759fb3c-db79-4c06-8870-5e6e4f674595	tasks.leadows.com.conf	active	tasks.leadows.com	2026-10-05 04:56:19.895	2026-10-05 05:46:01.25
5f1f5bc6-fa82-4b79-a74a-1cd346c1d4a9	train.leadows.com.conf	active	train.leadows.com	2026-10-05 04:56:19.896	2026-10-05 05:46:01.251
9cca75bf-5aa7-48c3-a23b-451e419ec56e	training.leadows.com.conf	active	training.leadows.com	2026-10-05 04:56:19.898	2026-10-05 05:46:01.252
2ef24305-4e90-4735-a95f-07354fae7d7c	warehouse.leadows.conf	active	warehouse.leadows.com	2026-10-05 04:56:19.9	2026-10-05 05:46:01.252
096bb299-9728-4757-b711-0bc0c268aa38	sites-enabled/default.conf	active	(default server), (catch-all, server_name _)	2026-10-05 04:56:19.902	2026-10-05 05:46:01.253
cca9586c-25c3-45ee-b858-1728e25c4e9a	nginx.conf	active	Main config: stream block with MongoDB ports 60007-60009, rate-limit zone php_limit (500 req/s, status 429)	2026-10-05 04:56:19.904	2026-10-05 05:46:01.254
ac6df376-049c-43c0-9bd6-162762c0f6d5	redis_cluster.conf.stream	active	Stream block: Redis ports 7001-7003; includes /etc/nginx/redis_whitelist.conf	2026-10-05 04:56:19.906	2026-10-05 05:46:01.255
7de71acb-7594-44f2-b584-2bdc9f8e46b3	redis_whitelist.conf	active	IP whitelist for the Redis stream ports	2026-10-05 04:56:19.908	2026-10-05 05:46:01.255
9d90b45b-e4ae-49d6-9b20-e3119404cac5	upgrade-map.conf	active	Map definitions (probably sets $jellyfin) - content not captured	2026-10-05 04:56:19.91	2026-10-05 05:46:01.256
362cc122-1b9b-4303-b8d3-f3fbfb0c1c40	leadows.leadowserp.com.conf.bak	backup	Ignored by nginx (extension is not .conf). Safe to archive or delete.	2026-10-05 04:56:19.912	2026-10-05 05:46:01.257
f3a665db-1c89-4f6f-af1f-0193262aa2e2	khabar.mahdibagh.net.conf.bak	backup	Ignored by nginx (extension is not .conf). Safe to archive or delete.	2026-10-05 04:56:19.913	2026-10-05 05:46:01.258
b3a79844-ea69-4afa-ace0-d098041cf976	mahdibagh.org.conf.bak	backup	Ignored by nginx (extension is not .conf). Safe to archive or delete.	2026-10-05 04:56:19.915	2026-10-05 05:46:01.258
e6c1d1fb-77aa-4a0d-b710-38f7e1608428	mahdibagh.org.conf.1.bak	backup	Ignored by nginx (extension is not .conf). Safe to archive or delete.	2026-10-05 04:56:19.917	2026-10-05 05:46:01.259
b09e5482-44a6-4aac-962c-108bb927cd40	redis_cluster.conf.stream.bak	backup	Ignored by nginx (extension is not .conf). Safe to archive or delete.	2026-10-05 04:56:19.919	2026-10-05 05:46:01.26
95d1b6f0-16f0-4ffa-a74d-169e931b21c1	restaurant.leadows.conf.bak	backup	Ignored by nginx (extension is not .conf). Safe to archive or delete.	2026-10-05 04:56:19.921	2026-10-05 05:46:01.261
f3789375-1050-4b00-a6c5-f0d4c2e592c4	restaurant.leadows.conf.save	backup	Ignored by nginx (extension is not .conf). Safe to archive or delete.	2026-10-05 04:56:19.923	2026-10-05 05:46:01.262
092f1c99-5ffd-4859-846b-a696c82b7d61	schoolbus.leadows.com.conf.bak	backup	Ignored by nginx (extension is not .conf). Safe to archive or delete.	2026-10-05 04:56:19.925	2026-10-05 05:46:01.262
919925a1-71af-4419-9821-3a65f415533c	schoolsecurity.uz.conf.bak	backup	Ignored by nginx (extension is not .conf). Safe to archive or delete.	2026-10-05 04:56:19.926	2026-10-05 05:46:01.263
3b135a63-34a1-4159-b8c8-b8ee211030a2	ems-staging.leadows.com.conf.save	backup	Ignored by nginx (extension is not .conf). Safe to archive or delete.	2026-10-05 04:56:19.928	2026-10-05 05:46:01.264
6a8cacef-05c8-4cd9-ab9b-8b8515aff050	abg.leadows.conf	active	abg.leadows.com	2026-10-05 04:56:19.838	2026-10-05 05:46:01.223
\.


--
-- Data for Name: custom_field_values; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.custom_field_values (id, "fieldId", "entityType", "entityId", "valueText", "valueJson", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: custom_fields; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.custom_fields (id, "entityType", name, key, "fieldType", options, required, "defaultValue", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: issues; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.issues (id, "issueNum", priority, title, observed, recommendation, status, "relatedPortId", "relatedRouteId", source, "autoKey", assignee, comments, "resolvedAt", "createdAt", "updatedAt") FROM stdin;
5a68dac7-3d9d-42e7-a417-bd601e8ff00d	2	High	Local port 9000 used twice	restaurant /rag/ -> 127.0.0.1:9000 (Vite) and api.schoolsecurity.uz /api/ -> 127.0.0.1:9000.	Run: sudo ss -tlnp | grep :9000 - confirm which app really owns it and give the other app its own port.	open	\N	\N	imported	imported-issue-2	\N	\N	\N	2026-10-05 04:56:20.345	2026-10-05 05:46:01.464
fd5b3b98-8057-4e8b-b0b7-1eb1d916544f	3	High	Database ports exposed via nginx	Redis (7001-7003) and MongoDB (60007-60009) are published as TCP stream ports.	Confirm firewall / redis_whitelist.conf restricts who can connect. Check that the whitelist covers the Mongo ports too.	open	\N	\N	imported	imported-issue-3	\N	\N	\N	2026-10-05 04:56:20.348	2026-10-05 05:46:01.465
3edb1dda-3697-48ff-b3da-dc6d61ae7bb3	4	Medium	Public plain-HTTP ports	10080, 10081, 10180, 10181 and 28096 have no SSL in nginx.	Confirm TLS is handled elsewhere (e.g. another proxy/CDN) or add SSL if exposed to the internet.	open	\N	\N	imported	imported-issue-4	\N	\N	\N	2026-10-05 04:56:20.351	2026-10-05 05:46:01.466
efb8b922-9b55-4670-8882-e507647114d5	5	Medium	schoolsecurity.uz has no HTTPS block	Port 80 redirects to https://schoolsecurity.uz, but no 443 server for that domain appeared in the output.	Run: sudo nginx -T | grep -n 'schoolsecurity.uz'  to confirm the 443 block exists.	open	\N	\N	imported	imported-issue-5	\N	\N	\N	2026-10-05 04:56:20.353	2026-10-05 05:46:01.468
746e310e-e2fd-4e47-91ff-63de647c17a9	6	Medium	Upstream/variable addresses not captured	Upstreams: publisher, superdesk_client/server/ws/capi, publisher-server, media_proxy, helix_backend, rag_backend, doc_backend, mongo_cluster; variable $jellyfin.	Run: sudo nginx -T 2>/dev/null | grep -E -A6 '^\\s*upstream|^\\s*map ' and send the output so the sheet can be completed.	open	\N	\N	imported	imported-issue-6	\N	\N	\N	2026-10-05 04:56:20.356	2026-10-05 05:46:01.469
bc998a86-8aae-4836-b2b5-9289ef0634a5	7	Medium	Missing target	books.leadows.com /live/project/ target not captured.	Run: sudo grep -A6 '/live/project/' /etc/nginx/conf.d/books.leadows.conf	open	\N	\N	imported	imported-issue-7	\N	\N	\N	2026-10-05 04:56:20.358	2026-10-05 05:46:01.47
aeb12099-d2f4-4d52-8f83-67e5d50658d5	8	Low	Catch-all server_name _ on custom ports	ban (10081) and mm (28096) answer to any host name on those ports.	Acceptable, but any request to server-IP:port reaches the app. Set a real server_name if needed.	open	\N	\N	imported	imported-issue-8	\N	\N	\N	2026-10-05 04:56:20.361	2026-10-05 05:46:01.472
20a07762-58af-4c05-bea3-9652fc441ffd	9	Low	Shared alternate ports	3009, 4000 are shared by several domains.	Works through SNI (name-based). Clients without SNI may get the first server's certificate.	open	\N	\N	imported	imported-issue-9	\N	\N	\N	2026-10-05 04:56:20.363	2026-10-05 05:46:01.473
726ead1a-b9f7-4d42-819b-bcdac3290b8c	10	Low	Placeholder app-store links	ems.leadows.com /app redirects to Airbnb app-store links.	Replace with your real app links when ready.	open	\N	\N	imported	imported-issue-10	\N	\N	\N	2026-10-05 04:56:20.366	2026-10-05 05:46:01.474
35f719c9-6618-4011-9914-57abf7f75b12	11	Low	Backup files in conf.d	10 .bak / .save files exist (see Config Files sheet).	Move to a separate backup folder to avoid confusion.	open	\N	\N	imported	imported-issue-11	\N	\N	\N	2026-10-05 04:56:20.368	2026-10-05 05:46:01.475
e468de88-e72b-4879-bc6b-3885413d4e4a	12	Info	Domains without their own port-80 block	Many HTTPS domains have no HTTP block.	They fall to sites-enabled/default.conf (default_server), which redirects to HTTPS.	open	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	\N	imported	imported-issue-12	\N	\N	\N	2026-10-05 04:56:20.37	2026-10-05 05:46:01.477
bba23a76-acf3-4d23-8edf-baf060e541e7	\N	High	Port 7002 is down / not listening	Port 7002 (TCP / stream) is documented in database but is NOT listening on the host.	Check service status: sudo ss -tlnp | grep :7002 or systemctl status nginx	open	d46d821e-0752-40d3-9408-4fc60b0355c5	\N	auto-detected	auto-port-down-7002	\N	\N	\N	2026-10-05 05:05:03.603	2026-10-05 06:18:56.828
ed8b7ba5-55eb-4e4c-9400-9e3c2ac20ba1	\N	High	Port 7001 is down / not listening	Port 7001 (TCP / stream) is documented in database but is NOT listening on the host.	Check service status: sudo ss -tlnp | grep :7001 or systemctl status nginx	open	534fe14c-dcfa-485a-b48f-bd474a096613	\N	auto-detected	auto-port-down-7001	\N	\N	\N	2026-10-05 05:05:03.62	2026-10-05 06:18:56.836
9d002455-dbd4-4f28-baa3-1b28d525d285	\N	High	Port 4000 is down / not listening	Port 4000 (HTTPS / http) is documented in database but is NOT listening on the host.	Check service status: sudo ss -tlnp | grep :4000 or systemctl status nginx	open	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	\N	auto-detected	auto-port-down-4000	\N	\N	\N	2026-10-05 05:05:03.625	2026-10-05 06:18:56.821
742e420f-3d4f-405a-94ca-846a20245d67	\N	High	Port 10181 is down / not listening	Port 10181 (HTTP / http) is documented in database but is NOT listening on the host.	Check service status: sudo ss -tlnp | grep :10181 or systemctl status nginx	open	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	\N	auto-detected	auto-port-down-10181	\N	\N	\N	2026-10-05 05:05:03.617	2026-10-05 06:18:56.823
187f2381-db0a-4bb1-887e-477d083314b5	\N	High	Port 443 is down / not listening	Port 443 (HTTPS / http) is documented in database but is NOT listening on the host.	Check service status: sudo ss -tlnp | grep :443 or systemctl status nginx	open	b8d9465b-b156-4a71-902d-9846891346a0	\N	auto-detected	auto-port-down-443	\N	\N	\N	2026-10-05 05:05:03.612	2026-10-05 06:18:56.838
2af0649c-ab59-45ad-a7d7-b9522e53ea61	\N	High	Port 28096 is down / not listening	Port 28096 (HTTP / http) is documented in database but is NOT listening on the host.	Check service status: sudo ss -tlnp | grep :28096 or systemctl status nginx	open	42138f4f-65a2-4291-a571-3c7f720d2921	\N	auto-detected	auto-port-down-28096	\N	\N	\N	2026-10-05 05:05:03.623	2026-10-05 06:18:56.827
acd140f2-1aa3-4fad-87f7-b707e0fb4df8	\N	High	Port 10080 is down / not listening	Port 10080 (HTTP / http) is documented in database but is NOT listening on the host.	Check service status: sudo ss -tlnp | grep :10080 or systemctl status nginx	open	11295648-cb50-419e-ae47-ee7a458b63c1	\N	auto-detected	auto-port-down-10080	\N	\N	\N	2026-10-05 05:05:03.628	2026-10-05 06:18:56.829
ee82a6c7-5188-4b64-b587-2cec270ab9d0	1	High	Port 8080 used twice	nginx stub_status listens on 8080, and restaurant.leadows.com /rag/api/ proxies to 127.0.0.1:8080 (RAG backend).	Run: sudo ss -tlnp | grep :8080  - if both are expected, move stub_status to a different port (e.g. 8081).	open	35fb4359-7c66-4d29-b21f-868fa30cf1bb	\N	imported	imported-issue-1	\N	\N	\N	2026-10-05 04:56:20.34	2026-10-05 05:46:01.462
4ac39d0f-e5a1-453f-9ef8-be70a3388fb9	\N	High	Port 10081 is down / not listening	Port 10081 (HTTP / http) is documented in database but is NOT listening on the host.	Check service status: sudo ss -tlnp | grep :10081 or systemctl status nginx	open	c6f3c962-4d9e-4584-baf6-08c9a0847815	\N	auto-detected	auto-port-down-10081	\N	\N	\N	2026-10-05 05:05:03.614	2026-10-05 06:18:56.829
03f7ecca-5444-4593-9a74-c7d8b1b1f952	\N	High	Port 7003 is down / not listening	Port 7003 (TCP / stream) is documented in database but is NOT listening on the host.	Check service status: sudo ss -tlnp | grep :7003 or systemctl status nginx	open	3be57a72-25ab-4961-a7f1-f3973a9319fe	\N	auto-detected	auto-port-down-7003	\N	\N	\N	2026-10-05 05:05:03.609	2026-10-05 06:18:56.83
adb78600-17ed-42cb-afd4-c4de3dd76360	\N	Medium	Undocumented listening port 9335	Port 9335 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :9335 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-9335	\N	\N	\N	2026-10-05 05:05:03.681	2026-10-05 06:18:56.853
9c33b1c9-6655-4b1b-bdfb-4ca6453d3f1c	\N	Medium	Undocumented listening port 6444	Port 6444 is actively listening (127.0.0.1) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :6444 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-6444	\N	\N	\N	2026-10-05 05:05:03.66	2026-10-05 06:18:56.855
196a8bcd-4aa0-43e7-ac36-23bce800aef8	\N	High	Port 60008 is down / not listening	Port 60008 (TCP / stream) is documented in database but is NOT listening on the host.	Check service status: sudo ss -tlnp | grep :60008 or systemctl status nginx	open	b2115ceb-b541-4c57-8c81-e9fc67989260	\N	auto-detected	auto-port-down-60008	\N	\N	\N	2026-10-05 05:05:03.645	2026-10-05 06:18:56.826
d8837ca9-ad9c-4a09-af3f-98a58ca90c9c	\N	Medium	Undocumented listening port 10001	Port 10001 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :10001 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-10001	\N	\N	\N	2026-10-05 05:05:03.658	2026-10-05 06:18:56.857
38451971-e98b-4f1c-a41e-901802037096	\N	Medium	Undocumented listening port 10249	Port 10249 is actively listening (127.0.0.1) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :10249 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-10249	\N	\N	\N	2026-10-05 05:05:03.665	2026-10-05 06:18:56.859
2192f860-1fed-4b46-a4ac-4f2174c14e05	\N	Medium	Undocumented listening port 5432	Port 5432 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :5432 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-5432	\N	\N	\N	2026-10-05 05:05:03.663	2026-10-05 06:18:56.851
7818a39a-267d-4ab4-9012-03f4432f3b8e	\N	High	Port 4020 is down / not listening	Port 4020 (HTTPS / http) is documented in database but is NOT listening on the host.	Check service status: sudo ss -tlnp | grep :4020 or systemctl status nginx	open	b01c4726-e22b-4760-be21-2106c644f07d	\N	auto-detected	auto-port-down-4020	\N	\N	\N	2026-10-05 05:05:03.649	2026-10-05 06:18:56.833
7f7fce5a-7a0d-4179-bb7d-e14d750fcc7f	\N	Medium	Undocumented listening port 53	Port 53 is actively listening (fe80::9899:f7ff:fe95:47d3]%vetha628d28) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :53 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-53	\N	\N	\N	2026-10-05 05:05:03.652	2026-10-05 06:18:56.839
836f18fd-29c3-47fb-ac13-e0be7806f956	\N	Medium	Undocumented listening port 9334	Port 9334 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :9334 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-9334	\N	\N	\N	2026-10-05 05:05:03.679	2026-10-05 06:18:56.854
1070e8dd-9855-4b2a-b3a0-dff8e4722207	\N	High	Port 3009 is down / not listening	Port 3009 (HTTPS / http) is documented in database but is NOT listening on the host.	Check service status: sudo ss -tlnp | grep :3009 or systemctl status nginx	open	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	\N	auto-detected	auto-port-down-3009	\N	\N	\N	2026-10-05 05:05:03.633	2026-10-05 06:18:56.825
8219e097-5382-48a6-a2cb-ccbd0d7d1263	\N	Medium	Undocumented listening port 10257	Port 10257 is actively listening (127.0.0.1) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :10257 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-10257	\N	\N	\N	2026-10-05 05:05:03.675	2026-10-05 06:18:56.861
f2d2ce2b-ae2e-4ac7-a97f-e1021b625d25	\N	Medium	Undocumented listening port 10259	Port 10259 is actively listening (127.0.0.1) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :10259 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-10259	\N	\N	\N	2026-10-05 05:05:03.67	2026-10-05 06:18:56.863
4ab31565-31e7-4230-8223-20f35c0f4803	\N	High	Port 10180 is down / not listening	Port 10180 (HTTP / http) is documented in database but is NOT listening on the host.	Check service status: sudo ss -tlnp | grep :10180 or systemctl status nginx	open	ccbc4c63-b042-48b0-85c1-cddf26463e50	\N	auto-detected	auto-port-down-10180	\N	\N	\N	2026-10-05 05:05:03.64	2026-10-05 06:18:56.837
02b8cdbb-6cd6-4507-8cb5-32fdbf7d67ad	\N	Medium	Undocumented listening port 10256	Port 10256 is actively listening (127.0.0.1) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :10256 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-10256	\N	\N	\N	2026-10-05 05:05:03.677	2026-10-05 06:18:56.86
61ac20b2-1eb5-45ac-9834-60916b5fba64	\N	High	Port 3021 is down / not listening	Port 3021 (HTTPS / http) is documented in database but is NOT listening on the host.	Check service status: sudo ss -tlnp | grep :3021 or systemctl status nginx	open	eb7162c7-530f-4aed-8c96-2b32940e6734	\N	auto-detected	auto-port-down-3021	\N	\N	\N	2026-10-05 05:05:03.638	2026-10-05 06:18:56.835
0fe3b14e-7f0b-4b37-9d60-df6115717d18	\N	High	Port 60007 is down / not listening	Port 60007 (TCP / stream) is documented in database but is NOT listening on the host.	Check service status: sudo ss -tlnp | grep :60007 or systemctl status nginx	open	f8163d47-80ea-44d2-b0ba-ad68c70ec123	\N	auto-detected	auto-port-down-60007	\N	\N	\N	2026-10-05 05:05:03.635	2026-10-05 06:18:56.832
110e27d1-1e61-48b9-9d23-db653146f315	\N	High	Port 60009 is down / not listening	Port 60009 (TCP / stream) is documented in database but is NOT listening on the host.	Check service status: sudo ss -tlnp | grep :60009 or systemctl status nginx	open	96949b28-e145-4028-a00e-af2cc7657073	\N	auto-detected	auto-port-down-60009	\N	\N	\N	2026-10-05 05:05:03.642	2026-10-05 06:18:56.834
cb563d9a-33dd-4e31-ace8-2eca51df49fb	\N	High	Port 3022 is down / not listening	Port 3022 (HTTPS / http) is documented in database but is NOT listening on the host.	Check service status: sudo ss -tlnp | grep :3022 or systemctl status nginx	open	dd1361b7-c5a2-4123-937a-11f62570ad6e	\N	auto-detected	auto-port-down-3022	\N	\N	\N	2026-10-05 05:05:03.647	2026-10-05 06:18:56.831
7649f8bc-6cbd-456c-9110-38ec77a1f686	\N	Medium	Undocumented listening port 10000	Port 10000 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :10000 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-10000	\N	\N	\N	2026-10-05 05:05:03.655	2026-10-05 06:18:56.858
6e99da9c-c965-4b45-a87c-a88cb2e13589	\N	Medium	Undocumented listening port 10248	Port 10248 is actively listening (127.0.0.1) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :10248 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-10248	\N	\N	\N	2026-10-05 05:05:03.668	2026-10-05 06:18:56.858
c3f853c9-388b-4baf-870f-f7dfb9dd2ffe	\N	Medium	Undocumented listening port 631	Port 631 is actively listening (::1) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :631 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-631	\N	\N	\N	2026-10-05 05:05:03.732	2026-10-05 06:18:56.879
39681cff-2f7c-4937-9767-1c461d5592ce	\N	Medium	Undocumented listening port 44401	Port 44401 is actively listening (127.0.0.1) under process 'language_server' (PID: 12846) but is not documented.	Run: sudo ss -tlnp | grep :44401 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-44401	\N	\N	2026-10-05 05:26:48.038	2026-10-05 05:05:03.693	2026-10-05 05:26:48.038
214e493a-4897-42dc-8efb-8b27d84fb481	\N	Medium	Undocumented listening port 3909	Port 3909 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :3909 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-3909	\N	\N	\N	2026-10-05 05:05:03.725	2026-10-05 06:18:56.886
4358be50-0064-47f3-99fc-8ba0ef668cba	\N	Medium	Undocumented listening port 8888	Port 8888 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :8888 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-8888	\N	\N	\N	2026-10-05 05:05:03.688	2026-10-05 06:18:56.848
0d77187e-42aa-4da4-981a-3f6d40ee6690	\N	Medium	Undocumented listening port 40443	Port 40443 is actively listening (127.0.0.1) under process 'antigravity-ide' (PID: 12332) but is not documented.	Run: sudo ss -tlnp | grep :40443 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-40443	\N	\N	2026-10-05 05:26:48.039	2026-10-05 05:05:03.698	2026-10-05 05:26:48.039
03949b79-253f-4c06-996f-01161516f80e	\N	Medium	Undocumented listening port 22	Port 22 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :22 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-22	\N	\N	\N	2026-10-05 05:05:03.705	2026-10-05 06:18:56.843
6e8f7e97-56c7-4cbd-a6d5-1a1efd8a8783	\N	Medium	Undocumented listening port 8333	Port 8333 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :8333 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-8333	\N	\N	\N	2026-10-05 05:05:03.702	2026-10-05 06:18:56.842
e31168af-888b-448e-9fb8-e40b537a64cc	\N	Medium	Undocumented listening port 8889	Port 8889 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :8889 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-8889	\N	\N	\N	2026-10-05 05:05:03.69	2026-10-05 06:18:56.847
400f6c53-cadc-44b1-ab18-a7015421b877	\N	Medium	Undocumented listening port 8334	Port 8334 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :8334 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-8334	\N	\N	\N	2026-10-05 05:05:03.7	2026-10-05 06:18:56.842
7af2b573-9166-4012-b6d8-d73865821996	\N	Medium	Undocumented listening port 36725	Port 36725 is actively listening (127.0.0.1) under process 'language_server' (PID: 14969) but is not documented.	Run: sudo ss -tlnp | grep :36725 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-36725	\N	\N	2026-10-05 05:26:48.036	2026-10-05 05:05:03.686	2026-10-05 05:26:48.037
3d81c285-7d64-44b4-b1be-2bd6acfe6bc4	\N	Medium	Undocumented listening port 8072	Port 8072 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :8072 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-8072	\N	\N	\N	2026-10-05 05:05:03.714	2026-10-05 06:18:56.884
07fa7c20-2b75-4440-9942-5b77b707523b	\N	Medium	Undocumented listening port 8070	Port 8070 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :8070 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-8070	\N	\N	\N	2026-10-05 05:05:03.71	2026-10-05 06:18:56.883
ee43b629-19b6-4586-9693-ed1beeabeecc	\N	Medium	Undocumented listening port 20000	Port 20000 is actively listening (0.0.0.0) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :20000 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-20000	\N	\N	\N	2026-10-05 05:05:03.735	2026-10-05 06:18:56.89
3f660c51-4353-4270-b509-a6dfce3824f7	\N	Medium	Undocumented listening port 3901	Port 3901 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :3901 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-3901	\N	\N	\N	2026-10-05 05:05:03.723	2026-10-05 06:18:56.887
a4ccf396-4100-426d-aa09-a09ce4dc405d	\N	Medium	Undocumented listening port 8071	Port 8071 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :8071 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-8071	\N	\N	\N	2026-10-05 05:05:03.712	2026-10-05 06:18:56.882
7127053d-138e-4091-af0f-46d1d33553f1	\N	Medium	Undocumented listening port 3900	Port 3900 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :3900 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-3900	\N	\N	\N	2026-10-05 05:05:03.719	2026-10-05 06:18:56.888
a66500d4-eb0f-4d73-8c43-fbbc81d7b78a	\N	Medium	Undocumented listening port 8000	Port 8000 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :8000 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-8000	\N	\N	\N	2026-10-05 05:05:03.727	2026-10-05 06:18:56.885
4f0dde19-b2ec-4e52-8806-68017bd4d701	\N	Medium	Undocumented listening port 3903	Port 3903 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :3903 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-3903	\N	\N	\N	2026-10-05 05:05:03.716	2026-10-05 06:18:56.889
c0ee7ab5-84cb-40bc-938b-fcd526e9112d	\N	Medium	Undocumented listening port 33060	Port 33060 is actively listening (0.0.0.0) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :33060 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-33060	\N	\N	\N	2026-10-05 05:05:03.695	2026-10-05 06:18:56.84
a277faca-744e-4cd0-b7cc-f6aaf635553c	\N	Medium	Undocumented listening port 953	Port 953 is actively listening (::1) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :953 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-953	\N	\N	\N	2026-10-05 05:05:03.73	2026-10-05 06:18:56.874
a7b9d195-8ef4-414e-9953-1f870b7d797b	\N	Medium	Undocumented listening port 11434	Port 11434 is actively listening (127.0.0.1) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :11434 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-11434	\N	\N	\N	2026-10-05 05:05:03.707	2026-10-05 06:18:56.849
c1796027-8038-441b-a022-91e55fb50f9b	\N	Medium	Undocumented listening port 57570	Port 57570 is actively listening (127.0.0.1) under process 'antigravity-ide' (PID: 14617) but is not documented.	Run: sudo ss -tlnp | grep :57570 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-57570	\N	\N	2026-10-05 05:26:48.04	2026-10-05 05:05:03.75	2026-10-05 05:26:48.04
69c9e6c0-9e8e-4a07-81fb-9e2b16c5979a	\N	Medium	Undocumented listening port 9614	Port 9614 is actively listening (::ffff:127.0.0.1) under process 'java' (PID: 6256) but is not documented.	Run: sudo ss -tlnp | grep :9614 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-9614	\N	\N	\N	2026-10-05 05:05:03.779	2026-10-05 06:18:56.894
616b4a71-3ebf-42da-ad30-4a4e7e655e57	\N	High	Database port 7002 (Raw TCP proxy (not HTTP)) bound publicly	Database/cache port 7002 is accessible on public interfaces (0.0.0.0).	Confirm firewall or IP whitelist restrictions: sudo ufw status or inspect nginx stream whitelist config.	open	d46d821e-0752-40d3-9408-4fc60b0355c5	\N	auto-detected	auto-db-exposed-7002	\N	\N	\N	2026-10-05 05:05:03.784	2026-10-05 06:18:56.896
c67baa4f-b66e-48fe-b784-31dae30b9d44	\N	Medium	Undocumented listening port 10250	Port 10250 is actively listening (*) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :10250 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-10250	\N	\N	\N	2026-10-05 05:05:03.782	2026-10-05 06:18:56.893
b80109ef-5659-4d9a-8eff-7923609b16e6	\N	Medium	Undocumented listening port 36951	Port 36951 is actively listening (127.0.0.1) under process 'language_server' (PID: 14969) but is not documented.	Run: sudo ss -tlnp | grep :36951 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-36951	\N	\N	2026-10-05 05:26:48.04	2026-10-05 05:05:03.739	2026-10-05 05:26:48.041
d6b8abfa-62a2-4e34-9bb7-97d4ab01e782	\N	Medium	Undocumented listening port 46861	Port 46861 is actively listening (127.0.0.1) under process 'language_server' (PID: 14969) but is not documented.	Run: sudo ss -tlnp | grep :46861 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-46861	\N	\N	2026-10-05 05:26:48.041	2026-10-05 05:05:03.76	2026-10-05 05:26:48.042
8a8a76c2-2025-409f-98db-248a1af5e630	\N	Medium	Undocumented listening port 3305	Port 3305 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :3305 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-3305	\N	\N	\N	2026-10-05 05:05:03.745	2026-10-05 06:18:56.875
9090f980-8654-41f5-ada4-bc3ea2a1a53c	\N	High	Database port 7003 (Raw TCP proxy (not HTTP)) bound publicly	Database/cache port 7003 is accessible on public interfaces (0.0.0.0).	Confirm firewall or IP whitelist restrictions: sudo ufw status or inspect nginx stream whitelist config.	open	3be57a72-25ab-4961-a7f1-f3973a9319fe	\N	auto-detected	auto-db-exposed-7003	\N	\N	\N	2026-10-05 05:05:03.788	2026-10-05 06:18:56.897
aa63cdc4-6b43-48d3-abe1-00b630fd5b23	\N	Medium	Undocumented listening port 3306	Port 3306 is actively listening (0.0.0.0) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :3306 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-3306	\N	\N	\N	2026-10-05 05:05:03.741	2026-10-05 06:18:56.877
51f28620-c14d-4804-88ad-ba017ecd9e4b	\N	Medium	Undocumented listening port 46805	Port 46805 is actively listening (127.0.0.1) under process 'antigravity-ide' (PID: 12332) but is not documented.	Run: sudo ss -tlnp | grep :46805 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-46805	\N	\N	2026-10-05 05:26:48.042	2026-10-05 05:05:03.765	2026-10-05 05:26:48.043
4ea1e489-02ca-4031-bfa7-71e1272ef73f	\N	Medium	Undocumented listening port 46095	Port 46095 is actively listening (127.0.0.1) under process 'language_server' (PID: 12846) but is not documented.	Run: sudo ss -tlnp | grep :46095 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-46095	\N	\N	2026-10-05 05:26:48.043	2026-10-05 05:05:03.768	2026-10-05 05:26:48.044
5108a599-5302-4f79-86b6-d77d4ba803b8	\N	Medium	Undocumented listening port 10010	Port 10010 is actively listening (127.0.0.1) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :10010 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-10010	\N	\N	\N	2026-10-05 05:05:03.762	2026-10-05 06:18:56.864
491f8ffa-dd66-4747-9ae1-b662a2e9bbd1	\N	Medium	Undocumented listening port 3307	Port 3307 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :3307 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-3307	\N	\N	\N	2026-10-05 05:05:03.743	2026-10-05 06:18:56.876
95aeaafe-054f-42c2-bbcf-335e7e98c1b4	\N	Medium	Undocumented listening port 23646	Port 23646 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :23646 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-23646	\N	\N	\N	2026-10-05 05:05:03.753	2026-10-05 06:18:56.88
81fff5e4-b109-4768-b249-71a22af1162b	\N	Medium	Undocumented listening port 14186	Port 14186 is actively listening (::ffff:127.0.0.1) under process 'java' (PID: 6454) but is not documented.	Run: sudo ss -tlnp | grep :14186 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-14186	\N	\N	\N	2026-10-05 05:05:03.772	2026-10-05 06:18:56.891
8bc65767-1b32-41a0-81f0-d4dc0f10512d	\N	Medium	Undocumented listening port 3100	Port 3100 is actively listening (0.0.0.0) under process 'node' (PID: 29943) but is not documented.	Run: sudo ss -tlnp | grep :3100 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-3100	\N	\N	\N	2026-10-05 05:05:03.747	2026-10-05 06:18:56.881
c827e575-a396-4c45-9e5a-4eb64a9a5cb0	\N	Medium	Undocumented listening port 6443	Port 6443 is actively listening (*) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :6443 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-6443	\N	\N	\N	2026-10-05 05:05:03.775	2026-10-05 06:18:56.892
41c0d73a-8c3f-4cf5-b7d6-18ed27ab6db7	\N	High	Database port 7001 (Raw TCP proxy (not HTTP)) bound publicly	Database/cache port 7001 is accessible on public interfaces (0.0.0.0).	Confirm firewall or IP whitelist restrictions: sudo ufw status or inspect nginx stream whitelist config.	open	534fe14c-dcfa-485a-b48f-bd474a096613	\N	auto-detected	auto-db-exposed-7001	\N	\N	\N	2026-10-05 05:05:03.791	2026-10-05 06:18:56.9
0ade0dfb-711f-4949-afd9-2c4ee096e57a	\N	Medium	Undocumented listening port 3000	Port 3000 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :3000 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-3000	\N	\N	\N	2026-10-05 05:05:03.755	2026-10-05 06:18:56.87
84953275-fb25-47c5-ac90-51b74d805626	\N	Medium	Undocumented listening port 3001	Port 3001 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :3001 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-3001	\N	\N	\N	2026-10-05 05:05:03.757	2026-10-05 06:18:56.869
af93f6a8-e96f-4166-bf92-434fe88b3f17	\N	Medium	Public plain-HTTP port 10180 without TLS	Port 10180 serves unencrypted HTTP without SSL configuration in Nginx.	Confirm if TLS termination is handled by an upstream CDN or add SSL certificates.	open	ccbc4c63-b042-48b0-85c1-cddf26463e50	\N	auto-detected	auto-plain-http-10180	\N	\N	\N	2026-10-05 05:05:03.817	2026-10-05 06:18:56.904
7f3b8606-6d72-4b88-84a5-15c6c6dd5457	\N	High	Database port 60009 (Raw TCP proxy (not HTTP)) bound publicly	Database/cache port 60009 is accessible on public interfaces (0.0.0.0).	Confirm firewall or IP whitelist restrictions: sudo ufw status or inspect nginx stream whitelist config.	open	96949b28-e145-4028-a00e-af2cc7657073	\N	auto-detected	auto-db-exposed-60009	\N	\N	\N	2026-10-05 05:05:03.797	2026-10-05 06:18:56.899
cd4ae6ad-fe29-4775-91f6-1e9b1beec14e	\N	High	Database port 60008 (Raw TCP proxy (not HTTP)) bound publicly	Database/cache port 60008 is accessible on public interfaces (0.0.0.0).	Confirm firewall or IP whitelist restrictions: sudo ufw status or inspect nginx stream whitelist config.	open	b2115ceb-b541-4c57-8c81-e9fc67989260	\N	auto-detected	auto-db-exposed-60008	\N	\N	\N	2026-10-05 05:05:03.8	2026-10-05 06:18:56.895
e071a71c-84b5-49f9-921e-b847975bfd70	\N	Medium	Public plain-HTTP port 10181 without TLS	Port 10181 serves unencrypted HTTP without SSL configuration in Nginx.	Confirm if TLS termination is handled by an upstream CDN or add SSL certificates.	open	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	\N	auto-detected	auto-plain-http-10181	\N	\N	\N	2026-10-05 05:05:03.808	2026-10-05 06:18:56.901
887d669b-044a-48f9-b0f8-72dca6f0a80a	\N	High	Local port 9000 mapped to multiple applications	Local backend localhost:9000 is shared across distinct domains: restaurant.leadows.com, api.schoolsecurity.uz.	Run: sudo ss -tlnp | grep :9000 to confirm which app owns it and isolate routes.	open	\N	\N	auto-detected	auto-port-conflict-localhost-9000	\N	\N	\N	2026-10-05 05:05:03.838	2026-10-05 06:18:56.909
ce0a8834-8c72-4a16-8e58-4c220fe13172	\N	High	Port 8080 is down / not listening	Port 8080 (HTTP / http) is documented in database but is NOT listening on the host.	Check service status: sudo ss -tlnp | grep :8080 or systemctl status nginx	open	35fb4359-7c66-4d29-b21f-868fa30cf1bb	\N	auto-detected	auto-port-down-8080	\N	\N	\N	2026-10-05 05:05:03.63	2026-10-05 06:18:56.824
0ac186d5-3cba-406b-8cf8-6bd0744354de	\N	Medium	Undocumented listening port 9333	Port 9333 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :9333 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-9333	\N	\N	\N	2026-10-05 05:05:03.683	2026-10-05 06:18:56.852
65e47762-a47d-44b0-aea9-cfc2e2f53cde	\N	Medium	Undocumented listening port 19443	Port 19443 is actively listening (127.0.0.1) under process 'RemoteDesktopMa' (PID: 7819) but is not documented.	Run: sudo ss -tlnp | grep :19443 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-19443	\N	\N	\N	2026-10-05 05:14:31.929	2026-10-05 06:18:56.852
7a417852-ca49-4105-b814-26fa4cabfac5	\N	Medium	Undocumented listening port 10258	Port 10258 is actively listening (127.0.0.1) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :10258 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-10258	\N	\N	\N	2026-10-05 05:05:03.672	2026-10-05 06:18:56.862
917380f1-f8a6-493b-9c38-00023ae1ce63	\N	Medium	Undocumented listening port 35755	Port 35755 is actively listening (127.0.0.1) under process 'MongoDB Compass' (PID: 33799) but is not documented.	Run: sudo ss -tlnp | grep :35755 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-35755	\N	\N	2026-10-05 05:14:07.659	2026-10-05 05:13:37.512	2026-10-05 05:14:07.66
67d998cb-37c8-4c0a-95aa-0eff64fe214f	\N	Medium	Undocumented listening port 7776	Port 7776 is actively listening (127.0.0.1) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :7776 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-7776	\N	\N	2026-10-05 05:41:11.456	2026-10-05 05:13:37.54	2026-10-05 05:41:11.457
27f749a6-ecfc-42f8-b684-f2bbe7084d14	\N	Medium	Public plain-HTTP port 10081 without TLS	Port 10081 serves unencrypted HTTP without SSL configuration in Nginx.	Confirm if TLS termination is handled by an upstream CDN or add SSL certificates.	open	c6f3c962-4d9e-4584-baf6-08c9a0847815	\N	auto-detected	auto-plain-http-10081	\N	\N	\N	2026-10-05 05:05:03.805	2026-10-05 06:18:56.903
7c2f5afc-2054-4127-9355-600effd13cd3	\N	Medium	Undocumented listening port 45403	Port 45403 is actively listening (127.0.0.1) under process 'antigravity-ide' (PID: 14617) but is not documented.	Run: sudo ss -tlnp | grep :45403 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-45403	\N	\N	2026-10-05 05:26:48.044	2026-10-05 05:05:03.737	2026-10-05 05:26:48.045
4e6e8a41-74ad-4ee7-8d05-a8adff023f5f	\N	Medium	Public plain-HTTP port 28096 without TLS	Port 28096 serves unencrypted HTTP without SSL configuration in Nginx.	Confirm if TLS termination is handled by an upstream CDN or add SSL certificates.	open	42138f4f-65a2-4291-a571-3c7f720d2921	\N	auto-detected	auto-plain-http-28096	\N	\N	\N	2026-10-05 05:05:03.812	2026-10-05 06:18:56.902
1b558c7c-f3af-4bb4-afc0-6a36075f42f5	\N	Medium	Undocumented listening port 8081	Port 8081 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :8081 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-8081	\N	\N	\N	2026-10-05 05:05:31.656	2026-10-05 06:18:56.884
eb5842e2-d477-4a96-888d-9d923a53f7da	\N	Medium	Public plain-HTTP port 10080 without TLS	Port 10080 serves unencrypted HTTP without SSL configuration in Nginx.	Confirm if TLS termination is handled by an upstream CDN or add SSL certificates.	open	11295648-cb50-419e-ae47-ee7a458b63c1	\N	auto-detected	auto-plain-http-10080	\N	\N	\N	2026-10-05 05:05:03.815	2026-10-05 06:18:56.902
62503758-0577-4606-87f9-056ff354d051	\N	Medium	Undocumented listening port 45667	Port 45667 is actively listening (127.0.0.1) under process 'language_server' (PID: 8332) but is not documented.	Run: sudo ss -tlnp | grep :45667 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-45667	\N	\N	2026-10-05 05:41:11.458	2026-10-05 05:26:47.959	2026-10-05 05:41:11.458
2e1bb684-ced4-4d79-a25a-aecdfc2f5ac4	\N	Medium	Undocumented listening port 41813	Port 41813 is actively listening (127.0.0.1) under process 'language_server' (PID: 9151) but is not documented.	Run: sudo ss -tlnp | grep :41813 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-41813	\N	\N	2026-10-05 05:41:11.459	2026-10-05 05:26:47.962	2026-10-05 05:41:11.459
a990fc08-21f9-40b4-9091-5a7524d6d576	\N	Medium	Undocumented listening port 46045	Port 46045 is actively listening (127.0.0.1) under process 'antigravity-ide' (PID: 7848) but is not documented.	Run: sudo ss -tlnp | grep :46045 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-46045	\N	\N	2026-10-05 05:41:11.46	2026-10-05 05:26:47.966	2026-10-05 05:41:11.46
d52d6256-9b01-47dd-be4a-99b982f3e1d7	\N	Medium	Undocumented listening port 46647	Port 46647 is actively listening (127.0.0.1) under process 'language_server' (PID: 8332) but is not documented.	Run: sudo ss -tlnp | grep :46647 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-46647	\N	\N	2026-10-05 05:41:11.461	2026-10-05 05:26:47.971	2026-10-05 05:41:11.461
e52152a6-6e03-4c12-b642-88633c112fd6	\N	Medium	Undocumented listening port 34439	Port 34439 is actively listening (127.0.0.1) under process 'antigravity-ide' (PID: 8382) but is not documented.	Run: sudo ss -tlnp | grep :34439 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-34439	\N	\N	2026-10-05 05:41:11.462	2026-10-05 05:26:47.973	2026-10-05 05:41:11.463
76467313-1c10-4b51-b197-08c94aa5613d	\N	Medium	Undocumented listening port 34125	Port 34125 is actively listening (127.0.0.1) under process 'antigravity-ide' (PID: 7848) but is not documented.	Run: sudo ss -tlnp | grep :34125 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-34125	\N	\N	2026-10-05 05:41:11.463	2026-10-05 05:26:47.978	2026-10-05 05:41:11.464
2b3ea4ad-8e54-4b6b-aca3-9ecbe48bf9d4	\N	Medium	Undocumented listening port 43837	Port 43837 is actively listening (127.0.0.1) under process 'language_server' (PID: 9151) but is not documented.	Run: sudo ss -tlnp | grep :43837 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-43837	\N	\N	2026-10-05 05:41:11.464	2026-10-05 05:26:47.983	2026-10-05 05:41:11.464
d1874444-157f-46f8-9b24-c438b636b3e0	\N	Medium	Undocumented listening port 43907	Port 43907 is actively listening (127.0.0.1) under process 'language_server' (PID: 9151) but is not documented.	Run: sudo ss -tlnp | grep :43907 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-43907	\N	\N	2026-10-05 05:41:11.465	2026-10-05 05:26:47.987	2026-10-05 05:41:11.465
65dac121-f6da-4390-b27d-125b68962ed6	\N	Medium	Undocumented listening port 43435	Port 43435 is actively listening (127.0.0.1) under process 'antigravity-ide' (PID: 8382) but is not documented.	Run: sudo ss -tlnp | grep :43435 to identify the application and document or close it.	resolved	\N	\N	auto-detected	auto-port-undocumented-43435	\N	\N	2026-10-05 05:41:11.466	2026-10-05 05:26:48.005	2026-10-05 05:41:11.466
915c6282-c9f1-4d98-97a2-772a999e7f66	\N	Medium	Undocumented listening port 5000	Port 5000 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :5000 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-5000	\N	\N	\N	2026-10-05 05:53:27.679	2026-10-05 06:18:56.845
99349f6a-80b5-41f7-822c-01e72e6d5b75	\N	Medium	Undocumented listening port 44459	Port 44459 is actively listening (127.0.0.1) under process 'language_server' (PID: 11940) but is not documented.	Run: sudo ss -tlnp | grep :44459 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-44459	\N	\N	\N	2026-10-05 05:41:11.377	2026-10-05 06:18:56.846
2438580b-b1e1-4f0a-9956-cea482f67e1b	\N	Medium	Undocumented listening port 35771	Port 35771 is actively listening (127.0.0.1) under process 'antigravity-ide' (PID: 11258) but is not documented.	Run: sudo ss -tlnp | grep :35771 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-35771	\N	\N	\N	2026-10-05 05:41:11.382	2026-10-05 06:18:56.85
d4fcb0d2-af2f-440c-a203-c8dc13268cbb	\N	Medium	Undocumented listening port 35037	Port 35037 is actively listening (127.0.0.1) under process 'antigravity-ide' (PID: 10730) but is not documented.	Run: sudo ss -tlnp | grep :35037 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-35037	\N	\N	\N	2026-10-05 05:41:11.398	2026-10-05 06:18:56.864
6bd8e637-1943-4b9a-901c-539b76907720	\N	Medium	Undocumented listening port 42561	Port 42561 is actively listening (127.0.0.1) under process 'antigravity-ide' (PID: 11258) but is not documented.	Run: sudo ss -tlnp | grep :42561 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-42561	\N	\N	\N	2026-10-05 05:41:11.402	2026-10-05 06:18:56.868
6961a453-e935-4e02-8f1b-65753a770061	\N	Medium	Undocumented listening port 33817	Port 33817 is actively listening (127.0.0.1) under process 'language_server' (PID: 11940) but is not documented.	Run: sudo ss -tlnp | grep :33817 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-33817	\N	\N	\N	2026-10-05 05:41:11.408	2026-10-05 06:18:56.873
972a4db8-3bc3-4412-852b-fa4260dcf1e1	\N	Medium	Undocumented listening port 37907	Port 37907 is actively listening (127.0.0.1) under process 'antigravity-ide' (PID: 10730) but is not documented.	Run: sudo ss -tlnp | grep :37907 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-37907	\N	\N	\N	2026-10-05 05:41:11.409	2026-10-05 06:18:56.873
db4bb31f-e2e9-4a12-9846-bedb5f1d0f83	\N	Medium	Undocumented listening port 37467	Port 37467 is actively listening (127.0.0.1) under process 'language_server' (PID: 11211) but is not documented.	Run: sudo ss -tlnp | grep :37467 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-37467	\N	\N	\N	2026-10-05 05:41:11.415	2026-10-05 06:18:56.878
59baf041-d7f4-4a26-9b71-da66921345bf	\N	Medium	Undocumented listening port 5001	Port 5001 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :5001 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-5001	\N	\N	\N	2026-10-05 05:53:27.677	2026-10-05 06:18:56.844
21ca7f9a-2de6-4dfb-9e60-b09883cd50fd	\N	Medium	Undocumented listening port 5173	Port 5173 is actively listening (*) under process 'node' (PID: 29925) but is not documented.	Run: sudo ss -tlnp | grep :5173 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-5173	\N	\N	\N	2026-10-05 05:26:48.01	2026-10-05 06:18:56.89
775677fc-5b0c-4843-9d3c-9a6f1007dd5f	\N	Medium	Undocumented listening port 35161	Port 35161 is actively listening (127.0.0.1) under process 'language_server' (PID: 11211) but is not documented.	Run: sudo ss -tlnp | grep :35161 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-35161	\N	\N	\N	2026-10-05 05:41:11.389	2026-10-05 06:18:56.856
798a6a6e-b6f1-44b9-8347-dbcbc01ec684	\N	Medium	Undocumented listening port 38765	Port 38765 is actively listening (127.0.0.1) under process 'language_server' (PID: 11940) but is not documented.	Run: sudo ss -tlnp | grep :38765 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-38765	\N	\N	\N	2026-10-05 05:41:11.401	2026-10-05 06:18:56.865
736097b2-5c78-49c9-af91-2dfb5522b1c6	\N	Medium	Undocumented listening port 2379	Port 2379 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :2379 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-2379	\N	\N	\N	2026-10-05 05:53:27.702	2026-10-05 06:18:56.866
68fc9f8c-b405-4441-94b6-c27ed51a1b15	\N	High	Database port 60007 (Raw TCP proxy (not HTTP)) bound publicly	Database/cache port 60007 is accessible on public interfaces (0.0.0.0).	Confirm firewall or IP whitelist restrictions: sudo ufw status or inspect nginx stream whitelist config.	open	f8163d47-80ea-44d2-b0ba-ad68c70ec123	\N	auto-detected	auto-db-exposed-60007	\N	\N	\N	2026-10-05 05:05:03.794	2026-10-05 06:18:56.898
ba277d01-d400-420a-a337-749690f8a84b	\N	Medium	Undocumented listening port 6432	Port 6432 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :6432 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-6432	\N	\N	\N	2026-10-05 05:53:27.703	2026-10-05 06:18:56.867
905bea43-a756-4fea-867d-6429a16b0a46	\N	Medium	Undocumented listening port 7000	Port 7000 is actively listening (::) under process 'unknown' (PID: ?) but is not documented.	Run: sudo ss -tlnp | grep :7000 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-7000	\N	\N	\N	2026-10-05 05:53:27.707	2026-10-05 06:18:56.871
a501360c-4e16-48d1-9d75-39b8087f1446	\N	Medium	Undocumented listening port 34211	Port 34211 is actively listening (127.0.0.1) under process 'python3' (PID: 33601) but is not documented.	Run: sudo ss -tlnp | grep :34211 to identify the application and document or close it.	open	\N	\N	auto-detected	auto-port-undocumented-34211	\N	\N	\N	2026-10-05 05:58:55.783	2026-10-05 06:18:56.872
\.


--
-- Data for Name: port_checks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.port_checks (id, "targetType", "targetId", "targetName", "checkedAt", status, "latencyMs", error, "checkType") FROM stdin;
4013e2ce-6d7f-4195-b403-a64b141c0347	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:26:38.828	down	17	\N	tcp
a19640ee-2fec-4fd2-9df5-2e7c5f7f90da	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:26:38.829	down	17	\N	tcp
d86036c6-2b5f-44f1-abf0-ec912b8c6e5d	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:26:38.865	down	3	connect ECONNREFUSED 127.0.0.1:6875	tcp
2c55e638-3622-4819-909a-903c46afb27e	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:26:41.858	down	3000	TCP connection timed out after 3000ms	tcp
9d8821f5-fbbc-4181-8d00-f7405cd436fc	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:26:41.863	down	3001	TCP connection timed out after 3000ms	tcp
ab1c4cdc-44ca-43b8-88e9-ab2fa92e1c75	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:26:41.872	down	3004	TCP connection timed out after 3000ms	tcp
a612ecec-55db-46e4-82fa-5ffb80f780c6	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:47:09.143	down	3	\N	tcp
7c7be74d-7e48-4da2-bc52-69f07881c197	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:47:09.148	up	7	\N	tcp
f43b9998-4b7e-4304-ab69-51a5683ff71a	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:47:09.144	down	3	\N	tcp
198fb3e5-5669-4815-8771-ac388f383956	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:47:09.145	down	4	\N	tcp
5c927b20-b39a-4c76-959a-1d67c6de4ec6	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:47:09.176	up	7	\N	tcp
7a0c46b7-c92a-4758-94b2-8c74768d2ddf	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:47:09.181	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
f82db339-1903-4bcb-8b60-fffbc0ec693b	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:01:51.78	down	2	\N	tcp
7196dead-1de2-4a69-ba81-4ac1101ebcb6	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:01:51.781	down	3	\N	tcp
3e44afc7-6a4f-454f-a946-fad2421cb0f9	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:01:51.79	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
15d95cc2-5e60-480b-b223-1722c1632550	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:01:51.803	up	15	\N	tcp
dc551603-ee1e-408d-8f56-20c1b42a81be	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:02:21.827	down	4	\N	tcp
821f0828-6063-4029-9728-d82917a2cd6d	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:05:00.125	down	7	\N	tcp
e0704402-5257-4d43-8c78-a5e41d0d17a8	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:05:00.134	up	14	\N	tcp
c73a2b1c-b7ec-43ea-81d9-a686e35d08fa	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:05:00.131	down	11	\N	tcp
221181b8-960d-4be0-af9b-cd8d16c6b499	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:05:00.137	down	16	\N	tcp
0cd11a62-107c-4953-bedc-99be75f808d2	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:05:00.138	down	16	\N	tcp
c51d6b5c-e3a8-4488-9e24-fc409453d155	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:05:00.137	down	16	\N	tcp
0742ac4b-7be8-4bc4-b27e-115f7706b467	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:05:00.133	down	12	\N	tcp
8f097a44-c811-4f28-8ac1-8971a20a69d7	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:05:00.129	down	9	\N	tcp
1e6cf329-3c25-4021-ba97-cae297e72ede	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:05:00.138	down	17	\N	tcp
5ffc0fe3-7b14-40a4-9c5d-800d04ad91b1	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:05:00.127	down	8	\N	tcp
1d308153-5503-4de7-a98e-89c5967098ae	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:05:00.128	up	8	\N	tcp
efb58222-44eb-4be6-8f72-19cb614ae547	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:05:00.129	down	9	\N	tcp
a93b663c-3354-4e9d-bf9e-f1ec44fbc61e	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:05:00.135	down	14	\N	tcp
e8b0cf10-3af7-46d8-b454-754493f3c9e6	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:05:00.136	down	15	\N	tcp
9b77c2d7-4cc1-4d30-93a2-542d4c4bd61b	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:05:00.136	down	15	\N	tcp
cc02a1aa-2607-41d1-a8b3-c942b1e115f8	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:05:00.132	down	12	\N	tcp
4a5372e0-7450-4123-83bf-17561177c100	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:05:00.134	down	13	\N	tcp
ef0c13da-f0e8-40d6-8384-e6478d4540e2	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:05:00.136	down	15	\N	tcp
dd87bdac-74fc-4cf3-823f-28c1f64af915	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:05:00.137	down	16	\N	tcp
f861eee8-4dcc-4382-8be8-addf4b5e76bb	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:05:00.199	up	6	\N	tcp
5eb0647f-b95c-4fb0-87bd-69009bd52507	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:05:00.2	down	7	connect ECONNREFUSED 127.0.0.1:8020	tcp
0c8c332f-444f-49e0-b438-f16a45dbf20b	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:05:00.2	down	7	connect ECONNREFUSED 127.0.0.1:6875	tcp
fab3729d-999b-4850-a7fe-9c3fb4522f14	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:05:00.201	down	8	connect ECONNREFUSED 127.0.0.1:8078	tcp
0187b9e9-ec54-4932-a806-930e027ebecc	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:05:00.201	down	8	connect ECONNREFUSED 127.0.0.1:8080	tcp
a45e010e-83a8-42b4-b167-466cf4e979c9	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:05:00.202	down	8	connect ECONNREFUSED 127.0.0.1:8555	tcp
1c4c7054-673b-4e82-851c-a25db237ae91	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:05:00.206	up	10	\N	tcp
97735c31-805a-4a88-a45e-c8e83eaa11bf	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:05:00.204	down	10	connect ECONNREFUSED 127.0.0.1:9020	tcp
964daf11-77ab-4245-a0c1-51e2b91d12ca	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:05:00.198	down	5	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
62156f17-000c-4e7d-bb05-b114c4f5d3fc	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:05:00.202	down	8	connect ECONNREFUSED 127.0.0.1:8088	tcp
7ad243e2-0a28-4c98-a576-6ddb5402bec4	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:05:00.206	up	10	\N	tcp
328e3841-2586-45cc-b83c-ba27ee2416ec	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:05:00.217	up	5	\N	tcp
85783e16-66e1-4712-aa46-51cd8cc755df	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:05:00.221	down	6	connect ECONNREFUSED 10.0.0.200:3100	tcp
fb7d2d20-75ca-4050-90bc-8db57556acc0	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:05:03.216	down	3000	TCP connection timed out after 3000ms	tcp
aadb7767-1ff8-4d86-adbb-d74f867b4fdc	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:05:03.219	down	3000	TCP connection timed out after 3000ms	tcp
be3c413e-a280-4551-afc5-06b21a32f3f2	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:05:28.043	down	4	\N	tcp
d716f498-d556-4f66-831b-416d54de07bc	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:05:28.046	down	6	\N	tcp
70ae63d8-adf4-4f1f-a732-ad66a3fc0f3d	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:05:28.048	up	8	\N	tcp
f3e98e71-5c75-4a13-8f0b-f90b2dce75c8	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:05:28.064	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
f93fd6d1-0979-41cd-b329-4aa92f2977bd	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:05:28.086	up	25	\N	tcp
07068ee4-e36e-4a11-bdf7-4bb9a43eea0f	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:05:28.087	up	26	\N	tcp
6461ad5a-bad8-4258-b146-83b272568082	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:05:31.072	down	3000	TCP connection timed out after 3000ms	tcp
61bb4a4a-6272-4dd4-a4a4-8cb14307d5b3	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:05:58.064	down	4	\N	tcp
55ad36b3-126a-4740-a2ca-dd4fd8f7cc0f	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:05:58.067	down	7	\N	tcp
65f3140a-c400-46a4-bd3a-3024330a8394	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:05:58.084	down	4	connect ECONNREFUSED 127.0.0.1:8555	tcp
42bf2742-ad92-4e14-a0a4-0f6c87730b82	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:05:58.233	up	152	\N	tcp
01629071-f5f7-4256-a615-60d054ef198f	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:05:58.235	up	154	\N	tcp
47dc1ee9-80a6-4314-a4f9-d3186db7958f	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:06:01.09	down	3001	TCP connection timed out after 3000ms	tcp
2e284814-cced-4f8f-95a1-5ab66d67bc85	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:06:01.092	down	3001	TCP connection timed out after 3000ms	tcp
ee1508b5-bb88-49f2-ae53-78971f16a0c7	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:26:38.819	down	12	\N	tcp
2ff8bed9-8fc6-40a8-b44d-bc7c9ee9bc2c	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:26:38.829	down	17	\N	tcp
55f21430-fc50-45ef-9997-a3737b198391	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:26:41.873	down	3004	TCP connection timed out after 3000ms	tcp
5679e91e-8186-4329-a09b-d32ddb12fbc6	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:47:09.148	down	6	\N	tcp
039db5ee-695c-45ba-bacc-f0333174a9b0	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:47:09.144	down	4	\N	tcp
ff92be5f-6e0b-4a18-88f5-342773689bb1	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:47:09.146	down	4	\N	tcp
114a46d9-d00f-404b-921a-3fa17deb1e1b	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:47:09.147	down	5	\N	tcp
81f3a2f6-9ed6-48b6-85c4-94006b960285	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:47:09.175	up	7	\N	tcp
43ec7810-aa2f-4a36-8432-e5653f0e8aa2	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:01:51.78	down	2	\N	tcp
4adc5d0d-8f8d-42df-b7e4-704d76de1aaa	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:01:51.781	down	3	\N	tcp
e09c6766-f9cf-4c9a-8ad4-8bcfb98fdf2e	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:01:51.804	up	15	\N	tcp
3f0341ed-37cd-4080-a590-4cbd15fd3323	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:02:21.825	down	2	\N	tcp
b024e3d2-c0f7-4b3c-a71b-631bf308652d	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:02:21.828	down	5	\N	tcp
ec9a88c6-dc96-45af-b81e-03715539f262	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:02:21.876	up	34	\N	tcp
26e2c7e0-1d46-4c5f-94da-305e82d54714	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:02:24.836	down	3000	TCP connection timed out after 3000ms	tcp
dcd70833-328c-4c49-8648-07801ed39c82	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:02:51.803	down	3	\N	tcp
68a244d5-1254-4d4d-95a4-c7e2a2573c09	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:02:51.825	up	7	\N	tcp
9e5c62ae-5ae3-4b3e-83a5-7e0b57896695	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:03:21.804	down	3	\N	tcp
8079a7eb-c458-4b8b-850f-c0f95fc9474f	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:03:21.806	down	5	\N	tcp
3f188a3d-e07b-4e6e-b523-2edd8b429620	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:03:21.815	up	3	\N	tcp
4309a019-5593-466b-a337-8a0158d825fb	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:03:21.823	up	10	\N	tcp
38368824-ba80-4336-9875-3a86e59072a6	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:03:51.809	down	2	\N	tcp
4880894e-9edc-4e91-8888-77f3a285cbc4	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:03:51.808	down	1	\N	tcp
8da1c1a7-53ea-461f-a671-7a4ec289f589	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:03:51.812	down	5	\N	tcp
8c0f3135-17aa-4093-959d-ccd28eba6ff7	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:03:51.809	down	2	\N	tcp
981cfeed-6454-4b80-a9d3-564dd7f50095	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:03:52.076	up	235	\N	tcp
0255c396-8428-4f7c-9f7c-ef98cc19108b	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:03:54.841	down	3000	TCP connection timed out after 3000ms	tcp
d78cc2cd-4c5f-438e-bfba-fede2db594ca	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:05:00.217	up	5	\N	tcp
14fa7ee3-f48e-48c4-a064-ac3f649b758c	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:05:03.217	down	3000	TCP connection timed out after 3000ms	tcp
5507ddf1-dc00-4e4a-8081-3b64269e4e2c	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:05:03.22	down	3001	TCP connection timed out after 3000ms	tcp
b031ec15-98ba-4831-9d9a-a384ba9fa4ec	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:05:28.044	up	4	\N	tcp
3bbbd2ba-a40d-41fd-9b9e-9471a27c12f9	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:05:28.045	down	6	\N	tcp
2a1a883c-41af-4e3c-961d-a4539e1863e8	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:05:28.048	down	8	\N	tcp
493fc315-f7e8-4266-ad2c-3a789659c05b	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:05:28.064	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
e56e5015-9ddb-4291-b294-93ae54f99fd1	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:05:28.086	up	24	\N	tcp
bff9681b-6a8b-4e55-b3b3-2e78256909fd	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:05:28.088	up	26	\N	tcp
6505a957-ee80-40e7-8365-cafbc7f8d8df	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:05:31.07	down	3000	TCP connection timed out after 3000ms	tcp
ec2ba7fd-85d4-4c1b-95c5-666cdffffbaf	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:05:58.064	down	3	\N	tcp
87f23277-e96e-46b8-8233-b87d39d52058	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:05:58.067	down	6	\N	tcp
9cef74a1-5037-48c2-80e0-98b0a28c7d09	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:05:58.085	up	4	\N	tcp
a9be377c-70a6-4179-b3b6-8fec9ce26ff8	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:05:58.09	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
28149ab7-58b6-436e-be96-f17b6b74383a	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:05:58.232	up	151	\N	tcp
06a6236b-dc9d-4ab3-a710-39b446f3403f	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:05:58.234	up	153	\N	tcp
931f3a42-f6fb-433c-9557-f00bb609e3d1	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:06:01.09	down	3001	TCP connection timed out after 3000ms	tcp
dbccaf8f-b58c-414d-9b17-ebacd171f4c3	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:10:28.199	down	6	\N	tcp
59a589c8-d7e1-4298-8dc5-ae2779ac2ed0	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:10:28.199	up	7	\N	tcp
fd220384-1ff1-4dfe-bf80-8c81d95f6d3a	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:10:28.243	down	5	connect ECONNREFUSED 127.0.0.1:4100	tcp
baaa91a4-04c2-48df-9096-87171b5cee0e	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:10:28.269	up	31	\N	tcp
2f2fc86e-044e-4c2e-89b9-c6e8e035afdc	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:10:28.27	up	21	\N	tcp
8a72f288-0ee8-4d49-a999-d90d39729dad	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:10:31.238	down	3000	TCP connection timed out after 3000ms	tcp
011ac957-588b-4a93-ad4b-76dd8090f734	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:10:58.206	down	3	\N	tcp
c0ac5242-2e35-47b9-a3cf-ea228d0f6c2b	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:10:58.209	down	6	\N	tcp
3f348d82-77bc-4b12-9fe9-cd555625ef47	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:10:58.227	up	6	\N	tcp
c30bef7d-ca6c-474b-99b1-aefb284343c8	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:10:58.23	up	8	\N	tcp
2e3503b9-d29e-410b-be4c-59ec81c81884	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:10:58.237	down	6	connect ECONNREFUSED 127.0.0.1:4100	tcp
0406710b-c811-4354-90c5-1acc282b3366	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:10:58.239	down	3	connect ECONNREFUSED 127.0.0.1:9020	tcp
02668b26-8486-42be-a7e4-23c5dc4149ca	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:11:01.222	down	3000	TCP connection timed out after 3000ms	tcp
50a624d5-19e6-4d3b-ad88-89c37a276ca6	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:11:28.23	down	3	\N	tcp
a8ad94fc-4ea5-4316-b66c-e86b23349f7a	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:11:28.235	down	7	\N	tcp
fbd3bb22-3773-4a88-8688-264a5a14a453	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:11:28.247	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
ae569631-313c-48a8-838c-b143e8c6b85f	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:11:28.252	up	7	\N	tcp
939d0353-875b-4662-ab1b-9ae5137b56e4	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:11:28.26	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
8fd1fa95-ac3e-4686-a2ac-3f1dd3034bdd	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:11:28.262	up	7	\N	tcp
747c2243-bc7b-458b-a0a8-721ad3212fd6	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:11:31.245	down	2987	connect EHOSTUNREACH 192.168.1.222:8080	tcp
ba97dcf9-4cd4-49ec-8931-d59b9ee7f4a3	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:11:31.255	down	3001	TCP connection timed out after 3000ms	tcp
311b85e8-0b14-46fc-838a-d1e494f16f70	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:11:58.259	down	5	\N	tcp
ef7b9690-df81-461d-b532-b7f7048c6445	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:11:58.262	down	7	\N	tcp
74e95f43-8fb7-4bea-b41b-88d853031ce4	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:11:58.363	up	90	\N	tcp
926e3824-6c79-443d-8756-a1a8b76734e0	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:11:58.365	up	92	\N	tcp
6e1c8ac2-9361-4535-ad58-689725e6c94e	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:12:01.272	down	3000	TCP connection timed out after 3000ms	tcp
d10e3eda-5e44-411c-b63a-1b911d55ad45	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:26:38.827	down	15	\N	tcp
2ed0cab1-4b0a-4808-9cf9-329706d973ca	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:26:38.829	down	17	\N	tcp
ee21c6b6-9ffd-4511-8796-52c21a7a87aa	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:05:00.217	up	5	\N	tcp
53b0963b-dc44-4d0a-a2aa-b16820a671a0	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:05:00.221	up	6	\N	tcp
84a28c24-8d54-4a00-96fc-02e49cb40da4	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:05:03.218	down	3000	TCP connection timed out after 3000ms	tcp
4cde05da-7d44-44bf-91b0-efafe6fcf1f2	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:05:58.063	down	3	\N	tcp
ba948e34-344e-4f7c-a897-823b9854758b	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:05:58.068	down	7	\N	tcp
72e9262c-3de7-4251-892b-aeb6a27a5187	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:05:58.084	down	4	connect ECONNREFUSED 127.0.0.1:8556	tcp
95518ef8-4caf-4863-8ff7-61fb678ba464	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:05:58.09	down	2	connect ECONNREFUSED 127.0.0.1:7000	tcp
890b07fb-46f3-4273-81d8-20007f77b456	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:10:28.197	down	5	\N	tcp
535342fa-f190-4855-b746-7e302e45dfaa	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:10:28.242	down	4	connect ECONNREFUSED 127.0.0.1:7000	tcp
370754c1-bcce-48a5-bb43-54c419ce34e9	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:10:28.267	up	29	\N	tcp
f39a8fb8-2d61-4fea-9573-3305fc09d5a7	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:10:28.269	up	21	\N	tcp
fa92b879-d149-44e8-87a7-0fd87d1674c8	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:10:31.238	down	3000	TCP connection timed out after 3000ms	tcp
ad3ef414-7aff-4f7f-b9b6-af3eb42bfb57	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:10:58.207	down	5	\N	tcp
ceccd9d9-b060-469d-9273-3c66fab572da	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:10:58.212	up	9	\N	tcp
455e28c9-32aa-4699-ba32-94871833ca23	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:10:58.224	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
d0f04a28-1de6-4300-ae81-05ef9da2f85d	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:10:58.226	up	5	\N	tcp
04931a6b-6546-438c-8cf7-2ec75331186a	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:10:58.229	up	8	\N	tcp
82f65735-f0f6-4b9c-bfc7-0120ece0db41	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:10:58.238	up	3	\N	tcp
7c49e60d-cd99-45a5-bedb-179c7e0b888d	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:11:01.221	down	3000	connect EHOSTUNREACH 192.168.1.222:82	tcp
6091c035-4efa-45ba-a21f-b97d9e1a1112	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:11:28.234	down	6	\N	tcp
ce63e6b2-dcee-49a1-be9c-591dd7de6aa8	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:11:28.237	down	8	\N	tcp
40ae7d2d-ed6f-46c1-9da7-52d33959911b	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:11:28.248	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
3c0272c3-62a9-4db9-88e2-de69a246e401	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:11:28.25	up	4	\N	tcp
9ef47836-7cf8-4693-aaeb-44e735d0adf7	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:11:28.26	down	2	connect ECONNREFUSED 127.0.0.1:8078	tcp
2b215928-72e7-4060-8683-eb400f3c3fc4	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:11:31.244	down	2990	connect EHOSTUNREACH 192.168.1.222:82	tcp
16198fe5-9bfe-4b72-b604-93df03592956	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:11:31.256	down	3001	TCP connection timed out after 3000ms	tcp
3164a508-8946-4954-a006-2b27f39c8e5a	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:11:58.261	down	7	\N	tcp
42528fc8-d0f5-4c81-8d7d-76d8ad7ae203	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:11:58.364	up	91	\N	tcp
0ae9d129-d625-44fa-a423-e5cfc11e848d	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:26:38.822	down	11	\N	tcp
36d2abbe-0c21-47d7-a437-0bc6c69e77a2	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:26:38.825	down	14	\N	tcp
723eb14d-5fb6-4af7-8204-79b1cbec599a	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:26:38.865	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
79ea0985-1a08-4145-b719-2d9e7df0324a	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:26:41.859	down	3000	TCP connection timed out after 3000ms	tcp
89050e5e-aeb6-46b5-8877-2446a67adc94	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:26:41.864	down	3001	TCP connection timed out after 3000ms	tcp
3152940d-eabc-43b6-82c8-6f5e5a115821	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:26:41.868	down	3000	TCP connection timed out after 3000ms	tcp
89adf310-1eeb-4009-8d24-acf808b79374	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:26:41.873	down	3004	TCP connection timed out after 3000ms	tcp
10e2f358-24a6-4a3d-bc22-9c6ec4ed74de	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:47:09.148	up	6	\N	tcp
f8b3da8a-2497-4108-ad98-be749ec0ad80	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:47:09.149	down	7	\N	tcp
480bf40e-6250-42bf-8ca8-c395fc43ad6b	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:47:09.147	down	5	\N	tcp
178d2bec-7b68-45c4-bf8b-e18319136afe	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:01:51.781	down	2	\N	tcp
7ac52185-688d-4b5a-b230-a8bf54f06d05	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:01:51.782	down	4	\N	tcp
96c45002-0c6a-4a93-825f-d05cdd6f6fa0	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:01:51.804	up	15	\N	tcp
c6a6a8a1-df43-46a6-a2a6-cd8ab9330a4e	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:02:21.825	down	3	\N	tcp
3375b639-34a8-4dbe-8d0d-3f06fae5498f	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:02:51.804	down	3	\N	tcp
773a905a-eada-45ed-9fb4-f7577b9273c7	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:02:51.816	down	3	connect ECONNREFUSED 127.0.0.1:8080	tcp
ae2eccf1-e0f7-479d-9aee-cb86062ae60a	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:02:51.819	down	1	connect ECONNREFUSED 127.0.0.1:8088	tcp
542414fc-2726-44fe-8819-2ed2719d00f4	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:06:28.063	down	2	\N	tcp
5f54dd5d-6eac-481d-a628-37d63b3cc22d	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:06:28.066	down	5	\N	tcp
231d89ff-b03f-482d-bf20-09e1a5899193	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:06:28.108	up	27	\N	tcp
ff2afde8-acd7-414f-a78a-62df7239464a	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:06:58.09	down	5	\N	tcp
76172caa-617e-4d15-a493-33c25c5bb2b5	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:06:58.093	down	8	\N	tcp
6c5f0c4a-9e65-42e8-bb98-e1d2bd2ae675	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:06:58.095	down	9	\N	tcp
88dd57c0-b373-4cf3-80b3-ceef123a77c1	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:06:58.106	down	3	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
e8f72cd7-21a6-43e8-b010-9912895880bd	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:06:58.11	down	1	connect ECONNREFUSED 127.0.0.1:8020	tcp
870a5999-29ac-49e6-8d36-1522ef652892	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:06:58.116	up	13	\N	tcp
d4157aee-0784-4a98-b6b9-1674cf0058b1	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:06:58.124	down	3	connect ECONNREFUSED 127.0.0.1:8078	tcp
7f47967e-cd75-475b-94ce-ef8d1b6dc74d	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:07:01.105	down	3001	TCP connection timed out after 3000ms	tcp
21015ff2-67e7-4a19-9882-485d3d6a9cf9	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:10:28.2	down	8	\N	tcp
304487a3-ff8d-4b45-a35b-1c77d4689edd	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:10:28.243	down	4	connect ECONNREFUSED 127.0.0.1:8555	tcp
0ef58e56-f04e-4d32-aedb-733ba56e6ce9	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:10:28.266	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
359f2dbc-4882-4d24-8ff4-47aaa80b9606	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:10:28.27	down	22	connect ECONNREFUSED 10.0.0.200:3100	tcp
cf7c3839-6229-440f-98de-50ea0c0927fa	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:10:58.205	down	2	\N	tcp
f1af54e8-7bdb-44f6-86f6-a9426117ccce	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:10:58.211	up	8	\N	tcp
2c9cef3a-d71f-497a-a6ac-2513ffd72269	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:10:58.229	up	7	\N	tcp
695a013a-5232-4839-abed-41f027fcb5db	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:10:58.237	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
11e2b108-1a65-4e61-9b52-582496877f22	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:11:28.233	down	5	\N	tcp
f16962a4-e6fd-45c8-ae96-d1ffe7907542	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:11:28.248	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
b2b6f29f-81f2-4e80-a8c9-68dfbff8da3e	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:11:28.249	down	4	connect ECONNREFUSED 127.0.0.1:8088	tcp
044e19cc-fb45-4496-a140-0c67b348b255	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:11:28.253	up	8	\N	tcp
3232c4c2-225d-4d16-9ebc-e54ef08ddadd	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:11:28.26	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
cd539ace-e86b-4021-9311-2df121066cbd	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:11:58.259	up	4	\N	tcp
7213faf3-d42e-4412-89f1-e00abd3490ff	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:11:58.263	down	9	\N	tcp
b8bb87d5-fb8e-404b-813f-afeeb402fdca	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:11:58.274	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
56da78e9-75ee-43f3-af88-f45fce1ea0e6	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:11:58.276	up	3	\N	tcp
1d10e3ac-c6f2-4a65-a3c1-745ed4d45a22	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:11:58.281	down	1	connect ECONNREFUSED 127.0.0.1:8080	tcp
da9befef-c553-4941-9f8b-571e27c78c95	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:11:58.285	down	0	connect ECONNREFUSED 127.0.0.1:8020	tcp
d0aa0786-3b2d-41c9-a6e1-1eecc6353072	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:11:58.289	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
7936b5ff-aaaf-4fe0-97c1-e64a41ec41fd	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:11:58.293	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
07d62448-a1d0-469e-9889-a49a2633a951	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:11:58.297	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
9eed1a03-ab7a-4462-abd8-5dddcdcd9276	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:11:58.301	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
5dce2d5e-65c1-432c-a975-3a593a4ea65f	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:11:58.305	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
c2472855-190a-439e-9bc6-92c34b393687	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:11:58.363	up	91	\N	tcp
6f3597e4-f1ed-492b-9718-a818ba817e59	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:11:58.365	up	92	\N	tcp
2cece9aa-56f3-4bfe-bce6-848db43a398d	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:12:01.273	down	3000	TCP connection timed out after 3000ms	tcp
5921048a-a959-47d8-95ff-e020fd51ac23	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:12:01.279	down	3000	TCP connection timed out after 3000ms	tcp
2678339b-cc2a-4f66-baab-5e0d43e40157	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:26:38.823	down	12	\N	tcp
1c2dc0b8-df13-4bb1-84be-a021ab919721	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:26:38.822	down	12	\N	tcp
0b11b2bd-4a8e-4f0b-a1a2-23ce50d83a33	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:26:38.865	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
426e5fc4-ef0b-4429-9c6b-3fa9ba59c8a0	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:26:38.866	down	3	connect ECONNREFUSED 127.0.0.1:8555	tcp
b0860f56-4063-4537-b8f3-04015fef9139	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:26:38.87	down	12	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
c5b178e2-c310-4873-8b12-1bab6f568ad9	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:06:28.063	down	3	\N	tcp
c18c4d95-d3d0-464d-8c9c-1625d58e508f	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:06:28.066	down	6	\N	tcp
f5c0a254-c156-47e8-8d0b-35aff21ba4e1	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:06:28.068	up	8	\N	tcp
30b60622-fce7-4d21-9075-08517b07c60c	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:06:28.082	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
c3d9b687-b9c7-46d5-a355-dbe2a13f72a3	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:06:28.107	up	26	\N	tcp
340e7018-d1b3-4aba-8b9b-6720e7ceee88	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:06:28.109	up	28	\N	tcp
5f7dc273-f7e8-4a41-b5b7-76ad4c6c543b	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:06:28.115	up	1	\N	tcp
f77ada35-56ca-44d4-9098-3efc1ace79b7	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:06:31.082	down	3001	TCP connection timed out after 3000ms	tcp
956b41be-d944-4376-8605-2045ec8d92c7	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:06:31.091	down	3000	TCP connection timed out after 3000ms	tcp
391d5ec2-e586-4603-bc1b-34f7526ee0a8	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:06:58.09	down	5	\N	tcp
e1423c14-6d8d-47a4-ab1f-814a233f209f	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:06:58.092	down	7	\N	tcp
9c181dc2-6cee-4c2c-abf8-88ff526053d7	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:06:58.095	down	10	\N	tcp
ee2bb9f0-ce4d-470f-88d5-7328b33f567d	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:06:58.106	down	3	connect ECONNREFUSED 127.0.0.1:8555	tcp
96bea361-207d-4532-8ac3-c3ccabf5cde6	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:06:58.11	down	1	connect ECONNREFUSED 127.0.0.1:4100	tcp
76a12166-d34f-475b-9dba-fb3a686a67e7	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:06:58.116	up	12	\N	tcp
957e0c85-49b8-4646-86ae-6562c88f8cba	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:06:58.122	up	5	\N	tcp
55fe2e2f-891a-400c-8991-34885606e729	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:10:28.198	up	6	\N	tcp
abf3a26c-8cbf-4456-9ac5-af3b0d46dae9	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:10:28.24	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
46e3357c-9ae2-41a1-8e4e-d210b7b238e6	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:10:28.244	down	6	connect ECONNREFUSED 127.0.0.1:8088	tcp
d7eaa926-aab5-458a-8fe7-b96f522b3879	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:10:28.268	up	30	\N	tcp
7b1ab0a1-5d1b-472f-b747-3fab879df8ac	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:11:28.249	down	4	connect ECONNREFUSED 127.0.0.1:8020	tcp
6dbdc28c-e384-429c-a22d-4c42274ac262	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:11:28.253	up	8	\N	tcp
0e605726-38b5-4228-a3d3-c6bbff115817	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:11:58.26	down	6	\N	tcp
bdbae963-cd3d-4938-9e83-ecf3ee7f6b14	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:11:58.364	up	91	\N	tcp
50636cbf-93fb-4690-a165-2953f6f92f5d	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:26:38.821	up	11	\N	tcp
0884678a-4311-47d0-9698-d4d97649d1e2	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:26:41.873	down	3004	TCP connection timed out after 3000ms	tcp
e64bc7bb-f7a3-42e0-9929-166ec5e9fd18	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:47:09.149	down	7	\N	tcp
4255c12b-49e0-4458-be5b-07bfb2fe9ba5	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:47:09.176	up	7	\N	tcp
1b2478b4-00a7-4a6b-a73a-a07ad9ed7c37	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:47:09.181	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
9fcee58a-1f9b-4afa-9ba6-3dda4e1e442f	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:47:12.169	down	3000	TCP connection timed out after 3000ms	tcp
90b5a13a-fbe5-4ff1-a3d3-e98144420a64	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:01:51.781	down	3	\N	tcp
fa45722b-d255-4736-91be-639a8d5a6ab4	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:01:51.781	down	3	\N	tcp
a4108616-8a64-487c-b1a5-5d21ed607a0e	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:01:51.804	up	15	\N	tcp
7cf1fab6-5459-458e-b03d-3487dea8a982	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:01:54.789	down	3000	TCP connection timed out after 3000ms	tcp
e376254c-8000-46c9-84d1-ec4ff1623fbf	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:02:21.826	down	3	\N	tcp
2b0085ff-4512-4b96-881e-56b650e48e67	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:02:21.827	down	5	\N	tcp
5a591f09-39e4-4ca9-8579-a70bc4ec1a2a	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:02:21.838	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
47ef0a41-9570-452f-8ff1-7b105255e0e7	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:02:21.875	up	40	\N	tcp
8ab1b8f3-0935-401b-b8f1-1db0fca8cd60	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:02:51.804	down	3	\N	tcp
083d1c41-d268-4be0-9450-c0a9acf3aa71	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:02:51.805	down	5	\N	tcp
13a97d65-d6b0-4fc5-89ef-02f01e745c24	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:02:51.814	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
0f34ef22-d6db-4b7e-913d-710986a48acf	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:02:51.824	up	12	\N	tcp
d1c10b38-e118-4e48-bca4-82c51994bdb2	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:02:51.825	up	7	\N	tcp
6ee73427-e0ff-4541-b914-d74a71fcbc19	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:02:51.827	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
a4b454df-03eb-4f46-b439-fd6a508559b1	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:02:51.828	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
e7bbd1e5-37e5-4e45-9d1e-108e52bb3252	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:06:28.063	down	3	\N	tcp
1578387b-95ba-430a-9c78-892abe2387d5	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:06:28.067	down	6	\N	tcp
cf990223-5efd-4561-8028-feb016aefbb5	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:06:28.108	up	28	\N	tcp
581bc5ca-1f9c-4992-ad36-c2e971015e7f	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:06:28.11	up	19	\N	tcp
66e23c18-e875-4831-a1b3-831bb5d8afef	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:06:28.116	down	2	connect ECONNREFUSED 127.0.0.1:8078	tcp
cb54bece-860f-4f65-a838-d96743211965	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:06:31.083	down	3002	TCP connection timed out after 3000ms	tcp
599a087f-ae32-48fa-8bf5-d814e7b58833	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:06:31.091	down	3000	TCP connection timed out after 3000ms	tcp
6301d1eb-49d1-42cb-af21-5d9868775016	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:06:58.091	up	6	\N	tcp
2dd6083f-f0fc-47df-a507-b2a6f59396c0	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:06:58.094	down	8	\N	tcp
8e0560e9-970e-4049-88e6-b3e58dcdd2a4	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:06:58.106	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
7bda38a9-ccee-4987-916e-46ae966f946b	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:06:58.111	down	1	connect ECONNREFUSED 127.0.0.1:7000	tcp
8635025d-de2b-4813-b521-548b643e47b5	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:06:58.112	down	1	connect ECONNREFUSED 127.0.0.1:6875	tcp
19d5b5ae-724c-4b6e-a009-44406b773a44	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:06:58.115	up	12	\N	tcp
e3f40c46-2c62-42fa-b929-69d3852474b2	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:07:01.105	down	3002	TCP connection timed out after 3000ms	tcp
12ab0a36-245a-437b-90be-797e3b4fbea3	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:10:28.242	up	4	\N	tcp
f5012342-f698-400e-915b-3e05bbe5c798	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:10:28.25	down	1	connect ECONNREFUSED 127.0.0.1:8080	tcp
c583cc29-9d2d-49fe-9f9b-488125e24e9a	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:10:28.255	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
aa4e7711-ba13-4212-8fdf-2a9087f63fb3	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:10:28.259	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
5495d88c-5b63-48d7-b53c-f560f83e7ff8	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:10:28.263	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
3b8cc369-aea5-4709-8330-bf35887415cd	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:10:28.269	up	21	\N	tcp
31fa389e-2185-457f-af6d-f70d239b852b	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:10:28.275	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
c2f452bb-ff9f-4282-96a4-b5e636be4b63	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:10:31.239	down	3001	TCP connection timed out after 3000ms	tcp
bb0a8680-4ddb-48b4-a5bd-4cca0c366270	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:10:31.249	down	3001	TCP connection timed out after 3000ms	tcp
7d8e77be-1cd9-424b-8bfb-fc95fac0c2e6	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:10:58.205	down	3	\N	tcp
07aa4b0a-a75e-43c8-bc09-dbff0f1bb0d7	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:10:58.207	down	5	\N	tcp
65d3f132-5f30-4880-bd7c-a8f4be9055a8	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:10:58.211	down	8	\N	tcp
f435e3f7-1b45-4495-a2b6-89215f242ce8	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:10:58.223	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
4cf624ec-374f-4892-b0ba-b9320f9fb35b	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:10:58.228	up	7	\N	tcp
19800198-c306-412d-8282-19ec48772cb3	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:10:58.237	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
9afd051c-91a5-4187-9b54-12fac7ae486d	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:11:28.231	down	4	\N	tcp
99628e11-a3b8-4074-81ed-400ca0a7e559	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:11:28.234	down	6	\N	tcp
3b17f0c5-a28e-459d-93fe-4ae877bdb8bf	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:11:28.254	up	8	\N	tcp
75883d95-1ae1-47fc-853a-8978992450d8	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:11:58.257	down	3	\N	tcp
013882b5-ce52-41a7-9682-89dc53dd3ff9	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:11:58.26	down	6	\N	tcp
1c70bdbd-6175-4d85-bce9-06f3701062fb	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:11:58.263	down	8	\N	tcp
fe2de380-d199-4b7b-bf45-e6cd9cffa306	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:11:58.275	down	3	connect ECONNREFUSED 127.0.0.1:6875	tcp
cb5d0f47-9227-4b91-bca8-02bcc74b5252	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:11:58.364	up	91	\N	tcp
2547e823-d4e7-4e13-b3e6-f3d69a92582d	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:11:58.366	up	77	\N	tcp
028fbfea-1951-4948-81bb-4a843a345622	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:12:01.273	down	3000	TCP connection timed out after 3000ms	tcp
32020efc-89d0-4b0f-98af-1403defdb19c	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:12:01.279	down	3000	TCP connection timed out after 3000ms	tcp
12a4224f-6f3d-4643-9f8c-f4d0704504c8	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:12:01.284	down	3001	TCP connection timed out after 3000ms	tcp
7e78c6f6-5dac-425f-8ffa-d6253408494f	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:26:38.824	up	13	\N	tcp
209f5f5a-784c-4fba-9fb6-4c4f7fba30ea	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:26:38.827	down	15	\N	tcp
9fe6a081-cc7d-403b-bd14-e8217b48f6bd	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:26:41.863	down	3000	TCP connection timed out after 3000ms	tcp
4a8ef048-34f5-4a0a-90ad-ecfcf844537f	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:06:28.064	down	3	\N	tcp
a8f669b6-7a88-4272-aa6a-2739664b9b19	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:06:28.108	up	27	\N	tcp
649a991d-df27-45ef-957a-5dc54b36ed54	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:06:28.11	up	19	\N	tcp
56aa6293-d349-4ce2-8d00-00f5396e7456	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:06:31.082	down	3001	TCP connection timed out after 3000ms	tcp
febe686a-e8f7-4a34-8ffb-ebe2ee23a584	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:06:58.123	down	3	connect ECONNREFUSED 127.0.0.1:9006	tcp
c83794d2-1566-41f2-b096-14b43d79df2f	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:06:58.124	down	3	connect ECONNREFUSED 127.0.0.1:9001	tcp
20026e6c-259c-474b-8644-6ecd04c86f94	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:07:01.106	down	3002	TCP connection timed out after 3000ms	tcp
c2ade460-63d6-4e88-b6a4-d22b244bd754	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:12:28.78	up	25	\N	tcp
da4c33d7-b372-4372-b97c-a6aae60e2453	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:12:28.959	down	45	connect ECONNREFUSED 10.0.0.200:3100	tcp
a764fdc6-21ff-450a-846c-3ed8a80e574b	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:12:31.92	down	3006	TCP connection timed out after 3000ms	tcp
55a82db4-cfa5-4c44-8668-3cc0857bd6e8	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:12:58.326	down	5	\N	tcp
5e3c8c64-5f2b-4ccd-adb7-cabb8dab8f6a	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:12:58.33	down	8	\N	tcp
272b5905-e7fa-4d69-9076-e9664ed8e0cf	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:12:58.341	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
8e887b28-e727-40a8-8feb-a43149ce832d	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:12:58.343	down	4	connect ECONNREFUSED 127.0.0.1:8020	tcp
3632ae1b-52a1-4414-8dde-1464d5c1d285	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:12:58.374	up	34	\N	tcp
f4de6891-50fb-4414-99c9-4014fbdc8850	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:13:28.359	down	4	\N	tcp
12ab9871-efe3-4d2e-b0bd-ad9035178f09	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:13:28.362	down	7	\N	tcp
e1cbd67c-fe31-4282-ac39-eb7c4a25c399	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:13:28.38	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
8ace8e00-4769-4fa7-97c0-a9756444dcc0	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:13:31.379	down	3001	TCP connection timed out after 3000ms	tcp
8a107385-e867-4328-b7c2-76153a6908ac	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:13:31.389	down	3002	TCP connection timed out after 3000ms	tcp
eb10f5c3-6fec-4289-9487-a66212c57d20	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:13:58.388	down	4	\N	tcp
834c91fa-5c2f-4c36-b000-52f918d54b10	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:13:58.393	down	9	\N	tcp
6661c355-4125-4568-aec2-3de3152f58ce	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:13:58.411	down	4	connect ECONNREFUSED 127.0.0.1:4100	tcp
2c7ffe80-caf4-49ad-af66-a1b5c9ea74f4	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:14:01.408	down	3001	TCP connection timed out after 3000ms	tcp
3621b5e9-72ff-42a2-bf8a-85f5db1b176a	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:14:01.41	down	3002	TCP connection timed out after 3000ms	tcp
8ab9505d-c42a-4cb0-8ec3-9d97785d7619	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:14:01.417	down	3000	TCP connection timed out after 3000ms	tcp
92e0488c-077f-4b28-8a0b-f7be047341d5	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:14:01.42	down	3000	TCP connection timed out after 3000ms	tcp
acba150e-350e-4cf0-925a-2be38050b135	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:26:38.829	down	17	\N	tcp
a18250fb-e891-47d8-9e23-4d25ebaa7b71	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:26:41.873	down	3004	TCP connection timed out after 3000ms	tcp
31223b89-61d0-414f-8b05-cdd6b7dbc6f7	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:47:09.144	down	3	\N	tcp
b5159879-f6cd-48b0-a3eb-7bb2b6d9b01e	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:47:09.174	down	0	connect ECONNREFUSED 127.0.0.1:8080	tcp
df03efd4-e45e-443a-8e65-a16f0b12598a	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:01:51.78	up	2	\N	tcp
3190f6f7-7cd8-4159-a67c-41b90c095adb	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:01:51.782	down	4	\N	tcp
5fa62479-088c-4a3a-9780-8be7886c29b1	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:01:51.79	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
cfc124aa-dc2f-4470-aaa6-7ebf9da4a1d3	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:01:51.793	down	0	connect ECONNREFUSED 127.0.0.1:8555	tcp
dd0377f8-44fd-4bd7-b180-70b2a46fbdbc	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:01:51.795	down	0	connect ECONNREFUSED 127.0.0.1:8088	tcp
28e7a5ba-d554-4981-afb9-9eeb68bdf18b	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:01:51.797	down	0	connect ECONNREFUSED 127.0.0.1:8020	tcp
dad65153-59fe-42fe-8af2-82f33a31a951	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:01:51.799	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
432444af-6c14-4ff5-85f5-4e46b44413c1	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:01:51.8	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
1f879994-9def-44de-9ab0-c5d4c50acc6e	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:01:51.802	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
8b5bff98-e772-4f5c-9652-8eb18e9ce361	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:01:51.804	up	15	\N	tcp
4c671a60-d1bc-4d54-b0f5-69409b175896	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:02:21.828	down	5	\N	tcp
1c829b23-8426-444e-8a0d-05fe213d26ed	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:02:21.837	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
5d2ad7dd-af8d-4026-98f9-68fb9e630d0c	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:06:28.064	down	4	\N	tcp
2878f419-8e6a-4305-ba1a-24c8f1d92ae8	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:12:28.769	down	18	\N	tcp
9d8d7f6a-82ff-4b20-af5a-96b79928cead	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:12:28.795	down	41	\N	tcp
588dbab8-af32-4aef-8e90-333fbeaf881e	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:12:28.936	up	22	\N	tcp
0e792781-dbab-435b-89fe-91955e432732	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:12:58.327	down	6	\N	tcp
7d57f914-796e-492b-911e-157d1cc43dbb	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:12:58.378	up	38	\N	tcp
34b25f1d-7166-474c-af2b-074ce15a7e90	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:13:01.348	down	3001	TCP connection timed out after 3000ms	tcp
45fbd868-5dc4-4f0e-a18e-b766492cde3f	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:13:28.361	up	5	\N	tcp
27e15590-d1f9-47bf-96e0-30aad1ea5d39	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:13:31.38	down	3002	TCP connection timed out after 3000ms	tcp
f26de95d-6bd5-42a3-b162-ef412c63db8b	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:13:31.386	down	3000	TCP connection timed out after 3000ms	tcp
5df65bba-c35f-4e26-8192-bbb5f9a4278d	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:14:01.408	down	3000	TCP connection timed out after 3000ms	tcp
a834e359-9275-488b-97a0-d10eb79750ba	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:14:01.41	down	3002	TCP connection timed out after 3000ms	tcp
6c899efd-878b-4223-ba80-25b3c0db912a	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:14:01.417	down	3000	TCP connection timed out after 3000ms	tcp
a7d33616-7d98-47e6-804c-680aa939fd65	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:26:38.823	down	12	\N	tcp
83cb989e-efbd-49c6-84ef-547e1e195877	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:26:38.826	down	15	\N	tcp
48347eb2-3759-4a1d-a07c-2eb9db0679a4	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:26:38.864	down	10	connect ECONNREFUSED 127.0.0.1:8020	tcp
c036982f-87e9-497c-b4a5-c7792764293c	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:26:41.864	down	3001	TCP connection timed out after 3000ms	tcp
5aebcad2-8803-4c6b-9fa6-c62a4b977700	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:47:09.146	down	5	\N	tcp
b2327902-9e0a-40da-9961-6f3d66ae414b	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:47:09.174	down	0	connect ECONNREFUSED 127.0.0.1:8020	tcp
8ed6caf0-64d5-47a9-aeba-b9c8ae116bca	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:01:51.781	up	3	\N	tcp
7efe4510-36ad-4625-a7ec-a63f66e06976	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:01:51.805	up	16	\N	tcp
1c461ebd-cb7a-403a-a445-e32371467f43	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:02:21.826	down	4	\N	tcp
39c708c3-a5cc-471d-ac2a-f3e33263ecaa	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:02:21.876	up	40	\N	tcp
4b2da1f0-a46b-47b2-9f10-1c5d0db769e7	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:02:51.804	down	3	\N	tcp
6d421a58-6349-4e1a-9330-22ce867b5086	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:02:51.806	down	5	\N	tcp
d5e23222-ddf3-46dc-ba9b-4541e2edbd7b	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:02:51.816	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
2c5f7b32-98e3-4889-9e09-1a3ed854cf85	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:03:21.803	down	2	\N	tcp
de5aee41-9598-41a1-8eb6-2b3c4f3dd349	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:03:51.809	down	2	\N	tcp
03222b1a-4207-44c6-bfb1-4d34125a3acd	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:03:51.813	down	6	\N	tcp
01803f2c-1505-40c2-8cdb-f73c799c9473	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:03:51.813	down	6	\N	tcp
2db9cef1-8f68-4589-a20f-c96cb10764f1	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:03:51.809	down	2	\N	tcp
fa88e896-5a69-46db-a53b-4c406d608d8e	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:03:52.076	up	226	\N	tcp
4d05ff84-9fcf-4d73-8ea2-5118e5a3a737	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:04:21.804	down	3	\N	tcp
5c1d112a-54bd-442d-ada6-b12c7af0508e	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:04:51.849	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
5901a5a0-9be6-4d28-9083-b2f30ee6df71	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:04:51.88	up	24	\N	tcp
7fc91058-f2bc-428b-a08d-ec565c9c1cae	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:04:51.882	up	21	\N	tcp
be3d7957-1529-4f92-b14a-22f659db0547	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:04:54.849	down	3001	TCP connection timed out after 3000ms	tcp
6810fbe6-5ab8-473a-9cfb-63169ffe2bdb	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:05:21.834	down	2	\N	tcp
eca36aa6-bec4-4def-baf2-8956666a3cae	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:05:21.835	up	3	\N	tcp
d34f3a46-e504-462c-a7c1-ed37714a946c	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:05:21.845	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
faef95d7-6538-49c0-90a5-ae81d2da1370	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:05:21.855	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
6c80411f-8adc-460e-a3d6-02d31373f1c0	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:05:21.879	up	23	\N	tcp
810374ed-f919-46fc-823d-2e11d62c4c05	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:05:21.878	up	34	\N	tcp
bf09717e-1b29-4b9c-ad00-ae39eadcabd4	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:05:24.844	down	3000	TCP connection timed out after 3000ms	tcp
bd1c99a8-d90d-4e25-888c-b4fea405351d	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:08:51.931	down	1	\N	tcp
c1a7f82f-6e59-4113-82db-c34cfa129e5b	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:08:51.934	up	3	\N	tcp
e679281f-19b7-4e12-89a3-5c43b0b7b3c9	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:06:28.065	down	4	\N	tcp
7fe332f2-1574-46e3-9303-3a4bb1c67b21	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:12:28.776	down	24	\N	tcp
48ebb4d9-cca0-4520-852f-0c58ee51c986	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:12:28.788	down	34	\N	tcp
65b56712-b23d-41f3-b9c6-b153cc735302	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:12:28.949	down	34	connect ECONNREFUSED 127.0.0.1:8556	tcp
49c8158e-41e0-4954-a4fd-e0dd44f10d17	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:12:28.939	down	26	connect ECONNREFUSED 127.0.0.1:8555	tcp
0d5e0358-7290-47b6-b637-bd2dad74f5c3	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:12:29.027	down	27	connect ECONNREFUSED 127.0.0.1:8088	tcp
b8112b1c-78ac-4067-b8b9-d35485035ace	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:12:29.088	down	10	connect ECONNREFUSED 127.0.0.1:9000	tcp
719baced-417a-4d3f-93ed-ab89c72a8547	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:12:31.933	down	3018	TCP connection timed out after 3000ms	tcp
216c9159-7262-42ad-bbd7-ef0ba9e4d807	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:12:58.325	down	4	\N	tcp
36cf1938-d570-48b3-8450-7f9172b8860b	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:12:58.329	down	8	\N	tcp
98e2ffb5-f74a-4038-b656-d269c83c4bfa	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:12:58.342	down	3	connect ECONNREFUSED 127.0.0.1:8555	tcp
e0e58466-564e-4675-a463-e45ba6c761a2	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:12:58.375	up	35	\N	tcp
185a79c2-cf62-417a-b560-3e44a36f8771	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:12:58.377	up	37	\N	tcp
a549a652-af8f-41d8-a785-b48c27d7ebb8	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:13:28.36	down	5	\N	tcp
8f9d46d7-c784-4d17-8f51-194c4219c45e	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:13:28.363	down	8	\N	tcp
552399a2-f385-4ebc-a7c9-23c4e9f65466	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:13:28.381	down	4	connect ECONNREFUSED 127.0.0.1:8080	tcp
ae272005-da0c-4205-ae26-278833a06b75	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:13:31.379	down	3001	TCP connection timed out after 3000ms	tcp
37fafc15-b5a9-4c92-a5bf-8092b840f308	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:13:58.391	down	6	\N	tcp
9a2b9025-1512-4c5a-9ed3-92ba051a5ffd	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:13:58.412	down	5	connect ECONNREFUSED 127.0.0.1:8080	tcp
c628d1ad-837d-4291-a3ec-f787296cb91d	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:13:58.416	down	1	connect ECONNREFUSED 127.0.0.1:7000	tcp
7e4a4117-3604-4333-a09b-fb9d2b08d5a1	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:26:38.826	down	15	\N	tcp
c7f2ac49-4c94-40e4-9b87-842cb744e189	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:26:38.864	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
ceb28f34-e884-44a0-8ee5-3eeadf2768ad	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:47:09.145	down	4	\N	tcp
11facd0f-9d38-4688-9b3b-e02ae6c5d1f9	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:47:09.147	down	6	\N	tcp
7a88dfdf-24ab-481a-9971-de15134a4974	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:47:09.175	up	6	\N	tcp
680e5683-2ac1-40bb-b5c5-48cae9899c27	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:01:51.78	down	2	\N	tcp
f3ff52ae-e194-479e-8ed8-bf39a058a641	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:01:51.791	up	1	\N	tcp
aa330a3e-001c-4091-902a-d1c81f0c5a5f	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:01:51.793	down	0	connect ECONNREFUSED 127.0.0.1:6875	tcp
f14460b3-32a1-4885-942a-b387c9a16d4e	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:01:51.804	up	15	\N	tcp
76b76945-85e4-43bf-8b59-32e28edf78ad	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:01:51.805	down	2	connect ECONNREFUSED 127.0.0.1:9001	tcp
d3944318-08bb-447b-93e0-1d2b1f0f1265	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:01:54.789	down	3000	TCP connection timed out after 3000ms	tcp
8d5f8534-152f-4bcc-b04c-ce7119d6c032	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:02:21.827	down	4	\N	tcp
5d8bc661-da70-40bc-92fa-181b14e99d55	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:02:21.876	up	34	\N	tcp
c6151d1a-d76c-4276-9c3c-f4c308399010	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:02:51.803	down	3	\N	tcp
e9e8c7a4-35f7-4149-b8e9-aac4664db2a8	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:02:51.815	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
5c4c72bb-f442-4c9c-bcc3-bb9ed678689c	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:02:51.824	up	11	\N	tcp
5b0bb605-6cfb-4400-9320-b5bc57a7ea58	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:02:51.825	up	7	\N	tcp
a11225d9-6741-4807-8d12-350f56cc1d75	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:02:51.828	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
1be9eb87-0392-4d09-9857-62b478e603d4	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:02:54.813	down	3000	TCP connection timed out after 3000ms	tcp
5436a460-4571-483b-b33a-c8925a5ed827	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:02:54.818	down	3000	TCP connection timed out after 3000ms	tcp
27764def-9775-412d-9d94-a6832c137668	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:03:21.804	down	2	\N	tcp
641a6210-0694-424e-80d0-976499439cac	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:03:21.807	down	5	\N	tcp
4f6b779a-d001-4b26-a16a-c1873e06828a	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:03:21.815	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
0d1c41ef-2c5a-4ca0-a448-5753ecd24584	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:03:21.822	up	9	\N	tcp
d9fff3f1-fa72-4f62-8379-c8c4851d5ded	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:03:21.828	down	2	connect ECONNREFUSED 127.0.0.1:9006	tcp
f14b6170-5626-47fc-addd-fc4fac022175	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:05:00.199	down	6	connect ECONNREFUSED 127.0.0.1:4100	tcp
c557b346-9712-42ce-a28b-a99188fbeefe	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:05:28.045	down	5	\N	tcp
4ee48a71-932e-46f6-8cf4-bdba4bcc7f33	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:05:28.048	down	8	\N	tcp
ca9364ea-30d5-453d-889b-270d083951e9	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:05:28.066	down	4	connect ECONNREFUSED 127.0.0.1:8078	tcp
8b1258af-b355-48b0-9fcf-e93f207bd72a	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:05:28.073	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
452e4dd3-fc7f-4815-8bc4-d0dcbbad75c7	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:05:28.077	up	0	\N	tcp
78056f08-32c0-46f5-9de9-c628831eb779	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:05:28.082	down	0	connect ECONNREFUSED 127.0.0.1:4100	tcp
96a4abf5-7ddc-47e8-a2cd-73905ef69475	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:05:28.085	up	24	\N	tcp
207a6cff-b640-4b4f-8022-bb30a5c7d6a3	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:05:28.087	up	26	\N	tcp
058c7f90-21b6-4415-abd5-56b2ee81b630	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:05:28.089	up	27	\N	tcp
94c26622-0cc6-4b7e-bac9-8efb6f985d36	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:05:28.095	down	5	connect ECONNREFUSED 127.0.0.1:8020	tcp
a7e09a37-b0a5-4c86-9186-f081cfecb310	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:05:28.096	down	1	connect ECONNREFUSED 127.0.0.1:8080	tcp
e258d683-5342-4ec8-866d-79dc5c031392	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:05:58.066	down	5	\N	tcp
6a1586d7-cc00-4729-83a5-086347046fb0	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:05:58.068	down	7	\N	tcp
b14d4c23-7c83-4d78-a176-b5dbca9bec44	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:05:58.084	down	4	connect ECONNREFUSED 127.0.0.1:8088	tcp
d7aaf72d-aa38-4b31-9620-eb701f18a99b	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:05:58.091	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
432bacd4-dd42-47be-a6aa-322d009f5f93	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:05:58.095	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
a04ec5fe-f0a6-4275-94b4-98f1a1c2ade3	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:05:58.099	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
62385d4e-d50e-4135-b9a1-28bb1e731185	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:05:58.104	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
279ba128-41b3-4405-b788-d029386193cf	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:05:58.108	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
825660f9-d438-4b2f-8e18-b18544efa173	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:05:58.233	up	152	\N	tcp
d325f6ca-cf0a-4a9d-b5c9-c3ff820401c1	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:05:58.235	up	154	\N	tcp
e60e789a-5cf1-4dd6-9f93-e81ae08eec1d	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:06:01.089	down	3001	TCP connection timed out after 3000ms	tcp
beea6178-5895-4b4a-9cf6-09b67f097c55	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:26:38.825	down	14	\N	tcp
d820ee2c-3724-44a5-b9e0-9facabe033fc	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:26:38.864	down	10	connect ECONNREFUSED 127.0.0.1:8088	tcp
5ad893d8-d2d7-4dbd-88cd-3f207435a738	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:26:41.858	down	3000	TCP connection timed out after 3000ms	tcp
5a931ddf-fb0c-4afc-9011-60bc3b41cfd5	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:26:41.864	down	3001	TCP connection timed out after 3000ms	tcp
1ffa599d-b803-498f-8ddc-30633f0b1b35	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:47:09.145	down	4	\N	tcp
03c47dbe-eb4c-410b-b1fd-ba651052a8d6	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:47:09.171	up	1	\N	tcp
e17f4b85-bd7d-42c1-be1c-5ae8e2de6054	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:47:09.175	up	6	\N	tcp
cf98e2c5-56bf-46b7-b867-f6592246bac1	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:47:09.18	down	1	connect ECONNREFUSED 127.0.0.1:8088	tcp
32db6aa9-5cae-41ae-97aa-dfb486a185cc	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:47:09.181	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
b6e061fd-6b2d-4ae0-b320-19ac353007c6	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:47:12.169	down	3000	TCP connection timed out after 3000ms	tcp
9ce4094a-c432-4dfc-a82f-5eff7db45127	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:47:12.179	down	3000	TCP connection timed out after 3000ms	tcp
0d2f1d50-39e2-47cc-ba30-1f54d5239feb	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:01:51.782	down	4	\N	tcp
6e3bc289-c7cd-4307-814d-01e5895d32d5	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:01:51.79	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
35d503cb-f4c7-4873-b250-506d685d19cf	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:01:51.804	up	15	\N	tcp
d4d38fa7-a15b-4d57-a409-272d3ea60a61	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:02:21.825	down	3	\N	tcp
32788736-99b0-4db7-bfc2-5033c4c595fd	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:02:21.828	down	5	\N	tcp
aba1e611-74c9-4a99-961d-2024e81ea4b1	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:02:21.838	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
3f38da50-5035-4083-a9c0-7358138ae4a0	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:02:21.876	up	40	\N	tcp
b95c1ad3-271b-4d8f-b529-2003c010e230	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:02:51.803	up	3	\N	tcp
2730fa30-d012-4e26-96b9-85106e11e0f6	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:02:51.805	down	4	\N	tcp
2cfb8258-6f41-48e8-94b8-e9a6c4b6b105	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:02:51.815	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
1776dbe1-8420-4546-a210-fbceaa59abc2	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:06:28.064	down	4	\N	tcp
11ea01c2-e57c-4c40-b465-2a13408408dc	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:06:28.069	down	8	\N	tcp
df10ca0c-7db9-4938-b97b-713af07c0469	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:06:28.084	down	3	connect ECONNREFUSED 127.0.0.1:9000	tcp
5fc9c20c-47c8-4f7b-809e-439c31f904da	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:06:28.108	up	27	\N	tcp
d1df6c09-bc2f-4904-bb8c-1cb6df1bfeb2	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:06:58.089	down	4	\N	tcp
cc1f1f4c-8123-4cf2-a3ff-a2a35ea5685a	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:06:58.091	down	6	\N	tcp
09aa3b97-a26f-4fe8-9560-0dd435816c42	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:06:58.093	down	8	\N	tcp
b677ae81-176a-41a6-9b4c-0842d126b2da	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:06:58.117	up	14	\N	tcp
2e9ca909-04d4-4712-b9ae-59a0b2efe337	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:06:58.121	up	7	\N	tcp
99304df6-6957-4459-8f45-14e13ec2fce0	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:07:01.106	down	3002	TCP connection timed out after 3000ms	tcp
5551dfa1-de6d-4bfd-a30a-3d6995604691	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:12:28.765	down	15	\N	tcp
645a3de0-f95a-41e5-82ec-9cbd19c01edc	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:12:28.798	down	43	\N	tcp
f73e4e37-4541-4c60-9f0a-33a0deae871a	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:12:28.931	up	17	\N	tcp
e155a034-9058-4aef-97d2-269f32e2a939	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:12:29.025	down	29	connect ECONNREFUSED 127.0.0.1:8080	tcp
3208d78e-516b-419a-a9ff-3645c4ff1b9e	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:12:58.324	down	3	\N	tcp
0ddb6bc9-383c-4fb3-841f-5757ffd90a26	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:12:58.343	down	3	connect ECONNREFUSED 127.0.0.1:6875	tcp
576573fe-c360-4299-a1c2-d0c81c495ff3	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:13:31.38	down	3002	TCP connection timed out after 3000ms	tcp
6f17782a-a503-4154-b277-87a441d85c8c	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:13:58.389	down	5	\N	tcp
9fde3840-4d0f-4cf0-8604-a09093987b6b	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:13:58.393	down	9	\N	tcp
4e8c3fdf-1e7d-46bd-a6dd-c1b2d6f9f46e	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:13:58.412	down	5	connect ECONNREFUSED 127.0.0.1:8556	tcp
6b16438e-585a-47d7-b895-46465b9f804b	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:13:58.416	down	1	connect ECONNREFUSED 127.0.0.1:8555	tcp
1858c31d-4415-4e00-b800-bcebf44a8bc0	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:14:01.408	down	3000	TCP connection timed out after 3000ms	tcp
72808e18-3380-4a16-b959-9cff042e8c08	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:14:01.41	down	3002	TCP connection timed out after 3000ms	tcp
61b828fc-bfac-4389-aa2c-7c1d393275b8	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:14:01.418	down	3000	TCP connection timed out after 3000ms	tcp
c1313e78-9578-4a48-a45a-0bcf19c65c3f	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:26:38.825	down	14	\N	tcp
1989f475-2ec5-4e18-b568-c65caad606c1	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:26:38.864	down	2	connect ECONNREFUSED 127.0.0.1:7000	tcp
bf0d414d-d79e-4101-938b-4f959d32d1cb	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:26:41.869	down	3000	TCP connection timed out after 3000ms	tcp
44a5d65e-8755-4964-a8e3-ed8e5f471cc4	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:47:09.147	down	6	\N	tcp
fc440141-d1cc-4113-b1ad-fdfa893a5fc2	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:47:09.17	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
199a2096-ffdb-46e4-96db-93eba97bda7e	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:47:09.175	up	6	\N	tcp
e893be29-2c92-42aa-9d7e-101166db6845	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:47:09.181	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
45f9a1bf-bdc6-4ce1-914e-6f65580c880f	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:02:21.837	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
8255b884-9f2c-4c71-a937-794dc77dcdb9	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:02:21.877	up	34	\N	tcp
3e7eb8d6-57f8-4831-bff3-56e4e7e32b8f	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:02:24.835	down	3000	TCP connection timed out after 3000ms	tcp
f0065d31-7f01-4dc3-9831-a7cd8aa179e7	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:02:51.803	down	3	\N	tcp
10810e63-0986-4fae-8799-278cb390f9dd	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:02:51.805	up	4	\N	tcp
0a1e440d-2591-4b30-ac97-b7952b186809	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:02:51.814	up	2	\N	tcp
bcc355bc-d158-4df6-9f15-e65f8763b2eb	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:02:51.815	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
4c1919d6-cd4a-435a-989d-debb2d6dadde	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:02:51.824	up	12	\N	tcp
a3054879-71d8-4271-a2d4-8861cfd2f75b	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:02:51.825	up	7	\N	tcp
42a4d327-0776-4dfd-b84c-dc68c54699ff	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:02:54.82	down	3001	TCP connection timed out after 3000ms	tcp
97fe25db-45c9-4609-b499-9aab0326c39c	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:03:21.804	down	2	\N	tcp
8a6d677e-73e8-4702-9501-c4ea92b131a7	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:03:21.822	up	9	\N	tcp
3ff9efb6-5601-482e-87f2-a691141d6986	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:03:51.809	up	2	\N	tcp
edcfef71-1437-4aec-b73d-0c6d877deb29	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:03:51.813	down	6	\N	tcp
957951b3-fdb1-4bfc-9515-45fdaf166026	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:06:28.066	down	5	\N	tcp
bca1273a-3246-4de1-b520-637099fd9444	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:12:28.763	down	14	\N	tcp
4ccd66d6-d8aa-45cb-822c-bf7c7d82f2c9	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:12:28.957	up	42	\N	tcp
26747921-f957-4518-bc58-cede041ff410	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:12:29.037	down	31	connect ECONNREFUSED 127.0.0.1:9020	tcp
7e26ce76-4fb2-4988-b827-d25d124cc30b	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:12:31.918	down	3004	TCP connection timed out after 3000ms	tcp
ff36c140-c2ff-4ff5-8d8f-4936fb144adf	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:12:58.325	down	4	\N	tcp
23ac92f2-1dd0-422b-88cf-d8cab38d0670	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:12:58.328	down	7	\N	tcp
a983f298-5b3d-478c-afe3-365a151e28a5	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:12:58.342	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
41efa67a-885e-4626-b84c-daee5cc4554e	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:12:58.374	up	35	\N	tcp
feba6ce9-7c2d-4fa0-ae23-f0bed2dfb5e0	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:12:58.375	up	35	\N	tcp
30c064d1-d870-4dc5-bce1-c2e6170912ed	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:13:28.36	down	4	\N	tcp
2b63bd1f-a56d-459d-900b-5dea03416dba	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:13:28.362	down	7	\N	tcp
da1d24fa-b328-48c1-b572-d63e6b2d0f02	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:13:28.382	down	4	connect ECONNREFUSED 127.0.0.1:8020	tcp
c4987e87-9a9f-44f8-a17c-eeca628aab2e	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:13:31.379	down	3001	TCP connection timed out after 3000ms	tcp
521605c5-fecd-4f15-8ea8-6fc1c4e14742	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:13:31.387	down	3000	TCP connection timed out after 3000ms	tcp
05b3aed8-eccc-4a34-882a-0433be572f12	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:13:58.388	down	4	\N	tcp
012752ce-3f8c-45cc-9be9-caac9d549278	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:13:58.393	down	8	\N	tcp
298d371e-f50b-484a-ba6b-f9a480fac53c	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:13:58.409	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
93b10734-aa91-4975-b168-01c95d1e5452	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:14:01.409	down	3002	TCP connection timed out after 3000ms	tcp
8d7a0a89-1e71-4cca-9342-4c2d41874616	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:14:01.42	down	3000	TCP connection timed out after 3000ms	tcp
1e78241a-47a4-4eed-bf0a-5d0ffcb6e2d5	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:26:38.865	up	2	\N	tcp
834666af-1332-4068-9885-38a985fc48c2	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:26:41.869	down	3000	TCP connection timed out after 3000ms	tcp
9f35cb46-b185-42aa-85ac-1ca41c56ff0c	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:47:09.147	down	6	\N	tcp
fa1b5137-565c-4737-b26b-0ee733a9fba5	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:47:09.17	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
c288e207-a0c1-48c7-aade-e1a3c20ace18	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:47:09.17	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
04521132-95ec-44fb-b2c8-81c1217f2e47	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:47:09.174	down	0	connect ECONNREFUSED 127.0.0.1:4100	tcp
2c397231-be4f-4464-a774-c8786bb68d86	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:47:09.175	down	7	connect ECONNREFUSED 10.0.0.200:3100	tcp
eb414257-97f5-4130-9c93-b741d6b5b2bf	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:47:09.181	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
44921609-fc2f-4670-a3c5-8ffeee96dd55	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:02:21.837	down	1	connect ECONNREFUSED 127.0.0.1:8555	tcp
05f97255-d8bc-4886-bcbf-b618a05aaee3	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:02:21.843	up	1	\N	tcp
ee174f3d-a059-4a88-87e0-840d59becdee	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:02:21.876	up	34	\N	tcp
c2f52387-e629-4d0c-8fee-7837e36d2d12	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:02:24.836	down	3000	TCP connection timed out after 3000ms	tcp
e4d1e351-765a-4515-9e78-1eec2494bb6b	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:02:51.804	down	3	\N	tcp
61e65227-0ef9-40ed-b6f0-e9776b5fa74c	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:03:21.806	down	5	\N	tcp
0feec620-b368-4209-887c-befd0e613cbe	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:03:21.814	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
1e67bd72-5193-49c0-bb53-713afcbf8b6d	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:03:21.816	up	3	\N	tcp
b78af917-8815-407d-bd44-b0a70f9a1af2	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:03:51.812	up	5	\N	tcp
fac9c7d8-d884-4fe4-b218-470badafad67	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:03:52.077	up	223	\N	tcp
b30ea1ec-b775-4f1a-9621-b39f63cb82c6	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:03:52.076	up	226	\N	tcp
33127bfd-9275-4b5e-8a14-12c52d2503d5	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:03:54.841	down	3000	TCP connection timed out after 3000ms	tcp
c68c7c3a-9568-469b-8fe6-76e190f3c485	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:04:21.803	down	2	\N	tcp
fc5c7c77-ad77-4b9d-b555-3506f5a3a298	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:04:21.807	up	4	\N	tcp
7ffe1f95-9d74-489c-98f8-65552b8cdeb3	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:04:21.82	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
1bc9434c-d828-45b6-a936-2e9e5d8c736d	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:04:21.823	down	1	connect ECONNREFUSED 127.0.0.1:6875	tcp
f6092c91-1563-4e86-a2fb-af2d6559fcb0	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:06:28.065	up	5	\N	tcp
aa6ecf06-563e-4f3d-baa4-1e20af5e6b6f	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:12:28.778	down	25	\N	tcp
b8b858d0-6018-45dd-9e7b-e8be431ca602	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:12:29.011	down	23	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
32f3da17-e864-4430-bff4-a5e2215aa78a	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:12:58.323	down	3	\N	tcp
03fcb8ab-8d0e-44d2-b579-920e0cfcdd5e	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:12:58.327	down	6	\N	tcp
69cec0ee-9905-4279-815b-cf1b9315de7a	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:12:58.343	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
9180bfd4-ae8a-4ccc-825e-cd147ec45977	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:12:58.376	up	37	\N	tcp
29afd0ba-ebd2-4d10-b6fb-04804e971f82	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:13:01.349	down	3001	TCP connection timed out after 3000ms	tcp
adc95135-3807-4ecf-bf95-70143462d914	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:13:28.358	down	3	\N	tcp
81d8ea07-bff2-4cee-87b6-8d1b2aa9275b	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:13:28.366	up	10	\N	tcp
a3116562-d80a-475c-80d6-6139498c1e51	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:13:28.382	down	5	connect ECONNREFUSED 127.0.0.1:7000	tcp
ed7e2ad0-c50b-41e1-95aa-e77141c8786a	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:13:31.38	down	3002	TCP connection timed out after 3000ms	tcp
41e6c6ba-fffd-4cac-bcca-ee2d85fe1565	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:13:58.388	up	3	\N	tcp
8509da3f-5c8d-452e-8604-4d2f7dbeba35	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:13:58.393	down	8	\N	tcp
b4e3787e-c8ce-4779-be2d-5f63042c76d8	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:13:58.412	down	4	connect ECONNREFUSED 127.0.0.1:8088	tcp
612ec4e5-a65d-4d80-9b3d-c7250ba9a291	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:26:38.873	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
513750b2-b7f3-4a4b-a3b0-dce4c9e998e4	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:26:38.875	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
17ddb8eb-0cea-4b2f-badf-e5934acc367a	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:26:38.877	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
9a0e475a-35ca-4069-aab0-e22848549c6e	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:26:38.881	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
b92cb3a9-ca59-4c32-bfc5-3a9b157e378f	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:26:38.883	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
c591dcb5-eedb-4787-b067-7992774523ee	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:26:41.858	down	3000	TCP connection timed out after 3000ms	tcp
71abc293-179d-4776-b2e8-33e652848a42	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:26:41.863	down	3000	TCP connection timed out after 3000ms	tcp
e7c45ff1-8036-4f22-9103-c8ff937b0cd6	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:47:09.176	up	7	\N	tcp
0a01440f-1248-4e3c-8210-3b05d96d4d7a	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:47:09.176	up	7	\N	tcp
8f508519-99be-4519-9e37-c7c6a6ffdda1	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:47:09.18	down	2	connect ECONNREFUSED 127.0.0.1:7000	tcp
089a34a2-9d48-41cc-a9dd-eb6d38ea4388	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:47:09.18	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
0729b924-8b29-4004-b188-084fa4d775e2	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:47:12.167	down	3000	TCP connection timed out after 3000ms	tcp
8805e4df-df15-4058-bcc8-0054f2921ab1	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:47:12.169	down	3000	TCP connection timed out after 3000ms	tcp
39842de5-eafa-4a20-9743-f74e1a4ff64e	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:47:12.174	down	3000	TCP connection timed out after 3000ms	tcp
eb5ab9a2-64df-48df-9dc2-fbe9e78af8e4	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:47:12.179	down	3001	TCP connection timed out after 3000ms	tcp
31c12782-e138-4c7d-a49a-9a2231c974fb	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:02:21.877	up	34	\N	tcp
66de411d-9a45-45c9-87c6-e5fb0015601f	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:02:24.836	down	3000	TCP connection timed out after 3000ms	tcp
7d530129-6a4b-4565-b942-15717ce7f4cd	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:02:51.803	down	3	\N	tcp
b79cbad4-3ee2-4dd1-a0e5-5ccc5cba56b2	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:03:21.805	down	3	\N	tcp
c3468ca8-0b29-44a9-a102-2005f6c99c4f	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:03:21.816	down	3	connect ECONNREFUSED 127.0.0.1:6875	tcp
4471ae7e-4cc6-40fc-9237-8e44a852181f	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:03:21.821	up	9	\N	tcp
4708837a-eb1e-49b8-83ab-ea656c8ff8f2	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:03:51.812	down	5	\N	tcp
5125e4be-bc91-4274-9ec1-6a7fadab3c52	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:03:54.841	down	3000	TCP connection timed out after 3000ms	tcp
8a451027-d5e5-4f76-8bc6-1938274a63c5	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:04:21.803	down	2	\N	tcp
7fce1680-6aec-4764-844b-1c0a1d70ae4a	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:04:21.805	down	4	\N	tcp
a62dd811-7efe-4b40-be5f-adfdaa7d569f	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:04:51.835	down	2	\N	tcp
d21726fc-de80-4042-9085-fa2760326ce6	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:04:51.838	down	4	\N	tcp
71ce47eb-1adb-4289-8f6b-1f37833b92d1	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:04:51.85	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
2a16e2ff-145e-47ab-b59a-69a9ac86930f	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:04:51.857	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
16241f3b-a985-42b7-bfc0-1416e88619a4	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:06:28.065	down	5	\N	tcp
2198cc51-e0a1-4e0f-b0a3-47f27feea38e	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:06:28.068	down	7	\N	tcp
fbe79d9e-7510-4f54-afac-333904c185fc	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:06:28.083	down	2	connect ECONNREFUSED 127.0.0.1:7000	tcp
a258ae1b-0eb0-4f8e-9535-005ceb51b9be	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:06:28.107	up	26	\N	tcp
ef78cd11-95e9-4935-9678-9cbfbf0336a0	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:06:28.109	up	28	\N	tcp
53210a67-bfb7-4755-a0fb-313956c774aa	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:06:28.115	down	2	connect ECONNREFUSED 127.0.0.1:9020	tcp
a57dc336-e52c-477a-942b-0eb3216128e4	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:06:31.081	down	3000	TCP connection timed out after 3000ms	tcp
51f06e78-19d6-4287-9b77-733f6a1fcaef	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:06:58.092	down	6	\N	tcp
32035700-e09a-453f-8807-a01f55fd7341	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:06:58.095	down	9	\N	tcp
76929322-2180-41a3-98c9-f56823fa2a26	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:06:58.107	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
e0b1925b-05df-4537-a803-6a9fea2aa76e	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:06:58.112	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
c9c379c3-93ae-4c96-990e-f4e1831531a7	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:06:58.115	up	12	\N	tcp
ca15e813-f380-4bed-8463-18cfcdfba113	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:06:58.122	up	5	\N	tcp
3794034b-4184-49b3-96e2-71923694323d	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:07:01.104	down	3000	TCP connection timed out after 3000ms	tcp
d7cade14-5d23-43a9-ad56-692b1a2a8fde	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:07:01.106	down	3003	TCP connection timed out after 3000ms	tcp
9ba05dd4-fe3c-4f79-a4c2-0a5292064a23	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:12:28.786	down	32	\N	tcp
6965b522-5ddd-44e8-a6da-57e087763248	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:12:28.937	up	24	\N	tcp
45140e81-b747-4523-82ba-ec25b2953568	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:12:29.023	up	28	\N	tcp
032dcf74-c285-4fec-9059-b18322f2c801	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:12:29.041	down	31	connect ECONNREFUSED 127.0.0.1:8078	tcp
e8081393-b5c8-4765-8f29-d665f0e0f651	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:12:29.051	down	38	connect ECONNREFUSED 127.0.0.1:9001	tcp
13c63501-6ec7-4285-9f61-fa28aba6e990	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:12:31.941	down	3027	TCP connection timed out after 3000ms	tcp
484b9128-49f5-4b32-89b4-8ab6a73a2b04	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:12:58.324	down	4	\N	tcp
fe26ba04-7c63-4186-be92-46f8e13a2989	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:12:58.377	up	37	\N	tcp
b99671c5-2d98-4b40-9404-dc173456efc1	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:13:01.349	down	3001	TCP connection timed out after 3000ms	tcp
3d324ab3-b7f9-4774-9744-ddd00ebeade0	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:13:28.359	down	4	\N	tcp
dc381aeb-899d-4379-8162-c30810e63544	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:13:28.362	down	6	\N	tcp
1c4f6956-8c5f-4c81-b1aa-368a104a71e6	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:13:28.382	down	5	connect ECONNREFUSED 127.0.0.1:8555	tcp
107bdacb-2e9a-42b7-a263-85ffea55220a	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:13:31.379	down	3002	TCP connection timed out after 3000ms	tcp
29147700-ed9e-47d6-a445-b676edf62e80	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:13:31.388	down	3002	TCP connection timed out after 3000ms	tcp
786ada2d-c2a2-43ed-a030-ee4b50f6d439	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:13:58.39	down	5	\N	tcp
b732ffd3-7abb-44fe-93d8-fffd4479fb99	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:14:01.409	down	3001	TCP connection timed out after 3000ms	tcp
6413219b-1d46-4a76-a954-235b3ba1b655	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:26:41.872	down	3004	TCP connection timed out after 3000ms	tcp
6c2798f5-185e-4880-8a90-89a0b142cea2	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:47:09.176	up	7	\N	tcp
05a09f12-89b4-49e1-a245-413cca3b5a1e	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:47:09.177	up	8	\N	tcp
4c72cc9a-5f02-40d5-a328-f138cd5d23bd	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:02:51.804	down	3	\N	tcp
6fed041a-d04d-4516-94e9-02367029b759	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:02:51.805	down	4	\N	tcp
3811d398-3fef-45e6-bf06-53e72cded80f	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:02:51.815	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
5282b3dd-d8b3-4c98-acac-d8eb8572964f	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:02:51.824	up	12	\N	tcp
2cbdf6f7-52e9-4394-9cab-d1f5302e911c	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:03:21.803	down	1	\N	tcp
44a41b02-ab79-4120-bfb6-781802cfe3bd	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:03:21.805	down	3	\N	tcp
f9d9e435-1f8d-45ea-aaba-848c10a4fa74	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:03:21.827	down	2	connect ECONNREFUSED 127.0.0.1:9000	tcp
b7a55a31-5a22-43e6-b305-ae02b56a2b0d	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:03:51.81	down	3	\N	tcp
e824ca63-960c-49aa-94ea-1631ff728111	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:03:52.076	up	235	\N	tcp
49e6b27b-5fc7-4796-9082-4e272c00f798	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:03:54.84	down	2999	TCP connection timed out after 3000ms	tcp
ea8f7726-20d7-4f99-be17-b9c814f40c7d	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:04:21.803	down	2	\N	tcp
95a81053-b26d-4b31-9f3a-5f54f9ff98f2	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:06:28.067	down	6	\N	tcp
6c073310-96da-4c5c-9958-2719c4db54fe	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:06:28.084	down	3	connect ECONNREFUSED 127.0.0.1:8080	tcp
8b11611d-76fc-4257-ba0b-f7031e40314a	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:06:28.109	down	28	connect ECONNREFUSED 10.0.0.200:3100	tcp
86399768-cfa5-4e5b-91cb-2baae47793f8	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:06:58.089	down	4	\N	tcp
f561307d-e1a4-440a-94ba-21b8b8f80eaa	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:06:58.092	down	7	\N	tcp
14a1302a-08f6-47e3-b6eb-85809be0a26c	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:06:58.094	up	8	\N	tcp
20a0b8c8-4862-49ff-bc63-39a5add4f0f4	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:06:58.115	up	11	\N	tcp
2925ca97-4b26-4f7b-b526-54e2903cbd2a	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:06:58.117	up	13	\N	tcp
50a0e625-3fb8-4040-8980-89b9e99b1b2e	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:06:58.121	up	7	\N	tcp
1f8fcedb-4a50-432f-b716-b86ee119622f	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:12:28.771	down	20	\N	tcp
80add964-58ef-41b0-858b-b4ba8fa383b9	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:12:29.028	down	24	connect ECONNREFUSED 127.0.0.1:7000	tcp
343b8444-c0a2-41e4-98d0-a52ca8c17682	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:12:58.326	up	5	\N	tcp
68e856fe-2960-41b7-a42e-c05892014d50	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:12:58.329	down	8	\N	tcp
67e9a5dc-ac59-4514-8e4e-6aa645b790a6	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:12:58.344	down	4	connect ECONNREFUSED 127.0.0.1:7000	tcp
36e8e8c5-9f70-46ba-a175-548f23eccade	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:12:58.349	down	1	connect ECONNREFUSED 127.0.0.1:8556	tcp
0cd06ed0-9a2e-47aa-9d5f-7f77aab46a41	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:12:58.353	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
32de39f9-f04f-43ef-aeff-024be7b371cf	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:12:58.357	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
d44598e6-0cfa-4908-856f-d69c6ad2aeeb	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:12:58.361	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
07079ba9-efe6-432f-a1fe-d4d13567577b	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:12:58.365	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
2b932123-3683-4a63-883d-3572e945fd1e	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:12:58.369	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
9c3d8e66-43ca-4311-8096-b9075a49a2cc	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:12:58.374	up	35	\N	tcp
313347e3-75de-48fe-83b8-19561c0df945	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:12:58.378	up	31	\N	tcp
7d28f02e-9d77-4b36-84d5-f121adbe5622	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:13:01.34	down	3000	TCP connection timed out after 3000ms	tcp
c50320b3-206d-49b4-9380-e78396be9f8f	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:13:01.349	down	3001	TCP connection timed out after 3000ms	tcp
1cefebbf-f960-492c-b1cd-3495b96e261d	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:13:28.359	down	3	\N	tcp
fe3d2ec4-f814-4d45-a41d-f5d4f4db0d1b	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:13:28.362	down	6	\N	tcp
4da801c2-2ad0-40c7-b659-2ba1d93c3040	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:13:28.383	down	5	connect ECONNREFUSED 127.0.0.1:6875	tcp
5de91bc9-7287-4434-83d3-184f6d0599ba	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:13:28.387	down	1	connect ECONNREFUSED 127.0.0.1:8088	tcp
02ec6184-6462-4b30-bee5-59193b1b7b12	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:13:28.392	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
eea19ab9-f47a-4511-83ec-038e168cdaba	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:13:28.396	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
b9b8fa6d-db45-4e8e-8fbc-8187878563be	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:13:28.4	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
415db999-eb5d-4202-9267-314617370aa4	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:13:28.405	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
77b94b7d-8fba-46e1-88c6-770354fd1be0	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:13:28.409	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
ea85868f-d13a-4efd-bb58-9806ed244ab3	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:13:58.39	down	6	\N	tcp
a2537dad-053b-4995-bc6e-8b8484594c74	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:14:01.409	down	3001	TCP connection timed out after 3000ms	tcp
1bc88184-6366-4ff1-9b58-27a6b3405a91	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:41:06.503	down	4	\N	tcp
7598098f-83c2-42e0-ab73-998abbae3722	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:41:06.509	up	8	\N	tcp
7d3b6bd6-41ca-4e60-a069-b3be9e28d877	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:41:06.548	down	4	connect ECONNREFUSED 127.0.0.1:7000	tcp
67b9fc5b-c2c7-4eea-a88d-847e94550446	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:41:06.553	up	7	\N	tcp
e7abd04b-d243-45b5-a81d-a40defdb45eb	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:41:34.496	down	4	\N	tcp
a2c2143f-4c5b-47e6-9b4f-20a45d155510	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:41:34.508	down	2	connect ECONNREFUSED 127.0.0.1:7000	tcp
418e6978-e7b5-4678-bc8d-824ff91d2d78	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:41:34.631	up	125	\N	tcp
e33d7e21-1bf8-4430-9187-21857cb3b283	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:41:37.512	down	3000	TCP connection timed out after 3000ms	tcp
c22c66c2-4c27-4eff-a323-a78d6700a007	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:47:09.176	up	7	\N	tcp
9c8449e0-31b8-43b5-8550-da9d66ff1da4	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:06:28.067	down	7	\N	tcp
152800fc-9542-49ef-a0ec-67d1dc28eea4	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:06:28.083	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
ccb7874a-7b20-4b4e-b5cc-6883ef9c1c41	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:06:28.105	down	0	connect ECONNREFUSED 127.0.0.1:8088	tcp
05a10aa2-3372-4157-9fe8-c95edd0bbe5f	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:06:58.09	down	5	\N	tcp
9f6acfbb-9a1d-4269-97f2-771406f79866	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:06:58.093	down	7	\N	tcp
471647c4-e2a8-4096-bd1c-5fa577214c84	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:06:58.095	down	9	\N	tcp
d93129c7-cc36-49f4-9e3f-4f3876849fd9	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:06:58.107	up	3	\N	tcp
100bebc4-f673-45e6-a4f7-de52be208124	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:06:58.116	down	13	connect ECONNREFUSED 10.0.0.200:3100	tcp
4aa85790-8824-451f-864a-170ef9b26b1c	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:06:58.122	down	4	connect ECONNREFUSED 127.0.0.1:8080	tcp
d935df5b-410c-4e96-89fa-45dbb2adc146	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:12:28.782	down	29	\N	tcp
2091accb-4dd0-4a1b-8f43-c9571d0f8e7a	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:12:28.8	down	45	\N	tcp
f4389612-68d2-4efd-93ca-4ac4c136f81a	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:12:28.806	up	49	\N	tcp
1dd8e4d7-e863-4f58-9406-38a3fbd67617	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:12:28.778	down	25	\N	tcp
754025fa-1c2d-4366-b8cf-cbe3634be9a8	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:12:29.039	down	31	connect ECONNREFUSED 127.0.0.1:9006	tcp
167be6e0-c0a2-4884-a2ca-53803aa98c23	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:12:31.919	down	3004	TCP connection timed out after 3000ms	tcp
161a418a-d8e5-4c36-9b4c-31fc5fadded2	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:12:31.935	down	3020	TCP connection timed out after 3000ms	tcp
24c1d133-ecbf-4c53-b7b2-c76f10e238ce	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:12:58.324	up	3	\N	tcp
9a810d7c-5b5c-400c-a2f6-65b0cb37362e	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:13:31.379	down	3002	TCP connection timed out after 3000ms	tcp
c7c5dbb4-175c-4ee7-b074-70c3a038b032	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:13:31.386	down	3000	TCP connection timed out after 3000ms	tcp
eb09cb4e-7949-4dc2-89d5-6e69d0fc596b	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:13:58.389	down	5	\N	tcp
84a9019f-60b9-4e7c-8bcd-7af427ccce16	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:13:58.39	down	6	\N	tcp
aa3dc995-cad7-4502-9fa4-22a23d6c349b	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:14:01.408	down	3001	TCP connection timed out after 3000ms	tcp
8d48ad0c-2925-43f7-b40c-d54d38ad33b7	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:41:06.507	down	7	\N	tcp
1f7e1309-02eb-4432-8344-ea0a4d6307a1	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:41:06.517	down	17	\N	tcp
50489fb1-b21b-4d01-ba73-aa66ea18a1fe	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:41:06.559	up	4	\N	tcp
9d744dc7-9f8a-4548-a2a7-4581fef5ce55	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:41:09.556	down	3001	TCP connection timed out after 3000ms	tcp
32d49135-0cf9-430b-8439-2a39ab6c097d	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:41:34.496	down	4	\N	tcp
8f9e8f8d-dc03-45d2-96f1-9074ac209ff4	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:41:34.508	up	2	\N	tcp
61a2cf8c-86db-41cf-a6a8-e92ec1025f83	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:41:34.631	up	125	\N	tcp
9174d8ba-9614-401d-8bb1-10671d7b570a	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:41:37.512	down	3000	TCP connection timed out after 3000ms	tcp
a46c8221-dc55-437b-9555-22f6d3115c39	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:53:23.62	up	3	\N	tcp
bba59dd9-7842-471b-817b-215b2b3ebc90	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:53:23.622	down	4	\N	tcp
ea2b2971-45ca-4700-ae62-98100e22674e	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:53:23.622	down	4	\N	tcp
47f51234-c565-4229-801c-a9b04bcf1e2a	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:53:23.67	up	13	\N	tcp
7111e4c8-9745-4036-80e0-39676f912d36	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:53:51.582	up	7	\N	tcp
06c99826-6ff0-4d8e-bdbf-86eb69c5cdb8	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:53:51.596	up	4	\N	tcp
01dfdbce-7389-4522-89b6-416aad7bfd47	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:54:21.601	up	2	\N	tcp
2fa42776-a623-4993-9ee6-e9c43fcefb14	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:54:21.77	up	150	\N	tcp
bdef9251-326e-413e-9275-bdbd0780671d	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:54:51.611	down	3	\N	tcp
f1c40800-d538-40fd-a678-b32593ae1b69	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:54:51.639	up	20	\N	tcp
582419fb-ba81-487f-aabf-6a6f480b5378	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:55:21.605	down	4	\N	tcp
9340b201-2ce8-4f51-b4fe-bca661e838cd	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:55:21.627	up	5	\N	tcp
8f560c4c-59ca-4d17-9818-a623ffa78ece	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:55:21.631	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
306442fe-e0bb-40d4-b65e-5fa329043f42	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:55:24.617	down	3001	TCP connection timed out after 3000ms	tcp
b2a2c629-0e90-4524-b369-527fea61bc8c	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:55:24.621	down	2999	connect EHOSTUNREACH 192.168.1.221:4001	tcp
66be5f2b-7afb-435f-a991-df49a949abf4	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:02:51.822	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
e9d6050b-4395-4f7a-838d-11639f41c1e8	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:06:28.068	down	7	\N	tcp
3ed8df81-a516-4c1a-9bdd-7dee935a97f9	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:06:28.083	down	3	connect ECONNREFUSED 127.0.0.1:6875	tcp
2afe9fe0-128e-4651-af9d-fafd924caba2	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:06:28.092	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
afa68dee-4c41-41d6-8c53-c2eabb43512a	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:06:28.097	down	0	connect ECONNREFUSED 127.0.0.1:8555	tcp
8ca2e631-c092-47d7-9c91-07a6b7f7348d	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:06:28.101	down	0	connect ECONNREFUSED 127.0.0.1:8556	tcp
80f35337-cb53-4387-a7fa-c16ff92ed6e4	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:06:28.11	up	20	\N	tcp
4f93b15a-6660-4479-884e-93e5b9e88a71	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:06:28.116	down	2	connect ECONNREFUSED 127.0.0.1:9006	tcp
93017605-ec17-4a90-803a-a6fdcd626bbd	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:06:28.116	down	2	connect ECONNREFUSED 127.0.0.1:9001	tcp
8d1fe2a5-eeb8-48ef-8fea-9844431cf97a	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:06:31.082	down	3001	TCP connection timed out after 3000ms	tcp
261bed86-2c04-427f-9683-66228e302f41	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:06:58.123	down	3	connect ECONNREFUSED 127.0.0.1:9020	tcp
cdc39951-eb81-4c6e-a970-fc103be7ccb2	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:07:01.106	down	3002	TCP connection timed out after 3000ms	tcp
d6102e8a-26e6-49f1-b5ea-f068f029a345	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:12:28.767	down	16	\N	tcp
ea408320-9118-470c-a153-ab72c0c10ede	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:12:28.773	down	21	\N	tcp
dc2fc5a0-cb1e-4003-afe4-9ecbf4645793	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:12:28.927	up	15	\N	tcp
03f4b2e9-0dd0-457f-961d-dfd077d36ee8	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:12:28.96	up	46	\N	tcp
d444923d-cbac-4fd8-a1fc-efdb04356a27	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:12:29.035	up	29	\N	tcp
a930f2c0-cbe2-48a3-a867-59c55f8c16ee	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:12:58.324	down	3	\N	tcp
607b2668-7e54-4596-abdc-0976f5fab283	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:12:58.327	down	6	\N	tcp
ccc863d2-245c-46de-83f0-2a1d46b938cb	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:12:58.343	down	3	connect ECONNREFUSED 127.0.0.1:8080	tcp
ffccc078-5893-47bf-88d7-e84d7b4128bb	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:12:58.349	up	2	\N	tcp
d92ccac4-8b99-4c6d-bea6-56d1bd2bf2d9	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:12:58.374	down	34	connect ECONNREFUSED 10.0.0.200:3100	tcp
68cc524a-8774-419c-a64e-0f0366b4549f	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:13:28.36	down	5	\N	tcp
74aa6007-041b-4829-95ab-0d4c2b5d3ab1	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:13:28.363	down	7	\N	tcp
36c9e9e4-8219-4697-9f81-68f1c5ccbf55	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:13:28.383	up	5	\N	tcp
251ecb73-e182-44a5-a37f-73a8b6e7e739	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:13:28.387	down	1	connect ECONNREFUSED 127.0.0.1:4100	tcp
a7d60922-65f0-48bc-a08a-fa399f00499b	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:13:31.377	down	3000	TCP connection timed out after 3000ms	tcp
fe90e183-5111-48ea-a2b9-0ac6ca04c77d	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:13:58.392	down	7	\N	tcp
add2cc2e-f1a6-4531-93a4-8150d8d35246	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:13:58.391	down	7	\N	tcp
bf39fd10-cf33-4393-b1cc-b5996501824a	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:13:58.411	up	4	\N	tcp
d022f1d0-e4b1-429a-9a59-6389a3c21108	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:41:06.513	up	11	\N	tcp
5a720592-d7b9-4366-b7be-ad17857c6671	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:41:06.504	down	4	\N	tcp
c56000b5-43e0-473e-b510-c8914964f5f6	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:41:06.548	up	4	\N	tcp
97a071d5-ef0e-45a9-a979-66934078a36c	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:41:06.553	up	9	\N	tcp
100ebfe3-7edc-4d77-9467-9be1a3fa89e9	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:53:23.626	down	7	\N	tcp
595b240a-472f-46e0-90ae-1a34759e69cd	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:53:23.626	down	8	\N	tcp
884fdce7-2093-4491-aefd-9ba91b0eaa9f	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:53:23.67	up	13	\N	tcp
48932658-6d30-47c7-91e5-b428c21f7fde	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:53:51.583	down	8	\N	tcp
1f338990-a6fc-4e02-90a9-73ed2f3ac2d4	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:53:51.603	up	10	\N	tcp
651e74d4-0b28-4612-a0b9-bb62ca4fa4f9	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:53:54.593	down	3001	TCP connection timed out after 3000ms	tcp
aab07788-9672-403a-9184-f5ed39f0ecc6	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:54:21.77	down	155	connect ECONNREFUSED 10.0.0.200:3100	tcp
fb0cbbce-7479-43a7-a984-a841aea156e3	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:54:51.611	down	4	\N	tcp
0769eee0-a0a6-492b-8142-c8cb1e2442cf	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:54:51.641	up	21	\N	tcp
a6740870-4966-4725-b8d2-35f4018e140e	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:54:54.62	down	3000	TCP connection timed out after 3000ms	tcp
46bf45ea-1494-4086-bc94-906c002c505e	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:55:21.606	down	4	\N	tcp
33a3e6fa-e4c6-4321-a45c-e140ca6a092e	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:55:21.619	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
3a156a02-28ec-46ea-be18-a3227fbf1176	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:05:00.202	down	9	connect ECONNREFUSED 127.0.0.1:8556	tcp
1be343d2-2cad-4b03-a0af-dfb7d702ce16	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:05:58.065	up	4	\N	tcp
b4931e94-24c5-45fb-824d-fb559eef72cd	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:05:58.07	down	9	\N	tcp
8a5e281b-f7df-4b87-afcd-e3458a43604e	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:05:58.234	up	153	\N	tcp
d8901b2f-d3d6-4821-ae1e-69bd75491de9	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:06:01.093	down	2999	TCP connection timed out after 3000ms	tcp
4234fb3c-59bc-451c-819c-c9da3e059f59	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:41:06.516	down	15	\N	tcp
b1fa357a-4e0c-4d0c-98a2-857b1f5cf0dd	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:41:06.506	down	6	\N	tcp
40dd40f3-c4f0-4d7b-8ce0-9df17642a47d	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:41:06.549	down	4	connect ECONNREFUSED 127.0.0.1:8080	tcp
fb9edfed-3906-47d9-b6a8-05e789580294	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:41:06.554	up	8	\N	tcp
d3708156-5cec-496f-a1b6-8be9bf3e1b14	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:41:06.558	down	4	connect ECONNREFUSED 10.0.0.200:3100	tcp
ccf813dc-19a3-4699-bb9d-6da4b53b50d1	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:41:06.562	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
75d822d0-72cc-4c02-a31a-c45eed4fa13d	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:41:09.545	down	3000	TCP connection timed out after 3000ms	tcp
6e2b0ee2-dde4-4d1d-b12c-3316cdebb2be	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:41:09.556	down	3001	TCP connection timed out after 3000ms	tcp
aa6d32bd-0fe1-47e3-8077-9789c3273cd3	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:41:34.495	down	3	\N	tcp
9381a001-1a02-4fa5-86f6-af964c665a65	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:53:23.626	down	7	\N	tcp
810456ca-196b-42f1-8ec5-806273faf540	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:53:23.622	down	4	\N	tcp
d513487d-9836-45a0-b445-b000cc8b1917	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:53:23.623	down	5	\N	tcp
58fc796d-f1b7-487a-9d75-e19582004570	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:53:23.654	down	4	connect ECONNREFUSED 127.0.0.1:6875	tcp
ebe407b4-4f6c-497a-8156-5ccc6e9b091b	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:53:23.669	up	19	\N	tcp
362515db-4de1-4770-be73-198197585a9d	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:53:51.578	up	3	\N	tcp
1f93f78c-d53d-41e0-9aac-63a4d17dd8ec	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:54:51.61	up	3	\N	tcp
98aeca04-b00f-48f1-a030-3cf761ab7cd8	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:54:51.64	up	20	\N	tcp
9987f1db-b3e5-435b-a31b-4e8b3d4eaccf	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:55:21.605	down	3	\N	tcp
57c6773e-8712-4367-af03-eb54c70030f3	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:02:51.825	up	12	\N	tcp
9dc67b86-d04e-4198-b300-043b08373638	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:03:21.803	down	2	\N	tcp
fd396338-0f84-48d6-a513-ab4767fd2805	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:03:21.806	down	4	\N	tcp
59c36471-e628-41dc-8dcf-c9500b6c86c7	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:03:21.821	up	9	\N	tcp
8d64551f-5949-4fcf-a68c-bd54a543ed3b	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:03:51.81	down	3	\N	tcp
64842b48-b19d-43ed-b632-58be5558412b	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:03:51.842	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
634a623b-de32-416e-b0c7-aea841da29d5	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:03:51.85	up	1	\N	tcp
f7c9f511-b4d0-415e-9c72-4356653bd7d8	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:03:52.076	up	235	\N	tcp
e395e1b3-98f5-4499-ba83-194f2369a4d3	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:03:52.076	down	235	connect ECONNREFUSED 10.0.0.200:3100	tcp
630e0119-855a-4ee3-9df7-5b018607374a	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:03:54.842	down	3001	TCP connection timed out after 3000ms	tcp
94ff0b6f-8198-4da5-aa56-b3964829e47b	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:03:54.85	down	3001	TCP connection timed out after 3000ms	tcp
5fc35fae-d0c5-4522-a3a7-8800b4dab9dc	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:04:21.803	down	2	\N	tcp
faaa49a4-61ff-4622-9ea3-570aa65f7a73	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:04:21.807	down	6	\N	tcp
304a5ca9-d78a-4c6a-a39f-ba4da7bb7ba0	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:04:21.817	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
9ca7930e-2c39-48d5-80cc-79e3144a4b93	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:04:23.401	slow	1585	\N	tcp
39fdbb38-6cf6-47d0-8831-54588e24e96c	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:04:23.4	down	1584	connect ECONNREFUSED 10.0.0.200:3100	tcp
dd105d0b-5d27-4b34-8ad0-0019caa5d738	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:04:51.836	down	3	\N	tcp
f14b9693-bfa3-41e8-b620-834e8fa74e08	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:04:51.838	down	4	\N	tcp
e7802085-0ed5-4368-8ad6-360a275962ee	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:04:51.85	down	3	connect ECONNREFUSED 127.0.0.1:6875	tcp
b943b767-e12d-44d4-b14c-7b8abde49307	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:04:51.881	up	20	\N	tcp
6fda5ade-25cf-4393-9862-881f674f4319	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:04:54.848	down	3001	TCP connection timed out after 3000ms	tcp
cf2e5b0f-42f4-4ad3-ae15-06d3224401a4	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:05:21.834	down	3	\N	tcp
87bb03b2-7d89-4010-a10f-16e1942a2d08	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:07:28.115	down	3	\N	tcp
4670eb9b-3726-405e-a985-3a9f47227b66	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:07:28.118	down	5	\N	tcp
9551d4a3-83f4-4a84-9157-ad3032255750	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:07:28.121	down	8	\N	tcp
a9258272-142c-4e98-a546-1fd740966206	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:07:28.136	down	4	connect ECONNREFUSED 127.0.0.1:8020	tcp
ca9faf5b-0464-4d85-af85-23200eb37f6f	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:07:28.139	up	6	\N	tcp
bb98737d-bf8f-4734-af0a-3619d41138db	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:07:28.143	up	10	\N	tcp
661d7f3b-7328-4149-96d0-4b1f6bf1eef4	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:07:28.15	up	6	\N	tcp
6a44a75c-86c7-49e0-887b-ef6bcfc2a9bb	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:07:58.14	down	6	\N	tcp
14dd347d-1825-495c-b057-4e8dd2dd9d3a	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:07:58.16	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
6588ac23-c88a-4824-9e5e-0b85133d1187	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:07:58.162	down	4	connect ECONNREFUSED 127.0.0.1:9000	tcp
c61d80bd-86e7-4ebd-b3c4-aaea79b3b534	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:07:58.18	up	21	\N	tcp
d6166e8c-da78-430a-ac8a-d8c6333e095f	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:07:58.181	up	23	\N	tcp
5046d217-9c3c-4339-ad47-5280e2bfe167	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:12:28.784	down	31	\N	tcp
53a2d877-1a15-4f3a-9fc3-d013c9b07862	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:12:28.774	down	23	\N	tcp
77629327-06aa-4691-b5ec-0efa28d1d943	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:12:28.943	down	29	connect ECONNREFUSED 127.0.0.1:4100	tcp
8b63b20e-8d8e-4e4a-b708-c4ba05ca3d89	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:12:28.96	up	46	\N	tcp
cf8dc420-ef14-4147-b8f2-4b30697072ef	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:12:29.03	up	25	\N	tcp
b920160d-6447-4ccd-83ed-a43a6cd5d449	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:12:58.325	down	4	\N	tcp
43ab000d-1620-47c9-a2dc-30a8a4d57df0	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:12:58.378	up	25	\N	tcp
bb8a52a1-6c9c-4390-9229-1b52dbe98bf5	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:13:01.339	down	3000	TCP connection timed out after 3000ms	tcp
021cc8f3-620e-42b4-bd84-8298c8aef619	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:13:01.349	down	3001	TCP connection timed out after 3000ms	tcp
01cb7548-c544-41f3-afb0-eb5fc80b609a	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:13:28.361	down	6	\N	tcp
4dfdee6e-374c-4f8c-8bfa-a6121709243a	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:13:31.38	down	3002	TCP connection timed out after 3000ms	tcp
1368c3ff-4b1b-45a6-85da-2e1a2026f0aa	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:13:58.389	down	5	\N	tcp
33d21798-8a65-46d9-ae62-3c16f5f2a551	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:13:58.391	down	7	\N	tcp
43928db4-56b4-4bdd-9c00-4749310cfbd7	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:13:58.392	up	7	\N	tcp
a4630b3f-e0f4-4287-92b1-658cb9e4c249	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:13:58.413	down	5	connect ECONNREFUSED 127.0.0.1:8020	tcp
f9b9aff5-eef1-45ab-bd15-a4af54bccd14	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:13:58.417	down	1	connect ECONNREFUSED 127.0.0.1:6875	tcp
043ef157-97b6-47fa-86ce-c45d122ebd6b	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:13:58.42	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
6641e7cc-bf10-404f-848b-eb9336427a86	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:13:58.426	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
e34ef23b-2ca1-4ce4-a078-2f2f6d9e8321	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:13:58.431	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
dbb04809-f63c-4bf2-a5d0-3ce32db047ad	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:13:58.436	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
5e6408fd-28ab-4ce7-908e-c11c53ff412f	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:13:58.441	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
29fa48b8-16bf-4570-a384-75d21e4c324a	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:14:01.409	down	3001	TCP connection timed out after 3000ms	tcp
2c6c85e7-22db-452c-b460-576f7ad929c2	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:41:06.504	down	4	\N	tcp
719d9cd0-666c-4bfc-8017-3d52255bac18	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:41:06.562	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
ecae5657-7a0a-48b0-b35d-c71b253264cd	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:41:09.546	down	3000	TCP connection timed out after 3000ms	tcp
4c8c93f5-f125-4f7e-a660-c7ce0d24ac76	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:41:09.556	down	3001	TCP connection timed out after 3000ms	tcp
1dbeeb8d-68fb-4d7d-8a0b-9b986cc6bb25	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:41:34.494	down	2	\N	tcp
dc236121-7c44-40f7-b0e2-941fbe5d7d5f	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:41:34.496	down	4	\N	tcp
2cc6178b-0b41-4aa9-b11c-e0b5304ce58d	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:41:34.499	down	7	\N	tcp
13b8864f-a36b-44d3-b997-f8b66517d89e	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:41:34.631	up	126	\N	tcp
369dd680-f5de-412b-885a-85a761e5a94e	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:41:34.637	down	126	connect ECONNREFUSED 10.0.0.200:3100	tcp
777329bd-95f6-4a92-b8ee-051735817f8f	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:41:37.505	down	3000	TCP connection timed out after 3000ms	tcp
f154d369-b6a3-452c-8326-f5fd340e2c91	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:53:23.626	down	7	\N	tcp
81cb2b11-e982-40df-b008-e4c2ae9201ea	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:07:28.115	down	3	\N	tcp
94403423-7fbb-46ea-a7fc-552603cd9429	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:07:28.118	up	6	\N	tcp
3574e2ca-dd5e-4feb-a892-fbeb90c1ee04	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:07:28.139	down	6	connect ECONNREFUSED 127.0.0.1:4100	tcp
825208b8-968d-4af4-9518-1ab15c503357	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:07:28.143	up	11	\N	tcp
5c16a3bf-664a-4a3f-8e31-89d054397b8f	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:07:28.15	up	16	\N	tcp
0b0566ea-22b1-4873-9396-b85ae72ca2e2	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:07:28.151	up	6	\N	tcp
52c789c6-1d21-4eae-ba0c-4e910f01a1a0	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:07:31.148	down	3002	TCP connection timed out after 3000ms	tcp
bd3dc730-f35a-4dd6-93d3-f161c97b7b4f	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:07:58.139	down	5	\N	tcp
becc6ce6-f9af-4c9f-b8fd-477b6a2ad0fa	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:07:58.162	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
48781db7-4dd9-4f9d-a29f-0cd3511fde46	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:07:58.179	up	21	\N	tcp
cf2aca74-b163-41d1-9328-de9e908dfb90	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:07:58.18	up	22	\N	tcp
2cddf5b3-bcb2-4f7d-b51a-af214604fde0	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:07:58.182	up	23	\N	tcp
eebea747-0be0-4723-9892-3dbc0700822e	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:07:58.186	down	3	connect ECONNREFUSED 127.0.0.1:8078	tcp
99caba1c-f886-48fb-8dce-23516867fcbb	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:08:01.167	down	3001	TCP connection timed out after 3000ms	tcp
b3ebf7bc-dfcb-4ec4-add7-ff780eb37c77	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:08:01.168	down	3000	TCP connection timed out after 3000ms	tcp
78f6f8ea-c82f-412b-960a-8b6e71292f12	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:12:28.947	down	33	connect ECONNREFUSED 127.0.0.1:8020	tcp
5716a4cb-7dc3-4d8c-8621-8878774d6ad2	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:12:29.032	up	26	\N	tcp
b8273815-b3d7-4084-b0e7-9bad561c4519	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:12:31.93	down	3015	TCP connection timed out after 3000ms	tcp
5b4b4b6f-4740-44f0-9455-c24983491c3c	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:12:58.325	down	5	\N	tcp
f094152e-f315-4dbb-9898-1ae5cdf0b840	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:13:31.386	down	3000	TCP connection timed out after 3000ms	tcp
d7e152c5-9c98-472c-af2d-a59d0094824f	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:41:06.506	down	6	\N	tcp
7656b5ee-5cbd-4c8d-974c-67296642f6b5	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:41:06.507	down	7	\N	tcp
fd428942-cdce-4d4a-a698-b525a06ebf64	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:41:06.548	down	4	connect ECONNREFUSED 127.0.0.1:8020	tcp
782825a2-a0ce-4232-9922-c2ce92006ca2	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:41:34.494	down	2	\N	tcp
33d4cc4e-1134-45d1-8d41-f30bdd032969	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:41:34.495	down	3	\N	tcp
d009f3fa-f875-45ab-a6d6-235a164b7b30	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:41:34.499	down	7	\N	tcp
fd759442-6524-4370-81dc-861ac14db808	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:41:34.508	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
3994242e-55d0-4841-bbef-a9f4a17099b3	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:41:34.631	up	126	\N	tcp
cd70a61f-b581-46a8-a80e-46eeb6fdb5d7	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:41:34.636	up	125	\N	tcp
da2028e8-bf49-4f8c-ac5b-02b4f04701a3	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:41:37.512	down	3001	TCP connection timed out after 3000ms	tcp
b765e1fd-3fb6-49e1-ab8e-736c4a9ebdd6	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:53:23.621	up	3	\N	tcp
6e79ed99-9962-4740-8664-300e32e64ed9	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:53:23.67	up	20	\N	tcp
c9a19c2c-69ae-4038-ab7a-e2b809609a39	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:53:51.584	down	8	\N	tcp
b3ed72a7-03c1-4528-93de-b34fef14095b	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:53:51.601	up	10	\N	tcp
e26e580f-8de3-4c91-bf9b-41c241dd4675	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:53:51.603	up	11	\N	tcp
a6f89cf3-d4a3-4983-b118-f88b5ead3d44	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:53:51.608	up	3	\N	tcp
d6c2300b-1b4f-413f-8a15-e4866c19e810	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:53:54.594	down	2995	connect EHOSTUNREACH 192.168.1.221:3011	tcp
36340180-e8fb-4e42-9347-2925e04ff292	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:54:21.601	down	2	\N	tcp
4cc48d23-c3b8-4a38-bdbd-5cc091c8ae19	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:54:21.603	down	4	\N	tcp
56f9abd4-882c-419a-925c-074a4ff2a3f8	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:54:21.605	down	5	\N	tcp
f9e8c11a-4fce-4575-b990-63b009193adb	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:54:21.769	up	155	\N	tcp
2b3759c8-0da1-418b-9080-dcdec58a441a	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:54:51.609	down	2	\N	tcp
46854857-f0f2-4634-a6f2-6982d525b158	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:54:51.611	down	4	\N	tcp
a8e35316-f5c1-4890-bb12-cd8b769b55c0	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:54:51.622	up	2	\N	tcp
055a0cac-992b-4a11-9b08-b0eadc61dbca	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:54:51.625	down	1	connect ECONNREFUSED 127.0.0.1:6875	tcp
ee0b370b-b3cb-4b17-a7a2-7038535ea819	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:54:51.639	up	20	\N	tcp
5848ce8c-84e7-40bd-93a6-b3a2092a2050	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:07:28.115	down	3	\N	tcp
99f66613-0740-42d5-a2e1-52e07f829985	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:07:28.121	down	8	\N	tcp
446aa16f-639d-4b71-ba32-e1e9121618aa	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:07:28.138	down	6	connect ECONNREFUSED 127.0.0.1:8556	tcp
1cc00bc9-77d8-43d1-9f96-0ed083b03d8a	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:07:28.144	up	11	\N	tcp
3fc5515e-bb9a-4c07-b1e7-4dc248fa3d42	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:07:58.142	down	7	\N	tcp
ce4f3311-ade8-4fe6-84ec-72b94f403571	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:07:58.143	down	9	\N	tcp
0d65c85a-7943-49f3-b2f5-6c9741b611f8	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:07:58.16	down	3	connect ECONNREFUSED 127.0.0.1:8555	tcp
5855c177-6cd5-4797-a150-158322d93758	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:07:58.167	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
03177a64-3ad3-45d2-a64c-91d985228faa	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:07:58.168	down	3	connect ECONNREFUSED 127.0.0.1:7000	tcp
83fdd57b-9524-425a-8ea6-7c47e8bd9805	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:07:58.172	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
cec7b151-e3bc-4aee-89e3-da7454d0483d	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:07:58.176	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
f6db24eb-cfa7-4958-8934-5e0c3647ff57	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:07:58.179	down	21	connect ECONNREFUSED 10.0.0.200:3100	tcp
62501aba-5fbc-49dc-a6a1-b2a3be1c637c	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:07:58.181	up	23	\N	tcp
145b594e-c3e2-4ef7-8383-0e58a00f0abf	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:08:01.165	down	2999	TCP connection timed out after 3000ms	tcp
40c7cecb-b734-45ee-a97d-03b2de57a157	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:08:01.167	down	3001	TCP connection timed out after 3000ms	tcp
74a43cf2-843f-4dea-b5f4-2f4e45c071a4	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:12:28.955	up	41	\N	tcp
91fe3cde-1778-4952-9531-5dce9c7ad17f	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:12:29.018	down	26	connect ECONNREFUSED 127.0.0.1:6875	tcp
a072d470-0957-499d-a542-91cefe2204cb	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:12:58.326	down	5	\N	tcp
4f2f0cbe-a86a-4d47-98a5-4225d44594d9	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:13:28.358	down	3	\N	tcp
12069fec-e150-49c2-bf96-e01ad370576b	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:13:28.361	down	6	\N	tcp
bbd1186f-bd55-4b62-b2af-a0fdb9726722	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:13:28.366	down	11	\N	tcp
5728741f-7ab1-4f5c-b667-864c81c0f15c	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:13:28.382	down	4	connect ECONNREFUSED 127.0.0.1:8556	tcp
ba7d8c4d-a7da-4508-aefe-bacd60651fdf	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:13:31.378	down	3001	TCP connection timed out after 3000ms	tcp
7172055b-3a2e-4204-84b2-fd401597e206	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:13:31.38	down	3003	TCP connection timed out after 3000ms	tcp
106abcb9-f897-4a88-9d66-bc757d2681a5	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:13:31.391	down	3000	TCP connection timed out after 3000ms	tcp
60d01c42-61c6-4917-9d3c-0cbf2a4edd28	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:13:58.39	down	6	\N	tcp
9ff0c572-e8f5-4dc8-9d2b-ab9e5cf7f43b	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:14:01.407	down	3000	TCP connection timed out after 3000ms	tcp
d6eb0833-24bb-410f-9b1f-db997ae63373	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:14:01.409	down	3002	TCP connection timed out after 3000ms	tcp
135b42b3-c6ba-411f-9a20-eee55ed783f2	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:14:01.418	down	3000	TCP connection timed out after 3000ms	tcp
179dd0fa-cd96-4817-be9e-34b3787afa79	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:41:06.515	down	15	\N	tcp
8f8ee94c-85f8-4dcc-8903-99590accfe51	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:41:06.505	down	5	\N	tcp
ba5befa0-ca9b-4f69-9261-87548b60e5e7	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:41:06.548	down	4	connect ECONNREFUSED 127.0.0.1:8088	tcp
e409f823-ed06-41ee-b379-503cba1706ed	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:41:06.562	down	2	connect ECONNREFUSED 127.0.0.1:8078	tcp
fad806a1-238f-476a-a88a-5f97b4b49002	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:41:09.546	down	3000	TCP connection timed out after 3000ms	tcp
b76b5909-fc60-46a3-a97c-90b4b20f9188	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:41:09.556	down	3001	TCP connection timed out after 3000ms	tcp
005eb82d-204e-451f-bf50-ed297cc5741f	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:41:34.495	down	3	\N	tcp
194c1614-88ea-4ab5-8ca8-6e2551d9de53	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:41:34.498	down	6	\N	tcp
e5eba633-8133-4cbf-b49f-a3c19ab36408	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:41:34.507	down	1	connect ECONNREFUSED 127.0.0.1:6875	tcp
948cde28-c4ee-4228-ade1-c3de7ce33db9	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:41:34.508	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
3e2c0f4f-5d1e-4fc6-9e02-2949673ff16e	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:41:34.63	up	125	\N	tcp
bb716368-a6bb-4f95-8d32-95c4ca954751	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:53:23.626	down	7	\N	tcp
a4280cfe-81ed-45aa-ab6d-f2c9bd1c7626	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:53:23.67	up	18	\N	tcp
4a2e7e52-457f-4803-be87-a1acd075b6b2	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:53:51.583	down	7	\N	tcp
5dcf1271-17f5-4874-ae3e-cc3eaf57e05e	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:53:51.584	down	8	\N	tcp
49766065-4be4-4970-9c75-6639b78a857a	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:07:28.116	down	4	\N	tcp
0535179d-174f-48bd-b836-4ddad4d03aa2	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:07:28.12	down	8	\N	tcp
3877d9df-df52-4436-ab7b-ed62f1a7ecf8	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:07:28.137	down	5	connect ECONNREFUSED 127.0.0.1:9000	tcp
2e5a5edc-0c06-4ac7-95bf-47c61463127f	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:07:28.15	up	6	\N	tcp
d7d50264-5079-4918-a154-3871869dc7a4	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:07:28.152	down	3	connect ECONNREFUSED 127.0.0.1:9001	tcp
5d6ed1a7-293d-4c46-82a6-fc6f1337ee90	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:07:31.146	down	3001	TCP connection timed out after 3000ms	tcp
75478141-9375-4e0b-8139-c7710e579309	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:07:58.138	down	4	\N	tcp
30037639-1c93-48a3-928e-ad0f5c3226f2	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:07:58.14	down	6	\N	tcp
812199e8-29b0-43cf-9519-56765d25540a	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:14:28.356	up	3	\N	tcp
9ceeb723-6bdc-4509-aa19-2d0d54f041e9	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:14:28.361	down	7	\N	tcp
ed5835ff-f074-4da2-8cb1-800730ece99c	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:14:28.375	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
f76bd035-dcde-4575-94e9-99bb279433c8	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:14:31.371	down	2989	connect EHOSTUNREACH 192.168.1.222:8787	tcp
483a354c-b1de-418a-a792-1878accc29e0	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:14:31.373	down	2999	TCP connection timed out after 3000ms	tcp
84772565-2eac-47ef-8d08-854957300a9d	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:41:06.515	down	15	\N	tcp
a0f2e93f-c18f-4437-a120-a1cedd9e5106	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:41:06.559	up	4	\N	tcp
f2954132-1567-44c7-9a13-bb15d860ff5e	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:41:34.494	up	2	\N	tcp
9ebe002b-3a61-4803-af43-91cf67aa7ff2	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:41:34.498	down	6	\N	tcp
b7ac4993-dcbb-4486-a922-db0b3bb98c3f	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:41:34.507	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
2024600a-6eba-4364-9ced-d2856769b705	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:41:34.512	down	1	connect ECONNREFUSED 127.0.0.1:8556	tcp
c8d3f81b-b612-40a2-b4c1-23a6115caa24	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:41:34.514	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
984ae546-c831-4a0e-8250-3fbee22f32f3	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:41:34.517	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
81eb9710-0afc-40ef-802a-4a4bdbe9382a	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:41:34.519	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
4fcd3835-2629-4727-96b8-28c89bfc203f	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:41:34.521	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
ec5a3ad5-1bb1-4049-aa38-a528548c46be	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:41:34.523	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
1c1462c9-dfe2-48b1-9121-c04d0a7c77d5	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:41:34.63	up	124	\N	tcp
de153da7-64bf-4d42-87ed-a79107917ce1	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:53:23.627	down	8	\N	tcp
d2496d25-b926-4419-a66d-2ca814d6d2d6	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:53:23.67	up	20	\N	tcp
5c0513c5-cf41-4b0d-8af6-7fe8456bbb9e	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:53:23.673	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
ce7d4fe1-596b-494c-94b5-68188c2a4cfa	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:53:26.651	down	3001	TCP connection timed out after 3000ms	tcp
58ca5bd1-1a7d-49a6-bc77-b9955fcc3a6a	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:53:51.577	down	2	\N	tcp
8a9f0f6d-7808-4cae-bea5-69f0e811813f	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:53:51.583	down	7	\N	tcp
03aa517f-7ce5-423e-946b-4c9a6cebda17	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:53:51.584	down	8	\N	tcp
833b0aa9-9f7c-4469-9995-ca6d4e94237a	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:53:51.595	up	2	\N	tcp
ab4600b5-2893-40c3-8ee6-69fa7384e84f	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:53:51.6	down	1	connect ECONNREFUSED 127.0.0.1:6875	tcp
e5a18052-4f95-40bb-b2ba-44486463a790	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:53:51.607	up	6	\N	tcp
9403e3bb-7a8c-450b-a77f-136b97ebf5b2	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:53:51.608	down	2	connect ECONNREFUSED 127.0.0.1:9020	tcp
7950740a-63ed-413c-b6be-b4ee74ea11a3	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:53:54.593	down	3000	TCP connection timed out after 3000ms	tcp
fddd1527-afa7-4ce8-80a7-3224bae9fcc8	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:53:54.594	down	2996	connect EHOSTUNREACH 192.168.1.222:8787	tcp
eab63b3b-75a0-4b7b-a14c-3f1ef1dca262	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:54:21.602	down	2	\N	tcp
6c320e4e-404d-4d79-9ce5-c6a5b687bb18	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:54:21.604	down	4	\N	tcp
a1791d8a-c31b-4355-931f-61cbd6cd455a	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:54:21.617	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
c8f019bd-f3de-4a92-93dc-623d46676348	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:54:21.621	up	1	\N	tcp
d92504fb-0133-4ad0-9d8d-e60e6f5a7c73	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:54:21.624	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
b3c08c49-f5b6-41cf-b588-dee827a7072d	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:54:21.626	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
87c128a3-b64f-47f7-b5be-510838763751	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:07:28.116	down	4	\N	tcp
610b467e-d6ec-420f-8655-0e520540c3f2	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:07:58.14	down	5	\N	tcp
dab79837-c6db-4abb-a299-665d3b78bd59	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:14:28.357	down	4	\N	tcp
52ffe803-181b-4e9a-9398-19b2ce8164d5	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:15:01.407	down	3002	TCP connection timed out after 3000ms	tcp
9d54ca76-b32e-497c-b63d-facc018d1c25	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:15:01.408	down	3003	TCP connection timed out after 3000ms	tcp
48f878ca-3d65-4bcf-a14e-dd38ea400ba6	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:41:06.506	down	6	\N	tcp
b37e58b5-f131-410a-a236-71ac26630536	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:41:06.549	down	4	connect ECONNREFUSED 127.0.0.1:4100	tcp
52c6f660-46bf-4e45-b21d-d5f07a02b7c2	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:41:34.495	down	2	\N	tcp
67587002-ab0b-4a15-a339-19b9e2e29791	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:41:34.498	down	5	\N	tcp
848d93bf-03ed-4a96-96a5-c71d46b4d1ff	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:41:34.507	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
6cd51593-c1ba-4809-90f9-258eaef30efb	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:53:23.623	down	5	\N	tcp
23794bbe-8492-4f01-898b-4e25dc28f5e2	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:53:23.67	up	12	\N	tcp
7b2e083e-17d0-4ece-a318-353b4a736c36	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:53:26.651	down	3001	TCP connection timed out after 3000ms	tcp
e19f0693-24b9-4b02-944f-9309c17b23cd	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:53:51.579	down	4	\N	tcp
5c23a475-6b46-4408-8d3c-08b9b593c0a1	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:53:51.584	down	8	\N	tcp
e486df63-6da6-446a-9da7-2270d2336bdd	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:54:21.602	down	3	\N	tcp
b9340832-8cef-4ea3-ab33-893acf0069f1	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:54:21.606	down	7	\N	tcp
32cf9b96-e1a0-4465-884a-8fd9e9fd92ca	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:54:21.617	up	3	\N	tcp
a21195b1-57ca-4174-aa5d-e561200f5176	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:54:21.617	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
613b3d9a-57c3-4bcb-a4d0-73c3db25d34d	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:54:21.768	up	154	\N	tcp
4ef5d585-08e0-4265-8c84-6e7af97019e7	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:54:21.77	up	150	\N	tcp
a95ba229-c1e9-4293-a5fb-7067063e146e	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:54:24.615	down	3001	TCP connection timed out after 3000ms	tcp
e8ab9c2c-b416-4d86-90ac-e340cb2f9976	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:54:24.622	down	3000	TCP connection timed out after 3000ms	tcp
eb52be5d-c54c-456b-a140-6a0ff71d84ff	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:54:51.609	down	2	\N	tcp
054c1fb4-4c5a-47e9-bd75-50581fe5912c	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:55:21.604	down	3	\N	tcp
2e6d74f2-3f0d-468d-a3a9-166ad60840ea	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:02:51.828	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
cc294b8c-8d58-4887-a66a-54fe16e08dcc	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:02:54.812	down	3000	TCP connection timed out after 3000ms	tcp
42fda19f-1662-42d7-abd3-bbb3563da666	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:02:54.818	down	3000	TCP connection timed out after 3000ms	tcp
85c3d823-6ef0-4b5a-95c6-6dc10dc92795	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:03:21.804	down	2	\N	tcp
ae6e464a-81e1-4f87-9bcf-e5e6be644baa	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:03:21.807	down	5	\N	tcp
8d77ae8b-c115-4b8d-8f00-7065d616bce2	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:03:21.822	up	9	\N	tcp
7907e2df-e617-44af-9228-757926bbbc84	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:03:21.824	up	6	\N	tcp
77f1906c-7d8e-442c-af6b-e552c918bea4	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:03:21.828	down	2	connect ECONNREFUSED 127.0.0.1:8078	tcp
7795787b-3a78-41ee-94b6-fd772efe7a4d	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:03:24.812	down	3000	TCP connection timed out after 3000ms	tcp
60170059-c068-47da-a5c2-76f2478a2ec4	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:03:24.819	down	3000	TCP connection timed out after 3000ms	tcp
f9eb5adf-9846-4979-97f8-c32da14eb56f	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:03:51.809	down	2	\N	tcp
9b950e28-7fb9-4609-adc2-5f83442c17d7	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:03:51.842	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
9e4ff1ce-1b1e-4523-9046-f844bf648b57	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:03:52.074	up	234	\N	tcp
3eb82c59-8bf6-4ae4-a6c2-9e927d68a0e8	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:04:21.807	down	6	\N	tcp
a6a07929-cd03-4bae-ace4-e7f4a6ce0bb3	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:04:21.819	up	2	\N	tcp
a0210113-5f8a-4e70-b53f-47acc0bd3948	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:04:23.401	slow	1580	\N	tcp
ffab5c44-e129-41ff-ad59-d6a09b809483	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:04:51.837	down	3	\N	tcp
0c464762-e37a-4eec-b870-fa03e5fbe6ac	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:04:51.85	down	3	connect ECONNREFUSED 127.0.0.1:8555	tcp
6fc66001-f426-44e4-bc4a-5fcb22537bba	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:04:51.88	up	23	\N	tcp
e314b5a2-30af-4cb7-b68e-50664c0a22bc	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:04:54.848	down	3001	TCP connection timed out after 3000ms	tcp
577bd50a-8a4f-49c0-8efe-196ffd6cd638	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:07:28.116	down	4	\N	tcp
e47aa7cd-ca53-4dd2-a9f8-9e7f076ae81d	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:07:28.121	down	9	\N	tcp
bff4a91f-1ef6-4c59-b308-5eafe9d54420	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:07:28.137	down	5	connect ECONNREFUSED 127.0.0.1:7000	tcp
48d427c1-d0e3-406f-801b-8e6712e75bf8	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:07:28.142	up	10	\N	tcp
93a8ce49-4829-4102-97db-c49d8dd2e2b8	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:07:28.152	down	3	connect ECONNREFUSED 127.0.0.1:9006	tcp
18d993cf-dc38-42a7-ac8a-d9a2850593b5	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:07:31.133	down	3001	TCP connection timed out after 3000ms	tcp
b5e8077a-f0f4-44cf-9be4-3214e4bc620e	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:07:31.146	down	3001	TCP connection timed out after 3000ms	tcp
71c5fd78-50c8-424d-bad0-e51186296fcc	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:07:31.147	down	3001	TCP connection timed out after 3000ms	tcp
2e959075-28c1-4343-a4a2-9d806c450ab3	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:07:58.139	down	5	\N	tcp
543c184c-48a7-4b65-8a7d-0c8d0a9fd052	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:07:58.141	up	6	\N	tcp
000b597f-a2a6-4a57-ac41-b21c6ab438ba	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:07:58.144	down	9	\N	tcp
aa668c1c-dfb1-4282-98cd-169b0458b8e6	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:07:58.161	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
b6833567-5807-4543-b24e-b2c9ff551568	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:07:58.162	down	4	connect ECONNREFUSED 127.0.0.1:8088	tcp
d01411aa-bdc4-4b1c-be94-1854365c2aad	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:07:58.179	up	21	\N	tcp
0916b1ce-4cd2-4b37-bed3-9fe7e804cdb7	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:14:28.357	down	3	\N	tcp
9c1d1290-6fe1-4e87-add0-3cf0caf2e2f8	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:14:28.362	down	8	\N	tcp
d300dd45-22eb-4bf2-9638-567962eca8d6	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:14:28.376	down	3	connect ECONNREFUSED 127.0.0.1:7000	tcp
9aff85c3-59f2-4864-8edc-168a8edd4fa4	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:14:28.384	up	11	\N	tcp
ac7917fa-28b2-4901-b2d6-b08bf632f27b	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:14:28.386	up	4	\N	tcp
d80da123-066f-4ac7-a7cc-059f50434183	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:14:58.392	down	6	\N	tcp
181aa78d-a250-4a64-a20f-4054962f627f	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:14:58.393	down	7	\N	tcp
40cca5d3-c5e8-41aa-88e3-97bad026a436	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:15:01.405	down	3001	TCP connection timed out after 3000ms	tcp
be43c4ea-2ab1-41c8-9d24-bb61e27c8e61	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:15:01.407	down	3003	TCP connection timed out after 3000ms	tcp
ffcca62b-232b-481a-b875-520a0b558a82	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:15:01.417	down	3000	TCP connection timed out after 3000ms	tcp
b141a68a-ffa7-474c-bf4c-c959a2d393e0	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:41:06.506	down	6	\N	tcp
f044feaa-6184-484a-af88-95b18a3d2fad	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:41:06.554	up	8	\N	tcp
8a7e7d7b-1311-4455-91a4-e4994f5c3156	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:53:23.623	down	5	\N	tcp
fd403aff-2b30-45a4-b407-16d09b4bb0f4	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:53:23.653	up	3	\N	tcp
8283d1e5-d0c0-4b43-b61c-fb1fe6f55e6b	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:53:23.669	up	19	\N	tcp
6fdffe13-76a1-4a8b-931f-4b17de2def37	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:53:23.671	up	9	\N	tcp
4be15421-90f0-4f8c-a745-9490e4ec15a1	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:53:26.651	down	3001	TCP connection timed out after 3000ms	tcp
5585a229-cd74-4614-9487-12f529be1664	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:53:26.658	down	3000	TCP connection timed out after 3000ms	tcp
1c34e701-b526-4a3b-aa82-f7fe2625f743	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:53:51.579	down	3	\N	tcp
4f279be2-5269-41cd-8099-03586db24b8b	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:53:51.584	down	8	\N	tcp
ea3b03f0-adfd-42a6-aeff-903ac0f7f418	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:54:51.61	down	3	\N	tcp
b21a5dc5-988d-4bf0-a42d-aed374d8439f	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:54:51.64	up	16	\N	tcp
6f561410-f34c-4ff2-8e12-473fd0a7a99d	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:55:21.604	down	3	\N	tcp
5451f905-3900-4471-bf27-7e682b55b085	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:55:21.607	down	6	\N	tcp
f0981afa-96cb-4283-82f0-c1bda4e388f1	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:55:21.62	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
536a6617-5f4a-492d-8b0d-925738037a0b	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:55:21.623	down	1	connect ECONNREFUSED 127.0.0.1:8556	tcp
b54a53dd-f9e9-4cda-a401-5851d93e3ca0	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:55:21.627	up	10	\N	tcp
8bfe0f81-cee3-4e60-ade3-6a7bf8e56ffd	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:55:21.631	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
12f4d492-b454-412d-b20c-8516083fdbdb	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:55:24.618	down	3001	TCP connection timed out after 3000ms	tcp
80c13b1f-ef08-429b-9e52-8599d47fe6a1	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:02:54.813	down	3000	TCP connection timed out after 3000ms	tcp
bb235899-62fc-4677-a132-6660dcf14197	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:02:54.82	down	3000	TCP connection timed out after 3000ms	tcp
69a0318c-a2ba-4bfb-a14a-6fb89e4c96de	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:07:28.117	down	5	\N	tcp
fc78292b-af36-401a-9e1e-5042c2dbc90d	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:07:58.138	down	4	\N	tcp
505da4a2-4df1-4f28-bcf3-e1b723c33c18	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:07:58.141	down	7	\N	tcp
edf02024-ef8c-4d25-9379-ba5befbb436d	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:14:28.357	down	4	\N	tcp
c7fbad16-2e09-49aa-a695-8cd2e5646bda	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:14:28.359	down	6	\N	tcp
78a9df3c-1b13-462c-bdaa-8c03bfe2ba73	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:14:28.377	up	3	\N	tcp
5b827fce-21c8-49b1-8b39-7b6e27723477	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:14:28.384	up	11	\N	tcp
05bb3f70-076a-409e-bc07-dd78b20f78d7	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:14:58.394	down	8	\N	tcp
c64188dd-a691-4dd0-ac5a-0afb96083141	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:15:01.406	down	3001	TCP connection timed out after 3000ms	tcp
7d04a60c-0726-4336-ba34-03face2224ec	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:15:01.407	down	3003	TCP connection timed out after 3000ms	tcp
bc678508-ae12-4a87-8fa4-61dff25bd645	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:15:01.41	down	2999	TCP connection timed out after 3000ms	tcp
e4902b03-0f9f-45a4-9e7a-a71b500e3caf	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:15:01.419	down	3000	TCP connection timed out after 3000ms	tcp
edb2f0a4-d644-4c68-b172-e137b0eebf81	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:41:06.508	down	7	\N	tcp
cc75d026-3f15-4bab-b9fd-0091980a93c2	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:41:06.548	down	3	connect ECONNREFUSED 127.0.0.1:8555	tcp
2d041547-84a8-4b8f-8875-9bc7b49bee51	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:41:06.554	up	9	\N	tcp
fe22c15a-46d2-40b0-9c5a-a61af1d1f07b	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:41:06.557	up	2	\N	tcp
b2dafb7d-9943-4942-ac1e-bbdc0a2a5d35	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:53:23.624	down	6	\N	tcp
94c39632-5372-497a-bcce-6fa85c16c0e7	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:53:51.583	down	7	\N	tcp
31d80a34-6fd0-4a15-877e-6d38b9bf7bb0	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:53:51.602	up	9	\N	tcp
b1e955b8-dc77-4d39-b106-6ab02d4d214b	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:53:51.608	down	2	connect ECONNREFUSED 127.0.0.1:9001	tcp
6083ba87-51ea-4ef4-be07-de32ed2dd21c	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:54:21.603	down	3	\N	tcp
83c4296b-6fae-44d1-88d3-eca244e93e67	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:54:21.617	down	3	connect ECONNREFUSED 127.0.0.1:6875	tcp
40a7e920-dce3-4882-9545-ba3ade378441	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:54:21.618	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
fe0eb1d6-4068-40f8-ba17-a7720fca5030	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:54:21.626	up	12	\N	tcp
694761af-6688-495f-9455-cf2bc0f6d658	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:54:21.629	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
6279bebd-24e3-4f06-9322-fc37da037c10	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:54:51.612	down	5	\N	tcp
7cdbc764-e2a7-46de-bcd2-3f10b8184b6d	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:54:51.621	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
c3c4e72e-26a1-4184-bcac-da04adbb695d	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:54:51.639	up	20	\N	tcp
00da20c7-a5ef-46c0-9e65-ae67a2f96b04	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:54:54.62	down	3001	TCP connection timed out after 3000ms	tcp
cb7747e5-c91d-4b8f-be08-aadc63e2b1f3	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:54:54.628	down	3001	TCP connection timed out after 3000ms	tcp
8216f0f9-e33d-4515-910f-59fcd67970b2	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:55:21.605	down	4	\N	tcp
a244674c-5a84-4a9e-b0cd-2c8c5ab62728	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:55:21.607	down	5	\N	tcp
95eaa495-2e8a-4775-8147-bde0eb66c8d4	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:55:21.62	down	3	connect ECONNREFUSED 127.0.0.1:8555	tcp
f03089ec-0ced-4dd0-9e1b-b6b49482812d	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:55:21.623	down	1	connect ECONNREFUSED 127.0.0.1:4100	tcp
34b0b516-2586-412d-8061-eb24e9382a73	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:55:21.626	up	10	\N	tcp
4dc74aaf-b0b0-459e-83eb-7c06d7732c79	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:03:21.804	up	3	\N	tcp
ce972807-09e0-49c7-ba19-b3b3a717e4c3	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:03:21.822	up	9	\N	tcp
b5d81093-4ecb-4a54-ba74-a2700eb9e413	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:03:21.827	up	5	\N	tcp
5560b32d-21d3-4f88-9d5b-d51ed50767a7	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:03:21.828	down	2	connect ECONNREFUSED 127.0.0.1:9020	tcp
bbf7f0f1-9d94-49e4-97ce-49ba6dc6623e	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:03:51.81	down	3	\N	tcp
68903e2b-4a70-4185-9834-c92affdd64d2	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:03:51.843	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
ab45254a-05ab-4999-961c-bd8d4c6c0386	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:03:51.851	down	1	connect ECONNREFUSED 127.0.0.1:4100	tcp
a995e648-d4e5-478a-918c-c2de5e1791da	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:03:51.853	up	0	\N	tcp
a1b17a80-4136-4da2-a1b2-b5c93b6da170	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:03:51.855	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
6835811a-12d1-46a4-9460-05e7fdc9624e	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:03:51.857	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
dd162bcf-6fc6-4d40-84a3-4019e16cd792	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:05:00.203	down	9	connect ECONNREFUSED 127.0.0.1:9000	tcp
9f7b4b77-4d00-4228-a6d4-58d5eae5247d	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:05:58.065	down	5	\N	tcp
5453cc01-189f-4341-8f1b-a7b572dc842f	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:41:06.508	down	8	\N	tcp
911b8f7b-b00d-44e1-9f5a-81051735b7ef	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:41:06.547	down	3	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
2adb37c2-c85a-4624-99f3-b0aabedef31f	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:41:06.553	up	8	\N	tcp
71d3d74b-a38a-4d80-84a7-da46c1f979ba	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:41:06.557	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
79751855-1c73-465c-8e95-4bb0bf1074f1	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:41:06.558	up	4	\N	tcp
8d738392-4b4e-4e35-ab63-d132baffaa67	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:41:06.562	down	2	connect ECONNREFUSED 127.0.0.1:9000	tcp
f0f29ecc-3d14-44cd-9425-d18ae75e657c	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:41:34.495	down	3	\N	tcp
68bc9d30-5d94-4ab9-8ed9-fda4e7d06a0d	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:41:34.499	up	6	\N	tcp
c593a311-4580-4ea9-a5d0-2df477ae9e0e	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:41:34.508	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
102342c7-e00f-4e6e-8922-aa29a8df820a	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:41:34.631	up	125	\N	tcp
febe8623-2113-4867-b2a2-bf90082c1718	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:53:23.625	down	6	\N	tcp
b63c7564-e957-4cea-bfd0-9ae40d85dcc8	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:53:23.654	down	4	connect ECONNREFUSED 127.0.0.1:8088	tcp
7bb16d75-9904-42f8-8af0-cd6fdfffac90	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:53:23.658	down	1	connect ECONNREFUSED 127.0.0.1:8555	tcp
741f507b-ea84-4698-8b25-795ba109e504	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:53:23.661	down	0	connect ECONNREFUSED 127.0.0.1:8080	tcp
f118d5e9-459d-450d-bf9c-65c44d24ea79	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:53:23.663	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
df126716-506e-4dba-9554-0b5d04d9dad4	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:53:23.665	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
75a88923-949a-4105-b876-ac1d44faf4d5	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:53:23.667	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
de19405f-bc30-4197-b29c-b54fa3b29b66	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:53:23.669	down	19	connect ECONNREFUSED 10.0.0.200:3100	tcp
22382ce2-5290-4818-9282-45db2375b193	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:53:51.58	down	4	\N	tcp
07fd0908-59cd-4cd1-ba82-9c3ff495992d	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:53:51.602	down	10	connect ECONNREFUSED 10.0.0.200:3100	tcp
3626dfd3-2c4b-4910-bd3b-bee92843037e	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:53:51.607	down	2	connect ECONNREFUSED 127.0.0.1:9000	tcp
be4e3ed3-1913-434a-84d2-e3c4e3128785	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:53:51.607	down	2	connect ECONNREFUSED 127.0.0.1:9006	tcp
be60828c-eb80-4abf-86c3-1a3d138f2b72	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:53:54.592	down	3000	TCP connection timed out after 3000ms	tcp
36cdcc75-ba20-4a51-b6ce-9173bd5a5335	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:54:21.602	down	2	\N	tcp
f0acf970-fa13-4ac5-9025-93e4642653ef	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:54:21.604	down	4	\N	tcp
e1c57f1c-11e0-4e87-ba1c-d7f77314f714	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:54:21.617	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
038a1e64-5a45-42b6-99b2-1d81fe023f3c	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:54:21.769	up	154	\N	tcp
67268805-7cf3-49de-b077-ce0b248f854b	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:54:21.77	up	150	\N	tcp
4bec62d7-e901-4d14-b209-cfb42622ee1c	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:54:24.615	down	3000	TCP connection timed out after 3000ms	tcp
c9f2efd4-ff51-4f88-8f3b-3a988d79d55b	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:54:24.619	down	2999	TCP connection timed out after 3000ms	tcp
b3ccb342-30cc-4faf-a5d6-7756058bbe5f	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:54:24.62	down	3000	TCP connection timed out after 3000ms	tcp
cc517bef-a06c-4a46-b40a-027046ab51c7	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:54:51.61	down	3	\N	tcp
07db1c77-77bf-428d-a3dd-cf08750212bb	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:55:21.605	up	3	\N	tcp
8ddb5e77-bb22-41d8-9cca-2baa37f5a5ca	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:55:21.626	up	9	\N	tcp
386de46d-6471-402c-92cc-9a3f5e89e17e	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:03:24.82	down	3001	TCP connection timed out after 3000ms	tcp
306131f4-5630-4007-af48-6a105e827152	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:03:51.811	down	4	\N	tcp
154e5763-4ecd-40f6-9011-364b06d02750	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:03:51.842	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
c31ef62c-ae3e-49f1-bcfc-139c46764e52	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:03:52.075	up	234	\N	tcp
55d2beda-21cf-4451-8ba8-34087e325ecd	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:04:21.804	down	3	\N	tcp
ddde1b76-d1e0-466d-a4c6-a6daa1b934a7	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:04:23.402	slow	1579	\N	tcp
5702a3f3-d6b8-468e-8d17-326e0aaa6237	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:04:51.837	up	3	\N	tcp
493db0ce-39aa-4523-9406-33712b053775	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:05:21.833	down	2	\N	tcp
752a93ec-eb7b-4e0b-9283-e84e863dcbaa	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:07:28.117	down	5	\N	tcp
c6a49799-8c78-4f07-8d68-26df940bf224	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:07:28.122	down	9	\N	tcp
abc3dd5c-5f91-4e31-82df-0b7cf600e59d	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:07:28.136	down	4	connect ECONNREFUSED 127.0.0.1:8088	tcp
a9511ca6-e90b-479f-96c3-2687eb711ebf	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:07:28.138	down	6	connect ECONNREFUSED 127.0.0.1:8555	tcp
40a17e2f-3515-4630-bc01-de772f6fc19d	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:07:28.143	up	11	\N	tcp
ee85743c-19d4-4123-8870-4b41b7aeb1e5	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:07:28.152	down	3	connect ECONNREFUSED 127.0.0.1:8078	tcp
c2e3a803-4105-47d7-abe6-0e11a69ed61f	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:07:31.148	down	3002	TCP connection timed out after 3000ms	tcp
0ede0ba2-7f53-4349-9bbc-45bd7dc77bda	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:07:58.139	down	5	\N	tcp
53a1a481-4d60-4827-aaab-dff75e85a921	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:14:28.358	down	4	\N	tcp
3efbc50e-47fc-4189-8571-9780bb8f812c	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:14:28.362	down	8	\N	tcp
d4e84272-1477-43b5-b0cd-dba8e30a128c	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:14:28.377	down	4	connect ECONNREFUSED 127.0.0.1:8088	tcp
706639af-9178-40c6-a4b1-e4190b9e9e6d	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:14:28.383	up	10	\N	tcp
bcdd3023-29dc-4293-aa77-fbae0fccda8e	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:14:28.385	up	11	\N	tcp
d4a5ad5e-c2fc-4fca-b56e-65c46a24fdd4	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:14:28.39	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
720be7f5-5673-4c8b-be94-a242b5c6fc7b	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:14:28.524	up	141	\N	tcp
0bad5fb7-941c-4a47-951f-ad1724ff7c14	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:14:28.538	up	153	\N	tcp
04b88183-8e7e-4b16-8f63-d7de6df79061	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:14:58.391	up	5	\N	tcp
2a62828a-b66a-4dff-80f2-9c478b33de7f	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:14:58.394	down	7	\N	tcp
75f05f95-1fc7-4209-b1c9-ab64d50deab2	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:14:58.396	down	9	\N	tcp
979fe8a8-f7e8-4604-9cb0-de8d09976a35	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:14:58.407	down	2	connect ECONNREFUSED 127.0.0.1:7000	tcp
63691a9f-7164-4aed-b5cc-a20cc221f920	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:14:58.411	down	1	connect ECONNREFUSED 127.0.0.1:8555	tcp
ac13c072-8bcf-422c-a97d-a374a7320180	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:14:58.416	down	0	connect ECONNREFUSED 127.0.0.1:4100	tcp
74b7308f-b6b9-4d50-8d29-c92a74d5c380	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:14:58.42	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
4b25d3e0-56a1-44a1-8105-328b1d86bc00	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:14:58.424	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
b5e8064f-08e9-4fa4-b7d1-ed44b77e4ef2	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:14:58.428	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
7ac27584-3ade-4663-9e8b-5970a7d21067	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:14:58.431	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
82b0056c-7f52-4daa-bfb6-30e9159c6d9b	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:14:58.435	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
742f4dc8-0008-4435-95ac-0608926a8b96	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:15:01.406	down	3002	TCP connection timed out after 3000ms	tcp
9f620b55-4cce-4547-b366-05997e1fe16c	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:41:06.508	down	8	\N	tcp
7b5bccec-96bd-416a-a6b3-bfe6b571eebf	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:41:06.547	down	3	connect ECONNREFUSED 127.0.0.1:6875	tcp
20872e34-b31c-4a72-96b5-9fbdb4c50ae6	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:41:06.548	down	4	connect ECONNREFUSED 127.0.0.1:8556	tcp
4237b76d-b297-42f9-9c25-cfa8bf29afdb	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:41:06.553	up	7	\N	tcp
e02a453c-e58b-4d63-bc50-52434e14b79c	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:41:34.494	down	2	\N	tcp
83e5647e-909a-4d26-8ee8-9f231264c37d	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:41:34.498	down	6	\N	tcp
7e715073-e779-42a7-82e8-07e1f6afdbf1	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:41:34.507	down	1	connect ECONNREFUSED 127.0.0.1:8020	tcp
ec1a1871-3326-4c3a-923b-715c08094974	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:41:34.63	up	125	\N	tcp
ddf6d059-3989-47c9-8d2a-818694ed2b15	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:41:34.631	up	126	\N	tcp
a1af6f03-6acc-44e8-bf4f-7adcaa8c7e2c	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:41:34.637	up	126	\N	tcp
b4801027-b0d7-4bf3-9788-68cfae548f54	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:41:37.506	down	3000	TCP connection timed out after 3000ms	tcp
0dd1c36d-28c7-48b7-8e40-e9cf6523329f	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:41:37.512	down	3000	TCP connection timed out after 3000ms	tcp
684f1e3b-2161-48dc-9d78-14e890c68380	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:53:23.625	down	7	\N	tcp
fe809583-17c4-4c83-9e1b-49f346d7b2e1	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:53:23.653	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
a2f87eea-9be9-4b9c-9bb9-aab1e2aaaa88	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:53:51.58	down	5	\N	tcp
e0a2730d-3087-4b8d-a321-57d54fa49a58	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:53:51.594	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
101dcebe-6821-4734-9aab-45c8fb8925ef	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:07:28.117	down	5	\N	tcp
0b2e2c84-91d9-4aec-bfac-2d8112e41340	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:07:28.122	down	9	\N	tcp
9e448692-2087-4c7f-ab17-7b8e3544872c	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:07:28.138	down	5	connect ECONNREFUSED 127.0.0.1:6875	tcp
6097efbf-dfcb-4f4d-a830-25349fa7c78d	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:07:28.142	up	10	\N	tcp
c2658fdc-ada7-4dda-9023-b476d6eac2b5	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:07:28.144	down	12	connect ECONNREFUSED 10.0.0.200:3100	tcp
c51e09f9-20a7-4979-822c-221f94a54b64	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:07:28.151	up	6	\N	tcp
06fd55e7-1f47-4a83-9f02-33896b237508	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:07:31.147	down	3001	TCP connection timed out after 3000ms	tcp
47d155db-c2b5-460b-bb6e-d2ad6bb8c972	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:07:58.142	down	8	\N	tcp
13cdfc40-d338-4c18-9977-d7c66ad9b9ef	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:14:28.358	down	5	\N	tcp
f96f18ab-5686-45af-947f-8210877bf443	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:14:28.361	up	7	\N	tcp
7b807d5b-f81f-4530-bc25-20b2434b05ea	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:14:28.378	down	4	connect ECONNREFUSED 127.0.0.1:8556	tcp
6d0481f3-7c0b-49bf-ad96-9efc452b137c	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:14:28.378	down	5	connect ECONNREFUSED 127.0.0.1:8020	tcp
9b3b1b76-384d-4b4e-9150-7a651e1060bd	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:14:28.384	up	11	\N	tcp
383fa367-a5b3-48af-9e7c-b37393c2f78a	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:14:58.391	down	5	\N	tcp
c82a8d10-b0d6-4c9a-92ba-7e0cb08a7f46	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:14:58.393	down	7	\N	tcp
e9de04e1-171b-4ee9-9601-d16fd14661ef	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:14:58.396	down	10	\N	tcp
9e8f9545-06de-4992-bb94-2ca508adb072	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:14:58.406	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
85b7834c-c3e3-4078-ae62-9173d1492e10	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:41:37.511	down	3000	TCP connection timed out after 3000ms	tcp
f70fde83-9a54-4b70-b4b4-054367f02f3c	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:53:23.625	down	7	\N	tcp
33e51996-26b6-4fd4-a3be-560bfc6dcd34	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:53:23.653	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
c43ac45e-f68c-4bff-bd71-49dea2b87ffd	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:53:23.654	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
4995fab5-1f14-47bd-abbf-f9741500b8b9	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:53:23.659	up	0	\N	tcp
da1564fa-b6d6-4953-bb54-5569466c2d1a	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:53:23.669	up	19	\N	tcp
294416bf-7c7d-4f58-9461-97b0984c09fb	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:53:51.58	down	4	\N	tcp
d7f80647-3391-435b-8212-ee0b990ead78	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:53:51.596	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
cb2ecdbd-83a8-4c8d-9ef4-7dfdcc7272d6	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:53:51.595	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
dfb8c6ad-07ca-46cf-8d22-4e4b2618311b	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:53:51.602	up	10	\N	tcp
a4d0f613-9d5f-4b69-8a6d-3e38221b5e69	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:53:51.604	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
b2a6fe53-b325-4f7f-b7de-3068895eeb28	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:53:51.607	up	7	\N	tcp
a0c1967c-afd3-45d9-bd03-3bbc07128692	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:53:51.608	down	2	connect ECONNREFUSED 127.0.0.1:8078	tcp
370d50c9-a0b7-47c9-a4de-bb8ecff95120	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:53:54.594	down	2995	connect EHOSTUNREACH 192.168.1.221:4001	tcp
352d1c8a-2b82-4584-9365-961950a2051b	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:54:21.603	down	3	\N	tcp
bd922e2e-7ee2-4927-9288-3b6c9cb235bb	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:54:21.605	down	5	\N	tcp
1022f972-522a-43a3-998d-920da103cb59	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:54:21.616	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
3c579220-4508-409b-960f-02dd7c6a6c31	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:54:51.609	down	2	\N	tcp
21e55773-9fc1-4f38-a0b6-f9b7cb46ce3a	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:54:51.611	down	4	\N	tcp
3138d5af-47c0-46df-80b6-ef95a32f3452	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:54:51.613	down	5	\N	tcp
b0d78d12-2163-4c5b-80e8-d6880acf6114	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:54:51.621	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
caac7d1c-13d4-4a38-8793-319452b5e57b	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:54:51.625	up	1	\N	tcp
50e3e126-4eca-48e8-a753-556914900f79	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:54:51.639	up	19	\N	tcp
1951df88-02eb-4c21-b7b7-1604522e61e6	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:54:51.64	up	21	\N	tcp
865d36c9-a191-4d92-935c-dbad8ee4b649	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:55:21.603	down	2	\N	tcp
ccf7b940-9c1b-4c79-9ef1-ca11bc463a6e	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:55:21.607	down	6	\N	tcp
d57d11dd-337d-44a1-bc8c-fb9c394cb4ca	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:55:21.619	down	3	connect ECONNREFUSED 127.0.0.1:6875	tcp
dc3c6ffa-ce1c-4110-b89b-21ec6c05ce89	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:55:21.626	up	10	\N	tcp
28399273-1f69-479c-950e-1eb47eb369d3	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:07:28.118	down	6	\N	tcp
fa017e73-dbfc-40b0-bfc1-ce36d72ebb9e	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:07:28.137	down	5	connect ECONNREFUSED 127.0.0.1:8080	tcp
cfa78047-29b4-4597-a2b3-1ed528fde6d6	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:07:28.151	down	5	connect ECONNREFUSED 127.0.0.1:9020	tcp
e96df392-4b11-4fd0-ae1f-6c4e64d4ea7c	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:07:58.142	up	7	\N	tcp
471eafde-1c70-4eb0-8e12-20f5b31a7ee2	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:07:58.161	down	3	connect ECONNREFUSED 127.0.0.1:6875	tcp
1787e8e8-69ad-4ea0-b045-b919ecc70d48	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:07:58.181	up	15	\N	tcp
a035cf52-eee6-413d-83bf-5f35b2d3c1c1	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:14:28.358	down	5	\N	tcp
c4b49101-5629-46d1-906f-567743fd8b24	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:14:28.361	down	7	\N	tcp
f420c18f-3308-45ca-85d5-5a97441b31a3	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:42:16.038	down	3	\N	tcp
b081fedb-a5f8-4806-842e-2dda009641e9	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:42:16.043	down	7	\N	tcp
3d989442-3c77-401d-aa04-33c3bd3aa1e8	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:42:16.042	down	5	\N	tcp
adb26c62-0fba-4388-8217-51d8cf669dba	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:42:16.07	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
6a41ffd8-5896-4b42-b014-40e6df7a172f	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:42:16.074	up	6	\N	tcp
e6a0497a-129d-424f-908f-2821a27941fc	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:42:16.079	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
fb12a90f-b02d-47a3-a4e5-9aa8156e7cd8	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:42:16.079	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
c956f69c-a037-4fc5-962f-664d93ed68c5	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:53:23.624	down	6	\N	tcp
05e03f89-fc2a-4b02-88bf-5ebf0c622c16	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:53:23.653	down	3	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
c39b3435-6f3c-4e08-b75b-8f32bb241452	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:53:23.669	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
483799ea-6953-417a-929c-7a80384f1b0c	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:53:23.67	up	18	\N	tcp
5eec1272-b209-4cca-b05c-13c0be169878	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:53:26.649	down	2999	TCP connection timed out after 3000ms	tcp
bbe26bfb-7150-4524-a1b4-a0e7e5a967f0	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:53:26.652	down	3001	TCP connection timed out after 3000ms	tcp
c360c8fe-22ef-446a-adbc-24570f2a3472	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:53:26.658	down	3000	TCP connection timed out after 3000ms	tcp
ed77e235-d0c8-4559-afa1-5976c066b750	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:53:51.582	down	6	\N	tcp
db0564cb-9078-455f-a124-dbcf169b8479	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:53:51.585	down	9	\N	tcp
aca1fa1a-2561-4245-a39f-bda213abfc43	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:53:51.594	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
a75a9a93-4798-4249-a9fd-50ba3c6afa3d	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:53:51.595	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
f091539d-4594-4826-804b-5827224bf16a	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:53:51.602	up	10	\N	tcp
1f6522a8-5c85-4fb8-a2d3-820b19dbbd6c	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:53:51.607	up	7	\N	tcp
894de3a8-c22a-4681-9779-4bc273366eff	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:53:54.593	down	3000	TCP connection timed out after 3000ms	tcp
1aaff1b2-6525-40a1-85f9-03ac48a09a10	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:54:21.603	up	4	\N	tcp
2f2bf22e-1c09-49b4-8626-256a73d6540f	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:54:21.605	down	5	\N	tcp
9f186b3f-229b-44c0-ade6-d837384c554a	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:54:21.769	up	155	\N	tcp
63036eb4-0a4e-4886-bc58-a3e6ee79c777	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:54:21.77	up	148	\N	tcp
f3586700-89f2-4dde-9c9e-095053de2fb8	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:54:24.615	down	3001	TCP connection timed out after 3000ms	tcp
e3e7e661-4260-4412-b632-dcc35a0e2714	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:54:24.622	down	3000	TCP connection timed out after 3000ms	tcp
527dc512-2187-4f3c-8190-1f976c1c2afc	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:54:51.61	down	3	\N	tcp
d99fbaa6-c3c9-4190-9aae-482b7b5be732	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:54:51.613	down	5	\N	tcp
483ff25c-2bfc-4278-bf67-28ffe2f91010	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:54:51.621	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
7bc8ecd0-94e5-46ed-8631-9cb731f5ef67	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:54:51.64	up	20	\N	tcp
df8d2110-ec36-4c2e-b077-f1449ec9d89a	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:55:21.603	down	2	\N	tcp
ff43fb85-13cb-43cf-a117-386b2170210e	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:55:21.606	down	5	\N	tcp
e4d46f8a-8bf9-4ed3-a538-9453ea6213ec	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:55:21.62	up	3	\N	tcp
3584a905-f7f7-49d5-962b-4ac42309b8fb	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:55:21.623	up	1	\N	tcp
f188e21e-eb82-47b6-891e-526d7fedefc4	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:55:21.627	up	10	\N	tcp
c8fd2c5f-ba73-4480-9223-2d627d4eedaf	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:03:24.82	down	3001	TCP connection timed out after 3000ms	tcp
2b61e0f3-7d95-40c4-a595-78b4fb73e443	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:07:28.12	up	6	\N	tcp
ee8c7a05-1303-4987-836e-5ca1ec5cc659	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:07:28.135	down	3	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
667933a7-045d-4f49-a7e6-223d22bcb373	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:07:58.137	down	4	\N	tcp
812f6e7d-e37d-4dc9-a770-6ae928fbf351	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:07:58.14	down	6	\N	tcp
98561ad9-6ff2-41a6-848a-f579969e5cc0	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:07:58.161	up	3	\N	tcp
4127c76b-aad4-4493-8583-6f3cfe4bb425	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:07:58.179	up	21	\N	tcp
7f9762df-e679-453d-813a-952664d9f370	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:07:58.181	up	23	\N	tcp
8e7c26ed-0097-451a-8773-ade2356e26d7	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:07:58.186	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
a5ac8c9c-1187-4870-9fd0-75c1ebef1f07	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:08:01.159	down	3001	TCP connection timed out after 3000ms	tcp
03b9e8aa-3226-4f3d-b588-11f31f218660	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:08:01.167	down	3001	TCP connection timed out after 3000ms	tcp
daea215a-d66f-4c86-a088-9ecdc4a4f192	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:08:01.171	down	3000	TCP connection timed out after 3000ms	tcp
58692612-76c2-4d50-bae6-7115a7bed930	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:14:28.359	down	6	\N	tcp
132289a5-3e72-4421-b4d8-423763d394e5	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:42:16.043	down	6	\N	tcp
9ab91c65-f0da-412d-8499-08026444903d	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:42:16.041	down	5	\N	tcp
79df1da6-4a8d-4178-a240-f87cc209deb5	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:53:51.595	down	3	connect ECONNREFUSED 127.0.0.1:8080	tcp
5e632e42-c14e-42f7-b8be-467756627d60	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:53:51.603	up	10	\N	tcp
d4a8dfa5-c635-4971-ad8d-775f1737b890	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:54:21.602	down	3	\N	tcp
8b4200d0-ce82-4af5-ad0e-c2556634c2d2	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:54:21.604	down	5	\N	tcp
05844547-551f-40c1-a091-2a985ecd255e	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:54:21.617	down	3	connect ECONNREFUSED 127.0.0.1:8555	tcp
0e3809e1-03bd-47fa-9209-2fbe2ff1b858	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:54:21.618	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
ce73b792-aa78-4f84-916a-96e09928c3fc	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:54:51.61	down	3	\N	tcp
c001f705-fdf6-4eb4-9adc-057395394511	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:54:51.641	down	16	connect ECONNREFUSED 10.0.0.200:3100	tcp
5d2142ff-5868-4caa-976d-8b0dfb7e7dce	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:54:54.62	down	3000	TCP connection timed out after 3000ms	tcp
1c039441-7804-4cb8-94d4-75a7774ff8bc	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:54:54.629	down	3001	TCP connection timed out after 3000ms	tcp
acc89d6c-9795-4bc4-a64d-f8406d9ef219	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:55:21.604	down	2	\N	tcp
790994b4-08fe-44e6-93d0-b7a19e928790	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:55:21.606	up	5	\N	tcp
8e990bfd-08a0-4ac7-867d-3c9631ab9008	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:55:21.62	down	3	connect ECONNREFUSED 127.0.0.1:8080	tcp
f42ef454-a182-4b04-9a3a-4f4a642841de	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:55:21.627	up	5	\N	tcp
d63683c3-9d13-449e-8a0b-a9339c783051	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:03:24.821	down	3001	TCP connection timed out after 3000ms	tcp
fdf4ba9c-27f7-4bbb-ae86-4f3a460ee7e9	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:03:51.81	down	3	\N	tcp
9635760a-4706-4208-b4c6-bde081b3750c	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:03:51.842	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
9d165c1f-70bb-42ae-b9c9-63e013f635db	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:03:51.85	down	1	connect ECONNREFUSED 127.0.0.1:8088	tcp
8f352b7f-b299-4109-8741-8d4cf07033c2	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:03:52.075	up	235	\N	tcp
5247b911-417a-4537-9fac-9dbaee418cf4	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:04:21.803	down	2	\N	tcp
1f53fc14-d02f-422a-956f-e1cabf528926	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:04:21.807	down	6	\N	tcp
45fcc285-22b6-42fc-a251-c11d84dfeba3	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:04:21.819	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
aac9151f-0148-4f7d-a16e-d30ac7ee3a76	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:04:23.401	slow	1584	\N	tcp
c3322d8b-56ab-46b3-9ac4-4ae6c025ab62	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:04:23.399	slow	1583	\N	tcp
05f23890-9781-40b8-810e-a133af994cd5	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:04:51.839	down	5	\N	tcp
a7765aa3-c541-4ab0-88a3-7830487170a4	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:04:51.851	up	3	\N	tcp
09268f8d-67c6-4310-854f-3db2d0cab92a	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:04:51.858	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
a4bf0fe0-de33-4c25-ac53-47efbbb10e5a	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:04:51.881	up	33	\N	tcp
1442996f-2729-43f7-9987-055d5340eb3b	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:05:21.833	down	2	\N	tcp
2b03c05a-790c-4df7-a9d7-20be7d84eba5	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:05:21.835	down	4	\N	tcp
79e24615-0882-4f91-ba3e-6a46a520ae54	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:05:21.847	down	3	connect ECONNREFUSED 127.0.0.1:6875	tcp
cd36773d-0a7b-4526-a253-fceea302a670	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:07:58.143	down	8	\N	tcp
d10de5df-4cc5-4a1b-9179-68a2db2c5a51	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:07:58.161	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
58b56360-bcbd-4510-8ed0-ebfdcc08949f	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:07:58.18	up	14	\N	tcp
9913f26d-42df-492a-82e8-964d86195f65	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:14:28.359	down	5	\N	tcp
52ffef11-95e6-450d-8300-23c28826607d	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:14:28.376	down	3	connect ECONNREFUSED 127.0.0.1:8555	tcp
3203233d-1867-4e57-960f-677759be6301	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:14:28.383	up	10	\N	tcp
5f3fb1d2-4eb8-4f46-a45e-d29bf3670d1b	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:14:28.391	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
42f0094d-5f74-4ed3-b3b2-8392385e6453	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:14:28.523	down	141	connect ECONNREFUSED 10.0.0.200:3100	tcp
5127b3dd-fa12-4563-b089-4270aa1c1906	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:14:31.371	down	2998	connect EHOSTUNREACH 192.168.1.222:82	tcp
f7ec6152-e367-46b7-953b-ac758ddf84ef	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:14:58.392	down	6	\N	tcp
0603b455-069d-43d6-bf2d-3ce08d62177d	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:14:58.395	down	9	\N	tcp
ccba41db-57fe-4f38-9b57-243570fdae33	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:42:16.043	down	6	\N	tcp
b82f8225-50ef-403f-a2fb-dfe00c572c6d	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:42:16.042	down	5	\N	tcp
4f50c461-0e78-4e37-b223-e5c598490030	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:42:16.074	up	6	\N	tcp
16ef0843-e723-476e-aad7-e25e238f5394	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:42:16.079	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
93efe5c2-238d-4e26-8f3c-decb1ee3096b	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:42:16.079	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
f0cb4c28-e377-457b-a210-db8b1d646af8	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:54:21.602	down	3	\N	tcp
b4390e00-5f25-432e-b15e-afa072d8d535	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:54:21.604	down	4	\N	tcp
3374db7a-bde6-432c-85bf-3e410da54296	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:54:21.769	up	155	\N	tcp
5291bf3b-db83-483a-a256-25e24eea831f	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:54:51.612	down	4	\N	tcp
25c044e0-05e7-4ef0-95ea-4d5bb065d4e0	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:54:51.612	down	5	\N	tcp
38731924-5018-48ff-b52a-4bb3b8ff257e	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:54:51.621	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
e9f135d3-0ecb-4e30-97a6-f113d703df68	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:54:51.626	down	1	connect ECONNREFUSED 127.0.0.1:8080	tcp
a484f534-67e8-433f-916e-c013484cd59f	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:54:51.628	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
e99e9a01-46d6-49a4-b7de-90d29700425f	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:54:51.631	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
20e440ea-d420-4d3b-86d4-798aa64b5717	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:54:51.632	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
6959b79b-f372-49fe-ac94-351537b49608	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:54:51.635	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
234594fb-d21a-4afc-88a3-70e8676fa132	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:54:51.637	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
496ba9d5-9e2b-4310-9749-68b4c06b7249	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:54:51.64	up	20	\N	tcp
c2a4cdf7-889c-4626-a0f8-1f66390a5c75	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:54:54.619	down	3000	TCP connection timed out after 3000ms	tcp
d362023d-7090-41d4-b099-f4b242dd9c02	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:54:54.628	down	3001	TCP connection timed out after 3000ms	tcp
d47ad503-2e27-4a9e-ba2c-55e65a33dfc3	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:55:21.604	down	2	\N	tcp
c3390ffc-a20c-4dbf-a31b-7f16e0e5a7c4	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:55:21.607	down	5	\N	tcp
052ab660-1d1c-481e-92bd-6e30617971be	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:55:21.618	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
a6122dfd-8e7a-4b8e-8f53-2cf662d0a5d9	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:55:21.626	down	10	connect ECONNREFUSED 10.0.0.200:3100	tcp
cfe18d40-5cf4-4373-9c00-800876ebfac8	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:55:21.631	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
f8c755c9-f2b3-4499-ae8a-faabf9d81184	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:55:24.618	down	3001	TCP connection timed out after 3000ms	tcp
a28610b1-b6df-4f66-8d67-3ac62ca8581e	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:03:51.81	down	3	\N	tcp
d9af3e56-b7d9-417d-808e-bea216a46ead	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:03:51.843	down	1	connect ECONNREFUSED 127.0.0.1:8556	tcp
6e1de576-2988-4fc0-90fa-27fe7a7eb0d7	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:03:52.075	up	234	\N	tcp
ddabe3e0-2a18-4437-8806-e336b95c4d76	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:04:21.804	down	3	\N	tcp
6d707538-3b4c-4b0e-8856-560b45f0c35f	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:04:23.401	slow	1585	\N	tcp
f1edae50-5720-4fa1-aa5e-fe38e75f62cf	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:04:51.837	down	3	\N	tcp
e5b0889f-2189-457c-9e15-a2401af167ce	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:04:51.882	up	22	\N	tcp
a7d95e8b-370a-4359-8415-c3b52d46da39	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:07:58.143	down	8	\N	tcp
eda228f5-5184-4149-b07d-672a86732703	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:14:28.359	down	5	\N	tcp
15f0bba4-7c7c-4714-a127-2071b2bacee2	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:14:28.377	down	4	connect ECONNREFUSED 127.0.0.1:4100	tcp
28b7ce67-fc82-4a3e-a24c-fe31575130fd	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:14:31.371	down	2989	connect EHOSTUNREACH 192.168.1.222:8080	tcp
0db8485d-9fc0-4bb8-9873-81aeaf64985c	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:14:31.374	down	3000	TCP connection timed out after 3000ms	tcp
f55e2e94-f829-45fe-831c-c6304f6c4e12	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:14:31.38	down	2999	connect EHOSTUNREACH 192.168.1.221:3011	tcp
6a89661a-170e-4046-ac3c-f29056421189	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:14:58.392	up	6	\N	tcp
953754b1-6ce4-4da3-bbae-9f5659753b14	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:14:58.394	down	8	\N	tcp
0a2a3aa3-9984-4ca9-88c0-6ce684f67566	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:14:58.395	down	9	\N	tcp
298525c5-eedc-4e53-aa94-22df4c125eb3	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:14:58.407	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
47402e8d-9ba5-4f39-acd4-479a56c1003b	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:14:58.415	down	0	connect ECONNREFUSED 127.0.0.1:6875	tcp
ef093e83-038b-4cd7-8752-0211a6343d2a	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:42:16.041	up	4	\N	tcp
3a127bca-53f3-4e0d-a335-290566820b16	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:42:16.04	up	4	\N	tcp
d86dca70-bdd8-47a9-8837-db5e07717498	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:42:16.07	down	3	connect ECONNREFUSED 127.0.0.1:8080	tcp
4184a274-031e-4c50-be2b-9454ef600130	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:42:16.073	up	5	\N	tcp
1e2ba53c-22d4-4f9e-9894-10bf95e87676	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:42:16.075	up	6	\N	tcp
3736f84e-c55c-4152-ac5f-555f10c418df	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:42:16.079	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
23f5378c-0971-404a-8102-858f14eaadff	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:42:16.081	up	5	\N	tcp
3c9344e5-a83b-4a4c-9507-742107a36f27	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:54:21.629	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
b9047494-846a-4f64-b9c8-eb30bf5dea1d	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:54:21.632	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
c8c3104a-48e5-4bfe-a2e4-6260276759df	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:54:21.77	up	155	\N	tcp
aa97eb94-ff56-426b-a4d1-753ceaf46397	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:54:51.611	up	4	\N	tcp
c38884cb-29e0-47a2-a851-8396ea3bf026	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:54:51.612	down	5	\N	tcp
1ffe21e2-c6af-49e3-a783-9f06c18ab5ce	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:54:51.622	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
70317d7d-0792-4ea2-8360-f5a268f7f816	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:54:51.625	down	1	connect ECONNREFUSED 127.0.0.1:8088	tcp
476c9a9f-de30-458a-9663-f44cd3a5a80e	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:54:51.64	up	20	\N	tcp
a85f1ae5-e504-492b-9ea2-8d250192b494	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:55:21.606	down	4	\N	tcp
a419929b-16d0-49d6-ba16-eb3604972e8b	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:55:21.628	up	4	\N	tcp
ca833631-975c-4c70-beb4-728e4873782d	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:55:21.631	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
7bb56d3a-69e2-4704-b848-d7bacfbf075c	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:55:24.617	down	3000	TCP connection timed out after 3000ms	tcp
89718987-9cb3-4660-b457-fc0c97fc3758	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:03:51.859	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
1385e99a-6d0b-4978-b231-0be45b9989d1	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:03:51.862	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
260c200c-1cb2-45eb-859f-5b06edc6381a	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:03:51.864	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
674a2816-d596-40de-a0f4-b2aeb7751805	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:03:52.077	up	223	\N	tcp
da1a2b93-28d8-4c49-801a-7849f46b31b6	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:03:54.84	down	3000	TCP connection timed out after 3000ms	tcp
0e9aceff-5dec-43e4-8c79-5bdbfd381183	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:04:21.802	down	2	\N	tcp
2d89db39-7e8f-4c0b-a545-70d57807b56f	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:04:21.805	down	4	\N	tcp
d4af1d37-ecfb-4020-940d-b6aee3bf1b16	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:04:21.819	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
2c783691-0e7e-47a5-b4e8-609384a9e2b9	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:04:23.401	slow	1585	\N	tcp
12b408e0-e89e-416d-8e96-6e08bfe7bf8d	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:04:24.817	down	3000	TCP connection timed out after 3000ms	tcp
335e3148-e646-4948-af27-7d49dc4f758c	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:04:51.836	down	2	\N	tcp
a29adc2f-20dd-4f57-9be3-36b7f141a4e5	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:04:51.838	down	4	\N	tcp
d195715d-88e6-4ac3-8235-45e5179ad173	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:04:51.85	up	3	\N	tcp
79c4b646-7553-4e8f-845c-aee3eb893788	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:04:51.88	down	23	connect ECONNREFUSED 10.0.0.200:3100	tcp
4f3a1842-826f-4e2c-8b34-b520292b2f4a	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:05:21.833	down	2	\N	tcp
47b9c226-40be-4c9e-b49b-f19ef7f8a76c	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:05:00.205	up	9	\N	tcp
d07ce0dd-f1ee-419f-b9f1-c52ebf57bf60	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:42:16.043	down	6	\N	tcp
e45a4ba9-b97a-402e-8b5a-6b6dc5efb005	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:42:16.041	down	5	\N	tcp
c84a14f0-e405-4363-bae9-29bd93ce1be7	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:42:16.071	up	2	\N	tcp
26208ad0-12be-48ed-9360-d80d4651af5f	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:42:16.074	up	6	\N	tcp
6e5e7446-e07e-4079-af81-ea5cc749b8b3	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:42:16.08	up	5	\N	tcp
90329faf-cb6c-408b-9e8a-b60788dd0929	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:55:21.605	down	4	\N	tcp
beaebc61-ba65-41ea-a144-e674cf5995a6	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:55:21.628	down	2	connect ECONNREFUSED 127.0.0.1:9000	tcp
e59b2d5e-bf62-4d77-bbc9-a86c12619ae9	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:55:21.632	up	7	\N	tcp
ead22663-56b7-4195-ae36-02f6fcff41f2	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:55:24.617	down	3000	TCP connection timed out after 3000ms	tcp
5b08a4ca-d757-4870-a56a-b2b9fc6f5b98	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:04:21.804	down	3	\N	tcp
0c817e95-a65a-4c73-9d14-680829dfb09c	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:04:23.401	slow	1580	\N	tcp
93a10774-d877-4720-82d4-21fd692ca5ef	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:04:51.836	down	2	\N	tcp
9bd013bf-c7b1-4814-8c4e-5a197d350a41	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:04:51.838	down	4	\N	tcp
e30c6df8-b070-49d9-a5d0-4c90eb38d0f4	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:04:51.851	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
a10c6b20-0fe0-43ef-a2e9-1f614e68a26e	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:04:51.858	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
d2212a55-b7d6-4640-bbac-78ee8fdebf97	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:04:51.881	up	21	\N	tcp
95e7413f-da5d-4c1a-93be-41647e0429cb	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:04:54.848	down	3001	TCP connection timed out after 3000ms	tcp
70519568-61a0-4ab6-947f-5084c8ed6de0	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:05:21.834	down	3	\N	tcp
e4b48555-0eab-4ca6-8459-7c5a2b7a1867	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:05:21.879	up	35	\N	tcp
a87c3654-7408-4a54-9297-7d5fab602934	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:05:24.844	down	3001	TCP connection timed out after 3000ms	tcp
ae4151c7-5ad2-4c1c-96f4-766af322b93b	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:08:51.933	down	3	\N	tcp
b4563f78-0d4c-428b-84d8-e0b60038c6fb	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:08:51.934	up	4	\N	tcp
18373936-d274-400c-bc03-8256e3517f68	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:08:51.932	down	2	\N	tcp
23c297fd-bc97-4f09-8f2a-48f5c348225b	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:08:54.973	down	3001	TCP connection timed out after 3000ms	tcp
63e1dafe-0ba2-441f-9d95-3449ac41c1f3	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:09:21.946	down	2	\N	tcp
028abad6-43ee-4cf7-8ad2-7b9a9a5189fe	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:09:21.95	down	5	\N	tcp
b72f8695-26bd-4f43-bbee-ff737d948b10	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:09:21.96	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
af33ea81-cc83-423f-91dd-6d17569c74f9	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:09:21.964	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
86b7bfed-bd69-4a4b-96fb-9850e812ac76	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:09:21.971	up	14	\N	tcp
40d27021-784c-46f5-9b36-1cd96dd70a16	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:09:51.965	down	2	\N	tcp
f4b2a5be-d075-45be-b1ef-8a3225097d7b	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:09:51.967	down	4	\N	tcp
291db209-ff5d-4595-86d6-f1b4b51c4542	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:09:51.98	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
8f3c7acd-3a81-475e-9125-677c41e5cabf	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:10:21.971	down	1	\N	tcp
15bd6f15-962f-4cb5-9863-5586c03442bf	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:10:21.972	down	3	\N	tcp
c2685c2f-cbff-4785-bb5c-5fe062348c56	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:10:21.973	down	4	\N	tcp
e52e6487-ba30-4f54-a6e8-a21125c28f4f	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:10:21.983	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
d4975357-79ff-45ad-aedc-a45eed12ff73	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:10:21.984	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
c3e9bca7-79de-4529-9079-2160760655f6	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:10:21.987	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
bc334089-6624-412e-b7f6-7617dcf93bd0	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:10:21.989	up	9	\N	tcp
ad16de5c-4767-4b54-b885-d53cb8ce5cdf	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:10:21.99	down	5	connect ECONNREFUSED 10.0.0.200:3100	tcp
fa363b62-caca-4299-a79a-7edb2e780056	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:10:21.993	up	3	\N	tcp
dffa8dfd-fc74-45b5-8374-0dd1d15f78db	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:10:24.981	down	3000	TCP connection timed out after 3000ms	tcp
e9fb34d4-aea3-48a2-8f5f-a83c7b8fecb0	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:10:24.985	down	3000	TCP connection timed out after 3000ms	tcp
e8b279a7-63a7-4461-be10-ad8b2120e2b2	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:10:51.974	down	2	\N	tcp
64141de8-6d10-4d78-adb6-99e4320da786	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:08:28.149	up	3	\N	tcp
1b500932-c1cb-4180-bf4f-909eeecd753e	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:08:28.153	down	6	\N	tcp
f995b0e4-bae5-4c39-9084-0ee2f52873cb	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:08:28.194	up	27	\N	tcp
8b97ca76-5f1b-4467-a865-de7239f229ed	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:14:28.36	down	6	\N	tcp
846aed35-6b3e-4672-901e-1789133da9b7	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:14:28.378	down	5	connect ECONNREFUSED 127.0.0.1:8080	tcp
c5d4b3f1-244c-4875-b12d-d7668f2ad476	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:14:28.387	down	2	connect ECONNREFUSED 127.0.0.1:9006	tcp
ceeaa90d-2f6b-45ae-ad5e-2f3ebba5abe7	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:14:58.393	down	7	\N	tcp
4d5c2af6-8795-4b86-90d1-dfd32600f3c3	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:14:58.395	down	9	\N	tcp
255ce0af-9eae-4db6-9834-02f66a1d72f1	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:14:58.406	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
637913e8-e380-4b88-9801-d25257b31ba7	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:15:01.408	down	3003	TCP connection timed out after 3000ms	tcp
5d67200d-e53b-412c-b064-70e85c849184	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:15:01.41	down	3000	TCP connection timed out after 3000ms	tcp
4ca46b1a-7db7-4d95-971e-511afa1d74fa	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:42:16.04	down	4	\N	tcp
f223b066-f6cd-4360-971b-4a0a003dca84	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:42:16.071	down	3	connect ECONNREFUSED 127.0.0.1:6875	tcp
bd5c3533-b2ae-40a2-90c6-855566dfd055	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:42:16.081	down	5	connect ECONNREFUSED 10.0.0.200:3100	tcp
2cea2e58-aa1a-45f6-bf86-c437a4971983	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:55:21.627	up	10	\N	tcp
18c6fedd-7239-467e-ad09-814003a1a400	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:55:21.631	up	6	\N	tcp
588451ed-b9d2-4128-af63-eaac4fdfc98d	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:55:24.618	down	3001	TCP connection timed out after 3000ms	tcp
e26205db-108c-41e1-8943-be511c1b998a	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:04:21.805	down	4	\N	tcp
a79bc937-3c78-48ec-839b-197d55d95010	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:04:21.819	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
2e37baa5-1304-44aa-b5c1-21e11e74fab6	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:04:21.82	down	4	connect ECONNREFUSED 127.0.0.1:8555	tcp
d6e817a7-4ae4-4f8e-b80c-f68b94c62e25	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:04:23.402	slow	1579	\N	tcp
f4f97979-54b1-4adc-a054-578343027947	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:04:24.816	down	3000	TCP connection timed out after 3000ms	tcp
f07a9012-3b17-4273-a0b1-4cad060646ab	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:04:24.823	down	3000	TCP connection timed out after 3000ms	tcp
b668f17d-b7f5-4e2d-8be2-d5e7d8c4a749	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:04:51.836	down	2	\N	tcp
d3f5bd03-b757-4485-a597-fbb7bee1b1d5	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:04:51.838	down	4	\N	tcp
993a0b29-a5d1-4099-bd75-fbdcac345a64	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:04:51.851	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
ab8435b4-1190-43f9-a799-7a2b1ac4e029	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:04:51.858	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
a594e15b-be8b-4bbe-a7e5-bab4c9dd7435	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:04:51.881	up	24	\N	tcp
f0bff8dd-181e-41ca-bac4-dee6220a89aa	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:04:54.848	down	3001	TCP connection timed out after 3000ms	tcp
d91de601-bdf5-46b3-b698-91eb1d18ba3c	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:05:21.833	down	2	\N	tcp
95810280-574a-4050-a8b0-0e4242c1e0c5	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:05:21.836	down	4	\N	tcp
ffdf46ad-e0aa-4f0b-893e-192fb9ab08bb	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:05:21.846	up	2	\N	tcp
94b3ab98-c00f-40cb-98b1-7a5a69a149a0	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:05:21.878	up	24	\N	tcp
b5bbfb04-aff4-4d47-babd-766b3e488221	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:05:21.879	up	27	\N	tcp
65889f5e-36fa-498a-aee5-d2a4ce00c074	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:05:24.844	down	3000	TCP connection timed out after 3000ms	tcp
718eaf6b-6e52-4fd2-aaab-d13d1fcdc137	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:08:51.934	down	4	\N	tcp
dab30e64-7a24-486d-a99f-0d076563357e	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:09:21.947	down	3	\N	tcp
4038fc6f-1bde-4d2f-921a-ed0f6dd6471f	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:09:21.959	up	2	\N	tcp
015e82f8-3ba9-4c45-8f73-19c071419a41	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:09:21.961	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
4298b67f-0d53-4265-b591-b44f8946f00f	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:09:21.964	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
40a43090-4a38-4224-9e03-530b889ecb75	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:09:21.971	up	14	\N	tcp
f3e66760-328c-4c9d-8493-426e2e876395	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:09:24.955	down	2992	connect EHOSTUNREACH 192.168.1.221:3011	tcp
9cb466f4-7216-4288-a687-ec5bab9272d5	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:09:51.966	down	3	\N	tcp
f1a02bfc-1ee4-4387-b51f-6ab9752c5a0c	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:09:51.98	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
c165a23b-c870-474f-9bf3-cf7b2069b4de	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:10:21.973	down	4	\N	tcp
1bcf409c-2ebf-4974-968f-a2b035bded56	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:08:28.149	down	4	\N	tcp
57cb189f-1f3e-4bae-9d80-cd2c8635d169	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:08:28.153	down	7	\N	tcp
7f0ae888-562a-4d0e-9f24-57a54b3dbd31	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:08:28.193	up	26	\N	tcp
ded51e2d-aa0b-42c8-977e-2dd59a681897	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:08:28.195	up	27	\N	tcp
4035bb00-a85d-482a-b16c-1d22842d9f4a	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:08:28.204	down	2	connect ECONNREFUSED 127.0.0.1:9001	tcp
6048db99-8252-4029-8792-4873da32e663	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:08:31.168	down	3000	TCP connection timed out after 3000ms	tcp
cd5ea2b6-001b-4787-b6b8-e53c544d5f70	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:08:58.169	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
d25ea9b9-7880-453c-9ab2-09f081a32024	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:08:58.175	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
eda1346c-678c-45b1-ae69-776cbafa89e6	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:08:58.179	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
c8e06600-b0f8-4f90-87e5-d022a9fa0c1e	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:08:58.183	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
0c33411e-4fc1-48f3-83a6-e94e50ee0957	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:08:58.186	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
fd252412-fdd3-4507-b14c-87cba57e88b1	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:08:58.19	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
e8412598-987e-45fb-b6ad-30779cbd1e96	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:08:58.194	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
199456b6-69ce-4833-b098-80baac7403a0	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:08:58.286	up	120	\N	tcp
a401f0b1-8ff1-4f86-999d-da222052abc2	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:08:58.289	up	122	\N	tcp
b1e8f6eb-a310-4535-a9ba-4e3c048b2276	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:09:01.175	down	3000	TCP connection timed out after 3000ms	tcp
d141f2c1-6aa9-4130-8906-5af18221a2fb	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:14:28.36	down	6	\N	tcp
d3e44cdc-6d99-426f-8636-ca12545a556d	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:14:58.391	down	5	\N	tcp
4d2301af-c2e8-47e4-8ec4-9954ed0117ba	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:42:16.039	down	3	\N	tcp
838d08d1-f316-4183-a0fa-bb80d6cda39e	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:55:51.621	down	2	\N	tcp
301ad0bf-c8be-439e-a774-05d575585d8e	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:55:51.627	down	8	\N	tcp
6b26ad68-64ab-45a9-a0f7-8e94d3f33032	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:55:51.627	down	8	\N	tcp
483e74b4-2142-4cb3-8bc3-210d49f61144	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:55:51.64	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
537df53d-8558-4d90-a537-345a704eecc9	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:55:51.673	up	36	\N	tcp
9e83508b-ad5e-433b-b9ca-b2b882b6cfde	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:56:21.631	down	3	\N	tcp
10136a2e-0c38-4d29-bffe-f535c35e04bc	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:56:51.619	up	2	\N	tcp
851086c3-7756-4dc8-907c-b646aec6934a	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:57:21.661	up	9	\N	tcp
9525d210-ff24-4b33-a66e-6a8d32f277d7	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:57:21.666	up	7	\N	tcp
abdc44b3-cea0-491f-8053-9c267183ff80	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:57:24.652	down	2994	connect EHOSTUNREACH 192.168.1.222:82	tcp
28aa87e0-96f4-4c93-819d-224f083489e4	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:57:51.639	down	2	\N	tcp
f23f201a-b25f-40e0-af20-1d5b600340f7	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:58:21.65	down	3	\N	tcp
7094bac5-fb5c-4f80-a314-49dbd60e8b4f	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:58:21.673	up	5	\N	tcp
d386910d-1e72-404b-9355-8b7feebb494a	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:04:21.804	down	3	\N	tcp
e051e32f-66d0-4392-bd5a-e1b1db9cca52	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:04:21.819	up	3	\N	tcp
b5e5e03f-d78d-43bb-b26c-a962d5abf0b9	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:04:21.82	down	3	connect ECONNREFUSED 127.0.0.1:8080	tcp
c585bc27-9306-4542-bfeb-4b349f947204	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:04:23.4	slow	1584	\N	tcp
df49e633-6d62-4856-891b-6e56cb3d10bb	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:04:24.817	down	3000	TCP connection timed out after 3000ms	tcp
649bd383-db99-47f2-aafb-2aa515fadec4	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:04:24.824	down	3001	TCP connection timed out after 3000ms	tcp
5c13c885-a832-4cd0-b97f-2a22019ca6e9	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:04:51.836	down	2	\N	tcp
6596b500-5453-4566-bcb4-35175994b8ce	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:05:21.834	up	3	\N	tcp
e6b49aee-7bff-477c-8685-e29f34a97c27	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:05:21.836	down	4	\N	tcp
5fc22123-d161-401b-9f5c-9410c6697720	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:05:21.846	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
f2018220-33ff-439c-9d86-6e1fc694394c	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:05:21.879	up	24	\N	tcp
bf33c4d9-ade5-4ef4-8a1b-3828ed1d8c32	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:08:51.934	down	4	\N	tcp
81e51fa4-06d3-4ae4-aaf2-a099e031f83e	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:08:51.933	down	3	\N	tcp
5f3ccd7b-1426-4457-b0d7-676517f86636	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:08:51.934	down	3	\N	tcp
f5d1ab52-c7aa-4e3f-97d7-33bb1dfad8e0	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:08:28.15	down	4	\N	tcp
7157f962-8e4e-423c-a703-a9b3a2ba49f1	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:08:28.155	down	8	\N	tcp
d4388bc2-b7d0-4f0b-8816-65dd66b7589f	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:08:28.196	up	28	\N	tcp
6d19fbf7-be0f-4c06-94ff-82f3df5f885c	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:08:58.154	up	5	\N	tcp
44efdad7-8846-4f6e-85ca-3920bec101de	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:08:58.156	down	8	\N	tcp
2b671747-0412-4cd6-8407-104410c9d99f	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:08:58.169	down	3	connect ECONNREFUSED 127.0.0.1:6875	tcp
add3d9ba-37ae-4d67-8517-c7e76cd57cec	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:08:58.285	up	119	\N	tcp
c4f6f123-945e-4ab9-8834-92c7e2276530	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:08:58.287	up	121	\N	tcp
0676f312-28bf-49c9-bd89-bdd7909c648c	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:09:01.174	down	3000	TCP connection timed out after 3000ms	tcp
2b3f3477-6bab-4c47-b64d-b37fc4c7323b	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:14:28.36	down	7	\N	tcp
0c288df1-f889-4cd6-91e2-6b7b8741706e	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:14:28.376	down	4	connect ECONNREFUSED 127.0.0.1:6875	tcp
63c6417b-82d7-4c36-9b24-24cda1b4027f	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:14:28.386	up	4	\N	tcp
cc568582-1aa5-4c6d-adfc-b838ee5b0453	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:14:28.39	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
c165053a-97ea-414b-b35a-241ac343b023	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:14:28.392	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
278fe779-5464-4e33-8c12-cb9029a6b782	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:14:28.524	up	142	\N	tcp
626339e3-8edd-4d32-b249-45ff4aaf610c	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:14:31.37	down	2997	connect EHOSTUNREACH 192.168.1.222:8082	tcp
a5fc9d9c-0caa-492d-8c3f-1289749b724a	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:14:58.392	down	6	\N	tcp
97ef6b30-dab9-485d-94a9-b9104c2b2d5f	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:14:58.394	down	8	\N	tcp
875193a6-4847-48af-8c50-ee0e77b8dead	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:14:58.406	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
c8a41a9b-f12f-43fe-ae78-d737fd2f0622	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:14:58.41	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
305367af-e403-47dd-a1dd-779b3c52cff9	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:14:58.412	up	1	\N	tcp
832f888e-ea5c-4883-914a-a838fa11fdab	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:42:16.041	down	4	\N	tcp
38830fbb-e2b5-4d68-99db-af0556670083	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:42:16.042	down	5	\N	tcp
1311b18c-e919-44ae-938e-5a0b47571fd6	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:55:51.621	down	2	\N	tcp
0250e4c6-0913-4041-ba9e-3a4405a0163e	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:55:51.627	down	8	\N	tcp
4bd40559-6f0f-4977-b895-77c476a5864c	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:55:51.628	down	8	\N	tcp
34a0a672-1111-4a51-98c5-96c451a7bfb0	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:55:51.638	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
d239f6a5-ebce-4c5b-823e-edcc0e335e79	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:55:51.674	up	37	\N	tcp
b46c9030-ba80-49a9-98aa-d7e2d57ee904	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:56:21.63	down	3	\N	tcp
2a0fd72c-ef62-4e98-bb13-73f825a593dd	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:56:21.633	up	5	\N	tcp
42485d4f-3bd7-479a-9b85-e6711caaea24	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:56:21.643	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
c49b8ff3-4a7f-4838-8aed-6bb476aadd0f	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:56:21.777	up	137	\N	tcp
ff76a799-781f-40ef-8847-6ab5faed75ed	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:56:51.62	down	3	\N	tcp
6a1f0d28-19bf-436d-bf5a-e09123cd244b	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:56:51.635	up	5	\N	tcp
e4e0b577-1fa8-4b63-b314-c8f2c6be8821	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:56:51.642	down	6	connect ECONNREFUSED 127.0.0.1:8555	tcp
6e29608c-3a89-4e35-b4ad-ab9ecf643ae6	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:57:21.637	down	2	\N	tcp
13d27343-2eda-4ae9-911f-51b5d41b2658	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:57:21.638	down	2	\N	tcp
07494175-9355-4d3d-9e0a-3893465782ff	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:57:51.642	down	5	\N	tcp
0596cd7e-82a9-4369-bd1c-88afcfb29219	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:57:51.653	up	1	\N	tcp
59594f9b-e591-4c3c-aefc-282edb2bb78f	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:57:51.66	up	8	\N	tcp
f98b8701-c181-4914-b487-a08c01ce94c7	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:58:21.648	down	1	\N	tcp
0816d88b-f26e-4f69-b5fd-d85d480cc835	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:58:21.651	down	4	\N	tcp
5d991d57-8b2a-4f10-9c0a-fcabdf2b0b4d	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:58:21.672	down	13	connect ECONNREFUSED 10.0.0.200:3100	tcp
6185afe1-96bb-4038-b27c-1ead679a3971	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:04:21.805	up	3	\N	tcp
30c7f3ff-1072-4ab2-9cb8-100b6bfe0b9a	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:04:51.836	down	2	\N	tcp
1da31caf-b831-4dbb-802b-c867f04f1a7a	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:04:51.838	down	4	\N	tcp
68282075-34db-4d04-bdb7-2ebbb5848513	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:08:28.15	down	4	\N	tcp
0d1ea816-5efc-402b-bf7a-de5425f987e8	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:08:28.155	down	8	\N	tcp
3552e474-c6d6-4322-b06f-11fea33d6158	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:08:28.194	up	27	\N	tcp
43d032fb-3a99-41cf-9adc-28ade395d88e	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:08:58.152	up	4	\N	tcp
58e2fce7-fcb6-42e8-aacb-df51196b648b	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:08:58.155	down	6	\N	tcp
a30eceb6-c47d-47c8-acc8-52c8de2c6291	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:08:58.157	down	9	\N	tcp
b463458c-e933-45c3-b697-adf5916ed359	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:08:58.168	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
bb821995-5bf6-4029-b5b0-22682031817f	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:08:58.286	up	120	\N	tcp
9145d563-6426-4e5e-9915-d08e9345d2e4	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:09:01.178	down	3000	TCP connection timed out after 3000ms	tcp
ca13b233-f6d3-4e6e-b844-b6b764de9738	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:15:01.406	down	3002	TCP connection timed out after 3000ms	tcp
d7190339-1e46-421f-8e2a-138a58c6c7ef	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:15:01.405	down	3001	TCP connection timed out after 3000ms	tcp
a299dd69-ae3e-4e93-ac39-948576ec7014	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:15:29.058	down	48	\N	tcp
2b66e3b5-431f-44c1-a43c-09a0ff945bb0	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:15:29.055	down	46	\N	tcp
27093d56-d19b-4b20-b469-d16a8d8780e3	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:15:29.486	up	31	\N	tcp
b60021a1-2cf6-4717-9da4-735001408691	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:15:29.478	down	24	connect ECONNREFUSED 127.0.0.1:8556	tcp
4e723bc1-c838-4e7d-a145-947b6946adaa	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:15:29.583	up	14	\N	tcp
300e9dde-2f93-4291-8856-26f7b9fc4eb1	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:15:29.662	down	7	connect ECONNREFUSED 127.0.0.1:9000	tcp
40fdf9ff-4431-42d0-ad22-cc97f1dbead7	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:15:32.458	down	3003	TCP connection timed out after 3000ms	tcp
1c2ba035-e9ab-4f11-b23a-c31a3bb5f62f	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:15:32.467	down	2906	connect EHOSTUNREACH 192.168.1.222:8080	tcp
f73b0b6c-4f12-44bb-b13c-076fdd595346	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:15:59.008	up	33	\N	tcp
f99a1bf2-88fe-4c37-82cc-4b7640d35df9	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:42:16.039	down	3	\N	tcp
209d49d6-5513-48f4-bf7c-4ea21a420402	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:55:51.622	down	3	\N	tcp
ed5a97f7-c9de-437f-9776-cd62b0671c61	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:55:51.628	up	8	\N	tcp
39898a06-131f-4b72-9c4c-e6982e492316	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:55:51.64	down	4	connect ECONNREFUSED 127.0.0.1:6875	tcp
67a59280-e492-4e8a-8838-c86c3bda677c	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:55:51.675	up	38	\N	tcp
df252c37-81c5-4ace-9e99-ba0a089181b2	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:56:21.63	down	2	\N	tcp
ad8b53f6-3b72-4c53-ae7d-d91b9bb47b88	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:56:21.633	down	5	\N	tcp
ba5e1bfc-6559-41a3-accf-fca4246b6825	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:56:21.642	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
772675aa-bbce-4576-995a-d28d8425db88	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:56:21.644	up	4	\N	tcp
8bb72ca0-bc3e-4dd7-bb13-c8b6ddba456b	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:56:21.648	up	1	\N	tcp
3af16223-49d0-4328-a0ce-3160809dd74d	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:56:21.651	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
aa0ed18c-ec61-432b-bba3-f631636ed365	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:56:21.654	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
8f43039c-21f1-4dd9-b675-87b74571c988	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:56:21.656	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
37999dae-3658-4ad1-b8d7-588c35b0fbaa	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:56:21.659	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
335a40d9-035d-41a7-8b77-d328b70dd533	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:56:21.661	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
e208954b-33b8-4085-a1d0-06ef01004b13	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:56:21.776	up	136	\N	tcp
8bccac4a-731f-4358-99d8-f054e6c52e98	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:56:21.78	up	131	\N	tcp
7c175ad9-e491-47b0-a57f-97acf0cf09f4	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:56:24.647	down	3000	TCP connection timed out after 3000ms	tcp
e44f0384-d726-461d-b8dd-001efd97d2a8	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:56:51.619	down	2	\N	tcp
cde3a4fa-f0a6-4348-8c8f-5420259ccf8d	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:56:51.621	down	4	\N	tcp
1318fa87-abf4-42a8-bdd6-cae78b7556ca	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:56:51.631	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
18470d5e-b056-4261-aa15-f89a0f7c2e29	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:56:51.634	up	5	\N	tcp
58b82d87-7221-4aea-996b-0be956e88bcc	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:56:51.644	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
1ad54089-8f14-493b-b284-e99fc503cc4e	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:56:54.63	down	3001	TCP connection timed out after 3000ms	tcp
83229f41-9fc6-4791-b711-87084614823d	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:57:21.638	down	3	\N	tcp
d3058950-b282-4bf8-be7d-ffe8eba4245c	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:08:28.15	down	4	\N	tcp
dd955b92-434e-4af9-85fd-b1c2e60bed2c	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:08:28.156	down	9	\N	tcp
3620f2f5-07ba-46a0-a64a-e11b57e2e6ca	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:08:28.192	up	25	\N	tcp
9c654e8e-4e8d-477f-9280-480ec9664448	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:08:28.196	up	28	\N	tcp
097005ff-e203-4f6b-9f35-edd3141ac7c5	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:08:28.203	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
d9a0092b-ad3e-4c42-99c3-bd8d70a1cfcc	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:08:31.168	down	3001	TCP connection timed out after 3000ms	tcp
a7c69b7f-8bcc-4a28-aec1-7144f0bf5140	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:08:58.152	down	4	\N	tcp
56392a8d-408a-4495-8253-aebcdbb1045b	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:08:58.154	down	6	\N	tcp
dbbd990e-09b1-4267-b46f-1de41a00258e	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:08:58.157	down	8	\N	tcp
73338c1a-c5f8-4b43-8618-f0ba801a3f02	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:08:58.286	up	119	\N	tcp
58e84275-1158-494b-a55c-91606fcbb0a4	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:08:58.288	up	122	\N	tcp
981e7299-49c4-4b95-8bd6-1cde74120808	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:09:01.175	down	3001	TCP connection timed out after 3000ms	tcp
efda564a-1914-42c8-b8a7-47518412d90d	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:15:01.406	down	3001	TCP connection timed out after 3000ms	tcp
93094c2b-5c70-4eae-be47-2c53bf321d52	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:15:01.407	down	3002	TCP connection timed out after 3000ms	tcp
f74330bf-fe9b-4715-a42d-c4937f69a2b0	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:15:29.035	up	27	\N	tcp
7224f877-c2fd-4000-9ce6-c9cd49ae043e	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:15:29.103	down	91	\N	tcp
ef8033f9-f915-4db2-8ce0-4dae6e1c6bdf	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:15:29.529	up	71	\N	tcp
05b28d59-9223-4976-a693-f719f625e1d9	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:15:29.588	up	9	\N	tcp
4bd7c744-ea28-4a3b-98ea-ebf9179fefbc	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:15:59.015	down	41	\N	tcp
2cefcf1c-5978-4a7a-9131-45a290a201cc	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:15:59.19	up	46	\N	tcp
05d4c369-ea8f-4094-8ecb-b26b81a78269	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:42:16.044	down	7	\N	tcp
24a2e768-d094-4202-80ce-a0a1bbe64ca8	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:42:16.07	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
9aaa52ff-ab13-4c0a-984f-19350dc7f9f6	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:42:16.071	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
f6a647e6-13be-4c4a-9026-04da081e9cdf	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:42:16.075	up	6	\N	tcp
16d46625-5de7-456e-950a-a81ff575dcfb	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:42:16.078	down	3	connect ECONNREFUSED 127.0.0.1:7000	tcp
42ebe240-5410-4604-a8e3-2e344df194f7	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:42:16.081	up	5	\N	tcp
20f5e7c6-55d7-4d30-aca3-6dc86630f732	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:55:51.624	up	5	\N	tcp
424bd7c7-c831-40db-a21f-5025d5ff74d5	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:55:51.628	down	9	\N	tcp
27bbbede-cfb5-40ef-86e0-4f54961762ac	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:55:51.641	up	4	\N	tcp
a22c318a-73a1-46b2-bec2-e9d5199ad4ac	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:55:51.647	down	0	connect ECONNREFUSED 127.0.0.1:8080	tcp
90604027-b4f7-4f1a-b872-ce7b2f24c99d	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:55:51.651	down	0	connect ECONNREFUSED 127.0.0.1:8555	tcp
983e0c04-6816-4bc1-b16d-3be68032f5ba	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:55:51.654	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
9471df60-f929-4a14-aece-393adddf47e0	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:55:51.657	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
98120b61-677b-41b3-b1b3-1eed8fb5a2c1	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:55:51.659	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
055af612-3580-4c9a-a587-57c911872ac8	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:55:51.663	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
78d22355-2baf-4e72-8cbd-d5686c9d454f	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:55:51.665	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
76790591-478a-4b19-9a8b-bb7b2d72dfab	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:55:51.675	up	38	\N	tcp
27c4357d-8664-404e-9d38-372d456b1722	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:56:21.63	down	2	\N	tcp
6bbb5e98-8a1e-4ed2-b6a1-2897e6c012b2	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:56:21.632	down	4	\N	tcp
8a820639-23f6-484f-ad54-d0fa86030613	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:56:51.619	down	2	\N	tcp
b1e823fc-198c-432f-b729-3e8066e7aea6	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:56:51.621	down	4	\N	tcp
300e497d-6c39-4551-921c-fa912ab9ea95	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:56:51.632	down	3	connect ECONNREFUSED 127.0.0.1:8080	tcp
b46e04ae-fa38-418b-b399-fa69afa3cfc7	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:56:51.634	up	5	\N	tcp
ee5b7e7e-ec80-4516-b6df-bfc4599481d6	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:56:51.645	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
2262933f-e69d-432c-8f1d-243efbc43025	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:56:51.778	up	135	\N	tcp
b0d23dcc-27d4-446c-a501-8d1d8ffe0629	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:08:28.151	down	4	\N	tcp
691be70b-a66b-497c-a459-3a00cb3025ba	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:08:28.156	down	9	\N	tcp
c96fdbad-ebb2-468d-8b48-661b983004aa	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:08:28.169	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
2db7b502-ee6d-42c4-b995-3a25fa19c78f	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:08:28.195	up	28	\N	tcp
64d78190-015b-4045-8cd7-1207457f9261	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:08:28.203	down	2	connect ECONNREFUSED 127.0.0.1:9020	tcp
26bebf55-c0b5-446e-af64-46b303ada31b	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:08:31.169	down	3001	TCP connection timed out after 3000ms	tcp
cca1a51f-a586-46ca-83a7-53578bead993	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:08:58.152	down	4	\N	tcp
1cf8426b-a361-437c-a314-3ed9beade76f	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:08:58.153	down	5	\N	tcp
f3f0dfe3-0b54-4e0e-9ecb-7a71f0f30b04	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:08:58.155	down	7	\N	tcp
4eadaaa0-e062-45c3-8108-fdda53453ff7	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:08:58.158	down	9	\N	tcp
12bedd2d-d42e-484b-b9e5-bd1a037d66db	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:08:58.17	down	4	connect ECONNREFUSED 127.0.0.1:4100	tcp
a0ac3c7c-1a0d-4f3a-9587-70e758428901	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:08:58.17	down	4	connect ECONNREFUSED 127.0.0.1:8555	tcp
0ca3b136-5196-426a-8d03-4c3e0e8d1f6d	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:08:58.284	up	118	\N	tcp
b0c5a0a4-710f-4e1d-a545-a92af86df89e	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:08:58.287	up	120	\N	tcp
ee15b370-6591-4710-b80e-3be0616ce1e6	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:09:01.174	down	3001	TCP connection timed out after 3000ms	tcp
d5f3a095-83b7-487d-8e8e-999a5d4d84a8	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:15:01.407	down	3002	TCP connection timed out after 3000ms	tcp
589e3c0b-4c96-48c2-b4c4-a70ee50b712a	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:15:01.407	down	3002	TCP connection timed out after 3000ms	tcp
4884662d-0e4f-4fb4-b84f-9e6bf9843b8c	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:15:01.406	down	3002	TCP connection timed out after 3000ms	tcp
69b4fb19-7249-469d-a0ad-1091366ae02a	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:15:29.078	up	64	\N	tcp
b7494ae5-6c73-4d38-b759-dbc345c7734f	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:15:29.048	down	40	\N	tcp
5b3ce0a0-f317-455a-a311-c4145b0fa7cf	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:15:29.492	down	38	connect ECONNREFUSED 127.0.0.1:8080	tcp
90318261-67ec-4653-9427-bb2a0be610d4	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:15:29.639	down	25	connect ECONNREFUSED 127.0.0.1:9006	tcp
94bf8bb7-e9cf-4ca0-a500-2cee5ba81408	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:15:59.017	down	43	\N	tcp
6c42adab-07e5-4a46-9ff9-26d503997c18	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:15:59.01	down	36	\N	tcp
58bbd6ac-0cd6-4b09-9fcb-6e451b911e12	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:15:59.167	down	23	connect ECONNREFUSED 127.0.0.1:8555	tcp
f0a746d5-ae01-4232-bf28-59bacae4f662	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:15:59.164	down	21	connect ECONNREFUSED 127.0.0.1:4100	tcp
242f8cb5-ca29-453e-8639-6544524cdc5a	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:15:59.185	up	42	\N	tcp
76001891-64fa-4445-9b76-f7ed1dcd5a53	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:42:16.042	down	6	\N	tcp
314019ca-762d-4da5-ab08-e252a89bb7aa	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:42:16.07	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
dd33e8f0-9e11-4c48-8320-8af07f78b8f8	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:42:16.074	up	5	\N	tcp
d4b2b71f-1194-4dc8-8f2a-f417bd63db02	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:55:51.624	down	5	\N	tcp
657e94f4-bb2b-4875-b378-24907fb3f715	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:55:51.675	up	29	\N	tcp
feca91d6-0c6a-4a8e-85f9-c355169627d4	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:55:54.637	down	3000	TCP connection timed out after 3000ms	tcp
59f39cb9-579c-455b-8ede-3f1627cda661	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:56:21.632	down	4	\N	tcp
48ed8164-d650-4d91-afba-f1fd12a2d104	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:56:21.644	down	4	connect ECONNREFUSED 127.0.0.1:4100	tcp
37f280fb-7b4e-4e95-a55b-a440fab5109a	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:56:21.644	down	4	connect ECONNREFUSED 127.0.0.1:8088	tcp
f8d22052-f413-4174-87d2-9d336750d945	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:56:21.776	up	136	\N	tcp
4caf403a-7427-49bb-831d-558dd7a290b2	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:56:51.62	down	3	\N	tcp
e63c2a7e-c4b6-435d-bb4f-7f1743a61f1f	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:56:51.622	down	4	\N	tcp
eeaa5b42-9cb4-4010-854b-17fd659995b0	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:56:51.631	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
c8dcced2-1f7c-4511-9816-4d0820d41093	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:56:51.634	up	5	\N	tcp
907111d3-fb17-426f-aefe-e4de2e551825	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:56:51.645	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
d5c63777-d1e0-410d-b146-cd79a271361d	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:56:51.777	up	140	\N	tcp
f40e9d0c-9ad7-4e8a-a736-df3b15cc0243	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:56:54.629	down	3000	TCP connection timed out after 3000ms	tcp
e175a089-3060-452b-b830-fd47c7f5d862	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:08:51.932	down	2	\N	tcp
65d095ce-c0a7-460e-9703-7e5e073ee9d0	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:08:28.151	down	5	\N	tcp
3c71f2da-a89f-4944-b5b4-517bfc176ae2	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:08:28.194	up	27	\N	tcp
d1fc63ba-eec2-4529-9b68-d2137e657b78	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:15:29.101	down	90	\N	tcp
748a5828-5c53-412e-87ac-f03876d763f8	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:15:29.097	down	86	\N	tcp
4bee7ab9-2884-4b3c-8b2a-7c10e571151d	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:15:29.053	down	45	\N	tcp
c30e74ab-05a7-47a7-8b17-e361f1a5aa03	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:15:29.477	down	23	connect ECONNREFUSED 127.0.0.1:8088	tcp
63d9fd56-7755-4f08-8850-54575496461b	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:15:29.527	up	70	\N	tcp
10a7b208-607b-40d1-8fcf-317cf806166c	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:15:29.589	up	4	\N	tcp
24357e32-696c-4853-b275-d6a03b8eca4e	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:15:29.641	down	11	connect ECONNREFUSED 127.0.0.1:8078	tcp
5b6ea7e5-8383-46b6-bd36-319d43352216	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:15:59	down	26	\N	tcp
313277e2-4b5f-4c9b-a8ae-0f5cd463930f	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:42:16.04	down	4	\N	tcp
8160fcb3-4a72-4711-b236-fe3e396ed9ff	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:42:16.069	down	3	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
8a880730-0a32-460c-bb09-a5c959a2b247	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:42:16.07	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
05ea1a1a-3f3a-4bfe-a09f-717451bbbe97	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:42:16.074	up	5	\N	tcp
faf88a9e-5ba4-4512-8bdb-9019a80dad35	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:55:51.622	down	3	\N	tcp
7ecfd4e8-0620-438b-be53-4082d9f0396b	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:56:21.629	down	2	\N	tcp
efe48673-476e-4bc8-af1d-9b7daff05240	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:56:21.632	down	4	\N	tcp
eb23001b-ce5f-4164-ac69-955dd9ff8fc0	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:56:51.619	down	2	\N	tcp
d0951e88-efd6-4e96-9091-d253731a354f	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:57:21.638	down	3	\N	tcp
8e90fb2a-5af2-4240-b7d7-67c6ada0f641	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:57:21.642	up	6	\N	tcp
82f8d535-e1e6-4e84-953c-f26d34644df4	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:57:21.654	up	2	\N	tcp
e7b059c9-9b51-4570-a1d3-b93ded711701	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:57:21.656	up	3	\N	tcp
c759f401-fee0-4e56-8a38-fbab8f30aac0	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:57:21.661	up	9	\N	tcp
36591abe-58a9-4579-a1aa-dcd4d260033a	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:57:21.666	up	6	\N	tcp
fedf7147-2d94-4df8-9cb9-33c6364f6e7c	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:57:24.653	down	2994	connect EHOSTUNREACH 192.168.1.221:8180	tcp
358d6912-3505-496b-88f2-3e03b57260fd	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:57:51.64	down	3	\N	tcp
e80dd66a-53b4-4641-9b4d-b845ee8e52e1	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:57:51.644	down	6	\N	tcp
c74714b8-e4ce-4c8b-9a87-df1841b5fe5d	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:58:21.65	down	3	\N	tcp
90e44771-1308-4347-a8da-df49276fd55b	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:58:21.673	up	13	\N	tcp
7e388162-f047-4db0-8c08-93ba5c1e4d92	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:04:21.826	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
4ef0634f-377a-4651-8797-0d9c2f754919	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:04:21.829	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
8787162b-2a45-4234-ab5c-94ada98c5a76	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:04:21.832	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
1fc3d6ad-d4e8-4752-a5e0-6e285552e1e9	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:04:21.834	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
7345a918-ef47-4df0-b31b-f4d3f45161df	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:04:21.836	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
71f56ee3-f1ac-42d6-aac6-ef0de30ece77	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:04:23.402	slow	1579	\N	tcp
44d54de9-7bea-48c9-a9f6-a40839022d3a	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:04:24.817	down	3000	TCP connection timed out after 3000ms	tcp
92d2c84d-00cc-47fe-a234-d83aa015382b	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:04:24.824	down	3001	TCP connection timed out after 3000ms	tcp
abe429a6-0116-4591-be5c-e76426749836	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:04:51.837	up	3	\N	tcp
ff968d40-0a92-4c80-8064-408265ac9bd0	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:04:51.848	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
49db500a-e842-49f9-8cf8-a42cc914a615	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:04:51.88	up	33	\N	tcp
658b358d-be2b-4a7c-8a34-63c5e03df128	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:05:21.834	down	2	\N	tcp
f345e1b7-2228-4c5a-82b3-f4ceb0424fc9	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:08:51.933	down	3	\N	tcp
754593e0-4b24-4e4d-9ab1-181b1852cbe6	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:08:51.974	up	2	\N	tcp
429c5574-54a3-4608-92ce-5df261774ea1	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:08:51.991	up	19	\N	tcp
438c43ce-ee82-4623-8ad9-46a1b8830286	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:09:21.946	down	1	\N	tcp
7a5ea39e-7c1e-431c-9e50-e8c66c9e72c0	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:09:21.948	down	4	\N	tcp
26136166-8cb4-4b56-9ac7-fc1fabb343ab	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:05:00.2	down	7	connect ECONNREFUSED 127.0.0.1:7000	tcp
99093d46-d8be-48dd-94cd-722180c464c7	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:05:28.043	down	4	\N	tcp
fe48a682-ba1f-4ab3-a8e1-73811e603569	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:05:28.045	down	6	\N	tcp
32702d7b-524e-410c-8239-80a43835998c	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:05:28.047	down	7	\N	tcp
fd61b882-0685-48e9-89d3-5766484cdbb0	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:05:28.049	down	9	\N	tcp
f9f02f13-64f2-481f-a4b0-44d5f4bb2031	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:05:28.065	down	4	connect ECONNREFUSED 127.0.0.1:9001	tcp
5a442acc-e156-4721-b2ef-a2fd3f873b7d	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:05:28.087	up	25	\N	tcp
3c8d9295-f2e6-4311-b77b-d7a9b5a9475b	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:05:58.068	up	8	\N	tcp
9e47ebb6-1ec5-44e2-b087-8086538ea930	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:05:58.232	up	151	\N	tcp
c66181f7-647b-49c6-949e-f3e717a20c37	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:05:58.235	down	154	connect ECONNREFUSED 10.0.0.200:3100	tcp
655feb4a-8c75-47a4-b2de-79474a1313b4	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:06:01.09	down	3001	TCP connection timed out after 3000ms	tcp
bd169399-64ba-4dc4-a701-1cc87e456751	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:06:01.095	down	3000	TCP connection timed out after 3000ms	tcp
00009b84-6c16-44d8-bbbd-57a38904b0e5	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:44:49.034	down	3	\N	tcp
f8593932-ae5d-4af1-830d-de0aed38fd46	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:44:49.04	down	8	\N	tcp
c0c189e8-aca2-4ab3-a34c-86244c630dfc	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:44:49.036	down	4	\N	tcp
2b2aad5c-85d9-484f-991e-60eaa2abd47e	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:44:49.171	up	109	\N	tcp
b8455e23-7dde-4750-bac1-0b13bb3adbcc	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:55:51.626	down	7	\N	tcp
c87719aa-9fd8-4d96-a8e6-ea05364c0502	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:55:51.675	up	38	\N	tcp
824ac347-87cb-4f14-bcea-025ff25e59bf	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:55:54.636	down	3000	TCP connection timed out after 3000ms	tcp
a24a6cc4-9f3d-42db-aa19-c271072383be	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:55:54.646	down	3001	TCP connection timed out after 3000ms	tcp
02d73058-6b2c-44c7-b57a-7206b497cce4	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:55:54.647	down	3000	TCP connection timed out after 3000ms	tcp
2e809f09-c288-4c9f-8c0e-aa1a9d7c711a	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:56:21.631	down	3	\N	tcp
ec7cd9d4-f645-4693-9e34-7998de2b20b8	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:56:21.644	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
e75e749b-fc0d-49ae-99a9-f9c6c824870d	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:56:21.648	down	1	connect ECONNREFUSED 127.0.0.1:6875	tcp
cb4ad135-fcd6-4ff8-8749-a2aa519782ac	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:56:21.777	up	137	\N	tcp
f021e409-e837-4b58-9026-2fd0b43550e8	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:56:21.78	up	129	\N	tcp
278aedc2-eb5e-40f0-b68f-ac4a4df42cb2	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:56:24.641	down	3000	TCP connection timed out after 3000ms	tcp
9a4d9cc2-dde5-4554-b474-631852e5b4b7	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:56:24.648	down	3001	TCP connection timed out after 3000ms	tcp
f345aa31-ab4d-43d4-bf95-3a052535842e	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:56:51.619	down	2	\N	tcp
679ade0f-1bf0-4cb0-8a8b-cf86a996f1f9	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:57:21.641	down	6	\N	tcp
b479a46a-92c1-4bcb-ac99-822403c053a0	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:57:21.656	down	4	connect ECONNREFUSED 127.0.0.1:8556	tcp
0a341e92-bca4-4d45-baec-6ec41be5a382	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:57:21.66	up	8	\N	tcp
d940b07c-88ef-469d-be3f-1d6f809b8a38	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:57:51.641	down	3	\N	tcp
d9fcd880-09e7-415d-8722-b52112fe894a	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:57:51.653	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
56f45744-361d-4dcf-9d34-55124ced8339	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:57:51.66	up	8	\N	tcp
cb21c6d6-2317-4469-bdf1-40b16d672623	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:58:21.648	down	1	\N	tcp
3e966b2b-9c11-42a8-80f4-a19e56da81ea	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:58:21.65	down	3	\N	tcp
21e3fd46-aa14-4c41-9d6f-24986186cce1	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:58:21.67	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
8776b899-1511-427b-9509-4cb1c4c674b7	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:58:21.672	up	13	\N	tcp
1fa1f4ba-244a-4e7d-96ec-8c0917826033	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:04:51.837	down	3	\N	tcp
b268d695-2481-4186-a55d-a92b628bcba9	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:04:51.851	down	4	connect ECONNREFUSED 127.0.0.1:8556	tcp
8c2ca9e6-6a1f-40c1-bd7e-13b52480db2d	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:04:51.858	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
d61df4b5-c4ec-47d8-93b5-f9d855f13178	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:04:51.881	up	24	\N	tcp
fdd96f3b-a91a-4100-8ec8-77572e311ad1	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:04:54.847	down	3000	TCP connection timed out after 3000ms	tcp
1987e94d-f2b4-4e04-b15b-babbb00de16c	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:05:21.834	down	2	\N	tcp
0c9a2728-98c5-4a9e-8b05-687bf3245d87	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:08:28.152	down	6	\N	tcp
ed1f6b9d-8ad3-4685-81cf-f1ca47c6c424	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:15:29.029	down	22	\N	tcp
78ce21ac-3a3c-4d20-a4dc-835ba35c778b	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:15:29.1	down	88	\N	tcp
9e6faf06-7963-4d52-bcc3-63d7effba746	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:15:29.522	up	67	\N	tcp
b67438e5-1dd0-4ef7-957a-d84ea4e31be1	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:15:29.657	down	26	connect ECONNREFUSED 127.0.0.1:9020	tcp
610c5a70-e4be-4c92-a78d-b9d395b3ea31	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:15:32.47	down	2908	connect EHOSTUNREACH 192.168.1.222:8082	tcp
ffb0e5fe-2104-4e76-99b7-da314891373c	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:15:58.998	down	24	\N	tcp
ad5f0bfb-e1f8-47e5-bdee-af1d242b6704	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:15:59.004	down	30	\N	tcp
0a2169ff-2299-4cb2-91b6-4881c8c7b7f4	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:15:59.163	down	21	connect ECONNREFUSED 127.0.0.1:6875	tcp
7c4c8885-68b4-49ab-a95d-8b345dc9bb82	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:15:59.179	down	34	connect ECONNREFUSED 127.0.0.1:8088	tcp
d084ef77-7667-4dbd-a89b-fbfa7443fde4	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:15:59.196	up	49	\N	tcp
4b2f7929-d113-4798-a078-124f75523930	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:15:59.261	down	10	connect ECONNREFUSED 127.0.0.1:9001	tcp
2be7d167-dd47-4a7a-9f3c-320e78c2fdb0	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:15:59.363	up	151	\N	tcp
3453e6b8-81e3-452f-93dd-a0d1c536a6a4	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:16:02.162	down	2913	connect EHOSTUNREACH 192.168.1.222:82	tcp
5baeae93-42a7-49a6-bf3d-27d0183241a5	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:16:02.148	down	3006	TCP connection timed out after 3000ms	tcp
bb866174-5998-4983-a3fc-3454c49a6309	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:44:49.037	down	5	\N	tcp
a5828f4d-74ab-47ef-9314-b262c9afa3de	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:44:49.035	down	3	\N	tcp
b052b5ca-5d5b-49a4-9412-ffe8f62d99e1	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:44:49.173	up	110	\N	tcp
677c8115-5b1b-4a04-8648-c627dc6846aa	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:55:51.626	down	7	\N	tcp
9d781e60-3960-49cc-ac43-e7a176389a65	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:55:51.674	up	38	\N	tcp
db5065d6-1fc9-4122-bba0-03d5b14cd7e0	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:56:21.631	down	4	\N	tcp
e2a0fb50-1397-4a06-aa80-b4ee0bbca92e	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:56:51.62	down	3	\N	tcp
7556c40f-7f05-4b7d-83f0-26add0a00212	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:57:21.639	down	3	\N	tcp
b2424a6b-5335-4ebd-b97c-31e7831fcb51	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:57:21.642	down	6	\N	tcp
5d61bf52-e499-4758-b70a-dc19f148373b	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:57:21.655	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
b01e7db2-bc84-4378-81d4-5a731d62a5e6	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:57:21.66	down	8	connect ECONNREFUSED 10.0.0.200:3100	tcp
77f83468-8716-4cce-b276-5b20c81e78fa	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:57:21.662	up	9	\N	tcp
72ff1428-181d-4201-9bcd-e239073d2587	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:57:24.652	down	2999	connect EHOSTUNREACH 192.168.1.221:4001	tcp
fb0f24cb-5a89-4233-b72d-f7c94d32d341	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:57:51.64	down	2	\N	tcp
150b76d9-272e-496a-835e-23ed7ba0c05c	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:57:51.643	down	6	\N	tcp
8238c789-83df-4d20-9a33-dc4d83d1a497	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:57:51.653	down	1	connect ECONNREFUSED 127.0.0.1:8088	tcp
06272972-d499-4329-b72b-c27b3be7dab2	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:57:51.659	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
cd2df27f-7fba-429a-a1ce-d5a16715d072	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:57:51.66	up	9	\N	tcp
43d2d44d-9cda-4cd3-bdc4-84230eb0be21	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:57:51.664	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
24365b92-a8ca-40bf-9acf-31bddbc15f2d	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:57:54.653	down	3001	TCP connection timed out after 3000ms	tcp
ecc401f8-3ca7-4e6b-9c0b-770e0ed2f860	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:58:21.649	up	2	\N	tcp
9889138a-66ae-4e06-8d16-444fba9b0242	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:58:21.673	up	7	\N	tcp
1dfc1744-6936-4bce-8b78-0a750a770ce7	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:04:51.881	up	33	\N	tcp
2d691409-ca7d-45d6-93d9-a3c32a1e58c3	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:05:21.833	down	2	\N	tcp
9500836d-5ba5-4776-947e-bb4eb82ad89d	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:05:21.835	down	3	\N	tcp
10b6e6e1-8bc1-4813-9e93-45ebaa1b17ff	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:05:21.846	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
b7373684-6429-4813-9a5b-047ac5b4dade	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:05:21.846	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
39de01af-8674-4bc3-90a3-d1e84c09773d	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:05:21.854	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
9de016ca-1140-46ce-a2c4-9e158c27ddea	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:08:51.932	down	1	\N	tcp
5e99125a-07ef-46a0-9968-46afd8582580	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:08:51.974	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
641a1475-7675-4e8a-bb0b-23f448c863aa	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:08:28.152	down	6	\N	tcp
ab461d05-f543-43cd-8d25-d6916604beab	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:08:28.193	up	26	\N	tcp
d2eeee8c-cf70-4b73-9e40-5f2b38ce4569	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:08:28.195	down	28	connect ECONNREFUSED 10.0.0.200:3100	tcp
4820b7e1-a05d-40b6-abbd-b25493639c17	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:08:28.202	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
fac92c68-5518-41d5-b990-38092f3e4c8f	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:08:28.203	down	2	connect ECONNREFUSED 127.0.0.1:9000	tcp
4bcf03af-bb0d-498a-9ec0-657684421eb5	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:08:31.169	down	3002	TCP connection timed out after 3000ms	tcp
6216bbb7-4bac-4deb-8fb5-e625f9f39549	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:08:31.177	down	3001	TCP connection timed out after 3000ms	tcp
2b328e27-ec4b-49d0-881a-8d8a1ca269ff	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:08:58.151	down	3	\N	tcp
498866b8-4a35-4265-9f95-e660c6956bc4	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:08:58.153	down	5	\N	tcp
fa87cb7a-56bb-4482-b09c-5baacfd0be2b	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:08:58.156	down	7	\N	tcp
3892be62-3e66-416f-a08f-2cf58c73b4da	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:08:58.17	up	3	\N	tcp
d40e4915-c74a-4326-96a0-a1d9f30c8880	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:08:58.175	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
dbad473b-92a8-4f15-8c21-050483eea814	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:08:58.285	up	119	\N	tcp
ce3d15a9-3812-47b6-b550-3480ccce1f46	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:08:58.287	up	121	\N	tcp
460aebe5-dda5-43ad-9c9b-608843cbfff8	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:09:01.175	down	3001	TCP connection timed out after 3000ms	tcp
adb9831b-01df-44b8-bf2f-a1ea6b5086f3	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:15:29.083	down	72	\N	tcp
fafb58a9-498b-4419-9d7b-c694be9074e8	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:15:29.493	down	36	connect ECONNREFUSED 127.0.0.1:8020	tcp
2c0a4044-1379-4422-8627-bd0ca2db6851	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:15:29.574	down	32	connect ECONNREFUSED 10.0.0.200:3100	tcp
a1d59974-db8d-49f6-86a6-841043bcebf0	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:15:29.661	down	7	connect ECONNREFUSED 127.0.0.1:9001	tcp
9fefdb28-a614-48cf-9392-84b3d8ff69c1	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:15:32.457	down	3003	TCP connection timed out after 3000ms	tcp
757e2e41-fe7a-4058-9a5e-b7e1c3086ae9	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:15:59.024	down	49	\N	tcp
63b08d97-4e79-47a7-abeb-957ae386280f	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:15:59.18	down	35	connect ECONNREFUSED 127.0.0.1:8020	tcp
03372725-98a8-4552-acb1-0ef20f9182d9	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:15:59.193	up	49	\N	tcp
247ed392-7161-4367-b608-227b0a3b74a7	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:15:59.255	down	5	connect ECONNREFUSED 127.0.0.1:9006	tcp
63fbc789-f1de-469d-80c7-649808077b47	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:44:49.039	down	6	\N	tcp
653e670f-fd3a-471c-8f7f-22b07fa60b40	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:44:49.035	up	4	\N	tcp
a90f00fd-cf6f-4acc-8f6e-8c4575f072ac	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:44:49.173	up	110	\N	tcp
835c5c5f-0d82-48e5-b5a7-e62327820c7a	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:55:51.622	down	3	\N	tcp
f51aff01-82c3-40d9-9d55-630c55a20988	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:55:51.64	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
a1d459ab-5081-4c4c-9b14-f026f60e121e	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:55:51.648	down	1	connect ECONNREFUSED 127.0.0.1:8020	tcp
ec84361f-7f2e-4a84-97cd-c7590af04698	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:56:21.63	down	3	\N	tcp
0e7a82fc-349a-4116-a59d-2d254a836a1f	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:56:21.633	down	5	\N	tcp
e285be53-f839-4f4b-807b-3cc1acad2a73	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:56:21.777	up	137	\N	tcp
c7536001-c421-4e6b-9952-8c99e3e4fb54	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:56:21.78	up	139	\N	tcp
5afff80e-f531-496d-819c-434fd3727e42	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:56:24.64	down	3000	TCP connection timed out after 3000ms	tcp
2dc8e19c-2a19-47a5-8732-f86447a1a26c	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:56:24.646	down	3000	TCP connection timed out after 3000ms	tcp
86b1ac50-f513-436f-9537-2d7a3305756d	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:56:51.621	down	3	\N	tcp
bd700e59-6984-4e6e-ad13-f0dd5afe56d5	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:56:51.634	up	5	\N	tcp
4d90657b-2b1c-47b8-9d29-0b4c77ec4397	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:56:51.642	down	5	connect ECONNREFUSED 127.0.0.1:8088	tcp
2e13b2e1-b723-4653-8d46-00fa3ac4f56b	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:57:21.639	down	4	\N	tcp
6bb920d8-d31f-45ef-8fdd-dce698e2164b	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:57:21.656	down	4	connect ECONNREFUSED 127.0.0.1:6875	tcp
3d8d15a6-27fa-46ca-a314-8656aba23cc2	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:57:21.661	up	9	\N	tcp
1bb252e7-c0b7-41ab-82a8-83dcbfa6b6fc	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:57:51.645	down	7	\N	tcp
dbf51fe6-24ee-463f-a610-c98d80a0c90b	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:57:51.654	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
7dc9d605-c35d-4722-84e5-de1501e8b306	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:08:51.933	down	3	\N	tcp
29baa755-fe56-4aea-adf7-3666bf700779	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:08:28.151	down	5	\N	tcp
413e3921-a9ff-4cf0-a5c7-9479e08593dd	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:08:28.169	down	2	connect ECONNREFUSED 127.0.0.1:7000	tcp
ee8f7b22-3b45-4976-b7ad-4fa83623c2e0	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:08:28.177	down	0	connect ECONNREFUSED 127.0.0.1:6875	tcp
b4b3b5d4-783d-4801-90ad-e4d8f49cc0dc	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:08:28.18	down	0	connect ECONNREFUSED 127.0.0.1:8556	tcp
14b6332f-078d-4f1c-9f23-89e906ea837f	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:08:28.184	up	0	\N	tcp
742a20f8-94a2-4935-94e8-6a1d9cdc510a	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:08:28.189	down	0	connect ECONNREFUSED 127.0.0.1:4100	tcp
90c961b6-ba40-43df-b5d4-56631f814104	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:08:28.193	down	1	connect ECONNREFUSED 127.0.0.1:8555	tcp
07910538-cc15-40c8-a889-93f55568c6a9	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:08:28.202	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
2b6139fa-36af-4756-895e-4c55dbbd2dbc	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:08:28.204	down	2	connect ECONNREFUSED 127.0.0.1:8078	tcp
a3e701f3-e2b8-4aa3-ab9e-7d9ef8f0217f	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:08:31.168	down	3001	TCP connection timed out after 3000ms	tcp
0039ddb4-9e47-4c9b-b7b5-ce1d9f642117	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:08:58.152	down	4	\N	tcp
a081c8ce-e840-4b75-bdb5-1741fb87aeda	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:08:58.153	down	5	\N	tcp
43fbc36c-c9d1-43fa-b474-e80b2b2473e3	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:08:58.155	down	7	\N	tcp
5fa9e4ae-7afa-423b-ba48-bfb2505cca2c	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:08:58.169	down	3	connect ECONNREFUSED 127.0.0.1:7000	tcp
75e6ac33-4dbf-47af-a1c6-637eac3b6e5d	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:08:58.288	down	121	connect ECONNREFUSED 10.0.0.200:3100	tcp
e5a8200f-9c5c-463d-8f7f-069f64d8b4bc	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:09:01.173	down	3000	TCP connection timed out after 3000ms	tcp
d941e31e-9cf0-4ef6-93b6-b179a36aeb35	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:15:29.041	down	34	\N	tcp
8ab857ca-cdc4-424e-8198-6bc984e42d4c	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:15:29.058	down	48	\N	tcp
56edec72-4f37-4519-8ab9-a38f505ba732	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:15:29.503	down	45	connect ECONNREFUSED 127.0.0.1:7000	tcp
82fdc8df-e90d-4a9b-8cfc-0d944381be73	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:15:29.492	down	37	connect ECONNREFUSED 127.0.0.1:6875	tcp
83be6112-1c0f-434e-b46e-5e22f86bf21c	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:15:59.159	down	18	connect ECONNREFUSED 127.0.0.1:7000	tcp
8a091817-090e-47cb-b530-e88bdb52c7ff	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:44:49.04	down	7	\N	tcp
f4bd2d42-bf30-4e6f-8e3e-f075d7a35dbf	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:44:49.04	down	8	\N	tcp
e71cd1a1-8df0-4b7b-b091-2fac0b8f79a5	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:44:49.038	down	6	\N	tcp
cc3cff60-5ef3-4a42-8f80-be2ab532d08a	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:44:49.172	up	109	\N	tcp
c4d2666a-fa3e-4e47-b40f-789a22932f43	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:44:49.173	up	110	\N	tcp
7d1994e5-9906-4503-b7bd-c2e57e4449f5	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:44:52.069	down	3000	TCP connection timed out after 3000ms	tcp
bc5d73f2-f2b0-42b8-a9e2-0441c952cd3a	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:55:51.627	down	7	\N	tcp
8d01f40d-a121-4d04-b5d6-e2ecf575dbff	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:55:51.676	up	25	\N	tcp
9176d5a2-3004-4639-8492-1439bf4a4bdd	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:55:54.637	down	3000	TCP connection timed out after 3000ms	tcp
d997d907-5395-4dcd-be28-813fb7c7128d	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:56:21.631	down	4	\N	tcp
3b3805da-ab3a-4042-b186-3579e40151b2	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:56:51.621	down	4	\N	tcp
f599865f-1127-425e-b097-3d86ba573329	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:56:51.631	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
f700a474-b4cf-4637-8ddd-922623cbcf18	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:56:51.635	up	5	\N	tcp
b58fece1-7ed9-45b6-a231-b292051622e3	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:56:51.642	down	5	connect ECONNREFUSED 127.0.0.1:4100	tcp
93df0b4e-1fa2-4433-b1d9-f294257de9b4	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:57:21.638	down	2	\N	tcp
134b7523-d98c-4d10-9ccc-295aff2a0164	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:57:21.641	down	5	\N	tcp
9baea6b7-92ea-4077-bae7-06c2f1a2016a	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:57:51.643	up	5	\N	tcp
0be5ed60-959e-41b6-8cd4-2e0a631449be	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:57:51.66	up	9	\N	tcp
a71a729b-6fa1-4f49-8217-cb6a532c72ea	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:57:54.655	down	3000	TCP connection timed out after 3000ms	tcp
f456fa13-95da-4f10-aa10-3838ab3d6484	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:58:21.651	down	4	\N	tcp
7311195b-633a-4624-a14f-ebf8055ea19f	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:58:21.672	up	13	\N	tcp
52d27404-3805-416f-9e6a-1d0f55768589	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:04:54.848	down	3001	TCP connection timed out after 3000ms	tcp
e94d855f-70f8-404f-a05f-9fcced1f87a8	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:08:51.934	down	3	\N	tcp
888cc2b8-4458-4f2f-9182-a2ac88c6d5da	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:09:51.964	down	2	\N	tcp
468fdc97-2f1f-4c3d-9181-b0beef1a715d	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:08:28.152	down	5	\N	tcp
809d0e9f-103e-401f-9e8b-6c719544d9de	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:08:28.193	up	26	\N	tcp
5cddd680-4c17-42c0-a4c4-c38e300a66f1	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:08:28.203	down	2	connect ECONNREFUSED 127.0.0.1:9006	tcp
4871cfdb-edf0-4296-93c3-6f0f8e6cff58	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:08:31.169	down	3001	TCP connection timed out after 3000ms	tcp
881539cf-6c71-4a35-879b-bbf6e80ba6d3	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:08:58.156	down	8	\N	tcp
2c571313-cc56-4436-a6b4-eda6bb4477d4	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:08:58.168	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
7c337ff7-a2d4-4962-b293-cae82a444e64	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:15:29.061	down	50	\N	tcp
a9ac442e-4db7-484b-a612-f9e071fca537	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:15:59.174	up	23	\N	tcp
a3efc383-f103-4eb8-979c-21f3acb8f1d6	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:15:59.189	up	45	\N	tcp
eaf1800e-1304-47bb-9c96-a4810a120019	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:15:59.26	down	10	connect ECONNREFUSED 127.0.0.1:9000	tcp
51b6da46-5de9-4246-97a7-953d8edcd62e	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:15:59.365	down	145	connect ECONNREFUSED 10.0.0.200:3100	tcp
becdb6e6-baee-46d7-8523-8308ada2b959	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:16:02.254	down	3007	TCP connection timed out after 3000ms	tcp
38922b1d-be1b-4fcd-8f36-f2e6812380c7	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:44:49.04	down	7	\N	tcp
83ab38bb-2368-4fcb-8471-0e6b2d1f23fd	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:44:49.172	up	109	\N	tcp
ff8cf3c9-fdd6-46e7-8c29-70741270bd5e	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:55:51.623	down	4	\N	tcp
7dd939af-73b5-4779-a2a5-284a6ac82cd6	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:55:51.674	up	37	\N	tcp
648df1fc-bcf6-417b-862a-a29218668e57	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:56:21.631	up	4	\N	tcp
77bdf2ce-ec7e-48d6-ba66-de812e3b2063	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:56:21.643	down	3	connect ECONNREFUSED 127.0.0.1:8080	tcp
334da55d-ea8f-4545-9704-cf695b8ed00b	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:56:21.777	down	136	connect ECONNREFUSED 10.0.0.200:3100	tcp
26642c37-6338-4a0b-8504-6901acdee46f	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:56:21.78	up	132	\N	tcp
714fb42e-53c4-493d-951a-265bbf86e6e8	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:56:24.641	down	3001	TCP connection timed out after 3000ms	tcp
a681cbe4-39da-401d-ae44-2864d5e7a71f	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:56:24.648	down	3001	TCP connection timed out after 3000ms	tcp
ae18e868-c969-4c53-aa00-453ee51be157	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:56:51.62	down	3	\N	tcp
817156ff-9899-4511-ac4b-118dd24126f6	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:56:51.621	down	4	\N	tcp
21b0f202-57d1-4014-9e75-3395571e6532	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:56:51.635	down	6	connect ECONNREFUSED 10.0.0.200:3100	tcp
3f5354f9-d035-4ee9-a4c1-a198ace55091	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:56:51.642	down	5	connect ECONNREFUSED 127.0.0.1:8020	tcp
e1c745bb-089a-408b-b242-2e3e19a606c2	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:57:21.638	down	2	\N	tcp
29ea1959-1e65-4b35-897c-225aa2e73371	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:57:21.641	down	5	\N	tcp
48779b4a-4b4d-433f-94d3-cf62cd133cdf	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:57:21.641	down	5	\N	tcp
489eaf2b-0107-44d6-b5d5-843c337c5806	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:57:21.656	down	4	connect ECONNREFUSED 127.0.0.1:8088	tcp
4a0b75a0-2d84-4bbb-bc09-d6988d183f5e	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:57:51.64	down	2	\N	tcp
83237a5e-4ad5-46ff-b3b6-d1135b60e21e	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:57:51.643	down	6	\N	tcp
90106e98-d556-4387-9b5e-dbac55c6d6e0	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:57:51.653	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
c9c74cba-140c-4a17-bf64-67ab95e97fc9	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:57:51.659	up	8	\N	tcp
f232eca0-b573-4092-b01e-171554d7bf07	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:57:51.661	up	5	\N	tcp
7fb7e7fe-740d-4f90-b1cb-e3c84f412bd2	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:57:51.664	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
791bd88a-e959-4533-9ae8-b9a6336e3246	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:57:54.652	down	3000	TCP connection timed out after 3000ms	tcp
1d2867e2-5f33-460f-a4cf-686686eba36a	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:57:54.656	down	3000	TCP connection timed out after 3000ms	tcp
93c338be-8320-4dc5-8e85-e920072c0573	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:58:21.649	down	2	\N	tcp
c594d448-524d-4957-90af-eefd217d1a6a	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:58:21.653	down	6	\N	tcp
676b0642-61c8-47db-b221-4f1d3ebe2acf	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:58:21.66	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
faeebfde-c7dd-4003-978b-e33cb6993c0d	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:58:21.664	down	1	connect ECONNREFUSED 127.0.0.1:8088	tcp
1124e83f-70ce-4a8f-937c-ce01557dab0b	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:58:21.671	up	13	\N	tcp
490d2c8c-e4c9-4f0e-aa51-d3549d65fede	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:05:21.834	down	2	\N	tcp
04d0231f-49c8-4a96-aed3-3676ee92ea32	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:05:21.879	up	35	\N	tcp
f48a6886-0413-4a04-93d6-d17d1775dd0b	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:08:28.153	up	6	\N	tcp
4a201f2d-acea-4db1-82b4-83f3de792c6a	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:15:29.068	down	58	\N	tcp
a8d429d5-2f6e-4537-8ca9-390b6f152337	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:15:29.057	down	48	\N	tcp
4b0f4de5-d276-4cae-842f-0b827cf77fde	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:15:29.473	down	22	connect ECONNREFUSED 127.0.0.1:8555	tcp
7d5beba0-5655-49d3-aca7-4420614b58a0	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:15:29.492	down	37	connect ECONNREFUSED 127.0.0.1:4100	tcp
3fdeee76-2e5d-4822-a668-81396c25afe4	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:15:59.02	down	46	\N	tcp
c43bda63-78b1-49dd-a015-cc7731b79331	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:15:59.158	down	13	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
75fc50dd-389d-4596-955d-2f5f25e0a2db	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:44:49.036	down	4	\N	tcp
acba49f4-20b5-4714-9f91-d557111793f5	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:44:49.039	down	7	\N	tcp
be1d725b-6f58-49c7-9d3a-2663bdbd7475	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:44:49.172	up	109	\N	tcp
64431683-c4d5-43cb-b5ae-c591bb181394	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:44:52.064	down	3000	TCP connection timed out after 3000ms	tcp
2debfe89-53c0-4af9-bbb5-32254f92047f	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:44:52.069	down	3000	TCP connection timed out after 3000ms	tcp
d3cec045-3c2d-4b95-8b78-b02f88bbc578	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:55:51.623	down	4	\N	tcp
5bc5a6d0-0b25-4922-9d02-b89e42b83c33	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:55:51.64	up	3	\N	tcp
7bc67615-c99a-4540-acce-3fdd089a626f	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:55:51.675	up	38	\N	tcp
712aa199-6e42-475d-a75d-88cee87fe467	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:56:21.63	down	3	\N	tcp
4515c874-2e17-4563-8249-62c9c77bd804	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:56:21.632	down	5	\N	tcp
fcc4f728-8932-430f-aba3-b66f7f74803e	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:56:21.644	down	4	connect ECONNREFUSED 127.0.0.1:8555	tcp
31a0e89c-5f11-4009-aec1-59ddb332ca4c	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:56:21.777	up	136	\N	tcp
2fd52318-aeef-4945-905c-6583548403d1	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:56:21.779	up	139	\N	tcp
79d67307-498a-4a55-8549-5799b0b6775f	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:56:51.618	down	2	\N	tcp
d5abcc3b-81de-48ba-94ab-2aefab8e4f2c	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:56:51.62	down	3	\N	tcp
1bbadedb-997e-490f-9da9-d81498edd614	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:56:51.631	up	2	\N	tcp
50570441-5a47-49ef-ad40-4357bfa02a3b	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:56:51.635	up	6	\N	tcp
cf1fc6dd-730c-4184-b04e-049a6dfd5e39	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:56:51.645	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
e5b34858-195c-4bb1-9b57-4e6df27e9c63	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:56:51.778	up	141	\N	tcp
aac7e027-9ee0-4237-a064-38efc0d3f60b	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:56:54.63	down	3001	TCP connection timed out after 3000ms	tcp
28ebaf44-08d6-4232-8c9c-66a1d497e052	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:57:21.639	down	3	\N	tcp
cd7e2bf4-d6b1-43ae-b628-6cd5a16d278b	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:57:21.655	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
0284ab98-7bc3-4854-8859-8ee0f8111a91	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:57:21.66	up	8	\N	tcp
0924bb68-d969-429c-b18f-9ed8fed455aa	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:57:21.665	up	5	\N	tcp
e3300d39-98e5-4a6e-ac4d-1ab9e7a1d3f1	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:57:24.653	down	2994	connect EHOSTUNREACH 192.168.1.222:8082	tcp
dfe0669c-4445-4c1c-a8af-a0ac7ca5f2f5	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:58:21.65	down	3	\N	tcp
fbe8c41e-a5a5-46a3-9ce8-62098413f86f	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:58:21.672	up	13	\N	tcp
4e77f24c-6a43-4bcd-81a5-4c2e28582e67	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:05:21.835	down	4	\N	tcp
3664dc8f-2547-48e9-a27a-6d3d2aff95d4	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:05:21.88	up	23	\N	tcp
32e94815-100e-44f3-b76d-3623186e8e2b	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:05:24.843	down	3000	TCP connection timed out after 3000ms	tcp
e5be85f3-2fd5-4bb6-a0be-9d7bbc234515	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:08:51.932	down	2	\N	tcp
2aa44791-a8e8-4e5d-8616-1005b78a803b	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:08:51.973	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
d7ce7d0a-38e5-44ce-9888-a5b579226095	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:08:51.99	up	18	\N	tcp
276150c0-7674-47a1-b3e6-5bb3215e034b	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:09:21.947	down	2	\N	tcp
e6121d82-9cd6-4bf8-b998-c4bde70610c8	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:09:21.972	up	5	\N	tcp
6cfe1e3a-69ae-42e0-a74d-4e620e8ed09f	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:09:24.954	down	2997	connect EHOSTUNREACH 192.168.1.222:82	tcp
41461315-1870-4742-8962-1a38c880df2d	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:09:24.955	down	2998	connect EHOSTUNREACH 192.168.1.222:8082	tcp
0918162c-903f-4bbd-b062-51bf2daf5ba7	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:09:51.966	down	3	\N	tcp
d564535d-95b7-403d-8975-805b9772e928	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:10:21.974	down	4	\N	tcp
a5b8d1bf-47e7-4745-9c07-9c83f2750479	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:08:28.154	down	7	\N	tcp
05bc355f-0ef8-4def-b2e6-ded0299bc254	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:15:29.063	down	52	\N	tcp
ce65ef09-bd1a-485d-b513-4de0d928f574	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:15:29.468	down	18	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
e65e6417-5b99-456e-a9ef-c49ebb961b39	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:15:32.455	down	3003	TCP connection timed out after 3000ms	tcp
ef211c4c-3999-4656-a925-68f0d40b5951	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:15:59.002	down	28	\N	tcp
79c221f6-66d9-41a3-b737-8ad885ae2073	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:44:49.037	down	5	\N	tcp
aa0cc6ca-a425-4ba9-9950-0e4e466d0f34	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:44:49.037	down	5	\N	tcp
303ab8de-8e19-4246-bdf0-fe4bb5a26f67	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:44:49.064	down	1	connect ECONNREFUSED 127.0.0.1:7000	tcp
b6d9626d-cee6-4c40-ab08-089e40105463	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:44:49.171	up	108	\N	tcp
6604efb3-ec8f-433d-80ea-0b98a5afea60	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:55:51.626	down	7	\N	tcp
ec5183e8-46c6-4ec5-baba-913b398906ad	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:55:51.639	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
f978e107-bc9e-462c-bf9b-c6c51d37dea4	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:55:51.674	down	38	connect ECONNREFUSED 10.0.0.200:3100	tcp
44177bce-306e-41eb-b02a-2f6df3cbb4a1	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:55:51.675	up	29	\N	tcp
646995ac-566d-431b-b210-40ab89df5c48	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:55:54.637	down	3000	TCP connection timed out after 3000ms	tcp
f15fe0f1-6dcc-4a3d-91eb-23dfaf2f7510	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:55:54.647	down	3001	TCP connection timed out after 3000ms	tcp
3322405e-366f-4e6c-9fc8-b8c2bc7e1460	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:56:21.631	down	3	\N	tcp
8843b866-3b7b-4aaa-b8f2-b222c975b10a	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:56:51.619	down	2	\N	tcp
8312e337-ca0e-43bf-8a39-56229522269b	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:56:51.622	up	5	\N	tcp
73745f05-dd50-4d19-a2e9-a07c34a2493b	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:56:51.632	up	2	\N	tcp
510e6088-a608-48f6-968b-949e1a6f0e14	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:56:51.634	up	5	\N	tcp
197de2c1-5661-4a25-b057-8bf079985671	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:56:51.645	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
f4872f7a-338b-4701-8ec0-30aa01d19cf1	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:56:54.63	down	3001	TCP connection timed out after 3000ms	tcp
925c2dba-343a-4714-9b0e-f4cf391ff9d4	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:56:54.644	down	3000	TCP connection timed out after 3000ms	tcp
5d116d8c-3ab8-44a5-a3b1-d095e7adf8ab	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:57:21.637	down	2	\N	tcp
d334b523-6bf2-4d25-8384-62d489e99c76	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:57:21.654	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
7a9ce2e4-086c-475c-8859-cf8da852190d	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:57:21.665	down	2	connect ECONNREFUSED 127.0.0.1:9000	tcp
6800a176-3f44-4a77-aa34-9c7e96ce1762	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:57:21.666	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
33f9ea76-d733-4fc1-b015-1024cfebd572	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:57:24.653	down	2994	connect EHOSTUNREACH 192.168.1.222:8080	tcp
dada0456-028b-4470-a4ab-6df1f819a4af	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:57:51.639	down	2	\N	tcp
d57686bc-1f5f-4d93-9e15-c8dd959e2882	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:57:51.643	up	5	\N	tcp
9c9d3e07-676d-46e2-b0d1-d37148f9a983	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:57:51.644	down	6	\N	tcp
d95eb502-9763-445b-82f4-95bdf58c2b80	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:57:51.652	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
a969344d-dc4a-44e2-b0d1-6ac844891556	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:57:51.66	up	8	\N	tcp
6670df63-931f-4b22-b624-77267d334393	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:58:21.649	down	2	\N	tcp
c63c9278-8c26-425b-8bb8-97b7e4c900f1	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:58:21.653	down	6	\N	tcp
23534786-cc17-4f3c-a5eb-7f42700eb025	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:58:21.661	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
734cf248-833b-4689-ad28-5c23aac84b62	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:58:21.664	up	1	\N	tcp
bd2e2c29-2d45-4dc5-b359-7efb208446b9	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:58:21.667	down	0	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
71691c54-6a79-4b90-9066-845967f5183d	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:58:21.669	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
ba4966f2-55b4-4ddc-bae0-dd4a6ad656ad	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:58:21.671	up	13	\N	tcp
2e6828cb-be12-4169-b774-fe211fe18b98	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:58:21.673	up	6	\N	tcp
910651ca-baa2-43b6-ad70-b91d36ea1482	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:58:21.676	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
2db742d8-2fc6-4915-b0ed-6faed085c04c	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:05:21.835	down	3	\N	tcp
9daf323c-d6df-4dc7-ba32-846dbb33b9e0	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:05:21.847	up	3	\N	tcp
f311ff61-47a1-4005-a9ee-053c9fc552d3	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:08:51.932	down	2	\N	tcp
200d472f-4cd1-4e0c-acd5-c71b7824bbc6	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:09:28.164	down	3	\N	tcp
6c8158a0-f2f3-4927-a2e8-11055b8aa2c2	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:09:28.169	down	7	\N	tcp
308c7f83-383a-4339-b831-6ae050b68831	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:15:29.07	down	59	\N	tcp
56d6979b-4fcb-4455-bfc3-71a1b7d68f3a	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:15:29.524	up	68	\N	tcp
91177640-aa0d-4ba4-a1d1-fcf773dc567d	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:15:59.019	down	44	\N	tcp
5b16f024-c1af-433d-ad55-35d73264a078	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:15:59.02	down	46	\N	tcp
b0136d88-b7d7-4fca-8d61-7a01a797fdf4	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:15:59.028	down	52	\N	tcp
d8bec3d2-b915-4772-90b4-e491cd6f723b	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:15:59.026	down	51	\N	tcp
cbb07d37-96b8-4863-bf8d-f42a53ddb7ad	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:15:59.161	down	20	connect ECONNREFUSED 127.0.0.1:8556	tcp
2766e3f8-2a65-44dd-b829-aa05a91d96f4	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:15:59.181	down	35	connect ECONNREFUSED 127.0.0.1:8080	tcp
452e1312-0c63-46b1-8a6d-3bbb7c5a9510	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:15:59.194	up	50	\N	tcp
c28fc778-5843-4b17-81c7-dc0cf22e447f	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:15:59.257	down	7	connect ECONNREFUSED 127.0.0.1:8078	tcp
968a1124-9907-4aac-bd0a-0dac088a28f0	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:15:59.367	up	131	\N	tcp
e8a623c9-f0a4-4d98-92a6-88f37b2abc4d	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:16:02.157	down	2913	connect EHOSTUNREACH 192.168.1.222:8787	tcp
3db83fb3-ccb1-4830-bb9e-e6872c7ba7eb	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:16:02.249	down	3003	TCP connection timed out after 3000ms	tcp
7024abf3-0b91-4d9f-8c40-3d44a08c3e09	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:44:49.038	down	6	\N	tcp
52dd891f-fe79-427b-945b-911bbd84765c	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:44:49.039	down	7	\N	tcp
dd120a90-02ff-40f1-a064-ab55f6d0f3a0	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:44:49.064	down	1	connect ECONNREFUSED 127.0.0.1:4100	tcp
51a131fc-0def-454c-a6d7-fa3ee0d3436a	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:44:49.068	down	0	connect ECONNREFUSED 127.0.0.1:8556	tcp
9e56cae8-6e98-45bf-a8bd-2087c87a7df0	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:56:54.63	down	3000	TCP connection timed out after 3000ms	tcp
32015cb1-5d4a-4137-84a4-d0f420b01615	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:57:21.638	down	3	\N	tcp
22485128-91fd-469f-883b-f7f5a7749788	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:57:21.642	up	6	\N	tcp
8c869643-8906-412f-84a9-523a0023c2da	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:57:21.661	up	8	\N	tcp
30cf27e8-7731-4658-9801-cd5373b26bfb	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:57:21.666	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
e63d46ed-45d8-4e2b-b423-d3ab7d5fe27a	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:57:24.652	down	3000	connect EHOSTUNREACH 192.168.1.222:8787	tcp
fd6ec7ed-1211-4790-b7c0-235bd855102d	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:57:24.653	down	2994	connect EHOSTUNREACH 192.168.1.221:3011	tcp
506fcb82-5cde-4695-810d-822408e3963e	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:57:51.64	down	3	\N	tcp
61ccdc0b-96bf-4972-bf0a-cab49c51d0da	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:57:51.644	down	6	\N	tcp
4e63c862-334e-4a11-a0e9-3b456f58c95f	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:57:51.661	up	9	\N	tcp
34832622-304f-4e8a-a155-39f3ac98fa19	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:57:51.664	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
73843b2b-64c3-4950-9827-4499730815d5	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:57:54.653	down	3001	TCP connection timed out after 3000ms	tcp
775af255-e7ec-4c90-8f92-4efcb38c4223	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:58:21.649	down	2	\N	tcp
367556d9-b3fd-4c70-a34c-93828c74d689	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:58:21.675	down	2	connect ECONNREFUSED 127.0.0.1:9006	tcp
f9a43095-c737-4671-8905-d7fe9bf45673	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:05:21.847	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
54c2b731-9c1d-4667-9be0-4679fba1020e	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:05:21.846	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
2850362a-d2f5-49e9-8fdd-aea0ad8abe59	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:05:21.854	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
d1acca3a-aae2-449c-9645-183723d5a133	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:05:21.88	up	23	\N	tcp
4f2bb4d7-cf86-4ff8-b8ce-b28044a62851	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:05:24.844	down	3001	TCP connection timed out after 3000ms	tcp
c6058742-8300-4b87-b3b1-a9cbfc1e85e7	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:08:51.933	down	2	\N	tcp
c61a70a5-2e9c-4f36-853c-339371527eff	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:08:51.973	up	2	\N	tcp
d9980145-b895-451b-8069-8e6dad20670a	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:08:51.974	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
85ece501-f01d-48ce-bef2-03c92f03f40d	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:08:51.991	up	12	\N	tcp
ba63209b-045f-4339-ab79-f050d49ede0f	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:08:54.972	down	3000	TCP connection timed out after 3000ms	tcp
16f3976d-fb7b-48fd-87a3-1d9733c7cc62	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:08:54.98	down	3000	TCP connection timed out after 3000ms	tcp
5f67d109-efb7-4aa1-b886-d1951cccf838	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:05:00.203	down	9	connect ECONNREFUSED 127.0.0.1:9001	tcp
752e8c97-b658-4245-b76d-a1e7587e7e44	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:05:28.045	down	5	\N	tcp
a86c8041-112a-4f97-9715-d6de3787789a	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:05:28.047	down	7	\N	tcp
9cc6738c-32ed-41bc-8ad3-01acb0159fc1	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:05:28.049	down	9	\N	tcp
587cf07c-cfb3-4156-852c-6cc272e45564	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:05:28.063	down	2	connect ECONNREFUSED 127.0.0.1:9000	tcp
1951a76f-fcbd-47a1-9b0c-506440e73941	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:05:28.066	down	4	connect ECONNREFUSED 127.0.0.1:9006	tcp
f21d03e4-1ca3-430d-8439-98b8dd691b3b	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:05:28.088	down	27	connect ECONNREFUSED 10.0.0.200:3100	tcp
69a2da40-7800-45b1-aacd-fede22536999	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:05:28.095	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
40f85355-a4d5-461b-b205-c2c10d7c143a	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:05:31.071	down	3000	TCP connection timed out after 3000ms	tcp
f04bc763-c069-41df-826a-16487af5ba0a	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:05:31.072	down	3000	TCP connection timed out after 3000ms	tcp
c6aee1c4-aaf5-4beb-9ae8-c0af5be3622b	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:05:58.063	down	3	\N	tcp
23b5f512-2451-4c01-95d1-9c7c12855f16	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:44:49.038	up	6	\N	tcp
6b978cc3-4726-4460-802b-1dc854482a66	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:44:49.065	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
3106ced1-4f53-401d-899d-cd8ef156d9aa	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:56:54.643	down	3001	TCP connection timed out after 3000ms	tcp
7f521d19-3edb-42b6-b03b-2672727d5fe7	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:57:21.639	down	3	\N	tcp
7f99ddb6-a0eb-4809-bddb-fad62fbbd57c	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:57:21.655	down	3	connect ECONNREFUSED 127.0.0.1:8555	tcp
78be78f4-4407-4934-a576-444c0a5f8729	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:57:21.661	up	9	\N	tcp
125e0fa8-43c8-40d3-b67a-ebd6230fed47	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:57:21.662	down	3	connect ECONNREFUSED 127.0.0.1:8080	tcp
a5845b59-2d85-4b1a-8c72-c645e078e36a	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:57:21.666	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
47cb434d-4738-4534-8f8f-be93e28cf8eb	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:57:21.666	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
2d377f25-814e-455c-86cf-6ad06f7d0b19	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:57:51.644	down	6	\N	tcp
031b1906-6e30-4ce1-81e5-f78628ce0aea	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:57:51.653	up	2	\N	tcp
9f555238-3443-4948-9301-3bab584e73f0	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:57:51.656	down	0	connect ECONNREFUSED 127.0.0.1:4100	tcp
4d0659e1-bc7f-490c-a553-c2618b061001	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:57:51.66	up	8	\N	tcp
3e13e912-8e70-428e-915b-073a52bc2cf6	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:58:21.65	up	3	\N	tcp
34ed2801-e15a-4684-99bd-5b9120ae9ff9	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:58:21.653	down	6	\N	tcp
d57332c4-bf4c-47a9-9704-cbfff3014488	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:58:21.661	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
cae60fbf-3891-4952-91e7-cebd724be4c9	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:58:21.664	down	1	connect ECONNREFUSED 127.0.0.1:8080	tcp
7983a374-065b-48c6-b8e1-965c3a537c9a	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:58:21.671	up	13	\N	tcp
7e0d45ec-feff-41fa-b9fb-246d844225bb	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:05:21.846	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
92483d64-6b4c-4622-a34d-8f800ed5d319	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:05:21.854	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
88bed514-1720-444b-b8aa-2872beaff78d	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:05:21.879	up	24	\N	tcp
0b0cb83d-2568-4ecb-a687-c84da860ce5d	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:05:24.844	down	3000	TCP connection timed out after 3000ms	tcp
40b725cb-9588-4967-bf86-9dee2703a553	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:08:51.932	down	2	\N	tcp
f909447d-a536-4b8d-a04c-035e389cdfb8	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:08:51.973	down	1	connect ECONNREFUSED 127.0.0.1:6875	tcp
7f352765-a738-4b98-8f84-56b7d77b63c4	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:08:51.992	up	12	\N	tcp
9cd88147-e4d4-42de-97b2-4e7d638e57dd	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:08:54.971	down	2999	TCP connection timed out after 3000ms	tcp
eed0f856-a9c3-4517-82d4-a4742001df17	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:09:21.947	down	3	\N	tcp
9941de11-cd56-48b7-9375-007515778f76	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:09:21.95	down	5	\N	tcp
4cd8f0df-ffdf-4034-b05c-1c4ac735a814	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:09:21.971	up	14	\N	tcp
a7ddd61e-c1e7-447d-a61e-b7015e9f387e	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:09:51.965	down	2	\N	tcp
6ab0d259-a110-4333-af3c-b7aedde6c0d0	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:09:51.967	down	5	\N	tcp
a4a1dadb-ccd9-4e57-afc0-fd755ab1bafe	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:09:51.979	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
ba9082dd-ce87-4eb2-98d3-9ffc2b00513b	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:10:21.972	down	2	\N	tcp
cf52206e-68ac-4083-91e7-3150e127b631	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:09:28.165	down	3	\N	tcp
661dbc33-476e-40f2-9304-08a54bf910d7	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:09:28.169	down	6	\N	tcp
1c4bb130-01e9-45eb-9879-928ec978d03c	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:15:29.526	up	69	\N	tcp
d5a07cae-c9e9-4c52-8c6c-31d29f35f386	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:15:29.581	up	14	\N	tcp
3b7c1350-b012-4ad2-8ef4-3eb68d5693f9	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:15:29.631	up	36	\N	tcp
68ca8664-a842-43e9-aaea-9bedec85e0ad	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:15:32.458	down	3002	TCP connection timed out after 3000ms	tcp
8522f2b8-b6fc-4e0c-b035-c8c127db9e4d	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:15:59.02	down	46	\N	tcp
ac1e5082-56a9-4e74-b010-4974e20b2cb4	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:15:59.191	up	48	\N	tcp
059d343d-1521-45bb-abe2-65e4d47a9aee	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:15:59.258	down	8	connect ECONNREFUSED 127.0.0.1:9020	tcp
4c2f7f62-79f1-4c3a-a89b-71a3fc660568	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:15:59.369	up	126	\N	tcp
5f247f9d-1888-41f3-90c8-3699174a1a7b	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:16:02.145	down	3001	TCP connection timed out after 3000ms	tcp
0e55fc0b-20fa-4291-a2d5-b45561570ff2	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:16:02.247	down	3002	TCP connection timed out after 3000ms	tcp
3a0e7ada-0e61-4ad3-8a67-59ab259ef904	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:44:49.039	down	7	\N	tcp
5a27fd91-51b6-4512-8adc-82e3a14f5589	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:44:49.064	down	1	connect ECONNREFUSED 127.0.0.1:8555	tcp
e7e094a8-bdac-4315-ab0a-8398bccd84f2	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:44:49.065	up	2	\N	tcp
edc460c3-c058-4136-a6d0-d721c0b09310	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:44:49.068	down	0	connect ECONNREFUSED 127.0.0.1:6875	tcp
ce473073-5482-4ae4-8a7b-14ac3688e902	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:44:49.072	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
af85389f-1c8f-4597-9f48-794b9d178c92	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:44:49.074	down	0	connect ECONNREFUSED 127.0.0.1:8020	tcp
b22b2a3e-2be2-4991-896f-235c4ba65ebb	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:44:49.076	down	0	connect ECONNREFUSED 127.0.0.1:8080	tcp
f852a3c9-9951-49d2-9a19-3de8ad74bf29	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:44:49.078	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
76e70724-497c-4948-8d5a-90aaf437acff	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:44:49.08	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
41f55097-8c25-446a-92ef-48b8d3283037	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:44:49.082	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
e70a336a-57f8-4016-82c9-7f1367af2442	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:44:49.083	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
312e57fe-feeb-4b45-8aa6-12128bacd6b1	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:44:49.085	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
90c817a4-e3c6-47d8-82fd-d8fdb06b86dd	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:44:49.171	up	108	\N	tcp
843e27d9-0703-4dc5-81e6-8354ed503d64	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:57:51.642	down	5	\N	tcp
23bdafe2-8f9a-402f-b5b9-ae618112268f	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:57:51.644	down	7	\N	tcp
f49ba574-6ec0-43c5-b707-7304dcb04b39	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:57:51.661	up	6	\N	tcp
fdd1e42c-9a45-47b4-aa30-eb77a828b340	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:57:51.664	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
dc76fe04-c858-4692-9334-2443faacc782	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:57:54.655	down	3000	TCP connection timed out after 3000ms	tcp
37430da1-e0ca-49ec-bd10-9a8a0f3c56a2	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:58:21.649	down	2	\N	tcp
e9403ee7-18a3-454d-bb23-08289dc584c4	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:58:21.653	down	5	\N	tcp
55ba8343-a030-4006-8388-7f0c600c9ff7	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:58:21.661	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
0913e030-fe7f-4146-adf7-59f6ff2b25d5	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:58:21.665	down	1	connect ECONNREFUSED 127.0.0.1:6875	tcp
d9e28666-86f1-47dc-9996-65b4a19ffc7c	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:58:21.666	up	0	\N	tcp
302a13d9-e1b7-45f9-a39b-f1bfa7aa6caf	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:58:21.672	up	13	\N	tcp
15004e00-4ad3-498e-b063-27208b1ba260	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:05:21.855	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
d91178cb-36e4-4419-b8e2-c66a161eb7b8	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:05:21.878	down	24	connect ECONNREFUSED 10.0.0.200:3100	tcp
2e273553-10d5-4091-a9a0-deeeef8395db	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:08:51.933	down	2	\N	tcp
0f37b20b-0a81-4056-bada-b184a828e41f	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:08:51.973	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
6d23ca99-331d-4a6a-9853-1a00814c8d64	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:08:51.979	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
0869a81a-6d3f-4d70-be50-4c398c52b0e3	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:08:51.981	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
52096c1b-60a0-4d17-9805-e6129051e371	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:08:51.983	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
1d780d39-94fd-46f4-82c7-ff5af8b7bf28	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:09:51.967	down	4	\N	tcp
dff53a5d-183d-4520-884a-5e8724dc4809	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:09:28.165	down	3	\N	tcp
5c2570ae-4b22-4dad-853f-9f899d7e6821	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:09:28.171	down	8	\N	tcp
3e055016-9c7b-4d3a-9812-2dda8b2bcdcc	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:09:28.187	up	4	\N	tcp
1800e23d-4871-4e41-9c78-a6a8e2f06825	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:09:28.191	up	7	\N	tcp
bba83879-c172-424d-94ef-cf3988660d1d	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:09:28.199	down	4	connect ECONNREFUSED 127.0.0.1:8556	tcp
6c67b09f-2ba2-406f-bd9c-548839503f6e	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:09:58.185	down	3	\N	tcp
e506d37e-ffcb-422a-ab7f-235d032381b8	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:09:58.187	down	5	\N	tcp
fc2114ad-f492-4457-b1c2-e583096d0f6d	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:09:58.191	down	9	\N	tcp
f1bb1ee6-78c6-41f8-81a6-780fb2080fed	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:09:58.205	down	5	connect ECONNREFUSED 127.0.0.1:4100	tcp
c3270cfe-9426-473f-9747-304248fb8cff	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:09:58.205	down	4	connect ECONNREFUSED 127.0.0.1:8088	tcp
e1ef64ff-983a-4b5b-9ab5-cde85d135f8c	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:09:58.64	up	441	\N	tcp
42da4fb1-b6a8-49fc-bf34-2b34a97c8522	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:09:58.643	up	443	\N	tcp
b34a5c9e-d127-4802-93cc-d1c32acf5a83	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:15:29.585	up	16	\N	tcp
62aebebf-745f-4b59-8b7c-d6ba032593de	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:15:32.458	down	3003	TCP connection timed out after 3000ms	tcp
9e5b8bfd-523c-4ff4-9e0c-5ae8255eb0b9	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:15:59.014	down	39	\N	tcp
fe7e277b-7d20-4875-9855-0489a79129e4	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:15:59.012	down	37	\N	tcp
77a34163-cc9e-4cff-a62c-f88ceb12ec91	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:15:59.006	up	31	\N	tcp
d3ae1403-e487-421a-aad2-9ed32d2df583	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:15:59.022	down	47	\N	tcp
59d9d114-a2a1-4f49-b641-e1eb6933bdc9	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:15:59.187	up	43	\N	tcp
35a0e765-f870-4f68-a18f-8f53394d1824	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:44:49.171	up	108	\N	tcp
62ec5036-482d-452c-a56e-0dbe4524df1e	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:57:51.654	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
3fd11816-269b-439e-8269-201526bfa1ea	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:57:51.657	down	0	connect ECONNREFUSED 127.0.0.1:8556	tcp
27effb35-57e8-45e8-b3e3-e26abd330b07	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:57:51.66	up	8	\N	tcp
ea440638-c092-45c2-8c35-4025946fbb81	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:57:51.664	down	6	connect ECONNREFUSED 10.0.0.200:3100	tcp
88160b65-c36b-4ca5-99ba-35deac823556	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:57:54.655	down	3000	TCP connection timed out after 3000ms	tcp
08322575-f0aa-406f-ac2e-da156432eab2	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:58:21.649	down	2	\N	tcp
833b2cba-b3bf-4b35-865d-59c078af3a41	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:58:21.675	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
21fd8df9-90a0-4d35-a3fe-28718bf2c737	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:05:21.88	up	23	\N	tcp
9e2c8d73-c728-47a5-97ea-cd38277337f6	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:05:24.843	down	3000	TCP connection timed out after 3000ms	tcp
eb295704-6ca3-464b-b27c-c4de3cbaf648	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:08:51.974	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
a2cc8a3d-078a-438e-964f-23d507c00197	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:08:51.979	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
0884bd90-9927-49d5-bf67-7fca595db142	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:08:51.981	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
4c318b5c-0dcd-43be-8e00-255ace884d7a	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:08:51.992	up	12	\N	tcp
6bac49fe-faab-444e-aa60-fa8dd8f2b215	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:08:54.973	down	3001	TCP connection timed out after 3000ms	tcp
ff7943c4-6b11-4b33-a22c-73d3f3e81214	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:09:21.947	down	2	\N	tcp
0ad4575b-ea2c-4772-a256-8e128a5f5134	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:09:21.949	down	5	\N	tcp
16742ccd-466e-40f7-a644-c635232dbc62	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:09:21.96	up	2	\N	tcp
473bcf46-ca6e-43ea-a386-90796e58210e	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:09:21.97	up	13	\N	tcp
4f0e2af0-0f5b-4567-b7db-1474b1c0e04f	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:09:21.972	up	5	\N	tcp
4043fe15-b13c-4bce-b52d-2d6292e2a728	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:09:24.955	down	2997	connect EHOSTUNREACH 192.168.1.221:4001	tcp
0039088c-15bd-4ce0-bf15-e1947b75ff49	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:09:51.965	down	2	\N	tcp
0c0523b2-2f28-42c6-ac33-8ebbd1bb9d78	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:09:51.978	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
84a9e2f3-0239-4ded-aa69-3e06f304bcdb	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:09:51.984	up	8	\N	tcp
b3e3e8f2-803d-438e-a733-7fab71583d03	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:10:21.972	down	3	\N	tcp
16585079-35fa-4ba4-aec4-e46c4664f3b5	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:10:21.974	down	4	\N	tcp
3d3e1281-6e40-4f17-891e-3d4073921d26	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:09:28.166	down	4	\N	tcp
9f554d20-9c3b-4a12-984c-f2180521ace7	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:09:28.17	down	7	\N	tcp
c39f7b38-9508-40d1-ae86-7ec4fa7ff987	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:09:28.187	up	4	\N	tcp
4167c743-b87f-4321-95c3-a49c12040f1c	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:09:28.197	up	6	\N	tcp
ddf1f20c-7815-4a25-94b2-e495101cb5f2	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:09:28.2	down	4	connect ECONNREFUSED 127.0.0.1:9006	tcp
0dd3c879-4556-478c-ad9b-3b2ed0ebd48c	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:09:31.185	down	2990	connect EHOSTUNREACH 192.168.1.221:8180	tcp
01846a6d-7caf-47b8-beaf-1bb37fbfac1c	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:09:58.185	down	4	\N	tcp
f9e508d8-9d24-4825-86b1-4cc97851fcf1	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:09:58.189	up	7	\N	tcp
cce27b1c-be67-4034-8fda-582ce3e98928	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:09:58.205	down	4	connect ECONNREFUSED 127.0.0.1:8555	tcp
79b881e2-103e-4e39-b30a-4a7ff158f64f	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:09:58.209	down	1	connect ECONNREFUSED 127.0.0.1:8556	tcp
f095b1e3-8eeb-49c5-bf57-72a2ef86c702	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:09:58.213	down	0	connect ECONNREFUSED 127.0.0.1:7000	tcp
51747479-fb24-4abe-b5fb-3b4baeb2c149	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:09:58.217	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
d856bae7-eb98-4bf1-94de-96ee8e03270d	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:09:58.221	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
989fe56f-23dc-48a1-a2ac-076f4cf65ef2	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:09:58.225	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
201647e5-e238-4f5a-b27c-8f0777228e79	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:09:58.229	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
6abf38da-b09f-4bd5-834c-3fa3d80b6f5c	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:09:58.233	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
b3de7e12-0249-4bd7-b4d5-de71a7ea3d87	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:09:58.642	up	442	\N	tcp
01f10d5f-b578-4230-ab71-fb73d5389e22	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:09:58.644	up	436	\N	tcp
e4dcf7f3-de52-4179-8544-9109798db8b3	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:44:49.172	up	109	\N	tcp
702dd644-6d1f-43b1-a73a-3d0bd9143f00	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:44:52.063	down	3000	TCP connection timed out after 3000ms	tcp
3d995fef-a58a-4ee0-b96c-3b99e18c7e2c	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:44:52.069	down	3000	TCP connection timed out after 3000ms	tcp
3c5206ef-9931-4dc8-b828-8dede3d7dd09	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:58:24.66	down	3001	TCP connection timed out after 3000ms	tcp
4cf326aa-b529-4766-9bd6-81901fe5ae3c	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:05:51.823	down	2	\N	tcp
65764771-0169-4c3b-b0bd-038df08579de	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:05:51.823	down	2	\N	tcp
94e5a117-8ac7-4e32-b419-5fa9719c5423	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:05:51.826	down	4	\N	tcp
38a6be8c-350b-41b3-b255-1bad48542d61	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:05:51.826	down	5	\N	tcp
6f6bad6b-3d7c-4f2c-8d85-663d9d95f8c4	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:05:51.838	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
0afc9f4a-1715-4bb4-8777-a8ec67138ac6	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:05:51.839	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
3924913c-8ed7-4f0b-898e-89f6f134afae	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:05:51.846	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
0bc219b2-4cde-48d8-98a1-ef65c7b23cc4	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:05:51.863	up	27	\N	tcp
9a734674-1fb8-4321-a15a-9d9ba660d748	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:06:21.856	down	2	\N	tcp
0b772743-2933-4301-8db4-a57ce21b0f40	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:06:21.856	up	2	\N	tcp
edf3582d-3eba-43d6-a12c-645fdab4c033	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:06:21.857	down	3	\N	tcp
fea67e91-30a9-4afd-b94c-b449d5a70fa1	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:06:21.858	down	4	\N	tcp
b414e706-8106-40aa-b57f-7e1c7d882a98	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:06:21.868	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
9a76a675-9ec2-4311-a399-5aff33c6e287	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:06:21.867	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
ba531e77-0843-4543-83c2-9325cb61b71d	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:06:21.867	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
78957d18-5306-4a34-a8a9-5854997fd3fb	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:06:21.875	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
f572ecd3-413c-4031-80aa-c2f885bcad7d	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:06:21.901	up	36	\N	tcp
ef888837-ad36-46c8-b442-02ae3b01c638	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:06:21.902	up	24	\N	tcp
3053894e-0bc6-4c30-9656-83985e1ed2ba	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:06:24.866	down	3001	TCP connection timed out after 3000ms	tcp
1cb36981-eafa-40db-bf5a-258595e57ded	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:06:51.861	down	3	\N	tcp
2e5902e5-4502-48d6-a10a-a2ef0500d090	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:06:51.862	down	4	\N	tcp
c32d295b-ee33-4e79-ab33-abce8acf2e2f	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:06:51.863	down	5	\N	tcp
75ae8f5f-cb6c-4bb1-89d7-bfffc6706ed8	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:06:51.877	up	4	\N	tcp
2053a798-930e-4fd5-b5a0-4f3cf07dbe39	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:09:28.166	down	4	\N	tcp
eda1d6f7-d04f-4651-af96-a3772cabfc19	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:09:28.17	down	8	\N	tcp
92b46868-3261-4233-bd8f-3e519f1fd22b	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:09:28.19	down	7	connect ECONNREFUSED 10.0.0.200:3100	tcp
e939c74e-ddbc-400f-ac0e-ba0f43e1266d	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:09:28.199	down	4	connect ECONNREFUSED 127.0.0.1:7000	tcp
68dad11c-fdfb-4bb8-b84e-816b3b3401a1	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:09:28.201	down	4	connect ECONNREFUSED 127.0.0.1:9001	tcp
932c4ba5-e9f6-4a08-bdd5-5a18cb51cfdf	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:09:31.184	down	3000	connect EHOSTUNREACH 192.168.1.221:3011	tcp
003e0c04-411d-43c8-b5fd-49a797267b4e	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:09:31.185	down	3002	TCP connection timed out after 3000ms	tcp
fb238690-c31a-41f1-9a50-03c29784e4f0	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:09:58.185	down	3	\N	tcp
1eea1d77-3b28-4cef-8812-03954b496a9c	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:09:58.188	down	6	\N	tcp
0c3ac725-08b4-4e86-99cf-5f184e946b1a	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:09:58.191	down	9	\N	tcp
c359668f-1d0f-4443-9696-4522cc087d23	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:09:58.204	down	4	connect ECONNREFUSED 127.0.0.1:8020	tcp
72c8064e-6cbe-478c-8311-e3ad70db81f3	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:09:58.642	up	442	\N	tcp
b4d8bf0a-7201-4b76-a8bf-f7890ccad2bf	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:44:49.173	down	110	connect ECONNREFUSED 10.0.0.200:3100	tcp
ecb36661-a059-4fe9-890f-4360d6f23ad3	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:44:52.063	down	3000	TCP connection timed out after 3000ms	tcp
65a90de1-ff3b-464c-8492-a32dee463ec8	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:44:52.069	down	3000	TCP connection timed out after 3000ms	tcp
1167d7d4-d0e1-4157-bc06-a2977ab8a18a	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:58:24.66	down	3001	TCP connection timed out after 3000ms	tcp
9d107d94-5c4f-4cf2-8c7a-d27e1caa0fa0	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:05:51.823	down	1	\N	tcp
264cc4e0-a44c-40d9-8720-c55c11f40e50	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:05:51.826	down	4	\N	tcp
a29bd75d-1f9d-400d-8bf1-cf711aab4e00	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:05:51.838	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
e0026e94-9b6c-4116-833c-265f5175a23a	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:05:51.864	up	14	\N	tcp
dd1a861d-9d6a-4448-9f65-b2fb2e05ccb6	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:06:21.858	down	3	\N	tcp
271e9805-f913-4c1b-b747-c075a1a2aab6	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:06:21.902	up	27	\N	tcp
66b39a7a-b485-4cf5-a78f-4b564543346a	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:06:51.86	down	2	\N	tcp
5545b167-0479-4b53-b00f-059bb87db0f3	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:06:51.861	down	3	\N	tcp
66c3cfd4-8e3e-43ee-95d8-f616192969f4	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:06:51.877	down	4	connect ECONNREFUSED 127.0.0.1:8088	tcp
af6b6f72-4761-40fd-8279-e7aeba1a4c22	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:06:51.882	up	9	\N	tcp
7095bfe1-e6b3-449b-bc2e-ccfd2c23cd5e	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:06:51.884	down	4	connect ECONNREFUSED 10.0.0.200:3100	tcp
1805dce4-f396-446d-a19e-c9536c58df8e	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:06:54.873	down	3001	TCP connection timed out after 3000ms	tcp
4e177b94-1d98-4bc1-ba4d-48781cab7b05	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:07:21.865	down	2	\N	tcp
acb6e568-f6ea-4059-9a77-f63c3e9c696d	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:07:21.867	down	3	\N	tcp
e7906d0e-47e7-4d9a-b447-d6acd9cd2da7	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:07:21.877	down	3	connect ECONNREFUSED 127.0.0.1:8080	tcp
5f4ef950-ac8f-45ce-8975-78530d4c7e3e	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:07:21.885	up	11	\N	tcp
a3bc1403-9f44-4aca-960e-a9ccd2c59c5b	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:07:51.897	down	2	\N	tcp
e3f83ee4-14b3-480f-b481-4cd02d2ca23e	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:07:51.899	down	4	\N	tcp
d1bca967-0dd2-4e64-b8dd-98281c7c9aaf	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:07:51.898	up	3	\N	tcp
9ca69dec-27f3-414e-ba2b-e32108b458df	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:08:21.903	down	3	\N	tcp
d835b740-9db0-43b5-b8ff-bf0e6f13fe73	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:08:21.914	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
82abb4a1-aad8-4f96-b77a-4b0dea4d0939	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:08:21.922	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
54e6f890-7e55-4ab1-a923-7b1607462c80	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:08:21.924	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
febfc609-12d7-4486-914e-a0aa748be916	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:08:21.926	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
60fbcada-5687-4c64-9673-eeff0cedeec0	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:08:21.928	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
ba7cd89c-8d08-4a08-a1c8-c983c9407cc9	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:08:21.94	up	19	\N	tcp
6c56f9e3-3c1b-489b-a299-a9b856fcceab	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:08:51.973	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
8f1384c7-2f51-494e-83b7-1cb54b9e3331	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:08:51.991	up	12	\N	tcp
a3cf91f1-6e94-4a7f-89f3-42618003ca3f	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:09:28.167	down	4	\N	tcp
0e0a2112-885b-4d83-862f-cdcc66e898e1	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:09:28.17	down	7	\N	tcp
cf54ab41-a6ac-4a26-a6fe-76be326465df	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:09:28.186	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
85bf64af-bccf-44ae-8adf-0e223f1c8e77	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:09:28.189	up	6	\N	tcp
9847e7b5-90b6-48b2-8adf-b8f4b752978b	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:09:28.198	down	4	connect ECONNREFUSED 127.0.0.1:8080	tcp
6cf6c01c-c95e-4410-9ec7-9bbaf6486aaa	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:09:28.201	down	4	connect ECONNREFUSED 127.0.0.1:9000	tcp
5d95b5ba-188d-425b-8578-f8bf751fc542	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:09:31.184	down	3001	TCP connection timed out after 3000ms	tcp
9a41587f-a2ab-4c76-84e1-77a41ffcb5b8	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:09:58.187	down	5	\N	tcp
e012c41a-ddaf-4466-96ec-793f04128d6a	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:09:58.191	up	7	\N	tcp
fbc3403a-c1cd-4fbd-ab4e-4fe5251063b5	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:09:58.204	up	4	\N	tcp
8b86ce5a-e982-4c56-bce4-e61c2a544536	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:09:58.643	up	443	\N	tcp
b4ae4f7b-0656-47c9-8ce5-0631893efad0	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:45:40.441	down	6	\N	tcp
b124dea3-d43a-4acb-9a33-a4eca847d65e	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:45:40.439	down	4	\N	tcp
d328e70d-cf3f-48b1-8196-21a1f2bebcc4	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:45:40.44	down	5	\N	tcp
db0d3daa-8128-420c-a03b-9babca44e794	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:45:40.443	down	7	\N	tcp
123ba4d6-b4f4-4517-a4f2-dc46f3ce549d	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:45:40.47	down	2	connect ECONNREFUSED 127.0.0.1:7000	tcp
e7166112-6f06-4ec6-801c-d54a6327f07b	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:45:40.475	down	1	connect ECONNREFUSED 127.0.0.1:6875	tcp
cee94024-8692-4336-9b6b-5ceb8da5025c	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:45:40.478	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
094e22e2-7c0d-4c79-9088-daeb73af8210	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:45:40.481	up	13	\N	tcp
8c46af47-396b-4ef5-8567-236dc494598b	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:45:40.482	up	5	\N	tcp
604d3f22-71bd-47cf-85db-562a6e84ab77	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:45:40.486	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
f485b06a-86d7-40a9-b77b-9b432a81a741	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:58:24.66	down	3001	TCP connection timed out after 3000ms	tcp
1ed4efb8-3a7c-43d3-b241-2976a428bdbe	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:05:51.824	down	2	\N	tcp
494fdbbe-c499-42b8-a3b1-254f851d36a3	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:05:51.826	down	5	\N	tcp
6882b5d6-c20c-4ca8-a5a7-c68802bd5972	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:05:51.838	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
fc830c55-318e-4cec-98c0-e1121b9bb348	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:05:51.864	up	15	\N	tcp
3e2a135f-5664-4f23-89a9-187e8cd7aadf	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:05:54.837	down	3001	TCP connection timed out after 3000ms	tcp
08051535-9eac-4622-b44b-921d2f82710f	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:06:21.857	down	3	\N	tcp
00d2fba3-afe6-427d-9910-3afebc50dbb6	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:06:51.877	down	4	connect ECONNREFUSED 127.0.0.1:8080	tcp
ebe358f9-d7b4-4ba1-8e2d-09713f0c72eb	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:06:51.89	up	2	\N	tcp
c6e6f18a-8f11-43f8-be35-a3f7253649af	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:06:51.893	up	3	\N	tcp
23c39ffc-fd29-4ef9-acff-e548c5754476	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:06:54.873	down	3000	TCP connection timed out after 3000ms	tcp
0208e56d-2dff-4dfc-b56f-2d1bfe054455	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:07:21.866	down	3	\N	tcp
5a1960a8-9387-4629-883c-188ec5b9527f	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:07:21.877	up	2	\N	tcp
14564318-88dc-43d0-9303-6af8df231280	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:07:21.884	up	10	\N	tcp
276d3cb6-2df3-41a3-bb46-071dc20af843	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:07:21.886	up	5	\N	tcp
14f90a4f-e950-47df-aacf-30bffdaa42ee	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:07:24.874	down	3000	TCP connection timed out after 3000ms	tcp
ff521bcd-9cb8-4a42-a671-0d4b0d7e7b1d	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:07:51.897	down	2	\N	tcp
ed05a1ad-4222-40b3-ae6a-c82a967ce0e8	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:08:21.904	down	4	\N	tcp
5d81734a-db68-4632-8205-076f7b57e0fe	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:08:21.913	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
5e4a6cfd-6090-4b98-977d-95a930f407ad	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:08:21.94	up	19	\N	tcp
d386870b-f5d2-4cf3-b4cf-fca1f77d0cd4	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:08:24.912	down	3000	TCP connection timed out after 3000ms	tcp
e7c2ed65-957d-4e54-af11-f0d90e79d719	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:08:24.921	down	3000	TCP connection timed out after 3000ms	tcp
27cbee8f-0fe6-45ca-83f7-d44a81ecf1c2	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:08:51.974	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
335521d4-19db-4939-b220-01b2dbed9d83	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:08:51.991	up	19	\N	tcp
36792cee-86f6-4880-a191-936edfb6ef86	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:09:28.167	up	4	\N	tcp
f89ae4e6-a90b-4f3c-8b29-609ebcccc7a3	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:45:40.438	down	4	\N	tcp
44d7eea1-edc2-4f61-b594-868a7e1c5dcd	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:45:40.444	down	8	\N	tcp
62a88779-a2da-4a5f-87ce-897018466b25	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:45:40.439	down	4	\N	tcp
ccad615d-9d9d-4c46-b4fd-9e5896160d93	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:45:40.481	up	14	\N	tcp
84929dde-0f61-4902-84f2-d5842ade4301	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:45:40.483	down	5	connect ECONNREFUSED 10.0.0.200:3100	tcp
9cd6c415-f8a7-47b1-82c6-be6893dd3040	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:45:40.486	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
106161d5-0ce1-4bcf-a04b-89f9c83b4bca	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:45:43.467	down	3000	TCP connection timed out after 3000ms	tcp
c05af59f-5ced-4bed-a2ad-a79e34606d76	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:58:24.66	down	3001	TCP connection timed out after 3000ms	tcp
6712bbda-e191-4c57-8ff5-80eb974d4764	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:05:51.824	down	2	\N	tcp
2b1a64ad-3b14-4ff4-ab5a-6854a8352af2	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:05:51.826	down	4	\N	tcp
e9e48254-4116-44e6-b784-7e397a176146	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:05:51.839	down	3	connect ECONNREFUSED 127.0.0.1:8080	tcp
440e486d-018e-4699-b4d6-0f3a7a62fb1b	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:05:51.847	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
28c75eaa-ab2f-482c-ac8c-d569ff41e5d9	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:06:21.859	down	4	\N	tcp
f50e63fc-c5e2-4745-aec6-196b97417439	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:06:21.866	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
533c5254-a912-4936-9d7e-29c33038d97d	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:06:21.876	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
8d58d918-70cc-4a1e-8486-1bfc3428f25c	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:06:21.902	up	24	\N	tcp
2a92ad5b-f17c-49ac-a8bc-2e324ae6d8f8	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:06:24.866	down	3001	TCP connection timed out after 3000ms	tcp
84229f7a-a756-4ccb-a428-cd96f505f778	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:06:51.86	down	3	\N	tcp
3540ca69-b7b5-427c-8a9b-657e5462953e	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:06:51.876	down	3	connect ECONNREFUSED 127.0.0.1:6875	tcp
ecfe7196-1d3e-4bef-a21d-f50471da8187	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:06:51.878	down	5	connect ECONNREFUSED 127.0.0.1:8020	tcp
912b2e02-70ea-451b-8619-bff90d840978	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:06:51.883	down	2	connect ECONNREFUSED 127.0.0.1:9000	tcp
7d173285-8f9d-4bbc-92f1-2e1e8e1e5bcd	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:06:51.884	up	4	\N	tcp
5b82f40c-2f09-42f7-918c-857591a6af25	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:07:21.866	down	3	\N	tcp
9f604d92-2c0b-4f3f-90fa-f7cd0b2b53c6	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:07:21.877	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
70f63dab-950c-454c-97b6-37e0776672e9	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:07:21.886	up	5	\N	tcp
7fbc8d18-9b7c-41f9-aac1-f55d1e57b51d	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:07:24.875	down	3000	TCP connection timed out after 3000ms	tcp
43c6602c-d12a-4eaa-9ff8-75fb1471ac90	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:07:24.881	down	2998	connect EHOSTUNREACH 192.168.1.221:8180	tcp
2b4bf65a-a2e2-4a95-8626-9aee389389f5	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:07:51.897	down	2	\N	tcp
0d214e84-d04f-4b69-b0c2-77c6900e6424	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:07:51.898	down	3	\N	tcp
208efc58-129f-44c9-bbc7-daf9ebba0415	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:07:51.907	up	2	\N	tcp
3e10c1f2-8b5b-416f-9022-c3d2d1d84402	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:07:51.908	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
511e36ea-eb14-4de2-8f5e-3683840c024b	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:08:21.902	down	2	\N	tcp
598a7b96-cf9c-4852-a777-9489c9cca2a7	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:08:21.906	down	6	\N	tcp
1c89a358-20f9-4c00-ab35-0c43d66591a9	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:08:21.914	down	2	connect ECONNREFUSED 127.0.0.1:8078	tcp
32112a67-2ed4-4a80-a643-8535b53128ec	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:08:21.939	up	27	\N	tcp
e72cc04e-0c22-4fa7-b963-41de8301883d	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:08:51.99	up	18	\N	tcp
bbfd3ac6-38a5-4542-a113-fd08a795b2a0	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:09:21.947	down	2	\N	tcp
7f2ea758-83b5-4746-aa6b-0008de750a1a	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:09:21.95	down	5	\N	tcp
40b5ff77-f77c-4469-a13f-51a11f64f4cc	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:09:21.95	down	5	\N	tcp
f06b99d1-53d8-47ac-9d4d-22910b7c2efd	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:09:21.96	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
353aa915-2b28-4be0-920e-5ec177427022	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:09:21.964	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
a3cf3cd7-3e8c-413a-956c-1953b98251f4	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:09:21.971	up	9	\N	tcp
79e9815a-cc3b-4340-b1f0-d3321b67ed55	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:09:24.955	down	2992	connect EHOSTUNREACH 192.168.1.221:8180	tcp
787e817d-a095-4fb0-b3f2-6760915fcdc7	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:09:51.966	down	4	\N	tcp
dd0fd617-c722-4fcf-8a60-c0a8a9c7d7b5	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:09:28.168	down	5	\N	tcp
f0842d1b-c1c5-46c3-a73b-7918039329e5	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:09:58.186	down	4	\N	tcp
14113193-f999-4473-a085-0beff4b5c811	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:09:58.189	down	7	\N	tcp
dd91234a-2a79-479d-bcbf-d446dd1e618f	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:09:58.641	down	441	connect ECONNREFUSED 10.0.0.200:3100	tcp
ec949027-8eff-42f3-93e0-dde757a72036	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:09:58.644	up	436	\N	tcp
0efc148d-09ec-4e2f-97f2-847158f77d2e	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:45:40.443	down	7	\N	tcp
f5086eec-beff-4a63-a03b-9613f4936c5d	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:45:40.444	down	8	\N	tcp
bf404fa4-3e80-4f63-a355-cd1e2c547e4c	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:58:24.66	down	3001	TCP connection timed out after 3000ms	tcp
1f89ced0-b465-4f60-916b-625db19ff5ac	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:05:51.824	down	2	\N	tcp
4608512b-d949-4604-8d93-9ea32c0f4443	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:05:51.825	up	3	\N	tcp
f5f4b8e3-dac8-4d40-a9b8-323b42d1cb79	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:05:51.839	up	3	\N	tcp
b6c3ff3b-5e10-41d9-8260-83bdba0c867f	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:05:51.863	up	27	\N	tcp
25d3547a-da1c-4211-bd2e-cb1de7a29cea	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:05:51.864	up	18	\N	tcp
3e93d9e6-a8f5-492a-b437-4ead3c02cd0b	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:06:21.855	down	1	\N	tcp
a1363847-169a-4c75-a19c-e79ff00bbb36	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:06:21.857	down	3	\N	tcp
425fe564-c81d-4347-906d-2d228544c072	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:06:21.867	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
fc6ea370-27fc-4ee1-91cd-6778e324598e	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:06:21.867	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
a5d4260b-b324-4a84-a57a-8ab987f1aead	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:06:21.875	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
6e9a47a5-bf2c-48ac-9df3-6639275212df	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:06:21.901	up	36	\N	tcp
e33bfeaa-a44f-4d0e-a905-e55dc7cd196e	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:06:21.903	up	25	\N	tcp
1ffecc59-c2ec-403d-afb4-b4bf3a0c9060	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:06:24.866	down	3001	TCP connection timed out after 3000ms	tcp
c9b1c717-2c04-4889-a111-fd27382e03e2	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:06:51.86	down	2	\N	tcp
f299eddb-9fc9-49c0-ad25-9edba596498c	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:06:51.863	down	5	\N	tcp
b2895381-6fc6-4019-929d-c89a0cdfe067	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:06:51.883	down	2	connect ECONNREFUSED 127.0.0.1:9001	tcp
840bca52-b53c-4a0b-b7ea-e72c7241e491	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:06:54.873	down	3000	TCP connection timed out after 3000ms	tcp
888fe27f-1bc5-4b61-afeb-0d45032f29bf	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:07:21.866	up	3	\N	tcp
cf462ed1-90c0-4b03-8c5a-77baccfa8aa1	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:07:51.897	down	2	\N	tcp
05e84bd6-5d9b-4b73-907a-924a43b57da2	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:07:51.907	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
3c05f8be-3db8-48a1-9993-3bd1c815f2be	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:07:51.908	down	3	connect ECONNREFUSED 127.0.0.1:9006	tcp
9c12f7ba-b0c7-47fd-b3f0-ca6a5f941789	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:07:51.913	up	7	\N	tcp
bfd777ba-640e-48f7-beaf-cf949c1729b0	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:07:54.906	down	2993	connect EHOSTUNREACH 192.168.1.221:3011	tcp
39b8ce17-866d-4b14-8571-8f36ad705b78	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:08:21.903	down	4	\N	tcp
8bf715cc-15c9-4db1-8b47-93ac08501d61	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:08:21.913	up	2	\N	tcp
1458b03f-ceea-447a-9b06-ae5a8c3c04c5	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:08:21.939	up	27	\N	tcp
e8179fe6-2898-44a3-94d5-fdcf4836d64f	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:08:21.94	up	19	\N	tcp
c75b5877-c76b-4a6c-bb30-5623451a41fc	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:08:24.911	down	3000	TCP connection timed out after 3000ms	tcp
7693a329-786a-45e1-93d7-c30b313f2977	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:08:51.991	down	19	connect ECONNREFUSED 10.0.0.200:3100	tcp
3d7e7c34-65bb-4ea8-a5c0-33b8c9eebda4	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:08:54.978	down	2998	connect EHOSTUNREACH 192.168.1.221:3011	tcp
3eb6b5e7-0401-4dfe-8f5c-ff410913f0b3	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:09:21.959	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
d18abe35-47e8-4161-8d1d-5a14b7c41b9e	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:09:21.971	up	14	\N	tcp
0c8073e6-1256-416c-ac7e-2a9036f32dc5	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:09:51.965	up	2	\N	tcp
ab761739-c7f4-4d2c-8c85-fe99773712fd	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:09:51.979	down	3	connect ECONNREFUSED 127.0.0.1:8080	tcp
da86145e-9997-441a-8e6e-15239b73dde5	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:09:51.984	up	8	\N	tcp
1f458bc6-0799-4e30-ad9b-c447355db8fe	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:10:21.971	up	2	\N	tcp
a25f9169-aac6-4aa0-8b30-6a542fc557aa	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:10:21.973	down	4	\N	tcp
97db3fe1-e41a-4407-8f8a-883bbe86dbad	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:05:00.205	up	9	\N	tcp
c04f8ecd-b24f-4eab-bf4a-a9c7c68ca1ec	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:05:28.044	down	5	\N	tcp
a954c0f3-0826-41a0-8e57-77b73d10fa3b	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:05:28.046	down	7	\N	tcp
bbc5a833-0c21-4744-8482-42aa4bde6ff9	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:05:28.049	down	9	\N	tcp
3361c8d4-c652-4923-89c3-eeb21c6afe87	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:05:58.064	down	3	\N	tcp
ab49c5cf-f39f-43cb-bdd3-5fc077b18584	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:05:58.066	down	6	\N	tcp
752720e9-34ae-4dfe-84c5-4109dacc37d9	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:45:40.443	down	8	\N	tcp
d139d60a-e6aa-4758-91bc-da20c9550f26	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:45:40.44	down	5	\N	tcp
bc38db3f-631c-4ce1-a81d-6e9382d22ef4	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:58:24.66	down	3001	TCP connection timed out after 3000ms	tcp
fe1ac2fd-f488-45b9-9218-a706fd0d90c0	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:05:51.824	down	3	\N	tcp
16b96f7d-bdde-4457-b112-467155bcf678	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:05:51.837	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
840fce66-de16-4510-9d90-d88482cd0c51	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:05:51.863	up	18	\N	tcp
e5d18dcd-6f44-41dd-ab00-0cad5136e076	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:05:51.864	up	17	\N	tcp
97af2bec-7ecb-44e4-92a9-fcd15a74afcf	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:05:54.837	down	3001	TCP connection timed out after 3000ms	tcp
a3a07562-24b3-4065-8001-fe3797940b82	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:06:21.857	down	2	\N	tcp
e3f64552-7ee5-48c6-b92c-3e8c8322778d	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:06:51.86	down	2	\N	tcp
b4087cdd-1df9-47be-babd-50d0638360a8	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:06:51.882	up	9	\N	tcp
a97226c5-8dc2-41ce-89d4-e790ab49f47d	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:06:51.883	down	2	connect ECONNREFUSED 127.0.0.1:9006	tcp
73b60114-f0c1-4096-b1ba-6bb2edef1453	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:06:51.89	up	3	\N	tcp
52576056-560f-4532-834d-1d825e35a103	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:06:51.892	up	4	\N	tcp
c16d276b-7ef3-4721-921d-6d4d578bc45e	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:06:54.873	down	3001	TCP connection timed out after 3000ms	tcp
6c9c2abc-fa65-4b55-9075-3365645b4fec	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:07:21.865	down	2	\N	tcp
38b1c1e9-11b4-42ad-b33c-ff70d5f05a48	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:07:21.868	down	4	\N	tcp
a40890d7-fbb1-4793-819b-46a44c301f9d	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:07:21.877	up	3	\N	tcp
0a848f99-c96a-41fd-b69d-5dbfc56c3e37	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:07:21.885	up	10	\N	tcp
37bd713f-6e45-4c08-b5b4-79f222818f21	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:07:51.897	down	2	\N	tcp
3e745ed6-a7b3-4089-98b7-0c11ae98a155	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:07:51.899	up	4	\N	tcp
ec21ed6d-f952-4a37-ade6-b21cc355ed32	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:07:51.897	down	2	\N	tcp
4b0d1246-7677-41f9-b730-fd0cbd80ecf0	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:07:51.913	up	7	\N	tcp
af09d301-70d4-46e8-ab11-cd98f6c2952e	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:07:51.922	up	9	\N	tcp
b5c75565-18fa-4f59-a0e8-9728a2c4796e	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:07:54.905	down	3000	TCP connection timed out after 3000ms	tcp
5619cefd-a509-4a97-8ac4-c772c2a2de15	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:08:21.904	down	4	\N	tcp
93ca43c4-766e-4b11-950a-ded3d27abe44	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:08:51.992	up	12	\N	tcp
091c9d18-0b52-43f5-b2ca-00a26d41f388	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:08:51.992	up	9	\N	tcp
911fc8be-3cf4-49aa-a6ca-d611eadb7c31	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:09:21.948	down	3	\N	tcp
66c42bd4-d072-433c-9414-52a576462d7d	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:09:51.967	down	4	\N	tcp
513a9c65-54cb-4777-9663-de8b789eebe1	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:09:51.98	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
be404458-65c6-4400-863b-441c5dd7f07c	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:10:21.972	down	3	\N	tcp
b63fd6b1-e9f5-471e-bf0c-934225371ad8	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:10:21.982	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
5143f063-f5a4-4a55-bbd2-c1e19683e755	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:10:21.986	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
038a8476-6203-48d0-848d-2bbfd54718fa	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:10:21.99	up	9	\N	tcp
b3e9b9ca-1737-463e-8544-3840453cf2e5	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:10:21.99	up	4	\N	tcp
261dc528-bdcd-49c3-80f8-732d62d1b51a	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:10:21.993	up	4	\N	tcp
a943ac63-c882-4ca4-9343-e7f0d530526b	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:10:24.98	down	3000	TCP connection timed out after 3000ms	tcp
949a981b-d3b3-4dd9-84cd-3a5fa056c084	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:10:24.98	down	3000	TCP connection timed out after 3000ms	tcp
063fe0da-5956-4312-95c4-cba3d25add07	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:10:24.985	down	3000	TCP connection timed out after 3000ms	tcp
ccda2b6f-83c9-44f3-9fe1-675a8e991535	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:09:28.167	down	5	\N	tcp
c34e13fa-1b40-489a-a5dd-658f8c18a4ab	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:45:40.444	down	8	\N	tcp
71922fce-a042-4a5c-808c-85f0af1ffc29	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:58:24.661	down	3001	TCP connection timed out after 3000ms	tcp
8d62fbb8-6f38-4c5e-aedc-e94b59f6dc76	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:05:51.825	down	3	\N	tcp
8c85db50-4729-4d8d-b618-a1cf59b8b259	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:06:21.858	down	4	\N	tcp
5a0e0d56-c6b9-46f6-9063-9cdbc84c9dbd	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:06:21.867	up	2	\N	tcp
fb63a8d0-9fe3-4888-97a9-9d584769e5a1	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:06:21.875	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
a8f5e333-32a2-4cbd-8948-4d75df771dbf	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:06:21.902	up	27	\N	tcp
ba5a9d8a-f80d-45e4-8c48-bec6d6f378e9	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:06:51.862	down	4	\N	tcp
17ab1468-6084-4a4c-bdbf-a02ee47f5e37	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:06:51.885	up	4	\N	tcp
cf14df2e-7e8d-4f80-96a8-e66b30183350	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:06:54.874	down	3001	TCP connection timed out after 3000ms	tcp
7fd8b213-077c-4a98-adc8-7f2c0649ccab	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:07:21.869	down	5	\N	tcp
a60e7355-5226-44df-946b-c5bb83282638	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:07:21.878	down	3	connect ECONNREFUSED 127.0.0.1:9006	tcp
26eec3b7-97ad-4f53-8df4-1395df3c75e1	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:07:21.88	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
91a1d90c-ffbe-4960-9843-da8d7c773545	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:07:21.886	up	5	\N	tcp
faf41020-29c2-411c-a0fa-fe1ff63174d8	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:07:24.874	down	3000	TCP connection timed out after 3000ms	tcp
f0508ef1-04e9-476d-888d-3222b211116e	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:07:24.881	down	3000	TCP connection timed out after 3000ms	tcp
303765a8-1700-4c17-8df9-2f8d9cc92e48	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:07:51.898	down	3	\N	tcp
f7a83d5b-a740-4e9a-a7a1-cc525356e9d2	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:08:21.902	down	2	\N	tcp
2346ddb6-a22d-4d86-b9e9-93e5a8030e2c	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:08:51.991	up	19	\N	tcp
78011070-ed24-4c47-98ab-d66afe5ff689	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:08:54.979	down	2999	connect EHOSTUNREACH 192.168.1.221:8180	tcp
57856c76-3441-4820-9e15-b683bdde1541	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:09:21.949	up	4	\N	tcp
b4d7bbe4-4548-4fef-a31b-caed972d94dc	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:09:21.96	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
a8ba7525-dc8b-4b78-a526-b91183397732	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:09:21.964	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
f6376d67-3a2c-4d59-b469-201bd22fae80	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:09:21.971	up	14	\N	tcp
df6b0fb3-d766-48e1-9f31-0c252c6b0788	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:09:51.966	down	3	\N	tcp
30c138a4-f6b4-45c2-b732-4f4fd9ab5083	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:09:51.984	up	7	\N	tcp
5ed7dd75-c4e1-4b38-8896-1409b39cf79b	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:09:51.984	up	8	\N	tcp
f7d2284c-e91c-4e0a-b84b-b609cac709d5	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:10:21.972	down	3	\N	tcp
5e8112c9-cfbf-4649-958e-0f310b4fb650	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:10:21.983	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
d65e25cc-2f2e-44fc-8ecf-96616d8efe30	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:10:21.987	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
c935d658-d24d-4bf8-b93d-8fa5a4922eef	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:10:21.989	up	9	\N	tcp
43413f56-9279-4a14-96e6-3ebb7aa5e5d7	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:10:21.99	up	9	\N	tcp
9dc39725-a412-457c-be47-e092c0d32091	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:10:51.974	down	2	\N	tcp
987ff7d9-a9da-42a8-b50d-1636403b3cb9	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:10:51.975	down	2	\N	tcp
3ac0f930-ab6f-4cf4-800b-ea82a29ca545	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:10:51.975	down	2	\N	tcp
8f78e426-7fc3-4b2f-80b2-3805f9fc39d1	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:10:51.975	down	2	\N	tcp
fa4dc54f-05f6-43f9-ae98-bcb068b4d52e	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:10:51.975	down	2	\N	tcp
87f71f05-aed9-41ce-a388-17359cf98bda	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:10:51.975	down	2	\N	tcp
a23c1df0-ca14-40ca-ac24-3222f85a6ec3	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:10:51.975	down	3	\N	tcp
76253010-89ac-4eb6-849a-17cb26d155bc	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:10:51.975	down	3	\N	tcp
c1aa87dc-9ba5-4352-a5ed-d4019d995a23	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:10:51.976	down	3	\N	tcp
c7a448a2-91e7-4f7b-af03-7999c0bb510b	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:10:51.976	down	3	\N	tcp
f592e8d4-b273-4b97-b440-5e2630e9d82a	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:10:51.976	up	3	\N	tcp
6f87ded9-9c35-47dc-84c9-f80a76a82eca	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:10:51.976	down	3	\N	tcp
42d32bb4-a912-4af3-bd5d-871b8a3b3fab	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:10:51.976	up	4	\N	tcp
da7e7ffb-f2df-4b0e-8800-68d18d511b59	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:09:28.168	up	5	\N	tcp
123caccc-4228-4758-8cb2-ea596170fc36	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:09:28.188	up	5	\N	tcp
cfea3ef7-4a91-48a8-909e-ec30376fb643	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:09:28.19	up	7	\N	tcp
4f17c893-b663-4dde-bff5-3ee0a8257a2d	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:09:28.2	down	4	connect ECONNREFUSED 127.0.0.1:8078	tcp
71f5bf7d-c519-4139-84c6-d83b853b5329	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:09:31.185	down	3001	TCP connection timed out after 3000ms	tcp
f40ab81f-55b2-4589-9b21-7a12423cba0d	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:09:58.184	down	3	\N	tcp
2753431c-6527-4b93-b924-9195e14e5277	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:45:40.439	down	4	\N	tcp
de46e04f-68eb-48e4-ae2a-a65a55e21085	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:58:51.668	down	2	\N	tcp
9ea71328-b6fe-4ae4-a6f5-b74512a60711	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:58:51.677	down	10	\N	tcp
fdaaddd0-54fb-4d12-8ad0-bb0c8f66f00a	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:58:51.728	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
2bf3a63b-12db-4ec4-a132-6a294281eab2	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:59:21.68	down	2	\N	tcp
0c03d66c-f48a-4e43-a0df-42f57880eac9	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:59:21.683	down	5	\N	tcp
8d7641e0-311c-4200-97fd-c2fd5433ee64	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:59:21.695	down	7	connect ECONNREFUSED 127.0.0.1:6875	tcp
bbc18929-2a2c-408b-bde3-1206da1cd2f6	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:59:21.697	up	0	\N	tcp
408ba130-317a-4cff-ac6e-02ee89d6a723	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:59:21.699	down	0	connect ECONNREFUSED 127.0.0.1:8555	tcp
f8d5d0d3-e3ff-4414-8041-d99a13c12d2c	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:59:21.701	down	0	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
45818b51-ece3-4fec-b089-18d92c32ccb7	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:59:21.703	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
6ab87ac9-f474-48c7-b43f-a3cd734eb0f1	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:59:21.705	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
e664461e-669b-4816-b3c4-c788594e71f1	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:59:21.707	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
e0d54796-c012-4988-9be5-e56a03e712a0	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:59:21.708	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
890c4e97-f951-42e0-bc17-e4a22b797dce	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:59:21.71	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
7433361b-0a55-47e3-9e6b-61bac75431b2	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:59:21.713	up	25	\N	tcp
9a9a0d26-7d4c-4d8f-a7c4-b779b9d17c68	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:59:51.686	down	1	\N	tcp
46c81e2b-6d21-4a10-82b3-b172a048cb2a	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:59:51.687	down	2	\N	tcp
f251d640-586c-45ae-9793-aeb9bbb94986	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:00:21.724	down	3	\N	tcp
0ccbba61-1601-4dc6-b99c-125df4c188e9	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:00:21.727	down	5	\N	tcp
e0daef05-8db3-4b0d-8f16-991115b41084	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:00:21.735	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
7aee3990-af84-4da7-ae20-a87e489ee9ba	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:00:21.742	up	9	\N	tcp
3ac1928a-a341-4c1c-9d6a-454cfb460a6a	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:00:21.745	down	2	connect ECONNREFUSED 127.0.0.1:9000	tcp
ca5a7740-27f7-431e-8fdd-da50cb035474	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:00:21.746	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
e4aca0c6-0252-4419-9168-d03986513634	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:00:24.734	down	3000	TCP connection timed out after 3000ms	tcp
99211313-7766-43e5-a396-e042fadd3ee4	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:00:51.743	down	3	\N	tcp
844054ed-6109-4779-a47c-9912846c8b40	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:00:51.744	down	5	\N	tcp
6d474fa2-9b13-4835-b749-daf22ce59d5d	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:00:51.755	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
8d5c6135-1978-4d57-b515-4bf9bdc880dd	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:00:51.756	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
624023f8-973d-4cee-a228-4145ef8dee36	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:00:51.759	up	0	\N	tcp
f036f9c8-b14b-4147-bb8e-807517e2499a	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:00:51.761	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
608a65d4-dc2c-4f69-aabf-871679837c1f	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:00:51.763	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
0975bc85-08f6-4b30-b757-f305751c898e	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:00:51.765	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
a6a6377c-9e50-4115-a129-2298df3e5182	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:00:51.767	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
fa50a3dc-47c6-41a8-8ce9-ed6778aa56fc	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:00:51.768	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
dc585929-2307-47ec-b7bf-b4f2b27d5c59	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:00:51.776	up	22	\N	tcp
f3026671-5947-43e7-bb19-6a818c909160	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:00:54.759	down	3000	TCP connection timed out after 3000ms	tcp
dfb27710-4bb3-432c-b1d4-97762654643b	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:01:21.772	down	1	\N	tcp
7738422c-1e43-4034-9205-3a1bc7df79e8	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:09:28.169	down	6	\N	tcp
b23b2cf9-e2f9-49dc-8860-46d994a2a9cb	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:09:28.186	down	3	connect ECONNREFUSED 127.0.0.1:8555	tcp
a1a95d38-b6f0-4ced-97c5-3371a4f070ab	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:09:28.19	up	7	\N	tcp
b1465b75-8927-499d-ba2b-02fbe7a65cc2	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:09:28.199	down	4	connect ECONNREFUSED 127.0.0.1:6875	tcp
921fecbe-21e4-4621-acc7-c330aa5e358b	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:09:28.205	up	9	\N	tcp
aa6a4066-2844-4035-af12-ecf542bbd7f7	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:09:31.184	down	3001	connect EHOSTUNREACH 192.168.1.222:82	tcp
1dc6cc9f-7d89-4856-b8a0-6dfa78f655d3	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:09:58.186	down	4	\N	tcp
dc12321f-10e4-4545-96cb-1c2c6b5f93e1	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:09:58.188	down	6	\N	tcp
455d58ca-510f-43dc-a542-de1751a2594c	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:09:58.203	down	3	connect ECONNREFUSED 127.0.0.1:6875	tcp
bd8e9efc-6ef0-4b25-ac7f-8ce5a4c08dbf	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:09:58.642	up	442	\N	tcp
9d98967a-a628-4510-a90e-22917d38d8d4	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:09:58.644	up	436	\N	tcp
0f8f51c1-bfa4-44e3-b87c-f8505fdf9936	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:45:40.44	up	4	\N	tcp
4de8bfb9-8611-403a-b6fa-a7185d30912c	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:45:40.482	up	6	\N	tcp
6737cd31-8594-4722-888c-1b5aec63e14c	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:45:40.485	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
539c9fdb-de20-4de3-b12b-5ebbae747d6a	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:45:43.468	down	3000	TCP connection timed out after 3000ms	tcp
654e1d14-7246-40c8-ad1a-230725511597	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:58:51.669	down	3	\N	tcp
1e4d9005-43ed-4132-ae1d-494900b5cdc3	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:58:51.683	up	11	\N	tcp
2f2b1c78-580e-451d-818b-50a669734543	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:59:21.681	down	3	\N	tcp
e9250498-c976-4e0e-b897-0c5124d732e9	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:59:21.713	down	25	connect ECONNREFUSED 10.0.0.200:3100	tcp
d1382451-78cb-4925-ad84-5682e2baa415	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:59:24.697	down	3000	TCP connection timed out after 3000ms	tcp
09a86caf-4d37-4799-9881-ada1778c77db	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:59:51.686	down	2	\N	tcp
9053070f-adad-473e-b0fe-8035a7d950f7	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:59:51.69	up	4	\N	tcp
08ff14eb-8dcf-4deb-8225-6868867b7ab2	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:59:51.696	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
b84b0100-13f6-4016-9b5e-c8fbb2e7b352	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:59:51.697	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
f6ecc4dd-d83d-402b-b2aa-1eec352e01a7	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:59:51.702	up	8	\N	tcp
c06f54ae-6422-4ea5-b538-a188cb8c553f	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:59:51.706	up	7	\N	tcp
0fb31abe-b321-4149-9e7f-02c33baa06e3	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:00:21.724	down	2	\N	tcp
3593cca6-73c4-4a76-ae0c-c89287cc08d4	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:00:21.743	down	3	connect ECONNREFUSED 10.0.0.200:3100	tcp
bb019e4d-456d-4c4c-b2ec-063f9af65ce6	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:00:21.745	up	6	\N	tcp
22053570-684d-48c0-af30-5ea97c49c027	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:00:24.734	down	3000	TCP connection timed out after 3000ms	tcp
2c9e211b-bb57-4025-83f6-71b38e2cb781	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:00:51.741	up	2	\N	tcp
0f549059-6fc7-4e93-89e2-f010bc05d412	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:01:21.773	down	3	\N	tcp
59187a83-deb1-4e6c-a44c-e02515c16fc1	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:01:21.775	down	4	\N	tcp
127214fb-b215-40d7-a567-755545033eaf	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:01:21.781	up	2	\N	tcp
a3c19697-cffc-46ff-815e-b23694e34d7c	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:05:51.825	down	3	\N	tcp
157a0980-3b86-4691-9a94-7f51e1a2d482	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:05:51.863	up	17	\N	tcp
9593e4fb-c7ac-4918-bde6-f87b6acbb7bc	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:05:54.837	down	3001	TCP connection timed out after 3000ms	tcp
dbc85429-275b-4b22-98f6-fdd13518f9e2	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:06:21.857	down	2	\N	tcp
d3f72616-a14d-4a16-98dd-194193157767	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:06:21.902	down	28	connect ECONNREFUSED 10.0.0.200:3100	tcp
b7f03e99-c863-40a2-a92c-852966308359	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:06:24.866	down	3001	TCP connection timed out after 3000ms	tcp
8b745785-de9b-4267-bbbc-5b7f1f5d8841	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:06:51.863	down	5	\N	tcp
b5568c31-25d8-4648-ab43-7abcd5273cb7	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:06:51.876	up	3	\N	tcp
cd737ded-e3fe-4d1e-9607-b650a31f9873	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:07:21.865	down	2	\N	tcp
c4d906db-ffcf-4b06-8bce-3f90ff0735be	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:07:21.866	down	3	\N	tcp
209467df-d09e-42f7-899b-a262fac5688e	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:07:21.877	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
afe5b6f2-97aa-41d4-9758-6cf6fce315ea	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:09:28.168	down	6	\N	tcp
1d4ea667-b13a-425e-a54d-f3cc041e3ee4	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:09:28.189	up	5	\N	tcp
1afbae71-db36-4556-b53c-9a7a728a5ba1	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:09:28.2	down	4	connect ECONNREFUSED 127.0.0.1:9020	tcp
58b5a0fe-eb44-4c4c-a7d1-99af38fadd3a	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:09:58.187	down	5	\N	tcp
6e916a1e-990b-45b6-91db-66290bae2f23	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:09:58.204	down	3	connect ECONNREFUSED 127.0.0.1:8080	tcp
e1e1a1b8-0b01-46ea-86a9-cc1e911c87c9	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:09:58.642	up	441	\N	tcp
f923b565-3f3a-420e-839f-166f1f1ed207	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:09:58.643	up	443	\N	tcp
993d8e8b-41ab-46be-8e4a-15ba47f8de76	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:45:40.441	down	5	\N	tcp
667f492e-cf10-468c-9af8-eec3ac81ae2d	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:45:40.481	up	13	\N	tcp
15fe0723-d41f-4f72-965b-e85f126f9f91	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:58:51.668	down	3	\N	tcp
29a09813-c877-4b91-95f2-27534d9b372e	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:58:51.686	down	19	\N	tcp
acf18e99-4d6d-4ede-acc3-2b584b46f72e	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:58:51.671	down	5	\N	tcp
36dd4ddb-08b3-4159-8129-c90762f514a8	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:58:51.728	up	3	\N	tcp
4a388725-06bf-47a9-b4c7-79d05bed6454	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:58:51.734	up	9	\N	tcp
0d852214-6fc6-4287-af71-564494d6a6c6	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:59:21.68	down	2	\N	tcp
c4222450-3359-4faa-9d97-6b90db5c53f0	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:59:51.688	down	3	\N	tcp
3badba52-0b85-419a-8935-b855c44a14a1	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:59:51.69	down	5	\N	tcp
3ea8af7d-a510-4c8f-9baf-6571ec493914	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:59:51.696	up	2	\N	tcp
54f46d51-ab27-4bf0-ac9b-a9a6dfb9160c	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:59:51.697	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
7a9b23c8-8954-4569-b7bb-779bd5507729	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:59:51.699	down	0	connect ECONNREFUSED 127.0.0.1:4100	tcp
9f281c4b-3861-44bd-99af-d205231652bf	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:59:51.702	up	8	\N	tcp
f53f6be2-dcbd-44d4-a4fa-9147de92961f	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:59:51.703	up	8	\N	tcp
7d26d0a1-d50a-4f92-a8df-165c3ab1d3de	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:59:51.706	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
d6a15458-a60d-4da8-a12b-a1ccecbaecb8	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:59:54.694	down	2999	TCP connection timed out after 3000ms	tcp
1072ea67-af2b-4a5f-9c0b-41af54dcf96f	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:00:21.723	down	2	\N	tcp
569c18f9-4ca1-4644-9e52-dadf2f526499	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:00:21.725	down	3	\N	tcp
c9494b32-a442-49b3-a2c2-1210f556a09a	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:00:21.736	up	2	\N	tcp
8c337c71-e358-44ca-af69-630d7f061f6d	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:00:21.742	up	9	\N	tcp
72014a09-5a93-49e5-85bf-bd5fe0b92bfe	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:00:51.742	down	3	\N	tcp
f44bcc7c-a4fb-48c6-aa80-6d2cc0400491	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:00:51.756	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
73f04672-a440-409a-ae0b-0227a4856ea4	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:00:51.776	up	21	\N	tcp
d4adb05b-605b-42f6-b939-6402299b1335	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:01:21.772	up	2	\N	tcp
67670a20-c812-4f01-b35a-dd2d8c0c4e8b	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:01:21.774	down	3	\N	tcp
a69dc336-b731-40dc-b3cc-28e2cace85c8	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:01:21.781	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
adbdbe8b-fb67-4aa1-bb91-de9a94fd4ef9	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:01:21.798	up	18	\N	tcp
0210aacd-b19c-417e-9179-16fe9de363f2	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:01:21.799	up	12	\N	tcp
ae1b0359-ed5e-42cc-874f-94eaf227505d	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:01:24.779	down	2999	TCP connection timed out after 3000ms	tcp
251409e0-f648-4a0b-b04b-5ba16b43511d	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:01:24.785	down	3001	TCP connection timed out after 3000ms	tcp
b0fd57df-7b96-4c87-92d5-249a07b7460e	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:05:51.825	down	3	\N	tcp
1602c7f2-1b40-4913-8afe-a96405bc1737	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:05:51.863	up	14	\N	tcp
ac6fb6d5-9e90-4962-9094-19d19ddfdc0e	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:05:54.835	down	2999	TCP connection timed out after 3000ms	tcp
39472bc5-ff7d-4671-994a-2e5c5495f602	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:05:54.837	down	3001	TCP connection timed out after 3000ms	tcp
3ce1c35b-b494-492d-92b6-3136106aaa72	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:06:21.856	down	2	\N	tcp
28338b4f-1477-4641-937b-65aec0490c27	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:06:21.902	up	27	\N	tcp
823fd6b7-3061-4ffb-bcb7-f61dca26ce17	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:06:24.867	down	3001	TCP connection timed out after 3000ms	tcp
63618f00-1516-49f7-befc-a260d9c6fbd6	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:06:51.86	down	2	\N	tcp
59894701-1a51-418d-bcb4-475c8d1d74af	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:09:28.172	down	9	\N	tcp
c11ffe35-a59f-44c9-a6e1-178c02e829b3	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:09:28.185	up	2	\N	tcp
e52c3e97-16ac-40d3-98a8-c6ec1f906533	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:09:28.186	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
e4954dfd-ae18-4e43-a2e5-d559097e1290	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:09:28.189	up	6	\N	tcp
f039953e-6431-4358-ba15-562ca13aaed0	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:09:28.198	down	3	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
3b76bcd0-48de-46ed-8ff7-6b870847ac76	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:09:28.199	down	4	connect ECONNREFUSED 127.0.0.1:8020	tcp
86798b41-ce59-49c2-bb00-e498c2932928	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:09:31.185	down	3001	TCP connection timed out after 3000ms	tcp
caf17e56-9b7e-4468-b9d0-ae8bbbe73e62	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:09:58.184	down	2	\N	tcp
cfbd8569-7b2f-48c7-ab95-6d6c28a9803a	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:09:58.188	down	6	\N	tcp
5bd711b7-5745-40c1-a1b9-a62e4c9da735	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:09:58.191	down	9	\N	tcp
69e255a8-ff78-40ee-90ec-10cb329fa970	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:09:58.202	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
125987ae-7a2d-4f18-b95f-70bfc05c0ee2	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:45:40.442	down	6	\N	tcp
8b478fe0-2a5c-4da9-b3f5-1458ee5f7ab0	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:45:40.471	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
2ce96cc8-86b1-4c25-a89b-1c0a2fddeda4	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:45:40.475	down	1	connect ECONNREFUSED 127.0.0.1:8556	tcp
0cabc179-6373-4f7c-88ac-95b0230f8f52	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:45:40.48	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
5e610140-81b0-43df-a04c-d520713b99bb	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:45:40.482	up	13	\N	tcp
af1910fd-9977-41df-9a9d-a136de48b42d	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:45:43.469	down	3000	TCP connection timed out after 3000ms	tcp
b223a797-b61d-4e30-b43e-c41a3658bb30	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:58:51.669	down	3	\N	tcp
ed1a2ec4-9949-409a-aac8-4a1ed7f8d72d	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:58:51.671	up	4	\N	tcp
3180d567-2c2a-4c7c-ba63-b44fbb096c8a	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:58:51.735	up	10	\N	tcp
1d1d2374-0e76-436a-87c8-c2abcc41ece8	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:58:51.749	up	11	\N	tcp
d7ecfce2-c1b1-4d93-848f-f65f358824d8	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:58:51.755	down	6	connect ECONNREFUSED 127.0.0.1:9001	tcp
11bee661-604d-470b-8075-b7594f5fc099	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:58:54.726	down	3001	TCP connection timed out after 3000ms	tcp
f8a06477-80ee-42a9-87d2-2467f6a1e55d	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:59:21.679	down	1	\N	tcp
4c2bd5a7-e86b-4f5e-925f-d1042e20c484	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:59:21.681	down	3	\N	tcp
22806834-ccd6-4ad6-b963-b87825f24e0b	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:59:21.712	up	24	\N	tcp
0ef74265-6c08-4b28-8a9b-79a077240591	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:59:24.696	down	3000	TCP connection timed out after 3000ms	tcp
5856a9e8-5018-4e9f-8017-b3dbb2c65b7a	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:59:51.688	down	3	\N	tcp
8b9ca404-33b0-4745-a46d-1d3925444d77	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:00:21.723	down	1	\N	tcp
c1e35d7b-ff2f-4302-9c0d-546af6c4bbf7	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:00:21.743	up	9	\N	tcp
4af6d9f8-f0d9-492f-8c38-6ca1e75687cc	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:00:24.734	down	2991	connect EHOSTUNREACH 192.168.1.221:4001	tcp
7b066f1f-0fd8-47d6-a05f-8c7d82cc99c6	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:00:51.742	down	2	\N	tcp
e788d073-4fe2-442f-8bdf-db868d83b6c0	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:00:51.777	up	22	\N	tcp
2e30f949-323b-4f2f-a154-417a9a45f272	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:00:54.755	down	3001	TCP connection timed out after 3000ms	tcp
75a737ef-c965-42fe-8bf8-e6f7034000a7	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:01:21.773	down	3	\N	tcp
a8e3aee1-eaa4-43e0-ad13-aea326f917ff	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:01:21.797	up	18	\N	tcp
8991d3c8-2cd9-4cbb-be06-5d31bc9fc7c5	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:05:51.824	down	3	\N	tcp
3489eb67-36a7-4e94-91a2-712189bfea78	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:05:51.838	up	3	\N	tcp
d080af7c-641a-4260-a987-0675a360cd2f	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:05:51.847	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
93e8e061-8a1f-44a4-ab5a-5cd2042fd490	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:05:51.862	up	26	\N	tcp
dfdd7e4e-b552-46c0-8816-44419890aca0	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:06:21.856	down	2	\N	tcp
cad7aa68-5fe5-4914-a584-5af103c1b256	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:06:21.858	down	4	\N	tcp
ce0dca0f-b615-4ccd-9027-ccc64b97c444	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:06:21.866	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
a8188af3-8a9d-41da-aecb-1eb6f557d91c	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:06:21.867	up	2	\N	tcp
1a2a41ec-4be5-40e1-b360-33b1028cae39	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:06:21.875	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
c8f4c084-181e-493b-ab35-dc008750742d	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:10:01.201	down	3001	TCP connection timed out after 3000ms	tcp
51983288-fae7-42d9-a546-e6fe4b420537	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:45:40.442	down	6	\N	tcp
b849bb53-95e9-495f-afdc-e549df606b67	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:45:40.47	down	1	connect ECONNREFUSED 127.0.0.1:8555	tcp
22b3c1ff-115a-4015-a6a6-43580a072cd6	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:45:40.474	up	1	\N	tcp
7d19e832-7152-422a-908c-a02cbc203b02	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:45:40.48	up	13	\N	tcp
b0a1d7aa-a16b-4310-b477-7080b12e0bc4	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:45:40.482	up	9	\N	tcp
5ebe8695-211d-431f-bde8-1f8058a696d6	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:45:40.482	up	7	\N	tcp
99c9db15-93bf-4360-92bd-be4a18460eb7	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:45:43.468	down	3000	TCP connection timed out after 3000ms	tcp
6652cdab-f28f-4e09-b32e-81e67d81cd85	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:45:43.469	down	3000	TCP connection timed out after 3000ms	tcp
b57fd8d4-4e1a-478f-8769-966b336aa7a2	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:58:51.676	down	10	\N	tcp
25a82ce1-361c-4aaa-8289-2d23c7df64b6	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:58:51.727	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
39642066-1f98-4db6-9948-83ef81a83c85	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:58:51.735	up	9	\N	tcp
61b55642-4632-4af9-9758-4589cf7280b1	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:58:51.755	up	7	\N	tcp
3c74c858-9ff1-452e-86fc-9460954f16bb	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:58:54.726	down	3001	TCP connection timed out after 3000ms	tcp
bab8a0ae-b463-4b05-8241-7364bfdbf860	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:58:54.737	down	2989	connect EHOSTUNREACH 192.168.1.222:8082	tcp
988b2951-0e98-4828-a6ac-314cce947eac	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:59:21.681	down	3	\N	tcp
3d1522bb-c5e4-41f7-a7d7-9c673b5a5d33	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:59:21.695	down	7	connect ECONNREFUSED 127.0.0.1:8080	tcp
444b518f-da2a-414e-aeeb-a52f7bc63124	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:59:21.712	up	24	\N	tcp
de9b91da-accc-4480-ab0e-84c1c60868e1	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:59:51.686	down	1	\N	tcp
56048d3c-0d9d-400f-86db-43c73ac1e526	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:59:51.688	down	3	\N	tcp
b7f1dd09-0151-41c9-b689-67f06e3787ee	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:59:51.702	up	8	\N	tcp
5d67bd2c-821d-47f8-a902-771607bbb79a	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:59:51.703	up	8	\N	tcp
ddc6ccdd-3649-43bf-8476-a5b61c1d59b4	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:59:51.706	up	7	\N	tcp
b0083fad-3c41-49ee-9856-98906d8a66cb	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:59:54.694	down	3000	TCP connection timed out after 3000ms	tcp
fe97a6db-b346-4f73-89bf-a45b7635276d	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:59:54.699	down	3001	TCP connection timed out after 3000ms	tcp
b2602356-d12c-4c72-a447-e8fd079edbd7	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:00:21.725	down	3	\N	tcp
19b933db-d9c4-45ea-947e-d07d88305682	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:00:21.743	up	9	\N	tcp
00722d56-15e7-47d8-ba43-7845e993b385	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:00:21.746	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
78005f1e-2fa1-446e-b94f-37d3ea3a4876	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:00:24.734	down	2994	connect EHOSTUNREACH 192.168.1.221:8180	tcp
23820f8c-4a42-426b-a82c-01bd142f53e0	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:00:51.742	up	2	\N	tcp
2f9fc4e3-72ea-43b1-be1a-34f9f16b4ba3	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:00:51.745	down	5	\N	tcp
660ef929-c6fd-4899-9c76-eb26726c19e1	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:00:51.756	up	2	\N	tcp
abd69aa8-e2d0-4f50-a506-2b8de7932608	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:00:51.775	up	21	\N	tcp
2022c8c5-8bfe-4431-9069-3006ad00b8f6	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:00:51.777	up	18	\N	tcp
91f4b3b7-5c5b-4e50-ab72-322c021e25ea	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:00:54.759	down	3000	TCP connection timed out after 3000ms	tcp
ddc73b88-aa11-4084-b3c2-1eb8931e700e	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:01:21.773	up	2	\N	tcp
8acf64e8-7496-426f-9a57-feb726432938	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:01:21.775	down	4	\N	tcp
b4d5f1a6-c66d-401d-91f1-c8755f83321e	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:01:21.798	up	18	\N	tcp
0f25fc3e-9443-4078-8406-49891512a6f7	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:05:51.826	up	4	\N	tcp
0e6ea75d-b01f-4bb0-b0ef-c9aeac7b3d07	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:05:51.839	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
e102579b-cb06-4ec7-9c02-5e366c54cecc	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:05:51.847	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
e840be04-985a-46eb-a93d-f23e48fb668f	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:05:51.864	down	18	connect ECONNREFUSED 10.0.0.200:3100	tcp
7d1decbe-ad24-4f3f-bea0-cdf91706abf0	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:05:54.837	down	3001	TCP connection timed out after 3000ms	tcp
0dbb38b5-3e09-45ec-bffc-db5525e20f17	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:06:21.857	down	3	\N	tcp
33d593f4-439b-4c95-9994-50ab33ac2bd6	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:06:21.859	down	4	\N	tcp
b0cca711-889c-4ec7-a09d-0e6fee09face	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:05:00.206	up	10	\N	tcp
99a09bc0-f36f-4b97-9c50-90bedf75dbeb	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:05:00.22	up	5	\N	tcp
1cb23e93-61e4-4285-8d60-3640dfa6150d	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:05:03.22	down	3002	TCP connection timed out after 3000ms	tcp
97d9c2b3-8824-4294-9f2a-dc00ae55e3a8	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:05:28.065	down	3	connect ECONNREFUSED 127.0.0.1:9020	tcp
11d609d5-bb18-409e-bdb8-080aa018e239	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:05:28.086	up	25	\N	tcp
8c6567ed-835b-4a25-b601-38b52ed29f13	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:05:28.088	up	27	\N	tcp
ffeee7a8-419f-4445-a726-378955a4a705	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:05:31.072	down	3000	TCP connection timed out after 3000ms	tcp
b31ddf72-9779-40c6-bf17-64e01b26701d	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:05:58.07	down	9	\N	tcp
153afe45-b93e-4010-9d4c-0ec5053b46fb	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:05:58.082	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
10d27235-0db2-4056-b728-ca6a992c5e1b	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:05:58.085	down	5	connect ECONNREFUSED 127.0.0.1:4100	tcp
a21c3bf7-d74f-4133-b3a4-24da604d5166	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:05:58.085	down	5	connect ECONNREFUSED 127.0.0.1:8020	tcp
64826d0a-3340-4c0a-9507-c274d4c54527	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:05:58.233	up	153	\N	tcp
2a95fe17-d50d-441c-9c51-b4dc33e5065b	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:05:58.236	up	155	\N	tcp
fe008f2b-1c12-48b2-b571-842c1a41b02a	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:45:40.442	up	7	\N	tcp
9d6a97ea-8c89-4f33-a66c-cd461330b02f	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:45:40.47	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
a930ac51-1541-4bf1-a518-1cadba9554f7	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:45:40.471	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
6eccfd43-622f-483b-8973-1c6c06d72362	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:45:40.474	down	0	connect ECONNREFUSED 127.0.0.1:4100	tcp
3ab10cba-742c-4d0c-a5c1-bc212510608c	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:45:40.481	up	13	\N	tcp
879db88e-7d60-46cf-a440-f956a527675f	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:45:43.468	down	3000	TCP connection timed out after 3000ms	tcp
f5a552a7-f3d5-403f-aa03-7abdf69ca12a	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:58:51.67	down	4	\N	tcp
f6a35fc3-43c7-43b5-bbc0-77ab4ad812a1	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:58:51.685	down	19	\N	tcp
15a3b707-341f-40f9-bab7-aa539380f7dd	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:58:51.671	down	5	\N	tcp
d5cad4c1-2c7b-4977-b981-cbe3cdac6d32	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:59:21.68	down	2	\N	tcp
b1386b8d-be42-4704-8b77-621382cc4d83	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:59:21.712	up	24	\N	tcp
8093ad33-2936-46fe-b0ac-0299f526c3e2	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:59:51.687	down	2	\N	tcp
905328b7-2f09-4392-b05d-d2d2d298b3b7	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:59:51.696	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
02141e3e-650a-4138-a5f1-52d69651fd8a	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:59:51.706	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
19821039-6a5a-4e1f-8f67-362532083a1c	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:00:21.724	down	2	\N	tcp
6be9e8ad-f21b-48be-a8ea-03503ba74282	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:00:21.727	down	5	\N	tcp
d6e120e5-b937-4d24-9fe4-6b3834758a06	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:00:21.734	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
67914723-4358-407a-b8a0-cba4e91224ea	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:00:21.742	up	9	\N	tcp
646a000f-446f-45f5-ab6d-4de949ed6a4b	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:00:51.741	down	2	\N	tcp
e7b1fa4a-5dda-4d69-af0a-96f0cf20e766	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:00:51.756	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
0ab5ccea-743a-4736-a9c1-2bd4c3f41cd0	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:00:51.776	up	18	\N	tcp
4915a5bf-807a-42d0-8a03-6bff985b9ae6	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:00:54.755	down	3001	TCP connection timed out after 3000ms	tcp
575c05e0-8785-45a7-94fa-6fea4e6faee2	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:00:54.755	down	3001	TCP connection timed out after 3000ms	tcp
7abf7e94-b963-4d34-b376-61c277ccbc15	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:01:21.774	down	3	\N	tcp
65b2895f-9d5c-4ce5-a3c0-aabcd07cf958	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:01:21.797	up	18	\N	tcp
ee2dd851-1d03-40fd-a9ae-1a56a71117ce	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:05:51.825	down	4	\N	tcp
9f2ee61c-0506-4d7c-9c2d-b77ea4bcf15d	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:05:51.839	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
7fcf8e26-d226-4a8d-a131-bef548ef1106	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:05:51.847	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
bfd65b93-c94d-471e-a5bb-e0d0a6303448	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:05:51.864	up	15	\N	tcp
159a9216-d20a-4a30-bf76-0c584ccd9ed4	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:05:54.837	down	3001	TCP connection timed out after 3000ms	tcp
96d3accb-c736-45aa-864a-9e0bb20a56cc	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:06:21.856	down	2	\N	tcp
65f18486-5acc-4fd6-b4e2-8c0d2cdc8ab7	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:10:01.202	down	3001	TCP connection timed out after 3000ms	tcp
61eaebaa-229b-48d9-8589-cfdb43d08091	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:45:40.443	down	7	\N	tcp
3edb0bcf-f0b0-40ea-9f05-083f0ae2e085	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:45:40.47	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
32937cd3-8cb8-43f1-9487-8513a31a6011	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:45:40.481	up	14	\N	tcp
e9e78442-2a4f-40da-bbdc-49e9ccea0c29	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:45:43.468	down	3000	TCP connection timed out after 3000ms	tcp
ba3cb4d9-f4f2-4b12-9c44-2f49b2a0ac25	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:58:51.677	down	10	\N	tcp
283628bc-3314-43b8-a129-34c78c653233	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:58:51.729	down	4	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
47528a65-6530-4046-9265-019309c3aa5a	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:58:51.735	up	9	\N	tcp
28178e92-67f9-4ec3-a4d6-0b6f14b204de	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:58:51.755	down	7	connect ECONNREFUSED 10.0.0.200:3100	tcp
00b6c1a0-be60-456f-8d0f-6d2ca3783441	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:58:54.725	down	3000	TCP connection timed out after 3000ms	tcp
37225c0f-a336-40ea-9690-4d5dcdf5f5d4	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:59:21.679	up	2	\N	tcp
ff6c45e9-9472-4f25-9da7-cec1086c3089	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:59:21.681	down	3	\N	tcp
a84738eb-6837-422b-a053-e4bbed0926b7	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:59:21.694	down	6	connect ECONNREFUSED 127.0.0.1:8556	tcp
fafae9c7-edec-4229-aef1-08af19e96cfc	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:59:21.713	up	25	\N	tcp
2eff30e2-cca0-4c52-afd1-8a32389100df	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:59:24.687	down	2999	TCP connection timed out after 3000ms	tcp
b9459776-460a-4334-9c22-f8827732d5e9	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:59:24.698	down	3001	TCP connection timed out after 3000ms	tcp
3b8ac799-8077-4894-88ea-cc307fdf971e	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:59:51.687	down	2	\N	tcp
df2614bc-aa29-496e-96bf-977051b2da47	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:59:51.702	up	7	\N	tcp
17c30cf9-f22e-4643-b1c7-b5bcf18fd9d9	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:59:51.706	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
c72b32bd-2794-4fd2-b175-7c654111bd3a	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:00:21.723	up	1	\N	tcp
96c89a4e-4c19-4a14-903f-3fe42bf8d727	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:00:21.726	down	5	\N	tcp
b9ec49b3-88f3-45fe-b24d-08d716c7e68f	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:00:21.736	up	2	\N	tcp
0fa709be-390b-4cf0-818d-bb80dc48eaf1	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:00:21.743	up	9	\N	tcp
8ffd5060-93ac-421c-a4b1-4ef1f5f71e99	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:00:21.746	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
6c39946b-b7f3-48d4-96a5-6272b4527235	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:00:24.734	down	2991	connect EHOSTUNREACH 192.168.1.222:8080	tcp
bb1f7b49-49e2-46ea-8b03-8ccf998cd5e1	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:00:51.743	down	3	\N	tcp
2dd7d5cc-7dc8-4527-ada1-7bd52e7f7812	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:00:51.744	down	4	\N	tcp
3452e961-c5ae-41b3-986c-90cdcc6dc018	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:00:51.756	down	1	connect ECONNREFUSED 127.0.0.1:8020	tcp
d4952865-7e7e-4159-a5bc-38f6ec6d5319	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:00:51.776	up	22	\N	tcp
de083969-eb6e-4ed4-a934-f0f213319440	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:01:21.774	down	4	\N	tcp
a3a9983a-9e62-454f-a005-dfe1b760f6d8	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:01:21.781	down	1	connect ECONNREFUSED 127.0.0.1:8080	tcp
2d2af28b-a804-4669-828a-1d675a44df50	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:01:21.781	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
668c342d-9e98-401f-b28f-d6b2a7db33e1	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:01:21.798	up	18	\N	tcp
dd7bb834-8cb5-4fbe-9dd6-9b83cd58bdd9	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:01:24.785	down	3001	TCP connection timed out after 3000ms	tcp
ee9d645b-eb97-47de-a268-f66dc03d048a	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:06:21.858	up	3	\N	tcp
0a3579c6-c6b2-4a71-9533-8d9084718b50	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:06:21.868	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
8fb59ef7-2938-495e-95a3-e537c8d1145f	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:06:21.901	up	36	\N	tcp
4423006e-7ccc-466a-a3d8-6c1065c607c1	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:06:51.86	down	2	\N	tcp
93862d71-1dbd-4b12-a4d1-8cd9aa0b3244	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:06:51.862	down	4	\N	tcp
12858378-3c2f-497a-81e5-8abd7bdd538f	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:06:51.861	down	4	\N	tcp
c6efe3df-0d76-436f-8550-0bad22f99980	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:06:51.883	down	2	connect ECONNREFUSED 127.0.0.1:8078	tcp
22a17794-42c5-487c-9eac-ca100a83236e	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:06:51.885	up	3	\N	tcp
7cbe31a9-57f4-4a1f-a960-8cb5a0c5714a	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:06:54.872	down	3000	TCP connection timed out after 3000ms	tcp
0e9a3e52-6aaa-425d-b67e-97558b68e071	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:07:21.868	up	5	\N	tcp
7b2f6c17-3bf3-4543-a6a2-d6c02e253ee8	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:09:21.946	down	1	\N	tcp
f900f0ab-2b1d-4355-b701-cd7825f38138	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:10:01.202	down	3001	TCP connection timed out after 3000ms	tcp
9dcb61ec-9e1a-4f60-a170-d531fc06f56f	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:46:51.291	down	4	\N	tcp
fc790345-6023-4dd6-ad63-2f9820ab10f7	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:46:51.293	down	5	\N	tcp
55c59629-4e9b-4899-9cd3-f016ceb08e58	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:46:51.295	down	6	\N	tcp
f98c2916-ce67-440a-aa72-34aa4b7a5264	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:58:51.67	down	4	\N	tcp
391abe12-69b2-40ac-a185-c561f2ee63c3	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:58:51.729	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
498021a6-7ab0-441f-ba89-d2a007066a91	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:58:51.736	up	11	\N	tcp
9f9f0e47-4f6e-477c-a1e0-0371f434bec0	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:58:51.754	down	6	connect ECONNREFUSED 127.0.0.1:8078	tcp
d3c23320-537c-4a49-9912-8861077f5665	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:58:51.754	down	6	connect ECONNREFUSED 127.0.0.1:9006	tcp
326b37c5-5934-4981-b3fe-08e1b8f564b6	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:58:54.726	down	3001	TCP connection timed out after 3000ms	tcp
d9461385-6e4c-4e40-afad-0f9c9d47c87d	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:58:54.737	down	2989	connect EHOSTUNREACH 192.168.1.222:82	tcp
5645b042-262a-45e1-86ed-ec026c8e0334	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:59:21.681	down	3	\N	tcp
73606c2b-333b-4b56-bb18-01dddd5b0928	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:59:21.694	down	6	connect ECONNREFUSED 127.0.0.1:8088	tcp
135e1d2f-97af-44e8-889e-b8250c2df3ea	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:59:21.712	up	25	\N	tcp
cedecf9a-7007-4ba1-8995-45823770bf5b	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:59:24.697	down	3000	TCP connection timed out after 3000ms	tcp
a8ed83e0-6246-4bd5-a255-ccbc5f799307	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:59:51.687	down	2	\N	tcp
90038c8c-b3cf-4fc4-b49b-a853d1814d70	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:59:51.706	up	7	\N	tcp
44328f1f-4581-42a1-9a50-973bf2b41706	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:59:54.695	down	3000	TCP connection timed out after 3000ms	tcp
2cd4abab-77b3-4e8c-8de6-ac564d300f10	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:59:54.699	down	3001	TCP connection timed out after 3000ms	tcp
99ca8e34-8101-4831-ad36-ce363b6d655f	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:00:21.725	down	3	\N	tcp
f3dfa571-ed68-4658-ac81-177c1a16d0a8	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:00:51.741	down	2	\N	tcp
40861972-8f1c-4923-bf7a-ff0fb1dcfc37	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:01:21.773	down	2	\N	tcp
5be14824-8697-4eb7-8507-81ca99ec444f	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:06:21.901	up	36	\N	tcp
7a56ef23-3e31-4633-91f6-cf66a3872971	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:06:21.902	up	25	\N	tcp
19df3d29-ab58-43e6-96c0-c595c7aa60de	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:06:24.866	down	3000	TCP connection timed out after 3000ms	tcp
cd0787bf-ea47-4e81-80fe-95e9f22d64ac	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:06:24.873	down	2999	TCP connection timed out after 3000ms	tcp
b1daca61-3843-4402-b7a2-86486ff30be0	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:06:51.861	down	3	\N	tcp
d13aeab6-0daf-43e7-916c-fcc6f08f06d8	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:06:51.874	down	2	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
dfc1ebdb-99ee-4914-b5c6-321621cb6ebb	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:06:51.877	down	4	connect ECONNREFUSED 127.0.0.1:8555	tcp
e10c7a6b-cd63-4fd5-ad33-4a8960a54f86	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:07:21.865	down	2	\N	tcp
f3e371d1-bfe6-4d85-8501-9b9559f351df	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:07:21.868	down	4	\N	tcp
226aab8b-92af-4b46-a651-10aaa5337fd8	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:07:21.877	down	3	connect ECONNREFUSED 127.0.0.1:8555	tcp
ffa458b4-fa57-4e2b-a2fd-a7592d75e4ac	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:07:21.885	up	5	\N	tcp
804b2bf9-e325-4458-ac21-b3a9bfd39a84	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:08:21.904	down	5	\N	tcp
7579bf54-402c-40c4-a1d1-5ca86e862ce8	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:08:21.914	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
0a75349b-65df-409b-a3ba-1c4cbe5807a2	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:08:21.94	up	19	\N	tcp
0248deae-7a6a-467f-9a48-6235a31967f1	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:08:24.911	down	3000	TCP connection timed out after 3000ms	tcp
5dd31425-13c5-4d91-a38e-db70078f85f0	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:08:24.913	down	3001	TCP connection timed out after 3000ms	tcp
e934439b-8a49-43f9-9943-40d989bbd789	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:08:24.922	down	3000	TCP connection timed out after 3000ms	tcp
286cbdbe-f336-415f-b1dc-e9d0ab39f8ca	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:09:21.948	down	3	\N	tcp
f29410cf-253e-4cb3-9ac1-77a48d5388ef	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:09:21.972	down	5	connect ECONNREFUSED 10.0.0.200:3100	tcp
97d33b3b-d0d5-4271-980c-8ec0be5168f9	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:09:24.955	down	2992	connect EHOSTUNREACH 192.168.1.222:8787	tcp
8ac1a3c6-d879-4b83-8738-06e764ed470b	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:09:51.979	up	2	\N	tcp
34a34839-49dd-4cf0-8b49-3e74173d427c	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:10:21.971	up	2	\N	tcp
8ce0bf51-d8fc-4ca7-99cd-7a52407523af	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:10:01.208	down	3000	TCP connection timed out after 3000ms	tcp
d8fe228b-6ad0-4bbd-833b-1e47024b4f50	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:10:01.21	down	3000	TCP connection timed out after 3000ms	tcp
0c3279ed-a736-4157-af15-2b8917898c69	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:46:51.296	down	7	\N	tcp
97ee8e12-23c2-4a95-a5c0-1b704d5d1f0d	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:46:51.293	up	4	\N	tcp
1a44e032-5979-4fd2-a630-c7023f8f7494	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:46:51.292	up	4	\N	tcp
59a57dd1-3197-4bcc-a1aa-7ec625209f32	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:58:51.673	down	7	\N	tcp
6e967ac7-0729-44fc-8973-970c0fce0276	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:58:51.729	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
0f226992-1fb4-4044-a91a-181fa69adc19	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:58:51.735	up	10	\N	tcp
70809f19-ea0e-458a-af19-d9a63dbe9d12	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:58:51.75	up	6	\N	tcp
e29b44fc-aabd-441b-8772-ad5e78b37fff	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:59:21.68	down	2	\N	tcp
d5c9f897-fa29-4e52-a479-dd0efcbce8e9	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:59:21.683	up	5	\N	tcp
2ab13c9c-310d-465f-86bf-3b8995081711	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:59:21.694	up	6	\N	tcp
6101fa6b-c8a6-4b09-aec8-f5be299979c1	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:59:21.713	up	25	\N	tcp
16051ae8-cbd4-4137-bb65-0fc1c41f63ad	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:59:24.698	down	3001	TCP connection timed out after 3000ms	tcp
108e08ec-5503-4839-a482-ad24b0046bdf	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:59:51.688	down	3	\N	tcp
d7134c2c-1f55-4799-a268-b19de1d8028b	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:00:21.723	down	1	\N	tcp
38ab973f-45f7-40a2-9043-87e0a91a1185	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:00:21.725	up	3	\N	tcp
54dd5fe1-37d9-4210-b52c-2625589bffd3	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:00:21.735	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
0b5118e8-638a-4e0c-a9c1-aed5d9111d45	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:00:21.74	down	1	connect ECONNREFUSED 127.0.0.1:8088	tcp
0d92e3d5-3e63-4466-b652-4f1f65b75afc	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:00:21.742	up	9	\N	tcp
70457269-3def-40ba-9cf4-10e005839994	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:00:51.741	down	1	\N	tcp
c3adc5f2-a107-4af5-8a81-65fa924dcb70	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:00:51.743	down	3	\N	tcp
a2c0a1a9-07fc-4c39-8ce0-a25ebb021f37	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:00:51.744	down	4	\N	tcp
f0ec9bd9-bd37-4364-8376-fdddb23b85ef	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:00:51.756	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
ddcfa782-d176-4141-becb-00e2b8ea9deb	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:00:51.775	down	21	connect ECONNREFUSED 10.0.0.200:3100	tcp
56b8da5b-03f1-4b24-9dd8-b8b3cfa45506	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:01:21.772	down	2	\N	tcp
22b7040d-1366-4c6a-b693-60a5d556f07e	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:06:51.859	up	2	\N	tcp
beb491bb-c3c4-4707-8d4d-209b61ecdc39	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:06:51.862	down	4	\N	tcp
16c0640c-a8b2-4d88-a258-b6bc374dfb88	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:06:51.878	down	5	connect ECONNREFUSED 127.0.0.1:8556	tcp
d05368db-595b-489d-a6bb-ac51a39f6cc9	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:07:21.866	down	2	\N	tcp
144e7198-b8f2-4b8b-868f-07d9e238d399	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:07:21.868	down	5	\N	tcp
0fcc17c1-e324-43cc-bc15-1c61ae734db5	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:07:51.898	down	3	\N	tcp
4435aa9d-e158-4aa8-bbfb-4d877f86e962	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:07:51.898	down	3	\N	tcp
0580ad65-be6e-4177-8adc-9be8838777b4	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:08:21.901	down	2	\N	tcp
6ecb8adb-939f-4807-aa72-8b9c008adcc9	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:08:21.904	down	5	\N	tcp
1121b49b-9ce9-4132-9485-167be1466435	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:08:21.914	up	2	\N	tcp
dffb3abf-7565-4f16-bec9-e6bb12c5041e	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:08:21.939	down	19	connect ECONNREFUSED 10.0.0.200:3100	tcp
87240a9d-b406-4fa1-a8e4-6ffabac79d42	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:09:21.948	up	3	\N	tcp
4b7556c4-d0e8-48b5-aea8-02639dafaf69	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:09:51.978	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
8c1d0e46-325c-4590-b7db-e45d98f46e5d	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:09:51.984	up	7	\N	tcp
b4ddb6c0-582e-4c09-b224-826d82438b94	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:09:51.989	up	4	\N	tcp
016695c3-0766-4ee3-9f43-ab79514021aa	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:09:51.993	up	3	\N	tcp
57374609-a48e-4074-a3c1-e0a41250359b	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:09:54.976	down	3000	TCP connection timed out after 3000ms	tcp
767c3303-1e49-424c-855a-41aee6e0cbcc	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:10:21.973	down	3	\N	tcp
c699bc3c-23eb-4f58-a5d7-4feebbd3757c	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:10:21.983	up	2	\N	tcp
1d647ac2-f388-48cd-9d46-164ad8dbe8f2	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:10:21.983	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
831573f1-698d-4e3d-ba5d-e0b711fdc64a	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:10:01.209	down	3000	TCP connection timed out after 3000ms	tcp
175b544c-5e27-4b84-aa96-b8540a6f215e	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:46:51.297	down	7	\N	tcp
a737b2f9-d37c-4f3b-9557-8839de943ccc	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:46:51.297	down	8	\N	tcp
00b9a633-b640-484a-b2bc-defafc497451	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:46:51.344	down	4	connect ECONNREFUSED 127.0.0.1:8088	tcp
b49c7e7d-d447-4b2b-89d8-5dc8c983e520	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:46:51.349	up	9	\N	tcp
98784e81-4da3-42f5-a9fd-6fa95b7baccc	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:46:51.355	down	4	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
97f5626f-4f54-4577-813a-0071788617fa	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:58:51.671	down	5	\N	tcp
0e4ca788-c9ab-4c17-ab5d-f5f3a30f98c3	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:59:21.68	down	2	\N	tcp
966e0371-1174-422f-a6c2-ad1081182022	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:59:21.683	down	5	\N	tcp
58e5fd14-465f-4054-aa9b-6b80ed553ba1	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:59:21.694	down	6	connect ECONNREFUSED 127.0.0.1:8020	tcp
e38cfa8b-7476-457e-9911-c29d0142a636	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:59:21.712	up	24	\N	tcp
84d2c6db-c002-4377-98c5-4438de170c74	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:59:51.686	down	1	\N	tcp
d780b017-2ee2-475b-9b28-c8c7b90fd86e	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:59:51.688	down	3	\N	tcp
43732971-8019-4ae4-a7ad-b5a5cc7c8d8e	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:59:51.696	up	2	\N	tcp
c64c95ea-5c4e-4bea-9d37-f1dddfbc40d2	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:59:51.697	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
30f7aed0-eece-48ff-b3ad-eca442ba89e1	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:59:51.703	up	8	\N	tcp
41272f65-4484-4e07-ab23-4d4e1566836a	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:59:51.702	down	8	connect ECONNREFUSED 10.0.0.200:3100	tcp
da34c6be-e16b-475e-9129-6a07ea8e2ab1	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:00:21.724	down	3	\N	tcp
9b997765-cacd-4636-80f2-514f2d7c77ab	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:00:21.727	down	5	\N	tcp
a05bb848-4dc7-45ea-9df0-7d788a09bfc9	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:00:21.736	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
632719d8-8e47-4659-a9dc-9947e97c812f	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:00:21.74	down	1	connect ECONNREFUSED 127.0.0.1:8555	tcp
9730effa-0758-4b18-af10-55f8d551637a	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:00:21.742	up	9	\N	tcp
538a514d-6093-4206-94b5-17a773e0cb63	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:00:21.746	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
a665dce3-2f13-47b8-907a-37f7891ab8ac	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:00:24.733	down	3000	TCP connection timed out after 3000ms	tcp
3aed15c6-c56f-494d-93d1-11b3c1d5417f	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:00:51.742	down	2	\N	tcp
a8a65f13-178c-4be9-b9b8-9abd60c586f0	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:00:51.776	up	18	\N	tcp
7522ea52-ec01-46cb-860a-85a45677c1f5	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:00:54.756	down	3001	TCP connection timed out after 3000ms	tcp
ac75be7f-6e07-4611-a15f-42c63f2dd244	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:01:21.772	down	2	\N	tcp
b74a72d4-e7f3-4fb6-9caf-79ea9d78c505	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:01:21.775	down	4	\N	tcp
c0f0a666-ec39-40bc-bdd8-d77d0a0da5ca	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:01:21.782	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
6b7b5a87-86e3-402e-8d93-ce1a0e81ba8c	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:01:21.785	down	0	connect ECONNREFUSED 127.0.0.1:4100	tcp
547b376a-1c76-4939-be35-cd83dc135f98	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:01:21.787	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
b9ac36d6-6910-455e-8045-9b4a6af2614b	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:01:21.788	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
baeedc9c-220f-4eec-8ff5-1f3ee1ebf47f	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:01:21.79	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
44f2d427-3c09-4394-8428-d742ed45e338	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:01:21.792	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
40f7df3b-eec2-411e-947c-d20e79f19701	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:01:21.793	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
33c42c2e-0d31-47b9-abf2-a3c6fa823469	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:01:21.798	up	18	\N	tcp
b7689ad0-cf3d-46c7-beae-df4567df8315	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:01:21.799	up	14	\N	tcp
79152c00-1582-43fe-8e18-b7079dfb8bcd	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:01:24.779	down	3000	TCP connection timed out after 3000ms	tcp
87ee1c9a-712c-4a73-b610-fadb3e592782	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:01:24.783	down	3000	TCP connection timed out after 3000ms	tcp
d3e3fb38-f2af-4149-a896-d816ad21bb9c	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:06:51.861	up	3	\N	tcp
07003a05-28d4-441d-b31f-bcf104b882a0	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:06:51.876	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
02c8d56b-b2a7-42cc-805d-b143fb6f46c0	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:07:21.865	down	2	\N	tcp
8bc64649-e9ca-47be-924a-ff11fa6e645b	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:07:21.868	down	5	\N	tcp
27be23ad-7dfc-47f7-9e5d-62f5d5b2edb5	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:10:01.209	down	3000	TCP connection timed out after 3000ms	tcp
ede02ec8-0582-4716-8972-a6bb63531e80	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:46:51.297	down	7	\N	tcp
fc0ae1d0-d2ae-4341-bf0c-118c39fc505d	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:46:51.298	down	8	\N	tcp
7a34f723-24f1-41da-a0d9-a03187ab5f17	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:58:51.676	down	10	\N	tcp
5349d3ac-b502-489a-aea6-e893d543df31	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:58:51.729	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
c680db7e-c007-4087-8552-5df8a79ebb1e	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:58:51.735	up	10	\N	tcp
36f9bfd9-772a-4aa6-b0de-30adba207ca0	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:58:51.754	down	6	connect ECONNREFUSED 127.0.0.1:9000	tcp
3f0f01dc-fc81-4fb2-9231-1eae38654457	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:59:21.68	down	2	\N	tcp
be659620-a04b-4d3f-aa67-edccf0dab97b	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:59:21.681	down	3	\N	tcp
4d154a49-3ca6-4989-85fe-437647ff6c7c	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:59:21.695	down	7	connect ECONNREFUSED 127.0.0.1:4100	tcp
0564f15a-55ad-4af6-bb9d-62be13a8f52f	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:59:21.712	up	24	\N	tcp
b3b3229f-afb9-41cf-83b3-b307095a2b32	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:59:51.687	down	2	\N	tcp
9952248a-2d6d-4ec6-99c1-ecb819316a53	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:00:21.724	down	2	\N	tcp
a337cf6b-ccf0-41bd-b275-9158c57254fb	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:01:21.773	down	2	\N	tcp
43324df8-ce41-43ad-acc7-86538c65b95c	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:01:21.782	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
11a821ca-0186-46b0-9b4f-5a417d14cdcc	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:01:21.785	down	0	connect ECONNREFUSED 127.0.0.1:8556	tcp
03d82f25-9efa-4de0-a62e-7bf8eb7aeae4	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:06:51.883	up	10	\N	tcp
56281ad8-93b9-4cd9-abf5-c884417d8659	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:06:51.884	up	3	\N	tcp
f0c2b92c-423f-43fc-8190-4948426d670b	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:07:21.865	down	2	\N	tcp
d08c46bd-212c-4d73-beb5-1698bf5e6ee2	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:07:21.877	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
fd155984-7ece-4271-a05a-f8e5b97b522b	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:07:21.885	up	5	\N	tcp
72bcfdc5-ea0c-4cf1-a9cc-a4a95e11c402	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:07:51.899	down	4	\N	tcp
b41bcbd0-eaa2-4a92-a7e4-dd38c10af7eb	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:07:51.906	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
8c21c739-3a24-4af4-9547-d45fc482ce0c	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:07:51.912	down	2	connect ECONNREFUSED 127.0.0.1:9001	tcp
309a8007-c8e5-4a36-97be-32dc5038cf33	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:07:51.913	up	7	\N	tcp
33a4d156-5052-499f-b7c0-3d047d84aa4e	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:07:54.906	down	2991	connect EHOSTUNREACH 192.168.1.221:8180	tcp
ac29d480-8de4-410a-89a3-0f6d9202e724	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:08:21.902	down	3	\N	tcp
a5de618b-a250-41dc-80dd-0c9693d5cfb5	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:08:21.905	down	6	\N	tcp
595e8fbf-486a-407e-a5d7-1f17d91c9215	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:08:21.913	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
156cdf23-e64a-4596-9831-826a2d61b6c6	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:08:21.939	up	27	\N	tcp
ae81042d-5f3f-47fd-abdb-48d6a47f0988	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:09:21.948	down	4	\N	tcp
18a4b37a-915a-4ea0-927a-51bd91ea4099	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:09:21.958	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
5f545071-f639-4b76-912e-ce796361d60f	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:09:21.96	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
9ea2858c-e2af-47ff-b858-5de11c35a03b	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:09:21.964	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
16160c3c-3b08-4b7c-9c07-57e68beaaa33	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:09:21.972	up	5	\N	tcp
f181ea12-deb0-4df9-9d47-699cddeeb706	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:09:51.984	down	8	connect ECONNREFUSED 10.0.0.200:3100	tcp
e4a952c2-d75a-4045-88e6-6380d7c686d9	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:09:51.988	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
f26bdb80-48a8-4eda-9eff-a50ce27c1bb9	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:09:54.977	down	3000	TCP connection timed out after 3000ms	tcp
1c8ac7a2-571a-4eb5-b753-58d908981410	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:09:54.987	down	3000	TCP connection timed out after 3000ms	tcp
11a09190-ec8d-4660-a170-6116373b9a37	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:10:21.971	down	2	\N	tcp
cd091c2d-1221-4a30-ad82-d616886cb9a4	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:10:21.982	up	2	\N	tcp
0f1ab551-9241-4fbf-aa9f-ae91cdbdcbd3	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:10:21.983	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
4b03d8f7-b76c-4437-9f6d-5144c7e9c464	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:10:21.99	up	9	\N	tcp
9e962e15-afca-4f62-8712-10854e431a41	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:10:21.99	up	5	\N	tcp
38aed0ef-3ec8-4fd4-bb6b-6c8a4b72ca66	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:10:21.993	up	4	\N	tcp
ca6f63f2-0fac-48d4-a908-b65598ddab7d	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:05:00.203	down	10	connect ECONNREFUSED 127.0.0.1:9006	tcp
5a4c9d56-aa8b-4666-9e66-20e7e78bdfe1	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:05:00.221	up	6	\N	tcp
aafeb5b1-ba28-43bb-bb34-7735eb4dc107	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:05:03.216	down	3000	TCP connection timed out after 3000ms	tcp
c1f65030-a371-47e3-85b4-b689ade973ea	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:05:28.047	down	7	\N	tcp
b21a979f-ca41-4c6e-bf51-08c08403d865	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:05:28.064	down	3	connect ECONNREFUSED 127.0.0.1:8555	tcp
e044d587-2ec1-40af-9826-c4f18f9e5883	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:05:28.089	up	27	\N	tcp
e46d37a0-6683-45a4-8088-61059d1b2f88	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:05:28.096	down	1	connect ECONNREFUSED 127.0.0.1:7000	tcp
b24df0f3-7564-494c-8eb5-2a9ff0555d5d	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:05:31.071	down	3000	TCP connection timed out after 3000ms	tcp
03e8435c-5246-454e-a51a-f1c18473ee69	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:05:31.073	down	3000	TCP connection timed out after 3000ms	tcp
9444e3a3-85fd-4123-a35d-63a8fab5c276	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:05:58.065	down	4	\N	tcp
8a99106d-94df-4c36-9355-00ada2646c8b	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:05:58.067	down	6	\N	tcp
67b2b77e-d5d9-4be9-9682-9f986000e188	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:05:58.07	down	9	\N	tcp
fdbd560d-9d98-434d-8746-16080a365dd0	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:05:58.084	down	4	connect ECONNREFUSED 127.0.0.1:9000	tcp
9e90db2e-1138-4c08-9864-3264c8ff164c	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:05:58.234	up	153	\N	tcp
975bacf0-00b2-4ec8-86e4-f967447e0fd6	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:46:51.295	down	6	\N	tcp
470825bc-0cb8-4ffe-a97e-c48bc4f5ccd9	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:46:51.296	down	6	\N	tcp
31a00b1d-36fe-4ef0-88da-802f576d09cb	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 05:46:51.343	up	2	\N	tcp
36e1b4f2-c1e5-4a86-9a5f-160a66b4d06d	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:46:51.35	up	9	\N	tcp
68b558c9-4d29-4b18-985e-b84658e5cc25	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:46:51.358	down	2	connect ECONNREFUSED 127.0.0.1:9000	tcp
d73fff4b-3ac9-4ed2-a241-bced4462f8a4	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:58:51.67	down	4	\N	tcp
12e5203b-a607-4462-b28e-ed16a8032ecd	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:58:51.738	down	1	connect ECONNREFUSED 127.0.0.1:8088	tcp
ace5c8d0-9e19-4dbf-855b-0ad80877bde0	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:58:51.754	up	9	\N	tcp
6410b0a7-fbb4-4c04-861e-6df759e73b35	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:58:51.755	down	4	connect ECONNREFUSED 127.0.0.1:9020	tcp
aa8b63c6-64da-456b-8dd5-813f5ce7700f	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:58:54.726	down	3001	TCP connection timed out after 3000ms	tcp
66ba489d-3e20-4578-946c-81287765b037	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:59:21.679	down	1	\N	tcp
bd94d5a8-179d-4858-91c0-66a93d8b20ed	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:59:21.712	up	24	\N	tcp
9f6b6950-2bf9-44a4-831e-a910046ac7cc	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:59:51.688	up	2	\N	tcp
7c8b078c-8cf4-435e-ad77-ab6cb2dcabf4	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:59:51.706	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
aa5d3881-e9ed-4607-8d94-13ff6cfce233	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:59:54.695	down	3000	TCP connection timed out after 3000ms	tcp
f08f6c57-d060-4d1d-befc-ebfd651d486f	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:59:54.699	down	3001	TCP connection timed out after 3000ms	tcp
e302d86e-2f28-44d5-9cd6-e6a3073af801	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:00:21.724	down	2	\N	tcp
df1587f9-97d6-417a-8ac3-2a190697a930	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:00:51.743	down	3	\N	tcp
4dbda3eb-56dc-41b6-8d01-f40f850b620a	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:00:51.744	down	4	\N	tcp
c9884eb5-3d6c-4c77-be6a-241cfd570178	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:00:51.755	down	1	connect ECONNREFUSED 127.0.0.1:8088	tcp
5ef78a1b-cd4e-4946-9c8e-0eacd8befb53	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:00:51.775	up	21	\N	tcp
f4f69318-ae97-45b3-a93e-8f4c5ad6f103	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:00:51.777	up	19	\N	tcp
1ae452b0-110d-49ed-8a7d-af27eeeaf247	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:00:54.759	down	3000	TCP connection timed out after 3000ms	tcp
b374113b-b4bb-406a-812b-8b5e20d73c7a	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:01:21.774	down	3	\N	tcp
73ee8088-3d01-40bd-be4b-559df32aef3c	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:01:21.798	up	18	\N	tcp
33f66a70-59d3-4e67-a2c3-a923ee23d483	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:01:21.798	down	18	connect ECONNREFUSED 10.0.0.200:3100	tcp
d3b21217-c858-4c51-9e51-2a45effd2d1b	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:01:24.783	down	3000	TCP connection timed out after 3000ms	tcp
25f92675-243d-4703-874c-f8da1bd50e59	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:06:51.884	down	2	connect ECONNREFUSED 127.0.0.1:9020	tcp
2758da2c-0154-4d9e-b39f-374f99c8b2b1	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:06:54.873	down	3000	TCP connection timed out after 3000ms	tcp
f1dfc41a-187b-4733-91f3-918b73720007	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:07:21.867	down	3	\N	tcp
980b964b-97f3-4da5-b7d0-bae7dc61c0c1	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:10:28.195	down	3	\N	tcp
af222490-58d8-4d6f-b152-0ef96be1ecd3	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 05:10:28.194	down	3	\N	tcp
feb4e7a8-75e3-4f1a-8567-3ca0c23e54aa	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:10:28.202	down	10	\N	tcp
c08523e9-9120-4bd7-9adb-5d9ca89515d5	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:10:28.196	down	4	\N	tcp
01b2b795-10fb-4b0b-80c3-1605ef699b05	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:10:28.197	down	5	\N	tcp
6a8b1573-086f-4d7d-8cf0-39989d2273ce	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:10:28.242	down	4	connect ECONNREFUSED 127.0.0.1:6875	tcp
0836ecd5-3764-4c2d-accc-5e8d5c5aab9a	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 05:10:28.27	up	20	\N	tcp
74d64028-1361-4ea4-b2fd-961388f8c7b0	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 05:10:31.239	down	3001	TCP connection timed out after 3000ms	tcp
bf2833cc-a57b-4975-b1fd-fbb8051594a8	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:10:58.24	down	4	connect ECONNREFUSED 127.0.0.1:8078	tcp
eb39487a-be0c-4550-a52e-529b8c256165	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 05:11:01.221	down	2999	connect EHOSTUNREACH 192.168.1.221:8180	tcp
60bb1426-81d1-49d4-b211-41e32e158941	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:11:28.231	down	3	\N	tcp
0efce2cd-7e47-4f5f-a103-c784c9dc6026	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:11:28.234	down	6	\N	tcp
c75f1393-cb50-4570-8049-448417e85a74	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:11:28.249	down	3	connect ECONNREFUSED 127.0.0.1:8555	tcp
911435c7-8626-4289-ab27-6a1952b94aa3	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:11:28.252	up	7	\N	tcp
f973be65-c708-4d45-9499-31fd76a2d00d	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:11:58.259	down	5	\N	tcp
a278175e-ae4e-4d45-9c2e-51e925efd9d2	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:11:58.262	down	7	\N	tcp
8f32f361-c97f-4ce9-ab45-56693f310aea	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:11:58.276	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
6159a916-d867-45f5-a44e-41adfed36bab	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:11:58.28	down	0	connect ECONNREFUSED 127.0.0.1:8556	tcp
f39f245e-f781-4994-9035-5adad0462623	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:11:58.281	down	1	connect ECONNREFUSED 127.0.0.1:7000	tcp
227c781b-deba-4aca-adb5-a6614fe297f2	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:11:58.284	down	0	connect ECONNREFUSED 127.0.0.1:8555	tcp
7dfbe19f-9693-41cd-9e81-9def5039ebfd	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:11:58.365	up	92	\N	tcp
e2c9e3a9-1275-440f-a410-87c586199a7b	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:46:51.293	down	5	\N	tcp
dfd6f855-7d0e-4e20-a018-6f03afb8dd66	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:46:51.294	down	6	\N	tcp
c0c686f1-86ef-4610-97f8-cec60d848287	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:46:51.344	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
1369f498-ea3c-4dbd-8cc1-c17faf113aa2	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 05:46:51.349	up	9	\N	tcp
294eab8c-c350-4033-853a-4abc95c39cb1	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:46:51.358	down	2	connect ECONNREFUSED 127.0.0.1:9001	tcp
2a877c67-fa13-42df-8e6e-46eb2191c199	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:58:51.728	down	3	connect ECONNREFUSED 127.0.0.1:8555	tcp
cc47fc32-38a7-46c3-8a62-947ffdc7261c	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:58:51.755	up	8	\N	tcp
cd510e6f-0a39-4115-8283-b6bbf7049437	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:59:21.68	down	2	\N	tcp
c6b4cf70-09ad-44a7-ac1e-78f5e7f3d46e	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:59:21.713	up	25	\N	tcp
c3f39082-d0da-4926-a2fe-eb006ac1cc6b	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:59:24.698	down	3001	TCP connection timed out after 3000ms	tcp
352c75b7-244f-4721-b2e1-d7afc01d0958	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:59:51.687	down	2	\N	tcp
e16a6f0b-8aee-4da5-9a42-abae02417b49	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:59:51.69	down	5	\N	tcp
80a2227b-98ce-4c84-bbd3-baea99a8ace6	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:59:51.697	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
d28fddac-c8e4-4405-8a7a-3d68487c0a74	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:59:51.699	down	0	connect ECONNREFUSED 127.0.0.1:8080	tcp
eec03878-9b65-4692-815c-c7e7c51a8052	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:59:51.701	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
4b64c20e-04bf-4c4b-93bb-93e73d73770c	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:59:51.706	up	6	\N	tcp
2f5d2fc6-f67b-42ca-bd41-dcc3c834a840	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:00:21.725	down	3	\N	tcp
2e5dd91c-b53c-4169-8d29-21d8cf963954	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:00:21.735	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
a806e529-434f-4a22-80a0-9ab3200d9140	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:00:21.74	down	1	connect ECONNREFUSED 127.0.0.1:8556	tcp
355d3a83-e6fc-425c-9904-6ee14ec222db	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:00:21.743	up	9	\N	tcp
5a2d2dd0-73f5-45ba-a12d-dabac5037f4f	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:00:21.746	up	6	\N	tcp
9b5abcf5-4b54-4131-8d06-b9636dc27439	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:00:24.733	down	2999	TCP connection timed out after 3000ms	tcp
fac24832-db85-4636-bd55-2c76bca85de5	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:00:51.742	down	3	\N	tcp
f99dd2f7-7cfd-4884-b29b-7ed42d4c334c	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:00:51.743	down	4	\N	tcp
3e558b0e-c9f2-4292-a858-a6558a37d828	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:10:28.196	down	4	\N	tcp
7c26b882-910c-4bb3-8794-73699da070de	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:10:28.202	down	10	\N	tcp
9828a33b-7438-4c47-9a05-8ffd0efcb0ad	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:11:58.26	down	5	\N	tcp
81787fdf-f3cb-4373-b3cb-d5ab1e99f5b2	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:11:58.264	down	9	\N	tcp
5864a222-d4c9-4de7-a916-2587bce5c755	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:11:58.364	up	91	\N	tcp
2c2e5660-4978-40b1-9462-d5ca93b3733a	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:46:51.294	down	5	\N	tcp
60b8cc50-fdb6-48a2-8c5e-571202ded82b	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:46:51.344	down	4	connect ECONNREFUSED 127.0.0.1:8080	tcp
2fd0adeb-2682-46d4-aac2-e5089a58875e	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:46:51.349	up	9	\N	tcp
d86c9147-0181-49d7-8024-73e4c012fe5a	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 05:46:51.358	down	2	connect ECONNREFUSED 127.0.0.1:8078	tcp
0e12eb51-04f0-4dd6-b81d-eed6ec71a5ba	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:00:51.755	down	1	connect ECONNREFUSED 127.0.0.1:8555	tcp
d5783ef8-c454-46e9-809d-0637304afa98	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:00:51.776	up	18	\N	tcp
f6879580-2cfe-4558-bccc-77dbedda7d73	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:01:21.772	down	1	\N	tcp
45600e40-ca93-4e51-8c1a-afd274ee3753	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:01:21.774	down	4	\N	tcp
d3a9bd3a-6010-45e7-92b0-bf4426ec339d	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:01:21.781	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
36a33254-defe-4078-80ff-b670b6a3baa0	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:01:21.798	up	19	\N	tcp
3ec62a61-67b5-49d2-82c0-6ad650aeb8b6	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:01:24.784	down	3000	TCP connection timed out after 3000ms	tcp
f06c866f-d1b4-459a-9fb0-c2ce7a6edd79	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:07:21.875	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
6e8158e6-df35-4c88-a8ca-7e5e304c378a	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:07:21.877	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
9a6985a7-29e2-4ae7-9b89-f25cc54580ed	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:07:21.881	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
fc524d17-cbeb-4b4c-a550-61d8c833849e	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:07:21.885	down	5	connect ECONNREFUSED 10.0.0.200:3100	tcp
b8606e01-f991-49e1-9f79-b9ce5ad5e7b4	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:07:51.896	down	2	\N	tcp
5bd0c0be-975a-4002-b343-d004cdfae041	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:07:51.898	down	3	\N	tcp
f61c0384-b971-44e6-8e3f-4429df25b0c0	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:07:51.907	down	1	connect ECONNREFUSED 127.0.0.1:6875	tcp
fb835e30-4bc1-4fa5-8c3b-a806fe482dd4	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:07:51.912	up	7	\N	tcp
599d7f13-f007-4522-9a6e-979b6cf20c6c	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:07:51.914	down	4	connect ECONNREFUSED 10.0.0.200:3100	tcp
98f32fd9-3239-44d5-aa11-21cb01acfb6a	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:07:54.906	down	3000	TCP connection timed out after 3000ms	tcp
8ca9a5c2-304a-40fe-8c16-21c6fff38ed2	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:08:21.902	down	3	\N	tcp
58c4dc22-6085-42d0-8048-102613fb28a4	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:08:21.905	down	5	\N	tcp
008aab8b-9071-4115-94ec-780cb1ed86aa	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:08:21.914	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
914b2d01-8c5a-4b17-b95c-0e701155aade	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:08:21.939	up	27	\N	tcp
7199ded0-1a18-4be8-bbd2-db043d70207d	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:09:21.959	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
4efa357e-cc16-49a0-a55c-b121970fcd37	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:09:21.971	up	9	\N	tcp
6b2e27e2-77bc-463c-a236-51b4013c1e8f	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:09:24.955	down	2998	connect EHOSTUNREACH 192.168.1.222:8080	tcp
8dba86a8-4d11-4e3f-9521-a54e233a1f3f	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:09:51.988	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
acfe8888-34a3-4b1b-88b0-8bef8442350c	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:09:51.991	up	4	\N	tcp
9d6124f2-c563-44d7-bc15-e38bcbe7b1a2	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:10:21.972	down	3	\N	tcp
db8189fe-0577-4dd9-9792-fab0d8b7ab4e	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:10:21.973	down	4	\N	tcp
01ddb41e-0a0f-4dd8-9f9a-cf0ab80c0e9e	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:10:21.983	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
fa71aeed-c3d5-4b05-acab-a26cac92e5c2	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:10:21.983	down	3	connect ECONNREFUSED 127.0.0.1:8555	tcp
d52cb6cd-73c0-4572-8aaf-c950467bf266	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:10:21.987	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
f4f3d912-550c-43e5-82f2-f53151002922	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:10:21.989	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
ad670903-122e-4a22-ae06-59c2e4fbbd7c	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:10:21.99	up	9	\N	tcp
7179f58a-8220-4508-87df-8d597784f63e	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:10:24.981	down	3000	TCP connection timed out after 3000ms	tcp
e6011c01-ca6f-45bf-9678-07c225828b30	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:10:24.986	down	3000	TCP connection timed out after 3000ms	tcp
a33b44da-46e0-4672-b98c-69333418286f	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 05:10:28.2	down	8	\N	tcp
ca51ba4b-6294-4fc1-b04e-5666c7ac2fd5	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:10:28.196	down	4	\N	tcp
d941f0c0-81b1-4338-b9e2-98c1ef232fe0	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:10:28.242	down	4	connect ECONNREFUSED 127.0.0.1:8556	tcp
60f4abc9-c88f-4888-ab65-4ea0b79428ce	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:10:28.268	up	31	\N	tcp
c98cb3da-3a6d-47d5-bbac-23c08efb1c09	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 05:10:58.204	down	2	\N	tcp
0e1c4c49-f386-4f79-a441-568d0d6b438b	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:10:58.207	down	4	\N	tcp
bf4ed312-2edc-4aec-9279-6bc772184c36	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:10:58.209	down	7	\N	tcp
6647ffa2-bf53-47d2-a2e9-d06981850c7c	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:10:58.227	up	6	\N	tcp
022c5c6d-571f-4e0e-a597-b50d454a484d	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 05:10:58.229	up	8	\N	tcp
3ed8db16-a287-4cf6-a44f-0b76a3a8049b	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:10:58.238	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
f572a1f4-016b-4eb4-81df-9bde214c4dad	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:10:58.24	down	4	connect ECONNREFUSED 127.0.0.1:9000	tcp
3194a5e3-876e-453f-ae52-18c1760f153d	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:11:28.231	down	3	\N	tcp
219487cc-d004-4b55-a9d9-4c02940c7ccb	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:11:28.233	down	5	\N	tcp
bc9f1246-0aee-475c-96f8-a3cf12d9a204	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 05:11:28.237	up	8	\N	tcp
3887d0c6-0c96-43db-a16e-3a117b31db30	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 05:11:28.248	down	3	connect ECONNREFUSED 127.0.0.1:8080	tcp
3ea09291-4f1e-43bf-bb79-6ad3cc131af7	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:11:28.252	up	7	\N	tcp
da768a1f-90ee-4ead-af31-e05929ac2374	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:11:58.257	down	3	\N	tcp
f78b7e3b-e376-4fbb-b75d-c46be0c16ab4	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:11:58.261	down	6	\N	tcp
fbd81fae-7292-4cbc-b9ec-315d6c5faf9c	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:11:58.362	down	90	connect ECONNREFUSED 10.0.0.200:3100	tcp
ddf9ef03-ebae-4bdd-90bd-05cbacfdbdd9	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:46:51.295	down	6	\N	tcp
f1aeb88f-5560-44fe-8c36-d8a3faa14d84	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:46:51.294	down	6	\N	tcp
db7721ad-b5f7-4e37-a3e1-edd65486271a	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 05:46:51.343	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
b54872d7-f0f7-414d-b392-fc558ab9bf6f	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:46:51.349	down	8	connect ECONNREFUSED 10.0.0.200:3100	tcp
9ffcee84-3cd9-455a-810e-a9bb474669ea	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:46:51.357	up	7	\N	tcp
92906eb9-97d6-459b-888c-528eb9cfdb17	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:01:21.774	down	3	\N	tcp
2c6bd97c-3cb0-46be-9588-acadf68290d9	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:01:21.781	up	1	\N	tcp
10442ca8-2392-45ac-8892-95585f51af50	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:01:21.797	up	18	\N	tcp
1af83864-28ae-48c3-95ad-88452eeec147	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:07:21.876	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
3d342406-1694-4ca3-9f0c-cab8727a4c68	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:07:21.878	down	3	connect ECONNREFUSED 127.0.0.1:9000	tcp
b8916cfa-1fc6-4066-9420-4171f471c069	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:07:21.881	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
14edd5f7-5eae-44c9-92d8-70c52db03d93	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:07:21.885	up	10	\N	tcp
551f969d-3a44-477d-960e-b3a094432c74	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:07:51.907	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
9c9c7ba7-954e-4dd7-a67d-d2e813a29551	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:07:51.908	down	3	connect ECONNREFUSED 127.0.0.1:9000	tcp
3edcdb6f-69df-4167-b192-543deac2a953	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:07:51.912	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
ef82edec-b99a-407c-8714-fd908d67a238	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:07:51.915	up	4	\N	tcp
69f3b9d1-86a5-4516-8e01-817a72291ee4	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:07:51.922	up	9	\N	tcp
e77523ac-fbe6-4fd4-b5e6-eab42f57e695	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:07:54.906	down	2991	connect EHOSTUNREACH 192.168.1.222:8787	tcp
d21433cf-13aa-443f-8b0e-751f4742c884	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:08:21.902	down	2	\N	tcp
0e1de319-8818-4acb-9f16-a6b56dc91459	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:08:21.905	up	5	\N	tcp
34b95c10-9204-4b74-bb6c-673e1397e200	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:08:21.914	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
ff75945b-b97b-4d24-bf02-e6f3edfbe1b5	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:08:21.94	up	19	\N	tcp
537de154-a646-4cc4-9712-63871a5d8dcc	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:08:24.921	down	3000	TCP connection timed out after 3000ms	tcp
9802dc75-d19c-4eda-862a-e78777edb94a	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:09:51.964	down	1	\N	tcp
e7031ac8-ef98-4b5b-8485-7948be3c2846	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:09:51.966	up	3	\N	tcp
45dda962-319f-45b2-bd67-3e1358dffee3	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:09:51.988	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
6b4f05c1-5204-4047-9602-2476264a4ea0	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:10:28.198	down	6	\N	tcp
c739c0f9-9a2e-43ff-9cdd-1d1287dfb70b	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:10:28.203	down	10	\N	tcp
2db8a6c4-9ed6-4ad3-9ad6-e57618537309	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:10:28.268	up	30	\N	tcp
6fc0e7b3-77f8-4b6f-b795-2958cf94d2ec	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 05:10:58.206	down	4	\N	tcp
7f7dfa48-f8b1-44ae-a978-98841419d6f0	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:10:58.208	down	6	\N	tcp
6ae8e54e-c11a-4314-a261-35bf50286a74	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:10:58.211	down	9	\N	tcp
9d77d242-ed72-440d-9807-438f2793925f	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 05:10:58.223	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
1eb1e94f-d0c6-4ec9-b4dd-d4b9eb41d52f	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:10:58.227	down	6	connect ECONNREFUSED 10.0.0.200:3100	tcp
a6e129c2-5eae-40b3-9569-e3174ea18677	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:10:58.228	up	7	\N	tcp
413f216f-1e6e-434e-a579-47de8a27dccc	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:10:58.239	down	4	connect ECONNREFUSED 127.0.0.1:9006	tcp
fd175737-8ee1-47ce-bddb-989f3a43a775	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 05:11:01.222	down	3000	connect EHOSTUNREACH 192.168.1.221:3011	tcp
dce36aa1-a5ee-4901-9961-f75818589b7f	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 05:11:28.232	down	4	\N	tcp
b9bc4d34-07f3-489a-addc-f282c680cb5d	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:11:28.234	down	6	\N	tcp
c0ccc010-6774-4d97-9c4a-a1b93359a1e4	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:11:28.248	down	3	connect ECONNREFUSED 127.0.0.1:7000	tcp
7910ae50-813a-4179-bf8d-6da9fed19a3d	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:11:28.252	up	7	\N	tcp
113e9a7c-7cf3-4a20-98f7-23fb5cec5f1b	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:11:28.26	down	2	connect ECONNREFUSED 127.0.0.1:9001	tcp
62759161-2720-4513-9cb6-6ec9eda3fe09	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:11:58.258	down	3	\N	tcp
e5410fa4-a011-45ad-a4a7-139082479f27	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 05:46:51.297	down	8	\N	tcp
3e06d92d-4e0f-45d1-8e6d-492a473d3ef6	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:46:51.343	down	3	connect ECONNREFUSED 127.0.0.1:6875	tcp
0bf90fff-4b5a-4062-8621-95ed49d7911e	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:46:51.348	up	8	\N	tcp
036831f5-9acb-40e0-8e79-f29dd19bb364	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 05:46:51.358	down	2	connect ECONNREFUSED 127.0.0.1:9006	tcp
6690889e-5936-4601-ad2e-a10239c908a6	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:01:51.78	down	2	\N	tcp
e8a3d8a9-a38e-4998-9ac0-e1fdf10482db	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:01:51.779	down	2	\N	tcp
db6ff82c-1804-483a-b5a4-ebada1ab060f	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:01:51.782	down	4	\N	tcp
00668060-0be9-421b-9f5b-cade4977e241	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:01:51.79	down	1	connect ECONNREFUSED 127.0.0.1:4100	tcp
38131bca-2167-4640-83d8-1e8141c6c08e	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:01:51.793	up	0	\N	tcp
84e3408e-332a-4f99-8426-126e5218c218	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:01:51.804	up	15	\N	tcp
51d612a2-e596-4ce4-8ff7-a290a37f3bbd	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:01:51.805	up	9	\N	tcp
facf744e-6e72-4b74-91d7-2095320b0571	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:01:54.79	down	3001	TCP connection timed out after 3000ms	tcp
ea82df56-c921-4907-95f4-89feeab43678	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:01:54.789	down	3000	TCP connection timed out after 3000ms	tcp
cb701ae2-6859-4ca7-87bc-888a4344d5cf	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:01:54.792	down	3000	TCP connection timed out after 3000ms	tcp
dcf82c37-3566-477a-b441-86e3b3b830b0	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:01:54.792	down	3000	TCP connection timed out after 3000ms	tcp
08a25c97-22ff-41a3-8add-0336e860b85e	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:02:21.826	down	3	\N	tcp
2d9c9af1-d03a-4a48-bb0c-c614858e0b9a	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:02:21.827	down	4	\N	tcp
56bd7844-cc2c-433c-ad56-bc116224908f	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:02:21.828	down	5	\N	tcp
327d6bd7-31a1-4b9f-ae30-475e07ee36d9	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:02:21.837	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
94a2d5a6-9615-41d0-9763-b9e861909459	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:02:21.838	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
9d9e2c36-08c4-48ca-9ea9-b1e4eff3ce98	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:02:21.843	up	1	\N	tcp
0c9bff39-54b4-45c1-aa2c-add28bee4ab0	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:02:21.847	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
50e280ff-0576-45e4-8236-9dafd5661f72	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:02:21.85	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
7ca1ccac-4c65-439c-ade3-e7869b465412	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:02:21.853	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
9f3f3f61-272a-4219-a425-3eb99832309c	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:02:21.856	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
28ea37dc-0416-48bb-af7b-65473ad76a70	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:02:21.858	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
0c402255-3d64-4c57-bcf2-cb51e716c1e9	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:02:21.876	down	40	connect ECONNREFUSED 10.0.0.200:3100	tcp
d018f46d-699b-40e5-9ff2-35bfb3c5b598	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 05:10:28.201	down	8	\N	tcp
bb143841-7e56-45de-85e0-d2448ba90cf1	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 05:46:51.296	down	7	\N	tcp
b04a5bb2-894a-422e-8195-c356feec3343	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 05:46:51.345	down	4	connect ECONNREFUSED 127.0.0.1:8555	tcp
16cb731e-5f42-451f-9413-6f11b4147690	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:46:51.349	up	9	\N	tcp
b84d31a1-79bd-4440-a7d5-8ec526c62fa6	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:46:51.358	up	7	\N	tcp
fc7d6773-9e5c-49a8-9e0e-f61e6b5d509f	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 05:46:51.359	down	2	connect ECONNREFUSED 127.0.0.1:9020	tcp
66cfe2dc-1f17-41ed-b589-fbe9fa115498	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:46:51.362	up	6	\N	tcp
eb0ec53f-49ba-43e6-b261-8e8669fa734b	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:01:51.78	down	2	\N	tcp
34a3e272-b490-4621-bb08-0f61a75bb529	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:02:21.826	up	4	\N	tcp
1daeb137-fb65-4c09-acdd-705fec248f81	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:02:21.827	down	5	\N	tcp
08758c5b-7532-40ac-b0e8-037dd6eeaf9d	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:02:21.837	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
a0fe02d0-55e3-41f2-8ba9-45439d7a0a98	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:02:21.875	up	39	\N	tcp
cc6e32f7-e0d3-4430-b4d7-f7b767fd3eaf	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:02:21.876	up	41	\N	tcp
a3c26bdf-98dd-4119-b855-1325922b3ef1	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:02:24.835	down	2999	TCP connection timed out after 3000ms	tcp
0b424fee-f75b-4705-8f3a-b2b692aa72fe	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:02:51.804	down	4	\N	tcp
2c8dc1a7-b085-45f6-b04c-275570157db4	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:02:51.806	down	5	\N	tcp
29793c3e-2872-450b-ad6a-b65422f27143	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:02:51.815	up	2	\N	tcp
ad33778c-16e8-4e38-80f8-c422ed1ed661	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:02:51.824	up	12	\N	tcp
a26f3179-88b0-4753-8cf8-a63ac8079dbc	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:03:21.805	down	3	\N	tcp
8e1ace37-9855-44da-a28b-533e3411d118	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:03:21.822	up	9	\N	tcp
8617550b-6d85-43b9-a88c-999ac309abec	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:03:21.823	up	11	\N	tcp
d83807d1-cb19-48fe-a6c6-3e0e63991371	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:07:21.886	up	5	\N	tcp
339db779-b85d-497f-b662-3a0129ce7874	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:07:51.897	down	2	\N	tcp
6aa8018e-193a-4ec5-b3b0-8a7ddecd27b9	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:07:51.899	down	4	\N	tcp
9bb5c2af-0814-4f7b-b827-f5fbd827f35f	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:07:51.907	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
359ff1f9-2c20-476f-bfd0-fdf2cb09868e	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:07:51.908	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
2c53356b-d166-4c0a-bfd3-31e2490a1aa3	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:07:51.912	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
43eb9c2a-5a75-4e77-bc4d-f5e4dc4b2edd	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:07:51.914	up	3	\N	tcp
343e3e8e-859d-4801-b535-a885f817ace0	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:07:54.905	down	3000	TCP connection timed out after 3000ms	tcp
8bd3e998-6874-48cc-9929-6b6ad87c894d	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:08:21.903	down	3	\N	tcp
41ba925a-e4c0-4b53-9c15-3a20f5629848	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:08:21.914	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
bc08ac65-b6c4-4fdd-bd8c-fe8f3b093e63	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:08:21.939	up	27	\N	tcp
3bf94c71-62d9-41b6-a3a8-f0a1262b5290	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:09:51.964	down	2	\N	tcp
b186415d-7bdc-4f31-bd77-5661235e250c	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:09:51.967	down	4	\N	tcp
bfa3b5b3-4d05-4af9-af4c-f4dffe250cfe	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:09:51.98	down	4	connect ECONNREFUSED 127.0.0.1:4100	tcp
c5ec845a-dec7-44e5-a0c1-5b5f3e7aeb74	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:09:51.985	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
c704ff41-a58e-4af6-b1b0-ce43e23833c0	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:09:51.988	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
05a11ff8-aef4-4eb8-9af3-46aed9572b6e	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:09:51.992	up	5	\N	tcp
c77f33c3-1835-48bf-b486-e8bd800615c6	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:09:51.993	up	3	\N	tcp
13078902-121d-46cc-8a0a-6f11b27a796b	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:09:51.993	up	3	\N	tcp
2aed61dd-447a-41d6-a209-a4c481c12ddb	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:09:54.977	down	3000	TCP connection timed out after 3000ms	tcp
f0afcec5-55c8-4ba0-b509-07b13526d29a	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:09:54.976	down	3000	TCP connection timed out after 3000ms	tcp
e5a6d6c9-4c78-4461-b089-f5d5c165bfa0	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:09:54.989	down	3000	TCP connection timed out after 3000ms	tcp
35110bc7-726a-452a-8278-a80fbf0bd6cb	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:09:54.99	down	3000	TCP connection timed out after 3000ms	tcp
f7086f9d-06ec-4852-9afd-ed3e250632dc	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:10:21.97	down	1	\N	tcp
de561c28-8757-4f5a-83fa-940a6190f64f	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:10:28.195	down	3	\N	tcp
bf26aed6-63dc-4c65-93f6-94e379425f80	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:10:28.27	up	21	\N	tcp
0e440edf-7548-4dff-b0a6-f3f61b912d05	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:10:31.239	down	3001	TCP connection timed out after 3000ms	tcp
399fa1f6-51aa-4d71-beb8-1495ca7d4feb	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:10:31.25	down	3001	TCP connection timed out after 3000ms	tcp
809a5fc4-7453-4977-b05e-ad30453402ed	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 05:10:58.205	down	3	\N	tcp
fe9770b5-fd44-415d-b0f4-b399a5d99219	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 05:10:58.208	down	5	\N	tcp
3155be95-5a84-4ad9-889a-9ba6d9c86ba3	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 05:10:58.229	up	8	\N	tcp
80f59c2f-51d1-498c-b4ad-fa3b21d55c0a	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:10:58.237	down	3	connect ECONNREFUSED 127.0.0.1:7000	tcp
812d6126-8b37-4698-b043-75c1cb6fd959	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 05:10:58.24	down	4	connect ECONNREFUSED 127.0.0.1:9001	tcp
c82ca248-0a19-4754-a435-24ac0828fe40	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:11:01.22	down	2999	connect EHOSTUNREACH 192.168.1.222:8082	tcp
df3ec8ef-98ac-4479-96fc-30b3606aceaf	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 05:11:01.223	down	2993	connect EHOSTUNREACH 192.168.1.222:8080	tcp
a1a3c950-6be0-4075-812d-f50dc39ddee5	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 05:11:28.23	down	2	\N	tcp
863b066a-e542-45a0-ae7c-48b30070bd4e	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 05:11:28.233	down	5	\N	tcp
3b392f34-ac44-401b-a242-4eec66042a5a	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 05:11:28.236	down	8	\N	tcp
b79badc6-522f-4051-863c-7cf0e3cdc061	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:11:28.249	down	4	connect ECONNREFUSED 127.0.0.1:6875	tcp
7dd1e848-8b98-435c-aaf0-157b64d94e7d	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 05:11:28.253	up	7	\N	tcp
aedd4e9a-9ed0-4d1c-83b3-bab72df78d6e	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 05:11:28.259	down	5	connect ECONNREFUSED 10.0.0.200:3100	tcp
1a2662ad-3b2a-488e-8687-254e610c514c	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 05:11:28.261	down	2	connect ECONNREFUSED 127.0.0.1:9000	tcp
3961c175-a16b-429f-9423-219b7db5c8cd	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 05:11:31.244	down	2990	connect EHOSTUNREACH 192.168.1.222:8082	tcp
152b5c6f-86e8-442a-8496-02825428420f	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:11:31.256	down	3001	TCP connection timed out after 3000ms	tcp
49d11e02-087c-43f0-8cf4-3ce62184d8d3	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:11:58.258	down	4	\N	tcp
2d6b18eb-ba8b-498e-b4f5-f5ca269acc06	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:11:58.261	up	6	\N	tcp
2fcf905f-a834-4fa1-960e-7a5166a7adfa	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 05:11:58.275	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
85f136b7-68c0-42e0-b853-58ef6e071e9b	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 05:11:58.365	up	92	\N	tcp
8f7125a9-4a3c-427e-8d71-26bb323eefbf	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:12:01.273	down	3000	TCP connection timed out after 3000ms	tcp
79620061-8ea5-47d9-a1ce-a019ec0b200c	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 05:46:51.344	down	4	connect ECONNREFUSED 127.0.0.1:7000	tcp
1e73f58a-1515-4bc5-ae53-80eee3c92e1c	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 05:46:51.35	up	9	\N	tcp
8133730d-894b-47b1-a63b-c73af6a75027	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 05:46:51.357	down	6	connect ECONNREFUSED 127.0.0.1:8556	tcp
463d58c7-a54f-40ce-abe3-772cf614959a	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:01:51.78	down	2	\N	tcp
b565fe50-79cd-4e1c-98de-ab1ecc492acc	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:01:51.804	down	15	connect ECONNREFUSED 10.0.0.200:3100	tcp
9f6c9b85-43fa-46d5-a2d3-24ed828ce54c	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:02:21.824	down	2	\N	tcp
84682071-4881-4fc4-b4f8-f1fd7459c260	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:02:21.827	down	4	\N	tcp
ca53c7e5-c805-463d-99ad-5613dcd1fc8a	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:02:21.877	up	34	\N	tcp
3f245fb9-b908-40da-bd4e-498cce8cf8f7	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:02:24.836	down	3000	TCP connection timed out after 3000ms	tcp
d4deff3a-0a07-4fdd-9569-f371f0e8bb79	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:02:24.846	down	3000	TCP connection timed out after 3000ms	tcp
b1c22917-870d-4723-9f68-7f93e1ad16e2	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:02:51.805	down	4	\N	tcp
1006d68c-2c57-4dc3-97ab-a3441de37573	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:02:51.824	up	12	\N	tcp
a9d8602d-75cb-4344-a409-837c497a4ce2	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:03:21.805	down	3	\N	tcp
878104fc-e7a2-4495-b4de-1d385ca82411	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:03:21.816	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
4bc5cf4e-c77a-4c0e-bc76-fa15f3834319	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:03:21.821	down	9	connect ECONNREFUSED 10.0.0.200:3100	tcp
6e41135c-e946-440b-97a2-0cdbea30c129	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:03:21.828	down	2	connect ECONNREFUSED 127.0.0.1:9001	tcp
29b34b68-e906-42f6-95ac-d947cc5f6ea3	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:03:24.813	down	3000	TCP connection timed out after 3000ms	tcp
bad76aed-d719-45eb-ab5f-5b2cbd23f3a6	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:03:24.819	down	3000	TCP connection timed out after 3000ms	tcp
017ec788-ce97-4f4a-8c4c-f292ee494569	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:07:21.886	up	5	\N	tcp
09980704-6e82-4817-9529-737568925c65	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 05:10:28.197	down	5	\N	tcp
a22c436e-a671-46c8-895f-94c7d51ca3e8	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 05:10:28.241	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
0ea52198-4577-4be9-9109-5a317ba83a88	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 05:10:28.269	up	30	\N	tcp
6443ff72-14f7-4998-a827-71e32c66800b	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 05:10:58.207	down	4	\N	tcp
adacb221-289d-4c07-b1d4-25efca7c6d1a	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 05:10:58.21	down	7	\N	tcp
5a612bd5-89b1-462f-adbe-0b16ffbaf5cb	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 05:10:58.228	up	7	\N	tcp
c7e54419-bef1-4e17-aaac-66cf14e428f4	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 05:10:58.238	down	3	connect ECONNREFUSED 127.0.0.1:6875	tcp
45ab74e5-ba5b-45b6-872f-9c8aecc2722f	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 05:11:01.222	down	2991	connect EHOSTUNREACH 192.168.1.221:4001	tcp
52539f12-8b4b-48ca-9b55-64d19786c25a	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 05:11:28.232	up	4	\N	tcp
1eff9c39-8cf5-4c91-814e-42818471e615	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:11:28.236	down	8	\N	tcp
8ef92dc3-1475-4996-8519-efcbf990f316	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 05:11:28.253	up	8	\N	tcp
c7fd5f04-77dd-4130-b57b-b8610a199c5c	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:11:28.262	up	4	\N	tcp
60f33a8b-0a73-4932-bb70-4f82b7fbc6d4	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 05:11:31.244	down	2999	connect EHOSTUNREACH 192.168.1.222:8787	tcp
a1c61d8b-b5d4-4ac6-b515-c3b9adbf8432	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 05:11:58.257	down	3	\N	tcp
476dd89b-a51b-4caf-a09c-45eeca89f6d5	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 05:46:51.354	up	13	\N	tcp
cb1e8253-44fc-4f10-bf7c-e76fb8fe5a03	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:01:51.781	down	3	\N	tcp
ba7983ce-7466-48b1-a55e-fd655c1b4f25	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:01:51.805	up	9	\N	tcp
e6d007c3-a94d-4b16-ad6a-f2d44ebf347a	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:01:51.807	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
1b91e1a5-1ee5-4741-a2ec-9f81368e616a	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:01:54.789	down	3000	TCP connection timed out after 3000ms	tcp
6b484e48-0dc7-42cb-a372-2fb88b8cf819	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:02:21.824	up	2	\N	tcp
6f7e13df-6577-4f02-8126-c8efa0da20e4	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:02:51.804	down	4	\N	tcp
cc25773f-89ca-4e55-b1a5-9187a8edd80b	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:02:51.825	down	12	connect ECONNREFUSED 10.0.0.200:3100	tcp
ecd7ee67-4902-41be-8c0b-aa3c62eef512	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:03:21.803	up	2	\N	tcp
c427a0ac-e1c2-45bd-9f8c-d5940ff94c07	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:03:21.806	down	4	\N	tcp
0ba320d6-f32f-4da1-8bc7-4c0f7bd24283	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:03:21.815	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
2006d3b5-260d-4460-be22-abd11b5de3a2	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:03:21.816	down	4	connect ECONNREFUSED 127.0.0.1:8020	tcp
8b241beb-5dbb-402c-b2ef-60a276d38d7e	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:03:21.82	down	0	connect ECONNREFUSED 127.0.0.1:8555	tcp
b88b50a8-2c81-439d-8b93-cd57b51c3b44	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:03:21.82	down	0	connect ECONNREFUSED 127.0.0.1:8080	tcp
5af533bf-13de-466f-b9bd-2de35b3e499e	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:07:24.874	down	3000	TCP connection timed out after 3000ms	tcp
2939d97c-c2cb-4f72-af30-54ef251c63a5	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:07:24.881	down	2998	connect EHOSTUNREACH 192.168.1.221:3011	tcp
790b2b7e-7231-4180-850f-4e0f8b5f83ef	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:07:51.897	down	3	\N	tcp
c3399112-3011-4a06-aff7-559f55dfa1a0	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:07:51.907	up	1	\N	tcp
5dd98760-8850-4558-827b-b371a49165c5	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:07:51.908	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
2a49b220-046b-4f32-8f84-7d7070a11850	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:07:51.915	up	3	\N	tcp
55d5b18e-d942-47a6-a055-247d1298d2d5	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:07:51.916	up	5	\N	tcp
114097d0-ee77-4a0e-a0be-984a577bffaa	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:07:51.922	up	9	\N	tcp
b411be68-0e82-4a08-894d-273982210d5d	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:07:54.905	down	2999	connect EHOSTUNREACH 192.168.1.222:8080	tcp
ff7f7a6d-757c-4cb2-9234-f54ea6e9326c	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:08:21.901	down	2	\N	tcp
d82df02e-c706-4f51-a82d-9bbcf1f65428	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:08:21.905	up	5	\N	tcp
95847eec-cd30-4bba-9953-07d04499cd1c	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:08:21.914	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
d4acf8a1-3d0b-4111-b677-a75d0407c8b2	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:08:21.94	up	19	\N	tcp
569488d2-93ee-442a-be22-37d2ca043d75	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:09:51.964	down	2	\N	tcp
2fefdc8a-a332-44d5-a976-c62454a49937	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:09:51.967	down	4	\N	tcp
c7c95dd3-a344-41f9-9d1d-1a322ad54a64	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:09:51.978	up	2	\N	tcp
bf6b098b-2e43-4f91-a48d-210f2fc89fb0	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:10:21.971	down	2	\N	tcp
7e35dad0-bedd-4fe5-8de5-6bb4998dfcde	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:10:51.977	down	4	\N	tcp
3143e191-0daf-4035-8c6c-0ef7280923ee	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:10:52.065	up	73	\N	tcp
144c48f6-2161-4019-9db4-7ba5d727fdc5	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:10:54.987	down	3001	TCP connection timed out after 3000ms	tcp
56b05078-91b2-4ec7-8e83-8f17b963cc83	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:11:21.974	down	3	\N	tcp
1ec04b5e-b444-44d9-b841-8bf6055fb95d	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:11:21.991	up	2	\N	tcp
cf755c58-cad8-4920-93c8-5566b3ebc0e1	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:11:21.99	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
9b5d0dfe-c23e-4604-bc21-3ea54d88b3cc	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:11:22	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
ebfc1ba9-a980-4324-9af1-96f2aebcc394	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:11:22.018	up	29	\N	tcp
03310f5c-a7d9-4785-8078-b95129148f21	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:11:51.993	down	1	\N	tcp
1b1a916b-7b86-41d8-85f3-37e6782da9fa	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:11:51.996	down	4	\N	tcp
4d7d855d-5003-44b8-acbc-e180f60b0a2e	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:11:52.01	up	3	\N	tcp
fd91fbe7-ceb3-4971-a131-bbbc364bad99	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:11:55.001	down	2999	TCP connection timed out after 3000ms	tcp
5b8ea605-363e-4728-990b-c528ac1f37a2	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:12:22.017	down	2	\N	tcp
308040ef-908d-4b1c-bc73-903aa497e202	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:12:22.018	down	3	\N	tcp
257ea8f2-ac03-4a7f-96a2-3e3631d71b80	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:12:22.024	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
094bae19-90b9-4010-a2c9-3ace342cc156	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:12:22.025	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
31a4c5da-0719-4541-8634-844e1ae26925	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:12:22.051	up	20	\N	tcp
51ba698b-7b69-4f96-b0c5-43565af6a8f4	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:12:25.024	down	3001	TCP connection timed out after 3000ms	tcp
0ea16132-c282-4081-b87c-d69520d8d45a	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:12:25.032	down	3000	TCP connection timed out after 3000ms	tcp
9b3128d8-2e91-46b9-bbb9-87f479c53033	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:12:52.019	down	3	\N	tcp
b377b43a-1583-425a-8f87-3858a3049658	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:12:52.021	down	5	\N	tcp
5d5ed0dc-fb35-48f2-afed-cdc3d17f690a	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:12:52.028	down	1	connect ECONNREFUSED 127.0.0.1:8088	tcp
878f38db-0606-40d5-8fef-51cfc0e645dd	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:12:52.033	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
7c6b2d1b-72ba-4edd-9075-8da8805d1e0f	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:12:52.036	up	5	\N	tcp
74034ae7-9093-41ec-8bc6-6ea72fe31763	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:12:55.026	down	2999	TCP connection timed out after 3000ms	tcp
d0d888ca-0064-4c8c-a9a7-d2a32fa31a58	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:12:55.032	down	3000	TCP connection timed out after 3000ms	tcp
877bfea7-05b2-4743-aee4-2f1e834a9a37	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:13:22.04	down	2	\N	tcp
0cc2077e-fcba-41fd-90aa-1fdfb472ddf3	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:13:22.042	down	4	\N	tcp
351bbf3a-a72d-420c-b3a2-669042b0a8ad	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:13:22.075	up	20	\N	tcp
be309141-9fae-4b97-8c01-12044d4aeb2c	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:13:25.048	down	3000	TCP connection timed out after 3000ms	tcp
41418f65-4f18-4523-91fe-b5fc212ec9de	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:13:25.056	down	3000	TCP connection timed out after 3000ms	tcp
58497471-e58a-4e86-9457-88a584a8832a	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:10:51.977	down	4	\N	tcp
393e20be-4ffa-412c-ab56-5765324a91ee	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:10:51.988	down	3	connect ECONNREFUSED 127.0.0.1:8555	tcp
0dfc8635-d805-4327-91ab-f01463c854fd	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:10:52.065	up	73	\N	tcp
35fd112b-a963-40a8-ae2e-ee4c99e75fd4	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:10:54.987	down	3002	TCP connection timed out after 3000ms	tcp
0f44d242-7800-4fcc-96a6-3ff89b8ede87	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:11:21.974	down	2	\N	tcp
678640e9-5b6b-44d3-bdf8-aeae8bdf41e4	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:11:21.991	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
0150983f-ff7e-49c1-bc99-acb3ff909690	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:11:22.019	up	20	\N	tcp
cf8efbaa-5d7a-430d-ab3d-9a832384d250	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:11:51.994	down	2	\N	tcp
62d7394f-ba34-4512-bbd6-7d08338048ef	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:11:52.003	down	1	connect ECONNREFUSED 127.0.0.1:8555	tcp
58db4d34-3c02-4818-a135-08eb6b9187f6	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:12:22.016	up	2	\N	tcp
1a9a2d4d-4e7e-40c2-822e-5dc637972ca3	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:12:22.018	down	4	\N	tcp
cb5fd705-5b6f-4f16-93f5-7ce1255e4be9	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:12:22.025	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
38251705-d40e-4dd7-b5f5-9411e2ef0cb7	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:12:22.051	up	19	\N	tcp
952b7e74-33b6-4709-bd8d-048c8000a11b	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:12:25.024	down	3001	TCP connection timed out after 3000ms	tcp
c4a8275f-9580-4f39-af34-d8bdec9cf5a6	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:12:25.031	down	3000	TCP connection timed out after 3000ms	tcp
e78603a1-058e-4916-b38a-899b54da37b1	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:12:52.02	up	4	\N	tcp
7e0ee5f9-4a04-433b-9122-ffc521770d84	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:12:52.028	down	1	connect ECONNREFUSED 127.0.0.1:8555	tcp
2a616e3a-77da-438c-8251-9364055a6511	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:12:52.033	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
b40d24df-94dc-4883-821f-f63e876aaa89	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:12:52.036	up	5	\N	tcp
c8b7bd58-bda4-49bd-8a52-26068333af8f	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:12:55.027	down	3000	TCP connection timed out after 3000ms	tcp
3ad119b8-f5e6-4b50-a7e0-b01e8538780a	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:12:55.032	down	3000	TCP connection timed out after 3000ms	tcp
e139c34f-3bf8-4a83-93f6-508d07362035	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:13:22.041	down	3	\N	tcp
8606c8a8-857c-4264-abb8-ca229c88b7e7	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:13:22.05	up	2	\N	tcp
0524f8e3-4810-468a-ac05-536835137914	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:13:22.056	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
347cbf38-741d-40c4-a39a-b9212c513a2d	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:13:22.058	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
906a309c-5bf6-4750-b46e-6cf1a9749a06	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:13:22.075	up	27	\N	tcp
6fdf6ed7-69dc-42e7-ad0e-407b3e2b9cf1	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:10:51.977	down	4	\N	tcp
cbbe5393-6a29-41c0-b037-d4ce26177ef9	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:10:51.978	down	5	\N	tcp
39c79cb1-d7b2-4ee8-87dd-393092234610	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:10:51.976	down	3	\N	tcp
e65badaa-1dff-40af-a5c7-4e46162ed40f	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:10:51.986	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
d2bf859a-f984-470a-8ccd-27d6911105f7	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:10:51.987	up	2	\N	tcp
9fc42212-41b1-4ca3-bac7-c404f620fce2	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:10:51.988	up	3	\N	tcp
76ec6008-eb3e-4d3c-a4a7-cbedf9dbd411	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:10:51.988	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
3802d298-a185-4813-a569-459a00f1d2ff	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:10:51.988	down	3	connect ECONNREFUSED 127.0.0.1:8080	tcp
0f2e7d19-1a67-494f-90cb-3820c140733d	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:10:51.989	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
9c2ff217-7a83-4cfb-b56c-0d864f1ea3be	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:10:51.989	down	4	connect ECONNREFUSED 127.0.0.1:4100	tcp
501af585-67b4-4bc2-8396-22719dfc2115	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:10:51.988	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
778b7e88-9537-46b1-8197-0ea178524b7c	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:10:51.989	down	4	connect ECONNREFUSED 127.0.0.1:9000	tcp
241d3086-59d6-46cf-8169-b6dda924a9b2	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:10:51.989	down	4	connect ECONNREFUSED 127.0.0.1:8556	tcp
ab075aed-eadd-4ef2-86a7-8417399166b1	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:10:51.992	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
3eb3463d-417e-414c-b205-463223eb0e29	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:10:51.993	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
43b102a7-d7ca-40eb-86d8-9b1cd4483e42	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:10:51.993	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
b43d0c78-c8e4-4b2a-b20c-e37e8fe33327	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:10:51.993	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
88fc7c32-3a8b-4219-b5bb-179d2b1d93e6	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:10:52.063	up	78	\N	tcp
2a52f8ea-05df-4dbd-bccb-cdd0200a1c97	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:10:52.064	up	78	\N	tcp
163fffdb-57fb-4237-8242-dce253bd1665	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:10:52.064	up	72	\N	tcp
c7258d45-4c57-4efd-9d93-468d4234f224	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:10:52.064	up	79	\N	tcp
d332dad8-24ca-4cc8-a09e-be057b141b0e	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:10:52.064	up	72	\N	tcp
e6a3716c-c7bf-4848-abac-6406fb15816d	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:10:52.064	up	72	\N	tcp
0f2f0b8a-3a3d-47d1-b6eb-5c680f6740b4	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:10:52.065	down	72	connect ECONNREFUSED 10.0.0.200:3100	tcp
cc2429be-9398-495d-bb17-3b04aa59dc74	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:10:52.064	up	79	\N	tcp
56f58545-66f5-425f-bfa2-506a973c3fd1	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:10:52.065	up	72	\N	tcp
41c3b1fe-6ef3-44c9-9f56-cf843030fdbf	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:10:52.065	up	70	\N	tcp
444c5d52-c87d-495b-9236-118d671bae08	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:10:54.986	down	3001	TCP connection timed out after 3000ms	tcp
32cdad35-ffe9-41ff-b53d-36578c6567bc	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:10:54.987	down	3002	TCP connection timed out after 3000ms	tcp
ba4bde02-ec08-4204-9a3e-85dbcdfc3a88	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:10:54.987	down	3002	TCP connection timed out after 3000ms	tcp
beaaf0d7-ddd0-490b-a8af-ffdd000fd3e5	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:10:54.996	down	3000	TCP connection timed out after 3000ms	tcp
f0360bf8-06dd-4ac8-a546-6b69d8105489	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:10:54.995	down	3000	TCP connection timed out after 3000ms	tcp
80fe79b0-4eaf-45f4-be28-6c77e1277bf7	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:11:21.973	down	2	\N	tcp
b0beee12-8b42-446b-ae72-815d437171f0	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:11:21.973	down	2	\N	tcp
6061c3e5-35c1-4cab-8bb9-4bacc9f12486	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:11:21.973	down	2	\N	tcp
0184945d-0608-46eb-bdd5-74d840e6d68e	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:11:21.973	down	2	\N	tcp
19be6223-fe3e-48dc-b5cd-9852676b87a1	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:11:21.973	down	2	\N	tcp
50f9e7f2-14c4-4fa5-b984-eec3e987e461	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:11:21.973	down	2	\N	tcp
47998578-7f13-4f2c-bac2-ecef9b7327ef	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:11:21.974	down	2	\N	tcp
2722b696-d3e9-4de0-8eee-e608bb15194f	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:11:21.974	down	3	\N	tcp
d14fc243-01b6-44a6-a54e-144f33bc4699	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:11:21.974	down	3	\N	tcp
ae617ba8-1f40-486a-9d33-bba27216d1de	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:11:21.975	down	3	\N	tcp
bd991f8b-e552-4920-ae86-f3d96376f7b4	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:11:21.974	down	3	\N	tcp
b3b244fd-b101-4392-83a0-a379460fe1b0	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:11:21.975	up	3	\N	tcp
46fe04db-4bed-4c88-9f6d-4d7f7c6d8046	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:11:21.975	up	4	\N	tcp
cb26bf6e-4d34-430f-866c-0a4feba8a9d2	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:11:21.975	down	4	\N	tcp
8883a6d3-a421-443c-9894-c888f128a310	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:11:21.992	down	3	connect ECONNREFUSED 127.0.0.1:9000	tcp
c811402b-9af9-48c4-a0ac-7a6fbd5addb8	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:11:22	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
61af7a7c-6dc9-49ba-b2c1-791d56cb80fe	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:11:22.018	up	29	\N	tcp
7bded660-2dad-4f9e-9b25-30e9315041e8	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:11:22.019	up	20	\N	tcp
b938bb3a-fdd3-409a-b83b-28a37a0493ea	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:11:24.99	down	3001	TCP connection timed out after 3000ms	tcp
e3fc4ada-fde1-4b03-936b-abc199a332c0	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:11:25	down	3000	TCP connection timed out after 3000ms	tcp
22352c97-e19f-42ee-915c-71585e450e54	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:11:51.993	down	1	\N	tcp
1511d64e-202f-44c2-a940-8b97ac5e0a7b	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:11:51.996	down	4	\N	tcp
3a794b81-9bf5-40bc-af66-42b651e5b963	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:11:52.004	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
0314164a-112d-40e8-9b58-6a294f6c8405	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:12:22.016	down	1	\N	tcp
9994a58b-47ef-4e12-a078-01d9c6450eba	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:12:22.017	down	3	\N	tcp
fad77513-eaef-4834-87f7-20c295440590	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:12:22.025	up	2	\N	tcp
f5729d0e-8a7c-4623-85d0-1bb2658054c8	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:12:22.05	down	19	connect ECONNREFUSED 10.0.0.200:3100	tcp
d978bb6a-ca3e-4cf1-acb5-51c81dd1038f	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:12:52.021	down	4	\N	tcp
9a15aaea-eed2-47e0-8d20-721d817da121	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:12:52.029	up	2	\N	tcp
e4b9a056-782c-482b-aae2-c8e97b390bd6	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:12:52.032	up	5	\N	tcp
fdde5e84-299c-4613-b7ff-37e21665b52d	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:13:22.04	down	2	\N	tcp
16adecb0-5933-41b9-9481-7b86b3416388	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:13:22.042	down	4	\N	tcp
c95c8022-d509-4357-b3e9-bf1b96248309	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:13:22.048	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
53d544f2-4f62-459e-b47f-e41e8040ae18	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:13:22.048	down	1	connect ECONNREFUSED 127.0.0.1:8020	tcp
fc8a47a8-7007-42d6-afc7-89481beba370	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:13:22.056	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
533e7b39-75bc-4b88-b8a9-c5790ff06b0b	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:13:22.058	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
195d6134-4e07-4871-ae1f-6a5759735e3d	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:13:22.075	up	21	\N	tcp
75856f28-547b-4b36-a8f8-7fc37757bb39	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:11:21.976	down	4	\N	tcp
6cb8b4ca-9d9b-42f4-92e0-e9c55cc732dc	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:11:22.019	up	19	\N	tcp
151b84aa-b6ad-4c12-9612-b216bbc17520	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:11:51.993	down	1	\N	tcp
5febbaba-1dcf-448f-b8de-7187f6b8e339	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:11:51.995	down	3	\N	tcp
3048da14-f8fa-4dd3-8fa2-57db10a6b33a	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:11:52.006	up	4	\N	tcp
4a6bb8f9-e5fb-40d3-9778-8851e0178d41	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:11:52.01	up	3	\N	tcp
d00fcdac-3e26-494f-a56d-71b0fb4f9436	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:11:55.002	down	3000	TCP connection timed out after 3000ms	tcp
43343535-4ebf-42f3-bc2b-ac9c2141bd45	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:11:55.008	down	3000	TCP connection timed out after 3000ms	tcp
1de731cf-fa77-4dca-87a4-644195128a6a	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:12:22.016	down	2	\N	tcp
0d7a443b-edfc-4ab0-8ff0-a7d416aa69be	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:12:22.018	down	3	\N	tcp
170dae2e-9afe-4769-b23d-bb74ff04eccb	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:12:22.025	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
6004bd38-2973-4d40-88f2-8d3a46327a0a	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:12:22.05	up	27	\N	tcp
2ab0e942-b8dc-4a3e-b5e2-8fab38628cde	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:12:52.019	up	2	\N	tcp
cac4b6df-66a9-4591-9937-8c1e41c5ae8b	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:12:52.021	down	4	\N	tcp
f914c9f1-e91d-484a-befb-7a3105d2f04a	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:12:52.028	down	1	connect ECONNREFUSED 127.0.0.1:8020	tcp
d7942664-06c3-4dac-a3bd-7f15b5ce9485	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:13:22.041	down	3	\N	tcp
5ed239be-4e69-4e01-b3b4-2b4b0f486980	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:13:22.076	up	16	\N	tcp
2d11b46d-155f-4f72-bdc3-0e3b32fa856e	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:13:25.047	down	3000	TCP connection timed out after 3000ms	tcp
0e26f1f0-b4c7-4a78-b9d5-796bb07fd9e8	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:13:25.056	down	3001	TCP connection timed out after 3000ms	tcp
2b86e7f7-bd6f-4923-8e11-53e12e0bd7b3	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:11:21.976	down	4	\N	tcp
846077aa-9782-4339-aec1-917475178134	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:11:21.992	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
b94311c2-125a-4d17-970f-d5f394b6d9a4	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:11:22.019	up	20	\N	tcp
119119c4-d579-47b5-806a-ed879018145a	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:11:24.989	down	3000	TCP connection timed out after 3000ms	tcp
60b7f788-a4e0-41c9-87b9-a54b1651068b	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:11:25.002	down	3000	TCP connection timed out after 3000ms	tcp
f412d87e-3001-4e12-af76-3aad27c657f7	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:11:51.994	down	2	\N	tcp
977e9b47-e7a1-45cd-af6d-a9fe50a794af	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:11:51.996	up	3	\N	tcp
bcdb9b1b-3b4a-4240-af72-9850c11d66a7	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:11:52.003	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
a6505c8b-7f60-43b6-a942-ccf9f326bb10	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:12:22.017	down	2	\N	tcp
f211a4b2-389d-494d-817f-253d3ad9aab2	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:12:52.019	down	3	\N	tcp
b2c58050-1661-4c35-b1c8-efe510f68c52	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:12:52.02	down	3	\N	tcp
0e160705-2184-49cb-8a40-fc434ac0b682	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:13:22.04	up	2	\N	tcp
d04620e9-d4aa-4a8a-9293-0a4b12bf3568	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:13:22.042	down	4	\N	tcp
a050dc4d-4978-4433-a60b-d3ed414364a6	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:13:22.049	down	1	connect ECONNREFUSED 127.0.0.1:8556	tcp
d2c9efa9-af98-46fc-ae72-226e428c8625	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:13:22.075	up	27	\N	tcp
a585908c-006e-4af1-81b0-363702fb232f	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:11:21.975	down	4	\N	tcp
26e16490-0cd3-4e41-ba78-01d214156bec	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:11:21.992	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
470f0196-b513-46b7-a8d2-5e6190d389d4	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:11:22	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
e33f31f6-34de-4943-837b-740a323ce18e	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:11:51.995	down	3	\N	tcp
4226f502-fe42-4d11-a272-58da034b6c74	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:11:52.004	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
b9008fcf-43ab-418c-8ed8-56d42e72b741	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:12:22.018	down	3	\N	tcp
65b70236-16ea-4836-aee0-084aeb03669e	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:12:22.026	down	2	connect ECONNREFUSED 127.0.0.1:9000	tcp
4d37ce7a-3a6b-4d42-bf9c-e61236a63276	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:12:22.05	up	26	\N	tcp
0fd87973-584c-447c-bc38-8d96397cbb5f	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:12:52.02	down	4	\N	tcp
c3e979a5-7ba2-42ec-a418-7b20a0062506	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:13:22.04	down	2	\N	tcp
9c59cdb0-0cf5-41dd-b18e-deb6a96d880f	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:11:21.99	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
245b4514-59c1-4788-baae-1fa40d5e2e47	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:11:22.019	up	20	\N	tcp
a5d2d2aa-ac1a-49a3-8cec-f7753961c366	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:11:24.99	down	3001	TCP connection timed out after 3000ms	tcp
b011bda6-cc42-4513-90bc-c364dd6c11ba	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:11:25.002	down	3000	TCP connection timed out after 3000ms	tcp
773e3c18-d638-4890-a689-21726d759fdf	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:11:51.994	down	2	\N	tcp
5e882ffb-ae99-49c0-ae6c-b5d56c3a6fb8	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:11:52.004	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
adc249b5-d252-4c55-b0d6-2ed5c0e4a921	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:11:52.004	down	3	connect ECONNREFUSED 127.0.0.1:8078	tcp
8caec092-23dd-4e27-9bfb-87c36d0f91c9	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:11:52.006	up	4	\N	tcp
2948b812-6c92-48cf-8acc-a3048c34b017	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:11:52.008	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
195603a8-fcb4-4455-a69d-dd67a7a4b6e7	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:11:52.01	up	3	\N	tcp
a18f77e2-fa8a-48bd-8540-97d216e33646	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:12:22.025	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
82d192c4-9628-47e0-b75d-2fc6e2198659	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:12:22.051	up	20	\N	tcp
1777b10c-7074-4322-984b-2d7c98d35e41	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:12:52.019	down	3	\N	tcp
7445d5cd-da9a-4d36-bb89-f5d7cdf9de23	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:12:52.021	down	4	\N	tcp
b8d77308-58fe-4a2f-915b-387bb778240a	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:12:52.028	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
5e4e2cb2-83a2-4766-8f14-c5fddacd678c	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:12:52.032	down	5	connect ECONNREFUSED 10.0.0.200:3100	tcp
7f6cf0db-5458-4f90-8ebc-5d1d28b0e890	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:12:52.034	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
3ff4f3a2-a955-477b-a1b4-800735876e18	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:12:52.036	up	5	\N	tcp
66814489-4e18-4083-82a0-34802553d259	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:12:52.037	up	3	\N	tcp
91e4fbeb-2b63-4db9-a023-ccdc93c4c0fc	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:12:55.027	down	3000	TCP connection timed out after 3000ms	tcp
20343477-4227-4b6c-8f88-8e654de90f91	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:12:55.032	down	3001	TCP connection timed out after 3000ms	tcp
cab16ce5-0dbe-4b54-83bc-9ff90cdfc0c1	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:13:22.04	down	2	\N	tcp
403fa39d-7643-4c29-9e4f-dd0206028715	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:13:22.042	down	3	\N	tcp
429361fa-0d2a-42f1-9b5b-7bcf377a7b51	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:13:22.049	up	2	\N	tcp
dafbfd70-6e7b-47bd-aa22-0f946728e785	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:13:22.074	up	27	\N	tcp
632f0e9d-e1c5-4380-8d36-e2b717294cf4	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:11:21.991	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
91bc752b-a703-42f6-8b90-f6bc56a72135	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:11:22.018	down	19	connect ECONNREFUSED 10.0.0.200:3100	tcp
642a8402-144d-4c2f-935f-4848ed0088d8	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:11:24.99	down	3001	TCP connection timed out after 3000ms	tcp
a4af87a0-fdc7-4810-8dc7-ad818c5e64d6	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:11:51.994	down	2	\N	tcp
c80a0538-cfa3-4455-be72-4a1a6ed34f4d	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:11:51.996	down	4	\N	tcp
6d494f9f-dfac-446d-bc3a-3500d95781f3	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:11:52.003	down	1	connect ECONNREFUSED 127.0.0.1:8020	tcp
89b433c9-d822-40c1-b1db-66fff56bf1e2	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:11:52.005	up	3	\N	tcp
13730032-bb93-4658-95c3-ff32813c986c	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:11:52.008	up	2	\N	tcp
be96651f-f9fd-455f-8dd9-23c51a633ac7	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:11:52.01	up	3	\N	tcp
d9fd754e-57ee-4928-8c65-c92fc34f2395	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:11:55.002	down	3000	TCP connection timed out after 3000ms	tcp
c975c8a1-5656-4c60-a435-3bf89779a375	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:11:55.008	down	3001	TCP connection timed out after 3000ms	tcp
aca1788d-89ae-48c5-a997-5c64f3bde023	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:12:22.017	down	2	\N	tcp
4f3cea55-a457-4dad-b57a-fe4be004efd7	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:12:52.02	down	4	\N	tcp
c00224f4-8fe1-43f0-a46a-ae4edb10defa	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:13:22.041	down	2	\N	tcp
f9cd313d-912d-404c-8e9b-686456266b51	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:11:21.991	up	2	\N	tcp
d64d6a2f-f445-451b-82af-f7c00283dd8c	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:11:22.019	up	20	\N	tcp
01465025-5045-494d-904f-0b454e6b397f	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:11:51.994	down	2	\N	tcp
00b91a74-286c-4abf-8582-0ac78fd76d1a	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:11:52.002	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
bee62235-7e27-415f-9355-c2a59fe39187	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:11:52.006	up	4	\N	tcp
4897f026-7478-4353-8d9e-50627193fdf2	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:11:52.01	down	3	connect ECONNREFUSED 10.0.0.200:3100	tcp
d0e5cb16-8903-4492-821d-6dd223aab213	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:11:55.001	down	3000	TCP connection timed out after 3000ms	tcp
4ab41fda-1560-4da5-b02f-cc95bfb7f853	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:11:55.008	down	3001	TCP connection timed out after 3000ms	tcp
d4ce552e-2ba0-466b-ba68-baaee21f1d0a	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:12:22.017	up	2	\N	tcp
42361b4e-e2b8-4710-b066-9d17baac8777	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:12:22.025	up	2	\N	tcp
6a561f44-c706-486e-90b8-7fe9568694a1	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:12:22.051	up	20	\N	tcp
116f18fd-2d83-49bf-a146-b9dc877d04ad	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:12:25.024	down	3001	TCP connection timed out after 3000ms	tcp
54018d39-c962-40c1-ad90-047c35193e96	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:12:25.032	down	3000	TCP connection timed out after 3000ms	tcp
4ca1df20-0f26-4b32-87ae-f85a538d9d52	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:13:22.04	down	2	\N	tcp
c9941d00-e2b5-4b70-9b3c-3fb96e076672	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:13:22.048	down	1	connect ECONNREFUSED 127.0.0.1:8555	tcp
63b293de-47d6-4d43-b34d-27e5e088498c	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:13:22.076	up	17	\N	tcp
765e9306-614e-454a-915b-7775b03c9dad	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:13:25.047	down	3000	TCP connection timed out after 3000ms	tcp
88cd32a0-ee0b-4b55-a88a-8d59b1bb7a63	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:11:21.991	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
5f50db85-7711-4955-8f7b-be9eb5db47fb	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:11:22.018	up	19	\N	tcp
7d56b94b-5d56-45c5-b493-38c13d67d017	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:11:51.995	down	3	\N	tcp
c920dfd4-371d-49f0-9d22-ac39c3658e4e	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:11:52.004	up	2	\N	tcp
a1db3b54-8be2-40ee-8266-0080200ec062	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:12:22.016	down	2	\N	tcp
33b5cd17-b0ef-4278-8a24-68e46ace262c	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:12:22.018	down	3	\N	tcp
b330423d-0902-41b1-8be3-caa23b39c27f	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:12:22.025	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
cae249e4-4dc4-4709-afa7-ef4c56f0e9a3	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:12:22.05	up	19	\N	tcp
1a5d9994-7218-4afb-9112-2d9c431da021	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:12:52.02	down	3	\N	tcp
1ae62ee6-fc04-47be-a5f8-f786d6cb9344	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:12:52.021	down	5	\N	tcp
3cb2b862-bc01-4330-a9b4-51fefc74e278	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:12:52.029	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
20d92624-5ef3-451c-b6fa-b1ed5588229f	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:12:52.032	up	5	\N	tcp
3e5da597-6d26-4d74-b5ad-3f9f3dae3caa	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:13:22.041	down	3	\N	tcp
064f82f3-1ff9-468c-bfec-105e99a49b28	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:13:22.049	down	1	connect ECONNREFUSED 127.0.0.1:8088	tcp
f106391a-fdff-4db8-a9d5-761e570140c5	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:13:22.075	up	20	\N	tcp
f643806a-0716-4143-9cd2-56175e5db98b	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:13:22.076	down	21	connect ECONNREFUSED 10.0.0.200:3100	tcp
764c17cb-9905-40f0-a477-3b3933775d06	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:13:25.048	down	3000	TCP connection timed out after 3000ms	tcp
7b47af1f-8a97-4e12-9106-c8ebbdad41b8	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:13:25.056	down	3000	TCP connection timed out after 3000ms	tcp
7de8d243-6c82-4988-ab06-ab8358e1c232	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:11:21.991	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
ea49d68f-3713-4689-8d56-b6187b7f8629	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:11:22.018	up	29	\N	tcp
e403a8d2-19dc-46cb-ad2a-b2e499e62457	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:11:51.994	down	2	\N	tcp
ce6a7e99-4c7a-4d99-98ee-8c1dec9ad47b	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:11:51.997	down	4	\N	tcp
67a3d658-d827-4628-ad9b-e8014491ec08	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:11:52.004	down	3	connect ECONNREFUSED 127.0.0.1:8080	tcp
832ffd94-a380-467b-9992-8c62aa51c2f8	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:11:52.007	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
5f4ac14c-cf82-4a97-ab9b-54ac21a8156d	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:11:52.01	up	3	\N	tcp
78eeb04f-40b0-4da5-84c9-6f822e72c9b8	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:12:22.016	down	2	\N	tcp
057284fa-fc19-4bb1-97c5-e18be23b3a3f	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:12:22.018	down	3	\N	tcp
1643f348-5bfd-45b3-a11e-aad29fcb3155	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:12:22.025	down	1	connect ECONNREFUSED 127.0.0.1:8020	tcp
40aa828f-0c78-4366-8a00-e7b07ebe14b7	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:12:22.049	up	26	\N	tcp
c6b2d20d-0e52-456f-af9a-7a97485eee4e	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:12:22.051	up	20	\N	tcp
d455ee40-b83c-480d-8307-b7a0ebc67572	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:12:25.024	down	3001	TCP connection timed out after 3000ms	tcp
d9d53495-ae5c-42fa-ab29-6c56acd05cda	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:12:52.021	down	5	\N	tcp
5922c577-7a7a-40c9-a765-2a16fd732da4	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:12:52.028	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
4b4e0e20-890c-438d-8e19-7953e2d13f6e	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:12:52.029	up	2	\N	tcp
eb2c9127-ce50-450b-b051-c655ec82031e	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:12:52.032	up	5	\N	tcp
b840fccd-54e3-45ee-a6b6-80adf069eac3	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:12:52.035	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
876aeb01-2348-4516-87d8-e69520362f62	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:12:52.036	up	5	\N	tcp
d44affb4-1071-4579-8570-f48633e06ec7	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:13:22.039	down	1	\N	tcp
71482c15-07cb-48f1-ac20-aae89ff190e2	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:13:22.041	up	3	\N	tcp
fcdc6904-f5a3-4ea6-8d85-2cbbd048fad4	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:13:22.049	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
be1d35e2-8add-43fa-9833-5aad64be36c1	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:13:22.074	up	27	\N	tcp
0ad69dd4-2f9b-4e20-b41e-ac049e922037	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:11:21.992	down	3	connect ECONNREFUSED 127.0.0.1:9001	tcp
76423ba0-1607-4fad-b758-ee56c6140a28	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:11:22.017	up	28	\N	tcp
390ee56a-a75d-496e-a870-83df6240a0e3	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:11:51.994	down	2	\N	tcp
05ea9e35-13c0-473d-be17-933f47e155d3	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:11:52.004	down	3	connect ECONNREFUSED 127.0.0.1:9001	tcp
289566dd-a821-45c4-8225-c5ea74ed9a35	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:11:52.007	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
329ab381-9e99-48bb-947e-7fc87ce6ba75	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:11:52.01	up	3	\N	tcp
a7a6cdd3-a0c5-4e7a-bbba-15bab610c384	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:12:22.016	down	2	\N	tcp
e6459d53-d4d7-46b2-8ab2-00e45533d9df	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:12:22.017	down	3	\N	tcp
d5f1916d-05c9-497d-8c06-79453dcb29b0	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:12:22.025	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
64265073-4987-4c58-b6a0-408711fac010	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:12:22.032	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
167708bd-8539-4934-8bdd-e446adb1227b	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:12:22.033	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
94a4196e-e125-41bc-ab59-5563ba3d1c5e	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:12:22.035	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
2def5e1f-8ef3-4561-892b-1c5d0fa2443a	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:12:22.036	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
83144e9b-df4a-4667-9e83-9b19fa728ec7	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:12:22.05	up	27	\N	tcp
72307f7d-eb9a-471f-ac3a-f62d21243f24	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:12:52.019	down	3	\N	tcp
741aebf9-d881-418e-b974-1819bdebba2d	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:12:52.02	down	4	\N	tcp
15cde678-e5bf-4e00-ac6f-96b856d31b27	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:12:52.028	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
cb1db7d6-5ef4-478d-98ad-1bbc891cb778	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:12:52.032	up	5	\N	tcp
161d6866-5399-42a8-9b77-10752c7d2b32	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:12:52.035	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
d1edb61a-9767-4325-b370-045651816338	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:13:22.041	down	3	\N	tcp
e0453ac6-a93e-4ed6-b65b-38468d0c8c2f	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:13:22.049	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
aa5f1d82-3d06-4052-a60c-6e5d6c9bb278	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:13:22.075	up	28	\N	tcp
f6851c42-1401-4561-8575-dcf4e30dabed	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:11:51.995	up	3	\N	tcp
e2e32e31-89ba-49ff-ac1d-977b6fbdc7f6	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:11:52.004	up	2	\N	tcp
a332479c-3cb5-40a1-9f88-b6f092f0c537	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:12:22.017	down	3	\N	tcp
a7ed0928-2cc8-4b92-8d23-4756bb143b55	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:12:22.05	up	27	\N	tcp
1b8d2656-c4a8-4ebc-86af-1e3a336f2bba	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:12:52.018	down	2	\N	tcp
c873d25d-1fec-4412-a911-45226faa7dcd	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:12:52.021	down	5	\N	tcp
02b5cb2f-124c-444c-8736-33b6aa24fbe4	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:12:52.029	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
6af7519d-df15-48a7-ba4f-045f7cfa34c9	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:12:52.032	up	5	\N	tcp
51c233ed-e425-4090-b1f8-26c6abab5fad	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:12:52.036	up	5	\N	tcp
c191d2c0-6040-4b8d-b5ec-add1a5917461	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:12:55.026	down	3000	TCP connection timed out after 3000ms	tcp
a07a8632-6ced-4d6e-9ea8-b60f2cb82e80	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:13:22.04	down	1	\N	tcp
9b32ed1b-4dc0-49c8-a420-9cfc12b835ea	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:13:22.042	down	3	\N	tcp
423723cb-1bb7-45ef-ae44-8465aa74b8a6	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:13:22.05	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
e828505b-94dd-4be6-811c-af31d4ff9ee6	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:13:22.056	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
5d6377be-33af-4606-b81c-704d78ec4452	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:13:22.074	up	27	\N	tcp
c7d6fe94-fbdb-4d05-b07a-f6502b229884	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:13:52.07	down	1	\N	tcp
c8f4c14e-005b-4b0c-9a13-abb1e5e9c02e	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:13:52.073	down	4	\N	tcp
70180fd7-2371-4a82-8afc-d64b0034e369	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:13:52.073	down	3	\N	tcp
e6df7f69-d5d3-42c1-b165-3d54b978df60	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:13:52.071	down	2	\N	tcp
26cf9f92-a08b-4cf3-b425-feb3bafdc5e9	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:13:52.073	down	4	\N	tcp
8069ecc4-74b0-416b-ac90-06c4cd059c09	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:13:52.073	down	4	\N	tcp
692255d6-5470-4d0d-a5d4-48523b3690d5	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:13:52.073	up	3	\N	tcp
592bf486-a1c6-483d-a1a0-48bc45830d2e	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:13:52.071	down	2	\N	tcp
b8ed6373-d5ed-4f0d-81bd-c66ac7588b10	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:13:52.072	down	2	\N	tcp
9b6fe0a5-e5ca-404d-9538-6898f883a60f	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:13:52.071	down	1	\N	tcp
ac98201e-d30b-4572-a6e8-a77f63503f14	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:13:52.072	down	3	\N	tcp
ab1e5ad8-e230-48e7-9e73-c0c97717eb4a	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:13:52.075	down	6	\N	tcp
d5452819-2744-4b3f-a131-bd8109a1ccc0	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:13:52.072	up	2	\N	tcp
e706d0b2-fbfd-4122-ab86-1f749bb61fd6	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:13:52.072	down	3	\N	tcp
3fa6096d-c545-4f7c-a17e-a044c286aa74	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:13:52.072	down	2	\N	tcp
2a6dc00a-bb89-422a-9e2d-2c27ec9f7be2	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:13:52.072	down	3	\N	tcp
8c14e775-a684-498f-9324-ec643e8702f2	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:13:52.071	down	2	\N	tcp
a45e85c5-ec01-4c87-b839-ae94b97da74d	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:13:52.071	down	2	\N	tcp
6f361b29-5f82-49a6-8802-4294f1132d2c	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:13:52.073	down	3	\N	tcp
8fc4e78c-267e-4fdd-b1a2-9b7f9c337367	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:13:52.104	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
134eb7b7-62c5-4243-a098-33d83878566c	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:13:52.105	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
9941a991-c78b-4798-9dfe-f638a537119b	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:13:52.106	up	2	\N	tcp
7c838121-27bf-4357-84af-00a93f83950a	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:13:52.105	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
68185d1b-ecb7-44e7-8694-39ba0103e11b	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:13:52.105	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
60fe2752-ddbb-4871-8539-e10ed2b5d0a3	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:13:52.105	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
5d2ed135-621a-4a25-8b2e-cd2ced5777cf	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:13:52.105	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
affb3f20-5ad2-4078-adb4-d0d1f1abb504	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:13:52.106	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
77a98e28-69a6-4220-9431-1b3f38c2e986	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:13:52.106	up	3	\N	tcp
ef14f96f-9884-47b8-aef2-ea3a9fc86163	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:13:52.105	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
ed48213d-5651-4037-a128-fa3bfc8a93f6	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:13:52.109	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
02ffb7a5-4a76-4fee-924f-8d0ee29787e8	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:13:52.109	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
80808b11-af97-4c3b-9f7b-d03c34335a13	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:13:52.109	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
b7cd669b-fafc-445e-a786-062a4f4d7e9e	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:13:52.121	up	10	\N	tcp
2db4a0a7-f0c7-4aca-86ab-f5c0849ce7ea	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:14:22.096	down	2	\N	tcp
8096c84b-63ad-468e-b899-0adc566cefac	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:14:22.099	down	4	\N	tcp
75038bc5-b7a1-4733-9b4b-c93d779f86d2	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:14:52.104	down	1	\N	tcp
b558357d-51ab-4604-8668-f4a82a0c40ef	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:14:52.106	up	3	\N	tcp
cbc88e2e-0025-4c71-9550-3f4e8eae9cbc	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:14:52.115	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
143cf78b-9677-4bf3-bca9-6a57dde7d691	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:14:52.118	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
4ba473ba-2b3a-47c0-b364-68cb821a1c42	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:14:52.191	up	78	\N	tcp
a8dfbad2-ea7c-4e34-a6d7-f92ebe2cd90d	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:15:22.134	down	2	\N	tcp
c4803e8a-9d8b-44e3-8cb4-e27c05721519	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:15:22.142	down	1	connect ECONNREFUSED 127.0.0.1:8555	tcp
756f0a46-1b0d-4d20-b124-e35b760f48d4	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:15:22.228	up	87	\N	tcp
de4c163d-5395-4849-8d69-dcb44fa272ce	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:15:52.152	down	2	\N	tcp
0f10a564-e7fc-4323-a9df-932c1593c0d2	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:15:52.155	down	4	\N	tcp
17dac46d-0ac9-4de3-92bb-ff906491eae5	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:15:52.196	up	36	\N	tcp
ad6442f3-6cca-46f3-9a3c-68c21b8c76ec	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:15:52.197	down	28	connect ECONNREFUSED 10.0.0.200:3100	tcp
787ed3a8-8054-4187-bad1-be9a713ed07f	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:15:55.162	down	3001	TCP connection timed out after 3000ms	tcp
b5df99f7-3202-4ade-94ad-c840bfb18d0c	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:16:22.181	down	2	\N	tcp
6a462da2-8438-482a-8659-8ef11b3363ff	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:16:22.182	down	3	\N	tcp
03f8f544-e355-4418-91ee-0bd9dd1b26ae	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:16:22.19	down	1	connect ECONNREFUSED 127.0.0.1:8020	tcp
71c489f6-f7e2-40ad-b8e4-ea33f15d1d97	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:16:22.191	down	3	connect ECONNREFUSED 127.0.0.1:9001	tcp
197ac3a3-a9b6-43e2-abdb-a9e639e842fc	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:16:52.196	down	2	\N	tcp
4bc19b8f-0500-4552-bdda-397cc09415a6	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:16:52.197	down	3	\N	tcp
2f913400-23da-427b-ada1-6ed1fbaaa17e	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:16:52.204	down	1	connect ECONNREFUSED 127.0.0.1:8020	tcp
1d01ea07-dcfa-4321-9cb1-9a4ed1221a74	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:16:52.205	down	2	connect ECONNREFUSED 127.0.0.1:8078	tcp
b6e79709-7bb6-4b7c-957f-af2a4ed2893d	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:16:52.207	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
8250daae-c040-4ed5-8152-1594e2d15ef6	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:16:52.209	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
ecb4f4ae-b080-4bdc-b8c6-8aa1a94b0ce2	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:16:52.476	up	274	\N	tcp
a8d401a2-2946-4f4a-9efe-18ff40947e72	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:16:52.478	down	270	connect ECONNREFUSED 10.0.0.200:3100	tcp
841882ed-af77-4d3d-a709-793057fd2a27	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:16:55.203	down	3001	TCP connection timed out after 3000ms	tcp
a405afd0-3616-48e8-b134-92637b8c0418	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:16:55.207	down	3000	TCP connection timed out after 3000ms	tcp
35d80316-77ca-45e7-8365-85c79296e855	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:17:22.216	down	4	\N	tcp
fe21f855-1e83-4ed9-b37a-f88cc084ea9a	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:17:22.224	up	2	\N	tcp
36afefb9-4ecc-49c4-914c-f9d468dce716	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:17:22.24	up	13	\N	tcp
9676313e-b575-443a-837d-0857916cea2a	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:17:52.244	down	2	\N	tcp
360e3aac-e6b6-4cef-8469-022e7597dcf6	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:17:52.246	up	4	\N	tcp
5b0aabc6-ef0b-42b2-94b1-287ac1f50f05	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:17:52.255	up	2	\N	tcp
a49e68e1-fbee-4b15-b46c-43d73ce2a5d7	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:17:52.258	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
7742b1ed-08f9-415c-bebd-41d1b144312f	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:17:52.583	up	330	\N	tcp
9c285509-142a-4382-9d17-7be1cf9ba3d1	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:18:22.279	up	2	\N	tcp
3f666a18-17f2-428b-89ec-de559bb7652c	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:18:22.288	down	1	connect ECONNREFUSED 127.0.0.1:8080	tcp
0e3ff58c-27da-4c2d-b842-518e9672ef76	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:18:22.289	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
8ac66c93-7f9e-4552-a084-e4f67b86c5c0	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:18:22.292	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
feb49aef-87dc-46c7-8c0a-99d6a30d77c1	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:18:22.315	up	22	\N	tcp
7dbf4eda-854c-4a5b-87e6-aec12c643f87	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:13:52.11	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
3904f8cb-8abf-46d1-a35b-3a78a77dfef4	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:13:52.121	up	9	\N	tcp
1c9d6921-6340-4da4-9c27-b82b3b8c4a78	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:13:55.104	down	3001	TCP connection timed out after 3000ms	tcp
f267dcd9-193d-4a25-848f-287a9314b5b2	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:13:55.107	down	3000	TCP connection timed out after 3000ms	tcp
bfe9a522-6bb1-4d93-a97a-7c3ab1e708c6	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:14:22.099	down	4	\N	tcp
f450705c-fd13-4e62-9a8a-299028563248	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:14:22.111	up	3	\N	tcp
3639609f-1fae-4801-8c3e-a5b7552c90a4	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:14:22.116	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
56d83e19-bfda-472d-ad32-e877eda220f2	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:14:22.14	up	32	\N	tcp
a0329c24-db88-49a3-8fad-1f2127096038	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:14:22.143	up	24	\N	tcp
949556d1-d544-4e89-9361-ec18f3059191	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:14:25.108	down	3001	TCP connection timed out after 3000ms	tcp
7f949dbf-013a-4d26-badd-0d0cd1a6a3be	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:14:25.112	down	2998	connect EHOSTUNREACH 192.168.1.222:8787	tcp
3a9c7076-892a-4a10-b8eb-bcb6906fae41	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:14:52.104	down	1	\N	tcp
29fb8f5b-5011-4843-8b0d-5e225b2d49ad	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:14:52.106	down	3	\N	tcp
711efe59-0951-4b45-b03e-c56acc750cee	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:14:52.115	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
c126d25a-c302-4443-99d2-38ec8a2171b0	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:14:52.118	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
d86094c1-9793-45ad-882c-af7fbb2221f9	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:14:52.192	up	72	\N	tcp
62b9ce83-bcbf-4abd-b4be-91f25c57d6cd	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:14:55.114	down	3001	TCP connection timed out after 3000ms	tcp
6d08d670-0f83-4c49-bd13-b414be833133	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:14:55.118	down	3001	TCP connection timed out after 3000ms	tcp
00017822-a840-40a0-814e-3d7a5f608b32	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:15:22.134	down	1	\N	tcp
fe90a4ab-6864-4e59-920e-ba25c01ced91	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:15:22.136	down	4	\N	tcp
83699f9d-129c-477b-b113-68131c703a28	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:15:22.142	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
5922670a-7cd6-4e8e-8e85-b3cab8ed84c0	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:15:22.143	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
fc4cef94-ce5f-44e1-a0cc-1e5297d87775	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:15:22.145	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
5264bbcc-d3e0-4b88-a361-c02da76e2d40	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:15:22.228	up	82	\N	tcp
7156ea4a-6b49-45ab-b94f-5f77b55da235	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:15:52.154	down	3	\N	tcp
1120d9c4-b91e-45fc-9f20-2ee782eb3ce6	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:15:52.197	up	28	\N	tcp
62b7883d-fe05-49e8-9862-e8e37ef865f3	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:16:22.182	down	3	\N	tcp
9e81be9d-1090-4071-88dc-d24686b3ee0a	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:16:22.19	down	1	connect ECONNREFUSED 127.0.0.1:8080	tcp
1bf55281-f3c6-44ea-b2f3-e8aaeb89ae42	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:16:22.212	up	17	\N	tcp
61e29dba-c95d-4aa8-8099-b60a7e6e1d54	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:16:25.189	down	3000	TCP connection timed out after 3000ms	tcp
cdf8e4c2-40cb-46fe-bd71-aabe03825899	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:16:25.197	down	3000	TCP connection timed out after 3000ms	tcp
21a59a12-bbc7-4a75-b7ef-6a96e021ed70	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:16:52.196	down	2	\N	tcp
d4c64e76-f888-47ae-832d-6204a8ef7575	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:16:52.205	up	2	\N	tcp
561093e8-668b-46a0-b8b1-da524fc68c57	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:16:52.207	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
1b218451-5fa7-4158-ac57-aabe5f8ce0e5	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:16:52.477	up	270	\N	tcp
e9733c59-52eb-4b25-acf1-b4becb754d31	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:16:55.203	down	3001	TCP connection timed out after 3000ms	tcp
4ba300c6-da5f-4bae-8b27-2e61bf6f3842	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:16:55.207	down	3000	TCP connection timed out after 3000ms	tcp
70b4612e-b4b2-4ce6-bdc1-eab2074727eb	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:17:22.216	down	4	\N	tcp
d2f6f417-8dab-46ea-96e7-ba725213b4a4	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:18:22.279	down	2	\N	tcp
6f2a4323-1197-43de-bbee-9c744d08695c	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:18:22.281	down	4	\N	tcp
1e0797b6-ab08-4975-8c7c-91ea21e8331c	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:18:22.288	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
7c3f2755-6810-40e9-bd6d-a914b9ce812d	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:18:22.315	up	25	\N	tcp
8142ef12-61c4-451c-9371-556ceb1b4e83	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:18:25.287	down	3000	TCP connection timed out after 3000ms	tcp
2d0b93fb-22ca-4dc8-8fb1-e7ed81aa47ab	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:18:25.291	down	3000	TCP connection timed out after 3000ms	tcp
01506fd8-ee62-4ec6-818f-7df8e3129d1f	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:13:52.11	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
65ce284e-1b24-48b8-81d4-423ed4623949	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:13:52.121	up	10	\N	tcp
4b921c24-ee6f-46fe-bb8a-9b6eb685f104	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:14:22.098	down	3	\N	tcp
83b996ad-b345-4733-b5ab-424fadf20a38	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:14:22.101	down	6	\N	tcp
019ca319-b8fa-40b4-b201-8398550a30d2	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:14:22.11	down	3	connect ECONNREFUSED 127.0.0.1:8555	tcp
fa9a3dcb-2d5e-4efe-9c55-067d46b503e1	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:14:22.141	up	26	\N	tcp
1a5f6bea-564e-4041-8a03-2f66e215985d	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:14:22.144	up	24	\N	tcp
5d967b73-1485-4e61-ab05-e6b9f709ca84	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:14:25.108	down	3000	TCP connection timed out after 3000ms	tcp
b98da54c-a038-4742-ac6e-7f7c0c4873bc	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:14:25.112	down	2998	connect EHOSTUNREACH 192.168.1.221:3011	tcp
8418a943-4a7a-4c60-bbd9-d333adc9b626	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:14:52.104	up	1	\N	tcp
be485591-596d-4f97-be5b-8cca47245e07	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:14:52.106	down	3	\N	tcp
e27fa06e-4fb9-4f9f-a374-c29fd8f7ac04	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:14:52.192	down	71	connect ECONNREFUSED 10.0.0.200:3100	tcp
bf5f01bc-051c-4f75-a106-4393ec6982cf	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:14:55.114	down	3001	TCP connection timed out after 3000ms	tcp
706eff55-1952-4537-8326-e40e63c5ac45	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:14:55.118	down	3001	TCP connection timed out after 3000ms	tcp
50aa4d3f-d174-4eda-b3d7-bbdea0ee5007	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:15:22.136	down	3	\N	tcp
e068eb23-8ea8-46be-8ea9-cf41b28a461d	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:15:22.142	down	1	connect ECONNREFUSED 127.0.0.1:8020	tcp
eefb8b64-035f-4fe2-9dd8-0931bcee9a85	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:15:22.146	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
38593a4a-bd51-4432-b6e5-f2a8667772cf	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:15:22.228	up	81	\N	tcp
4f8e3c02-7da5-45dc-bd7d-65c6d3953a53	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:15:25.144	down	2999	TCP connection timed out after 3000ms	tcp
cd35267b-c962-4482-a11e-30fa61a96485	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:15:52.153	down	2	\N	tcp
b7122a19-b8ad-4b47-acf8-475ea5b792af	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:15:52.197	up	30	\N	tcp
b4118565-4d7a-41ff-a595-84c2f127d4f0	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:15:55.161	down	3000	TCP connection timed out after 3000ms	tcp
6ec508df-6f0e-420b-b6ab-338723088311	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:16:22.182	down	3	\N	tcp
0c59860a-eb95-41e7-94e8-83dad47d3396	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:16:22.191	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
4d3f1add-8a5c-47d0-a8aa-4bedb7ded53f	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:16:22.191	down	2	connect ECONNREFUSED 127.0.0.1:9000	tcp
c18dc24f-3cbd-4752-9d8c-3c380e2b7535	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:16:22.194	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
64a0ad0e-4cf6-4bca-8fa3-884361b2374f	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:16:22.212	up	18	\N	tcp
4c1a8886-75a1-4bcd-990f-4da40764f8bb	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:16:25.189	down	3000	TCP connection timed out after 3000ms	tcp
16913536-89d7-4164-ad59-6c7e8948fd12	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:16:52.196	up	2	\N	tcp
d0dcba53-351d-4292-ba7a-d475d43e9801	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:16:52.197	down	4	\N	tcp
1a080223-b111-4fac-83ca-c2f19c26ec58	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:16:52.478	up	270	\N	tcp
00c0b596-8bcb-4400-869e-b43a947431db	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:16:55.203	down	3000	TCP connection timed out after 3000ms	tcp
3485c8c1-7816-4f3c-b6df-3ebbeefa414f	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:17:22.215	down	3	\N	tcp
b74fcebf-8db8-4f9b-b805-ed368a512028	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:17:22.216	down	4	\N	tcp
754d64c3-0f1b-4e2b-af81-1bf9885d935a	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:17:22.224	down	1	connect ECONNREFUSED 127.0.0.1:8556	tcp
a946b2d2-ae69-4175-af69-64e76792ce98	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:17:22.239	up	13	\N	tcp
563e8786-d618-4c9f-bb53-87220542162b	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:17:52.245	up	2	\N	tcp
f73ff806-a77c-4720-bd19-18db123f4b2a	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:17:52.247	down	4	\N	tcp
22ec07d8-e7e5-446f-ab07-d6ba7d7e6adb	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:17:52.254	up	1	\N	tcp
0d1f5624-6557-4a5e-9a5b-386374ede333	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:17:52.583	up	330	\N	tcp
4c4fa018-8e3c-46e9-ae53-4fe6e7335056	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:18:22.278	up	1	\N	tcp
9f023c5d-9b82-4774-8cb7-0303f9d6e31e	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:18:22.281	down	4	\N	tcp
4592fc79-1465-40bd-ba42-cff9f58aebef	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:18:22.287	up	1	\N	tcp
b6287fb2-d2be-42cb-9bee-2f677cf89882	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:18:22.314	up	28	\N	tcp
7704c6d0-6805-4d31-b41e-981eff9f676f	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:13:52.119	up	16	\N	tcp
ecce810d-b210-45f9-8fab-e3357b23b568	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:13:52.121	up	11	\N	tcp
7b7283b4-dfd5-4cf3-8a45-f48cb4b7b36b	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:13:55.104	down	3001	TCP connection timed out after 3000ms	tcp
79c7c3ae-5ffc-4252-8f70-06ee6c34c092	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:14:22.098	down	3	\N	tcp
414ed0d8-daf0-477d-a2c9-27ad1bf3a7da	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:14:52.105	down	2	\N	tcp
7e22fd76-bdb5-44c1-ba11-4aebbbcc82e0	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:15:22.134	up	2	\N	tcp
1a999d3a-dd47-4c9a-a151-ddd75ad8f177	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:15:22.136	down	4	\N	tcp
20978939-ecfc-4def-b70c-e734f83767d9	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:15:22.143	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
7fe48a0f-18ce-45f5-adc8-b85890e18370	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:15:22.146	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
ce9528d7-e1d1-4002-b116-11f605144318	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:15:22.229	up	83	\N	tcp
52397502-6244-405d-a2d8-c38cfdbc12aa	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:15:25.142	down	3001	TCP connection timed out after 3000ms	tcp
13390f21-3c97-4135-ad76-a1e205ed2258	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:15:52.153	down	2	\N	tcp
b539775f-5804-4474-8a99-148a8d8f674e	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:15:52.162	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
8f74aa4f-7784-4bc0-b133-ccfd486e31e0	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:15:52.163	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
210c0f02-91de-4617-9d9b-f26b88ada323	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:15:52.167	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
371bd354-eb5e-4e6f-b364-e1130b496671	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:15:52.197	up	30	\N	tcp
330f375a-e598-42dc-8543-082dd0eed522	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:15:55.162	down	3001	TCP connection timed out after 3000ms	tcp
b3b225a9-7447-49f8-be50-d66c3cdae6e7	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:15:55.166	down	3000	TCP connection timed out after 3000ms	tcp
37c56891-247a-46fc-b9a0-b0cf10ed75ee	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:16:22.18	down	2	\N	tcp
e525231b-7909-4122-850e-186d0ab47111	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:16:22.182	down	3	\N	tcp
ee92f7a5-4455-401d-aefb-3826e7b97aff	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:16:22.19	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
d7613409-c52b-40cc-a280-d752f718fc92	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:16:22.195	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
960b29d1-2e68-4177-8525-077c9d813647	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:16:22.211	up	22	\N	tcp
afb0b450-7f21-4f24-8e5f-604bab21e547	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:16:52.195	down	2	\N	tcp
9ac35390-88f6-46c1-aa59-96c4675e2fcc	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:16:52.196	down	3	\N	tcp
f405f130-1199-4154-89d1-5cffcf9ba189	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:16:52.204	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
14b4bc0e-b906-4db3-a781-e309dc2a2ae6	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:16:52.205	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
0cf9d9ad-4d7c-4e0b-9303-4ae7e0beeae0	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:16:52.477	up	274	\N	tcp
e96dbf46-f3de-4190-b0c6-f91bb779bc8e	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:17:22.215	down	3	\N	tcp
9314a38c-1553-4677-a0fa-e2c99fdd4409	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:17:22.224	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
455d599b-17f1-4cd9-a0aa-0ea4abccec79	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:17:22.225	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
7564d4c8-c7cd-4c72-a051-f9746db856cc	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:17:22.24	up	13	\N	tcp
fa9eb7c1-ed51-4f7e-876f-719e63715f15	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:17:25.223	down	3000	TCP connection timed out after 3000ms	tcp
21f5a9b4-9034-46dd-a5f7-dbeb45000273	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:17:52.245	down	3	\N	tcp
db25a1c1-1314-4135-ac6b-49a586a8dcee	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:17:52.248	down	6	\N	tcp
02065cf7-86af-4639-9e00-df5d33931ec3	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:17:52.584	up	324	\N	tcp
56d63a49-1c2f-4013-b4b1-5e34ecb2b543	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:17:54.614	down	2357	connect EHOSTUNREACH 192.168.1.221:3011	tcp
e3abe2c0-b541-49e8-a23a-d1f41c9934f3	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:17:55.253	down	3000	TCP connection timed out after 3000ms	tcp
204ab242-e592-44aa-aed5-64e8274e1a8c	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:18:22.279	down	2	\N	tcp
ce016941-ee1a-4a51-bb5a-47bf8cd23645	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:18:22.314	up	28	\N	tcp
9f3e918d-98ea-4077-8d05-c1cf2b6b5a1c	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:13:52.12	up	16	\N	tcp
8f745fe4-0a2a-4c1c-9f10-6e1583353e90	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:14:22.1	down	5	\N	tcp
4f1ac7d3-f3e9-4fcb-942c-cf797383a62f	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:14:52.105	down	2	\N	tcp
6fe16c2f-d352-4e98-83bf-32a794a03907	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:14:52.108	down	5	\N	tcp
9eca6a1d-dd4b-4b6e-87a8-c102df69445f	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:14:52.115	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
d5dd32c7-ada4-41f5-9685-60b83dc01aa4	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:14:52.115	up	2	\N	tcp
119bc67d-d3c6-4601-90ee-45e6075a7e84	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:14:52.118	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
99073613-5694-4050-8870-2dc31a375821	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:14:52.191	up	75	\N	tcp
aa84e6fb-1d2c-4235-b80c-db11010282e5	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:14:55.113	down	3000	TCP connection timed out after 3000ms	tcp
c04d31d5-a3df-4cd0-a3af-04717fe788fb	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:14:55.118	down	3001	TCP connection timed out after 3000ms	tcp
6144ac28-dcc8-4e98-8f5a-6c86f291755d	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:15:22.134	down	2	\N	tcp
84bb480f-5271-4106-aba3-cd447be9d08d	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:15:52.152	down	2	\N	tcp
7b7288c5-4ea6-4e5c-89d6-c6adbf98d069	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:15:52.196	up	35	\N	tcp
b02b4def-813b-43fc-bfee-d8004831be84	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:16:22.18	down	2	\N	tcp
9da0c5d8-0681-4b8d-bb0f-8071cce21120	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:16:22.182	down	3	\N	tcp
145875d1-d9ff-4ef9-b5b7-6ac34231c3f2	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:16:22.212	up	18	\N	tcp
4a5e976d-b06e-42e2-aac1-d2601df0e16a	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:16:22.212	down	17	connect ECONNREFUSED 10.0.0.200:3100	tcp
a60b762e-eb75-42a9-8324-1c893fde025c	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:16:25.189	down	3000	TCP connection timed out after 3000ms	tcp
ad301f2a-b9b2-4b11-a494-14348b9808cb	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:16:25.195	down	3000	TCP connection timed out after 3000ms	tcp
45c087d7-bf24-4596-9f89-0911421bd3ba	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:17:22.215	up	3	\N	tcp
df35dad5-61ec-4f92-9f23-442e3cae4cfe	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:17:22.225	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
59496ebc-6ad8-4008-ae90-0d41fef41e96	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:17:22.24	up	12	\N	tcp
61645fb6-b408-4908-9cdc-937ee2c246b2	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:17:25.222	down	3000	TCP connection timed out after 3000ms	tcp
6e0acec3-9907-4c5a-a54b-ce8b2554e42c	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:17:25.227	down	2999	TCP connection timed out after 3000ms	tcp
b46e6dd0-b400-4f92-839f-bde05d7e3068	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:17:52.245	down	3	\N	tcp
71335d40-bf91-4903-bcda-61f3bc0f7ec1	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:17:52.254	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
cf9da639-f40a-45b8-9276-9d57b1789eb4	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:17:52.255	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
add2d5e3-8cc2-4452-ac29-8600168b4714	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:17:52.583	down	326	connect ECONNREFUSED 10.0.0.200:3100	tcp
092e3c7f-a043-4612-b28b-f05f5884b035	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:18:22.279	down	2	\N	tcp
6ad3815c-0e41-42df-86fe-49d57207bf62	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:13:52.12	up	17	\N	tcp
2e7fd86d-33c7-42c8-8117-89a00320f785	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:13:52.12	up	17	\N	tcp
052226c0-943a-4d78-bc0b-67f85a650426	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:13:52.12	down	17	connect ECONNREFUSED 10.0.0.200:3100	tcp
1cfe7944-a6a9-427c-9957-a7d6afdfeb72	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:13:52.121	up	10	\N	tcp
efc3c5cf-7261-49dc-a049-94ab3f5b763c	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:13:52.12	up	17	\N	tcp
1c8ff164-133c-4cd0-a47f-0073626600f1	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:13:52.121	up	11	\N	tcp
5de7ed6a-cc70-48db-874e-6d459063485e	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:13:55.104	down	3001	TCP connection timed out after 3000ms	tcp
6252d95e-b91a-4691-a6e5-68bbe173e21c	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:13:55.104	down	3000	TCP connection timed out after 3000ms	tcp
447b21bd-5e20-4f85-8d6c-4c6c308db3f6	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:13:55.109	down	3000	TCP connection timed out after 3000ms	tcp
caf09460-f6b7-42f8-9a5f-18c8e9559253	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:13:55.108	down	3000	TCP connection timed out after 3000ms	tcp
cd640aab-dae4-4d1d-88a2-cc4f0c63b996	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:14:22.097	down	3	\N	tcp
587f2694-0caf-413c-a2a5-38845dc1531c	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:14:22.097	down	3	\N	tcp
c1839843-1070-4a20-96e2-ec943b242d0b	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:14:22.098	down	3	\N	tcp
bf836712-6a9e-4cd2-a57a-229e4755bdf3	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:14:22.098	down	3	\N	tcp
716fe0b5-f254-4e5c-9113-d175eac3f655	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:14:22.098	up	4	\N	tcp
bb5ef72d-c4f7-4ffd-89fe-a666094caf08	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:14:22.098	down	4	\N	tcp
cc962524-244b-4c20-879f-97c8e7547d61	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:14:22.099	down	4	\N	tcp
bfc4a965-2a34-4a87-9f69-7ac0304e62b6	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:14:22.099	down	5	\N	tcp
620795cf-41c1-4f3c-89bc-a8b2ad98a78b	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:14:22.099	down	4	\N	tcp
ac5330dd-f912-4cf5-8d43-69ded5a32066	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:14:22.099	up	5	\N	tcp
0ed7c806-f36b-40d3-bdc5-1eebc369e9dd	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:14:22.101	down	6	\N	tcp
63f64a7c-3201-4455-b4b1-0e039d06635c	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:14:22.101	down	6	\N	tcp
245ccf36-e5ee-4030-a3a4-bda4907c994e	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:14:22.109	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
73d32d9e-060b-4dac-bf7e-7af8ce8396a9	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:14:22.11	down	3	connect ECONNREFUSED 127.0.0.1:8020	tcp
635ac4af-17c3-4fca-8ba6-be1eafba0a0b	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:14:22.111	down	3	connect ECONNREFUSED 127.0.0.1:8556	tcp
03204b48-e063-4a22-8afd-88a11c94b69d	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:14:22.111	down	3	connect ECONNREFUSED 127.0.0.1:8088	tcp
29df34f8-3b97-4788-a868-e1d93d8dd68c	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:14:22.111	down	4	connect ECONNREFUSED 127.0.0.1:4100	tcp
6104467f-be63-405d-a1c0-543874e7a293	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:14:22.111	down	3	connect ECONNREFUSED 127.0.0.1:6875	tcp
ce1b07e1-ec95-48cc-8bfa-a49722a14757	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:14:22.111	up	3	\N	tcp
40b46c37-fb19-4588-a0b4-7fbbb7a5ddd4	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:14:22.11	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
b4a731e1-13c1-4423-97bf-8211ae8e8ced	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:14:22.116	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
1d090850-2c1e-4605-b860-359fa8641952	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:14:22.116	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
51f29858-2e64-4044-9b7a-0c370e05c437	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:14:22.116	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
0175eb2e-7868-4fad-9def-a80e940053dc	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:14:22.117	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
8694573d-8e81-4ac8-9993-7347a7bf8634	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:14:22.14	up	32	\N	tcp
e33d83a7-b34c-4c49-ab77-37ab869476de	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:14:22.14	up	33	\N	tcp
c112d010-ad0f-4575-8048-4bc6ace3ebdd	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:14:22.14	up	32	\N	tcp
46056cc9-958d-4604-93a2-e2158ec0c6ad	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:14:22.14	up	33	\N	tcp
22968249-b103-4601-9ee1-3e7a6c2c3ede	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:14:22.14	up	33	\N	tcp
4beaf557-63c9-4d62-aa02-645931aa5910	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:14:22.143	down	26	connect ECONNREFUSED 10.0.0.200:3100	tcp
009434ec-3d2b-47ff-9748-5320fa38f5e7	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:14:22.143	up	24	\N	tcp
2504a8e9-21fe-400a-9656-fe5d4beb6f19	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:14:22.143	up	25	\N	tcp
145ee041-e1ac-45f6-b27a-cbc82b5fd2cf	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:14:25.108	down	3000	TCP connection timed out after 3000ms	tcp
5bb534d4-1299-40f9-b123-5c07785322cb	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:14:25.109	down	3001	TCP connection timed out after 3000ms	tcp
f87b4fce-fcad-4dc3-8046-03979d264cf7	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:14:52.105	down	2	\N	tcp
f175fecb-3e90-40ec-87ea-78f54c6466bd	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:14:25.112	down	2997	connect EHOSTUNREACH 192.168.1.221:8180	tcp
979e80de-bb99-419c-a579-3e60558e28ce	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:14:52.106	down	3	\N	tcp
a2d68d86-ab18-4ae2-9908-b876e24fced2	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:14:52.115	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
7dc67158-8b55-4e96-8002-caba7e8412ed	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:14:52.118	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
bdda5fc5-a2f2-4819-8772-96760ca7644d	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:14:52.191	up	78	\N	tcp
43ba41ef-2b6a-497e-a4be-2fa0a9b51b3e	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:14:52.192	up	72	\N	tcp
7abb1b78-81d9-43d8-a0b3-95d042cd68f8	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:15:22.135	down	2	\N	tcp
cfc61f1c-4bba-4d5f-9b67-818af0c40fe7	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:15:22.143	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
b8dbe4af-f9b6-44e7-b98f-c18328d0d471	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:15:22.228	up	86	\N	tcp
0c794131-e782-44b2-ac89-e748c1c5d0dc	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:15:52.152	down	1	\N	tcp
5455a4b2-0373-416d-ab19-e164c235fbef	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:15:52.153	down	2	\N	tcp
c51cd516-3c61-4748-a7f6-170c9080eb7d	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:15:52.197	up	36	\N	tcp
387de89c-819e-4b3a-9cb4-d87da92eacf9	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:16:22.19	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
3bd88cc4-20d6-4921-93b8-feab9931b44b	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:16:22.194	down	2	connect ECONNREFUSED 127.0.0.1:8078	tcp
78b2c6bf-e351-468a-8325-f3eb95e8c6a6	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:16:22.211	up	22	\N	tcp
4f9cce02-f7e7-4d1c-8216-44300d348900	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:16:52.195	up	1	\N	tcp
27e558d1-611a-4dda-abc1-010c05a45461	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:16:52.197	down	3	\N	tcp
0bb03078-84dc-44fa-914d-511a53abb7fe	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:16:52.477	up	270	\N	tcp
61132a06-faae-4158-b22a-2a200fc45cd2	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:17:22.214	down	2	\N	tcp
5da7fc14-767e-424e-bb72-e0a816c39c63	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:17:22.215	down	3	\N	tcp
4c2a3654-a4fc-43d1-a56a-2990464e2cb6	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:17:22.225	up	2	\N	tcp
f4520650-620f-4e8c-ab45-04d0a7c9ac61	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:17:22.239	up	16	\N	tcp
5429c75c-8549-470b-91a3-1ab9dec49478	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:17:52.246	down	3	\N	tcp
2f2e47e1-33c1-4d8a-ac13-d6cdb715390d	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:17:52.584	up	327	\N	tcp
fd560edc-bb44-4d1b-ab0c-15fa66cf7c19	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:17:54.614	down	2357	connect EHOSTUNREACH 192.168.1.221:8180	tcp
344a869c-395a-470c-afc6-7018ba98ef6e	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:17:55.254	down	3001	TCP connection timed out after 3000ms	tcp
67fd5c83-957c-45b5-b3d7-c00a9c14315c	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:17:55.257	down	3000	TCP connection timed out after 3000ms	tcp
215f504b-9884-42dc-b838-bf9660a9b882	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:18:22.278	down	2	\N	tcp
e55336c0-16ec-40f9-a488-b58a8b86c56b	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:18:22.28	down	3	\N	tcp
e46df6c2-186a-4e17-82b6-3e0da7fa435b	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:18:22.288	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
2d469197-7482-4dc1-a96b-b926f5282e9e	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:18:22.292	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
6cec69bc-ae6d-4e19-aefb-8083d351f6ed	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:18:22.314	up	28	\N	tcp
09561f88-b456-4e37-901e-6e854ba5518c	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:18:22.316	up	22	\N	tcp
2ac38a57-7140-4997-9d34-61c0dc05606c	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:14:52.104	down	1	\N	tcp
f414edba-4aa5-41dc-a6b4-186fe3a423af	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:15:22.134	down	2	\N	tcp
e413e95c-f24a-4230-b97b-ce94d34afe43	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:15:22.229	up	81	\N	tcp
9dda3a9b-3360-477c-8326-649b143c2b28	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:15:25.141	down	3000	TCP connection timed out after 3000ms	tcp
c1ec9f8a-045b-45a6-a2af-c0af2cbf8788	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:15:25.144	down	3000	TCP connection timed out after 3000ms	tcp
03f1ec44-a674-4c9a-81ed-3b7164aacfeb	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:15:52.153	down	2	\N	tcp
a6407937-31d6-4212-b707-a84d32bc7fc8	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:15:52.155	down	4	\N	tcp
faf0b04b-dc13-4e3b-9106-8b7c5e9e259d	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:15:52.163	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
200ba4b4-6c60-4701-b674-c0036f31e59a	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:15:52.163	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
47b21be5-e6f0-4591-a82a-a73ffcfbcc47	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:15:52.167	down	1	connect ECONNREFUSED 127.0.0.1:9000	tcp
8231bf0b-34ee-41cc-84b5-2ad61779d23a	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:15:52.197	up	28	\N	tcp
52f6e1b7-4f5f-400f-8833-080d51266726	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:15:55.16	down	2999	TCP connection timed out after 3000ms	tcp
e1260651-aab9-4bf8-a63d-3323bb4ce8d6	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:16:22.181	down	2	\N	tcp
81e3475e-8c08-4b45-b716-3a5a31b00354	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:16:52.196	down	2	\N	tcp
18e6a94e-73f9-4900-82d9-fb0755d0bbd6	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:16:52.198	down	4	\N	tcp
00209d59-ec3e-4799-aa79-2baa8eba0c22	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:16:52.204	down	1	connect ECONNREFUSED 127.0.0.1:8080	tcp
4ec26b7f-7457-4a9e-9f5d-4236902ce98a	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:16:52.477	up	274	\N	tcp
8d5e6d44-3ae8-436a-8137-1c036c4d963c	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:17:22.214	down	2	\N	tcp
418b392a-2e51-4a4b-b080-d381dfca9499	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:17:22.216	down	4	\N	tcp
d99cc997-0651-4f92-9a1c-5a95bef51111	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:17:22.224	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
b189a326-82d5-48b6-b024-e15ef83a5a5f	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:17:22.24	down	13	connect ECONNREFUSED 10.0.0.200:3100	tcp
84817c32-0153-48a2-9f91-14733c4e1d5f	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:17:25.223	down	3000	TCP connection timed out after 3000ms	tcp
f43dbb33-2dac-48fe-8e1f-d3877398e20f	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:17:25.227	down	2999	TCP connection timed out after 3000ms	tcp
cac613de-c2d6-483b-a0c4-b875cc2e353b	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:17:52.244	down	2	\N	tcp
dea4d979-1685-4802-a0ad-35a6db5631af	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:17:52.246	down	3	\N	tcp
29dbb7e3-3fff-4a8e-be99-7349cbee62c3	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:17:52.254	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
5f42ee65-7fa8-444e-87a5-4ac01152bf16	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:17:52.582	up	329	\N	tcp
cd2c796e-ec10-47e5-931b-56e8a79eed67	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:18:22.279	down	2	\N	tcp
72520e8b-4e02-4e7c-abe1-e11c23714145	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:18:22.281	down	4	\N	tcp
e933f079-59f0-44cd-b29a-edb75f4e7dac	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:18:22.287	down	1	connect ECONNREFUSED 127.0.0.1:8556	tcp
b07eadaa-744c-4ba1-8a1b-94ececb8825f	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:18:22.316	down	22	connect ECONNREFUSED 10.0.0.200:3100	tcp
039dbcf3-2301-4e88-b924-8d399274b1c7	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:18:25.287	down	3000	TCP connection timed out after 3000ms	tcp
4a9e9f94-80d1-4fcd-bc4c-0c20390e9f4b	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:18:25.291	down	3000	TCP connection timed out after 3000ms	tcp
99b78edc-dd69-4af9-bd6b-868edbf6b3e3	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:14:52.105	down	2	\N	tcp
2c2acc2e-f1f3-4de3-aae4-f3ae2151b3ed	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:14:52.114	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
aa9294a7-f06c-4dc1-b237-a8db9d02f714	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:14:52.191	up	78	\N	tcp
1be95e1b-35f3-40cb-a8be-64f1f2537ebf	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:15:22.134	down	1	\N	tcp
9ec78d5b-3ba8-4e9d-9299-30d1f245c4c9	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:15:22.136	down	3	\N	tcp
120ea46d-7566-475a-b619-d4895e524d76	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:15:22.143	down	1	connect ECONNREFUSED 127.0.0.1:8088	tcp
c16bbe13-c907-4ceb-b722-bfb97f345294	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:15:22.146	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
cb99cb63-af66-48b3-b12d-54696eef8fc9	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:15:22.227	up	86	\N	tcp
7b7af2bd-b04c-4531-9520-c1a10428cfd9	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:15:52.153	down	3	\N	tcp
3618cf18-ae69-4fdf-86d6-0a8b5058ae5b	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:15:52.153	up	3	\N	tcp
dc07a660-bc15-46e0-8827-454cf3d17a2c	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:15:52.162	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
6eb84737-5e12-44dd-a6c7-1e3ab4364373	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:15:52.164	up	3	\N	tcp
b7fb8bd1-b975-4461-94c5-5a0b56ed73c9	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:15:52.163	up	2	\N	tcp
44a6b399-f32e-475e-8c2a-db65afec3a42	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:15:52.167	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
eb08898c-f580-47fc-93da-dad8472d426f	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:16:22.181	up	2	\N	tcp
964d972e-d246-487f-bafd-c6d903befe04	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:16:22.183	down	4	\N	tcp
2a003435-21cf-4f18-baeb-cdd5094c8133	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:16:22.19	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
c48f4e91-9aa8-4831-9f21-1a859b14412e	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:16:22.211	up	18	\N	tcp
55a64cf6-f299-42e5-b710-d7bcaec94bca	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:16:52.196	down	2	\N	tcp
add1e240-772d-4090-9949-e244499e0cdc	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:16:52.204	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
74a378b0-bbea-42ce-bf62-817422a42fd8	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:17:22.215	down	3	\N	tcp
45110732-3b1f-4711-8393-aae90a8d431e	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:17:22.24	up	13	\N	tcp
a1753c92-9e70-409d-9da2-ff3fdef127de	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:17:52.245	down	3	\N	tcp
35fe471e-9b57-4030-a792-b8d47734fa86	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:17:52.255	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
104d938b-bf62-43c3-b1f5-f218a26c7ff8	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:17:52.258	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
ca88b5de-7ef9-4c39-baeb-5ddea4187990	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:17:52.26	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
2dd8ee7d-b04a-40bf-a5aa-24b6a0c92ba4	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:17:52.583	up	326	\N	tcp
0e16d457-08f4-4b60-9760-4cda90f6b92c	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:18:22.279	down	2	\N	tcp
abfa1e7c-8237-4fbe-9c6f-ca8ee3b77206	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:18:22.281	down	4	\N	tcp
a4441359-0400-44df-8d23-c1995248314f	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:18:22.289	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
5775d5ea-ea3c-4417-ad7d-7521eaddb41f	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:18:22.292	down	1	connect ECONNREFUSED 127.0.0.1:8078	tcp
1df1f476-ee53-48d4-91ca-eab964536717	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:18:22.315	up	25	\N	tcp
24a86c46-faa2-4e95-b75c-79c6b92e3f62	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:18:25.286	down	3000	TCP connection timed out after 3000ms	tcp
2485120f-18ef-49cb-bbea-964101a2d67a	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:18:25.291	down	3000	TCP connection timed out after 3000ms	tcp
4e137765-cc4d-447f-8009-af2dc8f88d2f	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:14:52.105	down	2	\N	tcp
5937b789-4f9b-42f7-94b9-d8ca0eff3b36	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:15:22.136	down	3	\N	tcp
a4fea873-5875-4a05-9125-c07c30eb6780	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:15:22.142	down	1	connect ECONNREFUSED 127.0.0.1:8556	tcp
51d8b57e-f17d-4cf7-ba00-b4f3fa1a2d6d	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:15:22.228	up	81	\N	tcp
d986de68-cc1d-4020-9e54-5f58a3e1b11f	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:15:25.141	down	3000	TCP connection timed out after 3000ms	tcp
7b5b9761-5c91-4c07-b87f-cb6005c7cbca	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:15:52.155	down	4	\N	tcp
b4d8b927-5093-4a54-a06d-351b670f3d1b	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:15:52.163	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
ab3d0dd4-796f-4d26-b52b-b7bdeecd5aad	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:15:52.167	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
394979c7-bae5-454a-b437-56fbbb60ea57	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:15:52.197	up	29	\N	tcp
1e9d1829-ec82-444f-a1c3-baf9fd8f6a59	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:15:55.16	down	3000	TCP connection timed out after 3000ms	tcp
37626a38-39e0-43a6-ab08-7c875e58c152	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:16:22.182	down	3	\N	tcp
3d859551-dddb-408f-a72d-876265f63f91	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:16:22.19	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
c42fe8d3-a7c2-42b2-a32b-fffd860ce64c	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:16:22.211	up	23	\N	tcp
ff350b60-105b-4e9d-ba53-c65148c8c55f	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:16:52.197	down	3	\N	tcp
904a40ac-570b-4c62-a46c-8800bd4e46e6	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:16:52.477	up	270	\N	tcp
4ddb723a-6773-4d2e-9516-39e32a86ba06	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:16:55.203	down	3000	TCP connection timed out after 3000ms	tcp
b4ee14f9-80c6-4117-a8a2-d9672f819c4d	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:16:55.209	down	3000	TCP connection timed out after 3000ms	tcp
75fabb2d-9f0e-48a9-937a-23ca1103c00b	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:17:22.214	down	3	\N	tcp
ed72573d-cb2d-4719-9fd6-694083a6b864	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:17:22.216	down	4	\N	tcp
19b79499-851a-4b68-bff5-a272199d95f4	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:17:22.225	down	2	connect ECONNREFUSED 127.0.0.1:9000	tcp
7cf96977-40c4-4cee-a77c-51618a3d28d6	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:17:22.239	up	16	\N	tcp
873faef7-b239-43d8-92a6-ae9de5c3e192	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:17:52.245	down	3	\N	tcp
40b980ce-25ed-487d-a505-71c396978bf8	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:17:52.248	down	6	\N	tcp
e477a7d1-aefc-46ff-b9b5-395b7d85d45c	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:17:52.254	down	1	connect ECONNREFUSED 127.0.0.1:8556	tcp
c1b58d69-f5d1-4d04-b293-dd5dc96a1f41	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:17:52.583	up	330	\N	tcp
7762a7e7-8a2f-4a02-9f20-8e8c0e0661b6	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:18:22.279	down	3	\N	tcp
49e7fbaa-2cb5-43eb-a359-72ce1f7342d9	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:18:22.287	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
bfebd82c-0679-4c85-831b-25f954ba84ad	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:18:22.315	up	28	\N	tcp
b6f1a7ab-ba86-498e-af99-72cc35b5423a	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:14:52.105	down	2	\N	tcp
4d290222-1329-4c82-bdde-53edfa8f0ab0	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:14:52.106	down	2	\N	tcp
975b9e06-ab48-4381-8b2d-fa4ad6d1a150	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:14:52.106	down	3	\N	tcp
88ebe73b-e6cf-40ed-85e7-84ea81ab4430	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:14:52.106	down	3	\N	tcp
b755b543-27ca-481e-89be-7a1a96633e2a	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:14:52.108	down	5	\N	tcp
c94bb3b2-7c60-4737-ae12-58eb3c8b7ee3	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:14:52.114	down	1	connect ECONNREFUSED 127.0.0.1:8020	tcp
9fbabf18-04fd-4c23-aca8-1a7f6e7dcc20	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:14:52.115	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
c66112c2-c2f7-4a2b-a893-5b3443ac0117	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:14:52.115	up	2	\N	tcp
ec6dcf27-6de9-4fb1-b814-1182e10d97e9	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:14:52.115	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
8a690642-9d39-4c52-9da6-0e8a122b771a	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:14:52.118	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
a1da4449-2a89-43be-a484-ca4c3f72d55f	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:14:52.19	up	77	\N	tcp
eef12dbe-24ea-463e-8dca-d4c84742faea	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:14:52.19	up	77	\N	tcp
d9618144-891f-4b7a-b9ce-3c4a55858b86	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:14:52.191	up	78	\N	tcp
b861d63f-05a3-4740-bcd1-3ca7e8448f41	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:14:52.191	up	73	\N	tcp
033cc4f6-0569-438f-b4a8-0aeb8f749967	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:14:52.192	up	72	\N	tcp
760e3f70-fa98-4b25-81fc-1e93443e90e4	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:14:55.113	down	3000	TCP connection timed out after 3000ms	tcp
a0815aa2-6172-45d3-86b1-88df866d0e5e	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:15:22.133	down	1	\N	tcp
9fd3ed9d-a40e-4b5f-93a4-16e6aaf51dfa	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:15:22.134	down	1	\N	tcp
c4e8887c-502b-431c-8e5f-abbbea9f6c5f	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:15:22.134	down	2	\N	tcp
61396d2d-ad10-4b2c-9858-62efa730e71d	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:15:22.135	down	2	\N	tcp
3716ffa7-b969-4476-b36b-df571efcb70f	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:15:22.136	up	4	\N	tcp
3d72e21b-6165-4aa2-8680-b1aee3a2010d	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:15:22.136	down	4	\N	tcp
7d6180dd-1196-4725-9bd6-ef14c4c925d7	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:15:22.137	down	4	\N	tcp
a84eddc2-1c1f-46db-b5a0-545771613486	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:15:22.143	up	2	\N	tcp
4a137ae7-0cd8-4a6a-97d2-11e6cfcf6c56	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:15:22.143	up	2	\N	tcp
abd423e5-8ae8-4cbf-ba5c-a12ee8599d5c	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:15:22.146	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
6888969c-77bb-40a7-9d17-944ce8560228	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:15:22.227	up	86	\N	tcp
58e2baf4-152e-4ce3-8008-47c07550a6cd	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:15:22.227	up	86	\N	tcp
9164c2cf-d7ee-4496-a731-c2c71f7d6895	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:15:22.228	up	82	\N	tcp
33052e56-0db6-4b88-aecf-65f2d6aafcd5	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:15:22.229	down	81	connect ECONNREFUSED 10.0.0.200:3100	tcp
4193c7ca-fe11-442d-a185-8294a6616829	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:15:25.141	down	3000	TCP connection timed out after 3000ms	tcp
217cfa41-73f1-4f19-9664-df82c902a03c	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:15:25.142	down	3000	TCP connection timed out after 3000ms	tcp
30fcc472-585d-423f-b309-b5af7907aa25	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:15:52.152	down	1	\N	tcp
d311ef54-825a-4b3f-acb3-ccaabd604728	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:15:52.152	up	1	\N	tcp
671b2f6a-e903-4875-ba14-5aaccfac00d6	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:15:52.153	down	2	\N	tcp
94b531a8-e297-457a-a607-a449b90f7772	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:15:52.154	down	3	\N	tcp
6df484bc-547e-4b6b-9bb0-2e1858acca09	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:15:52.154	down	3	\N	tcp
6cd73a95-3e84-4b9e-be39-d774496a7044	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:15:52.155	down	4	\N	tcp
5cc00a1a-8e97-4795-bebe-53709e6389e7	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:15:52.163	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
340e6674-a9be-4b1b-91f5-b866443d5146	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:15:52.163	down	3	connect ECONNREFUSED 127.0.0.1:4100	tcp
b01f0d2e-9111-46a8-bda9-338c8345d33a	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:15:52.167	down	1	connect ECONNREFUSED 127.0.0.1:9001	tcp
650c6d83-4d72-4785-9617-0649d83bf0eb	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:15:52.196	up	36	\N	tcp
847ebfa8-ae3a-4e86-a097-727f94d9bc66	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:15:52.197	up	30	\N	tcp
ccd9ec54-2d3b-43d9-b182-cbc971efbfec	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:15:52.197	up	30	\N	tcp
396940e8-32ad-48cf-82ad-741c37565a9b	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:15:55.162	down	3001	TCP connection timed out after 3000ms	tcp
9bb3edad-d647-44cd-9f5d-d5d1c6cd1daa	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:16:22.181	down	2	\N	tcp
1d35b9df-e466-42d7-b572-f4fd6dc9eb69	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:16:22.181	down	2	\N	tcp
6584d04d-6bdc-4b8f-9c37-66e3bc5784ac	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:16:22.183	down	3	\N	tcp
9815cfd8-d829-48b5-910c-3f37db64690f	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:16:22.183	up	4	\N	tcp
45dc208e-e325-47c6-9b5f-088d2cf15ca5	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:16:22.191	up	2	\N	tcp
be1379d3-1a32-45de-89ee-3b7f1a15aad1	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:16:22.191	up	2	\N	tcp
c557678e-874e-4b6e-a515-7a67fcdabc3c	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:16:22.211	up	22	\N	tcp
1359ed31-75db-4ea4-a96c-de10fe52dc67	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:16:52.195	down	2	\N	tcp
46e4aaf0-60da-4c10-a149-6b1c9ce0755a	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:16:52.204	down	2	connect ECONNREFUSED 127.0.0.1:8556	tcp
8bf0a799-7a25-4d33-aa1e-e69404c17912	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:16:52.477	up	270	\N	tcp
ba77a5a0-9dce-4f3d-9432-4321576e5578	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:17:22.214	up	2	\N	tcp
946aa410-0b6a-4028-af0b-5f7e86efcfa3	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:17:22.217	down	4	\N	tcp
4886ec03-a183-4b7b-bcf7-b3b9f7a5a5b5	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:17:22.224	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
d39f2a5e-f6f3-456f-900a-a7ec8e0fa81c	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:17:22.239	up	16	\N	tcp
98aea82a-0007-47f6-b30b-e408353fda0a	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:17:22.24	up	13	\N	tcp
4f4558ec-48b7-4f33-a57d-54004aabe97e	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:17:25.223	down	3000	TCP connection timed out after 3000ms	tcp
5b355539-d268-4c3a-956a-20b93addacdb	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:17:25.229	down	3001	TCP connection timed out after 3000ms	tcp
be4a4cb0-661c-4daa-8ed2-771321b2a511	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:17:52.245	down	2	\N	tcp
b74695c6-75d5-4aaf-9bc6-81e89ac562c1	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:18:22.278	down	2	\N	tcp
2634e3ad-c120-4d28-95d4-c3228296d904	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:18:22.28	down	3	\N	tcp
65bc19ec-98f6-4ce0-b207-d8fe8520e8c7	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:18:22.289	up	2	\N	tcp
a6f998f9-ca91-4b7f-b1ad-46fbef0f7ecf	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:18:22.292	down	1	connect ECONNREFUSED 127.0.0.1:9006	tcp
be6f25e8-60db-4144-9896-d96709fd354d	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:18:22.315	up	28	\N	tcp
b4e64e9f-67e7-46c8-ab52-cb9b16ab5b8d	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:16:22.181	down	2	\N	tcp
2c5142ee-d2be-40cb-8681-b5e14fa9a449	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:16:52.195	down	2	\N	tcp
96f3a5eb-33bf-4c7b-8a46-b3ee0f754469	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:17:22.214	down	2	\N	tcp
3441f0f2-c42b-4eff-baee-b6905a8bdd72	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:17:22.224	down	2	connect ECONNREFUSED 127.0.0.1:8080	tcp
4ab35854-23fd-4bcd-a68b-9b027cbe9b39	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:17:22.239	up	16	\N	tcp
6728150d-2b5a-4127-97b0-a3eb18f62e80	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:17:52.244	down	2	\N	tcp
822d2edf-6258-405e-9537-e5e598845fc3	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:17:52.246	down	4	\N	tcp
5b4500b7-5a63-44ce-9772-1c932ea9a5c7	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:17:52.255	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
2d722f47-72ad-482d-b522-63d0e1ae0b6f	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:17:52.582	up	329	\N	tcp
da3bbe7b-26ed-41bb-8d76-6ea8961c943e	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:16:22.181	down	2	\N	tcp
218e67ce-7ca6-473c-9604-c6e59765bcd9	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:16:22.212	up	18	\N	tcp
c3cf9cbf-e013-47d5-b615-a40d6dbac87b	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:16:22.212	up	18	\N	tcp
b6bfa02d-9a5a-41b8-9e8f-47ab57288303	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:16:25.188	down	3000	TCP connection timed out after 3000ms	tcp
6e60b68b-9586-464b-b3c1-ad3a7a874a8a	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:16:25.196	down	3000	TCP connection timed out after 3000ms	tcp
0accf2eb-b77d-42c8-8608-1f47a8793493	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:16:52.197	down	3	\N	tcp
982c2c83-b10a-49fd-ae94-34e707c356d5	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:16:52.197	down	3	\N	tcp
72c141b1-7bed-449a-8f42-52fd744f0532	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:16:52.204	up	1	\N	tcp
8234323c-5309-4193-b649-f83eda2185bf	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:16:52.204	down	2	connect ECONNREFUSED 127.0.0.1:8555	tcp
dedee8e9-30b6-4233-9d08-ff848c05d2c8	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:16:52.477	up	270	\N	tcp
edfab8b8-f7e2-430e-850d-1c5ce00f1acf	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:17:22.215	down	3	\N	tcp
d48df54a-04e3-4365-a8ba-4ec3bbb3900e	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:17:22.217	down	5	\N	tcp
90c63ade-6047-40d7-ab43-ca83b34488f0	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:17:22.225	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
5235c067-e1a0-4131-a9c2-965b31e897c3	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:17:22.228	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
e5a63b51-4016-455f-a69c-eb204f14e000	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:17:22.23	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
afa57f48-db03-40c7-adad-8f31e53b9523	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:17:22.232	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
9acbe497-a0ae-485b-aa00-5ac7ccd340d5	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:17:22.234	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
6bbfea42-54a6-4c19-882c-f9273fe35c4c	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:17:22.239	up	16	\N	tcp
7872eff1-3874-4778-8586-8fb4994dda2a	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:17:52.244	down	1	\N	tcp
da60159b-a0d2-4d31-a5bd-94cd9d8556f3	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:17:52.247	down	4	\N	tcp
038d3dab-e279-4647-a3f8-74ddd35d7aff	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:17:52.255	down	2	connect ECONNREFUSED 127.0.0.1:8088	tcp
ea924d33-60ec-4079-b6a3-bac385b9f9a9	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:17:52.258	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
f7d7f887-945f-4988-a28a-b14dce069d10	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:17:52.584	up	324	\N	tcp
df40b38c-422e-43a1-95f9-2d93e51234be	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:18:22.278	down	2	\N	tcp
ca81fa80-7385-44cd-81c8-802dca9535dc	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:18:22.28	down	3	\N	tcp
03b55682-7d7a-4faa-9a9d-0a9bd6c36237	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:18:22.288	down	2	connect ECONNREFUSED 127.0.0.1:6875	tcp
009722f6-fa57-4133-aeae-98b1ee36b7e6	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:18:22.292	down	1	connect ECONNREFUSED 127.0.0.1:9020	tcp
0a321983-5a39-44cc-80a8-f78b154b023f	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:18:22.315	up	22	\N	tcp
14a74fea-d9eb-4529-a3de-9edccfd91ff0	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:16:22.182	down	3	\N	tcp
e5e86f14-fa8a-4bf8-9e21-e3a165150bfc	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:16:22.189	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
7da63246-1826-43a1-b552-8263219dfcb9	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:16:22.211	up	18	\N	tcp
4af6ec1e-4ecf-4e72-ad4a-d84877dd9835	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:16:52.195	down	1	\N	tcp
df01ea73-4289-466c-820d-b8a446f3c79c	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:16:52.197	down	3	\N	tcp
fae414c3-7662-4cc1-ad91-bf49fff77601	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:16:52.204	down	1	connect ECONNREFUSED 127.0.0.1:8088	tcp
9c89b167-0e6f-4824-937f-3a62915f5ea9	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:16:52.205	down	2	connect ECONNREFUSED 127.0.0.1:9001	tcp
50a8fd3a-10fd-42f2-a579-0c17d727358a	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:16:52.476	up	274	\N	tcp
2b801e82-ac0b-49df-aea3-682fd900ad50	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:16:52.477	up	270	\N	tcp
79a984e1-da4e-4ccd-a3cd-b1007d0b8e06	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:17:22.216	down	4	\N	tcp
86b66589-b771-4a29-ab45-c05d4f12db1a	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:17:52.246	down	3	\N	tcp
68b247ce-f7cf-4381-adcb-6357fbc4c8c0	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:17:52.255	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
5fb74ab3-3ec7-4075-99a2-1b6203d94d5e	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:17:52.258	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
18c5f6ad-bd26-4d06-b5cd-a8925d266b61	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:17:52.583	up	330	\N	tcp
9693be59-42af-4341-84ec-3017cba2a14b	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:17:52.584	up	324	\N	tcp
40ded0d3-f837-4866-8fcd-72ba9d58dd1f	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:17:54.614	down	2361	connect EHOSTUNREACH 192.168.1.221:4001	tcp
30015ebb-66d1-415f-833d-4ab875554011	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:17:55.253	down	3000	TCP connection timed out after 3000ms	tcp
0165362c-9ca8-4fb2-8853-fa4d040da037	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:18:22.279	down	2	\N	tcp
cf81b028-cece-459a-ad06-4beb6cded73a	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:18:22.314	up	28	\N	tcp
263ff914-7f05-4a3d-8c01-21588cda3f67	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:18:25.286	down	3000	TCP connection timed out after 3000ms	tcp
104c95d3-2145-4348-8473-326b786f8b92	port	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	Port 3009	2026-10-05 06:18:52.303	down	1	\N	tcp
1b5cbff3-f09a-491f-b139-fb883e87cad7	port	b2115ceb-b541-4c57-8c81-e9fc67989260	Port 60008	2026-10-05 06:18:52.305	down	3	\N	tcp
74127e2a-2f60-4787-b8ea-3a0518443158	port	11295648-cb50-419e-ae47-ee7a458b63c1	Port 10080	2026-10-05 06:18:52.303	down	2	\N	tcp
13d957e1-fe19-4e88-8aac-89aecba4bf56	port	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	Port 80	2026-10-05 06:18:52.308	up	7	\N	tcp
87198986-b766-4ca3-9bf9-eac9cf0a251b	port	b01c4726-e22b-4760-be21-2106c644f07d	Port 4020	2026-10-05 06:18:52.303	down	1	\N	tcp
fb7a254b-49a9-4a19-b36e-6e6a97378853	port	96949b28-e145-4028-a00e-af2cc7657073	Port 60009	2026-10-05 06:18:52.304	down	2	\N	tcp
22c3baaa-3f29-49a7-bd1f-4c644e9e3ccb	port	c6f3c962-4d9e-4584-baf6-08c9a0847815	Port 10081	2026-10-05 06:18:52.303	down	1	\N	tcp
150980d4-d12b-4d2c-923c-af2f1e7e33fd	port	3be57a72-25ab-4961-a7f1-f3973a9319fe	Port 7003	2026-10-05 06:18:52.309	down	7	\N	tcp
14021255-df29-4944-a6fa-86164905ead2	port	d46d821e-0752-40d3-9408-4fc60b0355c5	Port 7002	2026-10-05 06:18:52.309	down	7	\N	tcp
16be546d-a8e0-45c1-a39a-987f6f4b0c0d	port	dd1361b7-c5a2-4123-937a-11f62570ad6e	Port 3022	2026-10-05 06:18:52.303	down	1	\N	tcp
14e728b3-f74b-4ccd-87c8-ffc2fb0df86f	port	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	Port 4000	2026-10-05 06:18:52.303	down	2	\N	tcp
eb647d18-0799-42f1-83ed-546359cbf821	port	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	Port 10181	2026-10-05 06:18:52.308	down	6	\N	tcp
074a0177-83d1-4556-bcf8-6ed710887908	port	eb7162c7-530f-4aed-8c96-2b32940e6734	Port 3021	2026-10-05 06:18:52.308	down	6	\N	tcp
7c116161-437a-477f-9612-f96f92765398	port	42138f4f-65a2-4291-a571-3c7f720d2921	Port 28096	2026-10-05 06:18:52.308	down	7	\N	tcp
b60f7c67-cc41-4f72-864a-3dd8fc828e69	port	f8163d47-80ea-44d2-b0ba-ad68c70ec123	Port 60007	2026-10-05 06:18:52.309	down	7	\N	tcp
911cac83-6479-40f3-b617-50a295b45949	port	534fe14c-dcfa-485a-b48f-bd474a096613	Port 7001	2026-10-05 06:18:52.304	down	2	\N	tcp
23752663-f669-4e48-8104-7c68696b8d9c	port	b8d9465b-b156-4a71-902d-9846891346a0	Port 443	2026-10-05 06:18:52.305	up	3	\N	tcp
c3b6caa3-3f23-4793-b9fc-2ca4f9930c53	port	35fb4359-7c66-4d29-b21f-868fa30cf1bb	Port 8080	2026-10-05 06:18:52.304	down	3	\N	tcp
92c84143-1080-4382-a5cf-2ae7d8dc1e04	port	ccbc4c63-b042-48b0-85c1-cddf26463e50	Port 10180	2026-10-05 06:18:52.303	down	2	\N	tcp
3be7f634-7775-40fc-82df-efadd084943e	backend	1341092e-90ea-4bc4-8007-385460b87942	$jellyfin (variable):8096	2026-10-05 06:18:52.331	down	1	getaddrinfo ENOTFOUND $jellyfin (variable)	tcp
9dba7339-1276-4a7f-9a0a-5180edbe8516	backend	24582c1a-a546-46a6-a89e-2a80fe8ef43c	localhost:8088	2026-10-05 06:18:52.331	down	1	connect ECONNREFUSED 127.0.0.1:8088	tcp
70e520c1-a954-47d0-ae30-e1ca35b0fe34	backend	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	localhost:8555	2026-10-05 06:18:52.332	down	1	connect ECONNREFUSED 127.0.0.1:8555	tcp
5a2af6d3-36fe-4389-a15f-3fa9bd038cdf	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	2026-10-05 06:18:52.331	up	1	\N	tcp
426ef0bc-194d-4cec-84c3-c47639ec4482	backend	319957bc-1b42-4760-a62f-f99702ed7287	localhost:8556	2026-10-05 06:18:52.332	down	1	connect ECONNREFUSED 127.0.0.1:8556	tcp
2c113b8e-4d11-4af9-b7fd-ed73c515f9f1	backend	f060df71-9a9e-4de5-9298-a00f4facba0b	localhost:6875	2026-10-05 06:18:52.332	down	1	connect ECONNREFUSED 127.0.0.1:6875	tcp
a67dbf61-4668-4af7-b8e4-694235b163fa	backend	f818583c-c73b-4ce9-bbf5-1601cb636f9e	localhost:8080	2026-10-05 06:18:52.332	down	1	connect ECONNREFUSED 127.0.0.1:8080	tcp
e240a7f7-08a8-4acf-b13d-ebc16fe75406	backend	70069108-249c-4a7e-b962-1f00c3416dbb	localhost:3001	2026-10-05 06:18:52.332	up	2	\N	tcp
14da714d-5766-4a06-ae4e-8153300b4238	backend	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	localhost:9006	2026-10-05 06:18:52.337	down	0	connect ECONNREFUSED 127.0.0.1:9006	tcp
6ff3a664-22cf-4b84-b48a-e4a6bf05fe3b	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	2026-10-05 06:18:52.684	up	354	\N	tcp
64a5a59f-0038-4ffb-a7b4-6aee38cfba79	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	2026-10-05 06:18:52.686	up	348	\N	tcp
fe9f2a69-ea92-4547-9cfd-9be8d54770fe	backend	bc543403-17de-4254-8b46-4c2234f6a578	192.168.1.221:4001	2026-10-05 06:18:55.33	down	3000	TCP connection timed out after 3000ms	tcp
e4b05ad1-c53e-4def-ab64-803c00185ffb	backend	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	192.168.1.222:8787	2026-10-05 06:18:55.337	down	3000	TCP connection timed out after 3000ms	tcp
23a52287-2367-4489-afd3-ab20a0fac0a9	backend	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	localhost:8020	2026-10-05 06:18:52.332	down	2	connect ECONNREFUSED 127.0.0.1:8020	tcp
e7060220-bb29-4482-8155-e418faa04605	backend	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	localhost:8078	2026-10-05 06:18:52.336	down	0	connect ECONNREFUSED 127.0.0.1:8078	tcp
be9383f5-9728-43ea-865e-c81e244b1f33	backend	4b6d69ef-36a2-453a-bae1-02a7500c4225	localhost:9020	2026-10-05 06:18:52.337	down	0	connect ECONNREFUSED 127.0.0.1:9020	tcp
643b151e-2c29-4a23-9458-4fc8fc455da9	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	2026-10-05 06:18:52.686	up	355	\N	tcp
1d3fa637-ff85-4999-abe0-3845b67415ed	backend	f983d605-e989-4489-aa32-cf13fa3859b4	192.168.1.222:8080	2026-10-05 06:18:55.331	down	3001	TCP connection timed out after 3000ms	tcp
991dd0d7-bf46-4404-9638-59a0e42d57ed	backend	137e2e5e-b96f-4e8a-aaff-1dca0da29923	192.168.1.221:3011	2026-10-05 06:18:55.336	down	3001	TCP connection timed out after 3000ms	tcp
90868af2-47b6-42b7-8729-448c326f0fdc	backend	47012dbc-c20f-4924-9007-6448b27e32cd	localhost:4100	2026-10-05 06:18:52.332	down	2	connect ECONNREFUSED 127.0.0.1:4100	tcp
4e84bc0f-e7ad-4eb7-a284-19345e57e9cb	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	2026-10-05 06:18:52.684	up	354	\N	tcp
5332ed07-3b91-4f90-9a78-9c86be446ac6	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	2026-10-05 06:18:52.686	up	355	\N	tcp
029ef335-dbdf-4271-90ea-5d10fba4d6bd	backend	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	192.168.1.222:8082	2026-10-05 06:18:55.331	down	3000	TCP connection timed out after 3000ms	tcp
ce40be5d-215f-4c5d-88c1-dfe51b3fbb16	backend	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	localhost:9000	2026-10-05 06:18:52.335	down	0	connect ECONNREFUSED 127.0.0.1:9000	tcp
59969af9-102f-4980-bf63-2e516232d31e	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	2026-10-05 06:18:52.685	up	347	\N	tcp
a7141d4f-c9db-4160-bc20-e0aab3aa638d	backend	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	localhost:9001	2026-10-05 06:18:52.336	down	0	connect ECONNREFUSED 127.0.0.1:9001	tcp
ec52d36f-c0bc-4273-a25f-714fd0a4d33c	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	2026-10-05 06:18:52.686	up	347	\N	tcp
cf283e93-53a1-490c-8449-1a5f0aa1942c	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	2026-10-05 06:18:52.685	up	355	\N	tcp
83fe9191-344c-4dd7-bc36-80f0d6c463aa	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	2026-10-05 06:18:52.685	up	355	\N	tcp
f46e7d4a-26c7-49f4-aea3-893a57e6654d	backend	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	10.0.0.200:3100	2026-10-05 06:18:52.685	down	350	connect ECONNREFUSED 10.0.0.200:3100	tcp
b8f7be2a-9d64-42b3-90a0-374bf0aaac4b	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	2026-10-05 06:18:52.685	up	350	\N	tcp
7c0e109e-813b-47f4-87dd-b906957e7d22	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	2026-10-05 06:18:52.686	up	348	\N	tcp
cd8e2f23-a6f9-4f58-919c-cd2294e58db0	backend	dc188d16-4828-4521-b0a1-63a42113fd9c	192.168.1.222:82	2026-10-05 06:18:55.331	down	3001	TCP connection timed out after 3000ms	tcp
ea301591-be74-4710-a993-37116183e886	backend	0de000ed-8f0d-4886-8432-02a6ae7436be	192.168.1.221:8180	2026-10-05 06:18:55.335	down	3000	TCP connection timed out after 3000ms	tcp
\.


--
-- Data for Name: ports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ports (id, port, layer, protocol, purpose, "processName", pid, "listenAddress", "isPublic", "isExpected", status, "latencyMs", "lastCheckedAt", "lastSeenUpAt", tags, notes, "customValues", "createdAt", "updatedAt") FROM stdin;
06d2bfae-95a4-4d90-b491-a0b2474dc8d0	4000	http	HTTPS	Alternate HTTPS port (apps proxied to backends)	\N	\N	0.0.0.0	t	t	down	2	2026-10-05 06:18:52.303	\N	{http}	\N	\N	2026-10-05 04:56:20.032	2026-10-05 06:18:52.304
4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	10181	http	HTTP	Plain HTTP - school security web app	\N	\N	0.0.0.0	t	t	down	6	2026-10-05 06:18:52.308	\N	{http}	\N	\N	2026-10-05 04:56:20.047	2026-10-05 06:18:52.309
35fb4359-7c66-4d29-b21f-868fa30cf1bb	8080	http	HTTP	Local nginx monitoring (stub_status)	\N	\N	127.0.0.1	f	t	down	3	2026-10-05 06:18:52.304	\N	{http}	\N	\N	2026-10-05 04:56:20.037	2026-10-05 06:18:52.305
8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	3009	http	HTTPS	Alternate HTTPS port (ERP apps)	\N	\N	0.0.0.0	t	t	down	1	2026-10-05 06:18:52.303	\N	{http}	\N	\N	2026-10-05 04:56:20.024	2026-10-05 06:18:52.303
b2115ceb-b541-4c57-8c81-e9fc67989260	60008	stream	TCP	Raw TCP proxy (not HTTP)	\N	\N	0.0.0.0	t	t	down	3	2026-10-05 06:18:52.305	\N	{stream,tcp}	\N	\N	2026-10-05 04:56:20.061	2026-10-05 06:18:52.308
42138f4f-65a2-4291-a571-3c7f720d2921	28096	http	HTTP	Plain HTTP - media server (catch-all)	\N	\N	0.0.0.0	t	t	down	7	2026-10-05 06:18:52.308	\N	{http}	\N	\N	2026-10-05 04:56:20.049	2026-10-05 06:18:52.309
1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	80	http	HTTP	HTTP - redirects to HTTPS (or 404)	\N	\N	::	t	t	up	7	2026-10-05 06:18:52.308	2026-10-05 06:18:52.308	{http}	\N	\N	2026-10-05 04:56:20.016	2026-10-05 06:18:52.309
d46d821e-0752-40d3-9408-4fc60b0355c5	7002	stream	TCP	Raw TCP proxy (not HTTP)	\N	\N	0.0.0.0	t	t	down	7	2026-10-05 06:18:52.309	\N	{stream,tcp}	\N	\N	2026-10-05 04:56:20.054	2026-10-05 06:18:52.309
11295648-cb50-419e-ae47-ee7a458b63c1	10080	http	HTTP	Plain HTTP - school bus app	\N	\N	0.0.0.0	t	t	down	2	2026-10-05 06:18:52.303	\N	{http}	\N	\N	2026-10-05 04:56:20.04	2026-10-05 06:18:52.304
c6f3c962-4d9e-4584-baf6-08c9a0847815	10081	http	HTTP	Plain HTTP - BAN web app (catch-all)	\N	\N	0.0.0.0	t	t	down	1	2026-10-05 06:18:52.303	\N	{http}	\N	\N	2026-10-05 04:56:20.042	2026-10-05 06:18:52.304
3be57a72-25ab-4961-a7f1-f3973a9319fe	7003	stream	TCP	Raw TCP proxy (not HTTP)	\N	\N	0.0.0.0	t	t	down	7	2026-10-05 06:18:52.309	\N	{stream,tcp}	\N	\N	2026-10-05 04:56:20.056	2026-10-05 06:18:52.31
dd1361b7-c5a2-4123-937a-11f62570ad6e	3022	http	HTTPS	Alternate HTTPS port (ems super-admin)	\N	\N	0.0.0.0	t	t	down	1	2026-10-05 06:18:52.303	\N	{http}	\N	\N	2026-10-05 04:56:20.029	2026-10-05 06:18:52.303
f8163d47-80ea-44d2-b0ba-ad68c70ec123	60007	stream	TCP	Raw TCP proxy (not HTTP)	\N	\N	0.0.0.0	t	t	down	7	2026-10-05 06:18:52.309	\N	{stream,tcp}	\N	\N	2026-10-05 04:56:20.058	2026-10-05 06:18:52.31
b01c4726-e22b-4760-be21-2106c644f07d	4020	http	HTTPS	Alternate HTTPS port (warehouse backend)	\N	\N	0.0.0.0	t	t	down	1	2026-10-05 06:18:52.303	\N	{http}	\N	\N	2026-10-05 04:56:20.035	2026-10-05 06:18:52.304
96949b28-e145-4028-a00e-af2cc7657073	60009	stream	TCP	Raw TCP proxy (not HTTP)	\N	\N	0.0.0.0	t	t	down	2	2026-10-05 06:18:52.304	\N	{stream,tcp}	\N	\N	2026-10-05 04:56:20.064	2026-10-05 06:18:52.305
eb7162c7-530f-4aed-8c96-2b32940e6734	3021	http	HTTPS	Alternate HTTPS port (ems.leadows.com)	\N	\N	0.0.0.0	t	t	down	6	2026-10-05 06:18:52.308	\N	{http}	\N	\N	2026-10-05 04:56:20.027	2026-10-05 06:18:52.309
534fe14c-dcfa-485a-b48f-bd474a096613	7001	stream	TCP	Raw TCP proxy (not HTTP)	\N	\N	0.0.0.0	t	t	down	2	2026-10-05 06:18:52.304	\N	{stream,tcp}	\N	\N	2026-10-05 04:56:20.051	2026-10-05 06:18:52.305
ccbc4c63-b042-48b0-85c1-cddf26463e50	10180	http	HTTP	Plain HTTP - school security API	\N	\N	0.0.0.0	t	t	down	2	2026-10-05 06:18:52.303	\N	{http}	\N	\N	2026-10-05 04:56:20.044	2026-10-05 06:18:52.304
b8d9465b-b156-4a71-902d-9846891346a0	443	http	HTTPS	HTTPS - main public port	\N	\N	0.0.0.0	t	t	up	3	2026-10-05 06:18:52.305	2026-10-05 06:18:52.305	{http}	\N	\N	2026-10-05 04:56:20.022	2026-10-05 06:18:52.306
\.


--
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.routes (id, "rowNum", domain, "domainRaw", "isCatchAll", "portId", "portNum", "portRaw", protocol, path, paths, action, "targetRaw", "targetType", "backendId", "staticRoot", "redirectCode", "configFileId", notes, flags, "customValues", "createdAt", "updatedAt") FROM stdin;
94fa99b6-1991-403d-8e46-65860faf1424	1	abg.leadows.com	abg.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Proxy	http://10.0.0.100:8090	url	a7a3748e-e607-4880-9c19-c642e6557535	\N	\N	6a8cacef-05c8-4cd9-ab9b-8b8515aff050		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.336	2026-10-05 05:46:01.336
28b71efd-6b29-4c0d-ac47-36f8ea7404c4	2	abg.leadows.com	abg.leadows.com	f	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	80	80	HTTP	/	{/}	Redirect	301 -> https://abg.leadows.com	redirect	\N	\N	301	6a8cacef-05c8-4cd9-ab9b-8b8515aff050		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.34	2026-10-05 05:46:01.34
8190e88b-4c6f-4695-8a29-f14e427104f4	3	akhbar.mahdibagh.net	akhbar.mahdibagh.net	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Proxy	upstream: publisher	upstream	\N	\N	\N	8d29aff6-91c7-4a3a-ad00-c175239226c4	Upstream address not captured	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.342	2026-10-05 05:46:01.342
dda787a3-8da1-4404-8411-0023d90f440b	4	akhbar.mahdibagh.net	akhbar.mahdibagh.net	f	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	80	80	HTTP	/	{/}	Redirect	301 -> HTTPS (otherwise 404)	redirect	\N	\N	301	8d29aff6-91c7-4a3a-ad00-c175239226c4		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.343	2026-10-05 05:46:01.343
1c99c711-d211-4db0-a3ff-9f8b8a4fdc3f	5	app.schoolsecurity.uz	app.schoolsecurity.uz	f	4d34e9a3-a0c5-4c71-82e6-2f257e36ed61	10181	10181	HTTP	/	{/}	Static	root /usr/share/nginx/html/webapp.schoolsecurity.uz	static_root	\N	/usr/share/nginx/html/webapp.schoolsecurity.uz	\N	c5a4b892-5937-4bce-a69e-5e15c40c6426	Plain HTTP (SSL block commented out)	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.344	2026-10-05 05:46:01.344
27409e6a-125d-480d-9a4e-044614ef4ced	6	ban.leadows.com	ban.leadows.com (server_name _)	t	c6f3c962-4d9e-4584-baf6-08c9a0847815	10081	10081	HTTP	/api/	{/api/}	Proxy	http://127.0.0.1:4100	url	47012dbc-c20f-4924-9007-6448b27e32cd	\N	\N	b4c1aa4e-ffc9-4ddc-8dcb-0b208d201fee	Catch-all server_name _ ; plain HTTP (SSL commented out); also listens on IPv6	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.346	2026-10-05 05:46:01.346
934ae9be-1ee7-4980-a020-03b513afc6bc	7	ban.leadows.com	ban.leadows.com (server_name _)	t	c6f3c962-4d9e-4584-baf6-08c9a0847815	10081	10081	HTTP	/files/	{/files/}	Proxy	http://127.0.0.1:4100/api/files/	url	47012dbc-c20f-4924-9007-6448b27e32cd	\N	\N	b4c1aa4e-ffc9-4ddc-8dcb-0b208d201fee	Legacy image URLs (pre S3 API)	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.347	2026-10-05 05:46:01.347
69d004cb-0705-4664-96cc-25cbb4bae41c	8	ban.leadows.com	ban.leadows.com (server_name _)	t	c6f3c962-4d9e-4584-baf6-08c9a0847815	10081	10081	HTTP	/assets/	{/assets/}	Static	root .../ban-web-app/apps/web/dist (cache 1y)	static_root	\N	.../ban-web-app/apps/web/dist (cache 1y)	\N	b4c1aa4e-ffc9-4ddc-8dcb-0b208d201fee		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.348	2026-10-05 05:46:01.348
cf967e9a-b30c-4a71-b79a-50613f480c6e	9	ban.leadows.com	ban.leadows.com (server_name _)	t	c6f3c962-4d9e-4584-baf6-08c9a0847815	10081	10081	HTTP	/sw.js	{/sw.js}	Static	root .../ban-web-app/apps/web/dist (no-cache)	static_root	\N	.../ban-web-app/apps/web/dist (no-cache)	\N	b4c1aa4e-ffc9-4ddc-8dcb-0b208d201fee		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.35	2026-10-05 05:46:01.35
f4074d97-c362-45a4-ab30-9f63f785bd8b	10	ban.leadows.com	ban.leadows.com (server_name _)	t	c6f3c962-4d9e-4584-baf6-08c9a0847815	10081	10081	HTTP	/manifest.webmanifest	{/manifest.webmanifest}	Static	root .../ban-web-app/apps/web/dist (no-cache)	static_root	\N	.../ban-web-app/apps/web/dist (no-cache)	\N	b4c1aa4e-ffc9-4ddc-8dcb-0b208d201fee		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.351	2026-10-05 05:46:01.351
a29fd9ae-6b33-459b-b6bb-203fc93359c6	11	ban.leadows.com	ban.leadows.com (server_name _)	t	c6f3c962-4d9e-4584-baf6-08c9a0847815	10081	10081	HTTP	/	{/}	Static	root /dataDrive/BusinessAllianceNetwork/ban-web-app/apps/web/dist (SPA)	static_root	\N	/dataDrive/BusinessAllianceNetwork/ban-web-app/apps/web/dist (SPA)	\N	b4c1aa4e-ffc9-4ddc-8dcb-0b208d201fee	client_max_body_size 6m	{"rateLimit": false, "websocket": false, "maxUploadSize": "6m", "hasUploadLimit": true}	\N	2026-10-05 05:46:01.352	2026-10-05 05:46:01.352
28a89def-01cc-4c3e-9c92-bfeffb0f1b53	12	books.leadows.com	books.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/live/project/	{/live/project/}	Proxy	(target not captured)	unknown	\N	\N	\N	f4fd77fd-c085-4c27-9a7b-0bff29f2aaf6	Check conf for target	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.353	2026-10-05 05:46:01.353
7f090877-bd55-444c-abcd-14c52fc354b9	13	books.leadows.com	books.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/api/	{/api/}	Proxy	http://127.0.0.1:3001	url	70069108-249c-4a7e-b962-1f00c3416dbb	\N	\N	f4fd77fd-c085-4c27-9a7b-0bff29f2aaf6		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.354	2026-10-05 05:46:01.354
e34c4c81-cafe-4737-a544-a73006b77bf4	14	books.leadows.com	books.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Proxy	http://127.0.0.1:6875	url	f060df71-9a9e-4de5-9298-a00f4facba0b	\N	\N	f4fd77fd-c085-4c27-9a7b-0bff29f2aaf6		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.355	2026-10-05 05:46:01.355
e4a4e090-04f2-4c0a-9f69-6affeb689ea2	15	bugs.leadows.com	bugs.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Proxy	http://10.0.0.100:8082/	url	6a2f9668-696a-42bf-8c49-3429fc393581	\N	\N	692412a3-4697-4c61-a8f4-2ec2fc4b7ad9	Bugzilla; max upload 20M	{"rateLimit": false, "websocket": false, "maxUploadSize": "20M", "hasUploadLimit": true}	\N	2026-10-05 05:46:01.357	2026-10-05 05:46:01.357
4a64dc1d-9372-4372-9cba-9014424741de	16	demoshop.leadows.com	demoshop.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Proxy	http://localhost:8555	url	cc5b42fa-768d-4952-95ac-1dfbc0e3061a	\N	\N	61b68799-9f31-4972-b110-86115f96efac	Rate limit zone php_limit (burst 25); max upload 500M; WebSocket upgrade	{"rateLimit": true, "websocket": true, "maxUploadSize": "500M", "hasUploadLimit": true}	\N	2026-10-05 05:46:01.358	2026-10-05 05:46:01.358
d884daca-25a6-45d0-b049-638267a4053e	17	demoshop.leadows.com	demoshop.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/phpmyadmin/	{/phpmyadmin/}	Proxy	http://127.0.0.1:8556/	url	319957bc-1b42-4760-a62f-f99702ed7287	\N	\N	61b68799-9f31-4972-b110-86115f96efac	phpMyAdmin	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.359	2026-10-05 05:46:01.359
4ae006de-8795-4b35-8103-f08eeece275c	18	demoshop.leadows.com	demoshop.leadows.com	f	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	80	80	HTTP	/	{/}	Redirect	301 -> HTTPS (otherwise 404)	redirect	\N	\N	301	61b68799-9f31-4972-b110-86115f96efac	Blocks query strings like ?a=123 with 403	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.36	2026-10-05 05:46:01.36
e13e4d5c-63e4-4a39-8928-49d420645884	19	docs.mahdibagh.org	docs.mahdibagh.org	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Proxy	http://192.168.1.222:82/	url	dc188d16-4828-4521-b0a1-63a42113fd9c	\N	\N	0dab4bbf-5d9e-422a-9134-a8a69073a96c	Max upload 500M	{"rateLimit": false, "websocket": false, "maxUploadSize": "500M", "hasUploadLimit": true}	\N	2026-10-05 05:46:01.361	2026-10-05 05:46:01.361
a75aeb1c-aa0d-4a22-aeb2-086f1a06c8d8	20	docs.mahdibagh.org	docs.mahdibagh.org	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/ns	{/ns}	Return	301 -> /	redirect	\N	\N	301	0dab4bbf-5d9e-422a-9134-a8a69073a96c		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.362	2026-10-05 05:46:01.362
13fe5297-2587-45b3-adc8-233ddfcca56e	21	doks.leadows.com	doks.leadows.com	f	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	80	80	HTTP	/	{/}	Redirect	301 -> HTTPS	redirect	\N	\N	301	1915484d-41bb-4754-8f3d-1f4c2ffba90a		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.363	2026-10-05 05:46:01.363
386bfabc-0bd6-4809-b78a-00101552ea2b	22	doks.leadows.com	doks.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Proxy	http://192.168.1.221:8180	url	0de000ed-8f0d-4886-8432-02a6ae7436be	\N	\N	1915484d-41bb-4754-8f3d-1f4c2ffba90a	Max upload 100m	{"rateLimit": false, "websocket": false, "maxUploadSize": "100m", "hasUploadLimit": true}	\N	2026-10-05 05:46:01.364	2026-10-05 05:46:01.364
f334c810-71ca-492c-8ac3-deb58a70a2f0	23	doks.leadows.com	doks.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/ds-vpath/	{/ds-vpath/}	Proxy	http://192.168.1.221:8180/ds-vpath/	url	0de000ed-8f0d-4886-8432-02a6ae7436be	\N	\N	1915484d-41bb-4754-8f3d-1f4c2ffba90a		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.365	2026-10-05 05:46:01.365
7ef7a101-8289-4880-9769-735ffb992feb	24	doks.leadows.com	doks.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/controlpanel/	{/controlpanel/}	Proxy	http://192.168.1.221:8180/controlpanel/	url	0de000ed-8f0d-4886-8432-02a6ae7436be	\N	\N	1915484d-41bb-4754-8f3d-1f4c2ffba90a		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.367	2026-10-05 05:46:01.367
ddbd789b-d91a-47b3-987c-a14000a0533d	25	emr.mahdibagh.org	emr.mahdibagh.org	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Proxy	http://192.168.1.222:8080	url	f983d605-e989-4489-aa32-cf13fa3859b4	\N	\N	5ff25a60-7c1b-4342-9dd9-940294d62c5d	Max upload 50M	{"rateLimit": false, "websocket": false, "maxUploadSize": "50M", "hasUploadLimit": true}	\N	2026-10-05 05:46:01.368	2026-10-05 05:46:01.368
6a7ebdad-0106-4609-a083-8c0343e72c5f	26	emr.mahdibagh.org	emr.mahdibagh.org	f	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	80	80	HTTP	/	{/}	Redirect	301 -> HTTPS	redirect	\N	\N	301	5ff25a60-7c1b-4342-9dd9-940294d62c5d		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.369	2026-10-05 05:46:01.369
67833640-fb0a-401c-b57e-03bb3e78a336	27	ems-staging.leadows.com	ems-staging.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/ , /admin/ , /favicon.ico	{/,/admin/,/favicon.ico}	Static	root /usr/share/nginx/html/ems-staging.leadows.com	static_root	\N	/usr/share/nginx/html/ems-staging.leadows.com	\N	7a9a564e-e596-42a5-9cc2-5123f3724c9a		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.37	2026-10-05 05:46:01.37
1679169e-b292-42eb-89e9-7a6acaa20569	28	ems-staging.leadows.com	ems-staging.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/api/	{/api/}	Proxy	http://10.0.0.100:5050	url	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	\N	\N	7a9a564e-e596-42a5-9cc2-5123f3724c9a		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.371	2026-10-05 05:46:01.371
aa27b513-0eed-4344-8b64-5739fcfc2c4f	29	ems.leadows.com	ems.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/ , /admin/ , /favicon.ico	{/,/admin/,/favicon.ico}	Static	root /usr/share/nginx/html/ems.leadows.com	static_root	\N	/usr/share/nginx/html/ems.leadows.com	\N	867d3d2a-f9fc-4018-bfd1-0d74b85a7d7e		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.372	2026-10-05 05:46:01.372
6c53e6be-9769-4495-9523-bd14bc364b4f	30	ems.leadows.com	ems.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/app	{/app}	Redirect	302 -> App Store / Play Store (else https://ems.leadows.com/)	redirect	\N	\N	302	867d3d2a-f9fc-4018-bfd1-0d74b85a7d7e	Store links look like a placeholder (Airbnb app IDs) - verify	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.373	2026-10-05 05:46:01.373
ae977c1b-8c38-4ecd-abc0-87ed321eb7d1	31	ems.leadows.com	ems.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/api/	{/api/}	Proxy	http://10.0.0.100:5000	url	bc194eb2-5992-40e4-b518-6d96933dffb9	\N	\N	867d3d2a-f9fc-4018-bfd1-0d74b85a7d7e		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.374	2026-10-05 05:46:01.374
24e38d7e-9d06-402d-b3d9-29d109318f87	32	ems.leadows.com	ems.leadows.com	f	eb7162c7-530f-4aed-8c96-2b32940e6734	3021	3021	HTTPS	/	{/}	Proxy	http://10.0.0.100:5000/	url	bc194eb2-5992-40e4-b518-6d96933dffb9	\N	\N	867d3d2a-f9fc-4018-bfd1-0d74b85a7d7e	Alternate HTTPS port	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.375	2026-10-05 05:46:01.375
ef31e30f-67f3-4017-a9f8-3b9e5a3476e9	33	ems.leadows.com	ems.leadows.com	f	dd1361b7-c5a2-4123-937a-11f62570ad6e	3022	3022	HTTPS	/ , /favicon.ico	{/,/favicon.ico}	Static	root /usr/share/nginx/html/sa.ems.leadows.com	static_root	\N	/usr/share/nginx/html/sa.ems.leadows.com	\N	867d3d2a-f9fc-4018-bfd1-0d74b85a7d7e	Super-admin front end	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.376	2026-10-05 05:46:01.376
7e778a08-adbe-4b95-b602-b303ca3371d1	34	hub.leadows.com	hub.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Static	root /usr/share/nginx/html/twine_frontend	static_root	\N	/usr/share/nginx/html/twine_frontend	\N	0eff45cb-6f1f-4500-ba00-7b33fb18ce98		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.377	2026-10-05 05:46:01.377
62712eb4-1711-417f-9149-c90ce9e27c3c	35	khabar.mahdibagh.net	khabar.mahdibagh.net	f	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	80	80	HTTP	/	{/}	Redirect	301 -> HTTPS	redirect	\N	\N	301	e22d8e26-fb98-425d-ab2c-af892d0b88a0		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.378	2026-10-05 05:46:01.378
eb5debb6-dbc6-4599-a45b-ee39d4c9352a	36	khabar.mahdibagh.net	khabar.mahdibagh.net	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Proxy	upstream: superdesk_client	upstream	\N	\N	\N	e22d8e26-fb98-425d-ab2c-af892d0b88a0	Superdesk; upstream address not captured; HTTP/2; max upload 500M	{"rateLimit": false, "websocket": false, "maxUploadSize": "500M", "hasUploadLimit": true}	\N	2026-10-05 05:46:01.379	2026-10-05 05:46:01.379
34822053-9276-4666-bec2-803e2b226bb1	37	khabar.mahdibagh.net	khabar.mahdibagh.net	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/api/v2/	{/api/v2/}	Proxy	upstream: publisher-server	upstream	\N	\N	\N	e22d8e26-fb98-425d-ab2c-af892d0b88a0	Upstream address not captured	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.38	2026-10-05 05:46:01.38
22eb4008-1067-4c80-abd3-a81da8b8665b	38	khabar.mahdibagh.net	khabar.mahdibagh.net	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/media/	{/media/}	Proxy	upstream: publisher-server	upstream	\N	\N	\N	e22d8e26-fb98-425d-ab2c-af892d0b88a0	Upstream address not captured	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.381	2026-10-05 05:46:01.381
653fc0bb-f6c5-4605-a792-c41e48e5e139	39	khabar.mahdibagh.net	khabar.mahdibagh.net	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/api/	{/api/}	Proxy	upstream: superdesk_server	upstream	\N	\N	\N	e22d8e26-fb98-425d-ab2c-af892d0b88a0	Upstream address not captured	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.383	2026-10-05 05:46:01.383
2ba1bdf1-fd7b-4cd4-b4ba-32bb37aeeaa4	40	khabar.mahdibagh.net	khabar.mahdibagh.net	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/api/upload-raw/	{/api/upload-raw/}	Proxy	upstream: superdesk_server	upstream	\N	\N	\N	e22d8e26-fb98-425d-ab2c-af892d0b88a0	Upstream address not captured	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.384	2026-10-05 05:46:01.384
0bc23943-c260-4502-86ed-f82c44555c2d	41	khabar.mahdibagh.net	khabar.mahdibagh.net	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/capi/	{/capi/}	Proxy	upstream: superdesk_capi	upstream	\N	\N	\N	e22d8e26-fb98-425d-ab2c-af892d0b88a0	Upstream address not captured	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.385	2026-10-05 05:46:01.385
5f6e3b12-84d0-450d-bf65-051de12f71bb	42	khabar.mahdibagh.net	khabar.mahdibagh.net	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/ws	{/ws}	Proxy	upstream: superdesk_ws	upstream	\N	\N	\N	e22d8e26-fb98-425d-ab2c-af892d0b88a0	Upstream address not captured	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.386	2026-10-05 05:46:01.386
36a03163-28a2-48bd-8bb8-8d9e810550da	43	khabar.mahdibagh.net	khabar.mahdibagh.net	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/sd-media/	{/sd-media/}	Proxy	upstream: media_proxy	upstream	\N	\N	\N	e22d8e26-fb98-425d-ab2c-af892d0b88a0	Upstream address not captured	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.388	2026-10-05 05:46:01.388
2b482e27-b612-4b04-b7b2-37c45e8bbd10	44	leadowserp.com, www.leadowserp.com	leadowserp.com, www.leadowserp.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Proxy	http://10.0.0.100:3010	url	3c13e9b8-dded-4acd-99a2-eec56dea599e	\N	\N	af18d98c-4870-4b2d-8cd0-5184f9ccbdea		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.389	2026-10-05 05:46:01.389
92d44cdf-72d4-44d4-b91d-161c4b3d5a93	45	leadowserp.leadows.com	leadowserp.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Static	root /usr/share/nginx/html/leadows.leadowserp.com	static_root	\N	/usr/share/nginx/html/leadows.leadowserp.com	\N	af18d98c-4870-4b2d-8cd0-5184f9ccbdea		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.39	2026-10-05 05:46:01.39
27fda8d2-40bd-4422-900f-558faf57fa10	46	leadowserp.leadows.com	leadowserp.leadows.com	f	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	3009	3009	HTTPS	/	{/}	Proxy	http://10.0.0.100:3010	url	3c13e9b8-dded-4acd-99a2-eec56dea599e	\N	\N	af18d98c-4870-4b2d-8cd0-5184f9ccbdea	Alternate HTTPS port	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.391	2026-10-05 05:46:01.391
96e6bc1d-b948-4a29-91b2-5049137c94de	47	www.mahdibagh.org	www.mahdibagh.org	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/administrator/	{/administrator/}	Proxy	http://10.0.0.200:8786	url	1cbb503f-01dd-4427-bab5-30006e1fe60b	\N	\N	ec51f9dd-5cfc-4c89-8f89-8e958a3475e8	Joomla admin path; max upload 500M	{"rateLimit": false, "websocket": false, "maxUploadSize": "500M", "hasUploadLimit": true}	\N	2026-10-05 05:46:01.392	2026-10-05 05:46:01.392
76db6f86-83be-4887-9a4f-bce192003504	48	www.mahdibagh.org	www.mahdibagh.org	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	~ \\.php$ (PHP files)	{"~ \\\\.php$ (PHP files)"}	Proxy	http://10.0.0.200:8786	url	1cbb503f-01dd-4427-bab5-30006e1fe60b	\N	\N	ec51f9dd-5cfc-4c89-8f89-8e958a3475e8	Rate limit php_limit (burst 3)	{"rateLimit": true, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.394	2026-10-05 05:46:01.394
81314502-c1d0-459a-be58-2ab12ec7955c	49	www.mahdibagh.org	www.mahdibagh.org	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Proxy	http://10.0.0.200:8786	url	1cbb503f-01dd-4427-bab5-30006e1fe60b	\N	\N	ec51f9dd-5cfc-4c89-8f89-8e958a3475e8	Rate limit php_limit (burst 25)	{"rateLimit": true, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.395	2026-10-05 05:46:01.395
4e21c151-f3dd-44d9-aca8-536e2bd87dc4	50	www.mahdibagh.org	www.mahdibagh.org	f	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	80	80	HTTP	/	{/}	Redirect	301 -> HTTPS (otherwise 404)	redirect	\N	\N	301	ec51f9dd-5cfc-4c89-8f89-8e958a3475e8		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.396	2026-10-05 05:46:01.396
c1a61740-d867-4b32-b063-023d2f08c2b4	51	mbyc.mahdibagh.org	mbyc.mahdibagh.org	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/administrator/	{/administrator/}	Proxy	http://192.168.1.222:8787	url	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	\N	\N	ec51f9dd-5cfc-4c89-8f89-8e958a3475e8	Max upload 500M	{"rateLimit": false, "websocket": false, "maxUploadSize": "500M", "hasUploadLimit": true}	\N	2026-10-05 05:46:01.397	2026-10-05 05:46:01.397
e04d1d45-5b1c-4b19-bda1-4e9e64189f41	52	mbyc.mahdibagh.org	mbyc.mahdibagh.org	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	~ \\.php$ (PHP files)	{"~ \\\\.php$ (PHP files)"}	Proxy	http://192.168.1.222:8787	url	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	\N	\N	ec51f9dd-5cfc-4c89-8f89-8e958a3475e8	Rate limit php_limit	{"rateLimit": true, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.398	2026-10-05 05:46:01.398
1b86cb46-2b43-4921-b219-939ea051540f	53	mbyc.mahdibagh.org	mbyc.mahdibagh.org	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Proxy	http://192.168.1.222:8787	url	c84bb02a-f6b1-4a40-ad91-4f2cef7cb81e	\N	\N	ec51f9dd-5cfc-4c89-8f89-8e958a3475e8	Rate limit php_limit	{"rateLimit": true, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.399	2026-10-05 05:46:01.399
ae5637d8-4e3b-4487-aedb-80293de13953	54	mbapp.mahdibagh.net	mbapp.mahdibagh.net	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Proxy	http://10.0.0.200:8080	url	0c959eb9-7b7e-4565-b414-1923670acc19	\N	\N	e7489e9f-5a1c-4696-a074-2a216ef4a3ad	Max upload 3M	{"rateLimit": false, "websocket": false, "maxUploadSize": "3M", "hasUploadLimit": true}	\N	2026-10-05 05:46:01.4	2026-10-05 05:46:01.4
5481c9a8-87d7-4f36-8a3a-daae9fc614c7	55	mbapp.mahdibagh.net	mbapp.mahdibagh.net	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/api	{/api}	Proxy	http://10.0.0.200:3100	url	79d472f8-e5a7-41b7-b0b9-69b8bd6459ef	\N	\N	e7489e9f-5a1c-4696-a074-2a216ef4a3ad		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.401	2026-10-05 05:46:01.401
3338614e-e4be-46c9-b171-383402b894bf	56	mbapp.mahdibagh.net	mbapp.mahdibagh.net	f	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	80	80	HTTP	/	{/}	Redirect	301 -> HTTPS (otherwise 404)	redirect	\N	\N	301	e7489e9f-5a1c-4696-a074-2a216ef4a3ad		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.402	2026-10-05 05:46:01.402
6053f39d-355f-48a5-9492-cdaa1788761a	57	mbc.leadows.com	mbc.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Static	root /usr/share/nginx/html/mbc.leadowserp.com	static_root	\N	/usr/share/nginx/html/mbc.leadowserp.com	\N	2069eca7-2d93-4e54-8b52-322e186a481f		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.403	2026-10-05 05:46:01.403
65fcb861-714e-43e1-859b-2c1a02f7bac8	58	mbc.leadows.com	mbc.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/api/	{/api/}	Proxy	http://10.0.0.100:3010/	url	3c13e9b8-dded-4acd-99a2-eec56dea599e	\N	\N	2069eca7-2d93-4e54-8b52-322e186a481f	Passes Set-Cookie header	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.404	2026-10-05 05:46:01.404
35ba7379-5552-43bb-b602-9e4b61d80bf2	59	mbc.leadows.com	mbc.leadows.com	f	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	3009	3009	HTTPS	/	{/}	Proxy	http://10.0.0.100:3010	url	3c13e9b8-dded-4acd-99a2-eec56dea599e	\N	\N	2069eca7-2d93-4e54-8b52-322e186a481f	Alternate HTTPS port	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.406	2026-10-05 05:46:01.406
1cb1874f-7a41-4a43-852b-7177530216e6	60	mm.leadows.com	mm.leadows.com (server_name _)	t	42138f4f-65a2-4291-a571-3c7f720d2921	28096	28096	HTTP	/	{/}	Proxy	http://10.0.0.200:8096	url	af946847-9d32-403e-9910-eaaeeb0d5081	\N	\N	159b52db-7492-4a66-a82f-51ef03debd41	Plain HTTP catch-all; 8096 is Jellyfin's default port; max upload 20M	{"rateLimit": false, "websocket": false, "maxUploadSize": "20M", "hasUploadLimit": true}	\N	2026-10-05 05:46:01.407	2026-10-05 05:46:01.407
44a9597e-e955-4e26-8134-2a986fe65729	61	myneuron.leadows.com	myneuron.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Static	root /usr/share/nginx/html/myneuron.leadows.com	static_root	\N	/usr/share/nginx/html/myneuron.leadows.com	\N	b98f3007-7d8e-4a6b-a363-fd629fec2ad0		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.408	2026-10-05 05:46:01.408
32896aa0-1436-45bd-b06a-463c412546b2	62	myneuron.leadows.com	myneuron.leadows.com	f	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	4000	4000	HTTPS	/	{/}	Proxy	http://localhost:9006	url	cd45c8d5-3d4a-4596-8d54-99526d9c5daf	\N	\N	b98f3007-7d8e-4a6b-a363-fd629fec2ad0	Max upload 30M	{"rateLimit": false, "websocket": false, "maxUploadSize": "30M", "hasUploadLimit": true}	\N	2026-10-05 05:46:01.409	2026-10-05 05:46:01.409
0bce4805-bbe0-43b8-88b7-75a0f43d91f0	63	primary.leadowserp.com	primary.leadowserp.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Static	root /usr/share/nginx/html/primary.leadowserp.com	static_root	\N	/usr/share/nginx/html/primary.leadowserp.com	\N	90c0e851-6b36-46d9-90fc-1e33010653b9		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.41	2026-10-05 05:46:01.41
136d12e3-884e-46d8-8df7-1aeedf3017ef	64	primary.leadowserp.com	primary.leadowserp.com	f	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	4000	4000	HTTPS	/	{/}	Proxy	http://192.168.1.221:4001	url	bc543403-17de-4254-8b46-4c2234f6a578	\N	\N	90c0e851-6b36-46d9-90fc-1e33010653b9		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.411	2026-10-05 05:46:01.411
cad60d51-4e0e-4c16-8b72-94e17a280374	65	publisher.khabar.mahdibagh.net	publisher.khabar.mahdibagh.net	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Proxy	http://192.168.1.222:8082	url	4a338faf-033a-47a3-b5ff-4cf6b3d44a29	\N	\N	445418ff-4f39-43d9-ae07-263919d25422		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.412	2026-10-05 05:46:01.412
ebaf2700-5dba-428b-9d5e-530e74097c7d	66	punekar.leadows.com	punekar.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Static	root /usr/share/nginx/html/punekar.leadows.com	static_root	\N	/usr/share/nginx/html/punekar.leadows.com	\N	fcd17c96-acda-44e8-81ad-507540c939c2		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.414	2026-10-05 05:46:01.414
137120ae-5981-4727-b998-7f6268fb1302	67	punekar.leadows.com	punekar.leadows.com	f	06d2bfae-95a4-4d90-b491-a0b2474dc8d0	4000	4000	HTTPS	/	{/}	Proxy	http://10.0.0.100:9011	url	262738e7-53aa-4415-a3f1-2265f3ba9773	\N	\N	fcd17c96-acda-44e8-81ad-507540c939c2		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.415	2026-10-05 05:46:01.415
71a4df12-b84b-43c9-a14d-1c2c593b372c	68	rag.leadows.com	rag.leadows.com	f	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	80	80	HTTP	/.well-known/acme-challenge/	{/.well-known/acme-challenge/}	Static	root /var/www/html	static_root	\N	/var/www/html	\N	ac902460-3145-4f10-9643-bb62bd7c2755	Let's Encrypt validation	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.416	2026-10-05 05:46:01.416
b1343b63-2498-4e48-abdc-2f4e4af74c4f	69	rag.leadows.com	rag.leadows.com	f	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	80	80	HTTP	/	{/}	Redirect	301 -> HTTPS	redirect	\N	\N	301	ac902460-3145-4f10-9643-bb62bd7c2755		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.417	2026-10-05 05:46:01.417
ad5d0bcc-b43e-4622-a6c1-c52dec29c99a	70	rag.leadows.com	rag.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Proxy	upstream: helix_backend	upstream	\N	\N	\N	ac902460-3145-4f10-9643-bb62bd7c2755	Upstream address not captured; max upload 100M	{"rateLimit": false, "websocket": false, "maxUploadSize": "100M", "hasUploadLimit": true}	\N	2026-10-05 05:46:01.418	2026-10-05 05:46:01.418
7353b929-877d-4010-9216-c9c0ee5ce1af	71	rag.leadows.com	rag.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/ws	{/ws}	Proxy	upstream: helix_backend	upstream	\N	\N	\N	ac902460-3145-4f10-9643-bb62bd7c2755	Upstream address not captured	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.42	2026-10-05 05:46:01.42
cf440d66-6e64-4f0e-a9cb-f7f21abafa9f	72	rag.leadows.com	rag.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/api/	{/api/}	Proxy	upstream: helix_backend	upstream	\N	\N	\N	ac902460-3145-4f10-9643-bb62bd7c2755	Upstream address not captured	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.421	2026-10-05 05:46:01.421
8edca6bb-05ae-4430-8f17-7cb081c63fc9	73	rag.leadows.com	rag.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/api/rag/	{/api/rag/}	Proxy	upstream: rag_backend	upstream	\N	\N	\N	ac902460-3145-4f10-9643-bb62bd7c2755	Upstream address not captured	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.423	2026-10-05 05:46:01.423
5507f438-1bcc-4d62-8ad4-3df7d888dfa5	74	rag.leadows.com	rag.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/api/doc/	{/api/doc/}	Proxy	upstream: doc_backend	upstream	\N	\N	\N	ac902460-3145-4f10-9643-bb62bd7c2755	Upstream address not captured	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.424	2026-10-05 05:46:01.424
33dfa006-44a8-448e-9ecd-96251acd4c70	75	rag.leadows.com	rag.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/assets/	{/assets/}	Static	root /var/www/rag-helix	static_root	\N	/var/www/rag-helix	\N	ac902460-3145-4f10-9643-bb62bd7c2755		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.425	2026-10-05 05:46:01.425
c03bdccf-c44a-4598-be54-2a23017087c7	76	rag.leadows.com	rag.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/dashboard/	{/dashboard/}	Static	root /var/www/rag-helix	static_root	\N	/var/www/rag-helix	\N	ac902460-3145-4f10-9643-bb62bd7c2755		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.427	2026-10-05 05:46:01.427
1127a1bf-ccb5-4d58-8765-d1f9be3144f3	77	rag.leadows.com	rag.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/chat/	{/chat/}	Static	root /var/www/rag-helix	static_root	\N	/var/www/rag-helix	\N	ac902460-3145-4f10-9643-bb62bd7c2755		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.428	2026-10-05 05:46:01.428
a692ece3-9197-4b8d-bcfd-f9375b7839ce	78	rag.leadows.com	rag.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/upload , /dashboard (no slash) , /chat (no slash)	{/upload,"/dashboard (no slash)","/chat (no slash)"}	Redirect	301 -> /dashboard/ or /chat/	redirect	\N	\N	301	ac902460-3145-4f10-9643-bb62bd7c2755		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.429	2026-10-05 05:46:01.429
c73555da-1f82-4d65-8bce-fd6e1c4a8244	79	restaurant.leadows.com	restaurant.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Static	root /usr/share/nginx/html/restaurant (SPA)	static_root	\N	/usr/share/nginx/html/restaurant (SPA)	\N	4d95c5e1-b23e-4679-8159-a011c2a2c9e8		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.43	2026-10-05 05:46:01.43
a7ca667b-1f3f-413f-95d7-559c10dcabcf	80	restaurant.leadows.com	restaurant.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/api/	{/api/}	Proxy	http://localhost:8020	url	971176aa-5d7b-4ba8-a804-5496eeb5ebc8	\N	\N	4d95c5e1-b23e-4679-8159-a011c2a2c9e8	7-day timeouts (long-lived connections)	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.431	2026-10-05 05:46:01.431
e7ae2f06-7256-4170-a279-38bdbb361c19	81	restaurant.leadows.com	restaurant.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/rag/api/	{/rag/api/}	Proxy	http://127.0.0.1:8080/	url	f818583c-c73b-4ce9-bbf5-1601cb636f9e	\N	\N	4d95c5e1-b23e-4679-8159-a011c2a2c9e8	RAG backend; /rag/api/ prefix stripped; max upload 110m; timeout 300s	{"rateLimit": false, "websocket": false, "maxUploadSize": "110m", "hasUploadLimit": true}	\N	2026-10-05 05:46:01.432	2026-10-05 05:46:01.432
95b688d6-18c7-4548-b630-fa142a5e7859	82	restaurant.leadows.com	restaurant.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/rag/	{/rag/}	Proxy	http://127.0.0.1:9000	url	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	\N	\N	4d95c5e1-b23e-4679-8159-a011c2a2c9e8	RAG front end (Vite preview); /rag/ prefix kept	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.433	2026-10-05 05:46:01.433
af9dc7f3-2e5c-4ac6-a7fb-afba8f086b02	83	restaurant.leadows.com	restaurant.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/task...	{/task...}	Proxy	http://127.0.0.1:7000	url	7288259e-9538-4b21-b7eb-36339e423ad7	\N	\N	4d95c5e1-b23e-4679-8159-a011c2a2c9e8	Regex ^/task(/.*)?$	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.435	2026-10-05 05:46:01.435
c25247e9-790c-4db1-a13d-198f64b4e27c	84	schoolbus.leadows.com	schoolbus.leadows.com	f	11295648-cb50-419e-ae47-ee7a458b63c1	10080	10080	HTTP	/	{/}	Static	root /usr/share/nginx/html/school-bus.leadows.com	static_root	\N	/usr/share/nginx/html/school-bus.leadows.com	\N	a7e4f698-03d5-4fc3-ad28-283caf50890c	Plain HTTP	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.436	2026-10-05 05:46:01.436
3474731d-d1b8-4174-b8fa-c8b413bcac66	85	schoolbus.leadows.com	schoolbus.leadows.com	f	11295648-cb50-419e-ae47-ee7a458b63c1	10080	10080	HTTP	/api/	{/api/}	Proxy	http://127.0.0.1:8078	url	a0dd8aa5-3e3e-412a-9d4f-1bbb71e012f6	\N	\N	a7e4f698-03d5-4fc3-ad28-283caf50890c		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.437	2026-10-05 05:46:01.437
0582742f-90d9-4d8e-86cc-ff142cd694d8	86	schoolbus.leadows.com	schoolbus.leadows.com	f	11295648-cb50-419e-ae47-ee7a458b63c1	10080	10080	HTTP	/geo/	{/geo/}	Proxy	http://127.0.0.1:8088	url	24582c1a-a546-46a6-a89e-2a80fe8ef43c	\N	\N	a7e4f698-03d5-4fc3-ad28-283caf50890c		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.438	2026-10-05 05:46:01.438
e5d8d2eb-0410-45dc-86a0-2313042d76fa	87	schoolbus.leadows.com	schoolbus.leadows.com	f	11295648-cb50-419e-ae47-ee7a458b63c1	10080	10080	HTTP	/s3/	{/s3/}	Proxy	http://10.0.0.100:8333/	url	d53359f8-0936-4edd-bac6-65298f541aca	\N	\N	a7e4f698-03d5-4fc3-ad28-283caf50890c	S3 storage (SeaweedFS-style port); no upload limit	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.439	2026-10-05 05:46:01.439
49638a50-8bb2-4d93-b027-3ade59acc04e	88	www.schoolsecurity.uz	www.schoolsecurity.uz	f	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	80	80	HTTP	/	{/}	Redirect	301 -> https://schoolsecurity.uz	redirect	\N	\N	301	eb5d465b-e2dd-40b3-9bfc-b75f5b437dbe		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.44	2026-10-05 05:46:01.44
72ffa075-3c1e-4081-b0a5-3e7b9366bc1a	89	schoolsecurity.uz	schoolsecurity.uz	f	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	80	80	HTTP	/	{/}	Redirect	301 -> https://schoolsecurity.uz	redirect	\N	\N	301	eb5d465b-e2dd-40b3-9bfc-b75f5b437dbe	No HTTPS (443) block seen for this domain in output	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.441	2026-10-05 05:46:01.441
a4eca51d-1128-4d38-b649-846c9e3ed997	90	api.schoolsecurity.uz	api.schoolsecurity.uz	f	ccbc4c63-b042-48b0-85c1-cddf26463e50	10180	10180	HTTP	/api/	{/api/}	Proxy	http://127.0.0.1:9000	url	89c6c9dc-6690-472a-a5f0-c0cf195ef8ef	\N	\N	eb5d465b-e2dd-40b3-9bfc-b75f5b437dbe	Plain HTTP	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.443	2026-10-05 05:46:01.443
a716cbdf-6869-4806-8835-5987727ada30	91	api.schoolsecurity.uz	api.schoolsecurity.uz	f	ccbc4c63-b042-48b0-85c1-cddf26463e50	10180	10180	HTTP	/geo/	{/geo/}	Proxy	http://127.0.0.1:9001	url	85b9a7f2-c2ca-49c8-89de-fa7cb0a7f0c9	\N	\N	eb5d465b-e2dd-40b3-9bfc-b75f5b437dbe		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.444	2026-10-05 05:46:01.444
72a9ee6a-0269-4ac2-ad3f-9c549ceb1878	92	api.schoolsecurity.uz	api.schoolsecurity.uz	f	ccbc4c63-b042-48b0-85c1-cddf26463e50	10180	10180	HTTP	/s3/	{/s3/}	Proxy	http://10.0.0.100:8333/	url	d53359f8-0936-4edd-bac6-65298f541aca	\N	\N	eb5d465b-e2dd-40b3-9bfc-b75f5b437dbe	No upload limit	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.445	2026-10-05 05:46:01.445
9ea4e8aa-551b-42d5-bc03-f0a54df7e07b	93	api.schoolsecurity.uz	api.schoolsecurity.uz	f	ccbc4c63-b042-48b0-85c1-cddf26463e50	10180	10180	HTTP	/	{/}	Static	(root not captured)	unknown	\N	\N	\N	eb5d465b-e2dd-40b3-9bfc-b75f5b437dbe		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.446	2026-10-05 05:46:01.446
834fd084-b855-46c0-bd71-88ee6ce302d3	94	staging.leadowserp.com	staging.leadowserp.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Static	root /usr/share/nginx/html/leadowserp-staging/	static_root	\N	/usr/share/nginx/html/leadowserp-staging/	\N	0135aeec-54a3-4c98-a112-95fd24be807a		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.447	2026-10-05 05:46:01.447
d8a9e1c3-3297-4585-846e-f5039e101783	95	staging.leadowserp.com	staging.leadowserp.com	f	8526a8aa-7dfd-4058-bc5d-dd94ebcb22ca	3009	3009	HTTPS	/	{/}	Proxy	http://192.168.1.221:3011	url	137e2e5e-b96f-4e8a-aaff-1dca0da29923	\N	\N	0135aeec-54a3-4c98-a112-95fd24be807a	Alternate HTTPS port	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.448	2026-10-05 05:46:01.448
3b3573bf-e939-4df8-a291-e988cbda4105	96	localhost	localhost	f	35fb4359-7c66-4d29-b21f-868fa30cf1bb	8080	8080	HTTP	/stub_status	{/stub_status}	Status	nginx stub_status	status	\N	\N	\N	04c468a8-f556-43db-bbf5-17e84e8f8e1c	Nginx monitoring; see Issues sheet re: port 8080	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.45	2026-10-05 05:46:01.45
4cea04dd-b87c-41d7-9f27-fe6e3f0b7bee	97	tasks.leadows.com	tasks.leadows.com	f	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	80	80	HTTP	/	{/}	Redirect	301 -> HTTPS	redirect	\N	\N	301	1759fb3c-db79-4c06-8870-5e6e4f674595		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.451	2026-10-05 05:46:01.451
02c879e7-829d-425a-91ad-a1a4921743f5	98	tasks.leadows.com	tasks.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Proxy	http://10.0.0.100:8989	url	a830ee9a-87da-4280-9ec7-e547ef244051	\N	\N	1759fb3c-db79-4c06-8870-5e6e4f674595	Max upload 50M	{"rateLimit": false, "websocket": false, "maxUploadSize": "50M", "hasUploadLimit": true}	\N	2026-10-05 05:46:01.452	2026-10-05 05:46:01.452
a7310550-d9a8-40e7-837d-bd7ace0c7dee	99	train.leadows.com	train.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Proxy	http://$jellyfin:8096	variable	1341092e-90ea-4bc4-8007-385460b87942	\N	\N	5f1f5bc6-fa82-4b79-a74a-1cd346c1d4a9	$jellyfin set in upgrade-map.conf (not captured); HTTP/2	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.453	2026-10-05 05:46:01.453
0e16befd-d27c-4f7a-846e-cacd5fffec10	100	train.leadows.com	train.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/socket	{/socket}	Proxy	http://$jellyfin:8096	variable	1341092e-90ea-4bc4-8007-385460b87942	\N	\N	5f1f5bc6-fa82-4b79-a74a-1cd346c1d4a9	WebSocket	{"rateLimit": false, "websocket": true, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.454	2026-10-05 05:46:01.454
b0e2f83d-c561-4c03-89e5-257cda3cbcea	101	training.leadows.com	training.leadows.com	f	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	80	80	HTTP	/	{/}	Redirect	301 -> HTTPS	redirect	\N	\N	301	9cca75bf-5aa7-48c3-a23b-451e419ec56e		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.455	2026-10-05 05:46:01.455
2e08ed21-a3ce-45a0-9480-a0ed44a73264	102	training.leadows.com	training.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Static	root /usr/share/nginx/html/training_moodle/public (Moodle, PHP via FastCGI)	static_root	\N	/usr/share/nginx/html/training_moodle/public (Moodle, PHP via FastCGI)	\N	9cca75bf-5aa7-48c3-a23b-451e419ec56e	Max upload 100M; HTTP/2	{"rateLimit": false, "websocket": false, "maxUploadSize": "100M", "hasUploadLimit": true}	\N	2026-10-05 05:46:01.456	2026-10-05 05:46:01.456
9f62f709-36b8-4bcf-9fac-d44238a2bd2e	103	warehouse.leadows.com	warehouse.leadows.com	f	b8d9465b-b156-4a71-902d-9846891346a0	443	443	HTTPS	/	{/}	Static	root /usr/share/nginx/html/warehouse.leadows.com	static_root	\N	/usr/share/nginx/html/warehouse.leadows.com	\N	2ef24305-4e90-4735-a95f-07354fae7d7c		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.458	2026-10-05 05:46:01.458
b92a0565-0d55-4eb6-9e15-e947c7f6bb21	104	warehouse.leadows.com	warehouse.leadows.com	f	b01c4726-e22b-4760-be21-2106c644f07d	4020	4020	HTTPS	/	{/}	Proxy	http://localhost:9020	url	4b6d69ef-36a2-453a-bae1-02a7500c4225	\N	\N	2ef24305-4e90-4735-a95f-07354fae7d7c		{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.459	2026-10-05 05:46:01.459
8e9b0ad6-96d0-4a16-8749-7f87aa7b063d	105	default server	(default server)	f	1bcb0278-b2cf-442b-aefa-8edd7f05fe5b	80	80	HTTP	/	{/}	Redirect	301 -> HTTPS	redirect	\N	\N	301	096bb299-9728-4757-b711-0bc0c268aa38	default_server: catches any host on port 80 without its own block	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.46	2026-10-05 05:46:01.46
15bc8328-a37e-4c4c-923a-8654e69e6ae0	106	(catch-all)	(catch-all, server_name _)	t	\N	\N	(not captured)	HTTP	/	{/}	Static	root /var/www/html	static_root	\N	/var/www/html	\N	096bb299-9728-4757-b711-0bc0c268aa38	Listen port not captured	{"rateLimit": false, "websocket": false, "hasUploadLimit": false}	\N	2026-10-05 05:46:01.461	2026-10-05 05:46:01.461
\.


--
-- Data for Name: saved_views; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.saved_views (id, "userId", name, page, "filterJson", "isShared", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: servers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.servers (id, name, host, kind, "groupLabel", notes, tags, "customValues", "createdAt", "updatedAt") FROM stdin;
b5b99142-0282-4401-8a11-65a5b1a8beaa	Server A (App Backend)	10.0.0.100	backend	Group A	Backend server A	{}	\N	2026-10-05 04:56:19.819	2026-10-05 04:56:19.819
f308c74d-c257-4589-b650-7f8e9e994521	Server B (Service Backend)	10.0.0.200	backend	Group B	Backend server B	{}	\N	2026-10-05 04:56:19.824	2026-10-05 04:56:19.824
84183fa2-9430-466d-8b44-a2958f9c233b	Server C (LAN Node 1)	192.168.1.221	lan	Group C (LAN)	Backend server C (LAN)	{}	\N	2026-10-05 04:56:19.828	2026-10-05 04:56:19.828
0fec72ab-c1e8-4a3c-9122-0227baf33b5e	Server D (LAN Node 2)	192.168.1.222	lan	Group D (LAN)	Backend server D (LAN)	{}	\N	2026-10-05 04:56:19.831	2026-10-05 04:56:19.831
1503e4e3-ca1b-4bb5-add0-ee911baf81b3	Localhost (Nginx Server)	localhost	nginx-host	Localhost	Runs on this nginx server itself	{}	\N	2026-10-05 04:56:19.835	2026-10-05 04:56:19.835
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.settings (id, "scanIntervalSec", "tcpTimeoutMs", "slowThresholdMs", "concurrencyLimit", "retentionDays", "telegramConfig", "slackDiscordWebhook", "smtpConfig", "genericWebhook", "updatedAt") FROM stdin;
global	30	3000	1500	20	90	\N	\N	\N	\N	2026-10-05 04:56:20.667
\.


--
-- Data for Name: status_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.status_events (id, "targetType", "targetId", "targetName", "fromStatus", "toStatus", at, details) FROM stdin;
89d445d9-26ea-478d-812d-f6590804e95e	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	up	down	2026-10-05 05:13:31.387	\N
fbac5426-6f46-4560-9e8f-42df7d0dc648	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	up	down	2026-10-05 05:13:31.395	\N
4036449a-d1a1-448e-adcf-911cd241022d	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	up	down	2026-10-05 05:13:31.385	\N
76f021f9-1972-47f9-a06d-6709f11374c6	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	up	down	2026-10-05 05:13:31.397	\N
5bf51ce8-2864-4493-9015-e7e9cea15de2	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	up	down	2026-10-05 05:13:31.387	\N
14e607ae-61d2-4128-a684-887c53382b97	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	up	down	2026-10-05 05:13:31.389	\N
b4b9f2c7-ea52-4f41-88a1-05cf0b31470f	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	up	down	2026-10-05 05:13:31.389	\N
aad9a63c-cf3a-462e-8dab-c870194ae9bd	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	up	down	2026-10-05 05:13:31.39	\N
6b52494e-11e3-4e4a-aefd-e6d78635c09a	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	up	down	2026-10-05 05:13:31.393	\N
86f4126f-1797-4564-b777-51986f6c1e6a	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	up	down	2026-10-05 05:13:31.397	\N
5e51840f-3763-445c-a354-dc7d71389f3d	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	up	down	2026-10-05 05:13:31.397	\N
3455fab9-4f9b-4162-a7f0-54259daf8d12	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	down	up	2026-10-05 05:14:28.387	\N
77b8e50c-9b14-41f0-b74d-92010b87d641	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	down	up	2026-10-05 05:14:28.388	\N
56b43b6c-428f-404a-8f01-e2930261c6ad	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	down	up	2026-10-05 05:14:28.389	\N
46015189-c743-445b-9ea7-8ca319c77741	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	down	up	2026-10-05 05:14:28.388	\N
3e2864aa-2d56-447a-adc4-9375069bd4c6	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	down	up	2026-10-05 05:14:28.387	\N
8239b2b2-9950-4722-865e-a818c76cfa4d	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	down	up	2026-10-05 05:14:28.389	\N
d592bc52-071f-422b-bdc6-5b558f8afc72	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	down	up	2026-10-05 05:14:28.389	\N
b6949501-873b-48fa-a749-4813cfeec09c	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	down	up	2026-10-05 05:14:28.39	\N
0b48d3bd-3653-4554-ae49-ae4283383bbd	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	down	up	2026-10-05 05:14:28.528	\N
602e6095-63db-4614-9a55-cf600055c001	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	down	up	2026-10-05 05:14:28.529	\N
fbff1f46-9195-497e-9160-608412221b11	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	down	up	2026-10-05 05:14:28.541	\N
7c23f5da-e583-49ea-a6c0-2addb8ada27f	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	up	down	2026-10-05 05:15:01.413	\N
7793fd18-6e7d-42dd-8d75-313cd759912e	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	up	down	2026-10-05 05:15:01.413	\N
f6fb844d-e24c-4adf-a544-1dd631268fd7	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	up	down	2026-10-05 05:15:01.413	\N
7c44dfe6-7d6b-43b9-869a-49b7c55b1765	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	up	down	2026-10-05 05:15:01.429	\N
6ca4c2a0-3a3a-4fa0-bd28-67899c211a12	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	up	down	2026-10-05 05:15:01.443	\N
bc2809aa-7f10-45f0-823a-2f32b86357e0	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	up	down	2026-10-05 05:15:01.445	\N
7bc661cd-a17c-4c30-907a-48241f501436	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	up	down	2026-10-05 05:15:01.445	\N
e93962dc-1a1d-4907-a11d-4fa25e0b4bce	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	up	down	2026-10-05 05:15:01.446	\N
ef2de216-7a7b-491a-9678-640e054fcc14	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	up	down	2026-10-05 05:15:01.446	\N
66e04cdb-d77c-4faa-8a63-efab6d879f67	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	up	down	2026-10-05 05:15:01.446	\N
91c40183-e8b2-4c73-9d4c-8a964e2db3c9	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	up	down	2026-10-05 05:15:01.451	\N
5e666a44-7b8b-458f-8557-b42174e6ac21	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	down	up	2026-10-05 05:15:29.586	\N
a26d37fa-87a7-468f-8c67-0c6ed3e22794	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	down	up	2026-10-05 05:15:29.597	\N
1ffef233-4d0c-43ba-aaa7-e47c9eee2bda	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	down	up	2026-10-05 05:15:29.624	\N
f02f5b5e-81c6-4cc9-9783-d0e5b5e874eb	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	down	up	2026-10-05 05:15:29.623	\N
01b69920-6688-424b-876f-d3ad237b7dc4	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	down	up	2026-10-05 05:15:29.647	\N
54e3393e-18bf-4c0e-a8a8-0494b9cd6b7f	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	down	up	2026-10-05 05:15:29.655	\N
16d7e5fd-cf01-4347-a1f3-565957b74cbb	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	down	up	2026-10-05 05:15:29.655	\N
8c8a052e-fc01-48a6-8dfc-6af1be6b1e95	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	down	up	2026-10-05 05:15:29.659	\N
c96e82a7-cd18-444e-9d63-dae205fbf003	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	down	up	2026-10-05 05:15:29.655	\N
031d315f-0cb4-4270-9836-42dbfa115699	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	down	up	2026-10-05 05:15:29.663	\N
3070bd0e-3b62-4376-be54-ab4ce12f1f43	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	down	up	2026-10-05 05:15:29.672	\N
bdbd1a37-f47b-4aa2-b70e-0f0fbf1dd1da	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	up	down	2026-10-05 05:26:41.862	\N
179cd44d-b7ac-4ad8-92b7-d692d3660791	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	up	down	2026-10-05 05:26:41.862	\N
92cd4e88-d5ea-438f-a030-7fa9583bf4c9	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	up	down	2026-10-05 05:26:41.867	\N
376d8187-0aa5-4171-8a1a-45fc8fceb4cb	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	up	down	2026-10-05 05:26:41.867	\N
9b53c089-2760-49c7-846e-9bc0bd2bb24b	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	up	down	2026-10-05 05:26:41.868	\N
a12910ad-456f-4457-b027-b5b7d64ae43e	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	up	down	2026-10-05 05:26:41.867	\N
664ebb6c-b2ce-4829-a6c2-938a5cfbdef1	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	up	down	2026-10-05 05:26:41.868	\N
400e2502-2784-43f1-8c1a-45bc9d2541ec	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	up	down	2026-10-05 05:26:41.874	\N
0ed6c2e9-ec05-4e0c-868a-30578d4c52ca	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	up	down	2026-10-05 05:26:41.874	\N
479d68be-99db-46d8-b1e7-7013c2be5c89	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	up	down	2026-10-05 05:26:41.875	\N
c5283a24-17d4-469d-9c81-81cc9d85481a	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	up	down	2026-10-05 05:26:41.876	\N
26c95f31-be06-4dc4-8e92-65a0fe43dc3f	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	down	up	2026-10-05 05:41:06.557	\N
4e7796d3-ba2b-46ea-9366-ce6564888c1c	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	down	up	2026-10-05 05:41:06.557	\N
261c143a-3858-45e4-b0c5-9ab65e6eecd5	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	down	up	2026-10-05 05:41:06.557	\N
7c90b893-4982-4e63-b73c-a6d3fc335c54	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	down	up	2026-10-05 05:41:06.558	\N
507b1b2f-12ea-4cd6-9d0d-19bb1103411d	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	down	up	2026-10-05 05:41:06.558	\N
b1eb0755-db4a-4b37-9398-006beb99457b	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	down	up	2026-10-05 05:41:06.559	\N
00fec23c-3ca8-4287-b92c-1ae872f700b8	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	down	up	2026-10-05 05:41:06.559	\N
f730312e-3528-4317-a209-ed63628e3640	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	down	up	2026-10-05 05:41:06.561	\N
d097bcf9-c11b-46e5-97e7-054fbf5525f3	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	down	up	2026-10-05 05:41:06.563	\N
522c1c34-af63-419e-bd8d-36fa71307e4a	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	down	up	2026-10-05 05:41:06.563	\N
4cdc6920-d4a9-4837-815a-c13bc9c7ca70	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	down	up	2026-10-05 05:41:06.563	\N
dfd622ce-4306-456e-abb4-d60154fe7e90	backend	7288259e-9538-4b21-b7eb-36339e423ad7	localhost:7000	down	up	2026-10-05 05:53:23.658	\N
34867ae1-ac2e-46bd-b25d-c7ba32dafba3	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	up	slow	2026-10-05 06:04:23.404	\N
eac0ed62-4eed-4f5b-a720-0f37f3f1d319	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	up	slow	2026-10-05 06:04:23.405	\N
ebc7c51e-8068-41cb-ae77-c27c41e558d0	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	up	slow	2026-10-05 06:04:23.405	\N
3ccab52c-41b1-4a60-b4f2-58b6521851c7	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	up	slow	2026-10-05 06:04:23.405	\N
3623ddf1-7f9f-4abe-ae3d-c3af1f27c31e	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	up	slow	2026-10-05 06:04:23.405	\N
d8057f06-7c98-4a3b-b179-d454d95f19dd	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	up	slow	2026-10-05 06:04:23.41	\N
de94956f-46c3-4056-80cf-2124d5d97b2c	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	up	slow	2026-10-05 06:04:23.411	\N
0334a3c1-3f7c-478d-8265-e34b93ed51d1	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	up	slow	2026-10-05 06:04:23.411	\N
0229f073-1bc6-4954-990b-c9023e5f7459	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	up	slow	2026-10-05 06:04:23.411	\N
8c9c3aeb-dee3-4448-a9bf-a415c59780c9	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	up	slow	2026-10-05 06:04:23.411	\N
50046ecb-44bd-4f2d-8fec-65eaaf13945a	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	up	slow	2026-10-05 06:04:23.412	\N
3b8c168e-9f80-49fd-9e90-259168532b43	backend	a830ee9a-87da-4280-9ec7-e547ef244051	10.0.0.100:8989	slow	up	2026-10-05 06:04:51.884	\N
db200b8f-f671-49f9-a560-9fd0045e2c18	backend	6a2f9668-696a-42bf-8c49-3429fc393581	10.0.0.100:8082	slow	up	2026-10-05 06:04:51.884	\N
95b89176-3dfc-4245-8201-e08d1e58d214	backend	d53359f8-0936-4edd-bac6-65298f541aca	10.0.0.100:8333	slow	up	2026-10-05 06:04:51.884	\N
9f507d94-13b0-4f4d-8659-c38f4c03da20	backend	3c13e9b8-dded-4acd-99a2-eec56dea599e	10.0.0.100:3010	slow	up	2026-10-05 06:04:51.884	\N
7106f271-49c1-4280-8792-45f72c266f66	backend	8aeb84e7-f0d3-4577-8edb-34823b3e8e47	10.0.0.100:5050	slow	up	2026-10-05 06:04:51.885	\N
6b0df8f5-0783-4696-80fd-1fda8b64f8a8	backend	262738e7-53aa-4415-a3f1-2265f3ba9773	10.0.0.100:9011	slow	up	2026-10-05 06:04:51.885	\N
811d37c6-201c-432a-958d-4ef5352938d5	backend	bc194eb2-5992-40e4-b518-6d96933dffb9	10.0.0.100:5000	slow	up	2026-10-05 06:04:51.885	\N
fc413c22-f362-4ab0-a665-fbae7b3cea18	backend	1cbb503f-01dd-4427-bab5-30006e1fe60b	10.0.0.200:8786	slow	up	2026-10-05 06:04:51.884	\N
3e7793a0-b39b-44f8-81bf-c1a5cc497d8c	backend	0c959eb9-7b7e-4565-b414-1923670acc19	10.0.0.200:8080	slow	up	2026-10-05 06:04:51.885	\N
721fe4e8-8367-4da2-8a3a-b852c4114616	backend	a7a3748e-e607-4880-9c19-c642e6557535	10.0.0.100:8090	slow	up	2026-10-05 06:04:51.885	\N
e2d89837-4720-4e39-9e6a-ec478948ce36	backend	af946847-9d32-403e-9910-eaaeeb0d5081	10.0.0.200:8096	slow	up	2026-10-05 06:04:51.885	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, "passwordHash", role, email, "createdAt", "updatedAt") FROM stdin;
832098a3-e809-462c-9535-d2e5af015220	admin	$2a$10$hAAOqsQT/QIuy4EIaqnlsOGSFwk54j.m0jaN9v7zdGKnrWkl4braK	admin	admin@leadowserver.local	2026-10-05 04:56:20.53	2026-10-05 04:56:20.53
a2530ad9-96bf-4849-bd96-991aa13a2156	viewer	$2a$10$JHzbBGW7WjmBDp5EpltCUu9V4ATWn0xfdNFJj3EXzxJS4q8mrdDxW	viewer	viewer@leadowserver.local	2026-10-05 04:56:20.664	2026-10-05 04:56:20.664
\.


--
-- Name: alert_logs alert_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alert_logs
    ADD CONSTRAINT alert_logs_pkey PRIMARY KEY (id);


--
-- Name: alert_rules alert_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alert_rules
    ADD CONSTRAINT alert_rules_pkey PRIMARY KEY (id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: backends backends_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.backends
    ADD CONSTRAINT backends_pkey PRIMARY KEY (id);


--
-- Name: config_files config_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.config_files
    ADD CONSTRAINT config_files_pkey PRIMARY KEY (id);


--
-- Name: custom_field_values custom_field_values_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_field_values
    ADD CONSTRAINT custom_field_values_pkey PRIMARY KEY (id);


--
-- Name: custom_fields custom_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_fields
    ADD CONSTRAINT custom_fields_pkey PRIMARY KEY (id);


--
-- Name: issues issues_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT issues_pkey PRIMARY KEY (id);


--
-- Name: port_checks port_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.port_checks
    ADD CONSTRAINT port_checks_pkey PRIMARY KEY (id);


--
-- Name: ports ports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ports
    ADD CONSTRAINT ports_pkey PRIMARY KEY (id);


--
-- Name: routes routes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);


--
-- Name: saved_views saved_views_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saved_views
    ADD CONSTRAINT saved_views_pkey PRIMARY KEY (id);


--
-- Name: servers servers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.servers
    ADD CONSTRAINT servers_pkey PRIMARY KEY (id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: status_events status_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.status_events
    ADD CONSTRAINT status_events_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: alert_logs_sentAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "alert_logs_sentAt_idx" ON public.alert_logs USING btree ("sentAt");


--
-- Name: audit_log_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "audit_log_createdAt_idx" ON public.audit_log USING btree ("createdAt");


--
-- Name: audit_log_entity_entityId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "audit_log_entity_entityId_idx" ON public.audit_log USING btree (entity, "entityId");


--
-- Name: backends_host_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX backends_host_idx ON public.backends USING btree (host);


--
-- Name: backends_host_port_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX backends_host_port_key ON public.backends USING btree (host, port);


--
-- Name: backends_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX backends_status_idx ON public.backends USING btree (status);


--
-- Name: config_files_filename_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX config_files_filename_key ON public.config_files USING btree (filename);


--
-- Name: config_files_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX config_files_status_idx ON public.config_files USING btree (status);


--
-- Name: custom_field_values_entityType_entityId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "custom_field_values_entityType_entityId_idx" ON public.custom_field_values USING btree ("entityType", "entityId");


--
-- Name: custom_field_values_fieldId_entityId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "custom_field_values_fieldId_entityId_key" ON public.custom_field_values USING btree ("fieldId", "entityId");


--
-- Name: custom_fields_entityType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "custom_fields_entityType_idx" ON public.custom_fields USING btree ("entityType");


--
-- Name: custom_fields_key_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX custom_fields_key_key ON public.custom_fields USING btree (key);


--
-- Name: issues_autoKey_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "issues_autoKey_key" ON public.issues USING btree ("autoKey");


--
-- Name: issues_priority_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX issues_priority_idx ON public.issues USING btree (priority);


--
-- Name: issues_source_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX issues_source_idx ON public.issues USING btree (source);


--
-- Name: issues_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX issues_status_idx ON public.issues USING btree (status);


--
-- Name: port_checks_checkedAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "port_checks_checkedAt_idx" ON public.port_checks USING btree ("checkedAt");


--
-- Name: port_checks_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX port_checks_status_idx ON public.port_checks USING btree (status);


--
-- Name: port_checks_targetType_targetId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "port_checks_targetType_targetId_idx" ON public.port_checks USING btree ("targetType", "targetId");


--
-- Name: ports_layer_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ports_layer_idx ON public.ports USING btree (layer);


--
-- Name: ports_port_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ports_port_key ON public.ports USING btree (port);


--
-- Name: ports_protocol_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ports_protocol_idx ON public.ports USING btree (protocol);


--
-- Name: ports_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ports_status_idx ON public.ports USING btree (status);


--
-- Name: routes_action_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX routes_action_idx ON public.routes USING btree (action);


--
-- Name: routes_domain_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX routes_domain_idx ON public.routes USING btree (domain);


--
-- Name: routes_portNum_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "routes_portNum_idx" ON public.routes USING btree ("portNum");


--
-- Name: routes_targetType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "routes_targetType_idx" ON public.routes USING btree ("targetType");


--
-- Name: saved_views_page_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX saved_views_page_idx ON public.saved_views USING btree (page);


--
-- Name: status_events_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX status_events_at_idx ON public.status_events USING btree (at);


--
-- Name: status_events_targetType_targetId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "status_events_targetType_targetId_idx" ON public.status_events USING btree ("targetType", "targetId");


--
-- Name: users_username_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_username_key ON public.users USING btree (username);


--
-- Name: alert_logs alert_logs_ruleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alert_logs
    ADD CONSTRAINT "alert_logs_ruleId_fkey" FOREIGN KEY ("ruleId") REFERENCES public.alert_rules(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: backends backends_serverId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.backends
    ADD CONSTRAINT "backends_serverId_fkey" FOREIGN KEY ("serverId") REFERENCES public.servers(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: custom_field_values custom_field_values_fieldId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_field_values
    ADD CONSTRAINT "custom_field_values_fieldId_fkey" FOREIGN KEY ("fieldId") REFERENCES public.custom_fields(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: issues issues_relatedPortId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT "issues_relatedPortId_fkey" FOREIGN KEY ("relatedPortId") REFERENCES public.ports(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: issues issues_relatedRouteId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT "issues_relatedRouteId_fkey" FOREIGN KEY ("relatedRouteId") REFERENCES public.routes(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: routes routes_backendId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT "routes_backendId_fkey" FOREIGN KEY ("backendId") REFERENCES public.backends(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: routes routes_configFileId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT "routes_configFileId_fkey" FOREIGN KEY ("configFileId") REFERENCES public.config_files(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: routes routes_portId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT "routes_portId_fkey" FOREIGN KEY ("portId") REFERENCES public.ports(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict hPC1poLcc0sOVNPLTaAAqKvkcIUIEXxd7oGeXdTR2uMXHT92AUvHg0wcsdbhde8

