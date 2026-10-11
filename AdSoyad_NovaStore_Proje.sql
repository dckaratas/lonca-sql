/* ================================================================
   NovaStore E-Ticaret Veri Yönetim Sistemi
   Hazırlayan : Ad Soyad            -- TODO: adını yaz, dosya adını da değiştir
   Ortam      : Microsoft SQL Server (T-SQL)
   ================================================================ */


/* ================================================================
   BÖLÜM 1: VERİ TABANI TASARIMI (DDL)
   ================================================================ */

-- 1. Veri tabanı oluşturma
-- (Türkçe karakterlerin varchar sütunlarda doğru saklanması için Turkish collation)
IF DB_ID('NovaStoreDB') IS NOT NULL
BEGIN
    ALTER DATABASE NovaStoreDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NovaStoreDB;
END
GO

CREATE DATABASE NovaStoreDB COLLATE Turkish_CI_AS;
GO

USE NovaStoreDB;
GO

-- 2-A. Categories (ana tablo)
CREATE TABLE Categories (
    CategoryID   INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);

-- 2-C. Customers (ana tablo)
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName   VARCHAR(50),
    City       VARCHAR(20),
    Email      VARCHAR(100) UNIQUE
);

-- 2-B. Products (Categories'e bağlı)
CREATE TABLE Products (
    ProductID   INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price       DECIMAL(10,2),
    Stock       INT DEFAULT 0,
    CategoryID  INT FOREIGN KEY REFERENCES Categories(CategoryID)
);

-- 2-D. Orders (Customers'a bağlı)
CREATE TABLE Orders (
    OrderID     INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID  INT FOREIGN KEY REFERENCES Customers(CustomerID),
    OrderDate   DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2)
);

-- 2-E. OrderDetails (Orders ve Products'a bağlı ara tablo)
CREATE TABLE OrderDetails (
    DetailID  INT IDENTITY(1,1) PRIMARY KEY,
    OrderID   INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity  INT
);
GO


/* ================================================================
   BÖLÜM 2: VERİ GİRİŞİ (DML - INSERT)
   ================================================================ */

-- Görev 1: 5 kategori
INSERT INTO Categories (CategoryName) VALUES
('Elektronik'), ('Giyim'), ('Kitap'), ('Kozmetik'), ('Ev ve Yaşam');

-- Görev 2: Her kategoriden ürünler (toplam 12)
INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES
('Kablosuz Kulaklık',        1299.90, 35, 1),
('Akıllı Saat',              3499.00, 12, 1),
('Bluetooth Hoparlör',        899.50,  8, 1),
('Pamuklu Tişört',            249.90, 60, 2),
('Kot Pantolon',              749.00, 18, 2),
('Kışlık Mont',              1899.00,  5, 2),
('Suç ve Ceza',               129.00, 40, 3),
('Simyacı',                    95.00, 15, 3),
('Nemlendirici Krem',         189.90, 25, 4),
('Parfüm 100 ml',            1450.00,  7, 4),
('Seramik Kupa Seti',         329.00, 22, 5),
('Masa Lambası',              579.00, 10, 5);

-- Görev 3: 6 müşteri
INSERT INTO Customers (FullName, City, Email) VALUES
('Ahmet Yılmaz', 'İstanbul', 'ahmet.yilmaz@example.com'),
('Ayşe Demir',   'Ankara',   'ayse.demir@example.com'),
('Mehmet Kaya',  'İzmir',    'mehmet.kaya@example.com'),
('Zeynep Çelik', 'Bursa',    'zeynep.celik@example.com'),
('Can Öztürk',   'Antalya',  'can.ozturk@example.com'),
('Elif Şahin',   'Eskişehir','elif.sahin@example.com');

-- Görev 4: Farklı tarihlerde 10 sipariş (tutar, detaylardan hesaplanacak)
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES
(1, '2026-06-03 10:15', 0),
(2, '2026-06-18 14:40', 0),
(1, '2026-07-02 09:05', 0),
(3, '2026-07-21 19:30', 0),
(4, '2026-08-05 11:20', 0),
(5, '2026-08-19 16:45', 0),
(2, '2026-09-01 13:10', 0),
(6, '2026-09-14 20:00', 0),
(3, '2026-09-28 08:50', 0),
(1, '2026-10-05 17:25', 0);

INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES
(1, 1, 1), (1, 7, 2),
(2, 4, 3), (2, 9, 1),
(3, 2, 1),
(4, 5, 1), (4, 8, 2),
(5, 10, 1), (5, 11, 1),
(6, 3, 1), (6, 12, 1),
(7, 6, 1),
(8, 7, 1), (8, 8, 1), (8, 9, 2),
(9, 1, 2),
(10, 11, 2), (10, 4, 2);

-- Sipariş toplam tutarlarını detaylardan hesapla
UPDATE o
SET TotalAmount = t.Toplam
FROM Orders o
JOIN (
    SELECT od.OrderID, SUM(od.Quantity * p.Price) AS Toplam
    FROM OrderDetails od
    JOIN Products p ON p.ProductID = od.ProductID
    GROUP BY od.OrderID
) t ON t.OrderID = o.OrderID;
GO


/* ================================================================
   BÖLÜM 3: SORGULAMA VE ANALİZ (DQL)
   ================================================================ */

-- 3.1 Temel Listeleme: Stoğu 20'den az olan ürünler (stoğa göre azalan)
SELECT ProductName, Stock
FROM Products
WHERE Stock < 20
ORDER BY Stock DESC;

-- 3.2 JOIN: Hangi müşteri hangi tarihte sipariş vermiş?
SELECT c.FullName, c.City, o.OrderDate, o.TotalAmount
FROM Customers c
INNER JOIN Orders o ON o.CustomerID = c.CustomerID
ORDER BY o.OrderDate;

-- 3.3 Çoklu JOIN: Ahmet Yılmaz'ın aldığı ürünler, fiyatları ve kategorileri
SELECT c.FullName, p.ProductName, p.Price, cat.CategoryName
FROM Customers c
JOIN Orders o         ON o.CustomerID  = c.CustomerID
JOIN OrderDetails od  ON od.OrderID    = o.OrderID
JOIN Products p       ON p.ProductID   = od.ProductID
JOIN Categories cat   ON cat.CategoryID = p.CategoryID
WHERE c.FullName = 'Ahmet Yılmaz';

-- 3.4 Gruplama: Her kategoride kaç ürün var? (ürünü olmayan kategori de görünsün)
SELECT cat.CategoryName, COUNT(p.ProductID) AS UrunSayisi
FROM Categories cat
LEFT JOIN Products p ON p.CategoryID = cat.CategoryID
GROUP BY cat.CategoryName
ORDER BY UrunSayisi DESC;

-- 3.5 Ciro Analizi: Her müşterinin toplam cirosu (çoktan aza)
SELECT c.FullName, SUM(o.TotalAmount) AS ToplamCiro
FROM Customers c
JOIN Orders o ON o.CustomerID = c.CustomerID
GROUP BY c.FullName
ORDER BY ToplamCiro DESC;

-- 3.6 Zaman Analizi: Siparişlerin üzerinden kaç gün geçti?
SELECT OrderID, OrderDate, DATEDIFF(DAY, OrderDate, GETDATE()) AS GecenGun
FROM Orders
ORDER BY GecenGun DESC;
GO


/* ================================================================
   BÖLÜM 4: İLERİ SEVİYE VERİ TABANI NESNELERİ
   ================================================================ */

-- 4.1 VIEW: Sipariş özeti
CREATE VIEW vw_SiparisOzet AS
SELECT c.FullName    AS MusteriAdi,
       o.OrderDate   AS SiparisTarihi,
       p.ProductName AS UrunAdi,
       od.Quantity   AS Adet
FROM Customers c
JOIN Orders o        ON o.CustomerID = c.CustomerID
JOIN OrderDetails od ON od.OrderID   = o.OrderID
JOIN Products p      ON p.ProductID  = od.ProductID;
GO

SELECT * FROM vw_SiparisOzet ORDER BY SiparisTarihi;
GO

-- 4.2 BACKUP: Veri tabanını C:\Yedek\ klasörüne yedekle
-- (C:\Yedek klasörü önceden oluşturulmuş olmalı)
BACKUP DATABASE NovaStoreDB
TO DISK = 'C:\Yedek\NovaStoreDB.bak'
WITH FORMAT, INIT, NAME = 'NovaStoreDB Tam Yedek';
GO
