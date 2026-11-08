/*
================================================================================================================
PROJECT: MAVEN FUZZY FACTORY
FINAL COURSE PROJECT
================================================================================================================

ANALYSIS 01: QUARTERLY SESSION AND ORDER VOLUME
BUSINESS REQUIREMENT:
Show overall business growth by pulling quarterly website session and order
volume throughout the lifetime of the business. The most recent quarter
is incomplete, so handle it appropriately.
*/


    SELECT
        YEAR(ws.created_at) AS yr,
        DATEPART(QUARTER, ws.created_at) AS qtr,
        COUNT(DISTINCT ws.website_session_id) AS sessions,
        COUNT(DISTINCT o.order_id) AS orders
    FROM website_sessions AS ws
    LEFT JOIN orders AS o
        ON ws.website_session_id = o.website_session_id
    GROUP BY
        YEAR(ws.created_at),
        DATEPART(QUARTER, ws.created_at)
    ORDER BY
        yr, qtr;


/*
================================================================================================================
ANALYSIS 02: QUARTERLY BUSINESS EFFICIENCY IMPROVEMENTS
BUSINESS REQUIREMENT:
Showcase business efficiency improvements since launch by pulling quarterly
session-to-order conversion rate, revenue per order, and revenue per session.
*/


    SELECT
        YEAR(ws.created_at) AS yr,
        DATEPART(QUARTER, ws.created_at) AS qtr,
        CAST(COUNT(DISTINCT o.order_id) AS FLOAT)
            / NULLIF(COUNT(DISTINCT ws.website_session_id), 0) AS session_to_order_conv_rate,
        SUM(o.price_usd)
            / NULLIF(COUNT(DISTINCT o.order_id), 0) AS revenue_per_order,
        SUM(o.price_usd)
            / NULLIF(COUNT(DISTINCT ws.website_session_id), 0) AS revenue_per_session
    FROM website_sessions AS ws
    LEFT JOIN orders AS o
        ON ws.website_session_id = o.website_session_id
    GROUP BY
        YEAR(ws.created_at),
        DATEPART(QUARTER, ws.created_at)
    ORDER BY
        yr, qtr;


/*
================================================================================================================
ANALYSIS 03: QUARTERLY ORDERS BY TRAFFIC CHANNEL
BUSINESS REQUIREMENT:
Show quarterly order trends for Gsearch nonbrand, Bsearch nonbrand,
brand search, organic search, and direct type-in traffic to understand
how the different marketing channels have grown.
*/


    SELECT
        YEAR(ws.created_at) AS yr,
        DATEPART(QUARTER, ws.created_at) AS qtr,
        COUNT(DISTINCT CASE
            WHEN ws.utm_source = 'gsearch' AND ws.utm_campaign = 'nonbrand'
            THEN o.order_id
        END) AS gsearch_nonbrand_orders,
        COUNT(DISTINCT CASE
            WHEN ws.utm_source = 'bsearch' AND ws.utm_campaign = 'nonbrand'
            THEN o.order_id
        END) AS bsearch_nonbrand_orders,
        COUNT(DISTINCT CASE
            WHEN ws.utm_campaign = 'brand'
            THEN o.order_id
        END) AS brand_search_orders,
        COUNT(DISTINCT CASE
            WHEN ws.utm_source IS NULL AND ws.http_referer IS NOT NULL
            THEN o.order_id
        END) AS organic_search_orders,
        COUNT(DISTINCT CASE
            WHEN ws.utm_source IS NULL AND ws.http_referer IS NULL
            THEN o.order_id
        END) AS direct_type_in_orders
    FROM website_sessions AS ws
    LEFT JOIN orders AS o
        ON ws.website_session_id = o.website_session_id
    GROUP BY
        YEAR(ws.created_at),
        DATEPART(QUARTER, ws.created_at)
    ORDER BY
        yr, qtr;


