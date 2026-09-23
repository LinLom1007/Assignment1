INSERT ALL
  INTO customers VALUES (1, 'Alice Mutoni', 'alice@email.com', 'Kigali')
  INTO customers VALUES (2, 'Bob Keza', 'bob@email.com', 'Musanze')
  INTO customers VALUES (3, 'Charlie Gakuba', 'charlie@email.com', 'Kigali')
  INTO customers VALUES (4, 'Diana Uwase', 'diana@email.com', 'Rubavu')
  INTO customers VALUES (5, 'Eric Mugisha', 'eric@email.com', 'Huye')
  INTO customers VALUES (6, 'Fiona Ineza', 'fiona@email.com', 'Kigali')
SELECT * FROM Dual;  
INSERT ALL
  INTO products VALUES (101, 'Organic Milk 1L', 'Dairy', 1500.00)
  INTO products VALUES (102, 'Cheddar Cheese 250g', 'Dairy', 3500.00)
  INTO products VALUES (103, 'White Bread', 'Bakery', 1000.00)
  INTO products VALUES (104, 'Chocolate Croissant', 'Bakery', 1200.00)
  INTO products VALUES (105, 'Basmati Rice 5kg', 'Pantry', 8500.00)
  INTO products VALUES (106, 'Sunflower Oil 2L', 'Pantry', 6000.00)
  INTO products VALUES (107, 'Greek Yogurt', 'Dairy', 2000.00)
  INTO products VALUES (108, 'Whole Wheat Bread', 'Bakery', 1500.00)
SELECT * FROM Dual;

INSERT ALL
  INTO orders VALUES (1001, 1, TO_DATE('2026-09-01', 'YYYY-MM-DD'))
  INTO orders VALUES (1002, 2, TO_DATE('2026-09-01', 'YYYY-MM-DD'))
  INTO orders VALUES (1003, 3, TO_DATE('2026-09-02', 'YYYY-MM-DD'))
  INTO orders VALUES (1004, 4, TO_DATE('2026-09-03', 'YYYY-MM-DD'))
  INTO orders VALUES (1005, 5, TO_DATE('2026-09-04', 'YYYY-MM-DD'))
  INTO orders VALUES (1006, 1, TO_DATE('2026-09-05', 'YYYY-MM-DD'))
  INTO orders VALUES (1007, 2, TO_DATE('2026-09-06', 'YYYY-MM-DD'))
  INTO orders VALUES (1008, 3, TO_DATE('2026-09-07', 'YYYY-MM-DD'))
  INTO orders VALUES (1009, 4, TO_DATE('2026-09-08', 'YYYY-MM-DD'))
  INTO orders VALUES (1010, 5, TO_DATE('2026-09-09', 'YYYY-MM-DD'))
  INTO orders VALUES (1011, 1, TO_DATE('2026-09-10', 'YYYY-MM-DD'))
  INTO orders VALUES (1012, 2, TO_DATE('2026-09-11', 'YYYY-MM-DD'))
  INTO orders VALUES (1013, 3, TO_DATE('2026-09-12', 'YYYY-MM-DD'))
  INTO orders VALUES (1014, 4, TO_DATE('2026-09-13', 'YYYY-MM-DD'))
  INTO orders VALUES (1015, 1, TO_DATE('2026-09-15', 'YYYY-MM-DD'))
SELECT * FROM Dual;



INSERT ALL
  INTO order_items VALUES (1, 1001, 101, 2)
  INTO order_items VALUES (2, 1001, 103, 1)
  INTO order_items VALUES (3, 1002, 105, 1)
  INTO order_items VALUES (4, 1003, 106, 2)
  INTO order_items VALUES (5, 1003, 102, 1)
  INTO order_items VALUES (6, 1004, 104, 4)
  INTO order_items VALUES (7, 1005, 108, 2)
  INTO order_items VALUES (8, 1006, 101, 3)
  INTO order_items VALUES (9, 1006, 107, 2)
  INTO order_items VALUES (10, 1007, 105, 2)
  INTO order_items VALUES (11, 1008, 103, 3)
  INTO order_items VALUES (12, 1008, 104, 2)
  INTO order_items VALUES (13, 1009, 106, 1)
  INTO order_items VALUES (14, 1010, 102, 2)
  INTO order_items VALUES (15, 1011, 105, 1)
  INTO order_items VALUES (16, 1011, 106, 1)
  INTO order_items VALUES (17, 1012, 108, 1)
  INTO order_items VALUES (18, 1013, 101, 4)
  INTO order_items VALUES (19, 1013, 103, 2)
  INTO order_items VALUES (20, 1014, 107, 5)
  INTO order_items VALUES (21, 1015, 105, 2)
  INTO order_items VALUES (22, 1015, 102, 1)
  INTO order_items VALUES (23, 1002, 104, 2)
  INTO order_items VALUES (24, 1004, 101, 1)
  INTO order_items VALUES (25, 1007, 103, 2)
SELECT * FROM Dual;

COMMIT;


SELECT o.order_id, c.customer_name, c.city, o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_id;

SELECT oi.order_item_id, oi.order_id, p.product_name, p.category, p.price, oi.quantity
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.order_id;

SELECT c.customer_id, c.customer_name, o.order_id, o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id;

WITH customer_spend AS (
    SELECT o.customer_id, SUM(oi.quantity * p.price) AS total_spent
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY o.customer_id
)
SELECT cs.customer_id, c.customer_name, cs.total_spent
FROM customer_spend cs
JOIN customers c ON cs.customer_id = c.customer_id
WHERE cs.total_spent > (SELECT AVG(total_spent) FROM customer_spend); 


SELECT c.customer_name, SUM(oi.quantity * p.price) AS total_spent,
       RANK() OVER (ORDER BY SUM(oi.quantity * p.price) DESC) AS spend_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_name;

SELECT c.customer_name, o.order_id, o.order_date,
       ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS order_sequence
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;


WITH daily_revenue AS (
    SELECT o.order_date, SUM(oi.quantity * p.price) AS daily_sales
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY o.order_date
)
SELECT order_date, daily_sales,
       SUM(daily_sales) OVER (ORDER BY order_date) AS running_total_revenue
FROM daily_revenue
ORDER BY order_date;


SELECT c.customer_name, o.order_id, o.order_date,
       o.order_date - LAG(o.order_date, 1) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS days_since_last_order
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;
