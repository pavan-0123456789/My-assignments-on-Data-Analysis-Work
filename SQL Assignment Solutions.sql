## 1.QUESTION ##

# 1 (a):
use classicmodels;

SELECT EMPLOYEENUMBER,
       FIRSTNAME,
       LASTNAME
FROM EMPLOYEES
WHERE JOBTITLE = "SALES REP"
AND REPORTSTO = 1102;

# 1 (b):
SELECT DISTINCT PRODUCTLINE
FROM PRODUCTS
WHERE PRODUCTLINE LIKE "%CARS";

select * from products;

## 2.QUESTION ##

# 2 (a):
SELECT CUSTOMERNUMBER,
	   CUSTOMERNAME,
CASE WHEN COUNTRY IN ("USA","CANADA") THEN "NORTH AMERICA"
	 WHEN COUNTRY IN ("UK","FRANCE","GERMANY") THEN "EUROPE"
     ELSE "OTHER"
     END AS CUSTOMERSEGMENT
	FROM CUSTOMERS;
    
## QUESTION 3 ##
    
# 3 (a):
SELECT PRODUCTCODE,
SUM(QUANTITYORDERED) AS TOTAL_ORDERED
FROM ORDERDETAILS
GROUP BY PRODUCTCODE
ORDER BY TOTAL_ORDERED DESC
LIMIT 10;

# 3 (b):
SELECT MONTHNAME(PAYMENTDATE) AS PAYMENT_MONTH,
COUNT(*) AS NUM_PAYMENTS
FROM PAYMENTS
GROUP BY PAYMENT_MONTH
HAVING NUM_PAYMENTS >20
ORDER BY NUM_PAYMENTS DESC;

## QUESTION 4 ##

# 4 (a):
CREATE TABLE CUSTOMERS (CUSTOMER_ID  INT PRIMARY KEY AUTO_INCREMENT,
                        FIRST_NAME VARCHAR (50) NOT NULL,
                        LAST_NAME VARCHAR(50) NOT NULL,
						EMAIL VARCHAR(255) UNIQUE,
						PHONE_NUMBER VARCHAR(20)) ;

SELECT*FROM CUSTOMERS;

# 4 (b):
CREATE TABLE ORDERS (ORDER_ID INT PRIMARY KEY AUTO_INCREMENT,
					 CUSTOMER_ID INT ,
                     ORDER_DATE DATE,
                     TOTAL_AMOUNT DECIMAL(10,2),
FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS_ORDER(CUSTOMER_ID),
CONSTRAINT CHECK_TOTAL_AMOUNT CHECK (TOTAL_AMOUNT>0));
 
 select*from orders;
 
## QUESTION 5 ##
 
SELECT C.COUNTRY,
       COUNT(O.ORDERNUMBER) AS ORDER_COUNT
FROM CUSTOMERS AS C
INNER JOIN ORDERS AS O 
ON C.CUSTOMERNUMBER = O.CUSTOMERNUMBER
GROUP BY C.COUNTRY
ORDER BY ORDER_COUNT DESC
LIMIT 5;

## QUESTION 6 ##

CREATE TABLE PROJECT(EMPLOYEEID INT PRIMARY KEY AUTO_INCREMENT,
             FULLNAME VARCHAR(50) NOT NULL,
             GENDER ENUM("MALE","FEMALE"),
             MANAGERID INT );

INSERT INTO PROJECT (EMPLOYEEID,FULLNAME,GENDER,MANAGERID)VALUES
(1,"PRANAYA","MALE",3),
(2,"PRIYANKA" ,"FEMALE",1),
(3,"PREETY","FEMALE",NULL),
(4,"ANURAG","MALE",1),
(5,"SAMBIT","MALE",1),
(6,"RAJESH","MALE",3),
(7,"HINA","FEMALE",3);

SELECT*FROM PROJECT;

SELECT M.FULLNAME AS MANAGERNAME,
       E.FULLNAME AS EMPLOYEENAME
FROM PROJECT AS E
JOIN PROJECT AS M
ON 
E.MANAGERID = M.EMPLOYEEID
ORDER BY M.FULLNAME;

## QUESTION 7 ##

# 7 (a):
CREATE TABLE FACILITY(FACILITY_ID INT,
                     NAME VARCHAR(100),
                     STATE VARCHAR(100),
                     COUNTRY VARCHAR(100));
# 7 (a)(1):
ALTER TABLE FACILITY
MODIFY COLUMN FACILITY_ID INT PRIMARY KEY AUTO_INCREMENT;

SELECT *FROM FACILITY;

# 7 (a)(2):
ALTER TABLE FACILITY 
ADD COLUMN CITY VARCHAR(100) NOT NULL
AFTER NAME;

