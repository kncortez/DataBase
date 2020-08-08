USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sps_set_delivery_attempt]    Script Date: 2/08/2020 08:51:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-07-22>
-- Description:	<Cambiar la ubicación en rack de una guía>
-- =============================================
ALTER PROCEDURE [dbo].[sps_set_delivery_attempt]
		@GuideSerie NVARCHAR(2),
		@GuideNumber INT,
		@Dry BIT,
		@Cold BIT,
		@Latitude NVARCHAR(20),
		@Longitude NVARCHAR(20),
		@Delivered BIT,
		@IDCourier INT,
		@UserCreated NVARCHAR(50)
AS
BEGIN
	DECLARE @RInserted INT

	BEGIN TRANSACTION

		BEGIN TRY

			-- registrar nuevo intento de entrega
			INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryAttempt] 
			([Guide_Serie],[Guide_Number],[Dry],[Cold],[Latitude],[Longitude],[Delivered],[ID_Courier],[ID_DeliveryOrderBySettlement],[User_Created],[Date_Created]) 
			VALUES (@GuideSerie,@GuideNumber,@Dry,@Cold,@Latitude,@Longitude,@Delivered,@IDCourier,NULL,@UserCreated,GETDATE())

			SET @RInserted = @@ROWCOUNT

		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@RInserted > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide'
END
GO


