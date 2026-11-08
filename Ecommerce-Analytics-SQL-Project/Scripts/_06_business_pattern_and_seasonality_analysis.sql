/*
================================================================================================================
PROJECT: MAVEN FUZZY FACTORY
SECTION: BUSINESS PATTERN AND SEASONALITY ANALYSIS
================================================================================================================

BUSINESS PATTERN AND SEASONALITY ANALYSIS

This analysis focuses on identifying recurring patterns and trends in
website traffic and order volume over time. It helps the business understand
how customer activity changes across different periods and identify
potential seasonal trends.

COMMON USE CASES
    -- Analyzing monthly and weekly website session trends.
    -- Tracking changes in order volume over time.
    -- Identifying seasonal peaks and declines in business activity.
    -- Understanding recurring patterns in customer demand.
    -- Supporting sales forecasting and business planning.

KEY TABLES
    -- website_sessions
    -- orders

================================================================================================================
*/

USE Ecommerce_DB;
GO


/*
================================================================================================================
JANUARY 02, 2013
EMAIL FROM: CINDY SHARP (CEO)
SUBJECT: UNDERSTANDING SEASONALITY
================================================================================================================

Good morning,

2012 was a great year for us. As we continue to grow, we should take a look
at 2012's monthly and weekly volume patterns, to see if we can find any
seasonal trends we should plan for in 2013.

If you can pull session volume and order volume, that would be excellent.

Thanks,
Cindy

================================================================================================================
SQL ANALYSIS 01: MONTHLY SESSIONS AND ORDER VOLUME
================================================================================================================
*/


    SELECT
        YEAR(ws.created_at) AS yr,
        MONTH(ws.created_at) AS mo,
        COUNT(DISTINCT ws.website_session_id) AS sessions,
        COUNT(DISTINCT o.order_id) AS orders
    FROM website_sessions AS ws
    LEFT JOIN orders AS o
        ON ws.website_session_id = o.website_session_id
    WHERE ws.created_at < '2013-01-01'
    GROUP BY
        YEAR(ws.created_at),
        MONTH(ws.created_at)
    ORDER BY
        yr,
        mo;


/*
================================================================================================================
JANUARY 05, 2013
EMAIL FROM: CINDY SHARP (CEO)
SUBJECT: DATA FOR CUSTOMER SERVICE
================================================================================================================

Good morning,

We're considering adding live chat support to the website to improve our
customer experience. Could you analyze the average website session volume,
by hour of day and by day of week, so that we can staff appropriately?

Let's avoid the holiday time period and use a date range of
September 15 - November 15, 2012.

Thanks,
Cindy

================================================================================================================
SQL ANALYSIS 02: AVERAGE WEBSITE SESSIONS BY HOUR AND DAY OF WEEK
================================================================================================================
*/


    SELECT
        hr,
        ROUND(AVG(CASE WHEN wkday = 0 THEN CAST(website_sessions AS FLOAT) END), 1) AS mon,
        ROUND(AVG(CASE WHEN wkday = 1 THEN CAST(website_sessions AS FLOAT) END), 1) AS tue,
        ROUND(AVG(CASE WHEN wkday = 2 THEN CAST(website_sessions AS FLOAT) END), 1) AS wed,
        ROUND(AVG(CASE WHEN wkday = 3 THEN CAST(website_sessions AS FLOAT) END), 1) AS thu,
        ROUND(AVG(CASE WHEN wkday = 4 THEN CAST(website_sessions AS FLOAT) END), 1) AS fri,
        ROUND(AVG(CASE WHEN wkday = 5 THEN CAST(website_sessions AS FLOAT) END), 1) AS sat,
        ROUND(AVG(CASE WHEN wkday = 6 THEN CAST(website_sessions AS FLOAT) END), 1) AS sun
    FROM
    (
        SELECT
            CAST(created_at AS DATE) AS created_date,
            DATEPART(WEEKDAY, created_at) - 1 AS wkday,
            DATEPART(HOUR, created_at) AS hr,
            COUNT(DISTINCT website_session_id) AS website_sessions
        FROM website_sessions
        WHERE created_at >= '2012-09-15'
            AND created_at < '2012-11-16'
        GROUP BY
            CAST(created_at AS DATE),
            DATEPART(WEEKDAY, created_at),
            DATEPART(HOUR, created_at)
    ) AS daily_hourly_sessions
    GROUP BY hr
    ORDER BY hr;