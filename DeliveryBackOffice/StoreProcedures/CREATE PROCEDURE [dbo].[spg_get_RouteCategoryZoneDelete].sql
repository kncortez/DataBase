USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_Categories_Vehicle_Route]    Script Date: 24/03/2021 17:51:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-03-23>
-- Description:	<Se guarda la información del detalle y maestro de las rutas >
-- =============================================
--drop PROCEDURE [dbo].[sps_Categories_Vehicle_Route]
CREATE PROCEDURE [dbo].[spg_get_RouteCategoryZoneDelete]
	@Route int = 1,
	@Token varchar (50)= 'TEST'
	

AS
BEGIN
	
				BEGIN TRANSACTION
				BEGIN TRY
			
				update CatRoute set RowStatus = 0, TokenUpdated = @Token, DateUpdated = GETDATE()
				where IdRoute = @Route


				  END TRY
				
				BEGIN CATCH
						
						ROLLBACK TRANSACTION
						 select ERROR_MESSAGE()
						 select '401' as StatusCode 

						END CATCH;
						
						IF @@TRANCOUNT > 0
					BEGIN
						COMMIT TRANSACTION;
						select '200' as StatusCode 
					END
	
	
END
