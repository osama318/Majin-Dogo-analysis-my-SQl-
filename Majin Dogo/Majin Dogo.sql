SHOW TABLES;


SELECT * FROM employee;


SELECT province_name, position
FROM employee;

SELECT DISTINCT type_of_water_source
FROM water_source;

SELECT *
FROM visits
WHERE time_in_queue >500;

SELECT  *
FROM water_source
WHERE source_id IN ('AkKi00881224' ,'SoRu37635224','SoRu36096224');

SELECT *
FROM water_quality
WHERE subjective_quality_score =10 
AND visit_count =2;

SELECT * 
FROM well_pollution 
WHERE results='Clean'
AND biological >0.01;

SELECT  *
FROM well_pollution
WHERE description LIKE 'Clean%';



 SET SQL_SAFE_UPDATES=0;
 Update well_pollution 
 SET description ='Bacteria: E. coli'
 Where description = `Clean Bacteria: E. coli`;
 
 UPDATE well_pollution
 SET description = 'Bacteria: E. coli'
 WHERE description = 'Clean Bacteria: E. coli';
 
  UPDATE well_pollution_copy
 SET results = 'Contaminated: Biological'
 WHERE biological > 0.01 AND results = 'Clean';
 
 
 
 set sql_safe_updates =0;
use md_water_services;
select * from employee;

-- first_name.last_name@ndogowater.gov.
update employee
set  email=concat(lower(REPLACE(employee_name,' ','.')),'@ndogowater.gov');

SELECT *
fROM employee;



SELECT length(phone_number)
FROM employee;

UPDATE employee
SET phone_number= TRIM(phone_number);

SELECT phone_number ,length(phone_number)
FROM employee;


SELECT count(*) SUM_OF_EMPLYEES,town_name
FROM employee
group by town_name;


-- GET THE TOP PERFORMERS WHO MADE VISITS
SELECT assigned_employee_id,
	   count(*) AS NUMBER_OF_VISITS
 FROM visits
 group by assigned_employee_id
 order by NUMBER_OF_VISITS DESC
 LIMIT 3;
 
 SELECT E.employee_name,E.assigned_employee_id,count(V.visit_count) AS NUMBER_OF_VISITS
 FROM employee E
 INNER join visits V
 ON E.assigned_employee_id=V.assigned_employee_id
 GROUP by E.assigned_employee_id
 order by NUMBER_OF_VISITS DESC
 LIMIT 3;
 
 
-- COUNT NUMBER OF RECORDS PER TOWN
SELECT *
FROM location;

SELECT town_name, COUNT(*) AS RECORD_PER_TOWN
FROM location
group by town_name
ORDER BY RECORD_PER_TOWN;

-- CREATE RESULTSET(SUMMARY)
SELECT town_name,province_name, COUNT(*) AS NUMBER_OF_RECORDS
FROM location
group by town_name,province_name
order by province_name ASC,NUMBER_OF_RECORDS DESC;


-- NUBER OF RECORDS PER EACH LOCATION TYPE
SELECT location_type ,COUNT(*) AS NUMBER_OF_RECORDS
FROM location 
GROUP BY location_type;

SELECT province_name , COUNT(*) AS RECORD_PER_TOWN
FROM location
group by province_name
ORDER BY RECORD_PER_TOWN DESC;

-- WATER SOURCES
SELECT *
FROM water_source;

SELECT SUM(number_of_people_served) AS NUMBER_OF_PEOPLE_SERVED
FROM water_source;

SELECT count(*) AS NUMBER_OF_WATER_SOURCES,type_of_water_source
FROM water_source
group by type_of_water_source;

SELECT type_of_water_source,
ROUND(avg(number_of_people_served),0) AS AVG_NUMBER_OF_PEOPLE_SHARED
FROM water_source
group by type_of_water_source;

SELECT sum(number_of_people_served) NUMBER_OF_PEOPLE_GET_WATER,type_of_water_source
FROM water_source
group by type_of_water_source
order by  NUMBER_OF_PEOPLE_GET_WATER DESC;


