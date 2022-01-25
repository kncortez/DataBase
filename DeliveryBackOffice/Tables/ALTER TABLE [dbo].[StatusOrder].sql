
ALTER TABLE dbo.StatusOrder 
ADD CatCheckpointTypeId tinyint NOT NULL DEFAULT 2,
CONSTRAINT FK_StatusOrder_CatCheckpointType FOREIGN KEY(CatCheckpointTypeId) REFERENCES dbo.CatCheckpointType(IdCatCheckpointType);