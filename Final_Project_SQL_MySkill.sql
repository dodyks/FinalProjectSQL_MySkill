-- Question number 1
-- During transactions that occurred in 2021, in which month was
-- the total transaction value (after_discount) the highest? 
-- Use is_valid = 1 to filter transaction data.
-- Answer:
SELECT 
    MONTH(order_date) AS month_2021, 
    ROUND(SUM(after_discount), 2) AS total_sales 
FROM order_detail  
WHERE 
    is_valid = 1 
    AND order_date BETWEEN '2021-01-01' AND '2021-12-31' 
GROUP BY month_2021 
ORDER BY total_sales DESC, month_2021 ASC
LIMIT 5;


-- Question number 2
-- During transactions in 2022, which category generated the highest
-- transaction value? Use is_valid = 1 to filter transaction data.
-- Answer:
SELECT 
    sd.category, 
    ROUND(SUM(od.after_discount), 2) AS total_sales 
FROM order_detail AS od 
JOIN sku_detail AS sd  
    ON od.sku_id = sd.id 
WHERE 
    od.is_valid = 1 
    AND od.order_date BETWEEN '2022-01-01' AND '2022-12-31' 
GROUP BY sd.category 
ORDER BY total_sales DESC 
LIMIT 5;


-- Question number 3
-- Compare the transaction values from each category in 2021 with 2022. 
-- List which categories experienced an increase and which categories 
-- experienced a decrease in transaction value from 2021 to 2022. 
-- Use is_valid = 1 to filter transaction data.
-- Answer:
WITH transaction_data AS (
    SELECT
        SD.category,
        SUM(CASE WHEN EXTRACT(YEAR FROM OD.order_date) = 2021 
                 THEN after_discount END) AS total_sales_2021,
        SUM(CASE WHEN EXTRACT(YEAR FROM OD.order_date) = 2022 
                 THEN after_discount END) AS total_sales_2022,
        SUM(CASE WHEN EXTRACT(YEAR FROM OD.order_date) = 2022 
                 THEN after_discount END) - 
        SUM(CASE WHEN EXTRACT(YEAR FROM OD.order_date) = 2021 
                 THEN after_discount END) AS difference
    FROM order_detail OD
    LEFT JOIN sku_detail SD ON OD.sku_id = SD.id
    WHERE EXTRACT(YEAR FROM OD.order_date) IN (2021, 2022) 
    AND OD.is_valid = 1
    GROUP BY SD.category
)

SELECT *, 
       CASE WHEN total_sales_2021 < total_sales_2022 
            THEN 'Increase' ELSE 'Decrease' END AS trend
FROM transaction_data
ORDER BY difference DESC;


-- Question number 4
-- Display the top 5 most popular payment methods used during 2022 
-- (based on total unique orders). 
-- Use is_valid = 1 to filter transaction data.
-- Answer:
SELECT  
    pd.payment_method,  
    COUNT(DISTINCT od.customer_id) AS total_customers  
FROM order_detail AS od  
JOIN payment_detail AS pd ON pd.id = od.payment_id  
WHERE od.is_valid = 1  
AND od.order_date BETWEEN '2022-01-01' AND '2022-12-31'  
GROUP BY pd.payment_method  
ORDER BY total_customers DESC  
LIMIT 5;


-- Question number 5
-- Rank these 5 products based on their transaction value:
-- 1. Samsung 
-- 2. Apple 
-- 3. Sony 
-- 4. Huawei 
-- 5. Lenovo 
-- Use is_valid = 1 to filter transaction data.
-- Answer:
WITH product_sales AS ( 
    SELECT 
        CASE  
            WHEN LOWER(sd.sku_name) LIKE '%samsung%' THEN 'Samsung' 
            WHEN LOWER(sd.sku_name) LIKE '%iphone%' 
              OR LOWER(sd.sku_name) LIKE '%ipad%' 
              OR LOWER(sd.sku_name) LIKE '%macbook%' 
              OR LOWER(sd.sku_name) LIKE '%apple%' THEN 'Apple' 
            WHEN LOWER(sd.sku_name) LIKE '%sony%' THEN 'Sony' 
            WHEN LOWER(sd.sku_name) LIKE '%huawei%' THEN 'Huawei' 
            WHEN LOWER(sd.sku_name) LIKE '%lenovo%' THEN 'Lenovo' 
        END AS product_name, 
        SUM(od.after_discount) AS total_sales 
    FROM order_detail AS od 
    JOIN sku_detail AS sd ON sd.id = od.sku_id 
    WHERE od.is_valid = 1 
    GROUP BY product_name
)  
SELECT * 
FROM product_sales 
WHERE product_name IS NOT NULL 
ORDER BY total_sales DESC;