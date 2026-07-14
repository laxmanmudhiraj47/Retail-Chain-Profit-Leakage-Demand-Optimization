-- =====================================================
-- CREATE DATABASE
-- =====================================================
DROP DATABASE IF EXISTS retail_analysis;

CREATE DATABASE retail_analysis;
GO

USE retail_analysis;
GO


-- =====================================================
-- SALES TABLE
-- =====================================================

DROP TABLE IF EXISTS Sales;

CREATE TABLE Sales (
    Order_ID VARCHAR(255),
    Order_Date VARCHAR(255),
    Store_ID VARCHAR(255),
    Customer_ID VARCHAR(255),
    SKU_ID VARCHAR(255),
    Quantity VARCHAR(255),
    Selling_Price VARCHAR(255),
    Discount_Amount VARCHAR(255),
    Promo_ID VARCHAR(255),
    Delivery_Type VARCHAR(255),
    Payment_Mode VARCHAR(255),
    Order_Status VARCHAR(255)
);


-- =====================================================
-- PRODUCTS TABLE
-- =====================================================

DROP TABLE IF EXISTS Products;

CREATE TABLE Products (
    SKU_ID VARCHAR(255),
    SKU_Name VARCHAR(255),
    Category VARCHAR(255),
    Sub_Category VARCHAR(255),
    Brand VARCHAR(255),
    Tax_Percent VARCHAR(255),
    Unit_Cost VARCHAR(255),
    MRP VARCHAR(255)
);


-- =====================================================
-- INVENTORY TABLE
-- =====================================================

DROP TABLE IF EXISTS Inventory;

CREATE TABLE Inventory (
    Inventory_Date VARCHAR(255),
    Store_ID VARCHAR(255),
    SKU_ID VARCHAR(255),
    Reorder_Level VARCHAR(255),
    Opening_Stock VARCHAR(255),
    Closing_Stock VARCHAR(255),
    Warehouse_Stock VARCHAR(255)
);


-- =====================================================
-- RETURNS TABLE
-- =====================================================

DROP TABLE IF EXISTS Returns_Data;

CREATE TABLE Returns_Data (
    Return_ID VARCHAR(255),
    Order_ID VARCHAR(255),
    SKU_ID VARCHAR(255),
    Return_Date VARCHAR(255),
    Return_Reason VARCHAR(255),
    Refund_Amount VARCHAR(255),
    Return_Status VARCHAR(255)
);


-- =====================================================
-- VENDOR TABLE
-- =====================================================

DROP TABLE IF EXISTS Vendor;

CREATE TABLE Vendor (
    PO_ID VARCHAR(255),
    Vendor_ID VARCHAR(255),
    SKU_ID VARCHAR(255),
    Store_ID VARCHAR(255),
    PO_Date VARCHAR(255),
    Expected_Delivery_Date VARCHAR(255),
    Actual_Delivery_Date VARCHAR(255),
    Supplied_Quantity VARCHAR(255),
    Procurement_Cost VARCHAR(255)
);


-- =====================================================
-- PROMOTIONS TABLE
-- =====================================================

DROP TABLE IF EXISTS Promotions;

CREATE TABLE Promotions (
    Promo_ID VARCHAR(255),
    Promo_Type VARCHAR(255),
    Start_Date VARCHAR(255),
    End_Date VARCHAR(255),
    Target_Category VARCHAR(255),
    Promo_Budget VARCHAR(255)
);


-- =====================================================
-- CUSTOMERS TABLE
-- =====================================================

DROP TABLE IF EXISTS Customers;

CREATE TABLE Customers (
    Customer_ID VARCHAR(255),
    City VARCHAR(255),
    Signup_Date VARCHAR(255),
    Customer_Type VARCHAR(255)
);


-- =====================================================
-- BULK INSERT SALES
-- =====================================================

BULK INSERT Sales
FROM 'C:\Users\USER\Desktop\Excellenc\CLEANED_DATA\Cleaned_Sales.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);


-- =====================================================
-- BULK INSERT PRODUCTS
-- =====================================================

BULK INSERT Products
FROM 'C:\Users\USER\Desktop\Excellenc\CLEANED_DATA\Cleaned_Products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);


-- =====================================================
-- BULK INSERT INVENTORY
-- =====================================================

BULK INSERT Inventory
FROM 'C:\Users\USER\Desktop\Excellenc\CLEANED_DATA\Cleaned_Inventory.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);


-- =====================================================
-- BULK INSERT RETURNS
-- =====================================================