-- GIVING A RANK OF WATER SOURCES FOR REPAIRING THEM
WITH TOTAL_PROPLE_PER_SOURCE AS(
SELECT type_of_water_source,
sum(number_of_people_served) AS POPULATION_SERVED
FROM water_source
WHERE type_of_water_source !='tap_in_home'
group by type_of_water_source)

SELECT type_of_water_source,
		POPULATION_SERVED,
        round((POPULATION_SERVED/27000000) *100,0) AS PERCENTEGE_IN_TOTAL,
        rank() OVER(order by POPULATION_SERVED desc) AS SOURCE_RANK
FROM TOTAL_PROPLE_PER_SOURCE
order by SOURCE_RANK ;

WITH RANK_SOURCE AS (
SELECT source_id,type_of_water_source,number_of_people_served,
ROW_NUMBER() OVER(PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC) AS PRIORITY_RANK
FROM water_source
WHERE type_of_water_source IN ('shared_tap','river','well')
)
select type_of_water_source,source_id,number_of_people_served, PRIORITY_RANK
from RANK_SOURCE
order by type_of_water_source,PRIORITY_RANK;


-- analyzing queues
select   
round (avg(nullif(time_in_queue,0)),0) as avg_time_in_queue
from visits;


select min(time_of_record) as start_date,
		max(time_of_record) as end_date,
		DATEDIFF(max(time_of_record),min(time_of_record)) AS DURATION_TIME
 FROM visits;       
 
 -- AVG TIME IN QUEUE IN DAYS 
select dayname(time_of_record) AS DAY_OF_WEEK,
Round (avg(nullif(time_in_queue,0)),0) as avg_time_in_queue
from visits
group by dayname(time_of_record)
order by field(DAY_OF_WEEK,'SATURDAY','SUNDAY','MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY'
);

-- AVG TIME IN QUEUE IN HOURS 
SELECT time_format(time(time_of_record),'%H:00:00') AS HOURS_OF_DAY,
Round (avg(nullif(time_in_queue,0)),0) as avg_time_in_queue
FROM visits
GROUP BY HOURS_OF_DAY
ORDER BY HOURS_OF_DAY;
 
SELECT time_format(time(time_of_record),'%H:00:00') AS HOURS_OF_DAY,
dayname(time_of_record) AS DAY_OF_WEEK,
case 
WHEN dayname(time_of_record) THEN time_in_queue
else NULL
END AS AVG_TIME_IN_QUEUE
FROM visits
WHERE time_in_queue !=0;



SELECT time_format(time(time_of_record),'%H:00:00') AS HOURS_OF_DAY,

-- Sunday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END
),0) AS Sunday,
-- Monday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END
),0) AS Monday,

-- Tuesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
ELSE NULL
END
),0) AS Tuesday,

-- Wednesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
ELSE NULL
END
),0) AS Wednesday,

-- THURSDAY
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'THURSDAY' THEN time_in_queue
ELSE NULL
END
),0) AS  THURSDAY,
-- FRIDAY
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'FRIDAY' THEN time_in_queue
ELSE NULL
END
),0) AS  FRIDAY
FROM visits
WHERE time_in_queue != 0 
GROUP BY HOURS_OF_DAY
ORDER BY HOURS_OF_DAY;

select *
from auditor_report;

--  compare between AUDITOR_SCORE and SSURVEYOR_SCORE without duplicates
SELECT AR.location_id AS AUDIT_LOCATION, 
		AR.true_water_source_score AS AUDITOR_SCORE,
        WQ.subjective_quality_score AS SSURVEYOR_SCORE,
        V.record_id AS VISITS_ALLOCATION
FROM auditor_report AR 
INNER JOIN VISITS V 
ON AR.location_id=V.location_id
INNER JOIN water_quality WQ 
ON WQ.record_id=V.record_id      
WHERE AR.true_water_source_score !=WQ.subjective_quality_score
AND WQ.visit_count=1;

