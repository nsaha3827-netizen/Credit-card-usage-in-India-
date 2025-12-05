-- 1 at first i create a data base where for analysis
CREATE DATABASE linkdin;
USE linkdin;
-- Load the data
SELECT * FROM credit;
-- 2 now want to find if there is any missing or null values
SELECT 
    
    SUM(CASE WHEN City IS NULL THEN 1 END) AS city_nulls,
    SUM(CASE WHEN Date IS NULL THEN 1 END) AS date_nulls,
    SUM(CASE WHEN `Card Type` IS NULL THEN 1 END) AS cardtype_nulls,
    SUM(CASE WHEN 'Exp Type' IS NULL THEN 1 END) AS exptype_nulls,
    SUM(CASE WHEN Gender IS NULL THEN 1 END) AS gender_nulls,
    SUM(CASE WHEN Amount IS NULL THEN 1 END) AS amount_nulls
FROM credit;
-- there is no null values

-- if there any dublicated columns *
SELECT 
    City,
    Date,
    `Card Type`,
    `Exp Type`,
    Gender,
    Amount,
    COUNT(*) AS duplicate_count
FROM
    credit
GROUP BY City , Date , `Card Type` , `Exp Type` , Gender , Amount
HAVING COUNT(*) > 1;
-- no dublicated values *

--  total number of transaction *
SELECT 
    COUNT(`index`) AS total_number_of_transaction
FROM
    credit;
-- transaction in different cities *
SELECT 
    Users_from_cities,
    COUNT(Users_from_cities) AS Number_of_transaction
FROM
    (SELECT 
        LEFT(City, INSTR(City, ',') - 1) AS Users_from_cities
    FROM
        credit) AS d
GROUP BY Users_from_cities ORDER BY Number_of_transaction DESC LIMIT 10;

-- number of distinct cities 
SELECT COUNT(DISTINCT(LEFT(City,INSTR(City,',')-1))) as Number_of_cities FROM credit;

-- types of cards that users use during transaction and average amount *
SELECT 
    `Card Type`,
    COUNT(*) AS Total_number_of_transaction,
    ROUND(AVG(Amount), 1) AS Average_amount
FROM
    Credit
GROUP BY `Card Type`
ORDER BY Total_number_of_transaction DESC;

-- For what purpose use their cards and average amount
SELECT `Exp Type`,COUNT(*) AS Number_of_times,ROUND(AVG(Amount),1) As Average_amount FROM Credit GROUP BY `Exp Type` ORDER BY Number_of_times DESC;

-- gender distribution *
SELECT 
    Gender,
    ROUND(COUNT(*) / (SELECT 
                    COUNT(`index`)
                FROM
                    credit) * 100,
            1) AS Percentager_of_customer,
    ROUND(AVG(Amount), 1) AS Average_amount
FROM
    credit
GROUP BY Gender
ORDER BY Percentager_of_customer DESC;

-- highest amount transaction made my people *
SELECT 
    City, Date, `Card Type`, `Exp Type`, Gender, Amount
FROM
    credit
ORDER BY Amount DESC
LIMIT 10;

-- average amount per transaction
SELECT ROUND(AVG(Amount),1) as Average_amount FROM credit;

-- top 10 cities and there total amount of transaction *
SELECT 
    LEFT(City, INSTR(City, ',') - 1) AS City,
    COUNT(LEFT(City, INSTR(City, ',') - 1)) AS Total_number_of_Transaction,
    ROUND(SUM(Amount), 1) AS sum_amount
FROM
    credit
GROUP BY City
ORDER BY sum_amount DESC
LIMIT 10;

-- types of cards and  that is used in each city *************
SELECT 
    City,
    `Card Type`,
    COUNT(*) AS Number_of_Use
FROM credit
GROUP BY City, `Card Type`
ORDER BY City ASC, Number_of_Use DESC;

-- Different cards and there top 2 most number of use *
SELECT `Card Type`,City,Number_of_use_of_cards 
FROM 
(SELECT `Card Type`,City,COUNT(*) AS 'Number_of_use_of_cards',
ROW_NUMBER() OVER(PARTITION BY `Card Type` ORDER BY COUNT(*) DESC) AS rn 
FROM credit GROUP BY `Card Type`,city) AS d WHERE RN<=2;

-- most frequent purpose for using cards *
SELECT 
    `Exp Type`, COUNT(*) AS Number_of_uses
FROM
    credit
GROUP BY `Exp Type`
ORDER BY Number_of_uses DESC;

-- preferance of cards gender wise *
SELECT Gender,`Card Type` FROM 
(SELECT Gender,`Card Type`,COUNT(*) as Total_number,
ROW_NUMBER() OVER(PARTITION BY Gender ORDER BY COUNT(*) DESC) AS rn 
FROM credit GROUP BY Gender,`Card Type`) AS d WHERE rn=1;

