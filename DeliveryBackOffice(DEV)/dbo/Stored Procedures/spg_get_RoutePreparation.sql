



-- =============================================
-- Author:		<Bidcar, Herrera>
-- Create date: <2020-05-27>
-- Description:	<Devuelve información para preparación de ruta>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_RoutePreparation]
		@Token AS VARCHAR(50)    = 'ad1a2328ed27ea99622f68deae5d9976',
		@Rol AS BIGINT 			 =  1,
		@Guide AS VARCHAR(100) = '',
		@Sender AS VARCHAR(100) = '',
		@Receiver AS VARCHAR(100) ='',
		@ReceiverPhone AS VARCHAR(50) = ''
AS
--
--exec [dbo].[spg_get_RoutePreparation] @Manifest = 'FM1003'
BEGIN

IF (@Guide IS NOT NULL AND LEN(@Guide) > 0)
BEGIN

	  	SELECT  			 
			serv.Guide_Serie +  CAST(serv.Guide_Number AS VARCHAR) Guide,			
			isnull(serv.Receiver_FirstName,'') + ' '+ isnull(serv.Receiver_LastName,'') 'Name',
			serv.Receiver_Address 'Address',			
			STUFF(( SELECT  '| ' + CONVERT(VARCHAR(200),SMR.SMS_Message)  +' '
			FROM [DeliveryBackOffice].[dbo].[GuidesBySMS] B WITH(NOLOCK)
			inner join DeliveryBackOffice.dbo.SMS_Received SMR WITH(NOLOCK)
			 on B.SmsId = SMR.SMS_ID
			WHERE   
				B.GuideSerie = serv.Guide_Serie
				and B.GuideNumber = serv.Guide_Number

			FOR
			XML PATH('')
		), 1, 1, '') AS Alter_Address,

			serv.Receiver_Zone 'Zone',
			serv.Receiver_Town Town,
			serv.Receiver_Department Department,
			'' DateSettlement,
			serv.Delivery_Max_Date Delivery_Max_Date,
			serv.Courier_Route Courier_Route,
			serv.Courier_Name Courier_Name,
			serv.Dispatched_Date Dispatched_Date,
			serv.Manifest_Serie + CAST(serv.Manifest_Number AS VARCHAR) as Manifest_Number,
			serv.DateCreated as Date_Created,
			isnull(serv.Sender_FirstName,'') + ' ' + isnull(serv.Sender_LastName,'') as Sender_Fullname,
			serv.Ticket_Number as Ticket_Number,
			serv.Pieces_Dry as Pieces_Dry,
			serv.Pieces_Cold as Pieces_Cold,
			(SELECT so.OrderDescription FROM StatusOrder so WITH(NOLOCK) WHERE so.StatusOrderId = serv.StatusOrderId) as Status_Order_Id,
			serv.Receiver_Phone as Receiver_Phone,
			(SELECT p.Package_Name FROM Package p WITH(NOLOCK) WHERE p.Package_Type = serv.Package_Type) as Package_Type,
			(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(serv.Guide_Serie, serv.Guide_Number)) as Rack_Position,
			ISNULL(serv.Contact_Confirmed, 0) as Contact_Confirmed,
			serv.Contact_Instructions,
			ISNULL(serv.Receiver_CUI, '') as CUI,
			ISNULL(serv.Receiver_SocialSecurity_ID, '') as SocialSecurityID
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.StatusOrder sta WITH(NOLOCK) ON sta.StatusOrderId = serv.StatusOrderId
		WHERE 
		CONVERT(DATE, serv.DateCreated) BETWEEN CONVERT(DATE, GETDATE()-90) AND CONVERT( DATE, GETDATE()) AND 
		serv.StatusOrderId NOT IN( 7,15,5,22) AND -- ocultar los servicios anulados		
		(CONVERT(VARCHAR(100),serv.Guide_Number) = @Guide)  OR
		(serv.Guide_Serie + CONVERT(VARCHAR(100),serv.Guide_Number) = @Guide) 		 
