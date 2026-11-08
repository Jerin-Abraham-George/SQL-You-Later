/*
================================================================================================================
PROJECT: MAVEN FUZZY FACTORY
SECTION: MID-COURSE PROJECT
DATABASE: Ecommerce_DB
SQL DIALECT: MICROSOFT SQL SERVER (T-SQL)
================================================================================================================

PROJECT OVERVIEW:
Eight business analyses covering marketing performance, traffic acquisition,
conversion optimization, landing page experiments, and revenue impact.

KEY TABLES:
    -- website_sessions
    -- website_pageviews
    -- orders

================================================================================================================
*/


/*
================================================================================================================
ANALYSIS 01: MONTHLY GSEARCH SESSIONS AND ORDERS
================================================================================================================
BUSINESS REQUIREMENT:
Gsearch seems to be the biggest driver of our business. Pull monthly trends
for Gsearch sessions and orders to showcase the growth.
*/


    SELECT
        YEAR(ws.created_at) AS yr,
        MONTH(ws.created_at) AS mo,
        COUNT(DISTINCT ws.website_session_id) AS sessions,
        COUNT(DISTINCT o.order_id) AS orders,
        CAST(COUNT(DISTINCT o.order_id) AS FLOAT)
            / NULLIF(COUNT(DISTINCT ws.website_session_id), 0) AS conv_rate
    FROM website_sessions AS ws
    LEFT JOIN orders AS o
        ON o.website_session_id = ws.website_session_id
    WHERE ws.created_at < '2012-11-27'
        AND ws.utm_source = 'gsearch'
    GROUP BY YEAR(ws.created_at), MONTH(ws.created_at)
    ORDER BY yr, mo;


/*
================================================================================================================
ANALYSIS 02: MONTHLY BRAND VS. NON-BRAND CAMPAIGN TRENDS
================================================================================================================
BUSINESS REQUIREMENT:
Show monthly Gsearch trends split between nonbrand and brand campaigns
to determine whether brand traffic is growing.
*/


    SELECT
        YEAR(ws.created_at) AS yr,
        MONTH(ws.created_at) AS mo,
        COUNT(DISTINCT CASE WHEN ws.utm_campaign = 'nonbrand'
            THEN ws.website_session_id END) AS nonbrand_sessions,
        COUNT(DISTINCT CASE WHEN ws.utm_campaign = 'nonbrand'
            THEN o.order_id END) AS nonbrand_orders,
        COUNT(DISTINCT CASE WHEN ws.utm_campaign = 'brand'
            THEN ws.website_session_id END) AS brand_sessions,
        COUNT(DISTINCT CASE WHEN ws.utm_campaign = 'brand'
            THEN o.order_id END) AS brand_orders
    FROM website_sessions AS ws
    LEFT JOIN orders AS o
        ON o.website_session_id = ws.website_session_id
    WHERE ws.created_at < '2012-11-27'
        AND ws.utm_source = 'gsearch'
    GROUP BY YEAR(ws.created_at), MONTH(ws.created_at)
    ORDER BY yr, mo;


/*
================================================================================================================
ANALYSIS 03: MONTHLY GSEARCH NON-BRAND PERFORMANCE BY DEVICE
================================================================================================================
BUSINESS REQUIREMENT:
Pull monthly Gsearch non-brand sessions and orders split by device type.
*/


    SELECT
        YEAR(ws.created_at) AS yr,
        MONTH(ws.created_at) AS mo,
        COUNT(DISTINCT CASE WHEN ws.device_type = 'desktop'
            THEN ws.website_session_id END) AS desktop_sessions,
        COUNT(DISTINCT CASE WHEN ws.device_type = 'desktop'
            THEN o.order_id END) AS desktop_orders,
        COUNT(DISTINCT CASE WHEN ws.device_type = 'mobile'
            THEN ws.website_session_id END) AS mobile_sessions,
        COUNT(DISTINCT CASE WHEN ws.device_type = 'mobile'
            THEN o.order_id END) AS mobile_orders
    FROM website_sessions AS ws
    LEFT JOIN orders AS o
        ON o.website_session_id = ws.website_session_id
    WHERE ws.created_at < '2012-11-27'
        AND ws.utm_source = 'gsearch'
        AND ws.utm_campaign = 'nonbrand'
    GROUP BY YEAR(ws.created_at), MONTH(ws.created_at)
    ORDER BY yr, mo;


