PROJECT : E-Commerce Revenue and Customer Analytics 
TOOL : PostgreSQL(pgAdmin) 
AUTHOR : Akshit Thapa 

1) CREATE TABLES 

CREATE TABLE customerss (
customer_id INT PRIMARY KEY,
customer_name VARCHAR(50),
city VARCHAR(50),
signup_date DATE
);


CREATE TABLE orderss (
order_id INT PRIMARY KEY,
customer_id INT, 
order_date DATE, 
order_amount NUMERIC(10,2)
);


CREATE TABLE order_item (
item_id INT PRIMARY KEY, 
order_id INT, 
product_name VARCHAR(50),
quantity INT,
price NUMERIC
);


2) INSERT DATA 

INSERT INTO Customerss
VALUES
(1, 'Rahul', 'Delhi', '2021-01-10'),
(2, 'Akshit', 'Mumbai', '2021-02-15'),
(3, 'Neha', 'Pune', '2022-06-20'),
(4, 'Aman', 'Delhi', '2022-09-05'),
(5, 'Priya', 'Bangalore', '2023-02-01'),
(6, 'Rohan', 'Mumbai', '2023-07-18');


INSERT INTO orderss
VALUES
(1, 1, '2023-01-10', 5000),
(2, 1, '2023-03-12', 3000),
(3, 2, '2023-02-15', 7000),
(4, 3, '2023-04-20', 2000),
(5, 3, '2024-01-10', 6000),
(6, 4, '2024-02-12', 4000),
(7, 5, '2024-03-15', 8000), 
(8, 5, '2024-04-18', 9000), 
(9, 6, '2024-05-01', 1000);


INSERT INTO order_item
VALUES
(1, 1, 'Laptop', 1, 5000),
(2, 2, 'Mouse', 2, 1500),
(3, 3, 'Phone', 1, 7000),
(4, 4, 'Keyboard', 1, 2000),
(5, 5, 'Tablet', 1, 6000),
(6, 6, 'Monitor', 1, 4000), 
(7, 7, 'Laptop', 1, 8000), 
(8, 8, 'Phone', 1, 9000), 
(9, 9, 'Mouse', 1, 1000);


3) ANALYSIS QUERIES 

(i) Customer Lifetime Value(CLV) ?

SELECT c.customer_id, c.customer_name, SUM(p.order_amount) AS total_amount
FROM Customerss AS c
LEFT JOIN orderss AS p 
ON c.customer_id = p.customer_id 
GROUP BY c.customer_id, c.customer_name
ORDER BY total_amount DESC;


(ii) Rank Customers by Lifetime Value ?

WITH customer_total AS (
SELECT customer_id, SUM(order_amount) AS total_spent
FROM orderss
GROUP BY customer_id 
)
SELECT customer_id, total_spent,
RANK() OVER(ORDER BY total_spent DESC) AS rank
FROM customer_total;


(iii) Customers with more than 1 order ?

SELECT customer_id, COUNT(order_id) AS total_orders
FROM orderss
GROUP BY customer_id
HAVING COUNT(order_id) > 1;


(iv) Revenue By Product ?

SELECT oi.product_name, SUM(oi.quantity * oi.price) AS total_revenue
FROM order_item AS oi
JOIN orderss AS p 
ON oi.order_id = p.order_id 
GROUP BY oi.product_name
ORDER BY total_revenue DESC;


(v) Monthly Revenue Trend ?

SELECT EXTRACT(YEAR FROM order_date) AS year, 
       EXTRACT(MONTH FROM order_date) AS month,
	   SUM(order_amount) AS total_revenue
FROM orderss 
GROUP BY EXTRACT(YEAR FROM order_date), 
         EXTRACT(MONTH FROM order_date)
ORDER BY year, month;


(vi) Running Total of Revenue Over Time ?

SELECT order_date, SUM(order_amount) AS daily_revenue,
                   SUM(SUM(order_amount)) OVER(ORDER BY order_date) AS running_total
FROM orderss
GROUP BY order_date
ORDER BY order_date;


(vii) Top Product Per Year ?

SELECT year, product_name, total_revenue, rnk 
FROM(
SELECT EXTRACT(YEAR FROM c.order_date) AS year, p.product_name,
       SUM(p.quantity * p.price) AS total_revenue,
	   RANK() OVER(PARTITION BY EXTRACT(YEAR FROM c.order_date)
	   ORDER BY SUM(p.quantity * p.price) DESC
	   ) AS rnk
FROM orderss AS c 
JOIN order_item AS p 
ON c.order_id = p.order_id
GROUP BY EXTRACT(YEAR FROM c.order_date), p.product_name
) AS t 
WHERE rnk = 1
ORDER BY year;


(viii) Contribution % of each Customer to Total Revenue ?

WITH customer_total AS ( 
SELECT customer_id, SUM(order_amount) AS total_spent
FROM orderss
GROUP BY customer_id
)
SELECT customer_id, total_spent,
ROUND(total_spent * 100.0 / SUM(total_spent) OVER(), 2
) AS contribution_percentage
FROM customer_total 
ORDER BY contribution_percentage DESC;