END
ELSE IF (@Sender IS NOT NULL AND LEN(@Sender) > 0)
BEGIN
	  	SELECT  			 
			serv.Guide_Serie +  CAST(serv.Guide_Number AS VARCHAR) Guide,			
			isnull(serv.Receiver_FirstName,'') + ' '+ isnull(serv.Receiver_LastName,'') 'Name',
			serv.Receiver_Address 'Address',			
			STUFF(( SELECT  '| ' + CONVERT(VARCHAR(200),SMR.SMS_Message)  +' '
			FROM [DeliveryBackOffice].[dbo].[GuidesBySMS] B WITH(NOLOCK)
			inner join DeliveryBackOffice.dbo.SMS_Received SMR WITH(NOLOCK)
			 on B.SmsId = SMR.SMS_ID
			WHERE   
				B.GuideSerie = serv.Guide_Serie
				and B.GuideNumber = serv.Guide_Number

			FOR
			XML PATH('')
		), 1, 1, '') AS Alter_Address,

			serv.Receiver_Zone 'Zone',
			serv.Receiver_Town Town,
			serv.Receiver_Department Department,
			'' DateSettlement,
			serv.Delivery_Max_Date Delivery_Max_Date,
			serv.Courier_Route Courier_Route,
			serv.Courier_Name Courier_Name,
			serv.Dispatched_Date Dispatched_Date,
			serv.Manifest_Serie + CAST(serv.Manifest_Number AS VARCHAR) as Manifest_Number,
			serv.DateCreated as Date_Created,
			isnull(serv.Sender_FirstName,'') + ' ' + isnull(serv.Sender_LastName,'') as Sender_Fullname,
			serv.Ticket_Number as Ticket_Number,
			serv.Pieces_Dry as Pieces_Dry,
			serv.Pieces_Cold as Pieces_Cold,
			(SELECT so.OrderDescription FROM StatusOrder so WITH(NOLOCK) WHERE so.StatusOrderId = serv.StatusOrderId) as Status_Order_Id,
			serv.Receiver_Phone as Receiver_Phone,
			(SELECT p.Package_Name FROM Package p WITH(NOLOCK) WHERE p.Package_Type = serv.Package_Type) as Package_Type,
			(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(serv.Guide_Serie, serv.Guide_Number)) as Rack_Position,
			ISNULL(serv.Contact_Confirmed, 0) as Contact_Confirmed,
			serv.Contact_Instructions,
			ISNULL(serv.Receiver_CUI, '') as CUI,
			ISNULL(serv.Receiver_SocialSecurity_ID, '') as SocialSecurityID
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.StatusOrder sta WITH(NOLOCK) ON sta.StatusOrderId = serv.StatusOrderId
		WHERE 
		CONVERT(DATE, serv.DateCreated) BETWEEN CONVERT(DATE, GETDATE()-90) AND CONVERT( DATE, GETDATE()) AND 
		serv.StatusOrderId NOT IN( 7,15,5,22) AND -- ocultar los servicios anulados		
		(serv.Sender_LastName = @Sender)  OR
		(serv.Sender_FirstName + serv.Sender_LastName = @Sender)  OR
		(serv.Sender_FirstName LIKE ('%' + @Sender + '%'))  OR
		(serv.Sender_LastName  LIKE ('%' + @Sender + '%'))  OR
		(serv.Sender_FirstName + serv.Sender_LastName LIKE ('%' + @Sender + '%'))
