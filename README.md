# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
 create table netflix(
	show_id	        VARCHAR(5),
	type            VARCHAR(10),
	title	        VARCHAR(250),
	director        VARCHAR(550),
	casts	        VARCHAR(1050),
	country	        VARCHAR(550),
	date_added	    VARCHAR(55),
	release_year	INT,
	rating	        VARCHAR(15),
	duration	    VARCHAR(15),
	listed_in	    VARCHAR(250),
	description     VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
select
    type ,
    count(*) as count 
from netflix
group by type;

```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
select *
from
    (
    	select
            type,
            rating,
            count(*) as total_rating ,
    	    rank() over(partition by type order by count(*) desc) as ranking 
    	from netflix
    	group by type,rating
    	order by count(*) desc
    ) as t1 
where ranking = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
select *
from netflix
where release_year = 2020
and type  = 'Movie';
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
-- we have to split the list of string in a array
select unnest(string_to_array(country,',')) from netflix;

-- main query

select  
	unnest(string_to_array(country,',')) as country , 
	count(*) as total_content
from netflix
group by 1
order by 2 desc
limit 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
Select
    *
From netflix
Where type = 'Movie'
Order by split_part(duration, ' ', 1)::int desc;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
select *
from netflix
where to_date(date_added,'month dd,yyyy') >= current_date - interval '5 years';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
--exact match
select *
from netflix 
where director = 'Rajiv Chilaka';

--approx match
select *
from netflix 
where director like '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons and take count of it

```sql
with new_table
as
(
	select
        * ,
        split_part(duration,' ',1)as seasons
	from netflix
	where type = 'TV Show'
	and split_part(duration,' ',1) :: numeric > 5
	order by 2 desc
)  
select count(*) as count_of_season from num;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
select
    unnest(string_to_array(listed_in,',')) as gener,
    count(*)as total_gener
from netflix
group by 1;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
select
	extract(year from to_date(date_added,'month dd,yyyy')) as year ,
	count(*) as total_count,
	round(
            count(*) ::numeric/ (select count(*) from netflix where country= 'India')::numeric * 100,
        2) as avg_content_percent
from netflix
where  country = 'India'
group by 1;

```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
select *
from netflix
where listed_in like '%Documentaries%'
and type = 'Movie';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
select *
from netflix
where director is null;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
select *
from netflix
where release_year > extract(year from current_date ) - 10
and type = 'Movie'
and casts like '%Salman Khan%';
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
select
    unnest(string_to_array(casts,',')) as actors,
    count(*) as total_content
from netflix
where country ilike '%India'
group by 1
order by 2 desc
limit 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
with new_table
as 
(
	select 
		*,
		case
			when description ilike '%kill' or description ilike '%violence%'
			then 'Bad_content'
			else 'Good_content'
		end category
	from netflix
)
select category,count(*) as total_content
from  new_table
group by 1;
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

### 16. Top 3 most rated movies with year (consider ur has highest rating)

```sql
select
    release_year,
    type,
    title,
    rating
from netflix
where type = 'Movie'
and rating  = (select max(rating) from netflix) ;
```

**Objective:** assumption of highest rating ur getting released year and the movie name  
### 17. which movie has logest duration in the whole content

```sql
-- first find max duration 

select max(split_part(duration,' ', 1)::numeric) from netflix;

-- filter max duration through where clause

select
    title,
    duration
from netflix
where duration = '312 min';
```

**Objective:** Find the movie with the longest duration.

### 18. how many movies/TV Shows released between 2010 to 2021rds

```sql
select count(*) as total_movies
from netflix
where release_year between  2010 and 2021;
```

**Objective:** Find the count of movie and tv Shows for a particular year.

### 19. Count of movies for each year

```sql
select
    release_year ,
    count(*) as count_movies
from netflix
where type = 'Movie'
group by 1
order by 2 desc
```

**Objective:** Getting total count for each year.

### 20. In which year maximum production made
```sql
select
    release_year ,
    count(*)as production_of_content
from netflix
group by 1
order by 2 desc
limit 1;
```

**Objective:** Getting maximum production among all years.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.


 

Thank you for your support, and I look forward to connecting with you!
