-- =============================================
-- Author:		<Freddy Camposeco>
-- Create date:	<2025-11-10>
-- Description:	<Obtiene las guias en estado "En Revision" con filtros opcionales>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_GetGuidesInRevision]
    @CountryId NVARCHAR(5) = 'GT',
    @RouteId INT = NULL,
    @CourierName NVARCHAR(100) = NULL,
    @HubId INT = NULL,
    @Guide NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StatusRevision INT = (
        SELECT TOP 1 SO.StatusOrderId
        FROM StatusOrder SO WITH (NOLOCK)
        WHERE SO.OrderDescription = 'En Revisión'
    );

    DECLARE @GuideNormalized NVARCHAR(20) = NULL,
            @GuideSerie NVARCHAR(2) = NULL,
            @GuideSerieLike NVARCHAR(22) = NULL,
            @GuideNumberText NVARCHAR(18) = NULL,
            @GuideNumberPrefix NVARCHAR(20) = NULL,
            @GuideNumberLike NVARCHAR(22) = NULL,
            @GuideFullLike NVARCHAR(22) = NULL,
            @GuideNumberOnly BIT = 0,
            @GuideLettersOnly BIT = 0;

    IF @Guide IS NOT NULL
    BEGIN
        SET @GuideNormalized = UPPER(REPLACE(REPLACE(LTRIM(RTRIM(@Guide)), '-', ''), ' ', ''));
        IF @GuideNormalized = ''
        BEGIN
            SET @GuideNormalized = NULL;
        END
    END

    IF @GuideNormalized IS NULL
    BEGIN
        SELECT
            DO.Guide_Serie + CAST(DO.Guide_Number AS VARCHAR(20)) AS Guia,
            CR.CodeRoute AS Ruta,
            DO.Courier_Name AS Piloto,
            HL.HubName + ', ' + HL.HubAbbreviation AS HubDestino,
            DO.DateCreated AS Fecha,
            DOP.NoPiece AS Pieza,
            SO.OrderDescription AS Estado
        FROM DeliveryOrder DO WITH (NOLOCK)
        INNER JOIN DeliveryOrderPiece DOP WITH (NOLOCK)
            ON DO.Guide_Serie = DOP.GuideSerie
            AND DO.Guide_Number = DOP.GuideNumber
        INNER JOIN CatRoute CR WITH (NOLOCK)
            ON DO.Courier_Route = CR.CodeRoute
        LEFT JOIN HubLogistics HL WITH (NOLOCK)
            ON DO.HubDestinationId = HL.IdHubLogistic
        INNER JOIN StatusOrder SO WITH (NOLOCK)
            ON DO.StatusOrderId = SO.StatusOrderId
        WHERE DO.StatusOrderId = @StatusRevision
            AND ISNULL(CR.CountryId, 'GT') = @CountryId
            AND (@RouteId IS NULL OR CR.IdRoute = @RouteId)
            AND (@CourierName IS NULL OR DO.Courier_Name LIKE '%' + @CourierName + '%')
            AND (@HubId IS NULL OR HL.IdHubLogistic = @HubId)
        ORDER BY DO.DateCreated DESC;

        RETURN;
    END

    SET @GuideFullLike = '%' + @GuideNormalized + '%';

    IF @GuideNormalized NOT LIKE '%[^0-9]%'
    BEGIN
        SET @GuideNumberOnly = 1;
        SET @GuideNumberLike = '%' + @GuideNormalized + '%';
        SET @GuideNumberPrefix = @GuideNormalized + '%';
    END
    ELSE IF @GuideNormalized NOT LIKE '%[^A-Z]%'
    BEGIN
        SET @GuideLettersOnly = 1;
        SET @GuideSerieLike = @GuideNormalized + '%';
    END
    ELSE
    BEGIN
        SET @GuideSerieLike = @GuideNormalized + '%';
    END

    IF LEN(@GuideNormalized) > 2 AND @GuideNormalized LIKE '[A-Z][A-Z]%'
    BEGIN
        SET @GuideSerie = LEFT(@GuideNormalized, 2);
        SET @GuideSerieLike = @GuideSerie + '%';

        SET @GuideNumberText = SUBSTRING(@GuideNormalized, 3, LEN(@GuideNormalized) - 2);

        IF @GuideNumberText = '' OR @GuideNumberText LIKE '%[^0-9]%'
        BEGIN
            SET @GuideNumberText = NULL;
        END
        ELSE
        BEGIN
            SET @GuideNumberPrefix = @GuideNumberText + '%';
            SET @GuideNumberLike = '%' + @GuideNumberText + '%';
        END
    END

    SELECT
        g.GuideFull AS Guia,
        CR.CodeRoute AS Ruta,
        DO.Courier_Name AS Piloto,
        HL.HubName + ', ' + HL.HubAbbreviation AS HubDestino,
        DO.DateCreated AS Fecha,
        DOP.NoPiece AS Pieza,
        SO.OrderDescription AS Estado
    FROM DeliveryOrder DO WITH (NOLOCK)
    INNER JOIN DeliveryOrderPiece DOP WITH (NOLOCK)
        ON DO.Guide_Serie = DOP.GuideSerie
        AND DO.Guide_Number = DOP.GuideNumber
    INNER JOIN CatRoute CR WITH (NOLOCK)
        ON DO.Courier_Route = CR.CodeRoute
    LEFT JOIN HubLogistics HL WITH (NOLOCK)
        ON DO.HubDestinationId = HL.IdHubLogistic
    INNER JOIN StatusOrder SO WITH (NOLOCK)
        ON DO.StatusOrderId = SO.StatusOrderId
    CROSS APPLY (
        SELECT GuideNumberText = CONVERT(NVARCHAR(20), DO.Guide_Number),
               GuideFull = DO.Guide_Serie + CONVERT(NVARCHAR(20), DO.Guide_Number)
    ) AS g
    WHERE DO.StatusOrderId = @StatusRevision
        AND ISNULL(CR.CountryId, 'GT') = @CountryId
        AND (@RouteId IS NULL OR CR.IdRoute = @RouteId)
        AND (@CourierName IS NULL OR DO.Courier_Name LIKE '%' + @CourierName + '%')
        AND (@HubId IS NULL OR HL.IdHubLogistic = @HubId)
        AND (
            (@GuideSerie IS NOT NULL AND @GuideNumberText IS NOT NULL AND DO.Guide_Serie = @GuideSerie AND g.GuideNumberText = @GuideNumberText)
             OR (@GuideSerie IS NOT NULL AND @GuideNumberText IS NOT NULL AND DO.Guide_Serie = @GuideSerie AND g.GuideNumberText LIKE @GuideNumberPrefix)
             OR (@GuideSerie IS NOT NULL AND @GuideNumberText IS NULL AND DO.Guide_Serie LIKE @GuideSerieLike)
             OR (@GuideNumberOnly = 1 AND g.GuideNumberText LIKE @GuideNumberLike)
             OR (@GuideLettersOnly = 1 AND DO.Guide_Serie LIKE @GuideSerieLike)
             OR g.GuideFull LIKE @GuideFullLike
            )
    ORDER BY
        CASE
            WHEN @GuideSerie IS NOT NULL AND @GuideNumberText IS NOT NULL AND DO.Guide_Serie = @GuideSerie AND g.GuideNumberText = @GuideNumberText THEN 0
            WHEN @GuideSerie IS NOT NULL AND @GuideNumberText IS NOT NULL AND DO.Guide_Serie = @GuideSerie AND g.GuideNumberText LIKE @GuideNumberPrefix THEN 1
            WHEN @GuideNumberOnly = 1 AND g.GuideNumberText LIKE @GuideNumberLike THEN 2
            WHEN @GuideSerie IS NOT NULL AND DO.Guide_Serie = @GuideSerie THEN 3
            WHEN @GuideLettersOnly = 1 AND DO.Guide_Serie LIKE @GuideSerieLike THEN 4
            ELSE 5
        END,
        DO.DateCreated DESC;
END
GO
