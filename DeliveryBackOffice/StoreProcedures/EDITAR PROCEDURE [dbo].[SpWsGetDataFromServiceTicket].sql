use DeliveryBackOffice
go
ALTER PROCEDURE [dbo].[SpWsGetDataFromServiceTicket]
  @IdAccount int = 37,  
  @TrackingNumber varchar(100) = 'FD138358',
  @Token varchar(100) = 'C6A98D3AB3A005C0023D634A6ECD1E5B'
AS
BEGIN


    if not exists
     ( select 1
	  from DeliveryBackOffice.dbo.TokenLog
	  where TknRowStatus = 1 and TknIdToken = @Token	  
	  and CAST(TknDateCreated AS DATE) = CAST(getdate() AS DATE)  
	 )
	 BEGIN
	  print 'token inválido'
	  select '500 'IdError
	  ,'Token inválido'IdDescription	  
	  return

	 END
	 BEGIN

	 DECLARE @TotalWeight as decimal
	 DECLARE @TotalValue as decimal
	 DECLARE @ContentDescription as varchar(200)

	 select @TotalWeight = SUM(DOP.PieceWeight)
	       ,@TotalValue = SUM(DOP.Amount) 
     from DeliveryBackOffice.dbo.DeliveryOrderPiece DOP
	 where DOP.GuideSerie = substring(@TrackingNumber,1,2)
		   and DOP.GuideNumber = substring(@TrackingNumber,3,LEN(@TrackingNumber))
	 	
	 select top 1  @ContentDescription = DOP.Detail
     from DeliveryBackOffice.dbo.DeliveryOrderPiece DOP
	 where DOP.GuideSerie = substring(@TrackingNumber,1,2)
		   and DOP.GuideNumber = substring(@TrackingNumber,3,LEN(@TrackingNumber))	 				
		
	 select
	 PRV.IdCountry IdCountry,
	 DOR.Pieces_Cold + DOR.Pieces_Dry CountPieces
	 ,@TotalWeight TotalWeight
	 ,COALESCE(Collect_OnDelivery,0) TotalValue
	 ,DOR.Guide_Serie + CONVERT(varchar,DOR.Guide_Number) TrackingNumber
	 ,replace(convert(NVARCHAR, DOR.Delivery_Max_Date, 103),' ','/') DeliveryDate
	 ,DOR.PriceShippment Price
	 ,DOR.IsCollect Collected
	 ,@ContentDescription ContentDescription
	 ,IVH.inv_cli_nit TaxPayerNumber
	 ,IVH.inv_pk_id idInvoice
	 ,'' VPDescriptionOfClient
	 ,'' PriviceVisitPoint -- ????
	 ,'' CountryVisitPoint
	 ,'' VPAdress
	 ,COALESCE( Receiver_FirstName,'') + ' ' + COALESCE(Receiver_LastName ,'')  FromName 
	 ,Receiver_Phone FromPhone
	 ,coalesce( Receiver_Email,'') FromEmail					
	 ,Receiver_Address FromAddress
	 ,PRV2.ProvinceDescription  FromCity					
	 ,COALESCE(Sender_FirstName,'') + ' ' + COALESCE(Sender_LastName,'') ToName 
	 ,Sender_Phone ToPhone
	 ,coalesce(  rgu.UsrEmail,'') ToEmail					
	 ,Sender_Address ToAddress
	 ,PRV.ProvinceDescription  ToCity	 
	 from DeliveryBackOffice.dbo.DeliveryOrder DOR
	 join DeliveryBackOffice.dbo.Account ACC on  ACC.IdCustomer = DOR.IdCustomer
	 left join DeliveryBackOffice.dbo.RolByUserByAccount rbu on rbu.RuaIdAccount = acc.AccIdAccount
	 left join DeliveryBackOffice.dbo.RegisterUser rgu on rgu.UsrIdUser = rbu.RuaIdUser
	 join DeliveryBackOffice.dbo.Township TOW ON TOW.IdTownship = DOR.SenderIdTownship
	 join DeliveryBackOffice.dbo.Province PRV ON PRV.IdProvince = TOW.IdProvince
	 left join DeliveryBackOffice.dbo.invoiceDetail IVD ON IVD.dti_fk_orderSerie = DOR.Guide_Serie
	 	 AND IVD.dti_fk_orderNumber = DOR.Guide_Number
	 left join DeliveryBackOffice.dbo.invoiceHeader IVH ON IVH.inv_pk_id = IVD.dti_fk_header
	 join DeliveryBackOffice.dbo.Township TOW2 ON TOW2.IdTownship = DOR.ReceiverIdTownship
	 join DeliveryBackOffice.dbo.Province PRV2 ON PRV2.IdProvince = TOW2.IdProvince
	 where DOR.Guide_Serie = substring(@TrackingNumber,1,2)
	 and DOR.Guide_Number = substring(@TrackingNumber,3,LEN(@TrackingNumber))
	 and  ACC.AccIdAccount = @IdAccount
	 
	 END
END
