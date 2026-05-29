


-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-07-20>
-- Description:	<Devuelve información para monitoreo de ruta>
-- =============================================reo de ruta>
-- =============================================
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2025-05-17>
-- Description: <Devuelve información para monitoreo de ruta>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_RouteMonitor]
		@Token AS VARCHAR(50)    = 'ad1a2328ed27ea99622f68deae5d9976',
		@Rol AS INT 			 =  1,
		@Zone AS VARCHAR(100) = '',
		@Department AS VARCHAR(100) = '',
		@Town AS VARCHAR(100) ='',
		@Manifest AS VARCHAR(50) = '',
		@DateSettlement AS VARCHAR(50) = '',
        @IdCountry AS VARCHAR(2) = 'GT'
AS

BEGIN

		SELECT  			 
			serv.Guide_Serie +  CAST(serv.Guide_Number AS VARCHAR) Guide,
			isnull(serv.Receiver_FirstName,'') + ' '+ isnull(serv.Receiver_LastName,'') 'Name',
			serv.Receiver_Address 'Address',
			serv.Receiver_Zone 'Zone',
			serv.Receiver_Town Town,
			serv.Receiver_Department Department,
			serv.Delivery_Max_Date Delivery_Max_Date,
			serv.Courier_Route Courier_Route,
			(SELECT DeliveryBackOffice.dbo.fn_get_courier(serv.Guide_Serie, serv.Guide_Number)) Courier_Name,
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
			(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(serv.Guide_Serie, serv.Guide_Number)) as Rack_Position
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		WHERE 
		CONVERT(DATE, serv.DateCreated) BETWEEN CONVERT(DATE, GETDATE()-30) AND CONVERT( DATE, GETDATE()) AND 
		serv.Manifest_Number <> 999 AND -- ocultar primer servicio (semilla)
		serv.StatusOrderId IN (3,4) AND -- mostrar solo servicios Solicitados, Retornados a Forza y En Inventario
		(@Zone = '' OR Receiver_Zone = @Zone)  AND
		(@Department = '' OR Receiver_Department = @Department ) AND
		(@Town = '' OR Receiver_Town = @Town) AND
		(
		 @Manifest = '' OR 
		  (
		  Manifest_Serie +  CAST(Manifest_Number AS VARCHAR) = @Manifest		   
		  )
		 )  
        AND ReceiverCountryId = @IdCountry
	
	


	

END