-- RECOGNIZE THE EMPLOYEES WHO MADE THE WRONG SCORES
WITH INCORRECT_RECORDS AS (

SELECT AR.location_id AS AUDIT_LOCATION, 
		E.employee_name,
		AR.true_water_source_score AS AUDITOR_SCORE,
        WQ.subjective_quality_score AS SSURVEYOR_SCORE,
        V.record_id AS VISITS_ALLOCATION
FROM auditor_report AR 
INNER JOIN VISITS V 
ON AR.location_id=V.location_id
INNER JOIN water_quality WQ 
ON WQ.record_id=V.record_id     
INNER JOIN employee E 
ON E.assigned_employee_id=V.assigned_employee_id
WHERE AR.true_water_source_score !=WQ.subjective_quality_score
AND WQ.visit_count=1)

select *
FROM INCORRECT_RECORDS;



-- RECOGNIZE THE EMPLOYEES WHO MADE THE WRONG SCORES
WITH INCORRECT_RECORDS AS (

SELECT AR.location_id AS AUDIT_LOCATION, 
		E.employee_name,
		AR.true_water_source_score AS AUDITOR_SCORE,
        WQ.subjective_quality_score AS SSURVEYOR_SCORE,
        V.record_id AS VISITS_ALLOCATION
FROM auditor_report AR 
INNER JOIN VISITS V 
ON AR.location_id=V.location_id
INNER JOIN water_quality WQ 
ON WQ.record_id=V.record_id     
INNER JOIN employee E 
ON E.assigned_employee_id=V.assigned_employee_id
WHERE AR.true_water_source_score !=WQ.subjective_quality_score
AND WQ.visit_count=1)


SELECT employee_name,
COUNT(*) AS NUMBER_OF_MISTAKES
FROM INCORRECT_RECORDS
GROUP BY employee_name
order by NUMBER_OF_MISTAKES DESC;

with  INCORRECT_RECORDS AS (

SELECT AR.location_id AS AUDIT_LOCATION, 
		E.employee_name,
        AR.statements,
		AR.true_water_source_score AS AUDITOR_SCORE,
        WQ.subjective_quality_score AS SSURVEYOR_SCORE,
        V.record_id AS VISITS_ALLOCATION
FROM auditor_report AR 
INNER JOIN VISITS V 
ON AR.location_id=V.location_id
INNER JOIN water_quality WQ 
ON WQ.record_id=V.record_id     
INNER JOIN employee E 
ON E.assigned_employee_id=V.assigned_employee_id
WHERE AR.true_water_source_score !=WQ.subjective_quality_score
AND WQ.visit_count=1),

 COUNT_MISTAKES AS (

SELECT employee_name,
COUNT(*) AS NUMBER_OF_MISTAKES
FROM INCORRECT_RECORDS
GROUP BY employee_name)

SELECT avg(NUMBER_OF_MISTAKES) as avg_number_of_mistakes 
from COUNT_MISTAKES;


WITH INCORRECT_RECORDS AS (

SELECT AR.location_id AS AUDIT_LOCATION, 
		E.employee_name,
		AR.true_water_source_score AS AUDITOR_SCORE,
        WQ.subjective_quality_score AS SSURVEYOR_SCORE,
        V.record_id AS VISITS_ALLOCATION
FROM auditor_report AR 
INNER JOIN VISITS V 
ON AR.location_id=V.location_id
INNER JOIN water_quality WQ 
ON WQ.record_id=V.record_id     
INNER JOIN employee E 
ON E.assigned_employee_id=V.assigned_employee_id
WHERE AR.true_water_source_score !=WQ.subjective_quality_score
AND WQ.visit_count=1),


COUNT_MISTAKES AS (

SELECT employee_name,
COUNT(*) AS NUMBER_OF_MISTAKES
FROM INCORRECT_RECORDS
GROUP BY employee_name)


