
CREATE PROCEDURE [dbo].[sps_getReprintGuie]
  @Guide_Number int = 137916
  ,@Serie_Number varchar(2) = 'FD'
AS 
BEGIN 
 Declare   @jsonOutput VARCHAR(MAX) = '' 
  ,@parcels NVARCHAR(MAX) = ''
  /*pieces*/
  ,@i int = 0, @identity int = 1, @arpieces varchar(max) = '', @calcurrency varchar(50)=  ''
  ,@TotalWeight decimal(12,2), @TotalValue decimal(12,2)
  Declare @TMPPICES TABLE ( it int Identity(1,1), myrow int)  
  Declare @j int = 0, @integrationCost varchar(max) = '', @identityCost int
  
  select @i = count(1) 
  from DeliveryBackOffice.[dbo].[DeliveryOrderPiece] 
  where GuideNumber = @Guide_Number

  
  select @TotalWeight = isnull(sum(PieceWeight),0)
  from DeliveryBackOffice.[dbo].[DeliveryOrderPiece] 
  where GuideNumber = @Guide_Number

  
  select @TotalValue = isnull(sum(Amount),0)
  from DeliveryBackOffice.[dbo].[DeliveryOrderPiece] 
  where GuideNumber = @Guide_Number
  
  
  Insert into @TMPPICES (myrow)
	select GuidePiece
	from DeliveryBackOffice.[dbo].[DeliveryOrderPiece] 
	where GuideNumber = @Guide_Number

	DECLARE @DaysToExpiration INT = ( select isnull(cast(conf.Value as int),45) DaysToExpiration
	from DeliveryBackOffice.dbo.ConfigParams conf 
	where conf.Name ='DaysToExpiration' and Status =1)

  DECLARE @idCust BIGINT = (SELECT IdCustomer FROM DeliveryBackOffice.dbo.DeliveryOrder WHERE Guide_Number = @Guide_Number);
  DECLARE @customerType INT = (SELECT IdCustomerType FROM DeliveryBackOffice.dbo.Customer WHERE IdCustomer = @idCust);
  DECLARE @SalesChannel BIGINT = (SELECT SalePipeLineId FROM DeliveryBackOffice.dbo.DeliveryOrder WHERE Guide_Number = @Guide_Number);
  DECLARE @Impersonate VARCHAR(20)= CASE WHEN @salesChannel = 3 AND (@customerType = 1 OR @customerType = 3)  THEN 'TRUE' ELSE 'FALSE' END;
  DECLARE @ExpressName VARCHAR(50) = '';

  IF(@Impersonate = 'TRUE')
  BEGIN
	  SET @ExpressName = (SELECT DescriptionOfClient FROM DeliveryOrder do 
	  JOIN VisitPointClient vpc ON vpc.CodeOfReference = do.OriginSenderId  
	  WHERE Guide_Number= @Guide_Number)
  END
  ELSE
  BEGIN
	  IF (@SalesChannel = 3 OR @SalesChannel=4)
	  BEGIN
		  SET @ExpressName = (SELECT DescriptionOfClient FROM DeliveryOrder do 
		  JOIN VisitPointClient vpc ON vpc.CodeOfReference = do.Sender_ID  
		  WHERE Guide_Number= @Guide_Number)
	  END
  END
  
		 WHILE @i > 0
		 BEGIN
		   select @arpieces = @arpieces+ 
		 '{"length":'+ convert(varchar,isnull(PieceLength,0)	)+','+
		+'"width":'+  convert(varchar,isnull(PieceWidth	,0))+','+
		+'"height":'+ convert(varchar,isnull(PieceHeight	,0))+','+
		+'"weight":'+ convert(varchar,isnull(PieceWeight	,0))+','+
		+'"amount":'+ convert(varchar,isnull(Amount		,0)	)+', '
		+'"currency":"'+ COALESCE(Currency,'')+'",'+
		+'"fragil":'+case when fragile = 1 then 'true' else 'false' end+','+
		+'"description":"'+  COALESCE(Detail, '') + '"'
		+'},',@calcurrency =coalesce(Currency,'')
		from DeliveryBackOffice.[dbo].[DeliveryOrderPiece] 
		  where GuideNumber = @Guide_Number and GuidePiece = (select myrow from @TMPPICES where it = @identity)
		   Set @identity  = @identity + 1;
		   SET @i = @i - 1
		END
		
	if (@arpieces is not null and LEN(@arpieces)>0)
	BEGIN	
			SET @arpieces = LEFT(@arpieces, LEN(@arpieces) - 1) 
	END
	/*select @arpieces as cicloresult*/
  /*end pieces*/

  /*start integration cost*/

  Select @j = count(1) 
  from DeliveryBackOffice.[dbo].[Cost] ct
  left join DeliveryBackOffice.dbo.BreakdownOfPayment bdp ON bdp.IdCost = ct.IdCost
  where ProductNumber = CONCAT(@Serie_Number,@Guide_Number)

  SELECT  top 1 @identityCost = bdp.IdBreakdownOfPayment 
  from DeliveryBackOffice.[dbo].[Cost] ct
  left join DeliveryBackOffice.dbo.BreakdownOfPayment bdp ON bdp.IdCost = ct.IdCost
  where ProductNumber = CONCAT(@Serie_Number,@Guide_Number)

	WHILE @j > 0
		 BEGIN
		   select @integrationCost = @integrationCost+ 
		 '{"Currency":"'+'GTQ'+'",'+
		+'"Description":"'+  convert(varchar,isnull(Description	,0))+'",'+
		+'"Price":"'+ convert(varchar,isnull(Amount	,0))+'"'
		+'},'
		from DeliveryBackOffice.[dbo].[Cost] ct
		left join DeliveryBackOffice.dbo.BreakdownOfPayment bdp ON bdp.IdCost = ct.IdCost
		where ProductNumber = CONCAT(@Serie_Number,@Guide_Number) and IdBreakdownOfPayment = @identityCost
		   Set @identityCost  = @identityCost + 1;
		   SET @j = @j - 1
		END
		
	if (@integrationCost is not null and LEN(@integrationCost)>0)
	BEGIN	
			SET @integrationCost = LEFT(@integrationCost, LEN(@integrationCost) - 1) 
	END

	/*end integration cost*/
  
  SET @jsonOutput =  
  ( 
 
SELECT ''+ STUFF(( 
SELECT distinct top 1 --Price
   ',{"DateOfSale":"' +  Convert(varchar,isnull(dev.Preparation_Date, getdate()),121) +'",'+
   '"ContentDescription":"' + Convert(varchar,isnull(dev.Package_Description,''))+'",'+
   '"IdCountry":"'+ Convert(varchar,coalesce(p.IdCountry,'')) +'",'+
   '"CountPieces":'+Convert(varchar,isnull(dev.Pieces_Dry+dev.Pieces_Cold,0))+','+
  '"Collected":'+case when dev.IsCollect = 1 then 'true' else 'false' end+','+
  /*valor del felte para imprimir en la guia*/
  '"Price":"'+ coalesce(CONVERT(VARCHAR,dev.PriceShippment),'0.00')+'",'+
  /*valor collect*/
  '"IdCustomer":'+coalesce(Convert(varchar,ctm.IdCustomer), Convert(varchar,vp.CustomerID),'0')+','+
  '"from_address": {'+
  '"HeaderCodeTownship":"'+ Convert(varchar,coalesce(tws.HeaderCode,''))+'",'+
  -- Cambios para flujos de impersonar, creacion de Guias y Devoluciones
  '"name":"'+ REPLACE( dbo.fnt_String_Escape((CASE WHEN @Impersonate = 'TRUE' THEN
	--IMPERSONADO
	CASE WHEN (dev.IsReturn = 1) THEN
		--SI DEVOLUCION
		CASE WHEN (@customerType = 1) THEN
			--CORPORATIVO
			COALESCE(dev.Sender_FirstName,'')
		ELSE
			--INDIVIDUAL
			COALESCE(dev.Sender_FirstName,'')
		END
	ELSE
		-- NO DEVOLUCION
		CASE WHEN (@customerType = 1) THEN
			--CORPORATIVO
			COALESCE(vp.DescriptionOfClient,'')
		ELSE
			--INDIVIDUAL
			COALESCE(dev.Sender_FirstName,'')
		END
	END	
ELSE
	--NO IMPERSONADO
	Convert(varchar,coalesce(dev.Sender_FirstName,'')) + ' ' + Convert(varchar,coalesce(dev.Sender_LastName,''))
END),'json'),'"',' ')+'",'+
   '"phone":"'+ REPLACE(Convert(varchar,coalesce(dev.Sender_Phone,'')),'"',' ')+'",'+
   '"email":"'+ Convert(varchar,coalesce(rgu.UsrEmail,''))+'",'+
   '"address1":"'+ REPLACE(dbo.fnt_String_Escape(Convert(varchar(200),coalesce(dev.Sender_Address,'')),'json'),'"',' ')+'",'+
   '"address2":"'+ REPLACE(dbo.fnt_String_Escape( coalesce(dev.TypeService, 'EXP'),'json'),'"',' ') +'",'+
   '"city":"'+ COALESCE(ctm.Abbreviation,'')+'",'+
   '"IdMerchant":'+coalesce(Convert(varchar,ctm.IdCustomer),Convert(varchar,vp.CustomerID),'0')+','+
   -- Cambios para flujos de impersonar, creacion de Guias y Devoluciones
   '"contact":"'+(CASE WHEN @Impersonate = 'TRUE' THEN
	--IMPERSONADO
	CASE WHEN (dev.IsReturn = 1) THEN
		--SI DEVOLUCION
		CASE WHEN (@customerType = 1) THEN
			--CORPORATIVO
			COALESCE(@ExpressName,'')
		ELSE
			--INDIVIDUAL
			COALESCE(@ExpressName,'')
		END
	ELSE
		-- NO DEVOLUCION
		CASE WHEN (@customerType = 1) THEN
			--CORPORATIVO
			COALESCE(dev.Sender_FirstName,'')
		ELSE
			--INDIVIDUAL
			COALESCE(@ExpressName,'')
		END
	END	
ELSE
	--NO IMPERSONADO
	Convert(varchar,coalesce(dev.Sender_FirstName,'')) + ' ' + Convert(varchar,coalesce(dev.Sender_LastName,''))
END)+'"'+
   '},'+
  '"to_address": {'+
  '"HeaderCodeTownship":"'+ Convert(varchar,coalesce(tws2.HeaderCode,''))+'",'+
  '"name":"'+  REPLACE(dbo.fnt_String_Escape(COALESCE(dev.Receiver_FirstName,'') + ' ' + COALESCE(dev.Receiver_LastName,''),'json'),'"',' ')+'",'+
  '"phone":"'+  REPLACE(COALESCE(dev.Receiver_Phone,''),'"',' ')+'",'+
  '"email":"'+ REPLACE(COALESCE(dev.Receiver_Email,''),'"',' ')+'",'+
   '"address1":"'+ REPLACE(dbo.fnt_String_Escape(COALESCE(dev.Receiver_Address,''),'json'),'"',' ')+'",'+
  '"address2":"'+  REPLACE(dbo.fnt_String_Escape(COALESCE(lower(dev.IndicationsToSendDestination),''),'json'),'"',' ')+'",'+
  '"city":"'+''+'",'+
  '"ReceiverIdSettlement":'+Convert(varchar, ISNULL(dev.ReceiverIdSettlement ,0))+', '+ 
  '"contact":"'+ REPLACE( dbo.fnt_String_Escape(coalesce(dev.Receiver_Alternant_FullName,''),'json'),'"',' ')+'"'+
   '},'+
  '"parcels": ['
    + coalesce(@arpieces,'')+
  ' ] , '+
  '"TotalWeight":'+Convert(varchar,@TotalWeight)+', '+ 
  '"TotalValue":'+Convert(varchar,@TotalValue)+','+
  '"Currency":"'+'GTQ'+'",'+
  '"ProductInsuranceAmount":' + convert(varchar, cast(isnull(dev.InsuranceAmount ,0) as money))  +','+
  '"InsuranceCurrency":"' +Convert(varchar, @calcurrency)+'",'+
  '"CodeOfReference":' +Convert(varchar,coalesce(dev.Sender_ID,0))+','+
  '"IdInternalOrderRef":"' +Convert(varchar,coalesce( dev.Sender_Internal_Code,''))+'",'+
  -- '"Username":"' + dbo.fnt_String_Escape(Convert(varchar,coalesce( dev.Sender_Mail,'')),'json')+'",'+
  '"Username":"' + dbo.fnt_String_Escape(Convert(varchar,coalesce( dev.OrderUserCreated,'')),'json')+'",'+
   '"ExpirationDate":"' +Convert(varchar,coalesce(  DATEADD(DAY,@DaysToExpiration,dev.DateCreated) ,''),103)+'",'+
   '"Route":"'+  COALESCE(cov.RouteCode,'')+'",'+
   '"TypeService":"'+  dbo.fnt_String_Escape( coalesce(dev.TypeService, 'EXP'),'json') +'",'+
   '"Service_Payment":"'+  COALESCE(CPT.TimePlaName,'') +'",'+
  /*nueva seccion del si esta asegurado o no*/
  '"IsInsuarance":' + (case when dev.IsInsuarance = 1 then 'true' else 'false' end) +','+
  /**/
  /*Campos descripcion de entrega*/
  '"idDeliveryOption":' + Convert(NVARCHAR,coalesce(cdo.IdDeliveryOption,0))+','+ 
  '"descriptionDelivery":"' +REPLACE(dbo.fnt_String_Escape( coalesce(cdo.[Name], ''),'json'),'"',' ')+'",'+
  '"Impersonate":"' +@Impersonate+'",'+
  '"SaleChannel":' +CONVERT(NVARCHAR,coalesce(@SalesChannel,0))+','+
  /**/
  '"COD":  {'+
  '"CashOnDelivery": '+(case when dev.Collect_OnDelivery > 0 then 'true' else 'false' end)+','+	
  '"CreditNumber":"'+Convert(varchar,isnull(dev.Order_Number,0))+'",'+
  '"AmmountCashOnDelivery": '+coalesce(Convert(varchar,dev.Collect_OnDelivery),'0')+','+
  '"CashOnDeliveryCurrency":"'+'GTQ'+'",'+
  '"BankAccountName":"AccountName",'/*,*/+
  '"BankId":"'+coalesce(Convert(varchar,dcba.DCBA_Bank_Id),'')+'",'+	
  '"BankAccountType":"'+coalesce(Convert(varchar,dcba.DCBA_BankAccountType),'')+'",'+
  '"BankAccountId":"'+coalesce(Convert(varchar,dcba.DCBA_Num_account),'')+'",'+	
  '"Identification":"'+coalesce(Convert(varchar,dcba.DCBA_Identification),'')+'"'+
  ' },' +
   '"Integration": ['
    + coalesce(@integrationCost,'')+
  ' ] '+
  '} }' + ''
  from DeliveryBackOffice.dbo.DeliveryOrder dev 
      join DeliveryBackOffice.dbo.VisitPointClient vp on vp.CodeOfReference = dev.Sender_ID 
      left join DeliveryBackOffice.dbo.Customer ctm on ctm.IdCustomer = dev.IdCustomer 
      left join DeliveryBackOffice.dbo.Account acc on acc.IdCustomer = ctm.IdCustomer 
      --and acc.AccIdAccount = 1 
      left join DeliveryBackOffice.dbo.RolByUserByAccount rbu on rbu.RuaIdAccount = acc.AccIdAccount 
      left join DeliveryBackOffice.dbo.RegisterUser rgu on rgu.UsrIdUser = rbu.RuaIdUser 
      left join DeliveryBackOffice.dbo.Person prs on prs.PerIdPerson = rgu.UsrIdPerson 
      left join DeliveryBackOffice.dbo.Township tws on tws.IdTownship = dev.SenderIdTownship 
      left join DeliveryBackOffice.dbo.Township tws2 on tws2.IdTownship = dev.ReceiverIdTownship 
      left join DeliveryBackOffice.dbo.Province p on p.IdProvince = tws.IdProvince   
	  left join DeliveryBackOffice.dbo.Province p2 on p2.IdProvince = tws2.IdProvince   
      left join DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba on dcba.DCBA_Id = dev.DCBA_ID
      LEFT JOIN DeliveryBackOffice.dbo.CatDeliveryOptions cdo ON dev.IdDeliveryOption = cdo.IdDeliveryOption
	  left join DeliveryBackOffice.dbo.DumpServiceCoverage cov on cov.HeaderCode = tws2.HeaderCode
	  LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DOPD ON DOPD.GuideNumber = dev.Guide_Number
	  LEFT JOIN DeliveryBackOffice.dbo.CatPaymentTime CPT ON DOPD.TimePlaId = CPT.TimePlaId
	  and cov.RowStatus = 1
  where dev.Guide_Number = @Guide_Number

FOR XML PATH(''), TYPE 
  ) 
  .value('.', 'varchar(max)'),1,1,'' 
              ) + '' 
  ) 

  print @jsonOutput
 
  select  
  @jsonOutput
  FormatJson 
  
  
  end 
