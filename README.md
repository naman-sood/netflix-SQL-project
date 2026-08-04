# netflix-SQL-project
Netflix Movies and TV Shows Data Analysis using SQL
<img width="2226" height="678" alt="image" src="https://github.com/user-attachments/assets/fb38f52e-874c-4be4-ae0e-6ae01fa76c54" />


Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

Objectives
Analyze the distribution of content types (movies vs TV shows).
Identify the most common ratings for movies and TV shows.
List and analyze content based on release years, countries, and durations.
Explore and categorize content based on specific criteria and keywords.
Dataset
The data for this project is sourced from the Kaggle dataset:

Dataset Link: Movies Dataset
Schema
CREATE TABLE netflix
(
    show_id      VARCHAR(10) PRIMARY KEY,
    type         VARCHAR(20),
    title        VARCHAR(200),
    director     VARCHAR(250),
    casts        VARCHAR(1000),
    country      VARCHAR(150),
    date_added   VARCHAR(50),
    release_year INT,
    rating       VARCHAR(10),
    duration     VARCHAR(20),
    listed_in    VARCHAR(100),
    description  VARCHAR(350)
);
Business Problems and Solutions
1. Count the Number of Movies vs TV Shows
SELECT
    type,
    COUNT(*) AS total_content
FROM netflix
GROUP BY type;
Objective: Determine the distribution of Movies and TV Shows available on Netflix.

2. Find the Most Common Rating for Movies and TV Shows
WITH ratings_count AS
(
    SELECT
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
ranked_ratings AS
(
    SELECT *,
           RANK() OVER (
               PARTITION BY type
               ORDER BY rating_count DESC
           ) AS ratings_rank
    FROM ratings_count
)

SELECT
    type,
    rating AS most_occurring_rating
FROM ranked_ratings
WHERE ratings_rank = 1;
Objective: Identify the most frequently occurring rating for Movies and TV Shows.

3. List All Movies Released in a Specific Year (2020)
SELECT
    title
FROM netflix
WHERE type = 'Movie'
  AND release_year = 2020;
Objective: Retrieve all movies released in the year 2020.

4. Find the Top 5 Countries with the Most Content on Netflix
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY TRIM(UNNEST(STRING_TO_ARRAY(country, ',')))
ORDER BY total_content DESC
LIMIT 5;
Objective: Identify the top five countries with the highest amount of Netflix content.

5. Identify the Longest Movie
SELECT
    title,
    CAST(REPLACE(duration, 'min', '') AS INT) AS duration_minutes
FROM netflix
WHERE type = 'Movie'
  AND duration IS NOT NULL
ORDER BY duration_minutes DESC
LIMIT 1;
Objective: Find the movie with the longest runtime.

6. Find Content Added Between 2016 and 2021
SELECT *,
       TO_DATE(date_added, 'Month DD, YYYY') AS new_date_added
FROM netflix
WHERE EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY'))
      BETWEEN 2016 AND 2021
ORDER BY new_date_added DESC;
Objective: Retrieve all content added to Netflix between 2016 and 2021.

7. Find All Movies and TV Shows by Director 'Rajiv Chilaka'
SELECT *
FROM
(
    SELECT
        title,
        TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';
Objective: List all Netflix content directed by Rajiv Chilaka.

8. List All TV Shows with More Than 5 Seasons
WITH show_and_seasons AS
(
    SELECT
        title,
        CAST(
            TRIM(REGEXP_REPLACE(duration, ' Seasons?', '', 'g'))
            AS INT
        ) AS no_of_seasons
    FROM netflix
    WHERE type = 'TV Show'
)

SELECT *
FROM show_and_seasons
WHERE no_of_seasons > 5
ORDER BY no_of_seasons;
Objective: Identify TV Shows that have more than five seasons.

9. Count the Number of Content Items in Each Genre
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
    COUNT(show_id) AS no_of_items
FROM netflix
GROUP BY TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ',')))
ORDER BY no_of_items DESC;
Objective: Count the number of Netflix titles available in each genre.

10. Calculate the Percentage of Indian Netflix Content Released Each Year
WITH nations AS
(
    SELECT *,
           TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS countries
    FROM netflix
)

SELECT
    countries,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) * 100.00 /
        (
            SELECT COUNT(show_id)
            FROM nations
            WHERE countries = 'India'
        ),
        2
    ) AS release_pct
FROM nations
WHERE countries = 'India'
GROUP BY countries, release_year
ORDER BY release_pct DESC
LIMIT 5;
Objective: Calculate the yearly percentage of Indian Netflix content releases and identify the top five years with the highest contribution.

11. Calculate the Percentage of Movies That Are Documentaries
WITH genres AS
(
    SELECT
        show_id,
        TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre
    FROM netflix
    WHERE type = 'Movie'
)

SELECT
    COUNT(show_id) AS no_of_documentaries,
    ROUND(
        (COUNT(show_id) * 100.0) /
        (
            SELECT COUNT(show_id)
            FROM netflix
            WHERE type = 'Movie'
        ),
        2
    ) AS percentage_of_documentaries
FROM genres
WHERE genre = 'Documentaries';
Objective: Calculate what percentage of Netflix movies are documentaries.

12. Find All Content Without a Director
SELECT *
FROM netflix
WHERE director IS NULL;
Objective: Retrieve all Netflix titles that do not have a director listed.

13. Find All Titles Featuring Salman Khan Between 2011 and 2021
SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
  AND release_year BETWEEN 2011 AND 2021;
Objective: Retrieve all Netflix titles featuring Salman Khan that were released between 2011 and 2021.

14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
WITH cte_crew AS
(
    SELECT *,
           TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS crew
    FROM netflix
)

SELECT
    crew,
    COUNT(show_id) AS no_of_appearances
FROM cte_crew
WHERE country ILIKE '%India%'
  AND type = 'Movie'
GROUP BY crew
ORDER BY no_of_appearances DESC
LIMIT 10;
Objective: Identify the actors with the highest number of appearances in Indian-produced Netflix movies.

15. Categorize Content Based on the Presence of 'Kill' and 'Violence'
SELECT
    type,
    category,
    COUNT(*) AS content_count
FROM
(
    SELECT *,
           CASE
               WHEN description ILIKE '%kill%'
                 OR description ILIKE '%violence%'
               THEN 'Bad'
               ELSE 'Good'
           END AS category
    FROM netflix
) AS t
GROUP BY category, type
ORDER BY type, category DESC;
Objective: Categorize Netflix content as Bad if its description contains the keywords "kill" or "violence", and Good otherwise. Count the number of titles in each category.

Findings and Conclusion
Content Distribution: The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
Common Ratings: Insights into the most common ratings provide an understanding of the content's target audience.
Geographical Insights: The top countries and the average content releases by India highlight regional content distribution.
Content Categorization: Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.
This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.

Author - Naman Sood
This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!
