
-- Tech startup Case Study

-- create use case table 1

 drop table fct_events ;
 
    create table fct_events (
	event_id serial unique not NULL primary key ,
	event_name character varying(100), 
	event_type varchar (30),
	Timestamp varchar (30) ,
	context_page_path varchar,
	global_session_id serial unique not NULL
	)
  ;
  
  -- create use case table 2
   drop table dim_session_attributes ;
 
    create table dim_session_attributes (
	global_session_id serial unique not NULL primary key,
	user_id serial unique not NULL  ,
	session_start_Ts timestamp ,
	session_end_Ts timestamp ,
	session_start_device_category varchar (30),
	has_created_story BOOLEAN NOT NULL,
	has_shared_story BOOLEAN NOT NULL,
	has_viewed_resource BOOLEAN NOT NULL,
	has_started_training_course BOOLEAN NOT NULL,
	has_searched_funder_finder BOOLEAN NOT NULL
	)
	
	-- insert  data into table 1 
	
	insert into fct_events (event_name, event_type,Timestamp,context_page_path)
	values
	('left click search engine','click','3s','funder finder'),
	('type into search bar','typing','2s','funder finder'),
	('left click on funder finder link','click','1s','current page'),
	('left click on play button','click','.5s','Resources') 
	returning * 
	
	--insert  data in table 2 
	
	insert into dim_session_attributes (
		session_start_device_category,
		has_created_story,
		has_shared_story,
		has_viewed_resource,
		has_started_training_course,
		has_searched_funder_finder,
		session_start_Ts,
		session_end_Ts )	
		values
		('smart phone','no','no','yes','yes','yes','2022-05-03 09:13:46', '2022-05-03 09:25:41'),
		('tablet','no','no','no','no','yes','2022-03-06 11:13:59', '2022-03-06 13:25:21'),
		('PC','yes','yes','yes','yes','yes','2021-02-01 14:55:46', '2021-02-01 15:03:21'),
		('mobile','no','no','yes','no','yes','2021-03-01 19:21:46', '2021-03-01 19:29:21')
		RETURNING *

alter table dim_session_attributes


	select * from fct_events ;
	select * from dim_session_attributes ;
	
-- QUERY 1
-- what is the most used device to interact with our service
select session_start_device_category, count(session_start_device_category) as Value_Occurance
	from  dim_session_attributes 
	group by session_start_device_category 
	order by Value_Occurance desc
	limit 1;	

-- QUERY 2
-- find the most visited page on our app

select context_page_path, count(context_page_path) as Value_Occurance
from fct_events
group by context_page_path
order by Value_Occurance Desc
limit 1 ; 

-- QUERY 3
-- How many sessions on average are started daily 


	select count( distinct global_session_id)/count(distinct session_start_ts) as AverageDailySessions
	from dim_session_Attributes ;
	
-- QUERY 4	
-- How many events are there per session

Select
	count(distinct global_session_id) as distinct_sessions
	, count(distinct event_id) as distinct_events
	,  count(distinct event_id) / count(distinct global_session_id)  as events_per_session
From fct_events

-- QUERY 5
-- find the average time a user spends per session 

SELECT AVG(extract(minute from session_end_ts - session_start_ts)) as Session_time_in_Minutes 
	FROM dim_session_attributes ;

-- QUERY 6
-- What feature on our software do clients use the most?

-- Since PostgreSQL 9.4 there's the FILTER clause, which allows for a very concise query to count the true values: 
 -- I found this solution from : https://stackoverflow.com/questions/5396498/postgresql-sql-count-of-true-values
-- Using CTE to perform calculation on the aggregated column names

	with Most_Used_Feature as (
select count(*) filter (where has_created_story) as HasCreatedStory, -- counted the number of true rows 
count(*) filter (where has_shared_story) as has_shared_story,
count(*) filter (where has_searched_funder_finder) as Has_searched_funder_finder ,
count(*) filter (where has_started_training_course) as TC,
count(*) filter (where has_viewed_resource) AS VR
from dim_session_attributes
)
select greatest ( HasCreatedStory, has_shared_story, Has_searched_funder_finder, TC, VR -- Used greatest to count the highest value between 4 different columns
) 
from Most_Used_Feature


select has_created_story
from dim_session_attributes


