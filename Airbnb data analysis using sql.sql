CREATE DATABASE airbnb;
-- 1.Find the total number of available beds per hosts' nationality.
-- Output the nationality along with the corresponding total number of available beds.
---- Sort records by the total available beds in descending order.
use airbnb;
SELECT 
    h.host_id,
    h.nationality,
    SUM(a.n_beds) AS total_beds,
    DENSE_RANK() OVER (ORDER BY SUM(a.n_beds) DESC) AS rnk
FROM 
    airbnb_hosts h
INNER JOIN 
    airbnb_apartments a ON h.host_id = a.host_id
GROUP BY 
    h.host_id, h.nationality
ORDER BY 
    rnk;

---- 2 Rank each host based on the number of beds they have listed. The host with the most beds should be ranked 1 and the host with the least number of beds should be ranked last. Hosts that have the same number of beds should have the same rank but there should be no gaps between ranking values. A host can also own multiple properties.
--- Output the host ID, number of beds, and rank from highest rank to lowest group by nationality.avg
SELECT 
    h.host_id,
    h.nationality,
    SUM(a.n_beds) AS total_beds,
    DENSE_RANK() OVER (ORDER BY SUM(a.n_beds) DESC) AS rnk
FROM 
    airbnb_hosts h
INNER JOIN 
    airbnb_apartments a ON h.host_id = a.host_id
GROUP BY 
    h.host_id, h.nationality
ORDER BY 
    rnk;
    
--- 3.Rank guests based on their ages.
-- Output the guest id along with the corresponding rank.
--- Order records by the age in descending order.
SELECT 
    g.guest_id,
    g.age,
    (SELECT COUNT(*) 
     FROM airbnb_guests 
     WHERE age > g.age) + 1 AS `rank` 
FROM 
    airbnb_guests g 
ORDER BY 
    age DESC 
LIMIT 0, 50;
--- 4.--Rank guests based on the total number of messages they've exchanged with any of the hosts. Guests with the same number of messages as other guests should have the same rank. Do not skip rankings if the preceding rankings are identical.
--- Output the rank, guest id, and number of total messages they've sent. Order by the highest number of total messages first.
select id_guest, 
dense_rank() over (order by sum(n_messages) desc) as ranks, sum(n_messages) messages
from airbnb_contacts
group by id_guest
order by messages desc;

--- 5.Display the average number of times a user performed a search which led to a successful booking and the average number of times 
--- a user performed a search but did not lead to a booking. The output should have a column named action with values 'does not book' and
--- 'books' as well as a 2nd column named average_searches with the average number of searches per action. 
---- Consider that the booking did not happen if the booking date is null. 
------ Be aware that search is connected to the booking only if their check-in dates match.
SELECT CASE
           WHEN c.ts_booking_at IS NOT NULL AND c.ds_checkin = s.ds_checkin THEN 'books'
           ELSE 'does not book'
       END AS action,
       avg(n_searches) AS average_searches
FROM airbnb_searches s
LEFT JOIN (SELECT DISTINCT id_guest, ds_checkin, ts_booking_at FROM airbnb_contacts WHERE ts_booking_at IS NOT NULL) c ON s.id_user = c.id_guest AND s.ds_checkin = c.ds_checkin
GROUP BY action;

-- 6 Find the total number of searches for houses in Westlake neighborhood with a TV among the amenities.
SELECT 
   count(*) AS n_searches
FROM airbnb_search_details
WHERE 
    neighbourhood = 'Westlake' AND 
    property_type = 'House'    AND 
    amenities LIKE '%TV%';
    
-- 7.Find matching hosts and guests pairs in a way that they are both of the same gender and nationality.Output the host id and the guest id of matched pair.
SELECT DISTINCT 
    h.host_id, 
    g.guest_id 
FROM 
    airbnb_hosts h 
INNER JOIN 
    airbnb_guests g 
ON 
    h.nationality = g.nationality 
    AND h.gender = g.gender;
--- 8.Find the average age of guests reviewed by each host.
-- Output the user along with the average age.
SELECT
    from_user,
    AVG(age) AS average_age
  FROM airbnb_reviews AS r
  JOIN airbnb_guests AS g ON r.to_user = g.guest_id
 WHERE to_type = 'guest'
 GROUP BY from_user;
 
 --- 9.For each guest reviewer, find the nationality of the reviewer’s favorite host based on the guest’s highest review score given to
 --- a host. Output the user ID of the guest along with their favorite host’s nationality. In case there is more than one favorite host 
 --- from the same country, list that country only once (remove duplicates).Both the from_user and to_user columns are user IDs.
 
 SELECT DISTINCT t2.from_user, h.nationality
FROM (SELECT r.from_user, r.to_user, r.review_score
      FROM airbnb_reviews r
      INNER JOIN (SELECT from_user, MAX(review_score) AS max_s
                  FROM airbnb_reviews
                  WHERE from_type = 'guest'
                  GROUP BY 1) t1 on r.from_user = t1.from_user and r.review_score = t1.max_s
      WHERE r.from_type = 'guest') t2
INNER JOIN airbnb_hosts h on t2.to_user = h.host_id
ORDER BY t2.from_user;

-- 10.Write a query to find which gender gives a higher average review score when writing reviews as guests. Use the from_type column 
--- to identify guest reviews. Output the gender and their average review score.
SELECT  g.gender,
AVG(review_score) AS avg_score
FROM airbnb_reviews r
INNER JOIN airbnb_guests g ON r.from_user =g.guest_id
where r.from_type ='guest'
GROUP BY g.gender
ORDER BY avg_score DESC
LIMIT 1;






