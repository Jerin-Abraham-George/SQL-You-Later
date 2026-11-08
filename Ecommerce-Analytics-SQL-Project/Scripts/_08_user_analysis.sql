/*
================================================================================================================
PROJECT: MAVEN FUZZY FACTORY
SECTION: USER ANALYSIS
================================================================================================================

USER ANALYSIS

User Analysis focuses on understanding visitor behavior, engagement, and
returning customer activity. It helps the business understand how users
interact with the website over time and identify opportunities to improve
customer retention and long-term value.

COMMON USE CASES:
    -- Measuring the number of new and returning website visitors.
    -- Analyzing repeat visit patterns and user engagement.
    -- Understanding how frequently visitors return to the website.
    -- Evaluating customer retention and repeat purchase behavior.
    -- Identifying opportunities to improve customer loyalty and lifetime value.

KEY TABLES:
    -- website_sessions
    -- orders

================================================================================================================
*/


/*
================================================================================================================
NOVEMBER 01, 2014
EMAIL FROM: TOM PARMESAN (MARKETING DIRECTOR)
SUBJECT: REPEAT VISITORS
================================================================================================================

Hey there,

We've been thinking about customer value based solely on their first
session conversion and revenue. But if customers have repeat sessions,
they may be more valuable than we thought. If that's the case, we
might be able to spend a bit more to acquire them.

Could you please pull data on how many of our website visitors come
back for another session? 2014 to date is good.

Thanks, Tom

================================================================================================================
SQL ANALYSIS
================================================================================================================
*/


-- STEP 1: Identify new sessions and their corresponding repeat sessions
SELECT
    new_sessions.user_id,
    new_sessions.website_session_id AS new_session_id,
    repeat_sessions.website_session_id AS repeat_session_id
INTO #sessions_w_repeats
FROM
(
    SELECT
        user_id,
        website_session_id
    FROM website_sessions
    WHERE created_at < '2014-11-01'
        AND created_at >= '2014-01-01'
        AND is_repeat_session = 0
) AS new_sessions
LEFT JOIN website_sessions AS repeat_sessions
    ON repeat_sessions.user_id = new_sessions.user_id
    AND repeat_sessions.is_repeat_session = 1
    AND repeat_sessions.website_session_id > new_sessions.website_session_id
    AND repeat_sessions.created_at < '2014-11-01'
    AND repeat_sessions.created_at >= '2014-01-01';

-- STEP 2: Count users by the number of repeat sessions
SELECT
    repeat_sessions,
    COUNT(DISTINCT user_id) AS users
FROM
(
    SELECT
        user_id,
        COUNT(DISTINCT new_session_id) AS new_sessions,
        COUNT(DISTINCT repeat_session_id) AS repeat_sessions
    FROM #sessions_w_repeats
    GROUP BY user_id
) AS user_level
GROUP BY repeat_sessions
ORDER BY repeat_sessions DESC;

DROP TABLE #sessions_w_repeats;


/*
================================================================================================================
NOVEMBER 03, 2014
EMAIL FROM: TOM PARMESAN (MARKETING DIRECTOR)
SUBJECT: DEEPER DIVE ON REPEAT
================================================================================================================

Ok, so the repeat session data was really interesting to see.

Now you've got me curious to better understand the behavior of these
repeat customers.

Could you help me understand the minimum, maximum, and average time
between the first and second session for customers who do come back?
Again, analyzing 2014 to date is probably the right time period.

Thanks, Tom

================================================================================================================
SQL ANALYSIS
================================================================================================================
*/


    -- STEP 1: Identify new sessions and their corresponding repeat sessions
    SELECT
        new_sessions.user_id,
        new_sessions.website_session_id AS new_session_id,
        new_sessions.created_at AS new_session_created_at,
        repeat_sessions.website_session_id AS repeat_session_id,
        repeat_sessions.created_at AS repeat_session_created_at
    INTO #sessions_w_repeats_for_time_diff
    FROM
    (
        SELECT
            user_id,
            website_session_id,
            created_at
        FROM website_sessions
        WHERE created_at < '2014-11-03'
            AND created_at >= '2014-01-01'
            AND is_repeat_session = 0
    ) AS new_sessions
    LEFT JOIN website_sessions AS repeat_sessions
        ON repeat_sessions.user_id = new_sessions.user_id
        AND repeat_sessions.is_repeat_session = 1
        AND repeat_sessions.website_session_id > new_sessions.website_session_id
        AND repeat_sessions.created_at < '2014-11-03'
        AND repeat_sessions.created_at >= '2014-01-01';

    -- STEP 2: Identify the first repeat session for each new session
    SELECT
        user_id,
        new_session_id,
        new_session_created_at,
        MIN(repeat_session_id) AS second_session_id,
        MIN(repeat_session_created_at) AS second_session_created_at
    INTO #users_first_to_second
    FROM #sessions_w_repeats_for_time_diff
    WHERE repeat_session_id IS NOT NULL
    GROUP BY
        user_id,
        new_session_id,
        new_session_created_at;

    -- STEP 3: Calculate the number of days between the first and second sessions
    SELECT
        user_id,
        DATEDIFF(DAY, new_session_created_at, second_session_created_at)
            AS days_first_to_second_session
    INTO #users_first_to_second_days
    FROM #users_first_to_second;

    -- STEP 4: Calculate the average, minimum, and maximum time between sessions
    SELECT
        AVG(CAST(days_first_to_second_session AS DECIMAL(10,2))) AS avg_days_first_to_second,
        MIN(days_first_to_second_session) AS min_days_first_to_second,
        MAX(days_first_to_second_session) AS max_days_first_to_second
    FROM #users_first_to_second_days;

    -- STEP 5: Clean up temporary tables
    DROP TABLE #users_first_to_second_days;
    DROP TABLE #users_first_to_second;
    DROP TABLE #sessions_w_repeats_for_time_diff;


