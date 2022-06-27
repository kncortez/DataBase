


-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-12-08>
-- Description:	<Recupera detalle para generar manifiesto de liquidación (COD)>
-- =============================================
CREATE PROCEDURE [dbo].[spg_settlement_cod_guides]
		@IdManifest INT
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--DECLARE @IdManifest AS INT = 32181;
SELECT do.Guide_Serie + ISNULL(CONVERT(NVARCHAR, do.Guide_Number), '') Guide_Code,
       do.Pieces_Cold Pieces_Cold,
       do.Pieces_Dry Pieces_Dry,
       ISNULL(do.Receiver_FirstName, '') + ' ' + ISNULL(do.Receiver_LastName, '') Receiver_Fullname,
       IIF(cu.Name = 'FD EXPRESS CENTER', CONCAT(do.Sender_FirstName, ' ', do.Sender_LastName), cu.Name) AS Client,
       do.Receiver_Town Receiver_Town,
       do.Receiver_Department Receiver_Departament,
       CONVERT(VARCHAR, do.Preparation_Date, 103) + ' ' + CONVERT(VARCHAR(5), do.Preparation_Date, 108) Preparation_Date,
       CONVERT(VARCHAR, do.Shipping_Date, 103) Shipping_Date,
       ISNULL(CONVERT(VARCHAR, do.Delivery_Max_Date, 103), '') Max_Date,
       do.Receiver_Phone Receiver_Phone,
       (
           SELECT DeliveryBackOffice.dbo.fn_get_rackposition(do.Guide_Serie, do.Guide_Number)
       ) Rack_Position,
       CAST(IIF(do.IsCollect = 'TRUE', ISNULL(do.PriceShippment, 0), 0) AS DECIMAL(18, 2)) Price,
       CAST(ISNULL(do.Collect_OnDelivery, 0) AS DECIMAL(18, 2)) Collect_on_Delivery,
       CAST(IIF(do.IsCollect = 'TRUE',
                (ISNULL(do.Collect_OnDelivery, 0) + ISNULL(do.PriceShippment, 0)),
                ISNULL(do.Collect_OnDelivery, 0)) AS DECIMAL(18, 2)) Total,
       do.Receiver_ID Receiver_ID
FROM [DeliveryBackOffice].[dbo].DeliveryOrder do
    JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail dsd
        ON dsd.Guide_Serie = do.Guide_Serie
           AND dsd.Guide_Number = do.Guide_Number
           AND dsd.ID_DeliveryOrderBySettlement = @IdManifest
           AND dsd.RowStatus = 1
    LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vp
        ON do.Receiver_ID = vp.CodeOfReference
    LEFT JOIN [dbo].VisitPointClient vps
        ON vps.CodeOfReference = do.Sender_ID
    LEFT JOIN [dbo].[Customer] cu
        ON ISNULL(do.[IdCustomer], vps.CustomerID) = cu.[IdCustomer]
WHERE dsd.Guide_Settlement = 1 -- guía liquidada en bodega
      AND dsd.Guide_Discharged = 1 -- guía liquidada en COD
      AND
      (
          vp.IdKindOfVPClient <> 1
          OR vp.IdKindOfVPClient IS NULL
      )
	 -- AND dsd.Guide_Delivered =1
ORDER BY Receiver_Departament ASC,
         Receiver_Town ASC,
         Receiver_Zone ASC,
         Receiver_Address ASC;
	--SELECT * FROM @temp
	--order by Receiver_Departament asc, Receiver_Town asc, Receiver_Zone asc, Receiver_Address asc

END