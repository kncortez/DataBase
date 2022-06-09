



-- =============================================
-- Author:		<Bidcar, Herrera>
-- Create date: <2020-05-27>
-- Description:	<Devuelve información para preparación de ruta>
-- Updated By:  <Alfredo, Monroy>
-- Updated At:  <2021-09-16>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_RoutePreparation_AM]
		@Token AS VARCHAR(50)    = 'ad1a2328ed27ea99622f68deae5d9976',
		@Rol AS BIGINT 			 =  1,
		@Zone AS VARCHAR(100) = '',
		@Department AS VARCHAR(100) = '',
		@Town AS VARCHAR(100) ='',
		@Manifest AS VARCHAR(50) = '',
		@DateSettlement AS VARCHAR(50) = '',
		@HideOrigin BIT = 0, -- status 6
		@HideForza BIT = 0 -- status 8
AS
--
--exec [dbo].[spg_get_RoutePreparation_AM] @Manifest = 'FM1003'
BEGIN


		SELECT
			serv.Guide_Serie +  CAST(serv.Guide_Number AS VARCHAR) Guide,
			isnull(serv.Receiver_FirstName,'') + ' '+ isnull(serv.Receiver_LastName,'') 'Name',
			serv.Receiver_Address 'Address',			
			STUFF((
				SELECT  '| ' + CONVERT(VARCHAR(200),SMR.SMS_Message)  +' '
				FROM [DeliveryBackOffice].[dbo].[GuidesBySMS] B
				join DeliveryBackOffice.dbo.SMS_Received SMR
					on B.SmsId = SMR.SMS_ID
				WHERE   
					B.GuideSerie = serv.Guide_Serie
					and B.GuideNumber = serv.Guide_Number
			FOR XML PATH('')), 1, 1, '') AS Alter_Address,

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
			--(SELECT so.OrderDescription FROM StatusOrder so WHERE so.StatusOrderId = serv.StatusOrderId) as Status_Order_Id,
			sta.OrderDescription Status_Order_Id,
			serv.Receiver_Phone as Receiver_Phone,
			--(SELECT p.Package_Name FROM Package p WHERE p.Package_Type = serv.Package_Type) as Package_Type,
			p.Package_Name as Package_Type,
			(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(serv.Guide_Serie, serv.Guide_Number)) as Rack_Position,
			ISNULL(serv.Contact_Confirmed, 0) as Contact_Confirmed,
			serv.Contact_Instructions,
			ISNULL(serv.Receiver_CUI, '') as CUI,
			ISNULL(serv.Receiver_SocialSecurity_ID, '') as SocialSecurityID
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv  WITH(INDEX(IDX_StatusandCollect))
			JOIN DeliveryBackOffice.dbo.StatusOrder sta ON sta.StatusOrderId = serv.StatusOrderId
			LEFT JOIN DeliveryBackOffice.dbo.Package p ON p.Package_Type = serv.Package_Type
		WHERE 
		serv.StatusOrderId <> 7 AND -- ocultar los servicios anulados
		serv.StatusOrderId <> 15 AND -- ocultar guías generadas
		serv.StatusOrderId <> 5 AND -- ocultar los servicios entregados
		isnull(serv.Collect_OnDelivery, 0) > -1 AND
		serv.DateCreated >= DATEADD(MONTH, -1, GETDATE()) AND

		-- serv.Manifest_Number <> 999 AND -- ocultar primer servicio (semilla)
		( -- ocultar las guías que tengan en su historia retornado al origen
			@HideOrigin = 0
			OR
			((SELECT COUNT(*) FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] AS d1 WITH(INDEX([ClusteredIndex-GuideSerie-Number-Status])) where d1.Guide_Serie = serv.Guide_Serie and d1.Guide_Number = serv.Guide_Number and d1.StatusOrderId = 6) = 0)
		) AND
		( -- ocultar las guías que tengan en su historia retornado a Forza
			@HideForza = 0
			OR
			((SELECT COUNT(*) FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] AS d2 WITH(INDEX([ClusteredIndex-GuideSerie-Number-Status])) where d2.Guide_Serie = serv.Guide_Serie and d2.Guide_Number = serv.Guide_Number and d2.StatusOrderId = 8) = 0)
		) AND
		(@Zone = '' OR serv.Receiver_Zone = @Zone)  AND
		(@Department = '' OR serv.Receiver_Department = @Department) AND
		(@Town = '' OR serv.Receiver_Town = @Town) AND		
		(@Manifest = '' OR (serv.Manifest_Serie +  CAST(serv.Manifest_Number AS VARCHAR) = @Manifest))
		
	
	


	

END
