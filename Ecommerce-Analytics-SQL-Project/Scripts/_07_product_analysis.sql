/*
================================================================================================================
PROJECT: MAVEN FUZZY FACTORY
SECTION: PRODUCT ANALYSIS
================================================================================================================

PRODUCT ANALYSIS

Product Analysis focuses on evaluating the sales performance and profitability
of individual products. It helps the business understand which products generate
revenue, contribute to margins, and drive overall business growth.

COMMON USE CASES:
    -- Tracking product sales and revenue trends over time.
    -- Evaluating product profitability and contribution margins.
    -- Identifying top-performing and underperforming products.
    -- Measuring the business impact of new product launches.
    -- Supporting product pricing, inventory and growth decisions.

KEY TABLES:
    -- orders
    -- order_items
    -- products

================================================================================================================
*/



USE mavenfuzzyfactory;
GO

/*
================================================================================================================
PROJECT: MAVEN FUZZY FACTORY
SECTION: PRODUCT ANALYSIS
ANALYSIS 01: MONTHLY SALES, REVENUE AND MARGIN TRENDS
================================================================================================================

JANUARY 04, 2013
EMAIL FROM: CINDY SHARP (CEO)
SUBJECT: SALES TRENDS

Good morning,

We're about to launch a new product, and I'd like to do a deep dive on our
current flagship product.

Can you please pull monthly trends to date for number of sales, total revenue,
and total margin generated for the business?

Thanks,
Cindy

================================================================================================================
SQL ANALYSIS
================================================================================================================
*/


    SELECT
        YEAR(created_at) AS yr,
        MONTH(created_at) AS mo,
        COUNT(DISTINCT order_id) AS number_of_sales,
        SUM(price_usd) AS total_revenue,
        SUM(price_usd - cogs_usd) AS total_margin
    FROM orders
    WHERE created_at < '2013-01-04'
    GROUP BY
        YEAR(created_at),
        MONTH(created_at)
    ORDER BY
        yr,
        mo;


/*
================================================================================================================
APRIL 05, 2013
EMAIL FROM: CINDY SHARP (CEO)
SUBJECT: IMPACT OF NEW PRODUCT LAUNCH
================================================================================================================

Good morning,

We launched our second product back on January 6th. Can you pull together
some trended analysis?

I'd like to see monthly order volume, overall conversion rates, revenue
per session, and a breakdown of sales by product, all for the time period
since April 1, 2013.

Thanks,
Cindy

================================================================================================================
SQL ANALYSIS
================================================================================================================
*/


    SELECT
        YEAR(ws.created_at) AS yr,
        MONTH(ws.created_at) AS mo,
        COUNT(DISTINCT o.order_id) AS orders,
        CAST(COUNT(DISTINCT o.order_id) AS FLOAT) /
            NULLIF(COUNT(DISTINCT ws.website_session_id), 0) AS conv_rate,
        CAST(SUM(o.price_usd) AS FLOAT) /
            NULLIF(COUNT(DISTINCT ws.website_session_id), 0) AS revenue_per_session,
        COUNT(DISTINCT CASE
            WHEN o.primary_product_id = 1 THEN o.order_id
        END) AS product_one_orders,
        COUNT(DISTINCT CASE
            WHEN o.primary_product_id = 2 THEN o.order_id
        END) AS product_two_orders
    FROM website_sessions AS ws
    LEFT JOIN orders AS o
        ON ws.website_session_id = o.website_session_id
    WHERE ws.created_at < '2013-04-05'
        AND ws.created_at > '2012-04-01'
    GROUP BY
        YEAR(ws.created_at),
        MONTH(ws.created_at)
    ORDER BY
        yr,
        mo;


