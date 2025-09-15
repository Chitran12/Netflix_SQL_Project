# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project analyzes Netflix’s movies and TV shows dataset using SQL to uncover useful insights. The main aim is to help inform decisions and guide content strategy on the platform. It explores key aspects like content type, genres, release year, ratings, and countries. The analysis answers important business questions and turns raw data into actionable information. Overall, it highlights how data-driven insights can enhance content planning and viewer engagement.

## Objectives

* Examine the proportion of content types, distinguishing between movies and TV shows. 
* Identify the most common ratings assigned to movies and TV shows.
* Analyze content patterns across release years, countries, and duration ranges.
* Classify and assess content using selected keywords and defined criteria to extract meaningful insights.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
	type,
	COUNT(*)
FROM Netflix
GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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

```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM netflix
WHERE release_year = 2020
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT TOP 5
    LTRIM(RTRIM([value])) AS country,
    COUNT(*) AS total_content
FROM netflix
CROSS APPLY OPENJSON('["' + REPLACE(country, ',', '","') + '"]')
WHERE [value] IS NOT NULL 
  AND LTRIM(RTRIM([value])) <> ''
GROUP BY LTRIM(RTRIM([value]))
ORDER BY total_content DESC;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT TOP 1
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY 
    CAST(
        LEFT(duration, CHARINDEX(' ', duration + ' ') - 1) 
        AS INT
    ) DESC;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix
WHERE TRY_CONVERT(DATE, date_added, 107) >= DATEADD(YEAR, -5, GETDATE());
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *, 
            LTRIM(RTRIM(value)) AS director_name
FROM netflix n
CROSS APPLY STRING_SPLIT(n.director, ',')
WHERE LTRIM(RTRIM(value)) = 'Rajiv Chilaka';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND CAST(
        LEFT(duration, CHARINDEX(' ', duration + ' ') - 1) 
        AS INT
      ) > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
    LTRIM(RTRIM(value)) AS genre,
    COUNT(*) AS total_content
FROM netflix
CROSS APPLY STRING_SPLIT(listed_in, ',')
WHERE value IS NOT NULL AND LTRIM(RTRIM(value)) <> ''
GROUP BY LTRIM(RTRIM(value))
ORDER BY total_content DESC;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT * FROM netflix
WHERE listed_in = 'Documentaries'
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * FROM netflix
WHERE director IS NULL
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT *
FROM netflix
WHERE release_year > YEAR(GETDATE()) - 10
  AND casts LIKE '%Salman Khan%';
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset includes a wide variety of movies and TV shows spanning multiple genres and ratings.
- **Common Ratings:** Analyzing the most frequent ratings offers insights into the target audience and content suitability.
- **Geographical Insights:** Examining top countries and trends in content releases, such as in India, highlights regional distribution patterns.
- **Content Categorization:** Classifying content using specific keywords offers clear insights into the type and nature of Netflix’s offerings.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Chitran Khatri

This project is part of my portfolio, showcasing the SQL skills essential for Data Analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch in me on **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/chitrankhatri/)

Thank you for your support, and I look forward to connecting with you!
- **YouTube**: [Subscribe to my channel for tutorials and insights](https://www.youtube.com/@zero_analyst)
- **Instagram**: [Follow me for daily tips and updates](https://www.instagram.com/zero_analyst/)
- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/najirr)
- **Discord**: [Join our community to learn and grow together](https://discord.gg/36h5f2Z5PK)

Thank you for your support, and I look forward to connecting with you!
