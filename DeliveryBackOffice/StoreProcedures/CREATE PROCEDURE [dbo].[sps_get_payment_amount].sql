-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Aquino,César>
-- Create date: <2020-11-16,>
-- Description:	<Obtener monto a pagar segun guias selecionadas en formato json>
-- =============================================
CREATE PROCEDURE  [dbo].[sps_get_payment_amount]
	-- Add the parameters for the stored procedure here
	
	@InGuides   NVARCHAR(400) = '22221,22361,22223,22359,22226'
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
      
  DECLARE @jsonHeader NVARCHAR(MAX)
  DECLARE @jsonDetail NVARCHAR(MAX)
 SET @jsonHeader = (
	SELECT  
  sum(round((isnull(Det.Settlement_Collect_OnDelivery,0) *3/100 ),2))   as 'totalCommission'
  ,sum((isnull(Det.Settlement_Collect_OnDelivery,0) - round((isnull(Det.Settlement_Collect_OnDelivery,0) *3/100 ),2) )) as 'totalAmountToPay' 
  ,sum(isnull(Det.Settlement_Collect_OnDelivery,0)) as  'totalCollect_OnDelivery'
  , sum(isnull(Det.Settlement_Collect_OnDelivery,0)) as 'totalCollectedAmount'
	FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] o
  left join DeliveryBackOffice.dbo.DeliveryOrderPaid p on p.Guide_Serie = o.Guide_Serie and p.Guide_Number = o.Guide_Number
  left join [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] Det on Det.Guide_Serie = o.Guide_Serie and Det.Guide_Number = o.Guide_Number
 /* where o.Collect_OnDelivery is not null */
  where o.Guide_Number in(SELECT value  
								FROM STRING_SPLIT(@InGuides, ',')  
								WHERE RTRIM(value) <> '')
   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
  
   SET @jsonDetail = (
  SELECT  o.Guide_Serie as 'Guide_Serie'
  , o.Guide_Number as 'Guide_Nuber'
  , o.Sender_Department as  'Department'
  , o.Sender_Town   as 'Town'
  ,round((isnull(Det.Settlement_Collect_OnDelivery,0) *3/100 ),2)   as 'Commission'
  ,(isnull(Det.Settlement_Collect_OnDelivery,0) - round((isnull(Det.Settlement_Collect_OnDelivery,0) *3/100 ),2) ) as 'AmountToPay' 
  ,isnull(Det.Settlement_Collect_OnDelivery,0) as  'Collect_OnDelivery'
  ,  isnull(p.Guide_Number,0) as 'IdManifest'
  , isnull(Det.Settlement_Collect_OnDelivery,0) as 'CollectedAmount'
  , ( 
	case
	when isnull(p.Guide_Number,0) > 0  then concat('Esta guia fue pagada con el manifiesto:  ',isnull(p.Guide_Number,0))
	when isnull(p.Guide_Number,0) = 0 and  isnull(Det.Settlement_Collect_OnDelivery,0) =0 then 'Guia no liquidada'
	else 'Guia liquidada pendiente de pago'
	end
	) as 'Comment'
	, ( 
	case
	when isnull(p.Guide_Number,0) > 0  then 'PAGADO'
	when isnull(p.Guide_Number,0) = 0 and  isnull(Det.Settlement_Collect_OnDelivery,0) =0 then 'NO LIQUIDADO'
	else 'NO PAGADO'
	end
	) as 'Satatus'
	FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] o
  left join DeliveryBackOffice.dbo.DeliveryOrderPaid p on p.Guide_Serie = o.Guide_Serie and p.Guide_Number = o.Guide_Number
  left join [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] Det on Det.Guide_Serie = o.Guide_Serie and Det.Guide_Number = o.Guide_Number
 /* where o.Collect_OnDelivery is not null */
  where o.Guide_Number in(SELECT value  
								FROM STRING_SPLIT(@InGuides, ',')  
								WHERE RTRIM(value) <> '')
   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

select replace( '['+ @jsonHeader + '"services":[' + @jsonDetail + ']}]','}"services',',"services') FormatJson



END
GO
