/*
MLB Schools Analysis:
----------------------------------------------------------------------------------------------------------------------------------------------------
This analysis explores the contribution of educational institutions to Major League Baseball (MLB), focusing on the number of schools 
that have produced MLB players across different decades.

It also identifies the top 5 schools that have produced the most players overall and highlights the top 3 player-producing schools 
within each decade.
----------------------------------------------------------------------------------------------------------------------------------------------------
*/

/*================================================================================================================================================*/

/* Question 1:

a) In each decade, how many schools were there that produced MLB players?

b) What are the names of the top 5 schools that produced the most players?

c) For each decade, what were the names of the top 3 schools that produced the most players?

*/


-- Solution a: Number of schools producing MLB players in each decade
		
		SELECT 
			ROUND(yearID, -1) AS decade,
			COUNT(DISTINCT schoolID) AS num_schools
		FROM mlb.schools
		GROUP BY ROUND(yearID, -1)
		ORDER BY ROUND(yearID, -1)


-- Solution b: Top 5 schools that have produced the most MLB players overall

		SELECT TOP 5
			s.schoolID,
			sd.name_full,
		COUNT(DISTINCT s.playerID) AS total_players
		FROM mlb.schools s
		LEFT JOIN mlb.school_details sd
		ON s.schoolID = sd.schoolID
		GROUP BY s.schoolID, sd.name_full
		ORDER BY COUNT(DISTINCT s.playerID) DESC


-- Solution c: Top 3 player-producing schools for each decade

		WITH decades_schools AS (
		SELECT 
			ROUND(s.yearID,-1) AS decade,
			sd.name_full,
			COUNT(DISTINCT s.playerID) AS total_players
		FROM mlb.schools s
		LEFT JOIN mlb.school_details sd
		ON s.schoolID = sd.schoolID
		GROUP BY s.schoolID, sd.name_full, ROUND(s.yearID,-1) 
		),

		rn AS (
		SELECT 
			decade,
			name_full,
		total_players,
		ROW_NUMBER() OVER (PARTITION BY decade ORDER BY total_players DESC) AS row_num
		FROM decades_schools)

		SELECT * FROM rn
		WHERE row_num <= 3
		ORDER BY decade DESC, row_num
