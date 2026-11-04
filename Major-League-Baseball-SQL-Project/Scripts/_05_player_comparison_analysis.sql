/*
MLB Player Demographics Analysis:
----------------------------------------------------------------------------------------------------------------------------------------------------
This analysis explores various player characteristics and demographics in Major League Baseball (MLB), focusing on identifying players 
who share the same birthday and examining batting preferences across different teams.

It also investigates how the average height and weight of players at their debut changed over the decades, highlighting the differences 
in physical attributes across generations of MLB players.
----------------------------------------------------------------------------------------------------------------------------------------------------
*/

/*================================================================================================================================================*/

/* Question 1:

a) Which players have the same birthday?

b) Create a summary table that shows for each team, what percent of players bat right, left and both.

c) How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?

*/


-- Solution a: Identify players who share the same birthday

		WITH bn AS (
			SELECT 
			nameGiven,
			TRY_CAST(CONCAT(birthYear, '-', birthMonth, '-', birthDay) AS DATE) AS birthdate
		FROM mlb.players
		)

		SELECT 
			birthdate,
			STRING_AGG(nameGiven, ', ') AS player_name
		FROM bn
		WHERE birthdate IS NOT NULL AND YEAR(birthdate) BETWEEN 1980 AND 1990
		GROUP BY birthdate
		ORDER BY birthdate;


-- Solution b: Percentage breakdown of right-handed, left-handed, and switch hitters for each team

		SELECT
			s.teamID,
			COUNT(s.playerID) AS num_players,
			ROUND(CAST(SUM(CASE WHEN p.bats = 'R' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(s.playerID), 3) * 100 AS bats_right,
			ROUND(CAST(SUM(CASE WHEN p.bats = 'L' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(s.playerID), 3) * 100 AS bats_left,
			ROUND(CAST(SUM(CASE WHEN p.bats = 'B' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(s.playerID), 3) * 100 AS bats_both
		FROM mlb.salaries s
		LEFT JOIN mlb.players p
			ON s.playerID = p.playerID
		GROUP BY s.teamID;


-- Solution c: Decade-over-decade changes in average player height and weight at debut

		WITH hw AS (
		SELECT
			ROUND(YEAR(debut), -1) AS decade,
			AVG(height) AS avg_height,
			AVG(weight) AS avg_weight
		FROM mlb.players
		GROUP BY ROUND(YEAR(debut), -1)
		)

		SELECT 
		decade,
		avg_height,
		avg_weight,
		ROUND(CAST(avg_height - LAG(avg_height) OVER (ORDER BY decade) AS FLOAT), 2) AS height_diff,
		ROUND(CAST(avg_weight - LAG(avg_weight) OVER (ORDER BY decade) AS FLOAT), 2) AS weight_diff
		FROM hw
		WHERE decade IS NOT NULL
