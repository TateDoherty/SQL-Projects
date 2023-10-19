/* Hi, my name is Tate Doherty and I am making an SQL Project in MySQL using a data set 
from kaggle: "120 years of Olympic history: athletes and results" 
link: https://www.kaggle.com/datasets/heesoo37/120-years-of-olympic-history-athletes-and-results?rvi=1*/

/* A. Make sure that the data has loaded */
SELECT * FROM OLYMPICS_HISTORY;
SELECT * FROM OLYMPICS_HISTORY_NOC_REGIONS;

/* B. Make sure there are no null values in the data for the two tables */
SELECT COUNT(*) AS count_of_null_values_oly
FROM OLYMPICS_HISTORY
WHERE id IS NULL OR name IS NULL;

SELECT COUNT(*) AS count_of_null_values_noc
FROM OLYMPICS_HISTORY_NOC_REGIONS
WHERE NOC IS NULL OR region IS NULL;

/* 1. How many olympics games have been held? */
SELECT COUNT(DISTINCT games) AS total_olympic_games 
FROM OLYMPICS_HISTORY;

/* 2. List down all Olympics games held so far. */
SELECT DISTINCT year, season, city 
FROM OLYMPICS_HISTORY
ORDER BY year;

/* 3. Mention the total no of nations who participated in each olympics game. */
SELECT games, COUNT(DISTINCT NOC) AS total_countries
FROM OLYMPICS_HISTORY
GROUP BY games
ORDER BY games;

/* 4. Which year saw the highest and lowest no of countries participating in olympics? */
WITH CountryCounts AS (SELECT games, COUNT(DISTINCT NOC) AS TotalCountries FROM OLYMPICS_HISTORY GROUP BY games)
SELECT 
CONCAT(MIN(CASE WHEN TotalCountries = (SELECT MIN(TotalCountries) FROM CountryCounts) THEN games END), ' (', MIN(TotalCountries), ' countries)')AS lowest_countries, 
CONCAT(MAX(CASE WHEN TotalCountries = (SELECT MAX(TotalCountries) FROM CountryCounts) THEN games END), ' (', MAX(TotalCountries), ' countries)')AS highest_countries
FROM CountryCounts;

/* 5. Which nation has participated in all of the olympic games? */
SELECT noc.region AS Region, COUNT(DISTINCT oly.games) AS total_participating_games
FROM OLYMPICS_HISTORY_NOC_REGIONS noc JOIN OLYMPICS_HISTORY oly on noc.NOC = oly.NOC
GROUP BY noc.region 
HAVING COUNT(DISTINCT oly.games) = (SELECT COUNT(DISTINCT games) FROM OLYMPICS_HISTORY)
ORDER BY noc.region;

/* 6. Identify the sport which was played in all summer olympics. */
SELECT sport, COUNT(DISTINCT games) AS Number_of_Games, (SELECT COUNT(DISTINCT games) FROM OLYMPICS_HISTORY WHERE season = 'Summer') AS Total_Summer_Games
FROM OLYMPICS_HISTORY
GROUP by sport
HAVING COUNT(DISTINCT games) = (SELECT COUNT(DISTINCT games) FROM OLYMPICS_HISTORY WHERE season = 'Summer');

/* 7. Identify the sport which were just played once in all of olympics. */
SELECT sport, COUNT(DISTINCT games) AS number_of_games, GROUP_CONCAT(DISTINCT games ORDER BY games) AS games
FROM OLYMPICS_HISTORY
GROUP BY sport
HAVING COUNT(DISTINCT games) = 1;

/* 8. Fetch the total no of sports played in each olympic games. */
SELECT games, COUNT(DISTINCT sport) AS no_of_sports
FROM OLYMPICS_HISTORY
GROUP BY games
ORDER BY games;

/* 9. Fetch the 5 oldest athletes to win a gold medal. */
SELECT name, sex, age, team, games, city, sport, event
FROM OLYMPICS_HISTORY
WHERE medal = 'Gold' AND age != 'NA'
ORDER BY age DESC
LIMIT 5;

