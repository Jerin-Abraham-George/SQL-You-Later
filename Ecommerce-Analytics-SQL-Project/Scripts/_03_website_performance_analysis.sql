/*
================================================================================================================
PROJECT: MAVEN FUZZY FACTORY
SECTION: ANALYZING WEBSITE PERFORMANCE
================================================================================================================

WEBSITE PERFORMANCE ANALYSIS:

Website Performance Analysis focuses on understanding how visitors interact
with the website, identifying popular pages, and evaluating the overall
website experience.

COMMON USE CASES:
    -- Identifying the most frequently visited website pages.
    -- Understanding visitor navigation and browsing behavior.
    -- Identifying opportunities to improve website engagement and conversion.
    -- Evaluating website pages to identify potential performance bottlenecks.

KEY TABLES:
    -- website_pageviews
    -- website_sessions
    -- orders

================================================================================================================
*/


/*
================================================================================================================
JUNE 09, 2012
EMAIL FROM: MORGAN ROCKWELL (WEBSITE MANAGER)
SUBJECT: TOP WEBSITE PAGES
================================================================================================================

Hi there!

I'm Morgan, the new Website Manager.

Could you help me get my head around the site by pulling
the most-viewed website pages, ranked by session volume?

Thanks!
-Morgan


================================================================================================================
SQL ANALYSIS 01: IDENTIFYING THE MOST-VIEWED WEBSITE PAGES
================================================================================================================
*/


    SELECT
        pageview_url,
        COUNT(DISTINCT website_pageview_id) AS page_views
    FROM website_pageviews
    WHERE created_at < '2012-06-09'
    GROUP BY pageview_url
    ORDER BY page_views DESC;


/*
================================================================================================================
JUNE 12, 2012
EMAIL FROM: MORGAN ROCKWELL (WEBSITE MANAGER)
SUBJECT: TOP ENTRY PAGES
================================================================================================================

Hi there!

Would you be able to pull a list of the top entry pages? I
want to confirm where our users are hitting the site.

If you could pull all entry pages and rank them on entry
volume, that would be great.

Thanks!
-Morgan


================================================================================================================
SQL ANALYSIS 02: IDENTIFYING TOP WEBSITE ENTRY PAGES
================================================================================================================
*/


-- STEP 1: Identify the first pageview for each website session

    SELECT
        website_session_id,
        MIN(website_pageview_id) AS first_pageview_id
    INTO #first_pv_per_session
    FROM website_pageviews
    WHERE created_at < '2012-06-12'
    GROUP BY website_session_id;


-- STEP 2: Identify and rank landing pages by entry volume

    SELECT
        pv.pageview_url AS landing_page_url,
        COUNT(DISTINCT fp.website_session_id) AS sessions_hitting_page
    FROM #first_pv_per_session fp
    LEFT JOIN website_pageviews pv
        ON fp.first_pageview_id = pv.website_pageview_id
    GROUP BY pv.pageview_url
    ORDER BY sessions_hitting_page DESC;



    SELECT
        website_session_id,
        MIN(website_pageview_id) AS first_pageview_id
    INTO #first_pv_per_session
    FROM website_pageviews
    WHERE created_at < '2012-06-14'
    GROUP BY website_session_id;


