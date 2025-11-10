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
        AND (@Guide IS NULL OR (DO.Guide_Serie + CAST(DO.Guide_Number AS VARCHAR(20))) LIKE '%' + @Guide + '%')
    ORDER BY
        CASE
            WHEN @Guide IS NULL THEN 0
            WHEN (DO.Guide_Serie + CAST(DO.Guide_Number AS VARCHAR(20))) = @Guide THEN 0
            WHEN @Guide IS NOT NULL AND (DO.Guide_Serie + CAST(DO.Guide_Number AS VARCHAR(20))) LIKE @Guide + '%' THEN 1
            WHEN @Guide IS NOT NULL AND (DO.Guide_Serie + CAST(DO.Guide_Number AS VARCHAR(20))) LIKE '%' + @Guide + '%' THEN 2
            ELSE 3
        END,
        ABS(LEN(DO.Guide_Serie + CAST(DO.Guide_Number AS VARCHAR(20))) - LEN(ISNULL(@Guide, ''))),
        DO.DateCreated DESC;
END
GO
