/* ================================================================
   LoncaDB — Maceracılar Loncası Veri Tabanı
   NovaStore yapısının Lonca temasına uyarlanmış hali:
     Categories   -> ItemTypes      (eşya türleri)
     Products     -> Items          (demirci dükkanı eşyaları)
     Customers    -> Adventurers    (maceracılar)
     Orders       -> Purchases      (satın alımlar)
     OrderDetails -> PurchaseDetails
   + Tasks (lonca-api'deki görev panosu)
   ================================================================ */

IF DB_ID('LoncaDB') IS NOT NULL
BEGIN
    ALTER DATABASE LoncaDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LoncaDB;
END
GO

CREATE DATABASE LoncaDB COLLATE Turkish_CI_AS;
GO

USE LoncaDB;
GO

/* ---------------- TABLOLAR ---------------- */

CREATE TABLE ItemTypes (
    ItemTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeName   NVARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE Adventurers (
    AdventurerID INT IDENTITY(1,1) PRIMARY KEY,
    Name         NVARCHAR(50) NOT NULL,
    Class        NVARCHAR(20) NOT NULL,              -- Savaşçı, Büyücü, Okçu...
    GuildRank    CHAR(1) NOT NULL DEFAULT 'C'
                 CHECK (GuildRank IN ('S','A','B','C')),
    Gold         INT NOT NULL DEFAULT 100,
    JoinedAt     DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE Items (
    ItemID      INT IDENTITY(1,1) PRIMARY KEY,
    Name        NVARCHAR(100) NOT NULL,
    ItemTypeID  INT NOT NULL FOREIGN KEY REFERENCES ItemTypes(ItemTypeID),
    Rarity      NVARCHAR(20) NOT NULL
                CHECK (Rarity IN (N'Sıradan', N'Nadir', N'Epik', N'Efsanevi')),
    Price       INT NOT NULL,                        -- altın
    Stock       INT NOT NULL DEFAULT 0,
    Attack      INT NOT NULL DEFAULT 0,
    Defense     INT NOT NULL DEFAULT 0,
    Magic       INT NOT NULL DEFAULT 0,
    Description NVARCHAR(255)
);

CREATE TABLE Purchases (
    PurchaseID   INT IDENTITY(1,1) PRIMARY KEY,
    AdventurerID INT NOT NULL FOREIGN KEY REFERENCES Adventurers(AdventurerID),
    PurchaseDate DATETIME NOT NULL DEFAULT GETDATE(),
    TotalGold    INT NOT NULL DEFAULT 0
);

CREATE TABLE PurchaseDetails (
    DetailID   INT IDENTITY(1,1) PRIMARY KEY,
    PurchaseID INT NOT NULL FOREIGN KEY REFERENCES Purchases(PurchaseID),
    ItemID     INT NOT NULL FOREIGN KEY REFERENCES Items(ItemID),
    Quantity   INT NOT NULL CHECK (Quantity > 0)
);

CREATE TABLE Tasks (
    TaskID       INT IDENTITY(1,1) PRIMARY KEY,
    Title        NVARCHAR(100) NOT NULL,
    Description  NVARCHAR(500),
    Priority     VARCHAR(10) NOT NULL DEFAULT 'medium'
                 CHECK (Priority IN ('critical','high','medium','low')),  -- arayüzde S/A/B/C rütbesi
    Status       VARCHAR(20) NOT NULL DEFAULT 'open'
                 CHECK (Status IN ('open','in_progress','completed')),
    AssigneeID   INT NULL FOREIGN KEY REFERENCES Adventurers(AdventurerID),
    RewardGold   INT NOT NULL DEFAULT 0,
    CreatedAt    DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt    DATETIME NULL
);
GO

/* ---------------- ÖRNEK VERİ ---------------- */
-- Eşyalar lonca-mobile/assets/data/items.json ile aynıdır

INSERT INTO ItemTypes (TypeName) VALUES
(N'Silah'), (N'Zırh'), (N'İksir'), (N'Parşömen'), (N'Takı');

INSERT INTO Items (Name, ItemTypeID, Rarity, Price, Stock, Attack, Defense, Magic, Description) VALUES
(N'Ejderha Dişi Kılıcı',   1, N'Efsanevi', 950,  1, 48,  4, 12, N'Kül Dağı ejderhasının dişinden dövülmüş.'),
(N'Meşe Yayı',             1, N'Sıradan',   60, 14, 14,  0,  0, N'Her acemi okçunun ilk dostu.'),
(N'Cüce Savaş Baltası',    1, N'Nadir',    280,  5, 30,  6,  0, N'Demirsakal klanının ustalarınca dövüldü.'),
(N'Mithril Zincir Zırh',   2, N'Epik',     620,  2,  0, 40,  8, N'Tüy kadar hafif, ejderha pulu kadar sert.'),
(N'Deri Yelek',            2, N'Sıradan',   45, 20,  0, 10,  0, N'Hafif, sessiz ve hırsızların favorisi.'),
(N'Gölge Pelerini',        2, N'Nadir',    340,  3,  0, 12, 18, N'Karanlıkta giyeni neredeyse görünmez kılar.'),
(N'Kırmızı Şifa İksiri',   3, N'Sıradan',   15, 50,  0,  0,  5, N'Yaraları anında kapatır.'),
(N'Mavi Mana İksiri',      3, N'Sıradan',   20, 40,  0,  0, 15, N'Büyücülerin tükenen gücünü yeniler.'),
(N'Ejderha Nefesi Şişesi', 3, N'Epik',     410,  2, 25,  0, 25, N'Bir yudum al, düşmanına doğru üfle.'),
(N'Işınlanma Parşömeni',   4, N'Nadir',    180,  6,  0,  0, 30, N'Okuyanı en son dinlendiği hana götürür.'),
(N'Ateş Topu Parşömeni',   4, N'Nadir',    150,  8, 35,  0, 20, N'Tek kullanımlık. Kapalı alanda okumayın.'),
(N'Ay Taşı Yüzüğü',        5, N'Efsanevi', 880,  1,  0, 15, 45, N'Dolunay gecelerinde parlar.'),
(N'Şans Tılsımı',          5, N'Sıradan',   35, 25,  2,  2,  2, N'İşe yaradığı kanıtlanmadı.');

INSERT INTO Adventurers (Name, Class, GuildRank, Gold, JoinedAt) VALUES
(N'Aria Gümüşok',      N'Okçu',    'B',  420, '2026-03-12'),
(N'Borin Demirsakal',  N'Savaşçı', 'A',  860, '2025-11-02'),
(N'Lyra Gecerüzgârı',  N'Büyücü',  'A', 1200, '2025-08-21'),
(N'Kael Karagölge',    N'Hırsız',  'C',  150, '2026-07-30'),
(N'Selin Işıkkalkan',  N'Şifacı',  'B',  510, '2026-01-15'),
(N'Thorn Kızılbaşak',  N'Savaşçı', 'S', 3400, '2024-05-09');

INSERT INTO Purchases (AdventurerID, PurchaseDate) VALUES
(1, '2026-08-02 10:00'), (2, '2026-08-11 15:30'), (3, '2026-08-25 21:10'),
(4, '2026-09-03 09:45'), (6, '2026-09-10 12:00'), (5, '2026-09-22 18:20'),
(1, '2026-10-01 11:15'), (3, '2026-10-06 22:40');

INSERT INTO PurchaseDetails (PurchaseID, ItemID, Quantity) VALUES
(1, 2, 1), (1, 7, 3),
(2, 3, 1), (2, 5, 1),
(3, 8, 5), (3, 10, 1),
(4, 5, 1), (4, 13, 1),
(5, 1, 1), (5, 4, 1),
(6, 7, 6), (6, 13, 2),
(7, 11, 2),
(8, 12, 1), (8, 8, 3);

UPDATE p
SET TotalGold = t.Toplam
FROM Purchases p
JOIN (
    SELECT pd.PurchaseID, SUM(pd.Quantity * i.Price) AS Toplam
    FROM PurchaseDetails pd
    JOIN Items i ON i.ItemID = pd.ItemID
    GROUP BY pd.PurchaseID
) t ON t.PurchaseID = p.PurchaseID;

-- Görevler lonca-api/src/data/tasks.json ile aynıdır
INSERT INTO Tasks (Title, Description, Priority, Status, AssigneeID, RewardGold, CreatedAt) VALUES
(N'Kuzey Mağarasındaki Goblinleri Temizle', N'Goblin sürüsünü dağıt.',      'low',      'open',        NULL,   50, '2026-10-01 09:00'),
(N'Kayıp Kervanı Bul',                      N'Kervanı güvenle şehre getir.',   'medium',   'in_progress', 1,     120, '2026-10-02 14:30'),
(N'Kül Dağı Ejderhasını Uyandırma',         N'Yıldız Taşı''nı fark edilmeden çal.', 'critical', 'open',        NULL, 1000, '2026-10-03 08:15'),
(N'Simyacıya Ay Çiçeği Topla',              N'10 adet ay çiçeği topla.',           'low',      'completed',   2,      30, '2026-09-28 19:45'),
(N'Batık Tapınağın Lanetini Kaldır',        N'Lanetli totemi rahibeye teslim et.',  'high',     'in_progress', 3,     400, '2026-10-05 11:00');
GO

/* ---------------- VIEW'LAR ---------------- */

-- Heybe özeti (vw_SiparisOzet karşılığı)
CREATE VIEW vw_HeybeOzet AS
SELECT a.Name AS Maceraci, p.PurchaseDate AS Tarih, i.Name AS Esya, pd.Quantity AS Adet
FROM Adventurers a
JOIN Purchases p        ON p.AdventurerID = a.AdventurerID
JOIN PurchaseDetails pd ON pd.PurchaseID  = p.PurchaseID
JOIN Items i            ON i.ItemID       = pd.ItemID;
GO

-- Görev panosu özeti (lonca-api /reports/summary için)
CREATE VIEW vw_GorevOzet AS
SELECT Status, COUNT(*) AS GorevSayisi, SUM(RewardGold) AS ToplamOdul
FROM Tasks
GROUP BY Status;
GO

/* ---------------- ÖRNEK RAPORLAR ---------------- */

-- Stoğu azalan eşyalar
SELECT Name, Stock FROM Items WHERE Stock < 5 ORDER BY Stock;

-- En çok altın harcayan maceracılar
SELECT a.Name, SUM(p.TotalGold) AS HarcananAltin
FROM Adventurers a
JOIN Purchases p ON p.AdventurerID = a.AdventurerID
GROUP BY a.Name
ORDER BY HarcananAltin DESC;

-- Türe göre eşya sayısı
SELECT t.TypeName, COUNT(i.ItemID) AS EsyaSayisi
FROM ItemTypes t
LEFT JOIN Items i ON i.ItemTypeID = t.ItemTypeID
GROUP BY t.TypeName;

-- Maceracıların üstlendiği aktif görevler
SELECT a.Name, t.Title, t.Priority, t.Status
FROM Tasks t
JOIN Adventurers a ON a.AdventurerID = t.AssigneeID
WHERE t.Status <> 'completed';

SELECT * FROM vw_GorevOzet;
GO
