-- Selecting Airbnb Database for use--
use air_bnb_db;

-- Check total rows--
select count(*) from nola_listings;

-- Reviewing all data --
select * from nola_listings;


-- Checking for Duplicates --
select
	id,
	count(id)
from 
nola_listings
group by id
having count(id) = 1
order by 1 desc;

-- Removed any Listing without a price per night--

DELETE FROM nola_listings
WHERE
    price = 0;


-- Removed Naval Base Listing --
DELETE FROM nola_listings
WHERE
    neighbourhood_cleansed = 'U.S. Naval Base';
    
-- Modify ID Column to capture all numbers in ID --
ALTER TABLE nola_listings
MODIFY COLUMN ID BIGINT;


-- Queries Utilized for Tableau Dashboard --

-- Top 10 Host By Listing Volume--

select
	host_id,
    	host_name,
    	count(id) as listing_count
from
nola_listings
group by host_id, host_name
order by 3 desc
limit 10;

-- Average Price For 1-5 Bedrooms and Studio--
select
	case when bedrooms = 0 then 'Studio/Bedrooms Not Listed' else bedrooms end as bedrooms,
    	round(avg(price),0) as avg_price_per_night
from
nola_listings
where bedrooms in (1, 2, 3, 4, 5,'Studio/Bedrooms Not Listed')
group by 1
order by 2 asc;

-- Top 10 Areas with Highest Avg Price Per Night--
select
	neighbourhood_cleansed as neighborhood,
    	round(avg(price),0) as avg_price,
    	count(id) as number_of_listings
from
nola_listings
group by 1
order by 2 desc
limit 10;

-- Neighborhoods with Highest Projected Monthly Revenue--
with projected_revenue as
			(select id,
				host_id,
                        	neighbourhood_cleansed AS neighborhood,
                        	price * (30 - availability_30) as projected_30_day_revenue,
                        	id as listing_id
			from nola_listings
                    	order by projected_30_day_revenue desc)
select
    neighborhood,
    sum(projected_30_day_revenue) as monthly_projected_revenue,
    count(listing_id) as total_listings
from projected_revenue
group by neighborhood
order by 2 desc
limit 10;

-- Avg price per neighborhood--
with neighborhood_price as 
			(select
				neighbourhood_cleansed as neighborhood,
    				round(avg(price),0) as avg_price,
    				count(*) as number_of_listings
			from
			nola_listings
			group by 1
			order by 2 desc)

select
	np.neighborhood,
	nl.latitude,
    	nl.longitude,
    	np.avg_price,
    	np.number_of_listings
from neighborhood_price np
	join
nola_listings nl on np.neighborhood = nl.neighbourhood_cleansed
order by 4 desc;


-- Additional Queries --

-- Occupancy Rate By Neighborhood--
with occ_rate as
		(select id,
			host_id,
                        neighbourhood_cleansed as neighborhood,
                        30 - availability_30 as booked_days,
                        price * (30 - availability_30) as projected_30_day_revenue
		from nola_listings
                order by booked_days desc)
select
    neighborhood,
    round(avg(booked_days),2) as avg_booked_days,
    round(avg(booked_days)/30 ,2)* 100 as occupancy_rate,
    sum(projected_30_day_revenue) as monthly_projected_revenue,
    count(id) as number_of_listings
from occ_rate
group by neighborhood
order by 3 desc;

-- Occupancy Rate of Top 10 Revenue Generating Neighborhoods--
with occ_rate as
		(select id,
			host_id,
                        neighbourhood_cleansed as neighborhood,
                        30 - availability_30 as booked_days,
                        price * (30 - availability_30) as projected_30_day_revenue
		from nola_listings
                order by booked_days desc)
select
    neighborhood,
    round(avg(booked_days),2) as avg_booked_days,
    round(avg(booked_days)/30 ,2)* 100 as occupancy_rate,
    sum(projected_30_day_revenue) as monthly_projected_revenue,
    count(id) as number_of_listings
from occ_rate
group by neighborhood
order by 4 desc
limit 10;


-- Ratings by Neighborhood with listings between 100 and 500 --
select
	neighbourhood_cleansed as neighborhood,
    	round(avg(review_scores_cleanliness),2) as cleanliness_rating,
    	round(avg(review_scores_location),2) as location_Rating,
    	round(avg(review_scores_value),2) as value_Rating,
    	round((avg(review_scores_cleanliness) + avg(review_scores_location) + avg(review_scores_value))/3,2) as overall_rating,
    	count(*) as total_listings
from nola_listings
group by neighborhood
having total_listings > 99 and total_listings < 501
order by 5 desc;

-- Ratings by Neighborhood with all total listings--
select
	neighbourhood_cleansed as neighborhood,
    	round(avg(review_scores_cleanliness),2) as cleanliness_rating,
    	round(avg(review_scores_location),2) as location_Rating,
    	round(avg(review_scores_value),2) as value_Rating,
    	round((avg(review_scores_cleanliness) + avg(review_scores_location) + avg(review_scores_value))/3,2) as overall_rating,
    	count(*) as total_listings
from nola_listings
group by neighborhood
order by 5 desc;
