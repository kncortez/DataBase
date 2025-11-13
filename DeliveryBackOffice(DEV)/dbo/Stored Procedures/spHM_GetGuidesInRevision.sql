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

    DECLARE @GuideSerie NVARCHAR(2);
    DECLARE @GuideNumber INT;

    IF (@Guide IS NOT NULL)
    BEGIN
        SET @GuideSerie = LTRIM(RTRIM(LEFT(@Guide, 2)));
        DECLARE @GuideNumberText NVARCHAR(18) = LTRIM(RTRIM(RIGHT(@Guide, LEN(@Guide) - 2)));

        IF (
            LEN(@GuideNumberText) > 0
            AND @GuideNumberText NOT LIKE '%[^0-9]%'
        )
        BEGIN
            SET @GuideNumber = CAST(@GuideNumberText AS INT);
        END
        ELSE
        BEGIN
            SET @GuideSerie = NULL;
            SET @GuideNumber = NULL;
        END
    END

    IF (
        @GuideSerie IS NOT NULL
        AND @GuideNumber IS NOT NULL
    )
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
            AND DO.Guide_Serie = @GuideSerie
            AND DO.Guide_Number = @GuideNumber
        ORDER BY DO.DateCreated DESC;
    END
    ELSE IF (@Guide IS NULL)
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
    END
END
GO
