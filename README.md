# PL/SQL Assignment One: Sunrise Supermarket Sales Analysis

## Student Details
* **Student Name:** [Your Name Here]
* **Student ID:** [Your Student ID Here]
* **Instructor:** Eric Maniraguha
* **TA:** Afanyu Emmanuel
* **DBMS Tool Used:** Oracle SQL / Live SQL (Standard ANSI SQL Syntax)

---

## 1. Business Scenario Summary
Sunrise Supermarket is a retail enterprise selling daily consumable products categorized under Dairy, Bakery, and Pantry items. To maintain competitive advantage, optimization of inventory levels, and strategic customer retention, management requires data-driven answers regarding consumer demographics, order frequency, high-value purchasers, and revenue movement trajectories over time. 

This analytical project establishes a normalized Relational Database Management System (RDBMS) consisting of four interconnected entities (`customers`, `products`, `orders`, and `order_items`) and executes targeted relational queries utilizing Joins, Common Table Expressions (CTEs), and Window Functions to extract operational insights.

---

## 2. Analytical Queries & Technical Breakdowns

### Query 1: Order Details with Customer Context
* **Business Purpose:** Pairs transaction records with structural customer demographics to identify where processing shipments are heading.
* **SQL Query:**
```sql
SELECT o.order_id, c.customer_name, c.city, o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_id;
```
![Query-1 result](https://github.com/LinLom1007/Assignment1/blob/00d57a27c7c4990037e71ddf3d55183cef786f9f/1.png)

### Query 2: Product Breakdown Per Line Item
* **Business Purpose:** Extracts granular inventory sales movement metrics by evaluating quantities ordered against product classifications.
* **SQL Query:**
```sql
SELECT oi.order_item_id, oi.order_id, p.product_name, p.category, p.price, oi.quantity
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.order_id;
```
![Query-2 results](https://github.com/LinLom1007/Assignment1/blob/00d57a27c7c4990037e71ddf3d55183cef786f9f/2.png)

### Query 3: Comprehensive Customer Interaction Profile
* **Business Purpose:** Includes inactive accounts or churned clients who have registered but never placed an order, highlighting marketing re-engagement opportunities.
* **SQL Query:**
```sql
SELECT c.customer_id, c.customer_name, o.order_id, o.order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id;
```
![Query-3 results](https://github.com/LinLom1007/Assignment1/blob/00d57a27c7c4990037e71ddf3d55183cef786f9f/3.png)

### Query 4: High-Value Customer Identification (Above Average Spend)
* **Business Purpose:** Uses a Common Table Expression (CTE) to isolate top-tier consumers contributing total revenue greater than the mean platform benchmark.
* **SQL Query:**
```sql
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
```
![Query-4 results](https://github.com/LinLom1007/Assignment1/blob/00d57a27c7c4990037e71ddf3d55183cef786f9f/4.png)
### Query 5: Financial Contribution Ranking
* **Business Purpose:** Ranks the customer base strictly by financial volume generated to prioritize rewards for VIP clientele.
* **SQL Query:**
```sql
SELECT c.customer_name, SUM(oi.quantity * p.price) AS total_spent,
       RANK() OVER (ORDER BY SUM(oi.quantity * p.price) DESC) AS spend_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_name;
```
![Query-5 results](https://github.com/LinLom1007/Assignment1/blob/00d57a27c7c4990037e71ddf3d55183cef786f9f/5.png)
### Query 6: Sequential Order Indexing
* **Business Purpose:** Tracks individual customer paths by chronologically numbering their orders to monitor loyalty milestones.
* **SQL Query:**
```sql
SELECT c.customer_name, o.order_id, o.order_date,
       ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS order_sequence
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;
```
![Query-6 results](https://github.com/LinLom1007/Assignment1/blob/00d57a27c7c4990037e71ddf3d55183cef786f9f/6.png)
### Query 7: Continuous Running Revenue Track
* **Business Purpose:** Provides a running calculation of cumulative daily revenue to map financial scaling and trend velocity.
* **SQL Query:**
```sql
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
```
![Query-7 results](https://github.com/LinLom1007/Assignment1/blob/00d57a27c7c4990037e71ddf3d55183cef786f9f/7.png)
### Query 8: Purchase Interval Velocity Analysis
* **Business Purpose:** Measures customer retention metrics by checking how many days pass before a customer returns to place another order.
* **SQL Query:**
```sql
SELECT c.customer_name, o.order_id, o.order_date,
       o.order_date - LAG(o.order_date, 1) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS days_since_last_order
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;
```
![Query-8 results](https://github.com/LinLom1007/Assignment1/blob/00d57a27c7c4990037e71ddf3d55183cef786f9f/8.png)


## 3. Business Interpretation & Insights

* **Geographic Clusters:** Kigali brings in the highest transaction volume, while cities like Rubavu and Musanze show slower purchase velocity. Marketing actions should focus on expanding outside the primary city hub.
* **VIP Segments:** A small group of high-value consumers accounts for a major share of total pantry sales. This indicates a strong business case for introducing a premium tier loyalty program.
* **Churn Signals:** Inactive customers (e.g., Fiona Ineza) represent registered users who haven't crossed the conversion threshold. They can be targeted with specialized email promotions.
* **Purchase Restock Cycle:** Returning customers average a 4 to 5-day cycle between orders. Inventory for high-demand items (like Dairy and Bakery goods) should be planned around this quick turnaround.

---

## 4. Challenges & Solutions

* **Challenge:** Handling chronological ordering inside running totals when multiple transactions happen on the exact same calendar date.
* **Resolution:** Implemented a pre-aggregating Common Table Expression (`daily_revenue`) to consolidate clean distinct date values before applying the window-based global cumulative sum.

