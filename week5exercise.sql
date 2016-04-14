/* week 5 exercise
-- Exercise 1. How many distinct dates are there in the saledate column of the transaction
-- table for each month/year combination in the database?
the following quesry will give the mnth in number format as 1-12 */

SELECT EXTRACT(MONTH FROM saledate) as month_num, EXTRACT(YEAR FROM saledate) as year_num, COUNT(DISTINCT saledate)
FROM trnsact t
GROUP BY year_num, month_num
ORDER BY year_num, month_num;

/* Exercise 2. Use a CASE statement within an aggregate function to determine which sku
had the greatest total sales during the combined summer months of June, July, and August. */

SELECT sku, SUM(CASE WHEN EXTRACT(MONTH from saledate)=6
THEN amt
END) AS rev_Jun,
SUM(CASE WHEN EXTRACT(MONTH from saledate)=7 
THEN amt
END) AS rev_Jul,
SUM(CASE WHEN EXTRACT(MONTH from saledate)=8 AND EXTRACT(YEAR from saledate)=2004
THEN amt
END) AS rev_Aug, rev_Jun+rev_jul+rev_Aug as total_summer_revenue
FROM trnsact t
GROUP BY sku
ORDER BY total_summer_revenue DESC;

/*Exercise 3. How many distinct dates are there in the saledate column of the transaction
table for each month/year/store combination in the database? Sort your results by the
number of days per combination in ascending order.*/

SELECT EXTRACT(MONTH from saledate) AS m_num, EXTRACT(YEAR from saledate) AS y_num, store, COUNT(DISTINCT(saledate)) AS num_day
FROM trnsact
GROUP BY m_num, y_num, store
ORDER BY num_day ASC;


/*Exercise 4. What is the average daily revenue for each store/month/year combination in
the database? Calculate this by dividing the total revenue for a group by the number of
sales days available in the transaction table for that group.*/

SELECT CASE WHEN EXTRACT(MONTH from saledate)=8 AND EXTRACT(YEAR from saledate)=2005
THEN 1 
ELSE 0
END AS exclude,
store, EXTRACT(MONTH from saledate) AS m_num, EXTRACT(YEAR from saledate) AS y_num, SUM(amt)/COUNT(DISTINCT saledate) AS adr
FROM trnsact
WHERE stype='P' AND exclude=0
GROUP BY m_num, y_num, store
ORDER BY store, y_num, m_num
;


/* Method 1 USING HAVING statement removing bad data*/
SELECT CASE WHEN EXTRACT(MONTH from saledate)=8 AND EXTRACT(YEAR from saledate)=2005
THEN 1 
ELSE 0
END AS exclude,
store, EXTRACT(MONTH from saledate) AS m_num, EXTRACT(YEAR from saledate) AS y_num, COUNT(DISTINCT saledate) AS num_saleDays, SUM(amt)/num_saleDays AS adr
FROM trnsact
WHERE stype='P' AND exclude=0 
GROUP BY m_num, y_num, store
HAVING num_saleDays>=20
ORDER BY store, y_num, m_num
;


/*Q5- removing bad data USing subquery method*- need to be checked*/

SELECT *
FROM (SELECT CASE WHEN EXTRACT(MONTH from saledate)=8 AND EXTRACT(YEAR from saledate)=2005
THEN 1 
ELSE 0
END AS exclude, store, EXTRACT(MONTH from saledate) AS m, EXTRACT(YEAR from saledate) AS y, COUNT(DISTINCT saledate) AS sd, SUM(amt)/sd AS adr
FROM trnsact t
WHERE stype='P' AND exclude=0
GROUP BY store, y, m ) AS t1
WHERE sd>=20
ORDER BY store, y, m;


/*Exercise 5. What is the average daily revenue brought in by Dillard’s stores in areas of
high, medium, or low levels of high school education?*/
-- adding education level to store_msa table
SELECT edu_level, COUNT(DISTINCT saledate) AS sd, SUM(amt)/sd AS adr 
FROM  (SELECT t.store, CASE 
WHEN msa_high>=50 AND msa_high<60 THEN 'Low'
WHEN msa_high>=60 AND msa_high<70 THEN 'Medium'
ELSE 'High'
END AS edu_level, 
CASE WHEN EXTRACT(MONTH from saledate)=8 AND EXTRACT(YEAR from saledate)=2005
THEN 1 
ELSE 0
END AS exclude, stype, saledate, amt
FROM store_msa s, trnsact t
WHERE s.store=t.store 
AND stype='P'
AND exclude=0) AS t1
GROUP BY edu_level
ORDER BY adr DESC;