/*
================================================================================================================
JUNE 14, 2012
EMAIL FROM: MORGAN ROCKWELL (WEBSITE MANAGER)
SUBJECT: BOUNCE RATE ANALYSIS
================================================================================================================

Hi there!

The other day you showed us that all of our traffic is landing
on the homepage right now. We should check how that landing
page is performing.

Can you pull bounce rates for traffic landing on the
homepage? I would like to see three numbers... Sessions,
Bounced Sessions, and % of Sessions which Bounced
(aka "Bounce Rate").

Thanks!
-Morgan


================================================================================================================
SQL ANALYSIS 03: HOMEPAGE BOUNCE RATE ANALYSIS
================================================================================================================
*/


    -- STEP 1: Identify sessions landing on the homepage

    SELECT
        pps.website_session_id,
        w.pageview_url AS landing_page
    INTO #sessions_w_home_landing_page
    FROM #first_pv_per_session pps
    LEFT JOIN website_pageviews w
        ON pps.first_pageview_id = w.website_pageview_id
    WHERE w.pageview_url = '/home';


    -- STEP 2: Identify sessions that viewed only one page

    SELECT
        s.website_session_id,
        s.landing_page,
        COUNT(wp.website_pageview_id) AS count_of_pages_viewed
    INTO #bounced_sessions
    FROM #sessions_w_home_landing_page s
    LEFT JOIN website_pageviews wp
        ON s.website_session_id = wp.website_session_id
    GROUP BY
        s.website_session_id,
        s.landing_page
    HAVING COUNT(wp.website_pageview_id) = 1;


    -- STEP 3: Calculate homepage sessions, bounced sessions and bounce rate

    SELECT
        COUNT(DISTINCT s.website_session_id) AS total_sessions,
        COUNT(DISTINCT b.website_session_id) AS bounced_sessions,
        FORMAT(
            CAST(COUNT(DISTINCT b.website_session_id) AS FLOAT) /
            CAST(COUNT(DISTINCT s.website_session_id) AS FLOAT),
            'P2'
        ) AS bounce_rate
    FROM #sessions_w_home_landing_page s
    LEFT JOIN #bounced_sessions b
        ON s.website_session_id = b.website_session_id;


--

/*
================================================================================================================
JULY 28, 2012
EMAIL FROM: MORGAN ROCKWELL (WEBSITE MANAGER)
SUBJECT: HELP ANALYZING LP TEST
================================================================================================================

Hi there!

Based on your bounce rate analysis, we ran a new custom
landing page (/lander-1) in a 50/50 test against the
homepage (/home) for our gsearch nonbrand traffic.

Can you pull bounce rates for the two groups so we can
evaluate the new page? Make sure to just look at the time
period where /lander-1 was getting traffic, so that it is
a fair comparison.

Thanks,
Morgan


================================================================================================================
SQL ANALYSIS 04: LANDING PAGE A/B TEST - BOUNCE RATE COMPARISON
================================================================================================================
*/


    -- STEP 1: Identify when the new landing page was first introduced

    SELECT
        MIN(created_at) AS first_created_at,
        MIN(website_pageview_id) AS first_pageview_id
    FROM website_pageviews
    WHERE pageview_url = '/lander-1'
        AND created_at IS NOT NULL;


    -- STEP 2: Identify Google Search non-brand sessions after the test began

    SELECT
        wp.website_session_id,
        MIN(wp.website_pageview_id) AS min_pageview_id
    INTO #first_test_pageviews
    FROM website_pageviews wp
    INNER JOIN website_sessions ws
        ON wp.website_session_id = ws.website_session_id
        AND ws.created_at < '2012-07-28'
        AND wp.website_pageview_id > 23504
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
    GROUP BY
        wp.website_session_id;


    -- STEP 3: Identify the landing page for each session

    SELECT
        ft.website_session_id,
        wp.pageview_url AS landing_page
    INTO #nonbrand_test_sessions_w_landing_page
    FROM #first_test_pageviews ft
    LEFT JOIN website_pageviews wp
        ON ft.min_pageview_id = wp.website_pageview_id
    WHERE wp.pageview_url IN ('/home', '/lander-1');


    -- STEP 4: Identify sessions that bounced

    SELECT
        nt.website_session_id,
        nt.landing_page,
        COUNT(wp.website_pageview_id) AS count_of_pages_viewed
    INTO #nonbrand_test_bounced_sessions
    FROM #nonbrand_test_sessions_w_landing_page nt
    LEFT JOIN website_pageviews wp
        ON wp.website_session_id = nt.website_session_id
    GROUP BY
        nt.website_session_id,
        nt.landing_page
    HAVING COUNT(wp.website_pageview_id) = 1;


    -- STEP 5: Compare bounce rates between the two landing pages

    SELECT
        lp.landing_page,
        COUNT(DISTINCT lp.website_session_id) AS sessions,
        COUNT(DISTINCT bs.website_session_id) AS bounce_sessions,
        FORMAT(
            CAST(COUNT(DISTINCT bs.website_session_id) AS FLOAT) /
            CAST(COUNT(DISTINCT lp.website_session_id) AS FLOAT),
            'P2'
        ) AS bounce_rate
    FROM #nonbrand_test_sessions_w_landing_page lp
    LEFT JOIN #nonbrand_test_bounced_sessions bs
        ON lp.website_session_id = bs.website_session_id
    GROUP BY lp.landing_page;


