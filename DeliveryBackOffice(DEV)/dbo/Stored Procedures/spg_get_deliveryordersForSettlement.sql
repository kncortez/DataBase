



-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-05-27>
-- Description:	<Devuelve información para liquidación de ruta>
-- =============================================
-- =============================================
-- Author:		<CRISTIAN SUAZO>
-- Create date: <2024-05-28>
-- Description:	<si la guia tiene de destino el pais de usuario logueado, se liquida >
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_deliveryordersForSettlement] @IdManifest AS INT, 
												@IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @GuidesFound TABLE
    (
        Guide_Serie NVARCHAR(2),
        Guide_Number INT
    );

    DECLARE @GuidesDetail TABLE
    (
        Guide NVARCHAR(16),
        Delivered BIT,
        COD DECIMAL(14, 2),
		IsCollect BIT,
		Settlement BIT
    );

	DECLARE @StatusDelivery TINYINT = (SELECT StatusOrderId FROM StatusOrder  WITH(NOLOCK)  WHERE OrderDescription = 'Entregado')
	DECLARE @StatusCOD TINYINT = (SELECT StatusOrderId FROM StatusOrder  WITH(NOLOCK)  WHERE OrderDescription = 'COD pagado')
	DECLARE @StatusReturn TINYINT = (SELECT StatusOrderId FROM StatusOrder  WITH(NOLOCK)  WHERE OrderDescription = 'Devuelto')

    INSERT INTO @GuidesFound
    SELECT DISTINCT
           dsd.Guide_Serie,
           dsd.Guide_Number
    FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement dbs  WITH(NOLOCK) 
        INNER JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail dsd  WITH(NOLOCK) 
            ON dsd.ID_DeliveryOrderBySettlement = dbs.ID
    WHERE dbs.ID = @IdManifest
          AND
          (
              dsd.Guide_Settlement = 0
              OR dsd.Guide_Settlement IS NULL
          )
          AND dsd.RowStatus = 1;
		  
    SELECT 
        dbs.ID,
        Date_Dispatched,
        Pieces_Dry_Dispatched,
        Pieces_Cold_Dispatched,
        Guides_Dispatched,
        dbs.ID_Courier,
        ISNULL(sr.First_Name, '') + ' ' + ISNULL(sr.Last_Name, '') AS Courier_Name
    FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement dbs  WITH(NOLOCK) 
        INNER JOIN DeliveryBackOffice.dbo.SenderReceiver sr  WITH(NOLOCK) 
            ON sr.ID = dbs.ID_Courier
    WHERE dbs.ID = @IdManifest;

    INSERT INTO @GuidesDetail
    SELECT DISTINCT
           do.Guide_Serie + CONVERT(VARCHAR, do.Guide_Number) AS Guide,
           --da.Delivered,
           (ISNULL(
            (
                SELECT TOP 1
                       1
                FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod  WITH(NOLOCK) 
                WHERE dod.Guide_Serie = gf.Guide_Serie
                      AND dod.Guide_Number = gf.Guide_Number
                      AND dod.StatusOrderId IN ( @StatusDelivery, @StatusCOD, @StatusReturn ) -- Entregado, COD pagado y devuelto
					  AND dod.RowStatus = 1
            ),
            0
                  )
           ) AS Delivered,
           (CASE
                WHEN do.IsCollect = 'TRUE' THEN
                    CONVERT(VARCHAR, CAST((ISNULL(CASE WHEN do.IsLastMileReturn = 1 THEN 0 ELSE do.Collect_OnDelivery END, 0) + ISNULL(do.PriceShippment, 0)) AS DECIMAL), 1)
                ELSE
                    CONVERT(VARCHAR, CAST((ISNULL(CASE WHEN do.IsLastMileReturn = 1 THEN 0 ELSE do.Collect_OnDelivery END, 0)) AS DECIMAL), 1)
            END
           ) AS Collect_OnDelivery,
		   do.IsCollect,
		   CASE WHEN ISNULL(do.ReceiverCountryId, 'GT') = @IdCountry OR ISNULL(SenderCountryId, 'GT') = @IdCountry THEN 1 ELSE 0 END AS Settlement
    FROM @GuidesFound gf
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
            ON do.Guide_Serie = gf.Guide_Serie
               AND do.Guide_Number = gf.Guide_Number;

    SELECT SUM(COD) AS COD_Manifest,
		   Settlement
    FROM @GuidesDetail
	GROUP BY Settlement;

    SELECT
		Guide
	   ,Delivered
	   ,COD
	   ,IsCollect
	FROM @GuidesDetail gd
	ORDER BY gd.Guide ASC

END;
