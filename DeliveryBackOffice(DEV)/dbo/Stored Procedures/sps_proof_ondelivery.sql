-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-08-08>
-- Description:	<Registrar prueba de entrega en sitio>
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2023-06-19>
-- Description:	<inactivar el token de la confirmación de incidencia>
-- =============================================

CREATE PROCEDURE [dbo].[sps_proof_ondelivery]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@PhoneNumber NVARCHAR(50),
	@ReceiverName NVARCHAR(200),
	@PhotoDryB64 VARCHAR(MAX),
	@PhotoColdB64 VARCHAR(MAX),
	@Latitude NVARCHAR(20),
	@Longitude NVARCHAR(20),
	@Accuracy NVARCHAR(20)
AS
BEGIN
	-- control de inserciones para transacción
	DECLARE @RInserted INT
	-- tabla temporal para actualizar registros encontrados
	DECLARE @Table AS TABLE (ID INT)
	-- control de inserción de imagen en tabla de fotografías
	DECLARE @ID_Photo INT
	-- variables auxiliares para conversión de imagen de base64 a varbinary
	DECLARE @PhotoDryVB VARBINARY(MAX)
	DECLARE @PhotoColdVB VARBINARY(MAX)

	BEGIN TRANSACTION

		BEGIN TRY

			-- convertir base64 a varbinary
			SET @PhotoDryVB = (CAST(N'' AS xml).value('xs:base64Binary(sql:variable("@PhotoDryB64"))', 'varbinary(max)'))
			SET @PhotoColdVB = (CAST(N'' AS xml).value('xs:base64Binary(sql:variable("@PhotoColdB64"))', 'varbinary(max)'))

			-- buscar registros de tabla de entregas
			INSERT INTO @Table
			SELECT
				da.ID
			FROM DeliveryBackOffice.dbo.DeliveryAttempt da
				JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = da.ID_Courier
			WHERE sr.Phone like '%' + @PhoneNumber + '%'
				AND da.Guide_Serie = @GuideSerie
				AND da.Guide_Number = @GuideNumber
				AND CONVERT(VARCHAR, da.Date_Created, 23) = CONVERT(VARCHAR, GETDATE(), 23)


				--Invalidar token de validación de incidencias 
				Update   c
				Set  c.ConfirmationOfIncidentToken += 'TIMEOUT'
				From [dbo].[DeliveryAttempt] a
				Inner Join 
				[dbo].[ConfirmationOfIncidence] c
				On a.ConfirmationOfIncidenceId = c.IdConfirmationOfIncidence
				Where
				a.Guide_Serie = @GuideSerie And 	
				a.Guide_Number = @GuideNumber
				

				


			-- insertar foto y guardar ID para actualizar tabla de entregas
			INSERT INTO DeliveryBackOffice.dbo.DeliveryProof (Guide_Serie, Guide_Number, Date_Photo, Proof_Dry, Proof_Cold) VALUES (@GuideSerie, @GuideNumber, GETDATE(), @PhotoDryVB, @PhotoColdVB)
			SET @ID_Photo = SCOPE_IDENTITY()

			IF (@ID_Photo > 0)
			BEGIN
				-- actualizar tabla de entregas
				UPDATE DeliveryBackOffice.dbo.DeliveryAttempt SET Delivered = 1, ID_Proof = @ID_Photo, Latitude = @Latitude, Longitude = @Longitude, Accuracy = @Accuracy WHERE ID IN (SELECT ID FROM @Table)
			
				-- actualizar tabla de registro de guías electrónicas
				UPDATE DeliveryBackOffice.dbo.DeliveryOrder SET NameOfReceiver = @ReceiverName, StatusOrderId = 5 WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
			
				-- registrar estado en tabla de checkpoints
				INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail (Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, Observations, Temperature_Celsius)
				VALUES (@GuideSerie, @GuideNumber, 5, 'sps_proof_ondelivery',GETDATE(), GETDATE(), NULL, NULL)
				SET @RInserted = @@ROWCOUNT
			END

		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@RInserted > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					CONVERT(BIGINT, @@TRANCOUNT) AS 'NumTransferID',
					@GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					CONVERT(BIGINT,0) AS 'NumTransferID',
					@GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + CAST(@GuideNumber AS VARCHAR) AS 'Guide'
END