/*
================================================================================================================
APRIL 06, 2014
EMAIL FROM: MORGAN ROCKWELL (WEBSITE MANAGER)
SUBJECT: HELP W/ USER PATHING
================================================================================================================

Hi there!

Now that we have a new product, I'm thinking about our user path and
conversion funnel. Let's look at sessions which hit the /products page
and see where they went next.

Could you please pull clickthrough rates from /products since the new
product launch on January 6th 2013, by product, and compare to the
3 months leading up to launch as a baseline?

Thanks,
Morgan

================================================================================================================
SQL ANALYSIS
================================================================================================================
*/


    -- Step 1: Identify sessions that viewed the /products page  and classify them into pre-launch and post-launch periods.

    DROP TABLE IF EXISTS #products_pageviews;

    SELECT
        website_session_id,
        website_pageview_id,
        created_at,
        CASE
            WHEN created_at < '2013-01-06' THEN 'A. Pre_Product_2'
            WHEN created_at >= '2013-01-06' THEN 'B. Post_Product_2'
            ELSE 'Check Logic'
        END AS time_period
    INTO #products_pageviews
    FROM website_pageviews
    WHERE created_at < '2013-04-06'
        AND created_at > '2012-10-06'
        AND pageview_url = '/products';


    -- Step 2: Find the next pageview ID after the /products page for each session.

    DROP TABLE IF EXISTS #sessions_w_next_pageview_id;

    SELECT
        pp.time_period,
        pp.website_session_id,
        MIN(wp.website_pageview_id) AS min_next_pageview_id
    INTO #sessions_w_next_pageview_id
    FROM #products_pageviews AS pp
    LEFT JOIN website_pageviews AS wp
        ON wp.website_session_id = pp.website_session_id
        AND wp.website_pageview_id > pp.website_pageview_id
    GROUP BY
        pp.time_period,
        pp.website_session_id;


    -- Step 3: Retrieve the URL of the next pageview.

    DROP TABLE IF EXISTS #sessions_w_next_pageview_url;

    SELECT
        sn.time_period,
        sn.website_session_id,
        wp.pageview_url AS next_pageview_url
    INTO #sessions_w_next_pageview_url
    FROM #sessions_w_next_pageview_id AS sn
    LEFT JOIN website_pageviews AS wp
        ON wp.website_pageview_id = sn.min_next_pageview_id;


    -- Step 4: Compare clickthrough rates before and after
    -- the launch of the second product.

    SELECT
        time_period,
        COUNT(DISTINCT website_session_id) AS sessions,
        COUNT(DISTINCT CASE
            WHEN next_pageview_url IS NOT NULL
            THEN website_session_id
        END) AS sessions_with_next_pageview,
        CAST(
            COUNT(DISTINCT CASE
                WHEN next_pageview_url IS NOT NULL
                THEN website_session_id
            END) AS FLOAT
        ) / NULLIF(COUNT(DISTINCT website_session_id), 0) AS pct_with_next_pageview,
        COUNT(DISTINCT CASE
            WHEN next_pageview_url = '/the-original-mr-fuzzy'
            THEN website_session_id
        END) AS to_mrfuzzy,
        CAST(
            COUNT(DISTINCT CASE
                WHEN next_pageview_url = '/the-original-mr-fuzzy'
                THEN website_session_id
            END) AS FLOAT
        ) / NULLIF(COUNT(DISTINCT website_session_id), 0) AS pct_to_mrfuzzy,
        COUNT(DISTINCT CASE
            WHEN next_pageview_url = '/the-forever-love-bear'
            THEN website_session_id
        END) AS to_lovebear,
        CAST(
            COUNT(DISTINCT CASE
                WHEN next_pageview_url = '/the-forever-love-bear'
                THEN website_session_id
            END) AS FLOAT
        ) / NULLIF(COUNT(DISTINCT website_session_id), 0) AS pct_to_lovebear
    FROM #sessions_w_next_pageview_url
    GROUP BY
        time_period
    ORDER BY
        time_period;