/*
================================================================================================================
ANALYSIS 04: MONTHLY TRAFFIC TRENDS ACROSS ACQUISITION CHANNELS
================================================================================================================
BUSINESS REQUIREMENT:
Compare monthly Gsearch traffic with other channels to assess dependence
on Gsearch and understand traffic diversification.
*/


-- STEP 1: Inspect available sources, campaigns, and referring domains.

    SELECT DISTINCT
        utm_source,
        utm_campaign,
        http_referer
    FROM website_sessions
    WHERE created_at < '2012-11-27'
    ORDER BY utm_source, utm_campaign, http_referer;


-- STEP 2: Compare monthly traffic across acquisition channels.

    SELECT
        YEAR(created_at) AS yr,
        MONTH(created_at) AS mo,
        COUNT(DISTINCT CASE WHEN utm_source = 'gsearch'
            THEN website_session_id END) AS gsearch_paid_sessions,
        COUNT(DISTINCT CASE WHEN utm_source = 'bsearch'
            THEN website_session_id END) AS bsearch_paid_sessions,
        COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL
            THEN website_session_id END) AS organic_search_sessions,
        COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL
            THEN website_session_id END) AS direct_type_in_sessions
    FROM website_sessions
    WHERE created_at < '2012-11-27'
    GROUP BY YEAR(created_at), MONTH(created_at)
    ORDER BY yr, mo;


/*
================================================================================================================
ANALYSIS 05: MONTHLY WEBSITE SESSION-TO-ORDER CONVERSION TRENDS
================================================================================================================
BUSINESS REQUIREMENT:
Show monthly session-to-order conversion rates to demonstrate website
performance improvements over the first eight months.
*/


    SELECT
        YEAR(ws.created_at) AS yr,
        MONTH(ws.created_at) AS mo,
        COUNT(DISTINCT ws.website_session_id) AS sessions,
        COUNT(DISTINCT o.order_id) AS orders,
        CAST(COUNT(DISTINCT o.order_id) AS FLOAT)
            / NULLIF(COUNT(DISTINCT ws.website_session_id), 0) AS conversion_rate
    FROM website_sessions AS ws
    LEFT JOIN orders AS o
        ON o.website_session_id = ws.website_session_id
    WHERE ws.created_at < '2012-11-27'
    GROUP BY YEAR(ws.created_at), MONTH(ws.created_at)
    ORDER BY yr, mo;


/*
================================================================================================================
ANALYSIS 06: ESTIMATING THE REVENUE IMPACT OF THE LANDING PAGE TEST
================================================================================================================
BUSINESS REQUIREMENT:
Estimate the revenue generated by the Gsearch landing page test using
the conversion-rate lift from the test (June 19-July 28) and subsequent
Gsearch non-brand sessions.
*/


-- STEP 1: Find the first pageview ID for /lander-1.

    SELECT
        MIN(website_pageview_id) AS first_test_pv
    FROM website_pageviews
    WHERE pageview_url = '/lander-1';


-- STEP 2: Find the first relevant pageview for each Gsearch non-brand session.

    DROP TABLE IF EXISTS #first_test_pageviews;

    SELECT
        wp.website_session_id,
        MIN(wp.website_pageview_id) AS min_pageview_id
    INTO #first_test_pageviews
    FROM website_pageviews AS wp
    INNER JOIN website_sessions AS ws
        ON ws.website_session_id = wp.website_session_id
    WHERE ws.created_at < '2012-07-28'
        AND wp.website_pageview_id >= 23504
        AND ws.utm_source = 'gsearch'
        AND ws.utm_campaign = 'nonbrand'
    GROUP BY wp.website_session_id;


