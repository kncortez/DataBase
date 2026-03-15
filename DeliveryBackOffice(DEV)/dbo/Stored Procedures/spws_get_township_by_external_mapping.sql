/* =================================================
   SP:        [dbo].[spws_get_township_by_external_mapping]
   Propósito: Obtiene el IdTownship y HeaderCode de Forza mapeando el código o nombre enviado por el cliente.
   Autor:     Hanss Espinoza
   Historia:  FDAPI-5860
   Fecha:     2026-03-13
============================================
=== CHANGELOG ================================
=========================================== */
CREATE PROCEDURE [dbo].[spws_get_township_by_external_mapping]
    @pCodeOfReference INT,
    @pExternalId NVARCHAR(200) = NULL,
    @pExternalName NVARCHAR(200) = NULL,
    @CountryId NVARCHAR(2) = 'GT'
AS
BEGIN
    SET NOCOUNT ON;

    IF @pExternalId IS NULL AND @pExternalName IS NULL
    BEGIN
        RAISERROR('Debe proporcionar al menos un ID externo o un Nombre externo.', 16, 1);
        RETURN;
    END

    -- Bloque 1: Búsqueda por ID Externo (Uso de índice IX_CustomerTownshipMapping_Customer_ExternalId)
    IF @pExternalId IS NOT NULL
    BEGIN
        SELECT
            t.HeaderCode,
            CONVERT(VARCHAR, t.IdTownship) AS 'IdTownship',
            dbo.fnt_String_Escape(ISNULL(t.TownshipName, ''), 'json') AS 'TownshipName'
        FROM [dbo].[CustomerTownshipMapping] ctm WITH (NOLOCK)
        INNER JOIN [dbo].[Township] t WITH (NOLOCK)
            ON t.IdTownship = ctm.IdTownship
        WHERE ctm.CodeOfReference = @pCodeOfReference
            AND ctm.CountryId = @CountryId
            AND ctm.ExternalTownshipId = @pExternalId
            AND ctm.RowStatus = 1
            AND t.TownshipStatus = 1;
    END
    -- Bloque 2: Búsqueda por Nombre Externo (Uso de índice IX_CustomerTownshipMapping_Customer_ExternalName)
    ELSE IF @pExternalName IS NOT NULL
    BEGIN
        SELECT
            t.HeaderCode,
            CONVERT(VARCHAR, t.IdTownship) AS 'IdTownship',
            dbo.fnt_String_Escape(ISNULL(t.TownshipName, ''), 'json') AS 'TownshipName'
        FROM [dbo].[CustomerTownshipMapping] ctm WITH (NOLOCK)
        INNER JOIN [dbo].[Township] t WITH (NOLOCK)
            ON t.IdTownship = ctm.IdTownship
        WHERE ctm.CodeOfReference = @pCodeOfReference
            AND ctm.CountryId = @CountryId
            AND ctm.ExternalTownshipName = @pExternalName
            AND ctm.RowStatus = 1
            AND t.TownshipStatus = 1;
    END
END
GO

-- Descripciones Extendidas para el diccionario de datos de SQL Server
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Obtiene el IdTownship y HeaderCode de Forza mapeando el código o nombre enviado por el cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'spws_get_township_by_external_mapping';
GO