/*
================================================================================================================
APRIL 10, 2014
EMAIL FROM: MORGAN ROCKWELL (WEBSITE MANAGER)
SUBJECT: PRODUCT CONVERSION FUNNELS
================================================================================================================

Hi there!

I'd like to look at our two products since January 6th and analyze the
conversion funnels from each product page to conversion.

It would be great if you could produce a comparison between the two
conversion funnels, for all website traffic.

Thanks!
-Morgan

================================================================================================================
SQL ANALYSIS
================================================================================================================
*/


    -- STEP 1: Identify sessions that viewed either product page.

    DROP TABLE IF EXISTS #sessions_seeing_product_pages;

    SELECT
        website_session_id,
        website_pageview_id,
        pageview_url AS product_page_seen
    INTO #sessions_seeing_product_pages
    FROM website_pageviews
    WHERE created_at < '2013-04-10'
        AND created_at > '2013-01-06'
        AND pageview_url IN (
            '/the-original-mr-fuzzy',
            '/the-forever-love-bear'
        );


    -- STEP 2: Identify the pages visited after each product page.
    -- This helps determine the appropriate steps for the conversion funnels.

    SELECT DISTINCT
        wp.pageview_url
    FROM #sessions_seeing_product_pages AS spp
    LEFT JOIN website_pageviews AS wp
        ON wp.website_session_id = spp.website_session_id
        AND wp.website_pageview_id > spp.website_pageview_id;


    -- STEP 3: Identify whether visitors reached each subsequent funnel page.

    DROP TABLE IF EXISTS #session_product_level_made_it_flags;

    SELECT
        website_session_id,
        CASE
            WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
            WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
            ELSE 'Check Logic'
        END AS product_seen,
        MAX(cart_page) AS cart_made_it,
        MAX(shipping_page) AS shipping_made_it,
        MAX(billing_page) AS billing_made_it,
        MAX(thankyou_page) AS thankyou_made_it
    INTO #session_product_level_made_it_flags
    FROM
    (
        SELECT
            spp.website_session_id,
            spp.product_page_seen,
            CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
            CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
            CASE WHEN wp.pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
            CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
        FROM #sessions_seeing_product_pages AS spp
        LEFT JOIN website_pageviews AS wp
            ON wp.website_session_id = spp.website_session_id
            AND wp.website_pageview_id > spp.website_pageview_id
    ) AS pageview_level
    GROUP BY
        website_session_id,
        CASE
            WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
            WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
            ELSE 'Check Logic'
        END;


    -- STEP 4: Compare the conversion funnels for both products.

    SELECT
        product_seen,
        COUNT(DISTINCT website_session_id) AS sessions,
        COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
        END) AS to_cart,
        COUNT(DISTINCT CASE
            WHEN shipping_made_it = 1 THEN website_session_id
        END) AS to_shipping,
        COUNT(DISTINCT CASE
            WHEN billing_made_it = 1 THEN website_session_id
        END) AS to_billing,
        COUNT(DISTINCT CASE
            WHEN thankyou_made_it = 1 THEN website_session_id
        END) AS to_thankyou
    FROM #session_product_level_made_it_flags
    GROUP BY
        product_seen
    ORDER BY
        product_seen;


