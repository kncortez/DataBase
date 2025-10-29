SET NOCOUNT ON;

BEGIN TRY
    IF COL_LENGTH('dbo.CatTypeIncidence', 'CatPartyResponsibleId') IS NULL
    BEGIN
        ALTER TABLE dbo.CatTypeIncidence 
        ADD CatPartyResponsibleId INT NULL;

        EXEC sp_addextendedproperty 
            @name = N'MS_Description',
            @value = N'Llave foranea a la tabla de partes responsables Cliente,forza',
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'TABLE',
            @level1name = N'CatTypeIncidence',
            @level2type = N'COLUMN',
            @level2name = N'CatPartyResponsibleId';

    END
    ELSE
    BEGIN
        PRINT 'La columna CatPartyResponsibleId ya existe en dbo.CatTypeIncidence.';
    END

    IF NOT EXISTS (
        SELECT 1 
        FROM sys.foreign_keys 
        WHERE name = 'FK_CatTypeIncidence_CatPartyResponsible'
    )
    BEGIN
        ALTER TABLE dbo.CatTypeIncidence
        ADD CONSTRAINT FK_CatTypeIncidence_CatPartyResponsible
            FOREIGN KEY (CatPartyResponsibleId)
            REFERENCES dbo.CatPartyResponsible(IdCatPartyResponsible);
    END
    ELSE
    BEGIN
        PRINT 'La llave foranea FK_CatTypeIncidence_CatPartyResponsible ya existe.';
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.CatPartyResponsible WHERE PartyResponsibleName = 'Cliente')
    BEGIN
        INSERT INTO dbo.CatPartyResponsible
            (PartyResponsibleName, RowStatus, TokenCreated, DateCreated, DateUpdated, TokenUpdated)
        VALUES ('Cliente', 1, 'SYS-TGARCIA', GETDATE(), NULL, NULL);
    END
    ELSE
        PRINT 'Registro Cliente ya existe.';

    IF NOT EXISTS (SELECT 1 FROM dbo.CatPartyResponsible WHERE PartyResponsibleName = 'Forza')
    BEGIN
        INSERT INTO dbo.CatPartyResponsible
            (PartyResponsibleName, RowStatus, TokenCreated, DateCreated, DateUpdated, TokenUpdated)
        VALUES ('Forza', 1, 'SYS-TGARCIA', GETDATE(), NULL, NULL);
    END
    ELSE
        PRINT 'Registro Forza ya existe.';

    DECLARE @IdCatPartyResponsibleCliente INT = (SELECT TOP 1 IdCatPartyResponsible FROM dbo.CatPartyResponsible WHERE PartyResponsibleName = 'Cliente');
    DECLARE @IdCatPartyResponsibleForza INT = (SELECT TOP 1 IdCatPartyResponsible FROM dbo.CatPartyResponsible WHERE PartyResponsibleName = 'Forza');

    IF @IdCatPartyResponsibleCliente IS NULL OR @IdCatPartyResponsibleForza IS NULL
    BEGIN
        RAISERROR('No se encontraron los IDs de Cliente o Forza en CatPartyResponsible.', 16, 1);
        RETURN;
    END

    PRINT 'Actualizando registros de tipo incidencia...';

    UPDATE CatTypeIncidence 
    SET CatPartyResponsibleId = @IdCatPartyResponsibleCliente 
    WHERE IdIncidenceType IN (72,73,74,75,76,77,78,83,85,86,87,90,127,128,129,130,131,132,133,136,138,188,189,190,191,192,193,194,197,199,208,209,210);

    UPDATE CatTypeIncidence 
    SET CatPartyResponsibleId = @IdCatPartyResponsibleForza 
    WHERE IdIncidenceType IN (79,82,84,134,135,137,195,196,198);

    PRINT 'Actualizacion completada exitosamente.';
END TRY
BEGIN CATCH
    DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
    SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
    RAISERROR('Error ejecutando el script: %s', @ErrSeverity, 1, @ErrMsg);
END CATCH;