DESC FACILITY;

## QUESTION 8 ##

CREATE VIEW `product_category_sales` AS
    SELECT 
        pl.productLine AS PRODUCTLINE,
        SUM((od.quantityOrdered * od.priceEach)) AS TOTAL_SALES,
        COUNT(DISTINCT o.orderNumber) AS NUMBER_OF_ORDERS
    FROM
        (((productlines pl
        JOIN products AS p ON ((pl.productLine = p.productLine)))
        JOIN orderdetails od ON ((p.productCode = od.productCode)))
        JOIN orders AS o ON ((od.orderNumber = o.orderNumber)))
    GROUP BY pl.productLine;

SELECT *FROM PRODUCT_CATEGORY_SALES;

## QUESTION 9 ##

DELIMITER //
CREATE  PROCEDURE `Get_country_payments`(IN input_year INT,
                                         IN input_country VARCHAR(100))
BEGIN
    SELECT 
        YEAR(p.paymentDate) AS Year, 
        c.country, 
        CONCAT(FORMAT(SUM(p.amount) / 1000, 0), 'K') AS "Total Amount"
    FROM customers AS c
    JOIN payments AS p ON c.customerNumber = p.customerNumber
    WHERE YEAR(p.paymentDate) = input_year 
          AND c.country = input_country
    GROUP BY 
	Year, c.country;
END //
DELIMITER ;


CALL GET_COUNTRY_PAYMENTS(2003,"FRANCE");

## QUESTION 10 ##

# 10 (a):

SELECT 
    customerName, 
    COUNT(orderNumber) AS Order_count,
    DENSE_RANK() OVER (ORDER BY COUNT(orderNumber) DESC) AS order_frequency_rnk
FROM customers
INNER JOIN orders USING (customerNumber)
GROUP BY customerName;

# 10 (b):

WITH MonthlySales AS (SELECT YEAR(orderDate) AS Year, 
                              MONTHNAME(orderDate) AS Month, 
							  COUNT(orderNumber) AS Total_Orders
    FROM orders
    GROUP BY Year, Month
    ORDER BY Year, STR_TO_DATE(Month, '%M') 
)
SELECT Year, 
       Month, 
      Total_Orders,
    CONCAT(ROUND(((Total_Orders - LAG(Total_Orders) OVER (ORDER BY Year, STR_TO_DATE(Month, '%M'))) 
            / LAG(Total_Orders) OVER (ORDER BY Year, STR_TO_DATE(Month, '%M'))) * 100, 0), '%') AS "% YoY Change"
FROM MonthlySales;

## QUESTION 11 ##

SELECT PRODUCTLINE,
COUNT(*) AS TOTAL
FROM PRODUCTS
WHERE BUYPRICE > (SELECT AVG(BUYPRICE)
FROM PRODUCTS)
GROUP BY PRODUCTLINE
ORDER BY TOTAL DESC;

## QUESTION 12 ##

CREATE TABLE EMP_EH(EMP_ID INT PRIMARY KEY,
                    EMPNAME VARCHAR(50),
                    EMAILADDRESS VARCHAR(100));
                    
DELIMITER //
 CREATE  PROCEDURE `InsertEmployee`(IN p_id INT,
									IN p_name VARCHAR(100), 
                                    IN p_email VARCHAR(100))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
	SELECT 'Error occurred' AS Message;
    END;
    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress) 
    VALUES (p_id, p_name, p_email);
END //
DELIMITER ;               

call classicmodels.InsertEmployee(101, "RAVI", '"RAVI@GMAI.COM');

## QUESTION 13 ##

CREATE TABLE EMP_BIT(NAME VARCHAR (100),
                     OCCUPATION VARCHAR (100),
                     WORKING_DATE DATE,
                     WORKING_HOURS INT);
                     
SELECT*FROM EMP_BIT;

 DELIMITER //
CREATE TRIGGER before_insert_working_hours
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);
    END IF;
END //
DELIMITER ;                    
                     
          
INSERT INTO Emp_BIT (Name, 
                     Occupation,
                     Working_date, 
                     Working_hours) 
VALUES("Robin", "Scientist", "2020-10-04", 12),
	  ("Warner", "Engineer", "2020-10-04", 10),
      ("Peter", "Actor", "2020-10-04", 13),
	  ("Marco", "Doctor", "2020-10-04", 14),
      ("Brayden", "Teacher", "2020-10-04", 12),
      ("Antonio", "Business", "2020-10-04", 11);
                     
SELECT*FROM EMP_BIT;
                     
                     
                     
   INSERT INTO EMP_BIT VALUES ("CHANDU", "Expert", "2026-04-27", -5);
SELECT * FROM EMP_BIT;








