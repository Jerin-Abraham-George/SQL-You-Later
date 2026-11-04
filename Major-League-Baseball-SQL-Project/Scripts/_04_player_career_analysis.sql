/*
Player Career Analysis:
----------------------------------------------------------------------------------------------------------------------------------------------------
This analysis explores the career journeys of MLB players, focusing on their ages at debut and retirement, overall career longevity, 
and the teams they represented during their starting and ending years.

It also examines team loyalty by identifying players who spent more than a decade in the league and started and ended their 
careers with the same team.
----------------------------------------------------------------------------------------------------------------------------------------------------
*/

/*================================================================================================================================================*/
  
/* Question 3:

a) For each player, calculate their age at their first (debut) game, their last game, and their career length 
(all in years). Sort from longest career to shortest career.

b) What team did each player play on for their starting and ending years?

c) How many players started and ended on the same team and also played for over a decade?

*/


-- Solution a: Player ages and career length

        SELECT
            playerID, 
            nameGiven, 
            debut,
            finalGame,
            DATEDIFF(YEAR, (TRY_CAST(CONCAT(birthYear, '-', birthMonth, '-', birthDay) AS DATE)), debut) AS debut_age,
            DATEDIFF(YEAR, (TRY_CAST(CONCAT(birthYear, '-', birthMonth, '-', birthDay) AS DATE)), finalGame) AS finalgame_age,
            DATEDIFF(YEAR, debut, finalGame) AS career_length
        FROM mlb.players
        ORDER BY career_length DESC


-- Solution b: Starting and ending teams

        SELECT 
            p.playerid,
            p.nameGiven,
            s.yearID AS starting_year,
            s.teamID AS starting_team,
            e.yearID AS ending_year,
            e.teamID AS ending_team
        FROM mlb.players p
        INNER JOIN mlb.salaries s
        ON p.playerID = s.playerID AND YEAR(p.debut) = s.yearID
        INNER JOIN mlb.salaries e
        ON p.playerID = e.playerID AND YEAR(p.finalGame) = e.yearID


-- Solution c: Players with over 10-year careers who started and ended with the same team

        SELECT 
            p.playerid,
            p.nameGiven,
            s.yearID AS starting_year,
            s.teamID AS starting_team,
            e.yearID AS ending_year,
            e.teamID AS ending_team
        FROM mlb.players p
        INNER JOIN mlb.salaries s
        ON p.playerID = s.playerID AND YEAR(p.debut) = s.yearID
        INNER JOIN mlb.salaries e
        ON p.playerID = e.playerID AND YEAR(p.finalGame) = e.yearID  
        WHERE s.teamID = e.teamID AND e.yearID - s.yearID > 10
