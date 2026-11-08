/*
================================================================================================================
PROJECT: MAVEN FUZZY FACTORY
SECTION: ANALYZING TRAFFIC SOURCES
================================================================================================================

TRAFFIC SOURCE ANALYSIS:

Traffic Source Analysis is about understanding where customers are coming from
and which channels are driving the highest quality traffic.

COMMON USE CASES:
    -- Analyzing search data and shifting budget towards the engines, campaigns
       or keywords driving the strongest conversion rates.
    -- Comparing user behavior patterns across traffic sources to inform
       creative and messaging strategy.
    -- Identifying opportunities to eliminate wasted spend or scale
       high-converting traffic.

KEY TABLES:
    -- website_sessions
    -- website_pageviews
    -- orders

================================================================================================================
*/


/*
================================================================================================================
APRIL 12, 2012
EMAIL FROM: CINDY SHARP (CEO)
SUBJECT: SITE TRAFFIC BREAKDOWN
================================================================================================================

Good morning,

We've been live for almost a month now and we're starting to generate sales.
Can you help me understand where the bulk of our website sessions are coming
from, through yesterday?

I'd like to see a breakdown by UTM source, campaign and referring domain,
if possible.

Thanks!
- Cindy


================================================================================================================
SQL ANALYSIS 01: WEBSITE TRAFFIC BREAKDOWN
================================================================================================================
*/


    SELECT
        utm_source,
        utm_campaign,
        http_referer,
        COUNT(DISTINCT website_session_id) AS num_sessions
    FROM website_sessions
    WHERE created_at < '2012-04-12'
    GROUP BY
        utm_source,
        utm_campaign,
        http_referer
    ORDER BY num_sessions DESC;


/*
================================================================================================================
APRIL 14, 2012
EMAIL FROM: TOM PARMESAN (MARKETING DIRECTOR)
SUBJECT: GSEARCH CONVERSION RATE
================================================================================================================

Hi there,

Sounds like gsearch nonbrand is our major traffic source, but we need to
understand if those sessions are driving sales.

Could you please calculate the conversion rate (CVR) from session to order?
Based on what we're paying for clicks, we'll need a CVR of at least 4% to
make the numbers work.

If we're much lower, we'll need to reduce bids. If we're higher, we can
increase bids to drive more volume.

Thanks,
Tom


================================================================================================================
SQL ANALYSIS 02: GSEARCH SESSION-TO-ORDER CONVERSION RATE
================================================================================================================
*/


    SELECT
        COUNT(DISTINCT ws.website_session_id) AS [sessions],
        COUNT(DISTINCT o.order_id) AS total_orders,
        FORMAT(
            CAST(COUNT(DISTINCT o.order_id) AS FLOAT) /
            CAST(COUNT(DISTINCT ws.website_session_id) AS FLOAT),
            'P2'
        ) AS session_to_order_conversion_rate
    FROM website_sessions ws
    LEFT JOIN orders o
        ON ws.website_session_id = o.website_session_id
    WHERE ws.created_at < '2012-04-14'
        AND ws.utm_source = 'gsearch'
        AND ws.utm_campaign = 'nonbrand';


/*
================================================================================================================
APRIL 14, 2012
EMAIL FROM: TOM PARMESAN (MARKETING DIRECTOR)
SUBJECT: RE: GSEARCH CONVERSION RATE
================================================================================================================

Hmm, looks like we're below the 4% threshold we need to make the economics work.

Based on this analysis, we'll need to dial down our search bids a bit.
We're over-spending based on the current conversion rate.

Nice work, your analysis just saved us some $$$!


================================================================================================================
MAY 12, 2012
EMAIL FROM: TOM PARMESAN (MARKETING DIRECTOR)
SUBJECT: GSEARCH VOLUME TRENDS
================================================================================================================

Hi there,

Based on your conversion rate analysis, we bid down gsearch nonbrand on
2012-04-15.

Can you pull gsearch nonbrand trended session volume, by week, to see if
the bid changes have caused volume to drop at all?

Thanks,
Tom


================================================================================================================
SQL ANALYSIS 03: GSEARCH WEEKLY SESSION VOLUME TRENDS
================================================================================================================
*/


    SELECT
        YEAR(created_at) AS year,
        DATEPART(WEEK, created_at) AS week,
        CAST(MIN(created_at) AS DATE) AS week_start,
        COUNT(DISTINCT website_session_id) AS sessions
    FROM website_sessions
    WHERE created_at < '2012-05-10'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
    GROUP BY
        YEAR(created_at),
        DATEPART(WEEK, created_at)
    ORDER BY DATEPART(WEEK, created_at) ASC;


/*
================================================================================================================
MAY 11, 2012
EMAIL FROM: TOM PARMESAN (MARKETING DIRECTOR)
SUBJECT: GSEARCH DEVICE-LEVEL PERFORMANCE
================================================================================================================

Hi there,

I was trying to use our site on my mobile device the other day, and the
experience was not great.

Could you pull conversion rates from session to order, by device type?

If desktop performance is better than on mobile we may be able to bid up
for desktop specifically to get more volume?

Thanks,
Tom


================================================================================================================
SQL ANALYSIS 04: DEVICE-LEVEL SESSION-TO-ORDER CONVERSION RATE
================================================================================================================
*/


    SELECT
        ws.device_type,
        COUNT(DISTINCT ws.website_session_id) AS sessions,
        COUNT(DISTINCT o.order_id) AS orders,
        FORMAT(
            CAST(COUNT(DISTINCT o.order_id) AS FLOAT) /
            CAST(COUNT(DISTINCT ws.website_session_id) AS FLOAT),
            'P2'
        ) AS session_to_order_conversion_rate
    FROM website_sessions ws
    LEFT JOIN orders o
        ON ws.website_session_id = o.website_session_id
    WHERE ws.created_at < '2012-05-11'
        AND ws.utm_source = 'gsearch'
        AND ws.utm_campaign = 'nonbrand'
    GROUP BY ws.device_type;


/*
================================================================================================================
JUNE 09, 2012
EMAIL FROM: TOM PARMESAN (MARKETING DIRECTOR)
SUBJECT: GSEARCH DEVICE-LEVEL TRENDS
================================================================================================================

Hi there,

After your device-level analysis of conversion rates, we realized desktop
was doing well, so we bid our gsearch nonbrand desktop campaigns up on
2012-05-19.

Could you pull weekly trends for both desktop and mobile so we can see
the impact on volume?

You can use 2012-04-15 until the bid change as a baseline.

Thanks,
Tom


================================================================================================================
SQL ANALYSIS 05: WEEKLY DEVICE-LEVEL SESSION VOLUME TRENDS
================================================================================================================
*/


    SELECT
        YEAR(created_at) AS year,
        DATEPART(WEEK, created_at) AS week,
        CAST(MIN(created_at) AS DATE) AS week_start,
        COUNT(DISTINCT CASE
            WHEN device_type = 'desktop' THEN website_session_id
        END) AS desktop_sessions,
        COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
        END) AS mobile_sessions,
        COUNT(DISTINCT website_session_id) AS total_sessions
    FROM website_sessions ws
    WHERE ws.created_at < '2012-06-09'
        AND ws.created_at > '2012-04-15'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
    GROUP BY
        YEAR(created_at),
        DATEPART(WEEK, created_at)
    ORDER BY DATEPART(WEEK, created_at) ASC;
