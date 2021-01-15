/*
HPW-63
*/

ALTER TABLE [UserAddress]
ADD CodeOfReference INT;

ALTER TABLE [UserAddress] ADD CONSTRAINT FK_IdVisitPointClient
FOREIGN KEY (CodeOfReference) REFERENCES dbo.VisitPointClient (CodeOfReference);