/*
================================================================================================================
NOVEMBER 22, 2013
EMAIL FROM: CINDY SHARP (CEO)
SUBJECT: CROSS-SELLING PERFORMANCE
================================================================================================================

Good morning,

On September 25th we started giving customers the option to add a 2nd
product while on the /cart page. Morgan says this has been positive,
but I’d like your take on it.

Could you please compare the month before vs the month after the change?
I’d like to see CTR from the /cart page, Avg Products per Order, AOV,
and overall revenue per /cart page view.

Thanks,
Cindy

================================================================================================================
SQL ANALYSIS
================================================================================================================
*/



    /*
    STEP 1: Identify cart page sessions and classify them
    as pre-cross-sell and post-cross-sell.
    */

    DROP TABLE IF EXISTS #sessions_seeing_cart;

    SELECT
        CASE
            WHEN created_at < '2013-09-25' THEN 'A. Pre Cross Sell'
            ELSE 'B. Post Cross Sell'
        END AS time_period,
        website_session_id AS cart_session_id,
        website_pageview_id AS cart_pageview_id
    INTO #sessions_seeing_cart
    FROM website_pageviews
    WHERE created_at >= '2013-08-25'
        AND created_at < '2013-10-26'
        AND pageview_url = '/cart';


    /*
    STEP 2: Identify cart sessions where visitors
    viewed another page after the cart page.
    */

    DROP TABLE IF EXISTS #cart_sessions_seeing_another_page;

    SELECT
        sc.time_period,
        sc.cart_session_id,
        MIN(wp.website_pageview_id) AS pv_id_after_cart
    INTO #cart_sessions_seeing_another_page
    FROM #sessions_seeing_cart AS sc
    LEFT JOIN website_pageviews AS wp
        ON sc.cart_session_id = wp.website_session_id
        AND wp.website_pageview_id > sc.cart_pageview_id
    GROUP BY
        sc.time_period,
        sc.cart_session_id
    HAVING MIN(wp.website_pageview_id) IS NOT NULL;


    /*
    STEP 3: Retrieve orders associated with cart sessions.
    */

    DROP TABLE IF EXISTS #pre_post_sessions_orders;

    SELECT
        sc.time_period,
        sc.cart_session_id,
        o.order_id,
        o.items_purchased,
        o.price_usd
    INTO #pre_post_sessions_orders
    FROM #sessions_seeing_cart AS sc
    INNER JOIN orders AS o
        ON sc.cart_session_id = o.website_session_id;


    /*
    STEP 4: Combine cart activity, click-throughs,
    and order information at the session level.
    */

    DROP TABLE IF EXISTS #session_level_data;

    SELECT
        sc.time_period,
        sc.cart_session_id,
        CASE
            WHEN csp.cart_session_id IS NULL THEN 0
            ELSE 1
        END AS clicked_to_another_page,
        CASE
            WHEN pso.order_id IS NULL THEN 0
            ELSE 1
        END AS placed_order,
        pso.items_purchased,
        pso.price_usd
    INTO #session_level_data
    FROM #sessions_seeing_cart AS sc
    LEFT JOIN #cart_sessions_seeing_another_page AS csp
        ON sc.cart_session_id = csp.cart_session_id
    LEFT JOIN #pre_post_sessions_orders AS pso
        ON sc.cart_session_id = pso.cart_session_id;


    /*
    STEP 5: Compare cross-selling performance
    before and after the change.
    */

    SELECT
        time_period,
        COUNT(DISTINCT cart_session_id) AS cart_sessions,
        SUM(clicked_to_another_page) AS clickthroughs,

        CAST(SUM(clicked_to_another_page) AS FLOAT)
            / NULLIF(COUNT(DISTINCT cart_session_id), 0) AS cart_ctr,

        CAST(SUM(items_purchased) AS FLOAT)
            / NULLIF(SUM(placed_order), 0) AS products_per_order,

        CAST(SUM(price_usd) AS FLOAT)
            / NULLIF(SUM(placed_order), 0) AS aov,

        CAST(SUM(price_usd) AS FLOAT)
            / NULLIF(COUNT(DISTINCT cart_session_id), 0) AS revenue_per_cart_session

    FROM #session_level_data
    GROUP BY
        time_period
    ORDER BY
        time_period;