-- most use of cards for traveling *
SELECT `Card Type`,COUNT(*) AS Uses,ROUND(AVG(Amount),1) AS Average_amount FROM credit WHERE `Exp Type`='Travel' GROUP BY `Card Type` ORDER BY Uses DESC;
-- most use of cards for Entertainment *
SELECT `Card Type`,COUNT(*) AS Uses,ROUND(AVG(Amount),1) AS Average_amount FROM credit WHERE `Exp Type`='Entertainment' GROUP BY `Card Type` ORDER BY Uses DESC;
-- most use of cards for Bills *
SELECT `Card Type`,COUNT(*) AS Uses,ROUND(AVG(Amount),1) AS Average_amount FROM credit WHERE `Exp Type`='Bills' GROUP BY `Card Type` ORDER BY Uses DESC;
-- most use of cards for food; *
SELECT `Card Type`,COUNT(*) AS Uses,ROUND(AVG(Amount),1) AS Average_amount FROM credit WHERE `Exp Type`='Food' GROUP BY `Card Type` ORDER BY Uses DESC;
-- most use of cards for Fuel;
SELECT `Card Type`,COUNT(*) AS Uses,ROUND(AVG(Amount),1) AS Average_amount FROM credit WHERE `Exp Type`='Fuel' GROUP BY `Card Type` ORDER BY Uses DESC;

-- in whcih city people use the most amount for travelling
SELECT City,SUM(Amount) AS Amount_use_for_travelling FROM credit WHERE `Exp Type`='Travel' GROUP BY City ORDER BY Amount_use_for_travelling DESC LIMIT 10;
-- in whcih city people use the most amount for Entertainment;
SELECT City,SUM(Amount) AS Amount_use_for_entertainment FROM credit WHERE `Exp Type`='Entertainment' GROUP BY City ORDER BY Amount_use_for_entertainment DESC LIMIT 10;
-- in whcih city people use the most amount for bills;
SELECT City,SUM(Amount) AS Amount_use_for_bill FROM credit WHERE `Exp Type`='Bills' GROUP BY City ORDER BY Amount_use_for_bill DESC LIMIT 10;
-- in whcih city people use the most amount for food;
SELECT City,SUM(Amount) AS Amount_use_for_food FROM credit WHERE `Exp Type`='Food' GROUP BY City ORDER BY Amount_use_for_food DESC LIMIT 10;
-- in whcih city people use the most amount for fuel;
SELECT City,SUM(Amount) AS Amount_use_for_fuel FROM credit WHERE `Exp Type`='Fuel' GROUP BY City ORDER BY Amount_use_for_fuel DESC LIMIT 10;

-- top 10 cities and there card preferencee
WITH top_cities AS (
    SELECT City, COUNT(*) AS total_usage
    FROM credit
    GROUP BY City
    ORDER BY total_usage DESC
    LIMIT 10
),
city_card_usage AS (
    SELECT 
        City,
        `Card Type`,
        COUNT(*) AS Number_of_use,
        ROW_NUMBER() OVER(
            PARTITION BY City
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM credit
    WHERE City IN (SELECT City FROM top_cities)
    GROUP BY City, `Card Type`
)

SELECT City, `Card Type`, Number_of_use
FROM city_card_usage
WHERE rn <= 2      -- top 2 preference per city
ORDER BY City, Number_of_use DESC;

-- date wise
SELECT STR_TO_DATE(Date, '%d-%b-%y') AS formatted_date
FROM credit;
-- update the data format
UPDATE credit
SET Date = STR_TO_DATE(Date, '%d-%b-%y');
-- again load
SELECT 
    *
FROM
    Credit;
-- Month wise Transaction
SELECT 
    MONTH(Date) AS Month, COUNT(*) AS Number_of_transaction
FROM
    credit
GROUP BY Month
ORDER BY Number_of_transaction;

-- Yearly wise Transaction
SELECT 
    YEAR(Date) AS Year, COUNT(*) AS Number_of_transaction
FROM
    credit
GROUP BY Year
ORDER BY Number_of_transaction;

-- top cities and there top 2 most trafic months
SELECT City,Month FROM 
(SELECT City,MONTH(Date) AS Month,COUNT(*) AS total_number,ROW_NUMBER() OVER(PARTITION BY City 
ORDER BY COUNT(*) DESC) as rn FROM 
Credit WHERE City IN 
(SELECT City FROM 
(SELECT City,COUNT(*) FROM Credit GROUP BY City LIMIT 4) AS D) 
 GROUP BY City,Month) as g WHERE rn<=3; 