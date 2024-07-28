select * from employee_demographics;
select * from employee_salary;

select  first_name , last_name , gender
 from employee_demographics;
 
 select distinct  first_name,gender from employee_demographics;
 
 select * from employee_salary
 where salary >= '50000';
 
 SELECT *
FROM employee_demographics
WHERE gender = 'Female';

#We can use WHERE clause with date value also
SELECT *
FROM employee_demographics
WHERE birth_date > '1985-01-01';

-- Here '1990-01-01' is the default data formate in MySQL.
-- There are other date formats as well that we will talk about in a later lesson.

# LIKE STATEMENT

-- two special characters a % and a _

-- % means anything
SELECT *
FROM employee_demographics
WHERE first_name LIKE 'a%';

-- _ means a specific value
SELECT *
FROM employee_demographics
WHERE first_name LIKE 'a__';


SELECT *
FROM employee_demographics
WHERE first_name LIKE 'a___%';