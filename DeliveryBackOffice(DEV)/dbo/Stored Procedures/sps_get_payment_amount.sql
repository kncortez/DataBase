
-- =============================================
-- Author:		<Aquino,César>
-- Create date: <2020-11-16,>
-- Description:	<Obtener monto a pagar segun guias selecionadas en formato json>
-- =============================================
CREATE PROCEDURE  [dbo].[sps_get_payment_amount]
	-- Add the parameters for the stored procedure here
	
	@InGuides   NVARCHAR(400) = 'FD22221,FD22361,FD22223,FD22359,FD22226'
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
      
  DECLARE @jsonHeader NVARCHAR(MAX)
  DECLARE @jsonDetail NVARCHAR(MAX)
  DECLARE @Commission_Porcent int

  select SUBSTRING(Item, 1,2) ItemSerie,SUBSTRING(Item,3,len(Item)) ItemNumber 
				into #listGuides_cod
				from DenariusDesktop_Dev.dbo.SplitUnlimited(@InGuides,',')

  set @Commission_Porcent =0
 SET @jsonHeader = (
 SELECT STUFF((
	SELECT  
  ',{"totalCommission":' + convert(varchar,sum(round((isnull(Det.Settlement_Collect_OnDelivery,0) *@Commission_Porcent/100 ),2))) + ',' +
  '"totalAmountToPay":' + convert(varchar,sum((isnull(Det.Settlement_Collect_OnDelivery,0) - round((isnull(Det.Settlement_Collect_OnDelivery,0) *@Commission_Porcent/100 ),2) ))) + ',' +
  '"totalCollect_OnDelivery":' + convert(varchar,sum(isnull(Det.Settlement_Collect_OnDelivery,0))) + ',' +
  '"totalCollectedAmount":' + convert(varchar,sum(isnull(o.PriceShippment,0))) + ',' +
  '"totalAmount":' + convert(varchar, sum(isnull(Det.Settlement_Collect_OnDelivery,0)) + sum(isnull(o.PriceShippment,0))) + ',' +  
  '"Currency":"' + 'GTQ' + '"}' 

	FROM #listGuides_cod as guides
	inner join [DeliveryBackOffice].[dbo].[DeliveryOrder] o on o.Guide_Serie = guides.ItemSerie and o.Guide_Number = guides.ItemNumber
  left join DeliveryBackOffice.dbo.DeliveryOrderPaid p on p.Guide_Serie = o.Guide_Serie and p.Guide_Number = o.Guide_Number
  left join [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] Det on Det.Guide_Serie = o.Guide_Serie and Det.Guide_Number = o.Guide_Number AND Det.RowStatus = 1
  FOR XML PATH(''), TYPE
 ).value('.', 'varchar(max)'),1,1,''
              ) 
			  )


  
   SET @jsonDetail = (
    SELECT STUFF((
  SELECT  ',{"Guide_Serie":"' + o.Guide_Serie + '",' +
  '"Guide_Number":' + convert(varchar,o.Guide_Number) + ',' +
  '"Department":"' + o.Sender_Department + '",' +
  '"Town":"' + o.Sender_Town + '",' +
  
  '"SenderName":"' + UPPER(COALESCE(o.Sender_FirstName,'')) + ' '+ UPPER(COALESCE(o.Sender_LastName,'')) + '",'+		

  '"Commission":' + convert(varchar,round((isnull(Det.Settlement_Collect_OnDelivery,0) *@Commission_Porcent/100 ),2))+ ',' +
  '"AmountToPay":' +convert(varchar,(isnull(Det.Settlement_Collect_OnDelivery,0) - round((isnull(Det.Settlement_Collect_OnDelivery,0) *@Commission_Porcent/100 ),2) ) )+ ',' +
  '"Collect_OnDelivery":' +convert(varchar,isnull(Det.Settlement_Collect_OnDelivery,0))+ ',' +
  '"IdManifest":' + convert(varchar,isnull(p.Guide_Number,0))+ ',' +
  '"CollectedAmount":' +  convert(varchar,isnull(o.PriceShippment,0)) + ',' +
  '"Comment":"' + ( 
	case
	when isnull(p.Guide_Number,0) > 0  then concat('Esta guia fue pagada con el manifiesto:  ',isnull(p.Guide_Number,0))
	when isnull(p.Guide_Number,0) = 0 and  isnull(Det.Settlement_Collect_OnDelivery,0) =0 then 'Guia no liquidada'
	else 'Guia liquidada pendiente de pago'
	end
	) + '",' +
	'"Status":"' + ( 
	case
	when isnull(p.Guide_Number,0) > 0  then 'PAGADO'
	when isnull(p.Guide_Number,0) = 0 and  isnull(Det.Settlement_Collect_OnDelivery,0) =0 then 'NO LIQUIDADO'
	else 'NO PAGADO'
	end
	) + '",' +	
	'"BankId":"' + ISNULL(CONVERT(varchar,c.DCBA_Bank_Id),'-1')  + '",' +
	'"BankName":"' + ISNULL(b.Acronym,'NO DISPONIBLE') + '",' +
	'"BankAccountType":"' + ISNULL(c.DCBA_BankAccountType,'NO DISPONIBLE') + '",' +
	'"BankAccountId":"' + ISNULL(c.DCBA_Num_account,'-1')  + '",' +
	'"BankAccountName":"' + isnull(c.DCBA_Nom_account,'NO DISPONIBLE') + '"}'	
		FROM #listGuides_cod as guides
		inner join [DeliveryBackOffice].[dbo].[DeliveryOrder] o on o.Guide_Serie = guides.ItemSerie and o.Guide_Number = guides.ItemNumber
	left join DeliveryBackOffice.dbo.DeliveryCustomerBankAccount c on c.DCBA_Id = o.DCBA_ID
	left join DeliveryBackOffice.dbo.DeliveryBank b on b.Id_bank = c.DCBA_Bank_Id
	left join DeliveryBackOffice.dbo.DeliveryOrderPaid p on p.Guide_Serie = o.Guide_Serie and p.Guide_Number = o.Guide_Number
	left join [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] Det on Det.Guide_Serie = o.Guide_Serie and Det.Guide_Number = o.Guide_Number AND Det.RowStatus = 1



FOR XML PATH(''), TYPE
 ).value('.', 'varchar(max)'),1,1,''
              ) 
			  )


select replace( '['+ @jsonHeader + '"services":[' + @jsonDetail + ']}]','}"services',',"services') FormatJson



END