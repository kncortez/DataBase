use DeliveryBackOffice  
go
IF OBJECT_ID('sps_getReprintGuie') IS NOT NULL
BEGIN
 Drop procedure [dbo].[sps_getReprintGuie] 
END
go
CREATE PROCEDURE [dbo].[sps_getReprintGuie]
  @Guide_Number int = 137916
AS 
BEGIN 
  SET NOCOUNT ON; 
  Declare   @jsonOutput NVARCHAR(MAX) = '' 
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
  '""parcels"": [ {'+
   '""length"":'+'2,'+
   '""width"":'+'5,'+
   '""height"":'+'5,'+
   '""weight"":'+'7,'+
   '""amount"":'+'10,'+
   '""currency"":""'+Convert(varchar,coalesce(p.IdCountry ,''))+'"",'+
   '""description"":""'+COALESCE(dev.Package_Description,'')+'""'+
  '} ], '+
  '""TotalWeight"":7, '+ 
  '""TotalValue"":10,'+
  '""Currency"":""'+Convert(varchar,coalesce(p.IdCountry ,''))+'"",'+
  '""ProductInsuranceAmount"":10,'+
  '""InsuranceCurrency"":""' + Convert(varchar,coalesce(p.IdCountry ,''))+'"",'+
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
      and acc.AccIdAccount = 1 
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
