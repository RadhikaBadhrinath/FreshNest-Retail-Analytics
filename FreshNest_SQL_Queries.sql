-- ============================================================
-- FreshNest Foods — Retail Sales Analytics
-- SQL Business Questions & Queries
-- Database: SQLite / PostgreSQL compatible
-- Author: Radhika Balaji
-- ============================================================


-- ============================================================
-- SETUP: Create Tables
-- ============================================================

CREATE TABLE IF NOT EXISTS sales (
    Order_ID TEXT, Order_Date DATE, Week INTEGER, Month INTEGER,
    Year INTEGER, Quarter TEXT, Store_ID TEXT, Retailer TEXT,
    Product_ID TEXT, Product_Name TEXT, Category TEXT, Brand TEXT,
    Units_Sold INTEGER, Unit_Price REAL, Revenue REAL, COGS REAL,
    Gross_Profit REAL, Gross_Margin_Pct REAL, Promotion_ID TEXT,
    Promotion_Type TEXT, Discount_Rate REAL,
    Inventory_Level INTEGER, Weeks_of_Supply REAL
);

CREATE TABLE IF NOT EXISTS products (
    Product_ID TEXT, Product_Name TEXT, Brand TEXT, Category TEXT,
    Unit_Cost REAL, Unit_Price REAL, Gross_Margin_Pct REAL
);

CREATE TABLE IF NOT EXISTS stores (
    Store_ID TEXT, Retailer TEXT, Store_Format TEXT,
    Region TEXT, State TEXT, Store_Size TEXT
);

CREATE TABLE IF NOT EXISTS promotions (
    Promotion_ID TEXT, Promotion_Name TEXT, Promotion_Type TEXT,
    Category TEXT, Start_Date DATE, End_Date DATE,
    Promotion_Spend REAL, Discount_Rate REAL
);

CREATE TABLE IF NOT EXISTS customers (
    Customer_ID TEXT, Store_ID TEXT, Retailer TEXT, Region TEXT,
    Customer_Segment TEXT, Primary_Channel TEXT,
    Avg_Basket_Size REAL, Purchase_Frequency_Per_Month REAL
);


-- ============================================================
-- SECTION 1: EXECUTIVE KPIs
-- ============================================================

-- Q1: Total Revenue, Profit, Units, and Margin by Year
SELECT
    Year,
    ROUND(SUM(Revenue), 0)       AS Total_Revenue,
    ROUND(SUM(Gross_Profit), 0)  AS Total_Profit,
    SUM(Units_Sold)              AS Total_Units,
    ROUND(AVG(Gross_Margin_Pct), 1) AS Avg_Margin_Pct,
    COUNT(DISTINCT Order_ID)     AS Total_Orders
FROM sales
GROUP BY Year
ORDER BY Year;


-- Q2: Year-over-Year Revenue Growth by Category
WITH yearly AS (
    SELECT
        Category,
        Year,
        ROUND(SUM(Revenue), 0) AS Revenue
    FROM sales
    GROUP BY Category, Year
),
yoy AS (
    SELECT
        a.Category,
        a.Year AS Current_Year,
        a.Revenue AS Current_Revenue,
        b.Revenue AS Prior_Revenue,
        ROUND((a.Revenue - b.Revenue) / b.Revenue * 100, 1) AS YoY_Growth_Pct
    FROM yearly a
    LEFT JOIN yearly b
        ON a.Category = b.Category AND a.Year = b.Year + 1
)
SELECT * FROM yoy
WHERE Prior_Revenue IS NOT NULL
ORDER BY YoY_Growth_Pct DESC;


