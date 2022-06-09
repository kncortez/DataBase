/*-- =============================================
-- Author:		<>
-- Create date: <2021-02-15>
-- Description:	<Devuelve editar pago>
-- =============================================*/
CREATE PROCEDURE [dbo].[sps_SetEditGuides]
	 @Token  as VARCHAR(200) = '123sdaasd' ,
	 @GuideNumber as int = 138520			,
	 @SerieGuides as varchar(2) = 'FD'		,
	 @codApp as varchar(50) = 'SIFDCECOM300720201459' 
AS
BEGIN

  		IF OBJECT_ID('tempdb.dbo.#Ecommrce', 'U') IS NOT NULL DROP TABLE #Ecommrce;
			IF OBJECT_ID('tempdb.dbo.#HubSource', 'U') IS NOT NULL DROP TABLE #HubSource;
			IF OBJECT_ID('tempdb.dbo.#MonCurrency', 'U') IS NOT NULL DROP TABLE #MonCurrency;
			IF OBJECT_ID('tempdb.dbo.#HubDestiny', 'U') IS NOT NULL DROP TABLE #HubDestiny;
			IF OBJECT_ID('tempdb.dbo.#GeneralRate', 'U') IS NOT NULL DROP TABLE #GeneralRate;
			IF OBJECT_ID('tempdb.dbo.#Exceso', 'U') IS NOT NULL DROP TABLE #Exceso;


declare 	
	  @jsonResult1 varchar(Max) = ''
	 , @jsonResult varchar(Max) = ''
	 /*encabezado general*/