/*
================================================================================================================
AUGUST 31, 2012
EMAIL FROM: MORGAN ROCKWELL (WEBSITE MANAGER)
SUBJECT: LANDING PAGE TREND ANALYSIS
================================================================================================================

Hi there,

Could you pull the volume of paid search nonbrand traffic
landing on /home and /lander-1, trended weekly since June 1st?
I want to confirm the traffic is all routed correctly.

Could you also pull our overall paid search bounce rate
trended weekly? I want to make sure the lander change has
improved the overall picture.

Thanks!


================================================================================================================
SQL ANALYSIS 05: WEEKLY LANDING PAGE TRAFFIC AND BOUNCE RATE TRENDS
================================================================================================================
*/


    -- STEP 1: Calculate pageviews for each website session

    SELECT
        ws.website_session_id,
        MIN(wp.website_pageview_id) AS first_pageview_id,
        COUNT(wp.website_pageview_id) AS count_pageviews
    INTO #sessions_w_min_pv_id_and_view_count
    FROM website_sessions ws
    LEFT JOIN website_pageviews wp
        ON ws.website_session_id = wp.website_session_id
    WHERE ws.created_at >= '2012-06-01'
        AND ws.created_at < '2012-08-31'
        AND ws.utm_source = 'gsearch'
        AND ws.utm_campaign = 'nonbrand'
    GROUP BY ws.website_session_id;


    -- STEP 2: Identify each session's landing page and creation date

    SELECT
        s.website_session_id,
        s.first_pageview_id,
        s.count_pageviews,
        wp.pageview_url AS landing_page,
        wp.created_at AS session_created_at
    INTO #sessions_w_counts_lander_and_created_at
    FROM #sessions_w_min_pv_id_and_view_count s
    LEFT JOIN website_pageviews wp
        ON s.first_pageview_id = wp.website_pageview_id;


    -- STEP 3: Analyze weekly landing page traffic and bounce rates

    SELECT
        DATEPART(WEEK, session_created_at) AS year_week,
        MIN(session_created_at) AS week_start_date,
        COUNT(DISTINCT website_session_id) AS total_sessions,
        COUNT(DISTINCT CASE
            WHEN count_pageviews = 1 THEN website_session_id
        END) AS bounced_sessions,
        CAST(
            COUNT(DISTINCT CASE
                WHEN count_pageviews = 1 THEN website_session_id
            END) AS FLOAT
        ) / NULLIF(COUNT(DISTINCT website_session_id), 0) AS bounce_rate,
        COUNT(DISTINCT CASE
            WHEN landing_page = '/home' THEN website_session_id
        END) AS home_sessions,
        COUNT(DISTINCT CASE
            WHEN landing_page = '/lander-1' THEN website_session_id
        END) AS lander_sessions
    FROM #sessions_w_counts_lander_and_created_at
    GROUP BY DATEPART(WEEK, session_created_at)
    ORDER BY DATEPART(WEEK, session_created_at);