-- Q3: Monthly Revenue Trend with Rolling 3-Month Average
WITH monthly AS (
    SELECT
        Year,
        Month,
        ROUND(SUM(Revenue), 0) AS Monthly_Revenue
    FROM sales
    GROUP BY Year, Month
)
SELECT
    Year,
    Month,
    Monthly_Revenue,
    ROUND(AVG(Monthly_Revenue) OVER (
        ORDER BY Year, Month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 0) AS Rolling_3M_Avg
FROM monthly
ORDER BY Year, Month;


-- ============================================================
-- SECTION 2: PRODUCT PERFORMANCE
-- ============================================================

-- Q4: Top 10 Products by Revenue
SELECT
    Product_Name,
    Category,
    Brand,
    ROUND(SUM(Revenue), 0)      AS Total_Revenue,
    ROUND(SUM(Gross_Profit), 0) AS Total_Profit,
    SUM(Units_Sold)             AS Total_Units,
    ROUND(AVG(Gross_Margin_Pct), 1) AS Avg_Margin_Pct
FROM sales
GROUP BY Product_Name, Category, Brand
ORDER BY Total_Revenue DESC
LIMIT 10;


-- Q5: Worst Performing Products (Bottom 10 by Profit)
SELECT
    Product_Name,
    Category,
    ROUND(SUM(Revenue), 0)      AS Total_Revenue,
    ROUND(SUM(Gross_Profit), 0) AS Total_Profit,
    ROUND(AVG(Gross_Margin_Pct), 1) AS Avg_Margin_Pct,
    SUM(Units_Sold)             AS Total_Units
FROM sales
GROUP BY Product_Name, Category
ORDER BY Total_Profit ASC
LIMIT 10;


-- Q6: Revenue Share by Category with Rank
WITH cat_rev AS (
    SELECT
        Category,
        ROUND(SUM(Revenue), 0) AS Category_Revenue,
        ROUND(SUM(Gross_Profit), 0) AS Category_Profit
    FROM sales
    GROUP BY Category
),
total AS (SELECT SUM(Category_Revenue) AS Grand_Total FROM cat_rev)
SELECT
    cat_rev.Category,
    Category_Revenue,
    Category_Profit,
    ROUND(Category_Revenue / Grand_Total * 100, 1) AS Revenue_Share_Pct,
    RANK() OVER (ORDER BY Category_Revenue DESC) AS Revenue_Rank
FROM cat_rev, total
ORDER BY Revenue_Rank;


-- Q7: Product Revenue Ranking Within Each Category
SELECT
    Category,
    Product_Name,
    ROUND(SUM(Revenue), 0) AS Revenue,
    RANK() OVER (PARTITION BY Category ORDER BY SUM(Revenue) DESC) AS Rank_In_Category
FROM sales
GROUP BY Category, Product_Name
ORDER BY Category, Rank_In_Category;


-- ============================================================
-- SECTION 3: RETAILER & STORE PERFORMANCE
-- ============================================================

-- Q8: Revenue and Profit by Retailer
SELECT
    Retailer,
    ROUND(SUM(Revenue), 0)          AS Total_Revenue,
    ROUND(SUM(Gross_Profit), 0)     AS Total_Profit,
    SUM(Units_Sold)                 AS Total_Units,
    ROUND(AVG(Gross_Margin_Pct), 1) AS Avg_Margin_Pct,
    COUNT(DISTINCT Store_ID)        AS Store_Count,
    ROUND(SUM(Revenue) / COUNT(DISTINCT Store_ID), 0) AS Revenue_Per_Store
FROM sales
GROUP BY Retailer
ORDER BY Total_Revenue DESC;


-- Q9: Top 20 Stores by Revenue (Walmart Focus)
SELECT
    s.Store_ID,
    s.Retailer,
    s.Region,
    s.State,
    s.Store_Size,
    ROUND(SUM(sa.Revenue), 0)      AS Total_Revenue,
    ROUND(SUM(sa.Gross_Profit), 0) AS Total_Profit,
    RANK() OVER (ORDER BY SUM(sa.Revenue) DESC) AS Revenue_Rank
FROM sales sa
JOIN stores s ON sa.Store_ID = s.Store_ID
WHERE s.Retailer = 'Walmart'
GROUP BY s.Store_ID, s.Retailer, s.Region, s.State, s.Store_Size
ORDER BY Total_Revenue DESC
LIMIT 20;


-- Q10: Regional Performance Heatmap Data
SELECT
    s.Region,
    sa.Retailer,
    ROUND(SUM(sa.Revenue), 0)          AS Total_Revenue,
    ROUND(SUM(sa.Gross_Profit), 0)     AS Total_Profit,
    SUM(sa.Units_Sold)                 AS Total_Units,
    ROUND(AVG(sa.Gross_Margin_Pct), 1) AS Avg_Margin_Pct
FROM sales sa
JOIN stores s ON sa.Store_ID = s.Store_ID
GROUP BY s.Region, sa.Retailer
ORDER BY s.Region, Total_Revenue DESC;


-- ============================================================
-- SECTION 4: PROMOTION EFFECTIVENESS
-- ============================================================

-- Q11: Promotion ROI by Promotion Type
WITH promo_sales AS (
    SELECT
        Promotion_Type,
        ROUND(SUM(Revenue), 0)      AS Promo_Revenue,
        ROUND(SUM(Gross_Profit), 0) AS Promo_Profit,
        SUM(Units_Sold)             AS Promo_Units
    FROM sales
    WHERE Promotion_Type != 'None'
    GROUP BY Promotion_Type
),
baseline AS (
    SELECT
        ROUND(AVG(Revenue), 2) AS Baseline_Revenue_Per_Order
    FROM sales
    WHERE Promotion_Type = 'None'
),
promo_spend AS (
    SELECT
        Promotion_Type,
        ROUND(SUM(Promotion_Spend), 0) AS Total_Spend
    FROM promotions
    GROUP BY Promotion_Type
)
SELECT
    ps.Promotion_Type,
    ps.Promo_Revenue,
    ps.Promo_Profit,
    ps.Promo_Units,
    COALESCE(psp.Total_Spend, 0) AS Total_Spend,
    ROUND((ps.Promo_Profit - COALESCE(psp.Total_Spend, 0)) /
          NULLIF(COALESCE(psp.Total_Spend, 0), 0) * 100, 1) AS ROI_Pct
FROM promo_sales ps
LEFT JOIN promo_spend psp ON ps.Promotion_Type = psp.Promotion_Type
ORDER BY ROI_Pct DESC;


-- Q12: Before vs After Promotion Sales Lift by Category
WITH promoted AS (
    SELECT
        Category,
        ROUND(AVG(Revenue), 2) AS Avg_Revenue_With_Promo
    FROM sales
    WHERE Promotion_Type != 'None'
    GROUP BY Category
),
baseline AS (
    SELECT
        Category,
        ROUND(AVG(Revenue), 2) AS Avg_Revenue_Without_Promo
    FROM sales
    WHERE Promotion_Type = 'None'
    GROUP BY Category
)
SELECT
    p.Category,
    b.Avg_Revenue_Without_Promo AS Baseline,
    p.Avg_Revenue_With_Promo    AS With_Promotion,
    ROUND((p.Avg_Revenue_With_Promo - b.Avg_Revenue_Without_Promo)
          / b.Avg_Revenue_Without_Promo * 100, 1) AS Lift_Pct
FROM promoted p
JOIN baseline b ON p.Category = b.Category
ORDER BY Lift_Pct DESC;


-- Q13: Incremental Revenue Generated by Promotions
WITH promo_rev AS (
    SELECT
        Promotion_Type,
        SUM(Revenue) AS Total_Promo_Revenue,
        COUNT(*) AS Promo_Orders
    FROM sales WHERE Promotion_Type != 'None'
    GROUP BY Promotion_Type
),
baseline_rev AS (
    SELECT AVG(Revenue) AS Avg_Baseline FROM sales WHERE Promotion_Type = 'None'
)
SELECT
    pr.Promotion_Type,
    ROUND(pr.Total_Promo_Revenue, 0) AS Total_Revenue,
    ROUND(br.Avg_Baseline * pr.Promo_Orders, 0) AS Expected_Without_Promo,
    ROUND(pr.Total_Promo_Revenue - (br.Avg_Baseline * pr.Promo_Orders), 0) AS Incremental_Revenue
FROM promo_rev pr, baseline_rev br
ORDER BY Incremental_Revenue DESC;


-- ============================================================
-- SECTION 5: CUSTOMER INSIGHTS
-- ============================================================

-- Q14: Revenue and Basket Size by Customer Segment
SELECT
    c.Customer_Segment,
    COUNT(DISTINCT s.Store_ID)          AS Store_Count,
    ROUND(SUM(sa.Revenue), 0)           AS Total_Revenue,
    ROUND(AVG(c.Avg_Basket_Size), 2)    AS Avg_Basket_Size,
    ROUND(AVG(c.Purchase_Frequency_Per_Month), 1) AS Avg_Purchase_Freq,
    ROUND(SUM(sa.Revenue) / COUNT(DISTINCT s.Store_ID), 0) AS Revenue_Per_Store
FROM sales sa
JOIN stores s ON sa.Store_ID = s.Store_ID
JOIN customers c ON c.Store_ID = s.Store_ID
GROUP BY c.Customer_Segment
ORDER BY Total_Revenue DESC;


-- Q15: Category Preference by Customer Segment
SELECT
    c.Customer_Segment,
    sa.Category,
    ROUND(SUM(sa.Revenue), 0) AS Revenue,
    RANK() OVER (
        PARTITION BY c.Customer_Segment
        ORDER BY SUM(sa.Revenue) DESC
    ) AS Category_Rank
FROM sales sa
JOIN stores s ON sa.Store_ID = s.Store_ID
JOIN customers c ON c.Store_ID = s.Store_ID
GROUP BY c.Customer_Segment, sa.Category
ORDER BY c.Customer_Segment, Category_Rank;


-- Q16: Channel Performance (In-Store vs Online vs Click & Collect)
SELECT
    c.Primary_Channel,
    COUNT(DISTINCT sa.Store_ID)  AS Store_Count,
    ROUND(SUM(sa.Revenue), 0)    AS Total_Revenue,
    SUM(sa.Units_Sold)           AS Total_Units,
    ROUND(AVG(sa.Revenue), 2)    AS Avg_Order_Value
FROM sales sa
JOIN customers c ON c.Store_ID = sa.Store_ID
GROUP BY c.Primary_Channel
ORDER BY Total_Revenue DESC;


-- ============================================================
-- SECTION 6: INVENTORY ANALYTICS
-- ============================================================

-- Q17: Products at Risk of Stockout (Weeks of Supply < 3)
SELECT
    Product_Name,
    Category,
    Retailer,
    ROUND(AVG(Inventory_Level), 0) AS Avg_Inventory,
    ROUND(AVG(Weeks_of_Supply), 1) AS Avg_Weeks_of_Supply,
    ROUND(AVG(Units_Sold), 1)      AS Avg_Daily_Units,
    CASE
        WHEN AVG(Weeks_of_Supply) < 1 THEN 'Critical'
        WHEN AVG(Weeks_of_Supply) < 3 THEN 'At Risk'
        ELSE 'Healthy'
    END AS Stock_Status
FROM sales
GROUP BY Product_Name, Category, Retailer
HAVING AVG(Weeks_of_Supply) < 3
ORDER BY Avg_Weeks_of_Supply ASC
LIMIT 20;


-- Q18: Slow Moving Products (High Inventory, Low Sales)
SELECT
    Product_Name,
    Category,
    ROUND(AVG(Inventory_Level), 0) AS Avg_Inventory,
    ROUND(AVG(Units_Sold), 1)      AS Avg_Daily_Units,
    ROUND(AVG(Weeks_of_Supply), 1) AS Avg_Weeks_of_Supply,
    ROUND(SUM(Revenue), 0)         AS Total_Revenue
FROM sales
GROUP BY Product_Name, Category
HAVING AVG(Weeks_of_Supply) > 12 AND AVG(Units_Sold) < 3
ORDER BY Avg_Weeks_of_Supply DESC
LIMIT 15;


-- ============================================================
-- SECTION 7: ADVANCED ANALYTICS
-- ============================================================

-- Q19: Running Revenue Total by Month (Cumulative YTD)
WITH monthly AS (
    SELECT
        Year, Month,
        ROUND(SUM(Revenue), 0) AS Monthly_Revenue
    FROM sales
    GROUP BY Year, Month
)
SELECT
    Year, Month, Monthly_Revenue,
    ROUND(SUM(Monthly_Revenue) OVER (
        PARTITION BY Year
        ORDER BY Month
        ROWS UNBOUNDED PRECEDING
    ), 0) AS YTD_Revenue
FROM monthly
ORDER BY Year, Month;


-- Q20: Average Order Value by Retailer and Quarter
SELECT
    Retailer,
    Quarter,
    Year,
    ROUND(AVG(Revenue), 2)  AS Avg_Order_Value,
    ROUND(SUM(Revenue), 0)  AS Total_Revenue,
    COUNT(Order_ID)         AS Total_Orders
FROM sales
GROUP BY Retailer, Quarter, Year
ORDER BY Year, Quarter, Total_Revenue DESC;


-- Q21: Weekly Sales Trend with Previous Week Comparison
WITH weekly AS (
    SELECT
        Year, Week,
        ROUND(SUM(Revenue), 0) AS Weekly_Revenue
    FROM sales
    GROUP BY Year, Week
)
SELECT
    Year, Week,
    Weekly_Revenue,
    LAG(Weekly_Revenue) OVER (ORDER BY Year, Week) AS Prev_Week_Revenue,
    ROUND(
        (Weekly_Revenue - LAG(Weekly_Revenue) OVER (ORDER BY Year, Week))
        / NULLIF(LAG(Weekly_Revenue) OVER (ORDER BY Year, Week), 0) * 100
    , 1) AS WoW_Growth_Pct
FROM weekly
ORDER BY Year, Week;


-- Q22: Top Performing Region per Retailer using CTE + Window Function
WITH regional_perf AS (
    SELECT
        sa.Retailer,
        st.Region,
        ROUND(SUM(sa.Revenue), 0) AS Revenue,
        RANK() OVER (
            PARTITION BY sa.Retailer
            ORDER BY SUM(sa.Revenue) DESC
        ) AS Region_Rank
    FROM sales sa
    JOIN stores st ON sa.Store_ID = st.Store_ID
    GROUP BY sa.Retailer, st.Region
)
SELECT Retailer, Region, Revenue, Region_Rank
FROM regional_perf
WHERE Region_Rank = 1
ORDER BY Revenue DESC;


-- Q23: Monthly Growth Rate using LAG Window Function
WITH monthly_rev AS (
    SELECT
        Year, Month,
        ROUND(SUM(Revenue), 0) AS Revenue
    FROM sales
    GROUP BY Year, Month
)
SELECT
    Year, Month, Revenue,
    LAG(Revenue) OVER (ORDER BY Year, Month) AS Prior_Month_Revenue,
    ROUND(
        (Revenue - LAG(Revenue) OVER (ORDER BY Year, Month))
        / NULLIF(LAG(Revenue) OVER (ORDER BY Year, Month), 0) * 100
    , 1) AS MoM_Growth_Pct
FROM monthly_rev
ORDER BY Year, Month;


-- ============================================================
-- SECTION 8: EXECUTIVE RECOMMENDATIONS SUPPORT QUERIES
-- ============================================================

-- Q24: Category Investment Gap (Promo Spend vs Revenue Share)
WITH cat_revenue AS (
    SELECT Category, ROUND(SUM(Revenue), 0) AS Revenue
    FROM sales GROUP BY Category
),
total_rev AS (SELECT SUM(Revenue) AS Grand_Total FROM sales),
cat_spend AS (
    SELECT Category, ROUND(SUM(Promotion_Spend), 0) AS Promo_Spend
    FROM promotions GROUP BY Category
),
total_spend AS (SELECT SUM(Promo_Spend) AS Grand_Spend FROM cat_spend)
SELECT
    cr.Category,
    cr.Revenue,
    ROUND(cr.Revenue / tr.Grand_Total * 100, 1) AS Revenue_Share_Pct,
    COALESCE(cs.Promo_Spend, 0) AS Promo_Spend,
    ROUND(COALESCE(cs.Promo_Spend, 0) / ts.Grand_Spend * 100, 1) AS Spend_Share_Pct,
    ROUND(cr.Revenue / tr.Grand_Total * 100, 1) -
    ROUND(COALESCE(cs.Promo_Spend, 0) / ts.Grand_Spend * 100, 1) AS Investment_Gap
FROM cat_revenue cr
JOIN total_rev tr ON 1=1
LEFT JOIN cat_spend cs ON cr.Category = cs.Category
JOIN total_spend ts ON 1=1
ORDER BY Investment_Gap DESC;


-- Q25: Profit Opportunity by Retailer (Low Margin Retailers)
SELECT
    Retailer,
    ROUND(SUM(Revenue), 0)          AS Total_Revenue,
    ROUND(SUM(Gross_Profit), 0)     AS Total_Profit,
    ROUND(AVG(Gross_Margin_Pct), 1) AS Avg_Margin_Pct,
    CASE
        WHEN AVG(Gross_Margin_Pct) < 40 THEN 'Margin Improvement Needed'
        WHEN AVG(Gross_Margin_Pct) < 45 THEN 'On Target'
        ELSE 'Strong Performer'
    END AS Margin_Status
FROM sales
GROUP BY Retailer
ORDER BY Avg_Margin_Pct ASC;
