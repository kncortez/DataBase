/* =================================================
   SP:        [dbo].[spHM_GetGuidesInRevision]
   Propósito: <Obtiene las guias en estado "En Revision" con filtros opcionales>
   Autor:     <Freddy Camposeco>
   Historia:  <>
   Fecha:     2025-11-10
============================================
=== CHANGELOG ================================
-- 2025-12-17 | Historia/épica: FDAPI-5296 | Autor: Tito Garcia |
=========================================== */
USE [DeliveryBackOffice]
GO

CREATE PROCEDURE [dbo].[spHM_GetGuidesInRevision]
    @CountryId NVARCHAR(5) = 'GT',
    @RouteId INT = NULL,
    @CourierName NVARCHAR(100) = NULL,
    @HubId INT = NULL,
    @Guide NVARCHAR(20) = NULL
AS
BEGIN
    SET ANSI_NULLS ON
    SET QUOTED_IDENTIFIER ON
    SET NOCOUNT ON;

    DECLARE @StatusRevision INT = 55; -- 'En Revision LH'
    DECLARE @StatusExtraviado INT = 27;-- Estado pieza "Paquete Extraviado"
    DECLARE @StatusTrasladadoHub INT = 44;-- Estado pieza "Trasladado a Hub"
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
        @Guide IS NOT NULL
        AND (
            @GuideSerie IS NULL
        OR @GuideNumber IS NULL
        )
    )
    BEGIN
        RETURN;
    END

    DECLARE @Sql NVARCHAR(MAX) = N'
        WITH GuideAggregates AS (
            SELECT
                DOP.GuideSerie,
                DOP.GuideNumber,
                COUNT(1) AS TotalPiezas,
                SUM(CASE WHEN DOP.StatusOrderId = @StatusRevision THEN 1 ELSE 0 END) AS PiezasEnRevision,
                SUM(CASE WHEN DOP.StatusOrderId = @StatusExtraviado THEN 1 ELSE 0 END) AS PiezasExtraviadas,
                SUM(CASE WHEN DOP.StatusOrderId = @StatusTrasladadoHub THEN 1 ELSE 0 END) AS PiezasLiberadas,
                SUM(CASE WHEN DOP.StatusOrderId IN (@StatusRevision, @StatusExtraviado) THEN 1 ELSE 0 END) AS PiezasObservadas
            FROM DeliveryOrderPiece DOP WITH (NOLOCK)
            GROUP BY DOP.GuideSerie, DOP.GuideNumber
        )
        SELECT
            DO.Guide_Serie + CAST(DO.Guide_Number AS VARCHAR(20)) AS Guia,
            DOP.NoPiece AS Pieza,
            CR.CodeRoute AS Ruta,
            CONCAT(SR.First_Name, '' '', SR.Last_Name) AS Piloto,
            HL.HubName + '', '' + HL.HubAbbreviation AS HubDestino,
            DO.DateCreated AS Fecha,
            SO.OrderDescription AS EstadoPieza,
            GA.TotalPiezas,
            GA.PiezasEnRevision,
            GA.PiezasExtraviadas,
            GA.PiezasLiberadas,
            GA.PiezasObservadas,
            CASE WHEN GA.TotalPiezas > 0 AND GA.PiezasLiberadas = GA.TotalPiezas THEN 1 ELSE 0 END AS EsLiberable,
            CASE WHEN GA.PiezasExtraviadas > 0 THEN 1 ELSE 0 END AS TieneExtraviadas
        FROM DeliveryOrder DO WITH (NOLOCK)
        INNER JOIN LinehaulRoutePreparationContainerDetail LHP WITH (NOLOCK)
            ON DO.Guide_Serie = LHP.GuideSerie
            AND DO.Guide_Number = LHP.GuideNumber
        INNER JOIN LinehaulRoutePreparationContainer LHRP WITH (NOLOCK)
            ON LHP.LinehaulRoutePreparationContainerId = LHRP.IdLinehaulRoutePreparationContainer
        INNER JOIN LinehaulRoutePreparation HRP WITH (NOLOCK)
            ON HRP.IdLinehaulRoutePreparation = LHRP.LinehaulRoutePreparationId
        INNER JOIN CatRoute CR WITH (NOLOCK)
            ON HRP.CatRouteId = CR.IdRoute
        INNER JOIN SenderReceiver SR WITH (NOLOCK)
            ON HRP.SenderReceiverId = SR.ID
        LEFT JOIN HubLogistics HL WITH (NOLOCK)
            ON DO.HubDestinationId = HL.IdHubLogistic
        LEFT JOIN DeliveryOrderPiece DOP WITH (NOLOCK)
            ON DO.Guide_Serie = DOP.GuideSerie
            AND DO.Guide_Number = DOP.GuideNumber
        LEFT JOIN StatusOrder SO WITH (NOLOCK)
            ON DOP.StatusOrderId = SO.StatusOrderId
        LEFT JOIN GuideAggregates GA
            ON GA.GuideSerie = DO.Guide_Serie
            AND GA.GuideNumber = DO.Guide_Number
        WHERE DO.StatusOrderId = @StatusRevision
            AND (CR.CountryId = @CountryId OR CR.CountryId IS NULL)';

    IF (
        @GuideSerie IS NOT NULL
        OR @GuideNumber IS NOT NULL
    )
    BEGIN
        SET @Sql += N'
            AND DO.Guide_Serie = @GuideSerie
            AND DO.Guide_Number = @GuideNumber';
    END

    IF (@RouteId IS NOT NULL)
    BEGIN
        SET @Sql += N'
            AND CR.IdRoute = @RouteId';
    END

    IF (@CourierName IS NOT NULL)
    BEGIN
        SET @Sql += N'
            AND (CONCAT(SR.First_Name,'' '',SR.Last_Name) LIKE @CourierNamePattern)';
    END

    IF (@HubId IS NOT NULL)
    BEGIN
        SET @Sql += N'
            AND HL.IdHubLogistic = @HubId';
    END

    SET @Sql += N'
        ORDER BY DO.DateCreated DESC;';

    DECLARE @CourierNamePattern NVARCHAR(202);
    IF (@CourierName IS NOT NULL)
    BEGIN
        SET @CourierNamePattern = '%' + @CourierName + '%';
    END

    EXEC sp_executesql
        @Sql,
        N'@StatusRevision INT,
          @StatusExtraviado INT,
          @StatusTrasladadoHub INT,
          @CountryId NVARCHAR(5),
          @RouteId INT,
          @CourierNamePattern NVARCHAR(202),
          @HubId INT,
          @GuideSerie NVARCHAR(2),
          @GuideNumber INT',
        @StatusRevision = @StatusRevision,
        @StatusExtraviado = @StatusExtraviado,
        @StatusTrasladadoHub = @StatusTrasladadoHub,
        @CountryId = @CountryId,
        @RouteId = @RouteId,
        @CourierNamePattern = @CourierNamePattern,
        @HubId = @HubId,
        @GuideSerie = @GuideSerie,
        @GuideNumber = @GuideNumber;
END
GO