/* Exercise 6. Compare the average daily revenues of the stores with the highest median
msa_income and the lowest median msa_income. In what city and state were these stores,
and which store had a higher average daily revenue? */

SELECT store, city, state, req_store, SUM(amt)/COUNT (DISTINCT saledate) AS adr
FROM (SELECT t.store, city, state, saledate,
CASE WHEN EXTRACT(MONTH from saledate)=8 AND EXTRACT(YEAR from saledate)=2005
THEN 1 
ELSE 0
END AS exclude, 
CASE WHEN msa_income=(SELECT MAX(msa_income) FROM store_msa) THEN 'max_income_store'
WHEN msa_income=(SELECT MIN(msa_income) FROM store_msa) THEN 'min_income_store' 
ELSE NULL
END AS req_store, amt
FROM store_msa s, trnsact t
WHERE s.store=t.store 
AND stype='P'
AND exclude=0
AND req_store IS NOT NULL) as t1
GROUP BY store, city, state, req_store;


/*Exercise 7: What is the brand of the sku with the greatest standard deviation in sprice?
Only examine skus that have been part of over 100 transactions.*/
SELECT TOP 1 t.sku, brand, STDDEV_SAMP(sprice) as deviation, SUM(orgprice)/num_of_trn as Avg_org_price, COUNT(trannum) as num_of_trn
FROM trnsact t, skuinfo s
WHERE t.sku=s.sku
HAVING COUNT(trannum)>100
GROUP BY t.sku, brand
ORDER BY deviation DESC;


/* Examine all the transactions for the sku with the greatest standard deviation in
sprice, but only consider skus that are part of more than 100 transactions.*/
SELECT * FROM
(SELECT TOP 1 t.sku, brand, STDDEV_SAMP(sprice) as deviation, COUNT(trannum) as num_of_trn
FROM trnsact t, skuinfo s
WHERE t.sku=s.sku
HAVING COUNT(trannum)>100
GROUP BY t.sku, brand
ORDER BY deviation DESC) as t1, trnsact t
WHERE t.sku=t1.sku
ORDER BY orgprice DESC;

/*Exercise 9: What was the average daily revenue Dillard’s brought in during each month of
the year?
Adapt the query you wrote in Exercise 4 to answer this question.*/

SELECT CASE WHEN EXTRACT(MONTH from saledate)=8 AND EXTRACT(YEAR from saledate)=2005
THEN 1 
ELSE 0
END AS exclude,
EXTRACT(MONTH from saledate) AS m_num, EXTRACT(YEAR from saledate) AS y_num, SUM(amt)/COUNT(DISTINCT saledate) AS adr
FROM trnsact
WHERE stype='P' AND exclude=0
GROUP BY m_num, y_num
ORDER BY y_num, m_num
;

/*Exercise 10: Which department, in which city and state of what store, had the greatest %
increase in average daily sales revenue from November to December?*/

SELECT TOP 1 d.dept, deptdesc, city, state, t.store,
SUM(CASE WHEN EXTRACT(MONTH from saledate)=11
THEN amt
END) AS rev_Nov, 
SUM(CASE WHEN EXTRACT(MONTH from saledate)=12
THEN amt
END) AS rev_Dec,
COUNT(DISTINCT (CASE WHEN EXTRACT(MONTH from saledate)=11
THEN saledate
END) )AS Nov_saleDays, 
COUNT(DISTINCT(CASE WHEN EXTRACT(MONTH from saledate)=12
THEN saledate
END)) AS Dec_saleDays, rev_Nov/Nov_saleDays AS n_adr, rev_Dec/Dec_saleDays AS d_adr, ((d_adr-n_adr)/n_adr)*100 AS percent_sale_increase
FROM trnsact t, store_msa sm, skuinfo s, deptinfo d
WHERE t.sku=s.sku 
AND s.dept=d.dept
AND t.store=sm.store
AND stype='P'
HAVING (Nov_saleDays>=20 AND Dec_saleDays>=20)
GROUP BY d.dept, deptdesc, city, state, t.store
ORDER BY percent_sale_increase DESC;


