

Select * From station
Select * From Status
Select * From trip
Select * From weather

--For each given location/city, how many docks were installed
Select City, count(name) As No_of_Station, Sum(Dock_Count) As No_Dock, ROUND(SUM(dock_count)/COUNT(name), 2) AS avr_station_capacity from station
Group by City
Order by No_Dock desc, avr_station_capacity 

---Per city and date, what is the dock and station count?
Select City, installation_date, Sum(Dock_Count) As Dock_Count, count(id) As Station_Count from station
Group by City, installation_date

Select installation_date,
	CASE
	WHEN installation_date = '2013-08-01 00:00:00.000' THEN 'AUG13'
	WHEN installation_date > '2013-08-01 00:00:00.000'THEN 'after_AUG13'
    ELSE 'before_AUG13' END AS installation_date,
	SUM(Dock_count) AS dock_ct,
    SUM(station_count) AS station_ct
FROM (SELECT DATE(installed_date, 'start of month') as month,
                 Dock_count, 
                 station_count
FROM station 

 SELECT CASE 
        WHEN month = '2013-08-01 00:00:00.000'
        THEN 'AUG13'
        WHEN month > '2013-08-01 00:00:00.000'
        THEN 'after_AUG13'
        ELSE 'before_AUG13'
        END AS installation_month,
        SUM(Dock_count) AS dock_ct,
        SUM(station_count) AS station_ct
    FROM (SELECT DATE(installed_date, 'start of month') as month,
                 total_dock_ct, 
                 station_count
         FROM t1
         ) AS innerquery
    GROUP BY 1;




--- Number of trips started in each station

Select s.name, count(t.start_station_id) as No_Start_Trip from station as s
left join trip as t 
on s.id = t.start_station_id
group by s.name
order by No_Start_Trip desc


---No of trips started and ended per City
Select DISTINCT a.city, a.Tot_City_Start, b.Tot_City_End
From
(Select s.city, s.id, count(t.start_station_id) as Tot_City_Start from Station as S
inner join trip as t
on s.id = t.start_station_id
group  by s.city, s.id
)a 
inner join
(Select DISTINCT s.city, t.start_station_id, count(t.end_station_id) as Tot_City_End from Station as S
inner join trip as t
on s.id = t.end_station_id
group  by s.city, start_station_id) b
on a.id=b.start_station_id
Group by a.city, a.Tot_City_Start, b.Tot_City_End

Select s.City, 
	Count(CASE WHEN s.city = 'San Jose' THEN t.start_station_id END) as San_Jose_Trips,
	Count(CASE WHEN s.city = 'Mountain View' THEN t.start_station_id END) as Mountain_View_Trips,
	Count(CASE WHEN s.city = 'Redwood City' THEN t.start_station_id END) as Redwood_City_Trips,
	Count(CASE WHEN s.city = 'Palo Alto' THEN t.start_station_id END) as Palo_Alto_Trips,
	Count(CASE WHEN s.city = 'San Francisco' THEN t.start_station_id END) as San_Francisco_Trips
from station as s
inner join trip as t
on s.id = t.start_station_id
group by s.city

-- Total Trip Per Station
 Select name, count(t.start_station_id) as No_Start_Trip, count(t.end_station_id) As No_End_Trip, (count(t.start_station_id) + count(t.end_station_id)) as Total_Trip  from station as a
 left join trip as t
 On a.id = t.start_station_id
 group by name
 order by Total_Trip Desc


 ---How Much Percentage Does Subs/Cus. Represent In Each Station ?
----Subscription Type:  How Many Subs/Cus. Are Per Station?

Select a.start_station_name, a.No_of_Subscribers, b.No_of_Customers, b.No_of_Customers*100/(a.No_of_Subscribers + b.No_of_Customers) as Cust_Percent, a.No_of_Subscribers*100/(a.No_of_Subscribers + b.No_of_Customers) as Sub_Percent
	From
	(
	Select start_station_name, count(Subscription_type) as No_of_Subscribers from trip 
	where Subscription_type  = 'subscriber'
	group by start_station_name
	--Order by No_of_Subscribers desc
	) a
	inner join
	(
	Select start_station_name, count(Subscription_type) as No_of_Customers from trip 
	where Subscription_type like '%CUS%' 
	group by start_station_name
	--Order by No_of_Customers desc
	) b
	on a.start_station_name = b.start_station_name
	group by a.start_station_name, a.No_of_Subscribers, b.No_of_Customers
	Order by start_station_name desc

	---- using Case when 
Select t.start_station_name,
	COUNT(CASE WHEN subscription_type = 'Subscriber' THEN start_station_id END) as Sub_ct,
	COUNT(CASE WHEN subscription_type = 'Customer' THEN start_station_id END) as Cut_ct,
	(SELECT COUNT(start_station_id) FROM trip) as Total_trips,
	--(SELECT COUNT(start_station_id) FROM trip as t1 WHERE t.start_station_id = t1.start_station_id) as Total_trips   
    COUNT(CASE WHEN subscription_type='Subscriber' THEN start_station_id END)*100/COUNT(start_station_id) Sub_percent,
    COUNT(CASE WHEN subscription_type='Customer' THEN start_station_id END)*100/COUNT(start_station_id) Cus_percent
FROM trip AS t
GROUP BY t.start_station_name
Order by start_station_name desc

---Average trip to taken by subscribers and customers

Select avg(Sub_ct) as Avg_Sub_ct, avg(Cut_ct) As Avg_Cut_ct
	from
	(
	Select start_station_name,
		COUNT(CASE WHEN subscription_type = 'Subscriber' THEN start_station_id END) as Sub_ct,
		COUNT(CASE WHEN subscription_type = 'Customer' THEN start_station_id END) as Cut_ct
	FROM trip t
	GROUP BY start_station_name) as Subquery

-- End location of some stations with 5 highest starting point

select start_station_name, start_station_id, count(start_station_id) as start_count  from trip
group by start_station_name, start_station_id
order by start_count desc

Select start_station_name,
	Count(CASE WHEN end_station_id = '70' THEN end_station_name END) as SFC_Townsd,
	Count(CASE WHEN end_station_id = '50' THEN end_station_name END) as Harry_Bridge,
	Count(CASE WHEN end_station_id = '60' THEN end_station_name END) as Embar_San,
	Count(CASE WHEN end_station_id = '77' THEN end_station_name END) as Market_Sansome
from trip
group by start_station_name




Select * From station
Select * From Status
Select * From trip
Select * From weather


Select continent, sum(total_cases) As Tot_case From CovidDeaths group by continent order by Tot_case