END
ELSE IF (@Receiver IS NOT NULL AND LEN(@Receiver) > 0)
BEGIN
	  	SELECT  			 
			serv.Guide_Serie +  CAST(serv.Guide_Number AS VARCHAR) Guide,			
			isnull(serv.Receiver_FirstName,'') + ' '+ isnull(serv.Receiver_LastName,'') 'Name',
			serv.Receiver_Address 'Address',			
			STUFF(( SELECT  '| ' + CONVERT(VARCHAR(200),SMR.SMS_Message)  +' '
			FROM [DeliveryBackOffice].[dbo].[GuidesBySMS] B WITH(NOLOCK)
			inner join DeliveryBackOffice.dbo.SMS_Received SMR WITH(NOLOCK)
			 on B.SmsId = SMR.SMS_ID
			WHERE   
				B.GuideSerie = serv.Guide_Serie
				and B.GuideNumber = serv.Guide_Number

			FOR
			XML PATH('')
		), 1, 1, '') AS Alter_Address,

			serv.Receiver_Zone 'Zone',
			serv.Receiver_Town Town,
			serv.Receiver_Department Department,
			'' DateSettlement,
			serv.Delivery_Max_Date Delivery_Max_Date,
			serv.Courier_Route Courier_Route,
			serv.Courier_Name Courier_Name,
			serv.Dispatched_Date Dispatched_Date,
			serv.Manifest_Serie + CAST(serv.Manifest_Number AS VARCHAR) as Manifest_Number,
			serv.DateCreated as Date_Created,
			isnull(serv.Sender_FirstName,'') + ' ' + isnull(serv.Sender_LastName,'') as Sender_Fullname,
			serv.Ticket_Number as Ticket_Number,
			serv.Pieces_Dry as Pieces_Dry,
			serv.Pieces_Cold as Pieces_Cold,
			(SELECT so.OrderDescription FROM StatusOrder so WITH(NOLOCK) WHERE so.StatusOrderId = serv.StatusOrderId) as Status_Order_Id,
			serv.Receiver_Phone as Receiver_Phone,
			(SELECT p.Package_Name FROM Package p WITH(NOLOCK) WHERE p.Package_Type = serv.Package_Type) as Package_Type,
			(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(serv.Guide_Serie, serv.Guide_Number)) as Rack_Position,
			ISNULL(serv.Contact_Confirmed, 0) as Contact_Confirmed,
			serv.Contact_Instructions,
			ISNULL(serv.Receiver_CUI, '') as CUI,
			ISNULL(serv.Receiver_SocialSecurity_ID, '') as SocialSecurityID
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.StatusOrder sta WITH(NOLOCK) ON sta.StatusOrderId = serv.StatusOrderId
		WHERE 
		CONVERT(DATE, serv.DateCreated) BETWEEN CONVERT(DATE, GETDATE()-90) AND CONVERT( DATE, GETDATE()) AND 
		serv.StatusOrderId NOT IN( 7,15,5,22) AND -- ocultar los servicios anulados		
		(serv.Receiver_FirstName = @Receiver)  OR
		(serv.Receiver_LastName = @Receiver)  OR
		(serv.Receiver_FirstName + serv.Receiver_LastName = @Receiver)  OR
		(serv.Receiver_FirstName LIKE ('%' + @Receiver + '%'))  OR
		(serv.Receiver_LastName  LIKE ('%' + @Receiver + '%'))  OR
		(serv.Receiver_FirstName + serv.Receiver_LastName LIKE ('%' + @Receiver + '%'))
END
ELSE IF (@ReceiverPhone IS NOT NULL AND LEN(@ReceiverPhone) > 0)
BEGIN
	  	SELECT  			 
			serv.Guide_Serie +  CAST(serv.Guide_Number AS VARCHAR) Guide,			
			isnull(serv.Receiver_FirstName,'') + ' '+ isnull(serv.Receiver_LastName,'') 'Name',
			serv.Receiver_Address 'Address',			
			STUFF(( SELECT  '| ' + CONVERT(VARCHAR(200),SMR.SMS_Message)  +' '
			FROM [DeliveryBackOffice].[dbo].[GuidesBySMS] B WITH(NOLOCK)
			inner join DeliveryBackOffice.dbo.SMS_Received SMR WITH(NOLOCK)
			 on B.SmsId = SMR.SMS_ID
			WHERE   
				B.GuideSerie = serv.Guide_Serie
				and B.GuideNumber = serv.Guide_Number

			FOR
			XML PATH('')
		), 1, 1, '') AS Alter_Address,

			serv.Receiver_Zone 'Zone',
			serv.Receiver_Town Town,
			serv.Receiver_Department Department,
			'' DateSettlement,
			serv.Delivery_Max_Date Delivery_Max_Date,
			serv.Courier_Route Courier_Route,
			serv.Courier_Name Courier_Name,
			serv.Dispatched_Date Dispatched_Date,
			serv.Manifest_Serie + CAST(serv.Manifest_Number AS VARCHAR) as Manifest_Number,
			serv.DateCreated as Date_Created,
			isnull(serv.Sender_FirstName,'') + ' ' + isnull(serv.Sender_LastName,'') as Sender_Fullname,
			serv.Ticket_Number as Ticket_Number,
			serv.Pieces_Dry as Pieces_Dry,
			serv.Pieces_Cold as Pieces_Cold,
			(SELECT so.OrderDescription FROM StatusOrder so WITH(NOLOCK) WHERE so.StatusOrderId = serv.StatusOrderId) as Status_Order_Id,
			serv.Receiver_Phone as Receiver_Phone,
			(SELECT p.Package_Name FROM Package p WITH(NOLOCK) WHERE p.Package_Type = serv.Package_Type) as Package_Type,
			(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(serv.Guide_Serie, serv.Guide_Number)) as Rack_Position,
			ISNULL(serv.Contact_Confirmed, 0) as Contact_Confirmed,
			serv.Contact_Instructions,
			ISNULL(serv.Receiver_CUI, '') as CUI,
			ISNULL(serv.Receiver_SocialSecurity_ID, '') as SocialSecurityID
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.StatusOrder sta WITH(NOLOCK) ON sta.StatusOrderId = serv.StatusOrderId
		WHERE 
		CONVERT(DATE, serv.DateCreated) BETWEEN CONVERT(DATE, GETDATE()-90) AND CONVERT( DATE, GETDATE()) AND 
		serv.StatusOrderId NOT IN( 7,15,5,22) AND -- ocultar los servicios anulados		
		(serv.Receiver_Phone = @ReceiverPhone)  OR
		(serv.Receiver_Phone LIKE ('%' + @ReceiverPhone + '%')) 
