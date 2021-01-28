use DeliveryBackOffice 
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
          '""OriginAddress"":""' + coalesce(REPLACE(ISNULL(dev.Receiver_Address,''),'"',''),'') + '"",'+  
          '""OriginTownship"":""' + coalesce(tws.TownshipName,'') + '"",'+              
          '""OriginPhone"":""' + coalesce(dev.Sender_Phone,'') + '"",'+             
          '""DestinationName"":""' + COALESCE(dev.Receiver_FirstName,'') + ' ' + COALESCE(dev.Receiver_LastName,'') + '"",'+            
          '""DestinationAddress"":""' + COALESCE(REPLACE(ISNULL(dev.Receiver_Address,''),'"',''),'') + '"",'+              
          '""DestinationTownship"":""' + COALESCE(tws2.TownshipName,'') + '"",'+            
          '""DestinationPhone"":""' + COALESCE(REPLACE(ISNULL(dev.Receiver_Phone,''),';',' '),'') + '"",'+              
          '""DestinationMail"":""' + COALESCE(dev.Receiver_Email,'') + '"",'+           
          '""PackageDescription"":""' + COALESCE(dev.Package_Description,'') + '"",'+            
           '""Weight"":' + COALESCE(Convert(varchar,
		 (
		 select CONVERT(VARCHAR,sum(piec.PieceWeight)) PieceWeight from DeliveryBackOffice.dbo.DeliveryOrderPiece piec where dev.Guide_Serie = piec.GuideSerie and dev.Guide_Number = piec.GuideNumber
		 )
		 ),'0.00') + ','+         
          '""PiecesAccount"":' + COALESCE(Convert(varchar,(dev.Pieces_Dry+dev.Pieces_Cold)),'0') + ','+             
          '""TypeOfPay"":""' + (
		  case when dev.IsCollect = 1 then 'Collect' else 'Contado' end
		  ) 
		  + '"",'+
          '""TypeService"":""' + COALESCE(dev.TypeService,'') + '"",'+     
          '""AmmountCOD"":' + COALESCE('0','') + ','+        
          '""AmmountCollect"":' + COALESCE(convert(varchar,dev.Collect_OnDelivery),'0.00') + ','+     
            '""GrandTotal"":' + COALESCE(Convert(varchar,isnull(dev.PriceShippment,'0.00')) ,'0.00') + ','+   
          '""EstimationDate"":""' + COALESCE(Convert(varchar,Delivery_Max_Date, 105),'') + '""}'        
      from DeliveryBackOffice.dbo.DeliveryOrder dev 
      left join DeliveryBackOffice.dbo.VisitPointClient vp on vp.CodeOfReference = dev.Sender_ID 
      left join DeliveryBackOffice.dbo.Customer ctm on ctm.IdCustomer = vp.CustomerID 
      left join DeliveryBackOffice.dbo.Account acc on acc.IdCustomer = ctm.IdCustomer 
      and acc.AccIdAccount = @AccountId 
      left join DeliveryBackOffice.dbo.RolByUserByAccount rbu on rbu.RuaIdAccount = acc.AccIdAccount 
      left join DeliveryBackOffice.dbo.RegisterUser rgu on rgu.UsrIdUser = rbu.RuaIdUser 
      left join DeliveryBackOffice.dbo.Person prs on prs.PerIdPerson = rgu.UsrIdPerson 
      left join DeliveryBackOffice.dbo.Township tws on tws.IdTownship = dev.SenderIdTownship 
      left join DeliveryBackOffice.dbo.Township tws2 on tws2.IdTownship = dev.ReceiverIdTownship 
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
