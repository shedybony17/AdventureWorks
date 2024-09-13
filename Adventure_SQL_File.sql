
PRAGMA foreign_keys = ON;
-- Import of tables (Csv formats) USING DB browser for SQLite
-- File - Import -> Table from CSV file
--Tables imported: Adventure_Sales_2015, Adventure_Sales_2016, Adventure_Sales_2017, Adventure_Customers, Adventure_Returns, Adventure_Products, Adventure_Product_Categories, Adventure_Product_Subcategories, Adventure_Calendar and Adventure_Territories

--combine multiple sales tables into a unified FactSales table

CREATE TABLE FactSales AS 
SELECT * FROM AdventureWorks_Sales_2015
UNION ALL
SELECT * FROM AdventureWorks_Sales_2016
UNION ALL
SELECT * FROM AdventureWorks_Sales_2017;

SELECT COUNT(*)FROM FactSales AS count;

-- Rename tables for better identification of Facts and Dimension tables

ALTER TABLE AdventureWorks_Returns RENAME TO FactReturns;
ALTER TABLE AdventureWorks_Products RENAME TO DimProducts;
ALTER TABLE AdventureWorks_Customers RENAME TO DimCustomers;
ALTER TABLE AdventureWorks_Calendar RENAME TO DimCalendar;
ALTER TABLE AdventureWorks_Product_Categories RENAME TO DimProduct_Categories;
ALTER TABLE AdventureWorks_Product_Subcategories RENAME TO DimProduct_Subcategories;
ALTER TABLE AdventureWorks_Territories RENAME TO DimTerritories;

-- Dropping Redundant Tables (sales tables for 2015, 2016 and 2017)

DROP TABLE IF EXISTS AdventureWorks_Sales_2015;

DROP TABLE IF EXISTS AdventureWorks_Sales_2016;

DROP TABLE IF EXISTS AdventureWorks_Sales_2017;

--Defining primary Keys and foreign keys for all Tables
----This ensures that all records in each table can be referenced by other tables using foreign keys

-----FactSales_New table is created to capture the introduced contraints, and the data in FactSales is tranferred
--------Description: Contains sales transactions data.
--------Columns::
--------OrderNumber: Unique identifier for the order.
--------OrderLineItem: Line item number within an order.
--------ProductKey: Foreign key to DimProducts.
--------CustomerKey: Foreign key to DimCustomers.
--------TerritoryKey: Foreign key to DimTerritories.


DROP TABLE IF EXISTS FactSales_New;
CREATE TABLE FactSales_New (
	OrderDate DATE,
	StockDate DATE,
	OrderNumber TEXT,
    OrderLineItem INTEGER,
    ProductKey INTEGER,
	OrderQuantity INTEGER,
    CustomerKey INTEGER,
    TerritoryKey INTEGER,
    PRIMARY KEY (OrderNumber, OrderLineItem)
	);

----Copy Data from the Old FactSales to the New FactSales_New

INSERT INTO FactSales_New (OrderDate, StockDate, OrderNumber, OrderLineItem, ProductKey, OrderQuantity, CustomerKey, TerritoryKey)
SELECT OrderDate, StockDate, OrderNumber, OrderLineItem, ProductKey, OrderQuantity, CustomerKey, TerritoryKey
FROM FactSales;

----Recreating the FactSales Table in other to introduce the foreign keys as it flagged up error when i did earlier
	
CREATE TABLE FactSales (
	OrderDate DATE,
	StockDate DATE,
	OrderNumber TEXT,
    OrderLineItem INTEGER,
    ProductKey INTEGER,
	OrderQuantity INTEGER,
    CustomerKey INTEGER,
    TerritoryKey INTEGER,
    PRIMARY KEY (OrderNumber, OrderLineItem),
    FOREIGN KEY (ProductKey) REFERENCES DimProducts(ProductKey),
    FOREIGN KEY (CustomerKey) REFERENCES DimCustomers(CustomerKey),
    FOREIGN KEY (TerritoryKey) REFERENCES DimTerritories(SalesTerritoryKey),
    FOREIGN KEY (OrderDate) REFERENCES DimCalendar_New(OrderDate)
);

