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
    @pExternalTownship NVARCHAR(200), -- Recibe ID o Nombre del municipio
    @pExternalProvince NVARCHAR(200) = NULL, -- Recibe ID o Nombre del departamento
    @CountryId NVARCHAR(5) = 'GT'
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación inicial estricta
    IF @pExternalTownship IS NULL OR LTRIM(RTRIM(@pExternalTownship)) = ''
    BEGIN
        RAISERROR('El dato del municipio (headerCodeTownship) es obligatorio.', 16, 1);
        RETURN;
    END

    -- BLOQUE 1: INTENTO DE MATCH DIRECTO COMO ID (Prioridad alta, ignora provincia)
    -- Buscamos si el dato coincide directamente con la columna ExternalTownshipId
    IF EXISTS (
        SELECT 1 FROM [dbo].[CustomerTownshipMapping] WITH(NOLOCK)
        WHERE CodeOfReference = @pCodeOfReference
          AND ExternalTownshipId = @pExternalTownship
          AND CountryId = @CountryId
          AND RowStatus = 1
    )
    BEGIN
        SELECT TOP 1
            t.HeaderCode,
            CONVERT(VARCHAR, t.IdTownship) AS 'IdTownship',
            dbo.fnt_String_Escape(ISNULL(t.TownshipName, ''), 'json') AS 'TownshipName'
        FROM [dbo].[CustomerTownshipMapping] ctm WITH (NOLOCK)
        INNER JOIN [dbo].[Township] t WITH (NOLOCK) ON t.IdTownship = ctm.TownshipId
        WHERE ctm.CodeOfReference = @pCodeOfReference
          AND ctm.CountryId = @CountryId
          AND ctm.ExternalTownshipId = @pExternalTownship
          AND ctm.RowStatus = 1
          AND t.TownshipStatus = 1
        ORDER BY t.IdTownship ASC;

        RETURN;
    END

    -- BLOQUE 2: SI LLEGÓ AQUÍ, ASUMIMOS QUE ES NOMBRE.
    IF @pExternalProvince IS NULL OR LTRIM(RTRIM(@pExternalProvince)) = ''
    BEGIN
        RAISERROR('Desambiguación requerida: Al buscar por nombre de municipio, el departamento (clientProvince) es obligatorio.', 16, 1);
        RETURN;
    END

    -- Match por Nombre de Municipio + (ID o Nombre de Provincia)
    SELECT TOP 1
        t.HeaderCode,
        CONVERT(VARCHAR, t.IdTownship) AS 'IdTownship',
        dbo.fnt_String_Escape(ISNULL(t.TownshipName, ''), 'json') AS 'TownshipName'
    FROM [dbo].[CustomerTownshipMapping] ctm WITH (NOLOCK)
    INNER JOIN [dbo].[Township] t WITH (NOLOCK) ON t.IdTownship = ctm.TownshipId
    WHERE ctm.CodeOfReference = @pCodeOfReference
      AND ctm.CountryId = @CountryId
      AND ctm.ExternalTownshipName = @pExternalTownship
      -- Validamos que el dato de la provincia haga match ya sea con el ID de la provincia o con su nombre
      AND (ctm.ExternalProvinceId = @pExternalProvince OR ctm.ExternalProvinceName = @pExternalProvince)
      AND ctm.RowStatus = 1
      AND t.TownshipStatus = 1
    ORDER BY t.IdTownship ASC;

END
GO

-- Descripciones Extendidas para el diccionario de datos de SQL Server
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Obtiene el IdTownship y HeaderCode de Forza mapeando el código o nombre enviado por el cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'spws_get_township_by_external_mapping';
GO
