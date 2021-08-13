CREATE TABLE CatExternalPlatform(
	IdExternalPlatform INT IDENTITY(1,1) NOT NULL,
	NameEP NVARCHAR(100) NOT NULL,
	RowStatus BIT NULL,
	TokenCreated VARCHAR(50) NOT NULL,
	DateCreated DATETIME NOT NULL,
	TokenUpdated VARCHAR(50) NULL,
	DateUpdated DATETIME NULL,
	PRIMARY KEY (IdExternalPlatform),
);