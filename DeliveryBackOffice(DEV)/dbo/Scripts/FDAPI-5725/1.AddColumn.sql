/* 
SCRIPT FDAPI-5725: Adición de columna TownshipId a dbo.CatStation
*/

IF NOT EXISTS (
    SELECT 1 
    FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'dbo.CatStation') 
    AND name = N'TownshipId'
)
BEGIN
    PRINT 'Agregando columna TownshipId a dbo.CatStation...';
    
    ALTER TABLE DeliveryBackOffice.dbo.CatStation
    ADD TownshipId INT NULL;

    ALTER TABLE DeliveryBackOffice.dbo.CatStation
    ADD CONSTRAINT FK_CatStation_Township 
    FOREIGN KEY (TownshipId) 
    REFERENCES dbo.Township (IdTownship);
    
    EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Municipio relacionado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStation', @level2type = N'COLUMN', @level2name = N'TownshipId';

    PRINT 'Columna y FK agregadas exitosamente.';
END
ELSE
BEGIN
    PRINT 'La columna TownshipId ya existe en dbo.CatStation.';
END