---- Total trips

select count(distinct tripid) from trips 

--checking duplicate

select tripid, count(tripid) cnt from trips group by tripid having count(tripid) > 1


--total drivers
select count(distinct driverid) from trips

--total earning 
select sum(fare) fare from trips

-- driver earnings earnings
select driverid, sum(fare) Earnings from trips group by driverid

--total searches 
select sum(searches) searches from trips_details

-- total serches that got estimate
select sum(searches) searches from trips_details

-- 

--total driver cancelled
select count(*)-sum(driver_not_cancelled)  from trips_details

--total otp entered
select  sum(otp_entered)  from trips_details

--total end ride

select  sum(end_ride)  from trips_details

--cancelled bookings by driver
Select count(driver_not_cancelled) from trips_details where driver_not_cancelled =0 and customer_not_cancelled =1

--cancelled bookings by customer
Select count(driver_not_cancelled) from trips_details where driver_not_cancelled =0 and customer_not_cancelled =1


--average distance per trip

select avg(distance) from trips

-- average fare per distance 

select avg(fare) from trips


-- which is the most used payment method 
select p.method , a.cnt from payment p inner join
(select faremethod, count(faremethod) cnt from trips group by faremethod ) 
a on p.id= a.faremethod order by a.cnt desc
-- the highest payment was made through which instrument
select p.method , a.* from payment p inner join
(select top 1 * from trips order by fare desc
)a on p.id=a.faremethod
-- which two locations had the most trips

select *, dense_rank() over(order by trip desc) rnk from (
select loc_from, loc_to, count(distinct tripid) trip from trips group by loc_to, loc_from 
)a
--top 5 earning drivers
select top 5 * from
(select *, dense_rank() over (order by earn desc) rnk from
(select  driverid, sum(fare) earn from trips group by driverid
)b)c

-- which duration had more trips
select duration , rank() over (order by cnt desc)rnk from
(select duration , count( distinct tripid) cnt from trips group by 
duration)a


-- which driver , customer pair had more orders
select * from trips
select * from
(select driverid , custid , rank() over (order by trip desc) rnk from (
select driverid , custid, count(tripid) trip from trips group by driverid , custid
)a)b where rnk = 1
-- search to estimate rate

select  sum(searches_got_estimate)*100.0/sum(searches)  from trips_details 


-- estimate to search for quote rates


select  sum(searches_for_quotes)*100.0/sum(searches_got_estimate)  from trips_details 
-- quote acceptance rate


-- quote to booking rate


-- booking cancellation rate


-- conversion rate


-- which area got highest trips in which duration
select   duration , loc_from, cnt ,dense_rank() over(order by cnt desc) rnk    from 
(select duration,loc_from, count(distinct tripid) cnt from 
(
select a.duration , b.loc_from,  b.tripid from trips a inner join trips_details b 
on a.tripid=b.tripid
)a group by duration ,loc_from)b 


-- which area got the highest fares, cancellations,trips,
select * from trips

select *, DENSE_RANK() over(order by fare desc) rnk from (Select loc_from , sum (fare) fare from trips
group by loc_from)a

select *, DENSE_RANK() over(order by cnc desc) rnk from (Select loc_from , count(*)- sum(driver_not_cancelled)cnc from trips_details
group by loc_from)a


select *, DENSE_RANK() over(order by trips desc) rnk from (Select loc_from , count(*)trips from trips_details
group by loc_from)a


-- which duration got the highest trips and fares
select *, DENSE_RANK() over(order by trips desc) rnk from 
(Select duration , sum(fare) fare, count(distinct tripid) trips from trips
group by duration)a
