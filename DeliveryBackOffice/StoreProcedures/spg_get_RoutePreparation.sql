USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_get_RoutePreparation]    Script Date: 3/06/2020 16:58:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Bidcar, Herrera>
-- Create date: <2020-05-27>
-- Description:	<Devuelve información para preparación de ruta>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_RoutePreparation]
		@Token AS VARCHAR(50)    = 'ad1a2328ed27ea99622f68deae5d9976',
		@Rol AS BIGINT 			 =  1,
		@Zone AS VARCHAR(100) = '',
		@Department AS VARCHAR(100) = '',
		@Town AS VARCHAR(100) ='',
		@Manifest AS VARCHAR(50) = '',
		@DateSettlement AS VARCHAR(50) = ''
AS
--
--exec [dbo].[spg_get_RoutePreparation] @Manifest = 'FM1003'
BEGIN


		SELECT  			 
			serv.Guide_Serie +  CAST(serv.Guide_Number AS VARCHAR) Guide,
			CASE 
			WHEN mat.MSM_ValueRegistrationForm IS NULL THEN 0
			else 1 end HandHeld,
			--0 HandHeld, 			
			serv.Receiver_FirstName + ' '+ serv.Receiver_LastName Name,
			serv.Receiver_Address Address,
			serv.Receiver_Zone Zone,
			serv.Receiver_Town Town,
			serv.Receiver_Department Department,
			BySt.Received_Date DateSettlement,
			serv.Delivery_Max_Date Delivery_Max_Date,
			serv.Courier_Route Courier_Route,
			serv.Courier_Name Courier_Name,
			serv.Dispatched_Date Dispatched_Date  
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		LEFT JOIN DenariusCorporate_Dev.dbo.LGT_Master_Service_Material mat WITH(NOLOCK)
		on mat.MSM_ValueRegistrationForm = @Manifest
		and mat.MSM_MaterialCode = Guide_Serie +  CAST(Guide_Number AS VARCHAR)
		JOIN DeliveryBackOffice.dbo.StatusOrder sta ON sta.StatusOrderId = serv.StatusOrderId
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderBySettlement BySt WITH(nolock)
		 ON serv.Guide_Serie = bySt.Guide_Serie
		 and serv.Guide_Number = bySt.Guide_Number
		WHERE 
		--serv.StatusOrderId = 2 AND 
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
GO


