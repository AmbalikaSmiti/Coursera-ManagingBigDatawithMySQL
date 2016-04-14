-- week 5 graded quiz
-- Q.1 How many distinct skus have the brand “Polo fas”, and are either size “XXL” or “black” in color?

SELECT COUNT(DISTINCT(sku))
FROM skuinfo
WHERE brand='Polo fas'
AND (size='XXl' OR color='black')
-- Ans: 13623

/* Q2. There was one store in the database which had only 11 days in one of its months (in other words, that store/month/year combination only contained 11 days of transaction data). 
In what city and state was this store located? */

SELECT t.store, city, state, EXTRACT(MONTH FROM saledate) as month_num, EXTRACT(YEAR FROM saledate) as y_num, COUNT(DISTINCT saledate) as num_sd
FROM trnsact t, store_msa s
WHERE t.store=s.store
GROUP BY t.store, city, state, y_num, month_num
HAVING num_sd=11;

-- OR

SELECT DISTINCT t.store, s.city, s.state

FROM trnsact t JOIN strinfo s

ON t.store=s.store

WHERE t.store IN (SELECT days_in_month.store

FROM(SELECT EXTRACT(YEAR from saledate) AS sales_year,

EXTRACT(MONTH from saledate) AS sales_month, store, COUNT (DISTINCT saledate) as numdays

FROM trnsact

GROUP BY sales_year, sales_month, store

HAVING numdays=11) as days_in_month)
-- Ans: Atlanta, GA

/* Q3. Which sku number had the greatest increase in total sales revenue from November to December?
*/
SELECT sku, 
SUM(CASE WHEN EXTRACT(MONTH from saledate)=11 THEN amt END) AS rev_Nov,
SUM(CASE WHEN EXTRACT(MONTH from saledate)=12 THEN amt END) AS rev_Dec, 
(rev_Dec-rev_Nov) AS increase_in_rev 
FROM trnsact
WHERE stype='P'
GROUP BY sku
ORDER BY  increase_in_rev DESC;

-- OR

SELECT sku,

sum(case when extract(month from saledate)=11 then amt end) as November,

sum(case when extract(month from saledate)=12 then amt end) as December,

December-November AS sales_bump

FROM trnsact

WHERE stype='P'

GROUP BY sku

ORDER BY sales_bump DESC;
-- Ans:3949538

/* Q4. What vendor has the greatest number of distinct skus in the transaction table that do not exist in the skstinfo table? 
(Remember that vendors are listed as distinct numbers in our data set).
*/

SELECT vendor , COUNT(DISTINCT sku) AS sku_count
FROM skuinfo s, trnsact t
WHERE s.sku=t.sku AND NOT EXISTS
(SELECT * FROM skstinfo si
WHERE t.sku=si.sku)
GROUP BY vendor
ORDER BY sku_count DESC


/* 5. What is the brand of the sku with the greatest standard deviation in sprice? Only examine skus which have been part of over 100 transactions.
*/
SELECT t.sku, brand, STDDEV_SAMP(sprice) AS dev, COUNT(trannum) AS tr
FROM trnsact t, skuinfo s
WHERE t.sku=s.sku
GROUP BY t.sku, brand
HAVING tr>100
ORDER BY dev DESC;
-- Ans: 


/* Q6. What is the city and state of the store which had the greatest increase in average daily revenue 
(as I define it in Teradata Week 5 Exercise Guide) from November to December? */
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


/*Q7. Compare the average daily revenue (as I define it in Teradata Week 5 Exercise Guide) of the store 
with the highest msa_income and the store with the lowest median msa_income (according to the msa_income field). 
In what city and state were these two stores, and which store had a higher average daily revenue? */


/*Q8.Divide the msa_income groups up so that msa_incomes between 1 and 20,000 are labeled 'low', 
msa_incomes between 20,001 and 30,000 are labeled 'med-low', 
msa_incomes between 30,001 and 40,000 are labeled 'med-high', and 
msa_incomes between 40,001 and 60,000 are labeled 'high'. 
Which of these groups has the highest average daily revenue (as I define it in Teradata Week 5 Exercise Guide) per store? */


/*Q9.Divide stores up so that stores with msa populations between 1 and 100,000 are labeled 'very small', 
stores with msa populations between 100,001 and 200,000 are labeled 'small', stores with msa populations 
between 200,001 and 500,000 are labeled 'med_small', stores with msa populations between 500,001 and 1,000,000 are labeled 'med_large', 
stores with msa populations between 1,000,001 and 5,000,000 are labeled “large”, and 
stores with msa_population greater than 5,000,000 are labeled “very large”. 
What is the average daily revenue (as I define it in Teradata Week 5 Exercise Guide) for a store in a “very large” population msa? */

/*Q10. Which department in which store had the greatest percent increase in average daily sales revenue from November to December, 
and what city and state was that store located in? Only examine departments whose total sales were at least $1,000 in both November and December. */


/*Q11.  
Which department within a particular store had the greatest decrease in average daily sales revenue from August to September, 
and in what city and state was that store located? */

/*Q12. 
Identify the department within a particular store that had the greatest decrease innumber of items sold from August to September. 
How many fewer items did that department sell in September compared to August, and in what city and state was that store located? */

/*Q13.
For each store, determine the month with the minimum average daily revenue (as I define it in Teradata Week 5 Exercise Guide) . 
For each of the twelve months of the year, count how many stores' minimum average daily revenue was in that month. 
During which month(s) did over 100 stores have their minimum average daily revenue? */

/*Q14.Write a query that determines the month in which each store had its maximum number of sku units returned. 
During which month did the greatest number of stores have their maximum number of sku units returned? */

SELECT sku, m , units_returned
FROM
(SELECT sku, EXTRACT(MONTH from saledate) as m, COUNT(stype) AS units_returned, ROW_NUM() OVER (PARTITION BY store ORDER BY units_returned DESC) AS m_rank
FROM trnsact t
WHERE stype='R'
GROUP BY sku, m) AS t1
WHERE m_rank=1