/*
================================================================================================================
ANALYSIS 04: QUARTERLY CONVERSION RATES BY TRAFFIC CHANNEL
BUSINESS REQUIREMENT:
Pull quarterly session-to-order conversion rates for Gsearch nonbrand,
Bsearch nonbrand, brand search, organic search, and direct type-in traffic.
Identify periods where major improvements or optimizations were made.
*/

    SELECT
        YEAR(ws.created_at) AS yr,
        DATEPART(QUARTER, ws.created_at) AS qtr,
        CAST(COUNT(DISTINCT CASE
            WHEN ws.utm_source = 'gsearch' AND ws.utm_campaign = 'nonbrand'
            THEN o.order_id
        END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT CASE
                WHEN ws.utm_source = 'gsearch' AND ws.utm_campaign = 'nonbrand'
                THEN ws.website_session_id
            END), 0) AS gsearch_nonbrand_conv_rt,
        CAST(COUNT(DISTINCT CASE
            WHEN ws.utm_source = 'bsearch' AND ws.utm_campaign = 'nonbrand'
            THEN o.order_id
        END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT CASE
                WHEN ws.utm_source = 'bsearch' AND ws.utm_campaign = 'nonbrand'
                THEN ws.website_session_id
            END), 0) AS bsearch_nonbrand_conv_rt,
        CAST(COUNT(DISTINCT CASE
            WHEN ws.utm_campaign = 'brand'
            THEN o.order_id
        END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT CASE
                WHEN ws.utm_campaign = 'brand'
                THEN ws.website_session_id
            END), 0) AS brand_search_conv_rt,
        CAST(COUNT(DISTINCT CASE
            WHEN ws.utm_source IS NULL AND ws.http_referer IS NOT NULL
            THEN o.order_id
        END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT CASE
                WHEN ws.utm_source IS NULL AND ws.http_referer IS NOT NULL
                THEN ws.website_session_id
            END), 0) AS organic_search_conv_rt,
        CAST(COUNT(DISTINCT CASE
            WHEN ws.utm_source IS NULL AND ws.http_referer IS NULL
            THEN o.order_id
        END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT CASE
                WHEN ws.utm_source IS NULL AND ws.http_referer IS NULL
                THEN ws.website_session_id
            END), 0) AS direct_type_in_conv_rt
    FROM website_sessions AS ws
    LEFT JOIN orders AS o
        ON ws.website_session_id = o.website_session_id
    GROUP BY
        YEAR(ws.created_at),
        DATEPART(QUARTER, ws.created_at)
    ORDER BY
        yr, qtr;


/*
================================================================================================================
ANALYSIS 05: MONTHLY REVENUE AND MARGIN TRENDS BY PRODUCT
BUSINESS REQUIREMENT:
Pull monthly revenue and margin trends for each product, along with
overall sales and revenue. Identify any noticeable seasonal patterns.
*/


    SELECT
        YEAR(created_at) AS yr,
        MONTH(created_at) AS mo,
        SUM(CASE WHEN product_id = 1 THEN price_usd END) AS mrfuzzy_rev,
        SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd END) AS mrfuzzy_marg,
        SUM(CASE WHEN product_id = 2 THEN price_usd END) AS lovebear_rev,
        SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd END) AS lovebear_marg,
        SUM(CASE WHEN product_id = 3 THEN price_usd END) AS birthdaybear_rev,
        SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd END) AS birthdaybear_marg,
        SUM(CASE WHEN product_id = 4 THEN price_usd END) AS minibear_rev,
        SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd END) AS minibear_marg,
        SUM(price_usd) AS total_revenue,
        SUM(price_usd - cogs_usd) AS total_margin
    FROM order_items
    GROUP BY
        YEAR(created_at),
        MONTH(created_at)
    ORDER BY
        yr, mo;