/*
================================================================================================================
NOVEMBER 05, 2014
EMAIL FROM: TOM PARMESAN (MARKETING DIRECTOR)
SUBJECT: REPEAT CHANNEL MIX
================================================================================================================

Hi there,

Let's do a bit more digging into our repeat customers.

Can you help me understand the channels they come back through?
Curious if it's all direct type-in, or if we're paying for these
customers with paid search ads multiple times.

Comparing new vs. repeat sessions by channel would be really valuable,
if you're able to pull it! 2014 to date is great.

Thanks, Tom

================================================================================================================
SQL ANALYSIS
================================================================================================================
*/


    SELECT
        CASE
            WHEN utm_source IS NULL
                AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com')
                THEN 'organic_search'
            WHEN utm_campaign = 'nonbrand'
                THEN 'paid_nonbrand'
            WHEN utm_campaign = 'brand'
                THEN 'paid_brand'
            WHEN utm_source IS NULL
                AND http_referer IS NULL
                THEN 'direct_type_in'
            WHEN utm_source = 'socialbook'
                THEN 'paid_social'
        END AS channel_group,
        COUNT(DISTINCT CASE
            WHEN is_repeat_session = 0 THEN website_session_id
        END) AS new_sessions,
        COUNT(DISTINCT CASE
            WHEN is_repeat_session = 1 THEN website_session_id
        END) AS repeat_sessions
    FROM website_sessions
    WHERE created_at < '2014-11-05'
        AND created_at >= '2014-01-01'
    GROUP BY
        CASE
            WHEN utm_source IS NULL
                AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com')
                THEN 'organic_search'
            WHEN utm_campaign = 'nonbrand'
                THEN 'paid_nonbrand'
            WHEN utm_campaign = 'brand'
                THEN 'paid_brand'
            WHEN utm_source IS NULL
                AND http_referer IS NULL
                THEN 'direct_type_in'
            WHEN utm_source = 'socialbook'
                THEN 'paid_social'
        END
    ORDER BY repeat_sessions DESC;


/*
================================================================================================================
NOVEMBER 08, 2014
EMAIL FROM: MORGAN ROCKWELL (WEBSITE MANAGER)
SUBJECT: TOP WEBSITE PAGES
================================================================================================================

Hi there!

Sounds like you and Tom have learned a lot about our repeat
customers. Can I trouble you for one more thing?

I'd love to do a comparison of conversion rates and revenue per
session for repeat sessions vs new sessions.

Let's continue using data from 2014, year to date.

Thank you!
-Morgan

================================================================================================================
SQL ANALYSIS
================================================================================================================
*/


    SELECT
        ws.is_repeat_session,
        COUNT(DISTINCT ws.website_session_id) AS sessions,
        CAST(COUNT(DISTINCT o.order_id) AS FLOAT)
            / NULLIF(COUNT(DISTINCT ws.website_session_id), 0) AS conversion_rate,
        SUM(o.price_usd)
            / NULLIF(COUNT(DISTINCT ws.website_session_id), 0) AS revenue_per_session
    FROM website_sessions AS ws
    LEFT JOIN orders AS o
        ON ws.website_session_id = o.website_session_id
    WHERE ws.created_at < '2014-11-08'
        AND ws.created_at >= '2014-01-01'
    GROUP BY
        ws.is_repeat_session;