/* 10. Find the Ratio of male and female athletes participated in all olympic games. */
SELECT
CONCAT('1 male : ', 
CASE
	WHEN COUNT(DISTINCT CASE WHEN Sex = 'F' THEN name END) > 0
	THEN CAST(COUNT(DISTINCT CASE WHEN Sex = 'M' THEN name END) AS DECIMAL) / 
	COUNT(DISTINCT CASE WHEN Sex = 'F' THEN Name END)
	ELSE 0
END, ' female(s)') AS male_to_female_ratio
FROM OLYMPICS_HISTORY;

/* 11. Fetch the top 5 athletes who have won the most gold medals. */
SELECT name, team, SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) AS total_gold_medals
FROM OLYMPICS_HISTORY
GROUP BY name, team
ORDER BY total_gold_medals DESC
LIMIT 5;

/* 12. Fetch the top 10 athletes who have won the most medals (gold/silver/bronze). */
SELECT name, team, SUM(CASE WHEN medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS total_medals
FROM OLYMPICS_HISTORY
GROUP BY name, team
ORDER BY total_medals DESC
LIMIT 10;

/* 13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won. */
SELECT noc.region, COUNT(*) AS no_medals_won, ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS country_rank
FROM OLYMPICS_HISTORY oly JOIN OLYMPICS_HISTORY_NOC_REGIONS noc ON oly.NOC = noc.NOC
WHERE oly.medal IN ('Gold', 'Silver', 'Bronze')
GROUP by noc.region
ORDER BY country_rank 
LIMIT 5;

/* 14. List down total gold, silver and bronze medals won by each country. */
SELECT noc.region AS country, 
SUM(CASE WHEN oly.medal = 'Gold' THEN 1 ELSE 0 END) AS gold, 
SUM(CASE WHEN oly.medal = 'Silver' THEN 1 ELSE 0 END) AS silver, 
SUM(CASE WHEN oly.medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze
FROM OLYMPICS_HISTORY oly JOIN OLYMPICS_HISTORY_NOC_REGIONS noc ON oly.NOC = noc.NOC
GROUP BY noc.region
ORDER BY gold DESC;

/* 15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games. */
SELECT oly.games, noc.region AS country, 
SUM(CASE WHEN oly.medal = 'Gold' THEN 1 ELSE 0 END) AS gold, 
SUM(CASE WHEN oly.medal = 'Silver' THEN 1 ELSE 0 END) AS silver, 
SUM(CASE WHEN oly.medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze
FROM OLYMPICS_HISTORY oly JOIN OLYMPICS_HISTORY_NOC_REGIONS noc ON oly.NOC = noc.NOC
WHERE noc.region = 'Greece'
GROUP BY oly.games, noc.region
ORDER BY oly.games;

/* 16. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games. */
WITH MedalCounts AS (
	SELECT oly.games AS game, noc.region AS Country,
		SUM(CASE WHEN oly.medal = 'Gold' THEN 1
			WHEN oly.medal = 'Silver' THEN 1
			WHEN oly.medal = 'Bronze' THEN 1 ELSE 0 END) AS TotalMedals,
			ROW_NUMBER() OVER (PARTITION BY oly.games 
			ORDER BY SUM(CASE WHEN oly.medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) DESC) AS MedalRank
	FROM OLYMPICS_HISTORY oly JOIN OLYMPICS_HISTORY_NOC_REGIONS noc ON oly.NOC = noc.NOC
    GROUP BY oly.games, noc.region
)
SELECT Game, CONCAT(
        MAX(CASE WHEN MedalRank = 1 THEN Country END), ' - ',
        MAX(CASE WHEN MedalRank = 1 THEN TotalMedals
                 WHEN MedalRank = 2 THEN TotalMedals
				 WHEN MedalRank = 3 THEN TotalMedals END)) AS Total_Medals
FROM MedalCounts
GROUP BY
game
ORDER BY
game;



   

