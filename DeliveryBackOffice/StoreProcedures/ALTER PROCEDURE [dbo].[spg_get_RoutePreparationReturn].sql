USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_get_RoutePreparation]    Script Date: 12/04/2021 12:35:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-04-12>
-- Description:	<Devuelve información para preparación de ruta>
-- =============================================
ALTER PROCEDURE [dbo].[spg_get_RoutePreparationReturn]
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
--exec [dbo].[spg_get_RoutePreparation] @Manifest = 'FM1003'
BEGIN


		SELECT  			 
			serv.Guide_Serie +  CAST(serv.Guide_Number AS VARCHAR) Guide,
			--(CASE 
			--	WHEN mat.MSM_ValueRegistrationForm IS NULL 
			--		THEN 0
			--		ELSE 1 
			--END) HandHeld,
			isnull(serv.Sender_FirstName,'') + ' '+ isnull(serv.Sender_LastName,'') 'Name',
			serv.Sender_Address 'Address',
			serv.Sender_Zone 'Zone',
			serv.Sender_Town Town,
			serv.Sender_Department Department,
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
			--(CASE serv.printedStatus WHEN 0 THEN 'Pendiente' WHEN 1 THEN 'Impreso' WHEN 2 THEN 'Reimpreso' END) as Printed_Status,
			(SELECT so.OrderDescription FROM StatusOrder so WHERE so.StatusOrderId = serv.StatusOrderId) as Status_Order_Id,
			serv.Receiver_Phone as Receiver_Phone,
			(SELECT p.Package_Name FROM Package p WHERE p.Package_Type = serv.Package_Type) as Package_Type,
			--serv.Rack_Position as Rack_Position
			(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(serv.Guide_Serie, serv.Guide_Number)) as Rack_Position,
			ISNULL(serv.Contact_Confirmed, 0) as Contact_Confirmed,
			serv.Contact_Instructions
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		--LEFT JOIN DenariusCorporate_Dev.dbo.LGT_Master_Service_Material mat WITH(NOLOCK) on mat.MSM_ValueRegistrationForm = @Manifest and mat.MSM_MaterialCode = Guide_Serie +  CAST(Guide_Number AS VARCHAR)
		JOIN DeliveryBackOffice.dbo.StatusOrder sta ON sta.StatusOrderId = serv.StatusOrderId
		--LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement BySt WITH(nolock) ON serv.Guide_Serie = bySt.Guide_Serie and serv.Guide_Number = bySt.Guide_Number
		WHERE 
		serv.StatusOrderId <> 7 AND -- ocultar los servicios anulados
		serv.StatusOrderId <> 15 AND -- ocultar guías generadas
		serv.StatusOrderId <> 5 AND -- ocultar los servicios entregados
		serv.Manifest_Number <> 999 AND -- ocultar primer servicio (semilla)
		------------------------------------------------------------------------------Verificar filtros -------------------------------------------------------------------
		--( -- ocultar las guías que tengan en su historia retornado al origen
		--	@HideOrigin = 0
		--	OR
		--	serv.Guide_Number NOT IN (
		--		SELECT distinct [Guide_Number] FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] where StatusOrderId = 6
		--	)
		--) AND
		--( -- ocultar las guías que tengan en su historia retornado a Forza
		--	@HideForza = 0
		--	OR
		--	serv.Guide_Number NOT IN (
		--		SELECT distinct [Guide_Number] FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] where StatusOrderId = 8
		--	)
		--) AND
		--------------------------------------------------------------------------------Fin Filtros posibles ----------------------------------------------
		--serv.StatusOrderId IN (1,8,10) AND -- mostrar solo servicios Solicitados, Retornados a Forza y En Inventario
		--serv.Manifest_Number <> 1000 AND -- ocultar servicios en blanco de sosep
		(@Zone = '' OR Receiver_Zone = @Zone)  AND
		(@Department = '' OR Receiver_Department = @Department ) AND
		(@Town = '' OR Receiver_Town = @Town) AND
		
		--(@Department = '' OR Receiver_Department LIKE '%' + @Department + '%') AND
		--(@Town = '' OR Receiver_Town LIKE '%' + @Town + '%' ) AND
		(
		 @Manifest = '' OR 
		  (
		  Manifest_Serie +  CAST(Manifest_Number AS VARCHAR) = @Manifest		   
		  )
		 )  
		
		--(@DateSettlement = NULL OR Receiver_Zone = @DateSettlement) AND PENDIENTE
	
	


	

END