/*Exercise 11: What is the city and state of the store that had the greatest decrease in
average daily revenue from August to September?*/

SELECT TOP 1 d.dept, deptdesc, city, state, t.store,
SUM(CASE WHEN EXTRACT(MONTH from saledate)=8
THEN amt
END) AS rev_Aug, 
SUM(CASE WHEN EXTRACT(MONTH from saledate)=9
THEN amt
END) AS rev_Sep,
COUNT(DISTINCT (CASE WHEN EXTRACT(MONTH from saledate)=8
THEN saledate
END) )AS Aug_saleDays, 
COUNT(DISTINCT(CASE WHEN EXTRACT(MONTH from saledate)=9
THEN saledate
END)) AS Sep_saleDays, rev_Aug/Aug_saleDays AS a_adr, rev_Sep/Sep_saleDays AS s_adr, (a_adr-s_adr) AS sale_decrease
FROM trnsact t, store_msa sm, skuinfo s, deptinfo d
WHERE t.sku=s.sku 
AND s.dept=d.dept
AND t.store=sm.store
AND stype='P'
HAVING (Aug_saleDays>=20 AND Sep_saleDays>=20)
GROUP BY d.dept, deptdesc, city, state, t.store
ORDER BY percent_sale_increase DESC;


/*Exercise 12: Determine the month of maximum total revenue for each store. Count the
number of stores whose month of maximum total revenue was in each of the twelve
months. Then determine the month of maximum average daily revenue. Count the
number of stores whose month of maximum average daily revenue was in each of the
twelve months. How do they compare?*/

SELECT * FROM (SELECT CASE WHEN EXTRACT(MONTH from saledate)=8 AND EXTRACT(YEAR from saledate)=2005
THEN 1 
ELSE 0
END AS exclude,
store, EXTRACT(MONTH from saledate) AS m_num, EXTRACT(YEAR from saledate) AS y_num, SUM(amt)/COUNT(DISTINCT saledate) AS adr, ROW_NUMBER() OVER (PARTITION BY store ORDER BY adr DESC) AS m_rank
FROM trnsact
WHERE stype='P' AND exclude=0
GROUP BY m_num, y_num, store) AS t1
WHERE m_rank=1
;

-- Count the number of stores whose month of maximum total revenue was in each of the twelve months
SELECT COUNT(*) AS month_12 FROM (SELECT CASE WHEN EXTRACT(MONTH from saledate)=8 AND EXTRACT(YEAR from saledate)=2005
THEN 1 
ELSE 0
END AS exclude,
store, EXTRACT(MONTH from saledate) AS m_num, EXTRACT(YEAR from saledate) AS y_num, SUM(amt) AS total_rev, ROW_NUMBER() OVER (PARTITION BY store ORDER BY adr DESC) AS m_rank
FROM trnsact
WHERE stype='P' AND exclude=0
GROUP BY m_num, y_num, store) AS t1
WHERE m_rank=1 AND m_num=12
;


-- month of maximum average daily revenue. 
SELECT TOP 1 CASE WHEN EXTRACT(MONTH from saledate)=8 AND EXTRACT(YEAR from saledate)=2005
THEN 1 
ELSE 0
END AS exclude, EXTRACT(MONTH from saledate) AS m_num, EXTRACT(YEAR from saledate) AS y_num, SUM(amt)/COUNT(DISTINCT saledate) AS adr
FROM trnsact
WHERE stype='P' AND exclude=0
GROUP BY m_num, y_num
ORDER BY m_num DESC

-- Count the number of stores whose month of maximum average daily revenue was in each of the twelve months. How do they compare?
SELECT COUNT(*) AS month_12 FROM (SELECT CASE WHEN EXTRACT(MONTH from saledate)=8 AND EXTRACT(YEAR from saledate)=2005
THEN 1 
ELSE 0
END AS exclude,
store, EXTRACT(MONTH from saledate) AS m_num, EXTRACT(YEAR from saledate) AS y_num, SUM(amt)/COUNT(DISTINCT saledate) AS adr, ROW_NUMBER() OVER (PARTITION BY store ORDER BY adr DESC) AS m_rank
FROM trnsact
WHERE stype='P' AND exclude=0
GROUP BY m_num, y_num, store) AS t1
WHERE m_rank=1 AND m_num=12
;
