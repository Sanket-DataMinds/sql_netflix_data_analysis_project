-- netflix project

create table netflix(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

select * from netflix;

select count(*) from netflix;

-- business problems

-- 1. Count the number of Movies vs TV Shows
-- 2. Find the most common rating for movies and TV shows
-- 3. List all movies released in a specific year (e.g., 2020)
-- 4. Find the top 5 countries with the most content on Netflix
-- 5. Identify the longest movie
-- 6. Find content added in the last 5 years
-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
-- 8. List all TV shows with more than 5 seasons
-- 9. Count the number of content items in each genre
-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
-- 11. List all movies that are documentaries
-- 12. Find all content without a director
-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.
-- 16. Top 5 most rated movies in 2021
-- 17. which movie has logest duration in the whole content
-- 18. how many movies released between 2010 to 2021
-- 19. count of movies for each year
-- 20. In which year maximum production made

select * from netflix

--  1. Count the number of Movies vs TV Shows;
 
select type , count(*) as count 
from netflix
group by type;

-- 2. Find the most common rating for movies and TV shows

select * from
(
	select type,rating, count(*) as total,
	rank() over(partition by type order by count(*) desc) as ranking 
	from netflix
	group by type,rating
	order by count(*) desc
) as t1 
where ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

select * from netflix
where release_year = 2020
and type  = 'Movie';

-- 4. Find the top 5 countries with the most content on Netflix

-- we have to split the list of string in a array
select unnest(string_to_array(country,',')) from netflix;

select  
	unnest(string_to_array(country,',')) , 
	count(*)
from netflix
group by 1
order by 2 desc
limit 5;

-- 5. Identify the longest movie

select * from netflix
where type = 'Movie'
	and 
	duration = (select max(duration) from netflix);

-- 6. Find content added in the last 5 years

select * from netflix
where to_date(date_added,'month dd,yyyy') >= current_date - interval '5 years';

 
-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
--exact match
select * from netflix 
where director = 'Rajiv Chilaka';

--approx
select * from netflix 
where director like '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons and tak count of it
with num
as(
	select * , duration
	from netflix
	where type = 'TV Show'
	and duration < '5 Seasons'
	order by 2 desc
)  
select count(*) from num;
-- or
select *, split_part(duration,' ',1)as seasons from netflix
where split_part(duration,' ',1) :: numeric >= 5
and type = 'TV Show';


-- 9. Count the number of content items in each genre
select unnest(string_to_array(listed_in,',')) as gener,count(*) from netflix
group by 1;

-- 10.Find each year and the average numbers of content release in India on netflix.
-- return top 5 year with highest avg content release!


select   from netflix;

total content = 333/927

select
	extract(year from to_date(date_added,'month dd,yyyy')) as year ,
	count(*),
	round(count(*) ::numeric/ (select count(*) from netflix where country= 'India')::numeric * 100,2) as avg_content_percent
from netflix
where  country = 'India'
group by 1;

-- 11. List all movies that are documentaries

select *,unnest(string_to_array(listed_in,',')) as gener from netflix
where  gener = 'documentaries';

select * from netflix
where listed_in like '%Documentaries%'
and type = 'Movie';


-- 12. Find all content without a director

select * from netflix
where director is null;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!


select * from netflix
where release_year > extract(year from current_date ) - 10
and type = 'Movie' and
casts like '%Salman Khan%';

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select unnest(string_to_array(casts,',')) as actors,
count(*) as total_content
from netflix
where country ilike '%India'
group by 1
order by 2 desc
limit 10;


-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.
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



-- 16. Top 3 most rated movies with year (consider ur has highest rating)

select release_year, type, title,rating
from netflix
where type = 'Movie' and
rating  = (select max(rating) from netflix) ;
 
-- 17. which movie has logest duration in the whole content

-- first find max duration 

select max(split_part(duration,' ', 1)::numeric) from netflix;

-- filter max duration through where clause
select title,duration
from netflix
where duration = '312 min';


-- 18. how many movies released between 2010 to 2021

select count(*)
from netflix
where release_year between  2010 and 2021;

-- 19. count of movies for each year

select release_year ,count(*)
from netflix
where type = 'Movie'
group by 1
order by 2 desc

-- 20 In which year maximum production made

select release_year ,count(*)as production_of_content
from netflix
group by 1
order by 2 desc
limit 1;

 
