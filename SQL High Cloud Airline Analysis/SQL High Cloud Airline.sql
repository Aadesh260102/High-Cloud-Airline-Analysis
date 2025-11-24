-- STORED PROCEDUCE FOR DATE FUNCTION

DELIMITER //
create procedure Date_Function ()
Begin
with Date_table as (
select concat(Year,"-",`Month (#)`,"-",Day)as Date from maindata
)

select Date, year(Date) as Date,
month(Date) as Month_no,
monthname(Date) as month_name,
concat("Q",quarter(Date)) as Quarter,
date_format(Date,"%Y-%M") as Month_Year,
weekday(Date) as weekday_num,
DAYNAME(Date) as Weekday_Name,
case when month(Date) > 4 then  month(Date) -3 else month(Date) + 9 end as Financial_month,
case when quarter(Date)>1 then quarter(Date)-1 else quarter(Date)+3 end as Financial_Quarter
from Date_table;

END //
DELIMITER ;

CALL Date_Function();


# Find the load Factor percentage on a yearly , Quarterly , Monthly basis 
# ( Transported passengers / Available seats)
------------------------------------------------------------------------------------------------------
-- Yearly --
select Year, round((sum(`# Transported Passengers`)/sum(`# Available Seats`))*100,2) as 
Total_load_Factor from maindata group by Year;
--------------------------------------------------------------------------------------------------
-- monthly Load factor--
select `Month (#)`, 
round((sum(`# Transported Passengers`)/sum(`# Available Seats`))*100,2) as 
Total_load_Factor from maindata group by `Month (#)` order by `Month (#)`;
----------------------------------------------------------------------------------------------------
-- Quarterly Load_factor -- 
select 
 quarter(concat(Year,"-",`Month (#)`,"-",Day)) as Quarter ,
 round((sum(`# Transported Passengers`)/sum(`# Available Seats`))*100,2) as 
Total_load_Factor from maindata group by  Quarter order by Quarter;
--------------------------------------------------------------------------------------------------
-- Financial Quarter wise load Factor 
with Quarter_date  as (
select 
 quarter(concat(Year,"-",`Month (#)`,"-",Day)) as quarter_column,
 round((sum(`# Transported Passengers`)/sum(`# Available Seats`))*100,2) as Total_load_Factor 
from maindata group by quarter_column order by quarter_column
) 
select 
case when quarter_column >1 then quarter_column-1
else quarter_column + 3 end as Financial_Quarter,Total_load_Factor
from Quarter_date order by Financial_Quarter;

--------------------------------------------------------------------------------------------------
-- Load Factor percentage on a Carrier Name basis

select  `Carrier Name`, round((sum(`# Transported Passengers`)/sum(`# Available Seats`))*100,2) as Total_load_Factor 
from maindata group by `Carrier Name` order by Total_load_Factor desc
limit 10;

-- --------------------------------------------------------------------------------------------
-- Top 10 Carrier Based on Passenger Prefrence --

select `Carrier Name`,sum(`# Transported Passengers`) as No_Passenger from maindata
group by `Carrier Name` order by No_Passenger desc
limit 10;

-------------------------------------------------------------------------------------------------
-- Display top Routes ( from-to City) based on Number of Flights --

select `From - To City` ,count(`%Datasource ID`) as Number_Flight
from maindata group by `From - To City` order by Number_Flight desc;

-----------------------------------------------------------------------------------------------
-- weekend VS weekdays Load_Factor
with cte1 as(
select 
 weekday(concat(Year,"-",`Month (#)`,"-",Day)) as  week_day ,
 round((sum(`# Transported Passengers`)/sum(`# Available Seats`))*100,2) as Total_load_Factor
 from maindata group by week_day
)
select 
case when  week_day > 4 then "weekend" else "weekday" end as Weekend_vs_Weekdays
,round(avg(Total_load_Factor),2) as Load_factor from cte1 group by  Weekend_vs_Weekdays;

----------------------------------------------------------------------------
-- Identify number of flights based on Distance group --

select `%Distance Group ID`,count(`%Distance Group ID`) as NO_Flights
from maindata group by `%Distance Group ID` order by NO_Flights desc;

-- ---------------------------------------------------------------------------
 
 -- KPI --
select count(distinct `%Airline ID`) as NO_Airline from maindata;

select count(distinct `%Aircraft Type ID`) as NO_Airline from maindata;

select count(distinct`Origin Country Code`) as No_Country,
count(distinct`Origin State`) as No_State,
count(distinct `Origin City`) as No_City,
concat(round(sum(`# Transported Passengers`)/1000000,2)," M") as Total_Passenger,
concat(round(sum(Distance)/1000000,2)," M") as Total_Distance,
count(distinct `%Region Code`) as Operating_region 
from maindata;



