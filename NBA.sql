USE ProjectPortfolio

--Taking a quick look at the data

SELECT *
FROM NBA

--How many players are included in each season?
SELECT season, COUNT(*) AS NumberOfPlayers
FROM NBA
GROUP BY season
ORDER BY season

--For simplicity, I will update the season column with just the starting year.
Update [dbo].[NBA]
SET season = SUBSTRING(season, 1, CHARINDEX('-', season) -1)

Update [dbo].[NBAMVPs]
SET Season = SUBSTRING(Season, 1, CHARINDEX('–', Season) -1)

--Which Colleges produce the highest scorers in the NBA?
SELECT TOP 10 college, SUM(pts) AS TotalPointsPerGame
FROM NBA
GROUP BY college
ORDER BY SUM(pts) DESC

--Why is "None" leading in points scored?
SELECT player_name, SUM(pts)
FROM NBA
WHERE college = 'None'
GROUP BY player_name
ORDER BY SUM(pts) DESC
--This is because players like Lebron James and Kobe Bryant went from High School to the NBA
--And also because players like Dirk Nowitzki and Tony Parker came from overseas
--For the sake of just looking at the top 10 colleges, I will exclude them
SELECT TOP 10 college, SUM(pts) AS TotalPointsPerGame
FROM NBA
WHERE college != 'None'
GROUP BY college
ORDER BY SUM(pts) DESC


--I'm curious about the best Points Per Game (PPG) seasons in NBA history.
SELECT TOP 100 player_name, pts, season, college, age
FROM NBA
ORDER BY pts DESC

--Now let's look at points from a team standpoint
--For each season, which team had the highest PPG?
WITH top_team AS
(
	SELECT team_abbreviation, SUM(pts) AS PPG, season, ROW_NUMBER() OVER (PARTITION BY season ORDER BY SUM(pts) DESC) AS row_number
	FROM NBA
	GROUP BY season, team_abbreviation
)
SELECT team_abbreviation, PPG, season
FROM top_team
WHERE row_number = 1
--Unfortunately some are misleading because if a team completes a mid-season trade, they might get credit for players on their team before and after the trade

--Joining the Players Table with the MVP table to create a binary MVP column
SELECT TOP 50 n.player_name, n.team_abbreviation, n.age, n.college, n.pts, n.reb, n.ast, n.net_rating, n.season
, CASE WHEN m.Player is null THEN 'No'
	   ELSE 'Yes'
	   END AS 'WonMVP'
FROM NBA AS n
LEFT JOIN NBAMVPs AS m
	ON n.player_name = m.Player
	AND n.season = m.Season
ORDER BY pts DESC
--
SELECT TOP 50 n.player_name, n.team_abbreviation, n.age, n.college, n.pts, n.reb, n.ast, n.net_rating, n.season
, CASE WHEN m.Player is null THEN 'No'
	   ELSE 'Yes'
	   END AS 'WonMVP'
FROM NBA AS n
LEFT JOIN NBAMVPs AS m
	ON n.player_name = m.Player
	AND n.season = m.Season
ORDER BY reb DESC
--
SELECT TOP 50 n.player_name, n.team_abbreviation, n.age, n.college, n.pts, n.reb, n.ast, n.net_rating, n.season
, CASE WHEN m.Player is null THEN 'No'
	   ELSE 'Yes'
	   END AS 'WonMVP'
FROM NBA AS n
LEFT JOIN NBAMVPs AS m
	ON n.player_name = m.Player
	AND n.season = m.Season
ORDER BY ast DESC
--
---How has scoring evolved since 1996?
SELECT season, SUM(pts) AS TotalPlayerPPG, AVG(pts) AS AveragePlayerPPG
FROM NBA
GROUP BY season
ORDER BY season

--Now let's take a look at how draft position influences scoring
SELECT AVG(pts) AS AveragePPG
, CASE WHEN draft_number <= 15 THEN 'Early First'
	   WHEN draft_number >15 AND draft_number <= 30 THEN 'Late First'
	   WHEN draft_number >30 AND draft_number <= 45 THEN 'Early Second'
	   WHEN draft_number >45 AND draft_number <= 60 THEN 'Late Second'
	   ELSE 'Undrafted' END AS draft_position
FROM NBA
GROUP BY CASE WHEN draft_number <= 15 THEN 'Early First'
	   WHEN draft_number >15 AND draft_number <= 30 THEN 'Late First'
	   WHEN draft_number >30 AND draft_number <= 45 THEN 'Early Second'
	   WHEN draft_number >45 AND draft_number <= 60 THEN 'Late Second'
	   ELSE 'Undrafted' END 
ORDER BY AveragePPG DESC