-- STEP 3: Attach the landing page to each test session.

    DROP TABLE IF EXISTS #nonbrand_test_sessions_w_landing_pages;

    SELECT
        ftp.website_session_id,
        wp.pageview_url AS landing_page
    INTO #nonbrand_test_sessions_w_landing_pages
    FROM #first_test_pageviews AS ftp
    INNER JOIN website_pageviews AS wp
        ON wp.website_pageview_id = ftp.min_pageview_id
    WHERE wp.pageview_url IN ('/home', '/lander-1');


-- STEP 4: Attach orders to the test sessions.

    DROP TABLE IF EXISTS #nonbrand_test_sessions_w_orders;

    SELECT
        lp.website_session_id,
        lp.landing_page,
        o.order_id
    INTO #nonbrand_test_sessions_w_orders
    FROM #nonbrand_test_sessions_w_landing_pages AS lp
    LEFT JOIN orders AS o
        ON o.website_session_id = lp.website_session_id;


-- STEP 5: Compare conversion rates by landing page.

    SELECT
        landing_page,
        COUNT(DISTINCT website_session_id) AS sessions,
        COUNT(DISTINCT order_id) AS orders,
        CAST(COUNT(DISTINCT order_id) AS FLOAT)
            / NULLIF(COUNT(DISTINCT website_session_id), 0) AS conv_rate
    FROM #nonbrand_test_sessions_w_orders
    GROUP BY landing_page
    ORDER BY landing_page;


-- STEP 6: Dynamically identify the most recent Gsearch non-brand session
-- that viewed /home before November 27, 2012.

    DECLARE @last_home_session_id BIGINT;

    SELECT
        @last_home_session_id = MAX(ws.website_session_id)
    FROM website_sessions AS ws
    INNER JOIN website_pageviews AS wp
        ON wp.website_session_id = ws.website_session_id
    WHERE ws.utm_source = 'gsearch'
        AND ws.utm_campaign = 'nonbrand'
        AND wp.pageview_url = '/home'
        AND ws.created_at < '2012-11-27';


-- STEP 7: Count Gsearch non-brand sessions after that session.

    SELECT
        COUNT(DISTINCT website_session_id) AS sessions_since_test
    FROM website_sessions
    WHERE created_at < '2012-11-27'
        AND website_session_id > @last_home_session_id
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand';


/*
================================================================================================================
ANALYSIS 07: FULL CONVERSION FUNNEL - HOMEPAGE VS. CUSTOM LANDING PAGE
================================================================================================================
BUSINESS REQUIREMENT:
Compare the conversion funnel from /home and /lander-1 through the
thank-you page, using the June 19-July 28 landing page test period.
*/


-- STEP 1: Identify each session's first pageview and its landing page.

    DROP TABLE IF EXISTS #landing_test_sessions;

    WITH ranked_pageviews AS
    (
        SELECT
            ws.website_session_id,
            wp.pageview_url,
            ROW_NUMBER() OVER
            (
                PARTITION BY ws.website_session_id
                ORDER BY wp.website_pageview_id
            ) AS pageview_rank
        FROM website_sessions AS ws
        INNER JOIN website_pageviews AS wp
            ON wp.website_session_id = ws.website_session_id
        WHERE ws.utm_source = 'gsearch'
            AND ws.utm_campaign = 'nonbrand'
            AND ws.created_at >= '2012-06-20'
            AND ws.created_at < '2012-07-28'
    )
    SELECT
        website_session_id,
        pageview_url AS landing_page
    INTO #landing_test_sessions
    FROM ranked_pageviews
    WHERE pageview_rank = 1
        AND pageview_url IN ('/home', '/lander-1');


