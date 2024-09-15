----Firtsly, in defining star schema relationship between the tables, the sales tables and 
----the returns table were chosen to be the Fact tables, while others such as 
----Calendar, Product, ProductCategory, ProductSubcategory, Territory were chosen as Dimension tables

------I checked the struture of the sales tables to ensure
------they are consistent with each other in terms of fields and data types using the following queries:

PRAGMA table_info(AdventureWorks_Sales_2015);
PRAGMA table_info(AdventureWorks_Sales_2016);
PRAGMA table_info(AdventureWorks_Sales_2017);

-----A central FactSales table was created to bring the sales records (2015-2017) into one table

CREATE TABLE FactSale(
	"OrderDate" TEXT,
	"StockDate" TEXT,
	"OrderNumber" TEXT,
	"OrderLineItem" INTEGER,
	"ProductKey" INTEGER,
	"CustomerKey" INTEGER,
	"TerritoryKey" INTEGER,
	"OrderQuantity" INTEGER
	);
	
-----The records from AdventureWorks_Sales_2015, AdventureWorks_Sales_2016, and 
-----AdventureWorks_Sales_2017 was transferred in;
	
INSERT INTO FactSale(OrderDate, StockDate, OrderNumber, OrderLineItem, ProductKey, CustomerKey, TerritoryKey, OrderQuantity)
SELECT OrderDate, StockDate, OrderNumber, OrderLineItem, ProductKey, CustomerKey, TerritoryKey, OrderQuantity
FROM AdventureWorks_Sales_2015;

INSERT INTO FactSale(OrderDate, StockDate, OrderNumber, OrderLineItem, ProductKey, CustomerKey, TerritoryKey, OrderQuantity)
SELECT OrderDate, StockDate, OrderNumber, OrderLineItem, ProductKey, CustomerKey, TerritoryKey, OrderQuantity
FROM AdventureWorks_Sales_2016;

INSERT INTO FactSale(OrderDate, StockDate, OrderNumber, OrderLineItem, ProductKey, CustomerKey, TerritoryKey, OrderQuantity)
SELECT OrderDate, StockDate, OrderNumber, OrderLineItem, ProductKey, CustomerKey, TerritoryKey, OrderQuantity
FROM AdventureWorks_Sales_2017;	

----To avoid redundancy, old sales tables were deleted

drop TABLE AdventureWorks_Sales_2015; 
drop TABLE AdventureWorks_Sales_2016; 
drop TABLE AdventureWorks_Sales_2017;

---The structure of the calendar table was confirmed using the following query:
PRAGMA table_info(AdventureWorks_Calendar);

----In other to be able to view trends, its best to introduce Month and Year 
----into the Calendar table, therefore a new table was created using the query;
CREATE TABLE Calendar(
	"OrderDate" TEXT,
	"Year" TEXT,
	"Month" TEXT,
	"Month_Name" TEXT,
	PRIMARY KEY (OrderDate)
);

---Transfer of data to the New Calendar table while also casting the date data into the month and year columns;
INSERT INTO Calendar(OrderDate, Year, Month, Month_Name)
SELECT Date,
	CAST(Substr(Date, -4) as INTEGER) as Year,
	CAST(Substr(Date, 1, 2) as INTEGER) as Month,
	CASE
		WHEN CAST(Substr(Date, 1, 2) as INTEGER)=1 THEN "January"
		WHEN CAST(Substr(Date, 1, 2) as INTEGER) = 2 THEN "February"
		WHEN CAST(Substr(Date, 1, 2) as INTEGER) = 3 THEN "March"
		WHEN CAST(Substr(Date, 1, 2) as INTEGER) = 4 THEN "April"
		WHEN CAST(Substr(Date, 1, 2) as INTEGER) = 5 THEN "May"
		WHEN CAST(Substr(Date, 1, 2) as INTEGER) = 6 THEN "June"
		WHEN CAST(Substr(Date, 1, 2) as INTEGER) = 7 THEN "July"
		WHEN CAST(Substr(Date, 1, 2) as INTEGER) = 8 THEN "August"
		WHEN CAST(Substr(Date, 1, 2) as INTEGER) = 9 THEN "September"
		WHEN CAST(Substr(Date, 1, 2) as INTEGER) = 10 THEN "October"
		WHEN CAST(Substr(Date, 1, 2) as INTEGER) = 11 THEN "November"
		WHEN CAST(Substr(Date, 1, 2) as INTEGER) = 12 THEN "December"
	END AS Month_Name
FROM AdventureWorks_Calendar;

DROP TABLE AdventureWorks_Calendar; --To avoid table redundancy

------The other tables were renamed for easy identification;
ALTER TABLE AdventureWorks_Returns RENAME TO FactReturn;
ALTER TABLE AdventureWorks_Products RENAME TO Product;
ALTER TABLE AdventureWorks_Customers RENAME TO Customer;
ALTER TABLE AdventureWorks_Product_Categories RENAME TO Product_Category;
ALTER TABLE AdventureWorks_Product_Subcategories RENAME TO Product_Subcategory;
ALTER TABLE AdventureWorks_Territories RENAME TO Territory;



