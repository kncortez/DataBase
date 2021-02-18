USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_getReprintGuie]    Script Date: 1/29/2021 2:02:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sps_getReprintGuie]
  @Guide_Number int = 137916
  ,@Serie_Number varchar(2) = 'FD'
AS 
BEGIN 
 Declare   @jsonOutput NVARCHAR(MAX) = '' 
  ,@parcels NVARCHAR(MAX) = ''
  /*pieces*/
  ,@i int = 0, @identity int = 1, @arpieces varchar(max) = '', @calcurrency varchar(50)=  ''
  ,@TotalWeight decimal(12,2), @TotalValue decimal(12,2)
  Declare @TMPPICES TABLE ( it int Identity(1,1), myrow int)
  
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
  
  SET @jsonOutput =  
  ( 
 
SELECT ''+ STUFF(( 
SELECT distinct top 1 
   ',{"DateOfSale":"' +  Convert(varchar,isnull(dev.Preparation_Date, getdate())) +'",'+
   '"ContentDescription":"' + Convert(varchar,isnull(dev.Package_Description,''))+'",'+
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
   '"address2":"'+  coalesce(dev.TypeService, 'EXP') +'",'+
   '"city":"'+ COALESCE(ctm.Abbreviation,'')+'",'+
   '"contact":"'+coalesce('','')+'"'+
   '},'+
  '"to_address": {'+
  '"HeaderCodeTownship":"'+ Convert(varchar,coalesce(tws2.HeaderCode,''))+'",'+
  '"name":"'+  COALESCE(dev.Receiver_FirstName,'') + ' ' + COALESCE(dev.Receiver_LastName,'')+'",'+
  '"phone":"'+  COALESCE(dev.Receiver_Phone,'')+'",'+
  '"email":"'+ COALESCE(dev.Receiver_Email,'')+'",'+
   '"address1":"'+ COALESCE(dev.Receiver_Address,'')+'",'+
  '"address2":"'+ COALESCE(dev.IndicationsToSendDestination,'')+'",'+
  '"city":"'+''+'",'+
  '"contact":"'+coalesce(dev.Receiver_Alternant_FullName,'')+'"'+
   '},'+
  '"parcels": ['
    + coalesce(@arpieces,'')+
  ' ] , '+
  '"TotalWeight":'+Convert(varchar,@TotalWeight)+', '+ 
  '"TotalValue":'+Convert(varchar,@TotalValue)+','+
  '"Currency":"'+Convert(varchar,coalesce(p.IdCountry ,''))+'",'+
  '"ProductInsuranceAmount":10,'+
  '"InsuranceCurrency":"' +Convert(varchar, @calcurrency)+'",'+
  '"CodeOfReference":' +Convert(varchar,coalesce(dev.Order_Number,0))+','+
  /*nueva seccion del si esta asegurado o no*/
  '"IsInsuarance":' +CASE WHEN  dev.Collect_OnDelivery > 750 then case when dev.IsInsuarance = 1 then 'true' else 'false' end
  else 'true' end +','+
  /**/
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
  ' } } }'
  from DeliveryBackOffice.dbo.DeliveryOrder dev 
      join DeliveryBackOffice.dbo.VisitPointClient vp on vp.CodeOfReference = dev.Sender_ID 
      left join DeliveryBackOffice.dbo.Customer ctm on ctm.IdCustomer = vp.CustomerID 
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
  where dev.Guide_Number = @Guide_Number

FOR XML PATH(''), TYPE 
  ) 
  .value('.', 'varchar(max)'),1,1,'' 
              ) + '' 
  ) 


 
  select  
  @jsonOutput
  FormatJson 
  
  
  end 