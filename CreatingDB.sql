create database VirtualGallery
use VirtualGallery

create table Artists (
	ArtistID int IDENTITY(1,1) PRIMARY KEY,
	ArtistFirstName nvarchar(100),
	ArtistLastName nvarchar(100),
	ArtistVitalRecord DATE,
	ArtistBiography nvarchar(3000),
)

create table Artworks (
	ArtworkID int IDENTITY(1,1) PRIMARY KEY,
	ArtistID int foreign key (ArtistID) references Artists(ArtistID),
	ArtworkTitle nvarchar(200),
	ArtworkYear int,
	ArtworkMedium nvarchar(200),
	ArtworkHeight DECIMAL(5,2), -- Yükseklik (örn. 150.50 cm)
	ArtworkWidth DECIMAL(5,2), -- Genişlik (örn. 80.00 cm)
	ArtworkDepth DECIMAL(5,2), -- Derinlik (örn. 20.00 cm),
	ArtworkPrice DECIMAL(10,2), 
)

create table Exhibitions (
	ExhibitionID int IDENTITY(1,1) PRIMARY KEY,
	ExhibitionTitle nvarchar(200),
	ExhibitionStartDate DATE,
	ExhibitionEndDate DATE,
	ExhibitionLocation nvarchar(100)
)

create table Visitors (
	VisitorID int IDENTITY(1,1) PRIMARY KEY,
	VisitorFirstName nvarchar(100),
	VisitorLastName nvarchar(100),
	VisitorEmail nvarchar(200),
	VisitorVisitDate DATE
)

create table Artworks_Exhibitions (
	ArtworkID int,
	ExhibitionID int,
	FOREIGN KEY (ArtworkID) REFERENCES Artworks(ArtworkID),
	FOREIGN KEY (ExhibitionID) REFERENCES Exhibitions(ExhibitionID)
)

CREATE TABLE ArtworkPriceAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    ArtworkID INT,
    OldPrice DECIMAL(10, 2),
    NewPrice DECIMAL(10, 2),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    ModifiedBy NVARCHAR(100)
);

-- Artwork'ün Price Update'ini Denetleyen Trigger

CREATE TRIGGER trg_AuditArtworkPriceUpdate
ON Artworks
AFTER UPDATE
AS
BEGIN
    -- ArtworkPrice update edildi mi? Edildiyse -->
    IF UPDATE(ArtworkPrice)
    BEGIN
        INSERT INTO ArtworkPriceAudit (ArtworkID, OldPrice, NewPrice, ModifiedDate, ModifiedBy)
        SELECT 
            i.ArtworkID,   -- Update edilen row'un Artwork ID'si
            d.ArtworkPrice AS OldPrice,   -- Update'ten önceki eski fiyat
            i.ArtworkPrice AS NewPrice,   -- Update'ten sonraki yeni fiyat
            GETDATE() AS ModifiedDate,    -- Timestamp
            SYSTEM_USER AS ModifiedBy     -- Current System User
        FROM 
            inserted i
        INNER JOIN 
            deleted d ON i.ArtworkID = d.ArtworkID;
    END
END;

-- Update Example

UPDATE Artworks
SET ArtworkPrice = 25000.00
WHERE ArtworkID = 1;

-- Audit Log
SELECT * FROM ArtworkPriceAudit;

--ALTER TABLE Artworks_Exhibitions
--ADD PRIMARY KEY (ArtworkID, ExhibitionID); -- create clustered index

CREATE INDEX idx_ArtworkID ON Artworks(ArtworkID)
--CREATE CLUSTERED INDEX idx_ArtworkID ON Artworks(ArtworkID)
CREATE INDEX idx_ArtistID ON Artists(ArtistID)
--CREATE INDEX idx_ArtworksExhibitions_ArtworkID_ExhibitionID ON Artworks_Exhibitions(ArtworkID, ExhibitionID)

-- CREATING VIEW, JOINING 3 TABLES, Tüm sonuçlar için LEFT JOIN kullandım. Eseri olmasa dahi veya sergisi de olmasa 
-- dahi o Artist de gözükecek böylelikle.

CREATE VIEW TotalArtworksByArtist AS 
SELECT 
	A.ArtistID,
	A.ArtistFirstName,
	A.ArtistLastName,
	COUNT(AE.ArtworkID) AS TotalArtworks
FROM
	Artists A
LEFT JOIN
	Artworks W ON A.ArtistID = W.ArtistID
LEFT JOIN
	Artworks_Exhibitions AE ON W.ArtworkID = AE.ArtworkID
GROUP BY
	A.ArtistID, A.ArtistFirstName, A.ArtistLastName

CREATE CLUSTERED INDEX idx_ExhibitionID ON Exhibitions(ExhibitionID);
--DROP INDEX Visitors.idx_VisitorID
CREATE CLUSTERED INDEX idx_ArtworkID ON Artworks(ArtworkID);

-- VIEW RESULT

SELECT * FROM TotalArtworksByArtist

-- ADDING EXHIBITIONID FOREIGN KEY

ALTER TABLE Visitors
add ExhibitionID int foreign key (ExhibitionID) references Exhibitions(ExhibitionID)

-- CREATING Visitor by Date Range Procedure

CREATE PROCEDURE GetVisitorsByDate
	@StartDate DATE,
	@EndDate DATE
AS
BEGIN
	SELECT
		VisitorID,
		VisitorVisitDate,
		VisitorFirstName,
		VisitorLastName,
		ExhibitionID
	FROM
		Visitors
	WHERE
		VisitorVisitDate between @StartDate AND @EndDate
	ORDER BY
		VisitorVisitDate
END;

-- Exec Procedure --> @StartDate,@EndDate

EXEC GetVisitorsByDate '2020-10-20','2023-09-20'

-- INSERT örneği

INSERT INTO Artworks (ArtistID, ArtworkTitle, ArtworkYear, ArtworkMedium, ArtWorkHeight, ArtworkWidth, ArtworkDepth, ArtworkPrice) VALUES (2, 'Whispers of Time', 2009, 'Oil on Canvas', 100.20, 75.50, 15.30, 20000.50);

SET STATISTICS IO ON;

SELECT * FROM Artworks WHERE ArtworkPrice > 10000;
--CREATE INDEX idx_ArtworkPrice ON Artworks(ArtworkPrice)

SET STATISTICS IO OFF;

SET STATISTICS TIME ON;

SELECT * FROM Artworks WHERE ArtworkPrice > 10000;

SET STATISTICS TIME OFF;

DROP INDEX Artworks.idx_ArtworkPrice

