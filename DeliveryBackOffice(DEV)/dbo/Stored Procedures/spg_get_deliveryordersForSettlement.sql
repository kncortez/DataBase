



-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-05-27>
-- Description:	<Devuelve información para liquidación de ruta>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_deliveryordersForSettlement] @IdManifest AS INT
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
		IsCollect BIT
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
               AND dsd.RowStatus = 1
    WHERE dbs.ID = @IdManifest
          AND
          (
              dsd.Guide_Settlement = 0
              OR dsd.Guide_Settlement IS NULL
          );
		  
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
                    CONVERT(VARCHAR, CAST((ISNULL(CASE WHEN do.IsLastMileReturn = 1 THEN 0 ELSE do.Collect_OnDelivery END, 0) + ISNULL(CASE WHEN do.IsLastMileReturn = 1 THEN CASE WHEN ISNULL(cdp.IdConditionOfPayment, 1) > 1 THEN 0 ELSE do.PriceShippment END ELSE do.PriceShippment END, 0)) AS DECIMAL), 1)
                ELSE
                    CONVERT(VARCHAR, CAST((ISNULL(CASE WHEN do.IsLastMileReturn = 1 THEN 0 ELSE do.Collect_OnDelivery END, 0)) AS DECIMAL), 1)
            END
           ) AS Collect_OnDelivery,
		   do.IsCollect
    FROM @GuidesFound gf
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
            ON do.Guide_Serie = gf.Guide_Serie
               AND do.Guide_Number = gf.Guide_Number
		LEFT JOIN [dbo].VisitPointClient vps WITH(NOLOCK)
			ON vps.CodeOfReference = do.Sender_ID
		LEFT JOIN [dbo].[Customer] cu WITH(NOLOCK)
			ON ISNULL(do.[IdCustomer], vps.CustomerID) = cu.[IdCustomer]
		LEFT JOIN dbo.CatConditionOfPayment cdp WITH (NOLOCK)
            ON cdp.IdConditionOfPayment = cu.ConditionOfPaymentID
               AND cdp.IdConditionOfPayment > 1;

    SELECT SUM(COD) AS COD_Manifest
    FROM @GuidesDetail;

    SELECT
		Guide
	   ,Delivered
	   ,COD
	   ,IsCollect
	FROM @GuidesDetail gd
	ORDER BY gd.Guide ASC

END;