-----RECREATING NEW TABLES FOR IN ORDER TO INTRODUCE CONSTRAINTS
------LIKE PRRIMARY KEYS AND FOREIGN KEYS

PRAGMA FOREIGN_KEYS = ON; --- This enables foreign key support in SQLite

----The Structure of the Customer table was inspected;
PRAGMA table_info(Customer);

----A new Customers table was created, having CustomerKey as its defined PRIMARY KEY;
CREATE TABLE Customers (
	"CustomerKey" INTEGER,
	"Prefix" TEXT,
	"FirstName" TEXT,
	"LastName" TEXT,
	"BirthDate" TEXT,
	"MaritalStatus" TEXT,
	"Gender" TEXT,
	"EmailAddress" TEXT,
	"AnnualIncome" TEXT,
	"TotalChildren" INTEGER,
	"EducationLevel" TEXT,
	"Occupation" TEXT,
	"HomeOwner" TEXT,
PRIMARY KEY (CustomerKey)
);

---Transfer of data to the new Customers table;
INSERT INTO Customers(CustomerKey,FirstName,LastName,BirthDate,MaritalStatus,Gender,EmailAddress,
AnnualIncome,TotalChildren, EducationLevel,Occupation,HomeOwner)
SELECT CustomerKey,FirstName,LastName,BirthDate,MaritalStatus,Gender,EmailAddress,
AnnualIncome,TotalChildren, EducationLevel,Occupation,HomeOwner
FROM Customer;

DROP TABLE Customer; --- To avoid redundancy


---- The Structure of the Product_Category was inspected
PRAGMA table_info(Product_Category);

----A new Product_Category table was created, having ProductCategoryKey as its defined PRIMARY KEY;
CREATE TABLE Products_Categories(
	"ProductCategoryKey" INTEGER,
	"CategoryName" TEXT,
	PRIMARY KEY (ProductCategoryKey)
);


---Transfer of data to the new Products_Categories table;
INSERT INTO Products_Categories(ProductCategoryKey, CategoryName)
SELECT ProductCategoryKey, CategoryName
FROM Product_Category;

DROP TABLE Product_Category; ---- To avoid redundancy


---- The Structure of the Product_Subcategory was inspected;
PRAGMA table_info(Product_Subcategory);

----A new Product_Subcategories table was created, having ProductSubcategoryKey as its defined PRIMARY KEY
----and ProductCategoryKey as its FOREIGN KEY

CREATE TABLE Product_Subcategories(
	"ProductSubcategoryKey" INTEGER,
	"SubcategoryName" TEXT,
	"ProductCategoryKey" INTEGER,
	PRIMARY KEY(ProductSubcategoryKey),
	FOREIGN KEY ("ProductCategoryKey") REFERENCES "Products_Categories" ("ProductCategoryKey")
);

---Transfer of data to the new Product_Subcategories table;
INSERT INTO Product_Subcategories(ProductSubcategoryKey, SubcategoryName, ProductCategoryKey)
SELECT ProductSubcategoryKey, SubcategoryName, ProductCategoryKey
FROM Product_Subcategory;

DROP TABLE Product_Subcategory;  --- To avoid redundancy

-----The Structure of the Product table was inspected
PRAGMA table_info(Product);

----A new Products table was created, having ProductKey as its defined PRIMARY KEY
----and ProductSubcategoryKey as its FOREIGN KEY

CREATE TABLE Products(
	"ProductKey" INTEGER,
	"ProductSubcategoryKey" INTEGER,
	"ProductSKU" TEXT,
	"ProductName" TEXT,
	"ModelName"	TEXT,
	"ProductDescription" TEXT,
	"ProductColor" TEXT,
	"ProductSize" TEXT,
	"ProductStyle" TEXT,
	"ProductCost" REAL,
	"ProductPrice"	REAL,
	PRIMARY KEY (ProductKey),
	FOREIGN KEY ("ProductSubcategoryKey") REFERENCES "Product_Subcategories" ("ProductSubcategoryKey")
);


---Transfer of data to the new Products table;
INSERT INTO Products(ProductKey, ProductSubcategoryKey, ProductSKU,ProductName, ModelName,
 ProductDescription, ProductColor, ProductSize, ProductStyle, ProductCost, ProductPrice)
 SELECT ProductKey, ProductSubcategoryKey, ProductSKU,ProductName, ModelName,
 ProductDescription, ProductColor, ProductSize, ProductStyle, ProductCost, ProductPrice
 FROM Product;

DROP TABLE Product; --- To avoid redundancy


-----The Structure of the Territory table was inspected
PRAGMA table_info(Territory);

----A new Territories table was created, having SalesTerritoryKey as its defined PRIMARY KEY
CREATE TABLE Territories(
	"SalesTerritoryKey" INTEGER,
	"Region" TEXT,
	"Country" TEXT,
	"Continent" TEXT,
	PRIMARY KEY (SalesTerritoryKey)
);

---Transfer of data to the new Territories table;
INSERT INTO Territories(SalesTerritoryKey, Region, Country, Continent)
SELECT SalesTerritoryKey, Region, Country, Continent
FROM Territory;

