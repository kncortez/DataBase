use DeliveryBackOffice 
go
IF OBJECT_ID('ServiceNotification') IS not NULL
BEGIN
 Drop procedure [dbo].[ServiceNotification] 
END
go
CREATE PROCEDURE [dbo].[ServiceNotification] 
  @SystemId int = 1, 
  @Guide_Serie varchar(2) = 'FD',  
  @Guide_Number int = 89750, 
  @AccountId int = 10 
AS 
BEGIN 
  SET NOCOUNT ON; 
  DECLARE @jsonOutput NVARCHAR(MAX) 
    SET @jsonOutput =  
  ( 
 
SELECT ''+ STUFF(( 
SELECT  distinct 
          ',{""ClientName"":""' +  CONVERT(varchar,ctm.[Name]) + '"",'+            
          '""GuideNumber"":' + CONVERT(varchar,dev.Guide_Number)  + ','+ 
          '""ForzaEmail"":""' + 'info.gt@forzadelivery.com'  + '"",'+ 
          '""ForzaPhone"":""' + '23775300'  + '"",'+   
          '""EmailAccount"":""' + coalesce(rgu.UsrEmail,'')  + '"",'+  
          '""OriginName"":""' + coalesce(prs.PerFirstName,'') + ' ' + coalesce(prs.PerLastName,'')  + '"",'+   
          '""OriginAddress"":""' + coalesce(dev.Receiver_Address,'') + '"",'+  
          '""OriginTownship"":""' + coalesce(tws.TownshipName,'') + '"",'+              
          '""OriginPhone"":""' + coalesce(dev.Sender_Phone,'') + '"",'+             
          '""DestinationName"":""' + COALESCE(dev.Receiver_FirstName,'') + ' ' + COALESCE(dev.Receiver_LastName,'') + '"",'+            
          '""DestinationAddress"":""' + COALESCE(dev.Receiver_Address,'') + '"",'+              
          '""DestinationTownship"":""' + COALESCE(tws2.TownshipName,'') + '"",'+            
          '""DestinationPhone"":""' + COALESCE(dev.Receiver_Phone,'') + '"",'+              
          '""DestinationMail"":""' + COALESCE(dev.Receiver_Email,'') + '"",'+           
          '""PackageDescription"":""' + COALESCE(dev.Package_Description,'') + '"",'+            
           '""Weight"":' + COALESCE(Convert(varchar,
		 (
		 select sum(piec.Piece_Weight) Piece_Weight from DeliveryBackOffice.dbo.DeliveryPiece piec where dev.Guide_Serie = piec.Guide_Serie and dev.Guide_Number = piec.Guide_Number
		 )
		 ),'0.00') + ','+         
          '""PiecesAccount"":' + COALESCE(Convert(varchar,(dev.Pieces_Dry+dev.Pieces_Cold)),'') + ','+             
          '""TypeOfPay"":' + COALESCE(
		  (select H.inv_type from DeliveryBackOffice.dbo.invoiceDetail sub 
		  join DeliveryBackOffice.dbo.invoiceHeader H  on (sub.dti_fk_header = H.inv_pk_id)
		  where sub.dti_fk_orderSerie  =  dev.Guide_Serie and sub.dti_fk_orderNumber = dev.Guide_Number
		  )
		  ,'0') + ','+
          '""TypeService"":' + COALESCE('0','') + ','+     
          '""AmmountCOD"":' + COALESCE('0','') + ','+        
          '""AmmountCollect"":' + COALESCE(convert(varchar,dev.Collect_OnDelivery),'0.00') + ','+     
            '""GrandTotal"":' + COALESCE(
		(select  convert(varchar,sum(dti_amount)) total from DeliveryBackOffice.dbo.invoiceDetail sub where sub.dti_fk_orderSerie  =  dev.Guide_Serie and sub.dti_fk_orderNumber = dev.Guide_Number) ,'0.00') + ','+   
          '""EstimationDate"":""' + CONVERT(varchar,'') + '""}'        
      from DeliveryBackOffice.dbo.DeliveryOrder dev 
      join DeliveryBackOffice.dbo.VisitPointClient vp on vp.CodeOfReference = dev.Sender_ID 
      join DeliveryBackOffice.dbo.Customer ctm on ctm.IdCustomer = vp.CustomerID 
      join DeliveryBackOffice.dbo.Account acc on acc.IdCustomer = ctm.IdCustomer 
      and acc.AccIdAccount = @AccountId 
      join DeliveryBackOffice.dbo.RolByUserByAccount rbu on rbu.RuaIdAccount = acc.AccIdAccount 
      join DeliveryBackOffice.dbo.RegisterUser rgu on rgu.UsrIdUser = rbu.RuaIdUser 
      join DeliveryBackOffice.dbo.Person prs on prs.PerIdPerson = rgu.UsrIdPerson 
      join DeliveryBackOffice.dbo.Township tws on tws.IdTownship = dev.SenderIdTownship 
      join DeliveryBackOffice.dbo.Township tws2 on tws2.IdTownship = dev.ReceiverIdTownship 
	  where dev.Guide_Number =@Guide_Number
      and dev.Guide_Serie = @Guide_Serie  
  FOR XML PATH(''), TYPE 
  ) 
  .value('.', 'varchar(max)'),1,1,'' 
              ) + '' 
  ) 
 
  select  
  @jsonOutput  
  FormatJson 
 
END