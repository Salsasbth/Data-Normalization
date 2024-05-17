/*
Author  : Salsa Sabitha Hurriyah  
  
Program ini dibuat untuk melakukan Data Exploration, Data Cleaning, dan Data Normalization
*/

/* 4. Relational Database & SQL */
BEGIN;
-- Membuat tabel Segment, Seg_ID merupakan primary key dan Segment merupakan isi tabel
CREATE TABLE IF NOT EXISTS Segment (
    Seg_ID VARCHAR PRIMARY KEY,
    Segment VARCHAR(100) 
    );
-- Insert data tabel Segment dari file csv
COPY Segment(Seg_ID, Segment)
FROM 'C:\tmp\GC2\Segment.csv'
DELIMITER ','
CSV HEADER;
-- Savepoint untuk mengembalikan status transaksi (roll back)
SAVEPOINT Segment;

-- Membuat tabel Country, Country_ID merupakan primary key dan Country merupakan isi tabel
CREATE TABLE IF NOT EXISTS Country (
	Country_ID VARCHAR PRIMARY KEY,
	Country VARCHAR(100)
	);
-- Insert data tabel Country dari file csv
COPY Country(Country_ID, Country)
FROM 'C:\tmp\GC2\Country.csv'
DELIMITER ','
CSV HEADER;
-- Savepoint untuk mengembalikan status transaksi (roll back)
SAVEPOINT Country;

-- Membuat tabel Discount, Discount_ID merupakan primary key dan Discount merupakan isi tabel
CREATE TABLE IF NOT EXISTS Discount (
	Discount_ID VARCHAR PRIMARY KEY,
	Discount_Band VARCHAR(100)
	);
-- Insert data tabel Discount dari file csv
COPY Discount(Discount_ID, Discount_Band)
FROM 'C:\tmp\GC2\Discount.csv'
DELIMITER ','
CSV HEADER;
-- Savepoint untuk mengembalikan status transaksi (roll back)
SAVEPOINT Discount;

-- Membuat tabel Product, Product_ID merupakan primary key, Product dan Manufacturing_Price merupakan isi tabel
CREATE TABLE IF NOT EXISTS Product (
	Product_ID VARCHAR PRIMARY KEY,
	Product VARCHAR(100),
	Manufacturing_Price FLOAT
	);
-- Insert data tabel Product dari file csv
COPY Product(Product_ID, Product, Manufacturing_Price)
FROM 'C:\tmp\GC2\Product.csv'
DELIMITER ','
CSV HEADER;
-- Savepoint untuk mengembalikan status transaksi (roll back)
SAVEPOINT Product;

-- Membuat tabel MainTable, MainTable_ID merupakan primary key dan Product merupakan isi tabel
CREATE TABLE MainTable(
	MainTable_ID SERIAL PRIMARY KEY,
	SegmentID VARCHAR(10) REFERENCES Segment(Seg_ID),
	CountryID VARCHAR(10) REFERENCES Country(Country_ID),
	ProductID VARCHAR(10) REFERENCES Product(Product_ID),
	DiscountID VARCHAR(10) REFERENCES Discount(Discount_ID),
	Units_Sold INT,
	Manufacturing_Price FLOAT,
	Sale_Price FLOAT,
	Gross_Sales FLOAT,
	Discounts FLOAT,
	Sales FLOAT,
	COGS FLOAT,
	Profit FLOAT,
	Date DATE
	);
-- Insert data tabel MainTable dari file csv
COPY MainTable(SegmentID,CountryID,ProductID,DiscountID,Units_Sold,Manufacturing_Price,Sale_Price,Gross_Sales,Discounts,Sales,COGS,Profit,Date)
FROM 'C:\tmp\GC2\MainTable.csv'
DELIMITER ','
CSV HEADER;
-- Savepoint untuk mengembalikan status transaksi (roll back)
SAVEPOINT MainTable;

COMMIT;

-- Pembuatan user
-- Pembuatan user_1 
CREATE USER user_1 WITH PASSWORD '12345';

-- Pembuatan user_2
CREATE USER user_2 WITH PASSWORD '54321';


-- Pemberian akses query
-- Pemberian akses query SELECT kepada user_1
GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC TO user_1;

-- Block akses query INSERT,UPDATE,TRUNCATE,DELETE kepada user_1
REVOKE INSERT,UPDATE,TRUNCATE,DELETE ON ALL TABLES IN SCHEMA PUBLIC FROM user_1;

-- Pemberian akses semua query kepada user_2 
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA PUBLIC TO user_2;

/* 5.1.
a. Berikan tabel yang berisikan informasi total profit yang didapatkan di tiap jenis segmentasi. Jangan ambil data yang tidak diskon.
b. Berikan tabel yang berisikan informasi rangkuman statistik yang memuat nilai rata-rata, min, dan max (dijadikan dalam kolom yang berbeda) dari Sales masing-masing negara. 
*/
-- 5.1.a
COPY (  
SELECT
	Segment.Segment,
	SUM(MainTable.Profit) AS total_profit
FROM MainTable  
JOIN Segment ON Segment.Seg_id = MainTable.SegmentID 
JOIN Discount ON Discount.Discount_ID = MainTable.DiscountID  
WHERE Discount.Discount_Band != 'None'  
GROUP BY Segment.Segment
ORDER BY 2 DESC
)  
TO 'C:\tmp\GC2\5_1_a.csv' WITH CSV 
DELIMITER ',' 
HEADER ;

-- 5.1.b
COPY(  
SELECT
	Country.country,
	SUM(MainTable.sales) AS Total_sales,
	MIN(MainTable.sales) AS Min_sales,
	MAX(MainTable.sales) AS Max_sales
FROM MainTable  
JOIN Country ON Country.country_id = MainTable.CountryID
GROUP BY Country.country
ORDER BY 2 DESC
)  
TO 'C:\tmp\GC2\5_1_b.csv' WITH CSV 
DELIMITER ',' 
HEADER ;
