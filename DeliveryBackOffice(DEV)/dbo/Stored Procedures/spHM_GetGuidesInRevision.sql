-- =============================================
-- Author:		<Freddy Camposeco>
-- Create date:	<2025-11-10>
-- Description:	<Obtiene las guias en estado "En Revision" con filtros opcionales>
-- =============================================
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

    DECLARE @StatusRevision INT = 13;-- OrderDescription "En Revisión"
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
        SELECT
            DO.Guide_Serie + CAST(DO.Guide_Number AS VARCHAR(20)) AS Guia,
            CR.CodeRoute AS Ruta,
            DO.Courier_Name AS Piloto,
            HL.HubName + '', '' + HL.HubAbbreviation AS HubDestino,
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
            AND ISNULL(CR.CountryId, ''GT'') = @CountryId';

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
            AND DO.Courier_Name LIKE @CourierNamePattern';
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
          @CountryId NVARCHAR(5),
          @RouteId INT,
          @CourierNamePattern NVARCHAR(202),
          @HubId INT,
          @GuideSerie NVARCHAR(2),
          @GuideNumber INT',
        @StatusRevision = @StatusRevision,
        @CountryId = @CountryId,
        @RouteId = @RouteId,
        @CourierNamePattern = @CourierNamePattern,
        @HubId = @HubId,
        @GuideSerie = @GuideSerie,
        @GuideNumber = @GuideNumber;
END
GO