END	
ELSE
BEGIN
		SELECT  			 
			serv.Guide_Serie +  CAST(serv.Guide_Number AS VARCHAR) Guide,			
			isnull(serv.Receiver_FirstName,'') + ' '+ isnull(serv.Receiver_LastName,'') 'Name',
			serv.Receiver_Address 'Address',			
			STUFF(( SELECT  '| ' + CONVERT(VARCHAR(200),SMR.SMS_Message)  +' '
			FROM [DeliveryBackOffice].[dbo].[GuidesBySMS] B WITH(NOLOCK)
			inner join DeliveryBackOffice.dbo.SMS_Received SMR WITH(NOLOCK)
			 on B.SmsId = SMR.SMS_ID
			WHERE   
				B.GuideSerie = serv.Guide_Serie
				and B.GuideNumber = serv.Guide_Number

			FOR
			XML PATH('')
		), 1, 1, '') AS Alter_Address,

			serv.Receiver_Zone 'Zone',
			serv.Receiver_Town Town,
			serv.Receiver_Department Department,
			'' DateSettlement,
			serv.Delivery_Max_Date Delivery_Max_Date,
			serv.Courier_Route Courier_Route,
			serv.Courier_Name Courier_Name,
			serv.Dispatched_Date Dispatched_Date,
			serv.Manifest_Serie + CAST(serv.Manifest_Number AS VARCHAR) as Manifest_Number,
			serv.DateCreated as Date_Created,
			isnull(serv.Sender_FirstName,'') + ' ' + isnull(serv.Sender_LastName,'') as Sender_Fullname,
			serv.Ticket_Number as Ticket_Number,
			serv.Pieces_Dry as Pieces_Dry,
			serv.Pieces_Cold as Pieces_Cold,
			(SELECT so.OrderDescription FROM StatusOrder so WITH(NOLOCK) WHERE so.StatusOrderId = serv.StatusOrderId) as Status_Order_Id,
			serv.Receiver_Phone as Receiver_Phone,
			(SELECT p.Package_Name FROM Package p WITH(NOLOCK) WHERE p.Package_Type = serv.Package_Type) as Package_Type,
			(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(serv.Guide_Serie, serv.Guide_Number)) as Rack_Position,
			ISNULL(serv.Contact_Confirmed, 0) as Contact_Confirmed,
			serv.Contact_Instructions,
			ISNULL(serv.Receiver_CUI, '') as CUI,
			ISNULL(serv.Receiver_SocialSecurity_ID, '') as SocialSecurityID
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.StatusOrder sta WITH(NOLOCK) ON sta.StatusOrderId = serv.StatusOrderId
		WHERE 
		CONVERT(DATE, serv.DateCreated) BETWEEN CONVERT(DATE, GETDATE()-90) AND CONVERT( DATE, GETDATE()) AND 
		serv.StatusOrderId NOT IN( 7,15,5,22) AND -- ocultar los servicios anulados		
		(CONVERT(VARCHAR(100),serv.Guide_Number) = @Guide)  OR
		(serv.Guide_Serie + CONVERT(VARCHAR(100),serv.Guide_Number) = @Guide) 	
END
	
END