/*
================================================================================================================
ANALYSIS 06: MONTHLY PRODUCT PAGE PERFORMANCE AND CONVERSION
BUSINESS REQUIREMENT:
Pull monthly sessions visiting the /products page and show how the
percentage of sessions clicking through to another page has changed
over time, along with the conversion rate from /products to an order.
*/


    DROP TABLE IF EXISTS #products_pageviews;
    GO

    SELECT
        website_session_id,
        website_pageview_id,
        created_at AS saw_product_page_at
    INTO #products_pageviews
    FROM website_pageviews
    WHERE pageview_url = '/products';

    SELECT
        YEAR(pp.saw_product_page_at) AS yr,
        MONTH(pp.saw_product_page_at) AS mo,
        COUNT(DISTINCT pp.website_session_id) AS sessions_to_product_page,
        COUNT(DISTINCT wp.website_session_id) AS clicked_to_next_page,
        CAST(COUNT(DISTINCT wp.website_session_id) AS FLOAT)
            / NULLIF(COUNT(DISTINCT pp.website_session_id), 0) AS clickthrough_rt,
        COUNT(DISTINCT o.order_id) AS orders,
        CAST(COUNT(DISTINCT o.order_id) AS FLOAT)
            / NULLIF(COUNT(DISTINCT pp.website_session_id), 0) AS products_to_order_rt
    FROM #products_pageviews AS pp
    LEFT JOIN website_pageviews AS wp
        ON wp.website_session_id = pp.website_session_id
        AND wp.website_pageview_id > pp.website_pageview_id
    LEFT JOIN orders AS o
        ON o.website_session_id = pp.website_session_id
    GROUP BY
        YEAR(pp.saw_product_page_at),
        MONTH(pp.saw_product_page_at)
    ORDER BY
        yr, mo;


/*
================================================================================================================
ANALYSIS 07: PRODUCT CROSS-SELLING PERFORMANCE
BUSINESS REQUIREMENT:
Our fourth product became available as a primary product on December 5, 2014,
having previously been available only as a cross-sell item. Pull sales data
since its introduction and show how effectively each product cross-sells
alongside the other products.
*/


    DROP TABLE IF EXISTS #primary_products;
    GO
    SELECT
        order_id,
        primary_product_id,
        created_at AS ordered_at
    INTO #primary_products
    FROM orders
    WHERE created_at > '2014-12-05';

    -- Identify cross-sell products associated with each primary product order.

    SELECT
        pp.order_id,
        pp.primary_product_id,
        pp.ordered_at,
        oi.product_id AS cross_sell_product_id
    FROM #primary_products AS pp
    LEFT JOIN order_items AS oi
        ON oi.order_id = pp.order_id
        AND oi.is_primary_item = 0;

    -- Calculate cross-sell volume and rates by primary product.

    SELECT
        primary_product_id,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id END) AS _xsold_p1,
        COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id END) AS _xsold_p2,
        COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id END) AS _xsold_p3,
        COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id END) AS _xsold_p4,
        CAST(COUNT(DISTINCT CASE WHEN cross_sell_product_id = 1 THEN order_id END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT order_id), 0) AS p1_xsell_rt,
        CAST(COUNT(DISTINCT CASE WHEN cross_sell_product_id = 2 THEN order_id END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT order_id), 0) AS p2_xsell_rt,
        CAST(COUNT(DISTINCT CASE WHEN cross_sell_product_id = 3 THEN order_id END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT order_id), 0) AS p3_xsell_rt,
        CAST(COUNT(DISTINCT CASE WHEN cross_sell_product_id = 4 THEN order_id END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT order_id), 0) AS p4_xsell_rt
    FROM
    (
        SELECT
            pp.order_id,
            pp.primary_product_id,
            oi.product_id AS cross_sell_product_id
        FROM #primary_products AS pp
        LEFT JOIN order_items AS oi
            ON oi.order_id = pp.order_id
            AND oi.is_primary_item = 0
    ) AS primary_w_cross_sell
    GROUP BY
        primary_product_id
    ORDER BY
        primary_product_id;