---Tansferring the data into the FactSales Table with defined foreign keys
INSERT INTO FactSales (OrderDate, StockDate, OrderNumber, OrderLineItem, ProductKey, OrderQuantity, CustomerKey, TerritoryKey)
SELECT OrderDate, StockDate, OrderNumber, OrderLineItem, ProductKey, OrderQuantity, CustomerKey, TerritoryKey
FROM FactSales_New;


--Creating the Dimension table for Calender

CREATE TABLE DimCalendar_New (
    OrderDate TEXT,
    Year INTEGER,
    Month INTEGER
	PRIMARY KEY (OrderDate)
	);
	
		
----Moving in data from previous table
INSERT INTO DimCalendar_New (OrderDate, Year, Month)
SELECT 
    Date ,
    CAST(substr(Date, -4) AS INTEGER) AS Year,  -- Extract year
    CAST(substr(Date, 1, 2) AS INTEGER) AS Month  -- Extract month
    FROM DimCalendar;

 ---- Deleting the former Calender table
DROP TABLE DimCalendar;


--- Creating DimReturns Table with Constraints (primary and foreign keys

CREATE TABLE FactReturns_New (
    ReturnID INTEGER,
    ReturnDate DATE,
    ProductKey INTEGER,
    TerritoryKey INTEGER,
    ReturnQuantity INTEGER,
    PRIMARY KEY (ReturnID)
	);

INSERT INTO FactReturns_New (ReturnDate, ProductKey, TerritoryKey, ReturnQuantity)
SELECT ReturnDate, ProductKey, TerritoryKey, ReturnQuantity
FROM FactReturns;

DROP TABLE FactReturns; 
--- drop the previous returns table

CREATE TABLE FactReturns (
    ReturnID INTEGER,
    ReturnDate DATE,
    ProductKey INTEGER,
    TerritoryKey INTEGER,
    ReturnQuantity INTEGER,
	PRIMARY KEY (ReturnID)
    FOREIGN KEY (ReturnDate) REFERENCES DimCalendar_New(OrderDate),
    FOREIGN KEY (ProductKey) REFERENCES DimProducts(ProductKey),
    FOREIGN KEY (TerritoryKey) REFERENCES DimTerritories(SalesTerritoryKey)
);

INSERT INTO FactReturns (ReturnDate, ProductKey, TerritoryKey, ReturnQuantity)
SELECT ReturnDate, ProductKey, TerritoryKey, ReturnQuantity
FROM FactReturns_New;



--- drop the previous returns table
DROP TABLE FactReturns_New;


---fOR THE dimension tables like DimTerritories, DimProducts,DimProduct_Categories, and DimProduct_Subcategories, their primary keys and foreign keys were defined using the gui interface of DB browser for SQLite
-------Database Structure -- (select the tabble to use) - Modify Table -
-------and define tick the fields boxes to define them as primary keys and foreign keys

----Reconfirming  the Constraints on the fact tables
PRAGMA foreign_key_list(FactSales);
PRAGMA foreign_key_list(FactReturns);

---- Testing the schema using sample queries to ensure everything is functioning correctly (verification of data integrity)
-------Query 1: Selecting Total Sales by Product and Year

SELECT P.ProductName,C.Year AS Year,
       ROUND(SUM(S.OrderQuantity * P.ProductPrice), 2) AS TotalSales
FROM FactSales S
JOIN DimProducts P ON S.ProductKey = P.ProductKey
JOIN DimCalendar_New C ON S.OrderDate = C.OrderDate
GROUP BY P.ProductName, strftime('%Y', C.OrderDate);

-------Query 2: Selecting Total Returns by Region

SELECT T.Region, SUM(R.ReturnQuantity) AS TotalReturns
FROM FactReturns R
JOIN DimTerritories T ON R.TerritoryKey = T.SalesTerritoryKey
GROUP BY T.Region;