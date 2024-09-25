
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2024-10-25>
-- Description:	<Description,Actualizar estado Link de entrega >
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_UpdateDeliveryLink] 
@Token         NVARCHAR(250),
@ReceiverName  NVARCHAR(200),
@ReceiverPhone NVARCHAR(50),
@ReceiverEmail NVARCHAR(100),
@ReceiverZone  NVARCHAR(100),
@ReceiverCatCityPlaceId INT,
@ReceiverNeighborhood   NVARCHAR(50),
@ReceiverAddress        NVARCHAR(600),
@ReceiverAdditionalInstuctions NVARCHAR(250),
@ReceiverLatitude  NVARCHAR(50),
@ReceiverLongitude NVARCHAR(50)

AS
BEGIN

  DECLARE @StatusId INT =(SELECT  IdDeliveryLinkStatus FROM [dbo].[DeliveryLinkStatus] WHERE [Name]='Aperturado' )


  BEGIN TRANSACTION
	BEGIN TRY

	  UPDATE [dbo].[DeliveryLInk]
	     SET DeliveryLinkStatusId = @StatusId,
		     ReceiverName  = @ReceiverName,
		     ReceiverPhone = @ReceiverPhone,
		     ReceiverEmail = @ReceiverEmail,
			 ReceiverCatCityPlaceId = @ReceiverCatCityPlaceId,
		     ReceiverZone = @ReceiverZone,
		     ReceiverNeighborhood = @ReceiverNeighborhood,
		     ReceiverAddress = @ReceiverAddress,
		     ReceiverAdditionalInstuctions = @ReceiverAdditionalInstuctions,
		     ReceiverLatitude  = @ReceiverLatitude,
		     ReceiverLongitude = @ReceiverLongitude
	  WHERE TOKEN = @Token

	COMMIT TRANSACTION;

	SELECT 1 AS [StatusCode], 'Datos Actualizados exitosamente' AS[MessageResponse]
	   
	END TRY
	
		BEGIN CATCH

			ROLLBACK TRANSACTION;

			SELECT 0 AS [StatusCode], 'Actualización de datos fallida' AS[MessageResponse]

		 END CATCH

END
GO
