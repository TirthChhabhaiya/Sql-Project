SELECT * FROM cafe;


CREATE TABLE cafe_index 
LIKE cafe;
insert cafe_index 
select * from cafe;

select * from cafe_index;
-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways

-- 1. Remove Duplicates

# First let's check for duplicates

select cash_type,card,money,coffee_name,`date`,`datetime`,  
row_number()over(partition by cash_type,card,money,coffee_name,`date`,`datetime`) as row_num
from cafe_index;

select * from
(
select cash_type,card,money,coffee_name,`date`,  
row_number()over(partition by cash_type,card,money,coffee_name,`date`) as row_num
from cafe_index
) duplicates 
where row_num > 1 ;

-- let's just look at Americano to confirm
select * from cafe_index where coffee_name = 'Americano';

-- it looks like these are all legitimate entries and shouldn't be deleted. We need to really look at every single row to be accurate
-- these are our real duplicates 
select * from
(
select cash_type,card,money,coffee_name,`date`,  
row_number()over(partition by cash_type,card,money,coffee_name,`date`) as row_num
from cafe_index
) duplicates 
where row_num > 1 ;

-- these are the ones we want to delete where the row number is > 1 or 2or greater essentially
-- now you may want to write it like this:
WITH DELETE_CTE AS
(select * from
(
select cash_type,card,money,coffee_name,`date`,  
row_number()over(partition by cash_type,card,money,coffee_name,`date`) as row_num
from cafe_index
) duplicates 
where row_num > 1
)
DELETE
FROM DELETE_CTE
;

-- one solution, which I think is a good one. Is to create a new column and add those row numbers in. Then delete where row numbers are over 2, then delete that column
-- so let's do it!!
alter table cafe_index add row_num INT;
alter table cafe_index drop column row_num ;

CREATE TABLE `index`.`cafe2` (
  `date` text,
  `datetime` text,
  `cash_type` text,
  `card` text,
  `money` double DEFAULT NULL,
  `coffee_name` text,
  row_num int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

drop table cafe2;
select * from cafe2;

INSERT INTO `index`.`cafe2` 
(`date`,
`datetime`, 
`cash_type`,
`card`,
`money`,
`coffee_name`, 
`row_num`)
SELECT `date`,
`datetime`,
`cash_type`,
`card`,
CAST(`money` AS DECIMAL(10,2)),
`coffee_name`, 
ROW_NUMBER() OVER (PARTITION BY cash_type, card, money, coffee_name, `date`) AS row_num 
FROM `index`.`cafe_index`;

SELECT * FROM cafe2 WHERE row_num > 1 AND row_num <= 4;
-- now that we have this we can delete rows were row_num is greater than 2
delete FROM cafe2
WHERE row_num >= 2;


-- 2. Standardize Data

select * from cafe2;
 
 -- we sholud check blank space and null values
SELECT *
FROM cafe2
WHERE card IS NULL 
OR card = ''
ORDER BY card;

-- we should set the blanks to nulls since those are typically easier to work with
UPDATE cafe2
SET card = NULL
WHERE card= '';

SELECT *
FROM cafe2
WHERE card IS NULL 
ORDER BY card;

-- we can use str to date to update this field
UPDATE cafe2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

select * from cafe2;

-- 3. Look at Null Values

-- the null values in card all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase

-- so there isn't anything I want to change with the null values


-- 4. remove any columns and rows we need to
select * from cafe2
where card is  null 
or card = ''
order by card;

delete  from cafe2
where card is  null 
or card = ''
order by card;

alter table cafe2
drop  column row_num;

select * from cafe2;

select coffee_name from cafe2 
order by coffee_name;

-- EDA

-- Here we are jsut going to explore the data and find trends or patterns or anything interesting like outliers

-- normally when you start the EDA process you have some idea of what you're looking for

-- with this info we are just going to look around and see what we find!

select * from cafe2;

-- which coffee order more in cafe
 select coffee_name,max(money),sum(money) from cafe2
 group by coffee_name
 order by 2 desc;
 -- after total or sum money that cafe sold latte more them other coffe

-- now we check most sales coffe sold by cafe
SELECT YEAR(date), SUM(money),max(coffee_name)
FROM cafe2
GROUP BY YEAR(date)
ORDER BY 1 ASC;
 -- useing where claues we can aslo check last year most sales coffe sold by cafe
SELECT YEAR(date), SUM(money),max(coffee_name)
FROM cafe2
where YEAR(date) = 2023
GROUP BY YEAR(date)
ORDER BY 1 ASC;


 -- we aslo check how much total sales done by cafe in day
SELECT DATE(date) AS sale_date, SUM(money) AS total_sales
FROM cafe2
WHERE DATE(date) = '2024-06-03'
GROUP BY DATE(date);

-- we aslo check how much total sales and coffe was sold  by cafe in day
SELECT DATE(date) AS sale_date, coffee_name, SUM(money) AS total_sales
FROM cafe2
WHERE DATE(date) = '2024-06-03'
GROUP BY DATE(date), coffee_name
ORDER BY sale_date, coffee_name
LIMIT 0, 1000;


select * from cafe2;



 
