-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,2023-03-03>
-- Description:	<Description, SP para cabecera de reporte de guías en carrito de compra que no estan liquidadas y no son collect>
-- =============================================
CREATE PROCEDURE [dbo].[RptGuidesWithoutLiquidationinShoppingCartDetail] 
@IdManifiesto int	
AS
BEGIN

     DECLARE @TotalGuide int
	 DECLARE @temp TABLE (
		Guide_Code	nvarchar(max),
		Sender_Fullname nvarchar(201),
		Sender_Phone nvarchar(100),
		Sender_Address nvarchar(600),
	    TotalPrice  Decimal(18,2)
	                      )

	SET NOCOUNT ON;

	-- tablix content
	INSERT INTO @temp
							SELECT
								  DO.Guide_Serie + Cast(DO.Guide_Number as nvarchar(20))
								  ,DO.Sender_FirstName +' '+ DO.Sender_LastName	
								  ,DO.Sender_Phone
								  ,DO.Sender_Address
								  ,DO.PriceShippment

							FROM
								[DeliveryBackOffice].[dbo].[AccountServiceCartDetail] AccSCD WITH(NOLOCK)
							INNER JOIN
								[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
							ON
							    [DO].[Guide_Serie] = [AccSCD].[GuideSerie] AND [DO].[Guide_Number] = [AccSCD].[GuideNumber]
							INNER JOIN
								[DeliveryBackOffice].[dbo].[Cost] Co WITH(NOLOCK)
							ON
								[Co].[GuideSerie] = [DO].[Guide_Serie] AND [Co].[GuideNumber] = [DO].[Guide_Number]
							INNER JOIN
								[DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH(NOLOCK)
							ON  Co.GuideSerie = DSD.Guide_Serie And  Co.GuideNumber= DSD.Guide_Number
							INNER JOIN
								[DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH(NOLOCK)
							ON DSD.ID_DeliveryOrderBySettlement = DOBS.ID AND dsd.RowStatus = 1
							Inner Join  
							    [DeliveryBackOffice].[dbo].[SettlementByPickupDetail] spd WITH(NOLOCK)
							ON DO.Guide_Serie = spd.GuideSerie AND DO.Guide_Number = spd.GuideNumber
							INNER JOIN 
							    [DeliveryBackOffice].[dbo].[SettlementByPickup] sp WITH(NOLOCK)
			                ON spd.SettlementByPickupId = sp.Id
							WHERE  [AccSCD].[RowStatus] = 1 AND
								   [DO].[IsCollect] = 0 AND
								   [Co].[TotalAmountPaid] IS NULL AND
								   [sp].Id = @IdManifiesto

    SELECT Guide_Code,
	       Sender_Fullname,
		   Sender_Phone,
		   Sender_Address,
		   TotalPrice
	FROM @temp
	Order By Guide_Code Desc
END