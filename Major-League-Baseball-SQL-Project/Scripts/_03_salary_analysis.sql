/* Question 2:

a) Return the top 20% of teams in terms of average annual spending.

b) For each team, show the cumulative sum of spending over the years.

c) Return the first year that each team's cumulative spending surpassed 1 billion.

*/


-- Solution a.
		
		WITH ts AS (
			SELECT
				teamid,
				yearid,
			SUM(CAST(Salary AS BIGINT)) AS total_spend
			FROM mlb.salaries
			GROUP BY teamID, yearID
			),

		sp AS (
			SELECT
				teamID,
				AVG(total_spend) AS avg_spend,
				NTILE(5) OVER (ORDER BY AVG(total_spend) DESC) AS spend_pct
			FROM ts
			GROUP BY teamID)

		SELECT 
			teamID,
			ROUND(avg_spend / 1000000, 1) AS AvgSpending
		FROM sp
		WHERE spend_pct = 1


-- Solution b.
		
		WITH ts AS (
			SELECT
				yearID,
				teamID,
				SUM(CAST(salary AS BIGINT)) AS total_spend
			FROM mlb.salaries
			GROUP BY teamID, yearID
			--ORDER BY teamID, yearID
			)

		SELECT
			yearID,
			teamID,
			total_spend,
		SUM(total_spend/1000000) OVER (PARTITION BY teamID ORDER BY yearID ASC
									   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_spend_in_millions
		FROM ts
		ORDER BY teamID, yearID
		

-- Solution c.

		WITH ts AS (
			SELECT
				yearID,
				teamID,
				SUM(CAST(salary AS BIGINT)) AS total_spend
			FROM mlb.salaries
			GROUP BY teamID, yearID
			--ORDER BY teamID, yearID
			),

		cs AS (
			SELECT
				yearID,
				teamID,
				total_spend,
			SUM(total_spend) OVER (PARTITION BY teamID ORDER BY yearID ASC
										   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_spend_in_millions
			FROM ts
			--ORDER BY teamID, yearID
			),

		rn AS (
			SELECT
				teamID,
				yearID,
				cumulative_spend_in_millions,
			ROW_NUMBER() OVER( PARTITION BY teamID ORDER BY cumulative_spend_in_millions ASC) AS rn
			FROM cs
			WHERE cumulative_spend_in_millions > 1000000000
		)

		SELECT 
			teamID,
			yearID,
			ROUND(cumulative_spend_in_millions/1000000000.0, 2) AS cumulative_spend_in_billions
		FROM rn
		WHERE rn = 1


