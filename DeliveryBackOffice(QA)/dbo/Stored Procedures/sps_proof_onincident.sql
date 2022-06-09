

-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-09-08>
-- Description:	<Registrar incidente de entrega en sitio>
-- =============================================
CREATE PROCEDURE [dbo].[sps_proof_onincident]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@PhoneNumber NVARCHAR(50),
	@IdIssue INT,
	@PhotoIncidentB64 VARCHAR(MAX),
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
	DECLARE @PhotoIncidentVB VARBINARY(MAX)

	BEGIN TRANSACTION

		BEGIN TRY

			-- convertir base64 a varbinary
			SET @PhotoIncidentVB = (CAST(N'' AS xml).value('xs:base64Binary(sql:variable("@PhotoIncidentB64"))', 'varbinary(max)'))

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

			-- insertar foto y guardar ID para actualizar tabla de entregas
			INSERT INTO DeliveryBackOffice.dbo.DeliveryProof (Guide_Serie, Guide_Number, Date_Photo, Proof_Incident) VALUES (@GuideSerie, @GuideNumber, GETDATE(), @PhotoIncidentVB)
			SET @ID_Photo = SCOPE_IDENTITY()

			IF (@ID_Photo > 0)
			BEGIN
				-- actualizar tabla de entregas
				UPDATE DeliveryBackOffice.dbo.DeliveryAttempt SET ID_Incident = @IdIssue, ID_Proof = @ID_Photo, Latitude = @Latitude, Longitude = @Longitude, Accuracy = @Accuracy WHERE ID IN (SELECT ID FROM @Table)
			
				-- actualizar tabla de registro de guías electrónicas
				UPDATE DeliveryBackOffice.dbo.DeliveryOrder SET StatusOrderId = 12 WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber

				--- Actualizar el estado de las piezas
				UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrderPiece]
				SET
					StatusOrderId = 12
				WHERE GuideSerie = @GuideSerie AND GuideNumber =  @GuideNumber
			
				-- registrar estado en tabla de checkpoints
				INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail (Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, Observations, Temperature_Celsius)
				VALUES (@GuideSerie, @GuideNumber, 12, 'sps_proof_onincident',GETDATE(), GETDATE(), NULL, NULL)
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