select employee_name,
NUMBER_OF_MISTAKES
from COUNT_MISTAKES
where NUMBER_OF_MISTAKES> (select avg(NUMBER_OF_MISTAKES) as avg_number_of_error
from COUNT_MISTAKES);


WITH INCORRECT_RECORDS AS (  
    SELECT 
        AR.location_id AS AUDIT_LOCATION,    
        E.employee_name,   
        AR.true_water_source_score AS AUDITOR_SCORE,         
        WQ.subjective_quality_score AS SSURVEYOR_SCORE,         
        V.record_id AS VISITS_ALLOCATION 
    FROM auditor_report AR  
    INNER JOIN VISITS V  ON AR.location_id = V.location_id 
    INNER JOIN water_quality WQ  ON WQ.record_id = V.record_id      
    INNER JOIN employee E  ON E.assigned_employee_id = V.assigned_employee_id 
    WHERE AR.true_water_source_score != WQ.subjective_quality_score 
    AND WQ.visit_count = 1
) 
SELECT * FROM INCORRECT_RECORDS; 



-- TO KNOW PROVINCES AND TOWNS THAT HAVE SOURCES MORE ABDUNDANT 
SELECT ws.type_of_water_source,ws.number_of_people_served,
		l.province_name,l.town_name,l.location_type,v.time_in_queue,wp.results
FROM  visits v
left join well_pollution wp
on wp.source_id =v.source_id
inner join location l 
on l.location_id=v.location_id
inner join water_source ws
on ws.source_id=v.source_id
-- this condition to ignore multiple locations that were visited
 where v.visit_count =1;
 
 /* So this table contains the data we need for this analysis. Now we want to analyse the data in the results set. 
 We can either create a CTE, and then query it, or in my case, I'll make it a VIEW so it is easier to share with you.
  I'll call it the combined_table.*/
  create view  combined_table as
  SELECT ws.type_of_water_source,ws.number_of_people_served,
		l.province_name,l.town_name,l.location_type,v.time_in_queue,wp.results
FROM  visits v
left join well_pollution wp
on wp.source_id =v.source_id
inner join location l 
on l.location_id=v.location_id
inner join water_source ws
on ws.source_id=v.source_id
-- this condition to ignore multiple locations that were visited
 where v.visit_count =1;
 
WITH province_totals AS (
    SELECT province_name, SUM(number_of_people_served) AS total_pop_served
    FROM combined_table  group by province_name)





select ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
round (sum((case when type_of_water_source='tap_in_home'
then number_of_people_served else 0 end )*100 /pt.total_pop_served),0) as percentege_in_tap_in_home ,
round (sum((case when type_of_water_source='tap_in_home_broken'
then number_of_people_served else 0 end )*100 /pt.total_pop_served),0) as percentege_in_tap_in_home_broken,
round (sum((case when type_of_water_source='well'
then number_of_people_served else 0 end )*100 /pt.total_pop_served),0) as percentege_in_well,
round (sum((case when type_of_water_source='shared_tap'
then number_of_people_served else 0 end )*100 /pt.total_pop_served),0) as percentege_in_shared_tap,
round (sum((case when type_of_water_source='river'
then number_of_people_served else 0 end )*100 /pt.total_pop_served),0) as percentege_in_river
from combined_table ct 
join province_totals pt
on ct.province_name=pt.province_name
group by ct.province_name
order by ct.province_name desc;
  

 /*this CTE calculates the population of each town
Since there are two Harare towns, we have to group by province_name and town_name*/
WITH town_totals AS (SELECT province_name, town_name, SUM(number_of_people_served) AS total_pop_served
FROM combined_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
round (sum((case when type_of_water_source='tap_in_home'
then number_of_people_served else 0 end )*100 /tt.total_pop_served),0) as percentege_in_tap_in_home ,
round (sum((case when type_of_water_source='tap_in_home_broken'
then number_of_people_served else 0 end )*100 /tt.total_pop_served),0) as percentege_in_tap_in_home_broken,
round (sum((case when type_of_water_source='well'
then number_of_people_served else 0 end )*100 /tt.total_pop_served),0) as percentege_in_well,
round (sum((case when type_of_water_source='shared_tap'
then number_of_people_served else 0 end )*100 /tt.total_pop_served),0) as percentege_in_shared_tap,
round (sum((case when type_of_water_source='river'
then number_of_people_served else 0 end )*100 /tt.total_pop_served),0) as percentege_in_river
FROM
combined_table ct
 /*Since the town names are not unique, we have to join on a composite key*/
 JOIN town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
 /*We group by province first, then by town.*/
GROUP BY ct.province_name,ct.town_name
ORDER BY tt.province_name,
ct.town_name;


CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (SELECT province_name, town_name, SUM(number_of_people_served) AS total_pop_served
FROM combined_table
GROUP BY province_name,town_name
)
SELECT
ct.province_name,
ct.town_name,
round (sum((case when type_of_water_source='tap_in_home'
then number_of_people_served else 0 end )*100 /tt.total_pop_served),0) as percentege_in_tap_in_home ,
round (sum((case when type_of_water_source='tap_in_home_broken'
then number_of_people_served else 0 end )*100 /tt.total_pop_served),0) as percentege_in_tap_in_home_broken,
round (sum((case when type_of_water_source='well'
then number_of_people_served else 0 end )*100 /tt.total_pop_served),0) as percentege_in_well,
round (sum((case when type_of_water_source='shared_tap'
then number_of_people_served else 0 end )*100 /tt.total_pop_served),0) as percentege_in_shared_tap,
round (sum((case when type_of_water_source='river'
then number_of_people_served else 0 end )*100 /tt.total_pop_served),0) as percentege_in_river
FROM
combined_table ct
 /*Since the town names are not unique, we have to join on a composite key*/
 JOIN town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
 /*We group by province first, then by town.*/
GROUP BY ct.province_name,ct.town_name
ORDER BY tt.province_name,
ct.town_name;
-- each broken tap by province and town using temporary table 
SELECT
province_name,
town_name,
ROUND(percentege_in_tap_in_home / (percentege_in_tap_in_home_broken + percentege_in_tap_in_home) *100,0) AS Pct_broken_taps

FROM town_aggregated_water_access;


/*We need to know if the repair is complete, and the date it was
completed, and give them space to upgrade the sources.*/
CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
Address VARCHAR(50),
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50),
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
Date_of_completion DATE,
Comments TEXT
);

SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
well_pollution.results
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id;

/*This query identifies water source improvements based on contamination results and type of water source.*/
select LOC.address,
LOC.province_name,
LOC.town_name,
WS.source_id,
wp.results,
WS.type_of_water_source,

case 
when wp.results='Contaminated: Chemical' then 'install Ro filter'
WHEN wp.results='Contaminated: Biological' then 'install UV AND Ro filter'
WHEN WS.type_of_water_source='river' THEN 'DRILL WELL'
WHEN WS.type_of_water_source='shared_tap' AND V.time_of_record>=30
THEN concat('INSTALL' ,FLOOR(V.time_of_record>=30),'TAPSS NEARBY')
WHEN WS.type_of_water_source='tap_in_home_broken' THEN 'DIAGNOSE LOCAL INFRASTRUCTURE'
ELSE NULL
END AS IMPROVMENTS

FROM water_source WS 
LEFT JOIN well_pollution wp 
on wp.source_id=WS.source_id
INNER JOIN visits V 
ON V.source_id =WS.source_id
inner JOIN location LOC
ON V.location_id=LOC.location_id
WHERE V.visit_count=1
AND(wp.results !='Clean' 
OR WS.type_of_water_source IN ('river' ,'tap_in_home_broken')
OR WS.type_of_water_source='shared_tap'
AND V.time_of_record>=30);


 