DROP TABLE Territory; --- To avoid redundancy

----The Structure of the FactSale table was inspected;
-------FIRSTLY: Checked if OrderNumber is duplicate free accross the rows
SELECT OrderNumber, COUNT(*) as count
FROM FactSale
GROUP BY OrderNumber
HAVING COUNT(*)>1; --- The result showed that it was

------SECONDLY, Checked if using OrderNumber alongside OrderLineItem could uniquely identify the rows
SELECT OrderNumber, OrderLineItem, COUNT(*) as count
FROM FactSale
GROUP BY OrderNumber, OrderLineItem
HAVING COUNT(*)>1; -----There result showed that they did


----A new FactSales table was created, having OrderNumber and OrderLineItem
----as its defined COMPOSITE KEY (More than one PRIMARY KEY)
-----The defined FOREIGN KEYS were ProductKey, CustomerKey, TerritoryKey, and OrderDate
CREATE TABLE FactSales(
	"OrderDate" TEXT,
	"StockDate" TEXT,
	"OrderNumber" TEXT,
	"OrderLineItem" INTEGER,
	"ProductKey" INTEGER,
	"CustomerKey" INTEGER,
	"TerritoryKey" INTEGER,
	"OrderQuantity" INTEGER,
	PRIMARY KEY (OrderNumber, OrderLineItem),
	FOREIGN KEY (ProductKey) REFERENCES Products(ProductKey),
	FOREIGN KEY (CustomerKey) REFERENCES Customers(CustomerKey),
	FOREIGN KEY (TerritoryKey) REFERENCES Territories(SalesTerritoryKey),
	FOREIGN KEY (OrderDate) REFERENCES Calendar(OrderDate)
);
	
---Transfer of data to the new FactSales table;
INSERT INTO FactSales(OrderDate, StockDate, OrderNumber, OrderLineItem, ProductKey, CustomerKey, TerritoryKey, OrderQuantity)
SELECT OrderDate, StockDate, OrderNumber, OrderLineItem, ProductKey, CustomerKey, TerritoryKey, OrderQuantity
FROM FactSale;
	
DROP TABLE FactSale; --- To avoid redundancy

----The Structure of the FactReturn table was inspected;	
PRAGMA table_info(FactReturn);

----A new FactReturns table was created, having ReturnIndex as its PRIMARY KEY,
----and its FOREIGN KEYS were TerritoryKey and ProductKey
CREATE TABLE FactReturns (
    "ReturnIndex" INTEGER PRIMARY KEY AUTOINCREMENT,
    "TerritoryKey" INTEGER,
    "ProductKey" INTEGER,
    "ReturnQuantity" INTEGER,
    FOREIGN KEY ("TerritoryKey") REFERENCES TerritorIES("SalesTerritoryKey"),
    FOREIGN KEY ("ProductKey") REFERENCES ProductS("ProductKey")
);

---Transfer of data to the new FactReturns table;
INSERT INTO FactReturns(TerritoryKey, ProductKey, ReturnQuantity)
SELECT TerritoryKey, ProductKey, ReturnQuantity
FROM FactReturn;

DROP TABLE FactReturn;   --- To avoid redundancy



---QUERYING TO TEST THE FUBCTIONALITY OF THE STAR SCHEMA ESTABLISHMENT
---BETWEEN THE FACT TABLES AND THE DIMENSION TABLES

---QUERY 1: Querying with the FactSales Table

------Checking the total sales of goods by product
SELECT P.ProductName, "$" || ROUND(SUM(S.OrderQuantity*P.ProductPrice),2) AS TotalSales
FROM FactSales S
JOIN Products P ON S.ProductKey = P.ProductKey
GROUP BY P.ProductName;

------Checking the Checking the total sales by Year and Month

SELECT C.Year, C.Month_Name, "$" || ROUND(SUM(S.OrderQuantity*P.ProductPrice),2) AS TotalSales
FROM FactSales S
JOIN Calendar C ON S.OrderDate = C.OrderDate
JOIN Products P ON S.ProductKey = P.ProductKey
GROUP BY C.Year, C.Month_Name;

---QUERY 2: Query with the FactReturns Table

------Checking the number of return cases by region
SELECT T.Region, COUNT(R.ReturnIndex) as ReturnCount
FROM FactReturns R
JOIN Territories T ON R.TerritoryKey = T.SalesTerritoryKey
GROUP BY T.Region;

------Checking the total cost of goods returned by region
SELECT T.Region, "$" || ROUND(SUM(R. ReturnQuantity*P.ProductPrice),2) AS Total_Cost_Of_Goods_Returned
FROM FactReturns R
JOIN Territories T ON R.TerritoryKey = T.SalesTerritoryKey
JOIN Products P ON R.ProductKey = P.ProductKey
GROUP BY T.Region;



SELECT T.Region, "$" || ROUND(SUM(S.OrderQuantity*P.ProductPrice),2) AS TotalSales
FROM FactSales S
JOIN Products P ON S.ProductKey = P.ProductKey
JOIN Territories T ON S.TerritoryKey = T.SalesTerritoryKey
GROUP BY T.Region;