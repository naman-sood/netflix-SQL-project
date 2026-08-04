 --Netflix Project

 CREATE TABLE netflix

 (
	show_id	VARCHAR(10) PRIMARY KEY,
	type	VARCHAR(20),
	title	VARCHAR(200),
	director VARCHAR(250),
	casts	 VARCHAR(1000),
	country	 VARCHAR(150),
	date_added	VARCHAR(50),
	release_year	INT,
	rating	VARCHAR(10),
	duration	VARCHAR(20),
	listed_in	VARCHAR(100),
	description  VARCHAR(350)
 );

 Select COUNT(*) as total_count FROM netflix

 -- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

SELECT type,
		COUNT(*) as total_content
FROM netflix
GROUP BY type;


--2. Find the most common rating for movies and TV shows

with ratings_count as (
				SELECT type,
					   rating,
					   COUNT(*) as rating_count 
				FROM netflix
				GROUP BY type, rating 
				),
ranked_ratings as (
						SELECT *,
								RANK() OVER(partition by type 
												order by rating_count desc) as ratings_rank
						FROM ratings_count
					)

SELECT type, 
		rating as most_occurring_rating
FROM ranked_ratings
WHERE ratings_rank = 1;

--3. List all movies released in a specific year (e.g., 2020)

SELECT title
FROM netflix 
WHERE type = 'Movie' AND release_year = 2020;


--4. Find the top 5 countries with the most content on Netflix

SELECT TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country, 
		COUNT(show_id) as total_content
FROM netflix 
GROUP BY TRIM(UNNEST(STRING_TO_ARRAY(country, ',')))
ORDER BY total_content DESC
LIMIT 5;


--5. Identify the longest movie

SELECT 
	title,
	CAST(REPLACE(duration, 'min' , '') AS INT ) as duration_minutes 
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY duration_minutes DESC
LIMIT 1; 


--6. Find only the content added between 2016 and 2021 

SELECT *, 
		TO_DATE(date_added, 'Month DD, YYYY') as new_date_added
FROM netflix
WHERE EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) BETWEEN 2016 AND 2021
ORDER BY new_date_added DESC;



--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM (SELECT title, 
				TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) as director_name
	   FROM netflix) as t
WHERE director_name = 'Rajiv Chilaka';

--8. List all TV shows with more than 5 seasons

with show_and_seasons as (
							SELECT
							    title,
							    CAST(TRIM(REGEXP_REPLACE(duration, ' Seasons?', '', 'g')) AS INT)
										AS no_of_seasons
							FROM netflix
							WHERE type = 'TV Show'
						)
SELECT *
FROM show_and_seasons 
WHERE no_of_seasons > 5 
ORDER BY no_of_seasons;


--9. Count the number of content items in each genre (listed_in column is genres combined)

SELECT TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) as genre,
		COUNT(show_id) as no_of_items
FROM netflix
GROUP BY TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ',')))
ORDER BY no_of_items DESC;

/* we can conclude through this line of code that 
	International Movies, Dramas and Comedies are the most watched genre*/

--10.For each release year, calculate the percentage of
		--Indian Netflix content released in that year. 
		--Return the top 5 years with the highest percentage of releases.

with nations as (
				SELECT *,
						TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) as countries
				FROM netflix   
				)
SELECT countries,
		release_year,
		COUNT(show_id) as total_release,
		ROUND(COUNT(show_id)*100.00/ 
								(SELECT COUNT(show_id) FROM nations WHERE countries = 'India'),2) 
			as release_pct
FROM nations 
WHERE countries = 'India'
GROUP BY countries, release_year
ORDER BY release_pct DESC
LIMIT 5;

--11. List the percentage of movies that are documentaries
 
with genres as (
				SELECT show_id,
						TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) as genre
				FROM netflix 
				WHERE type = 'Movie'
				)
SELECT COUNT(show_id) as no_of_documentaries,
		ROUND((COUNT(show_id) * 100.0)/
						(SELECT COUNT(show_id) FROM netflix WHERE type = 'Movie'), 2) 
									as percentage_of_documentaries
FROM genres 
WHERE genre = 'Documentaries';

--12. Find all content without a director

SELECT *
FROM netflix
WHERE director IS NULL;

--13. Find how many times does the movie actor 'Salman Khan' appeared from 2011 to 2021

SELECT * 
FROM netflix 
WHERE casts ILIKE '%Salman Khan%'
		AND release_year BETWEEN 2011 AND 2021;


--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

with cte_crew as 
				(SELECT *,
						TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) as crew
				FROM netflix 
				)
SELECT crew,
		COUNT(show_id) as no_of_appearances
FROM cte_crew
WHERE country ILIKE '%India%' AND type = 'Movie'
GROUP BY crew
ORDER BY no_of_appearances DESC
LIMIT 10;
 

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

SELECT type, 
		category,
		COUNT(*) as content_count
FROM   (SELECT *, 
			(CASE WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' then 'Bad'
					ELSE 'Good' END) as category 
		FROM netflix) as t
GROUP BY category, type 
ORDER BY type, category DESC;