BULK INSERT Returns_Data
FROM 'C:\Users\USER\Desktop\Excellenc\CLEANED_DATA\Cleaned_Returns.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);


-- =====================================================
-- BULK INSERT VENDOR
-- =====================================================

BULK INSERT Vendor
FROM 'C:\Users\USER\Desktop\Excellenc\CLEANED_DATA\Cleaned_Vendor.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);


-- =====================================================
-- BULK INSERT PROMOTIONS
-- =====================================================

BULK INSERT Promotions
FROM 'C:\Users\USER\Desktop\Excellenc\CLEANED_DATA\Cleaned_Promotions.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);


-- =====================================================
-- BULK INSERT CUSTOMERS
-- =====================================================

BULK INSERT Customers
FROM 'C:\Users\USER\Desktop\Excellenc\CLEANED_DATA\Cleaned_Customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);


-- =====================================================
-- CHECK DATA
-- =====================================================

SELECT TOP 10 * FROM Sales;

SELECT TOP 10 * FROM Products;

SELECT TOP 10 * FROM Inventory;

SELECT TOP 10 * FROM Returns_Data;

SELECT TOP 10 * FROM Vendor;

SELECT TOP 10 * FROM Promotions;

SELECT TOP 10 * FROM Customers;


-- =========================================
-- 1. TOP 10 PROFIT LEAKING SKUs
-- =========================================

SELECT TOP 10
    s.SKU_ID,
    p.SKU_Name,

    SUM(
        (CAST(s.Selling_Price AS FLOAT) *
         CAST(s.Quantity AS FLOAT))

        -

        (CAST(p.Unit_Cost AS FLOAT) *
         CAST(s.Quantity AS FLOAT))

        -

        CAST(s.Discount_Amount AS FLOAT)

    ) AS Profit

FROM Sales s

JOIN Products p
ON s.SKU_ID = p.SKU_ID

GROUP BY
    s.SKU_ID,
    p.SKU_Name

ORDER BY Profit ASC;



-- =========================================
-- 2. STORES WITH HIGHEST DISCOUNT
-- =========================================

SELECT
    Store_ID,

    SUM(
        CAST(Discount_Amount AS FLOAT)
    ) AS Total_Discount

FROM Sales

GROUP BY Store_ID

ORDER BY Total_Discount DESC;



-- =========================================
-- 3. CATEGORY RETURN LOSS
-- =========================================

SELECT
    p.Category,

    SUM(
        CAST(r.Refund_Amount AS FLOAT)
    ) AS Return_Loss

FROM Returns_Data r

JOIN Products p
ON r.SKU_ID = p.SKU_ID

GROUP BY p.Category

ORDER BY Return_Loss DESC;



-- =========================================
-- 4. PROMOTION PROFITABILITY
-- =========================================

SELECT
    s.Promo_ID,

    SUM(
        (CAST(s.Selling_Price AS FLOAT) *
         CAST(s.Quantity AS FLOAT))

        -

        CAST(s.Discount_Amount AS FLOAT)

    ) AS Promo_Profit

FROM Sales s

GROUP BY s.Promo_ID

ORDER BY Promo_Profit DESC;



-- =========================================
-- 5. VENDOR DELAY
-- =========================================

SELECT
    Vendor_ID,
    Store_ID,

    DATEDIFF(
        DAY,
        TRY_CONVERT(DATE, Expected_Delivery_Date),
        TRY_CONVERT(DATE, Actual_Delivery_Date)
    ) AS Delay_Days

FROM Vendor;



-- =========================================
-- 6. STOCKOUT FREQUENCY
-- =========================================

SELECT
    SKU_ID,
    Store_ID,

    COUNT(*) AS Stockout_Count

FROM Inventory

WHERE CAST(Closing_Stock AS FLOAT) = 0

GROUP BY
    SKU_ID,
    Store_ID

ORDER BY Stockout_Count DESC;



-- =========================================
-- 7. CUSTOMER COHORT
-- =========================================

SELECT
    Customer_ID,

    MIN(
        TRY_CONVERT(DATE, Order_Date)
    ) AS First_Order

FROM Sales

GROUP BY Customer_ID;



-- =========================================
-- 8. RFM SCORING
-- =========================================

SELECT

    Customer_ID,

    COUNT(Order_ID) AS Frequency,

    SUM(
        CAST(Selling_Price AS FLOAT) *
        CAST(Quantity AS FLOAT)
    ) AS Monetary

FROM Sales

GROUP BY Customer_ID;




