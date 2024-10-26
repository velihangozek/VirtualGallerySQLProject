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

CREATE INDEX idx_ArtworkID ON Artworks(ArtworkID)
--CREATE CLUSTERED INDEX idx_ArtworkID ON Artworks(ArtworkID)
CREATE INDEX idx_ArtistID ON Artists(ArtistID)
--CREATE INDEX idx_ArtworksExhibitions_ArtworkID_ExhibitionID ON Artworks_Exhibitions(ArtworkID, ExhibitionID)
--CREATE INDEX idx_ExhibitionID ON Exhibitions(ExhibitionID)
--CREATE INDEX idx_VisitorID ON Visitors(VisitorID)

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

SELECT * FROM TotalArtworksByArtist

ALTER TABLE Visitors
add ExhibitionID int foreign key (ExhibitionID) references Exhibitions(ExhibitionID)

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

EXEC GetVisitorsByDate '2024-10-20','2023-09-20'

INSERT INTO Artworks (ArtistID, ArtworkTitle, ArtworkYear, ArtworkMedium, ArtWorkHeight, ArtworkWidth, ArtworkDepth, ArtworkPrice) VALUES (2, 'Whispers of Time', 2009, 'Oil on Canvas', 100.20, 75.50, 15.30, 20000.50);