SELECT top 1 @jsonResult1 =
						  ' {"Guide":"' +   isnull(concat(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",' +
							'"RequestDate":"' + isnull( convert(varchar,ord.DateCreated,20), 'N/A')  + '",' +
							'"Source":"' + isnull(concat(twn.TownshipName, pr.ProvinceAbbreviation),'N/A') + '",' +
							'"Destiny":"' + isnull(concat(twd.TownshipName, prd.ProvinceAbbreviation),'N/A') + '",' +
							'"NameofSender":"' + isnull(CAST(upper(isnull(ord.Sender_FirstName,'')) AS VARCHAR)+' '+ CAST(upper(isnull(ord.Sender_LastName,'')) AS varchar),'N/A')  + '",' +
							'"NameReceiver":"' + isnull(CAST(upper(isnull(ord.Receiver_Alternant_FullName,'')) AS VARCHAR) +' '+ CAST(upper(isnull(ord.Receiver_LastName,'')) AS VARCHAR),'N/A' ) + '",' +
							'"AddresofSender":"' + isnull(CAST(upper(isnull(ord.Sender_Address,'N/A')) AS VARCHAR), 'N/A' ) + '",' +
							'"DateRecoleccion":"' + isnull(CAST(convert(varchar, ord.Preparation_Date,20 ) AS varchar), 'N/A')  + '",' +
							'"DateProgramadaEntrega":"' + isnull(CAST(convert( varchar, ord.Shipping_Date,20)as varchar), 'N/A')  + '",' +
							'"CurrencySymbol":"' +convert( varchar, 'Q.')  +  '",' +
							'"PrecioServicio":"' + CONVERT(varchar,cast( coalesce(ord.PriceShippment ,'0')as money),1)   + '",' +
							'"CollectOnDelivery":"' + CONVERT(varchar,cast(coalesce(ord.Collect_OnDelivery,'0')as money),1)   + '",' +
							'"ShippmentComplete":' + CONVERT(varchar, coalesce(paydord.ShipmentCompleted ,'false'))   + ',' +
							'"IdStatus":' + CONVERT(varchar, coalesce(sto.StatusOrderId ,'0'))   + ',' +
							'"Status":"' + isnull(convert( varchar, sto.OrderDescription) , 'N/A') +  '",' +
							'"WayToPay":"' + iif(isnull(paydord.ShipmentCompleted,0)=0,'PENDIENTE',(  isnull(convert( varchar, case 
																		when paydord.TypeofInOutMoneyId = 1 THEN UPPER(catpay.PayTypeName)
																		when paydord.TypeofInOutMoneyId = 2 THEN UPPER(catpay.PayTypeName)
																		ELSE CASE WHEN ord.IsCollect = 1 THEN 'COLLECT' ELSE 'CONTADO' END		
																																		END ) ,'N/A'))) +  '",' +
							'"TypePayment":"' + isnull(convert( varchar,  case 
																		when paydord.TypeofInOutMoneyId  = 1 THEN UPPER(ctgmon.tio_pk_name)
																		when paydord.TypeofInOutMoneyId = 2 THEN UPPER(ctgmon.tio_pk_name)
																		when paydord.TypeofInOutMoneyId = 3 THEN UPPER(ctgmon.tio_pk_name)
																		when paydord.TypeofInOutMoneyId = 4 THEN UPPER(ctgmon.tio_pk_name)
																		ELSE CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END
																																			END ),'N/A')  +  '",' +
							'"CollectDelivery":"' + isnull(CONVERT(varchar,CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') + --'",' +
						
							+ '",  '

						from dbo.DeliveryOrder ord
						join dbo.StatusOrder sto on sto.StatusOrderId =  ord.StatusOrderId
						LEFT join [dbo].[DeliveryOrderPaymentDetail] paydord On (ord.Guide_Number = paydord.GuideNumber)
						LEFT join [dbo].[CatPaymentType] catpay on (catpay.PayTypeId = paydord.PayTypeId)
						LEFT join [dbo].[CatPaymentTime] cattime on (cattime.TimePlaId     =  paydord.TimePlaId)
						LEFT join [dbo].[ctgTypeOfInOutOfMoney] ctgmon on(ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId)
						left join dbo.Township twn on twn.IdTownship = ord.SenderIdTownship
						left join dbo.Province pr on pr.IdProvince = twn.IdProvince
						left join dbo.Township twd on twd.IdTownship = ord.ReceiverIdTownship
						left join dbo.Province prd on prd.IdProvince = twd.IdProvince
					
						 where ord.Guide_Number= @GuideNumber
						

				/*piezas y datos del destinatario y remitente*/
		
 Declare   @jsonOutput NVARCHAR(MAX) = '' 
  ,@parcels NVARCHAR(MAX) = ''
  /*pieces*/
  ,@i int = 0, @identity int = 1, @arpieces varchar(max) = '', @calcurrency varchar(50)=  ''
  ,@TotalWeight decimal(12,2), @TotalValue decimal(12,2)
  Declare @TMPPICES TABLE ( it int Identity(1,1), myrow int)
  
  select @i = count(1) 
  from DeliveryBackOffice.[dbo].[DeliveryOrderPiece] 
  where GuideNumber = @GuideNumber

  
  select @TotalWeight = isnull(sum(PieceWeight),0)
  from DeliveryBackOffice.[dbo].[DeliveryOrderPiece] 
  where GuideNumber = @GuideNumber

  
  select @TotalValue = isnull(sum(Amount),0)
  from DeliveryBackOffice.[dbo].[DeliveryOrderPiece] 
  where GuideNumber = @GuideNumber
  
  
  Insert into @TMPPICES (myrow)
	select GuidePiece
	from DeliveryBackOffice.[dbo].[DeliveryOrderPiece] 
	where GuideNumber = @GuideNumber
  
		 WHILE @i > 0
		 BEGIN
		   select @arpieces = @arpieces+ 
		 '{"length":'+ convert(varchar,isnull(PieceLength,0)	)+','+
		+'"width":'+  convert(varchar,isnull(PieceWidth	,0))+','+
		+'"height":'+ convert(varchar,isnull(PieceHeight	,0))+','+
		+'"weight":'+ convert(varchar,isnull(PieceWeight	,0))+','+
		+'"amount":'+ convert(varchar,isnull(Amount		,0)	)+', '
		+'"currency":"'+ COALESCE(Currency,'')+'",'+
		+'"description":"'+  COALESCE(Detail, '') + '"'
		+'},',@calcurrency =coalesce(Currency,'')
		from DeliveryBackOffice.[dbo].[DeliveryOrderPiece] 
		  where GuideNumber = @GuideNumber and GuidePiece = (select myrow from @TMPPICES where it = @identity)
		   Set @identity  = @identity + 1;
		   SET @i = @i - 1
		END
		
	if (@arpieces is not null and LEN(@arpieces)>0)
	BEGIN	
			SET @arpieces = LEFT(@arpieces, LEN(@arpieces) - 1) 
	END
  /*end pieces*/
  
  SET @jsonOutput =  
  ( 
 
SELECT ''+ STUFF(( 
SELECT distinct top 1
   ', "ContentDescription":"' + Convert(varchar,isnull(dev.Package_Description,''))+'",'+
   '"IdCountry":"'+ Convert(varchar,coalesce(p.IdCountry,'')) +'",'+
   '"CountPieces":'+Convert(varchar,isnull(dev.Pieces_Dry+dev.Pieces_Cold,0))+','+
  '"Collected":'+case when dev.IsCollect = 1 then 'true' else 'false' end+','+
  '"IdCustomer":'+coalesce(Convert(varchar,ctm.IdCustomer),'0')+','+
  '"from_address": {'+
  '"HeaderCodeTownship":"'+ Convert(varchar,coalesce(tws.HeaderCode,''))+'",'+
  '"name":"'+Convert(varchar,coalesce(prs.PerFirstName,'')) + ' ' + Convert(varchar,coalesce(prs.PerLastName,''))+'",'+
   '"phone":"'+ Convert(varchar,coalesce(dev.Sender_Phone,''))+'",'+
   '"email":"'+ Convert(varchar,coalesce(rgu.UsrEmail,''))+'",'+
   '"address1":"'+ Convert(varchar,coalesce(dev.Receiver_Address,''))+'",'+
   '"address2":"'+  coalesce(dev.IndicationsToSendOrigin, '') +'",'+
   '"contact":"'+coalesce('','')+'"'+
   '},'+
  '"to_address": {'+
  '"HeaderCodeTownship":"'+ Convert(varchar,coalesce(tws2.HeaderCode,''))+'",'+
  '"name":"'+  COALESCE(dev.Receiver_FirstName,'') + ' ' + COALESCE(dev.Receiver_LastName,'')+'",'+
  '"phone":"'+  COALESCE(dev.Receiver_Phone,'')+'",'+
  '"email":"'+ COALESCE(dev.Receiver_Email,'')+'",'+
   '"address1":"'+ COALESCE(dev.Receiver_Address,'')+'",'+
  '"address2":"'+ COALESCE(dev.IndicationsToSendDestination,'')+'",'+
  '"contact":"'+coalesce(dev.Receiver_Alternant_FullName,'')+'"'+
   '},'+
  '"parcels": ['
    + coalesce(@arpieces,'')+
  ' ] , '+
  '"TotalWeight":'+Convert(varchar,@TotalWeight)+', '+ 
  '"TotalValue":'+Convert(varchar,@TotalValue)+','+
  '"Currency":"'+Convert(varchar,coalesce(p.IdCountry ,''))+'",'+
  '"InsuranceCurrency":"' +Convert(varchar, @calcurrency)+'",'+
  '"CodeOfReference":' +Convert(varchar,coalesce(dev.Order_Number,0))
  from DeliveryBackOffice.dbo.DeliveryOrder dev 
      join DeliveryBackOffice.dbo.VisitPointClient vp on vp.CodeOfReference = dev.Sender_ID 
      left join DeliveryBackOffice.dbo.Customer ctm on ctm.IdCustomer = vp.CustomerID 
      left join DeliveryBackOffice.dbo.Account acc on acc.IdCustomer = ctm.IdCustomer 
      left join DeliveryBackOffice.dbo.RolByUserByAccount rbu on rbu.RuaIdAccount = acc.AccIdAccount 
      left join DeliveryBackOffice.dbo.RegisterUser rgu on rgu.UsrIdUser = rbu.RuaIdUser 
      left join DeliveryBackOffice.dbo.Person prs on prs.PerIdPerson = rgu.UsrIdPerson 
      left join DeliveryBackOffice.dbo.Township tws on tws.IdTownship = dev.SenderIdTownship 
      left join DeliveryBackOffice.dbo.Township tws2 on tws2.IdTownship = dev.ReceiverIdTownship 
      left join DeliveryBackOffice.dbo.Province p on p.IdProvince = tws.IdProvince   
	  left join DeliveryBackOffice.dbo.Province p2 on p2.IdProvince = tws2.IdProvince   
      left join DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba on dcba.DCBA_Id = dev.DCBA_ID 
  where dev.Guide_Number = @GuideNumber

FOR XML PATH(''), TYPE 
  ) 
  .value('.', 'varchar(max)'),1,1,'' 
              ) + '' 
  ) 

  /*detalle del servicio al cotizar*/
  declare @idcustumer as int = 0, @HeaderCodeSource as varchar(10) = '', @HeaderCodeDestiny as varchar(10) = ''
  , @FechaCompra as datetime, @Country as varchar(5) = 'GT', @ObjectType as varchar(5000) = '', @CountPieces as int = 0
  , @AmmountValue decimal(18,2) = 0 ,@WeightValue as decimal(18,2), @IsFragil as varchar(50) = 'false' , 
  @IsCollected as varchar(50) = '' ;
  select @CountPieces = count(1)
  from @TMPPICES;

  select top 1 @idcustumer = coalesce(dev.IdCustomer,0)
		,@HeaderCodeSource = Convert(varchar,coalesce(tws.HeaderCode,''))
		,@HeaderCodeDestiny = Convert(varchar,coalesce(tws2.HeaderCode,''))
		, @FechaCompra = coalesce(dev.DateCreated,getdate())
		, @ObjectType = ''
		,@AmmountValue = coalesce(Convert(varchar,dev.Collect_OnDelivery),'0')
		,@IsCollected = case when dev.IsCollect = 1 then 'true' else 'false' end
		from DeliveryBackOffice.dbo.DeliveryOrder dev 
      join DeliveryBackOffice.dbo.VisitPointClient vp on vp.CodeOfReference = dev.Sender_ID 
      left join DeliveryBackOffice.dbo.Customer ctm on ctm.IdCustomer = vp.CustomerID 
      left join DeliveryBackOffice.dbo.Account acc on acc.IdCustomer = ctm.IdCustomer 
      left join DeliveryBackOffice.dbo.RolByUserByAccount rbu on rbu.RuaIdAccount = acc.AccIdAccount 
      left join DeliveryBackOffice.dbo.RegisterUser rgu on rgu.UsrIdUser = rbu.RuaIdUser 
      left join DeliveryBackOffice.dbo.Person prs on prs.PerIdPerson = rgu.UsrIdPerson 
      left join DeliveryBackOffice.dbo.Township tws on tws.IdTownship = dev.SenderIdTownship 
      left join DeliveryBackOffice.dbo.Township tws2 on tws2.IdTownship = dev.ReceiverIdTownship 
      left join DeliveryBackOffice.dbo.Province p on p.IdProvince = tws.IdProvince   
	  left join DeliveryBackOffice.dbo.Province p2 on p2.IdProvince = tws2.IdProvince   
      left join DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba on dcba.DCBA_Id = dev.DCBA_ID 
  where dev.Guide_Number = @GuideNumber
 
 DECLARE @IdRateSegment  int = 0
		declare @HubSource int =0
		declare @HubDestiny  int =0
		declare @TownshipSource int =0
		declare @TownshipDestiny int =0

		select twn.IdTownship 
			,twn.IdProvince
			,thb.IdHublogistic
			,thb.IdRateSegment
			into #HubSource
				from dbo.Township twn
		join dbo.TownshipByHubLogistic thb on thb.IdTownship = twn.IdTownship
		where twn.HeaderCode = @HeaderCodeSource

		select  twn.IdTownship
			,twn.IdProvince
			,thb.IdHublogistic
			,thb.IdRateSegment
			into #HubDestiny
			from dbo.Township twn
		join dbo.TownshipByHubLogistic thb on thb.IdTownship = twn.IdTownship
		where twn.HeaderCode = @HeaderCodeDestiny

		set @HubSource = (select top 1 IdHublogistic from #HubSource)
		set @HubDestiny = (select top 1 IdHublogistic from #HubDestiny)

		set @TownshipSource = (select top 1 IdTownship from #HubSource)
		set @TownshipDestiny = (select top 1 IdTownship from #HubDestiny)

		
		Declare @IVA as decimal(12,2)= (select top 1 (sur.PercentValue) from dbo.Surcharge sur where sur.IdSurcharge = 6) 

		select 
				cts.CtsName as Segment,
				cts.CtsDescription as Description,
				cts.CtsId as IdService,
				cts.CtsName  as ServiceName,
				cts.CtsShortName as ServiceShortName,
				(rdt.RbhRate * @CountPieces ) as Rate
				,0 AS FragileRate
				,0  AS InsuranceRate
				,iif(@IsCollected = 'true',
				(CASE
				WHEN 	rdt.RbhCollectedRate > 1 THEN (rdt.RbhCollectedRate * @CountPieces)
				ELSE  round((rdt.RbhCollectedRate * rdt.RbhRate * @CountPieces ),2)
				END),0) AS CollectedRate,
				rdt.RbhWeightLimit as limit,
				iif(@WeightValue> rdt.RbhWeightLimit,(@WeightValue - rdt.RbhWeightLimit) *  rdt.RbhWeightAdditionalRate ,0) as WeightAdditionalRate,
				iif(@WeightValue> rdt.RbhWeightLimit,(@WeightValue - rdt.RbhWeightLimit)  ,0) as WeightAdditional
				,(select (rdt.RbhRate* @CountPieces * sur.PercentValue /100 ) from dbo.Surcharge sur where sur.IdSurcharge = 6) as Taxes 
				,(select ( sur.PercentValue) from dbo.Surcharge sur where sur.IdSurcharge = 6)AS TaxPorcent, 
				rdt.RbhCollectedRate,  @CountPieces as pieces, rdt.RbhWeightAdditionalRate as AditionalRate
	
			 into #GeneralRate
				from dbo.RatebyCustomer rbc
				 join dbo.RateByHub rdt on rdt.RbhIdRate   = rbc.RbcIdRate
				join dbo.CatTypeService cts on cts.CtsId = rdt.RbhIdTypeService
				and cts.CtsShortName = (select TypeService from DeliveryBackOffice.dbo.DeliveryOrder ord where ord.Guide_Number  = @GuideNumber)
			where rdt.RbhIdHubSource = @HubSource and rdt.RbhIdHubDestiny = @HubDestiny and  rbc.RbcIdCustomer = @idcustumer  and rdt.RbhRowStatus = 1 

			IF OBJECT_ID('tempdb.dbo.#Weights', 'U') IS NOT NULL DROP TABLE #Weights;
			select cast(@CountPieces as int) as Item 
				into #Weights
				--from DenariusDesktop_Dev.dbo.SplitUnlimited(@WeigthParcels,',')

			select Idservice, sum(iif((item- limit)>0,(item- limit),0)) as exceso 
			into #Exceso 
			from #GeneralRate
			left join #Weights on 1=1
			group by IdService



			 declare @jsonResult3 as nvarchar(max) = '';
			 

			          select @jsonResult3 =   
					  ' ,"Title":"' + COALESCE(gr.Segment,'')  + '",' +
					'"Service":"' + COALESCE(gr.ServiceName,'') + '",' +
					'"ServiceDescription":"' + COALESCE(gr.Description,'') + '",' +
					'"ServiceShortName":"' + COALESCE(gr.ServiceShortName,'') + '",' +
						'"DeliveryDate":"' + COALESCE(Convert(varchar(24),@FechaCompra,120),'') + '",'
						+'"Price":"'  
						+COALESCE(convert(varchar(20),(gr.Rate + gr.InsuranceRate + gr.CollectedRate + (gr.AditionalRate * ex.exceso))),'') 
						+ '",'+
						'"Integration":[{"Description":"' + 'Servicio' + '",' +
						'"Price":"' +COALESCE(convert(varchar(20),gr.Rate /(1+(gr.TaxPorcent/100))),'') + '",' +
						'"Currency":"' + COALESCE(@calcurrency,'') + '"' +
						'}'+
						 iif(gr.InsuranceRate>0, ',{"Description":"' + 'Seguro' + '",' + 
						'"Price":"' +COALESCE(convert(varchar(20),gr.InsuranceRate/(1+(gr.TaxPorcent/100))),'') + '",' +
						'"Currency":"' + COALESCE(@calcurrency,'') + '"' +
						'}' ,' '  ) +
						 iif(gr.CollectedRate>0, ',{"Description":"' + 'Pago en Destino' + '",' + 
						'"Price":"' +COALESCE(convert(varchar(20),gr.CollectedRate/(1+(gr.TaxPorcent/100))),'') + '",' +
						'"Currency":"' + COALESCE(@calcurrency,'') + '"' +
						'}' ,' '  ) +
						 iif((gr.AditionalRate * ex.exceso)>0, ',{"Description":"' + 'Recargo por Peso' + '",' + 
						'"Price":"' +COALESCE(convert(varchar(20),(gr.AditionalRate * ex.exceso)/(1+(gr.TaxPorcent/100))),'') + '",' +
						'"Currency":"' + COALESCE(@calcurrency,'') + '"' +
						'}' ,' '  ) +
						',{"Description":"' + 'IVA' + '",' +
						'"Price":"' +COALESCE(convert(varchar(20),  (((gr.Rate +gr.FragileRate + gr.InsuranceRate + gr.CollectedRate + (gr.AditionalRate * ex.exceso))/(1+(gr.TaxPorcent/100))) * (gr.TaxPorcent/100)) ),'') + '",' +
						'"Currency":"' + COALESCE(@calcurrency,'') + '"' +
						'}'+
						' ]}'
					  from #GeneralRate gr
					  left join #Exceso ex on ex.IdService =  gr.IdService

			
  select  
  @jsonResult1+''+
  @jsonOutput + ''+ @jsonResult3
  FormatJson 
  
  		IF OBJECT_ID('tempdb.dbo.#Ecommrce', 'U') IS NOT NULL DROP TABLE #Ecommrce;
			IF OBJECT_ID('tempdb.dbo.#HubSource', 'U') IS NOT NULL DROP TABLE #HubSource;
			IF OBJECT_ID('tempdb.dbo.#MonCurrency', 'U') IS NOT NULL DROP TABLE #MonCurrency;
			IF OBJECT_ID('tempdb.dbo.#HubDestiny', 'U') IS NOT NULL DROP TABLE #HubDestiny;
			IF OBJECT_ID('tempdb.dbo.#GeneralRate', 'U') IS NOT NULL DROP TABLE #GeneralRate;
			IF OBJECT_ID('tempdb.dbo.#Exceso', 'U') IS NOT NULL DROP TABLE #Exceso;

end