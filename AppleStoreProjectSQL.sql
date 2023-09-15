
--Intro: Hi, my name is Tate Doherty and this is a SQL Project using a data set from Kaggle about Apple Store applications to learn trends and insights. 

--1. Check that the two tables imported, AppleStore and appleStore_description, have data that is available 

SELECT *
FROM dbo.AppleStore

SELECT * 
FROM dbo.appleStore_description

--2. Check that the unique ids match in both tables 

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM dbo.AppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM dbo.appleStore_description

--3. Check for missing values in both tables 

SELECT COUNT(*) AS MissingValues
FROM dbo.AppleStore
WHERE track_name IS NULL OR user_rating IS NULL OR prime_genre IS NULL

SELECT COUNT(*) AS MissingValues
FROM dbo.appleStore_description
WHERE track_name IS NULL OR size_bytes IS NULL OR app_desc IS NULL

--4. Check for the number of apps in the Apple Store per genre 

SELECT prime_genre, COUNT(*) AS NumApps
FROM dbo.AppleStore 
GROUP BY prime_genre
ORDER BY NumApps DESC

--5. Check for apps in the Apple Store with the minimum, maximum, and average rating

SELECT  min(user_rating) AS MinRating,
		max(user_rating) AS MaxRating,
		avg(user_rating) AS AvgRating
FROM dbo.AppleStore


--6. Create a temp table using info from the AppleStore table and add a new column named App_Type. 
--Then find the average rating for free and paid applications


DROP TABLE IF EXISTS #Temp_AppleTable
CREATE TABLE #Temp_AppleTable (
ID nvarchar(200), 
track_name nvarchar(250),
size_bytes nvarchar(250),
price float, 
user_rating float)

INSERT INTO #Temp_AppleTable
SELECT id, track_name, size_bytes, price, user_rating FROM dbo.AppleStore


ALTER TABLE #Temp_AppleTable ADD App_Type as (case
		WHEN price > 0 THEN 'Paid'
		ELSE 'Free'
	END);
	
SELECT App_Type, AVG(user_rating) as Avg_rating
FROM #Temp_AppleTable
GROUP BY App_Type


--7. Create a temp table using info from the AppleStore table and add a new column named Language_Bucket. 
--Then find the average ratings for each Language Bucket (<10, 10-30, >30 languages)

DROP TABLE IF EXISTS #Temp_AppleTableLanguage
CREATE TABLE #Temp_AppleTableLanguage (
ID nvarchar(200), 
track_name nvarchar(250),
size_bytes nvarchar(250),
lang_num float, 
user_rating float)

INSERT INTO #Temp_AppleTableLanguage
SELECT id, track_name, size_bytes, lang_num, user_rating FROM dbo.AppleStore


ALTER TABLE #Temp_AppleTableLanguage ADD Language_Bucket as (case
		WHEN lang_num < 10 THEN '<10 Languages'
		WHEN lang_num BETWEEN 10 AND 30 THEN '10-30 Languages'
		ELSE '>30 Languages'
	END);

SELECT Language_Bucket, AVG(user_rating) as Avg_rating
FROM #Temp_AppleTableLanguage
GROUP BY Language_Bucket
ORDER BY Avg_rating DESC

--8. Check genres with the lowest ratings so potential App Developers can make improved Apps in these genres

SELECT prime_genre, avg(user_rating) as AvgRating
FROM dbo.AppleStore 
GROUP BY prime_genre
ORDER BY AvgRating ASC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY

--9. Join the two tables and make a temp table to see if there is a correlation betweeen the length of the app desc and the user rating

DROP TABLE IF EXISTS #Temp_DescTable
CREATE TABLE #Temp_DescTable (
ID nvarchar(200), 
track_name nvarchar(250),
size_bytes nvarchar(250),
app_desc nvarchar(MAX), 
user_rating float)

INSERT INTO #Temp_DescTable
SELECT appstore.id, appstore.track_name, appstore.size_bytes, appdesc.app_desc, appstore.user_rating
FROM dbo.appleStore_description appdesc JOIN dbo.AppleStore appstore on appdesc.id = appstore.id


ALTER TABLE #Temp_DescTable ADD Description_Length_Bucket as (case
		WHEN len(app_desc) < 500 THEN 'Short'
		WHEN len(app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
		ELSE 'Long'
	END);

SELECT Description_Length_Bucket, AVG(user_rating) as Avg_rating
FROM #Temp_DescTable
GROUP BY Description_Length_Bucket
ORDER BY Avg_rating DESC


--10. Check the top rated apps for each genre with the highest rating and rating total

SELECT prime_genre, track_name, user_rating
FROM (SELECT prime_genre, track_name, user_rating, RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS RANK
	  FROM dbo.AppleStore) AS BestAppofGenre
WHERE BestAppofGenre.rank = 1



--Conclusion

--Insights and Trends Learned:

--Games, Entertainment, Education, Photo & Video, and Utilities have the highest number of apps so they are the most competitive categories (Step #4) 
-- The average app rating is 3.527, so app devlopers should aim to develop applications with a rating over 3.527 out of 5 (Step #5) 
-- Paid apps do have better ratings: Paid Avg Rating = 3.721 and Free AVG Rating = 3.377 so developers should consider creating a paid application (Step #6) 
-- Apps with 10-30 Languages have the highest avg app rating = 4.131 so developers should create apps with 10-30 languages (Step #7) 
--Catalogs, Finance, and Book apps have the lowest ratings so developers should create new market opportunities in these categories (Step #8) 
-- Apps with a longer description have the highest ratings so developers should include long descriptions for their apps to attain the highest ratings (Step #9) 





	

