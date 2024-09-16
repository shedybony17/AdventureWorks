# **Adventure Works Analysis**
##  Overview
<div align="justify">
This project aims to perform an in-depth analysis of sales data, customer demographics, and product information to reveal intricate relationships and generate valuable insights. The goal is to help Adventure Works leverage these insights to craft more effective sales strategies, enhance product offerings, and design targeted marketing campaigns, bringing about sustained growth and improving customer satisfaction.</div>

##  This project was broken into weekly tasks;
<div align="justify">Week one focuses on Database Setup, importing of datasets, creating a data star schema by creating relationship keys between tables as well as initial data cleaning, thereby preparing the data for data analysis.</div>

## Prerequisite
SQLite or DV Browser for SQLite (recommended) is required in order to run the queries in the SQL file i uploaded in this repository.


## Datasets Import
The datasets used for this project were CSV files which were stored on a Google Drive, and they were imported using DB Browser for SQLite.
The tables imported were sales (for 2015, 2016, and 2017), Rerturns, Product, Customer, Territory, Product, Product_Categories, Product_Subcategories.

## Database Schema Overview

### Fact Tables
#### 1. FactSales
Contains sales transactions data:

- OrderNumber: TEXT, Unique identifier for the order (Primary Key)
- OrderLineItem: INTEGER, Line item number within an order (Primary Key)
- ProductKey: INTEGER, Foreign Key to DimProducts.
- CustomerKey: INTEGER, Foreign Key to DimCustomers
- SalesTerritoryKey: INTEGER, Foreign Key to DimTerritories
- OrderDate: TEXT, Foreign Key to DimCalendar
- StockDate: TEXT
- OrderQuantity: INTEGER
#### 2. FactReturns
Contains product return information:

- ReturnIndex: INTEGER, Primary Key (AUTOINCREMENT)
- TerritoryKey: INTEGER, Foreign Key to DimTerritories
- ProductKey: INTEGER, Foreign Key to DimProducts
- ReturnQuantity: INTEGER, Number of products returned

### Dimension Tables

#### 1. Products
Contains product details: 

- ProductKey: INTEGER, Primary Key
- ProductSubcategoryKey: INTEGER
- ProductSKU: TEXT, Stock Keeping Unit
- ProductName: TEXT
- ModelName: TEXT
- ProductDescription: TEXT
- ProductColor: TEXT
- ProductSize: TEXT
- ProductStyle: TEXT
- ProductCost: REAL
- ProductPrice: REAL

#### 2. Customers
Stores customer details:

- CustomerKey: INTEGER, Primary Key
- Prefix: TEXT (e.g., Mr., Mrs.)
- FirstName: TEXT
- LastName: TEXT
- BirthDate: TEXT
- MaritalStatus: TEXT
- Gender: TEXT
- EmailAddress: TEXT
- AnnualIncom: REAL
- TotalChildren: INTEGER
- EducationLevel: TEXT
- Occupation: TEXT
- HomeOwner: TEXT
  
#### 3. Territories
Contains information about sales territories:

- SalesTerritoryKey: INTEGER, Primary Key
- Region: TEXT
- Country: TEXT
- Continent: TEXT
- OrderDate: TEXT

#### 4. Calendar
Stores date-related information for time-based analysis:

- Date: TEXT (Primary Key)
- Year: INTEGER
- Month: INTEGER

#### 5. Product_Categories
Contains product category information:

- ProductCategoryKey: INTEGER, Primary Key.
- CategoryName: TEXT

#### 6. Product_Subcategories
Contains detailed information about product subcategories:

- ProductSubcategoryKey: INTEGER, Primary Key
- SubcategoryName: TEXT
- ProductCategoryKey: INTEGER

### Foreign Key Relationships

- FactSales(ProductKey) → Products(ProductKey)
- FactSales(CustomerKey) → Customers(CustomerKey)
- FactSales(SalesTerritoryKey) → Territories(SalesTerritoryKey)
- FactSales(OrderDate) → Calendar(OrderDate)
- FactReturns(ProductKey) → Products(ProductKey)
- FactReturns(TerritoryKey) → Territories(SalesTerritoryKey)
- DimProducts(ProductSubcategoryKey) → DimProductSubcategories(ProductSubcategoryKey)
- DimProductSubcategories(ProductCategoryKey) → DimProductCategories(ProductCategoryKey)

##  Useful Relationships Summary
- FactSales and FactReturns reference dimension tables through foreign keys to ensure data integrity and enable detailed analysis.
- Products is linked to DimProductSubcategories and DimProductCategories to provide hierarchical product data.

## Usage Notes
- Fact Tables: Use for transaction-based queries and aggregations
- Dimension Tables: Use for descriptive and categorical analysis
- Ensure foreign key relationships are correctly established to maintain data integrity
- Use the fact tables for querying transactional data and dimension tables for descriptive attributes


## Files in This Repository
#### 1. SQL Script File (AdventuresWorksQueryScript.sql)
This file contains all SQL commands used to create the star schema, including:

- Table creation: Defines fact and dimension tables with explicit column definitions
- Primary and foreign keys: Sets up constraints linking the tables for referential integrity.
- Data cleanup: Scripts to check for null or duplicate values and ensure data integrity.
- Relationship checks: Queries to validate if the star schema relationships between tables are well-defined.
  
#### 2. ER Diagram (ERDiagram.png)

An ER diagram depicting the star schema, with fact tables at the center and dimension tables connected to them. The diagram provides a visual representation of the relationships between:

- FactSales table with the Products, Customers, Territories, and Calendar tables.
- FactReturns table linked to Products and Territories tables.

#### 3. README File (README.md)
This file provides an overview of the week one project task, instructions for reproducing the schema, and additional project details.

##This is the png file of the ERDiagram for this project

![](ERDiagram_Adventure_Works.png)