-- STEP 2: Create session-level flags for each funnel page.

    DROP TABLE IF EXISTS #session_level_made_it_flagged;

    SELECT
        lts.website_session_id,
        lts.landing_page,
        MAX(CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END) AS product_made_it,
        MAX(CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS mrfuzzy_made_it,
        MAX(CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart_made_it,
        MAX(CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END) AS shipping_made_it,
        MAX(CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END) AS billing_made_it,
        MAX(CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS thankyou_made_it
    INTO #session_level_made_it_flagged
    FROM #landing_test_sessions AS lts
    LEFT JOIN website_pageviews AS wp
        ON wp.website_session_id = lts.website_session_id
    GROUP BY
        lts.website_session_id,
        lts.landing_page;


-- STEP 3: Count sessions reaching each funnel stage.

    SELECT
        landing_page,
        COUNT(DISTINCT website_session_id) AS sessions,
        COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id END) AS to_products,
        COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id END) AS to_mrfuzzy,
        COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id END) AS to_cart,
        COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id END) AS to_shipping,
        COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id END) AS to_billing,
        COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id END) AS to_thankyou
    FROM #session_level_made_it_flagged
    GROUP BY landing_page
    ORDER BY landing_page;


-- STEP 4: Calculate conversion rates between funnel stages.

    SELECT
        landing_page,

        CAST(COUNT(DISTINCT CASE WHEN product_made_it = 1
            THEN website_session_id END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT website_session_id), 0) AS lander_click_rate,

        CAST(COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1
            THEN website_session_id END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT CASE WHEN product_made_it = 1
            THEN website_session_id END), 0) AS products_click_rate,

        CAST(COUNT(DISTINCT CASE WHEN cart_made_it = 1
            THEN website_session_id END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1
            THEN website_session_id END), 0) AS mrfuzzy_click_rate,

        CAST(COUNT(DISTINCT CASE WHEN shipping_made_it = 1
            THEN website_session_id END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT CASE WHEN cart_made_it = 1
            THEN website_session_id END), 0) AS cart_click_rate,

        CAST(COUNT(DISTINCT CASE WHEN billing_made_it = 1
            THEN website_session_id END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT CASE WHEN shipping_made_it = 1
            THEN website_session_id END), 0) AS shipping_click_rate,

        CAST(COUNT(DISTINCT CASE WHEN thankyou_made_it = 1
            THEN website_session_id END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT CASE WHEN billing_made_it = 1
            THEN website_session_id END), 0) AS billing_click_rate

    FROM #session_level_made_it_flagged
    GROUP BY landing_page
    ORDER BY landing_page;


/*
================================================================================================================
ANALYSIS 08: BILLING PAGE TEST - REVENUE LIFT AND MONTHLY IMPACT
================================================================================================================
BUSINESS REQUIREMENT:
Quantify the billing page test lift in revenue per billing page session
(September 10-November 10), then count billing page sessions in the
most recent month to estimate the monthly impact.
*/


-- STEP 1: Identify unique sessions exposed to each billing page version.

    DROP TABLE IF EXISTS #billing_test_sessions;

    SELECT DISTINCT
        website_session_id,
        pageview_url AS billing_version_seen
    INTO #billing_test_sessions
    FROM website_pageviews
    WHERE created_at >= '2012-09-10'
        AND created_at < '2012-11-10'
        AND pageview_url IN ('/billing', '/billing-2');


-- STEP 2: Calculate revenue per billing page session.
-- Aggregate orders to one row per session to avoid duplicating revenue.

    SELECT
        bts.billing_version_seen,
        COUNT(DISTINCT bts.website_session_id) AS sessions,
        COALESCE(SUM(o.session_revenue), 0) AS total_revenue,
        CAST(COALESCE(SUM(o.session_revenue), 0) AS FLOAT)
            / NULLIF(COUNT(DISTINCT bts.website_session_id), 0)
            AS revenue_per_billing_page_session
    FROM #billing_test_sessions AS bts
    LEFT JOIN
    (
        SELECT
            website_session_id,
            SUM(price_usd) AS session_revenue
        FROM orders
        GROUP BY website_session_id
    ) AS o
        ON o.website_session_id = bts.website_session_id
    GROUP BY bts.billing_version_seen
    ORDER BY bts.billing_version_seen;


-- STEP 3: Count unique billing page sessions during the past month.

    SELECT
        COUNT(DISTINCT website_session_id) AS billing_sessions_past_month
    FROM website_pageviews
    WHERE pageview_url IN ('/billing', '/billing-2')
        AND created_at >= '2012-10-27'
        AND created_at < '2012-11-27';

