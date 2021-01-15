/*
HPW-63
*/

ALTER TABLE [VisitPointClient]
ADD IdTownship INT;

ALTER TABLE [VisitPointClient]
ADD CONSTRAINT FKIdTownship
FOREIGN KEY (IdTownship) REFERENCES dbo.Township(IdTownship);