/*
================================================================================================================
JANUARY 12, 2014
EMAIL FROM: CINDY SHARP (CEO)
SUBJECT: RECENT PRODUCT LAUNCH
================================================================================================================

Good morning,

On December 12th 2013, we launched a third product targeting the
birthday gift market (Birthday Bear).

Could you please run a pre-post analysis comparing the month before
vs. the month after, in terms of session-to-order conversion rate,
AOV, products per order, and revenue per session?

Thank you!
-Cindy

================================================================================================================
SQL ANALYSIS
================================================================================================================
*/


    SELECT
        CASE
            WHEN ws.created_at < '2013-12-12' THEN 'A. Pre_Birthday_Bear'
            WHEN ws.created_at >= '2013-12-12' THEN 'B. Post_Birthday_Bear'
            ELSE 'uh oh...check logic'
        END AS time_period,
        COUNT(DISTINCT ws.website_session_id) AS sessions,
        COUNT(DISTINCT o.order_id) AS orders,
        CAST(COUNT(DISTINCT o.order_id) AS FLOAT)
            / NULLIF(COUNT(DISTINCT ws.website_session_id), 0) AS conv_rate,
        SUM(o.price_usd) AS total_revenue,
        SUM(o.items_purchased) AS total_products_sold,
        SUM(o.price_usd)
            / NULLIF(COUNT(DISTINCT o.order_id), 0) AS average_order_value,
        CAST(SUM(o.items_purchased) AS FLOAT)
            / NULLIF(COUNT(DISTINCT o.order_id), 0) AS products_per_order,
        SUM(o.price_usd)
            / NULLIF(COUNT(DISTINCT ws.website_session_id), 0) AS revenue_per_session
    FROM website_sessions ws
    LEFT JOIN orders o
        ON o.website_session_id = ws.website_session_id
    WHERE ws.created_at >= '2013-11-12'
        AND ws.created_at < '2014-01-13'
    GROUP BY
        CASE
            WHEN ws.created_at < '2013-12-12' THEN 'A. Pre_Birthday_Bear'
            WHEN ws.created_at >= '2013-12-12' THEN 'B. Post_Birthday_Bear'
            ELSE 'uh oh...check logic'
        END;


/*
================================================================================================================
OCTOBER 15, 2014
EMAIL FROM: CINDY SHARP (CEO)
SUBJECT: QUALITY ISSUES & REFUNDS
================================================================================================================

Good morning,

Our Mr. Fuzzy supplier had some quality issues which weren't corrected
until September 2013. Then they had a major problem where the bears'
arms were falling off in Aug/Sep 2014. As a result, we replaced them
with a new supplier on September 16, 2014.

Can you please pull monthly product refund rates, by product, and
confirm our quality issues are now fixed?

-Cindy

================================================================================================================
SQL ANALYSIS
================================================================================================================
*/


    SELECT
        YEAR(oi.created_at) AS yr,
        MONTH(oi.created_at) AS mo,

        COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN oi.order_item_id END) AS p1_orders,
        COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN r.order_item_id END) AS p1_refund,
        CAST(COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN r.order_item_id END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN oi.order_item_id END), 0) AS p1_refund_rt,

        COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN oi.order_item_id END) AS p2_orders,
        COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN r.order_item_id END) AS p2_refund,
        CAST(COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN r.order_item_id END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN oi.order_item_id END), 0) AS p2_refund_rt,

        COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN oi.order_item_id END) AS p3_orders,
        COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN r.order_item_id END) AS p3_refund,
        CAST(COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN r.order_item_id END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN oi.order_item_id END), 0) AS p3_refund_rt,

        COUNT(DISTINCT CASE WHEN oi.product_id = 4 THEN oi.order_item_id END) AS p4_orders,
        COUNT(DISTINCT CASE WHEN oi.product_id = 4 THEN r.order_item_id END) AS p4_refund,
        CAST(COUNT(DISTINCT CASE WHEN oi.product_id = 4 THEN r.order_item_id END) AS FLOAT)
            / NULLIF(COUNT(DISTINCT CASE WHEN oi.product_id = 4 THEN oi.order_item_id END), 0) AS p4_refund_rt

    FROM order_items oi
    LEFT JOIN order_item_refunds r
        ON oi.order_item_id = r.order_item_id
    WHERE oi.created_at < '2014-10-15'
    GROUP BY
        YEAR(oi.created_at),
        MONTH(oi.created_at)
    ORDER BY
        yr,
        mo;