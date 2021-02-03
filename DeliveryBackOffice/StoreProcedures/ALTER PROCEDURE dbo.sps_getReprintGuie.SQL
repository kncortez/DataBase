USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_getReprintGuie]    Script Date: 1/29/2021 2:02:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[sps_getReprintGuie]
  @Guide_Number int = 137916
  ,@Serie_Number varchar(2) = 'FD'
AS 
BEGIN 



  SET NOCOUNT ON; 
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
		 '{""length"":'+ convert(varchar,isnull(PieceLength,0)	)+','+
		+'""width"":'+  convert(varchar,isnull(PieceWidth	,0))+','+
		+'""height"":'+ convert(varchar,isnull(PieceHeight	,0))+','+
		+'""weight"":'+ convert(varchar,isnull(PieceWeight	,0))+','+
		+'""amount"":'+ convert(varchar,isnull(Amount		,0)	)+', '
		+'""currency"":""'+ COALESCE(Currency,'')+'"",'+
		+'""description"":""'+  COALESCE(Detail, '') + '""'
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
	
	
  /*end pieces*/
  
  SET @jsonOutput =  
  ( 
 
SELECT ''+ STUFF(( 
SELECT  distinct 
   ',{""DateOfSale"":""' +  Convert(varchar,isnull(dev.Preparation_Date, getdate())) +'"",'+
   '""ContentDescription"":""' + Convert(varchar,isnull(dev.Package_Description,''))+'"",'+
   '""IdCountry"":""'+ Convert(varchar,coalesce(p.IdCountry,'')) +'"",'+
   '""CountPieces"":'+Convert(varchar,isnull(dev.Pieces_Dry+dev.Pieces_Cold,0))+','+
  '""from_address"": {'+
  '""HeaderCodeTownship"":""'+ Convert(varchar,coalesce(tws.HeaderCode,''))+'"",'+
  '""name"":""'+Convert(varchar,coalesce(prs.PerFirstName,'')) + ' ' + Convert(varchar,coalesce(prs.PerLastName,''))+'"",'+
   '""phone"":""'+ Convert(varchar,coalesce(dev.Sender_Phone,''))+'"",'+
   '""email"":""'+ Convert(varchar,coalesce(rgu.UsrEmail,''))+'"",'+
   '""address1"":""'+ Convert(varchar,coalesce(dev.Receiver_Address,''))+'"",'+
   '""address2"":""'+  ''+'"",'+
   '""city"":""'+ ''+'"",'+
   '""contact"":""'+coalesce('Empresa del Cliente que envia','')+'""'+
   '},'+
  '""to_address"": {'+
  '""HeaderCodeTownship"":""'+ Convert(varchar,coalesce(tws2.HeaderCode,''))+'"",'+
  '""name"":""'+  COALESCE(dev.Receiver_FirstName,'') + ' ' + COALESCE(dev.Receiver_LastName,'')+'"",'+
  '""phone"":""'+  COALESCE(dev.Receiver_Phone,'')+'"",'+
  '""email"":""'+ COALESCE(dev.Receiver_Email,'')+'"",'+
   '""address1"":""'+ COALESCE(dev.Receiver_Address,'')+'"",'+
  '""address2"":""'+ ''+'"",'+
  '""city"":""'+  ''+'"",'+
  '""contact"":""'+coalesce('Empresa del Cliente que recibe','')+'""'+
   '},'+
  '""parcels"": ['
    + @arpieces+
  ' ] , '+
  '""TotalWeight"":'+Convert(varchar,@TotalWeight)+', '+ 
  '""TotalValue"":'+Convert(varchar,@TotalValue)+','+
  '""Currency"":""'+Convert(varchar,coalesce(p.IdCountry ,''))+'"",'+
  '""ProductInsuranceAmount"":10,'+
  '""InsuranceCurrency"":""' +Convert(varchar, @calcurrency)+'"",'+
  '""CodeOfReference"":' +Convert(varchar,coalesce(dev.Order_Number,0))+','+
  '""COD"":  {'+
  '""CashOnDelivery"": true,'+		
  '""CreditNumber"":""'+Convert(varchar,isnull(dev.Order_Number,0))+'"",'+
  '""AmmountCashOnDelivery"": 100,'+
  '""CashOnDeliveryCurrency"":""'+'GTQ'+'"",'+
  '""BankAccountName"":""AccountName"",',+
  '""BankId"":""1"",'+	
  '""BankAccountType"":""Monetaria"",'+
  '""BankAccountId"":""090-10-639996"",'+	
  '""Identification"":""1000983780101""'+
  ' } } }'
  from DeliveryBackOffice.dbo.DeliveryOrder dev 
      join DeliveryBackOffice.dbo.VisitPointClient vp on vp.CodeOfReference = dev.Sender_ID 
      join DeliveryBackOffice.dbo.Customer ctm on ctm.IdCustomer = vp.CustomerID 
      join DeliveryBackOffice.dbo.Account acc on acc.IdCustomer = ctm.IdCustomer 
      --and acc.AccIdAccount = 1 
      join DeliveryBackOffice.dbo.RolByUserByAccount rbu on rbu.RuaIdAccount = acc.AccIdAccount 
      join DeliveryBackOffice.dbo.RegisterUser rgu on rgu.UsrIdUser = rbu.RuaIdUser 
      join DeliveryBackOffice.dbo.Person prs on prs.PerIdPerson = rgu.UsrIdPerson 
      join DeliveryBackOffice.dbo.Township tws on tws.IdTownship = dev.SenderIdTownship 
      join DeliveryBackOffice.dbo.Township tws2 on tws2.IdTownship = dev.ReceiverIdTownship 
      join DeliveryBackOffice.dbo.Province p on p.IdProvince = tws.IdProvince   
	  join DeliveryBackOffice.dbo.Province p2 on p2.IdProvince = tws2.IdProvince   
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
