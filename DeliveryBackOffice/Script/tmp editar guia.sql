declare 	
    @Token  as VARCHAR(200) = '123sdaasd'
	,@IdAccount bigint = 1
	 ,@GuideNumber int = 138520
	 ,@SerieGuides  varchar(2)			= 'FD'
	 ,@codApp as varchar(50) = 'SIFDCECOM300720201459' 
	 , @jsonResult1 varchar(Max) = ''
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
   --'"address2":"'+  coalesce(dev.TypeService, 'EXP') +'",'+
   --'"city":"'+ COALESCE(ctm.Abbreviation,'')+'",'+
   '"contact":"'+coalesce('','')+'"'+
   '},'+
  '"to_address": {'+
  '"HeaderCodeTownship":"'+ Convert(varchar,coalesce(tws2.HeaderCode,''))+'",'+
  '"name":"'+  COALESCE(dev.Receiver_FirstName,'') + ' ' + COALESCE(dev.Receiver_LastName,'')+'",'+
  '"phone":"'+  COALESCE(dev.Receiver_Phone,'')+'",'+
  '"email":"'+ COALESCE(dev.Receiver_Email,'')+'",'+
   '"address1":"'+ COALESCE(dev.Receiver_Address,'')+'",'+
  --'"address2":"'+ COALESCE(dev.IndicationsToSendDestination,'')+'",'+
  --'"city":"'+''+'",'+
  '"contact":"'+coalesce(dev.Receiver_Alternant_FullName,'')+'"'+
   '},'+
  '"parcels": ['
    + coalesce(@arpieces,'')+
  ' ] , '+
  '"TotalWeight":'+Convert(varchar,@TotalWeight)+', '+ 
  '"TotalValue":'+Convert(varchar,@TotalValue)+','+
  '"Currency":"'+Convert(varchar,coalesce(p.IdCountry ,''))+'",'+
  --'"ProductInsuranceAmount":10,'+
  '"InsuranceCurrency":"' +Convert(varchar, @calcurrency)+'",'+
  '"CodeOfReference":' +Convert(varchar,coalesce(dev.Order_Number,0))/*+','+
  '"COD":  {'+
  '"CashOnDelivery": '+case when dev.Collect_OnDelivery > 0 then 'true' else 'false' end+','+		
  '"CreditNumber":"'+Convert(varchar,isnull(dev.Order_Number,0))+'",'+
  '"AmmountCashOnDelivery": '+coalesce(Convert(varchar,dev.Collect_OnDelivery),'0')+','+
  '"CashOnDeliveryCurrency":"'+'GTQ'+'",'+
  '"BankAccountName":"AccountName",',+
  '"BankId":"'+coalesce(Convert(varchar,dcba.DCBA_Bank_Id),'')+'",'+	
  '"BankAccountType":"'+coalesce(Convert(varchar,dcba.DCBA_BankAccountType),'')+'",'+
  '"BankAccountId":"'+coalesce(Convert(varchar,dcba.DCBA_Num_account),'')+'",'+	
  '"Identification":"'+coalesce(Convert(varchar,dcba.DCBA_Identification),'')+'"'+
  ' } '*/
  +'}'
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
  , @AmmountValue decimal(18,2) = 0 ,@WeightValue as decimal(18,2);
  --@TotalWeight , @TotalValue, @calcurrency
  select @CountPieces = count(1)
  from @TMPPICES;

  select top 1 @idcustumer = coalesce(dev.IdCustomer,0)
		,@HeaderCodeSource = Convert(varchar,coalesce(tws.HeaderCode,''))
		,@HeaderCodeDestiny = Convert(varchar,coalesce(tws2.HeaderCode,''))
		, @FechaCompra = coalesce(dev.DateCreated,getdate())
		, @ObjectType = coalesce(dev.de,'')
		,@AmmountValue = coalesce(Convert(varchar,dev.Collect_OnDelivery),'0')--preguntar
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





  /*pintada general*/
  select  
  @jsonResult1+''+
  @jsonOutput
  FormatJson 
  
  
  select top 1000 d.* from DeliveryBackOffice..DeliveryOrder p
  join DeliveryOrderPiece d on d.GuideNumber = p.Guide_Number  and d.GuideSerie = p.Guide_Serie
  where --p.Guide_Number > 138500 and 
  d.Currency is null