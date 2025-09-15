-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems

--  1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*)
FROM Netflix
GROUP BY type

-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT type, rating, COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
MaxCounts AS (
    SELECT type, MAX(rating_count) AS max_count
    FROM RatingCounts
    GROUP BY type
)
SELECT rc.type,
       rc.rating AS most_frequent_rating,
       rc.rating_count
FROM RatingCounts rc
INNER JOIN MaxCounts mc
    ON rc.type = mc.type
   AND rc.rating_count = mc.max_count
ORDER BY rc.type;

-- 3. List all movies released in a specific year 2020

SELECT * 
FROM netflix
WHERE release_year = 2020

-- 4. Find the top 5 countries with the most content on Netflix

SELECT TOP 5
    LTRIM(RTRIM([value])) AS country,
    COUNT(*) AS total_content
FROM netflix
CROSS APPLY OPENJSON('["' + REPLACE(country, ',', '","') + '"]')
WHERE [value] IS NOT NULL 
  AND LTRIM(RTRIM([value])) <> ''
GROUP BY LTRIM(RTRIM([value]))
ORDER BY total_content DESC;


-- 5. Identify the longest movie

SELECT TOP 1
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY 
    CAST(
        LEFT(duration, CHARINDEX(' ', duration + ' ') - 1) 
        AS INT
    ) DESC;


-- 6. Find content added in the last 5 years
 
SELECT *
FROM netflix
WHERE TRY_CONVERT(DATE, date_added, 107) >= DATEADD(YEAR, -5, GETDATE());


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *, 
            LTRIM(RTRIM(value)) AS director_name
FROM netflix n
CROSS APPLY STRING_SPLIT(n.director, ',')
WHERE LTRIM(RTRIM(value)) = 'Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND CAST(
        LEFT(duration, CHARINDEX(' ', duration + ' ') - 1) 
        AS INT
      ) > 5;


-- 9. Count the number of content items in each genre

SELECT 
    LTRIM(RTRIM(value)) AS genre,
    COUNT(*) AS total_content
FROM netflix
CROSS APPLY STRING_SPLIT(listed_in, ',')
WHERE value IS NOT NULL AND LTRIM(RTRIM(value)) <> ''
GROUP BY LTRIM(RTRIM(value))
ORDER BY total_content DESC;


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

SELECT TOP 5
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        CAST(COUNT(show_id) AS DECIMAL(10,2)) /
        CAST((SELECT COUNT(show_id) FROM netflix WHERE country = 'India') AS DECIMAL(10,2)) * 100, 
        2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC;


-- 11. List all movies that are documentaries

SELECT * FROM netflix
WHERE listed_in = 'Documentaries'


-- 12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT *
FROM netflix
WHERE release_year > YEAR(GETDATE()) - 10
  AND casts LIKE '%Salman Khan%';

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.	

SELECT TOP 10
    LTRIM(RTRIM(value)) AS actor,
    COUNT(*) AS total_content
FROM netflix
CROSS APPLY STRING_SPLIT(casts, ',')
WHERE country = 'India'
  AND value IS NOT NULL
  AND LTRIM(RTRIM(value)) <> ''
GROUP BY LTRIM(RTRIM(value))
ORDER BY total_content DESC;


/* 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other 
         content as 'Good'. Count how many items fall into each category.	
*/

SELECT 
    category,
    type,
    COUNT(*) AS content_count
FROM (
    SELECT *,
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category, type
ORDER BY type;



--END OF THE PROJECT