/*
================================================================================================================
NOVEMBER 10, 2012
EMAIL FROM: MORGAN ROCKWELL (WEBSITE MANAGER)
SUBJECT: HELP ANALYZING CONVERSION FUNNELS
================================================================================================================

Hi there!

I'd like to understand where we lose our gsearch visitors
between the new /lander-1 page and placing an order.

Can you build us a full conversion funnel, analyzing how
many customers make it to each step?

Start with /lander-1 and build the funnel all the way to
our thank you page. Please use data since August 5th.

Thanks!
-Morgan


================================================================================================================
SQL ANALYSIS 06: CONVERSION FUNNEL ANALYSIS
================================================================================================================
*/


    -- STEP 1: Identify Google Search non-brand sessions
    -- that entered the website through /lander-1

    WITH ranked_pageviews AS
    (
        SELECT
            ws.website_session_id,
            wp.pageview_url,
            ROW_NUMBER() OVER (
                PARTITION BY ws.website_session_id
                ORDER BY wp.website_pageview_id
            ) AS pageview_rank
        FROM website_sessions ws
        INNER JOIN website_pageviews wp
            ON ws.website_session_id = wp.website_session_id
        WHERE ws.utm_source = 'gsearch'
            AND ws.utm_campaign = 'nonbrand'
            AND ws.created_at >= '2012-08-05'
            AND ws.created_at < '2012-09-05'
    )

    SELECT
        website_session_id
    INTO #lander_sessions
    FROM ranked_pageviews
    WHERE pageview_rank = 1
        AND pageview_url = '/lander-1';


    -- STEP 2: Identify which funnel pages each session visited

    SELECT
        ls.website_session_id,
        MAX(CASE
            WHEN wp.pageview_url = '/products' THEN 1 ELSE 0
        END) AS products_made_it,

        MAX(CASE
            WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0
        END) AS mrfuzzy_made_it,

        MAX(CASE
            WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0
        END) AS cart_made_it,

        MAX(CASE
            WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0
        END) AS shipping_made_it,

        MAX(CASE
            WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0
        END) AS billing_made_it,

        MAX(CASE
            WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0
        END) AS thankyou_made_it

    INTO #session_level_made_it_flags
    FROM #lander_sessions ls
    LEFT JOIN website_pageviews wp
        ON ls.website_session_id = wp.website_session_id
    GROUP BY ls.website_session_id;


    -- STEP 3: Calculate the number of sessions reaching each funnel stage

    SELECT
        COUNT(DISTINCT website_session_id) AS sessions,

        COUNT(DISTINCT CASE
            WHEN products_made_it = 1 THEN website_session_id
        END) AS to_products,

        COUNT(DISTINCT CASE
            WHEN mrfuzzy_made_it = 1 THEN website_session_id
        END) AS to_mrfuzzy,

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

    FROM #session_level_made_it_flags;


    -- STEP 4: Calculate conversion rates between funnel stages

    SELECT
        FORMAT(
            CAST(COUNT(DISTINCT CASE WHEN products_made_it = 1
                THEN website_session_id END) AS FLOAT) /
            NULLIF(COUNT(DISTINCT website_session_id), 0),
            'P2'
        ) AS lander_click_rate,

        FORMAT(
            CAST(COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1
                THEN website_session_id END) AS FLOAT) /
            NULLIF(COUNT(DISTINCT CASE WHEN products_made_it = 1
                THEN website_session_id END), 0),
            'P2'
        ) AS products_click_rate,

        FORMAT(
            CAST(COUNT(DISTINCT CASE WHEN cart_made_it = 1
                THEN website_session_id END) AS FLOAT) /
            NULLIF(COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1
                THEN website_session_id END), 0),
            'P2'
        ) AS mrfuzzy_click_rate,

        FORMAT(
            CAST(COUNT(DISTINCT CASE WHEN shipping_made_it = 1
                THEN website_session_id END) AS FLOAT) /
            NULLIF(COUNT(DISTINCT CASE WHEN cart_made_it = 1
                THEN website_session_id END), 0),
            'P2'
        ) AS cart_click_rate,

        FORMAT(
            CAST(COUNT(DISTINCT CASE WHEN billing_made_it = 1
                THEN website_session_id END) AS FLOAT) /
            NULLIF(COUNT(DISTINCT CASE WHEN shipping_made_it = 1
                THEN website_session_id END), 0),
            'P2'
        ) AS shipping_click_rate,

        FORMAT(
            CAST(COUNT(DISTINCT CASE WHEN thankyou_made_it = 1
                THEN website_session_id END) AS FLOAT) /
            NULLIF(COUNT(DISTINCT CASE WHEN billing_made_it = 1
                THEN website_session_id END), 0),
            'P2'
        ) AS billing_click_rate

    FROM #session_level_made_it_flags;

