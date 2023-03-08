



-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-11-22>
-- Description:	<Registrar transacción de liquidación para material devuelto>
-- =============================================
CREATE PROCEDURE [dbo].[sps_settlement_guide_returned]
		@GuideSerie AS VARCHAR(2),
		@GuideNumber AS INT,
		@Token NVARCHAR(50),
		@IdManifest INT
AS
BEGIN
	DECLARE @RModified INT
	DECLARE @Amount DECIMAL (14,2)
	DECLARE @IsMarkedReturn BIT = 0

	BEGIN TRANSACTION

		BEGIN TRY
			
			SET @Amount = (SELECT Collect_OnDelivery FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK) WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber)

			-- actualizar guía debido al proceso de liquidación
			UPDATE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]
			SET 
				Settlement_Collect_OnDelivery = @Amount, 
				SettlementCollect_TokenCreated = @Token, 
				SettlementCollect_DateCreated = GETDATE(), 
				Guide_Settlement = 1, -- guía liquidada en bodega
				Guide_Returned = 1,  -- guía liquidada vía material devuelto
				Guide_Delivered = 0  -- guía liquidada vía comprobante de entrega
			WHERE 
				Guide_Serie = @GuideSerie 
				AND Guide_Number = @GuideNumber 
				AND ID_DeliveryOrderBySettlement = @IdManifest

			SET @RModified = @@ROWCOUNT

			-- registrar checkpoint histórico de devolución
			INSERT INTO [dbo].[DeliveryOrderDetail]
			   ([Guide_Serie]
			   ,[Guide_Number]
			   ,[StatusOrderId]
			   ,[UserCreated]
			   ,[DateCreated]
			   ,[DateCreatedInSystem]
			   ,[Observations]
			   ,[Temperature_Celsius])
			 VALUES
				   (@GuideSerie
				   ,@GuideNumber
				   ,8 -- retornado a Forza
				   ,@Token
				   ,GETDATE()
				   ,GETDATE()
				   ,NULL
				   ,NULL)

			-- registrar último checkpoint de devolución
			UPDATE DeliveryBackOffice.dbo.DeliveryOrder SET StatusOrderId = 8 WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
			

			--FDAPI-1374 <Oscar Morales 2023-02-16> 
			-- invalidar token de incidencias
			UPDATE coi
			SET coi.ConfirmationOfIncidentToken += 'TIMEOUT'
			FROM ConfirmationOfIncidence coi
			INNER JOIN DeliveryAttempt da WITH (NOLOCK)
				ON coi.IdConfirmationOfIncidence = da.ConfirmationOfIncidenceId
				AND da.Guide_Serie = @GuideSerie
				AND da.Guide_Number = @GuideNumber
				AND da.ID_DeliveryOrderBySettlement = @IdManifest
			-- FIN FDAPI-1374 <Oscar Morales 2023-02-16>

			--FDD-1071 <Oscar Morales 2023-02-16> 
			--Detectar desacatos courier
			UPDATE coi
			SET CourierContempt = 1
			   ,TokenUpdated = @Token
			   ,DateUpdated = GETDATE()
			FROM ConfirmationOfIncidence coi
			INNER JOIN DeliveryAttempt da WITH (NOLOCK)
				ON coi.IdConfirmationOfIncidence = da.ConfirmationOfIncidenceId
				AND da.Guide_Serie = @GuideSerie
				AND da.Guide_Number = @GuideNumber
				AND da.ID_DeliveryOrderBySettlement = @IdManifest
			WHERE coi.IsActionIssued = 1
			--FIN FDD-1071 <Oscar Morales 2023-02-16> 

			--FDD-1071 <Oscar Morales 2023-02-22> 
			--Detectar marcado como devolución por cliente
			
			IF EXISTS (SELECT
					1
				FROM ConfirmationOfIncidence coi
				INNER JOIN DeliveryAttempt da WITH (NOLOCK)
					ON coi.IdConfirmationOfIncidence = da.ConfirmationOfIncidenceId
					AND da.Guide_Serie = @GuideSerie
					AND da.Guide_Number = @GuideNumber
					AND da.ID_DeliveryOrderBySettlement = @IdManifest
				WHERE coi.ClientConfirmsReturn = 1)
			BEGIN
				DECLARE @StatusReturn TINYINT = (SELECT StatusOrderId FROM StatusOrder WHERE OrderDescription = 'Declarado para Devolución' AND RowStatus = 1)
				SET @IsMarkedReturn = 1

				-- registrar checkpoint histórico de devolución
				INSERT INTO [dbo].[DeliveryOrderDetail] ([Guide_Serie]
				, [Guide_Number]
				, [StatusOrderId]
				, [UserCreated]
				, [DateCreated]
				, [DateCreatedInSystem]
				, [Observations]
				, [Temperature_Celsius])
					VALUES (@GuideSerie, @GuideNumber, @StatusReturn, @Token, GETDATE(), GETDATE(), NULL, NULL)

				-- registrar último checkpoint de devolución
				UPDATE DeliveryOrder
				SET StatusOrderId = @StatusReturn
				WHERE Guide_Serie = @GuideSerie
				AND Guide_Number = @GuideNumber
			
			END
			--FDD-1071 <Oscar Morales 2023-02-22> 
		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
				@Amount AS 'Amount',
				0 AS 'SubStatusCode'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@RModified > 0)
				SELECT
					1 AS 'StatusCode'
				   ,'Registro guardado correctamente' AS 'Description'
				   ,@@TRANCOUNT AS 'NumTransferID'
				   ,@GuideSerie + CONVERT(NVARCHAR, @GuideNumber) AS 'Guide'
				   ,@Amount AS 'Amount'
				   ,0 AS 'SubStatusCode'
				   ,CASE
						WHEN DOR.IsLastMileReturn = 1 THEN ISNULL(doad.GuideReturnAttemptCount, 1)
						ELSE ISNULL(doad.GuideDeliveryAttemptCount, 1)
					END AS RetriesMade--Numero intentos de entrega fallidas
				   ,CASE
						WHEN DOR.IsLastMileReturn = 1 THEN ISNULL(doad.GuideReturnMaxAttemptCount, 2)
						ELSE ISNULL(doad.GuideDeliveryMaxAttemptCount, 2)
					END AS RetriesAllowed ---Numero de intentos permitidos
				   ,'' 'Retries'
				   ,CASE
						WHEN DOR.IsLastMileReturn = 1 THEN 1
						ELSE 0
					END ValidateAbandonedPackage
				   ,CASE
						WHEN @IsMarkedReturn = 1 THEN 1
						ELSE 0
					END IsMarkedReturn
				FROM DeliveryOrder DOR WITH (NOLOCK)
				INNER JOIN DeliveryOrderAttemptData doad WITH (NOLOCK)
					ON doad.GuideSerie = DOR.Guide_Serie
						AND doad.GuideNumber = DOR.Guide_Number
						AND doad.RowStatus = 1
				WHERE DOR.Guide_Serie = @GuideSerie
				AND DOR.Guide_Number = @GuideNumber

			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
					@Amount AS 'Amount',
					0 AS 'SubStatusCode',
					0 AS RetriesMade,
					0 AS RetriesAllowed,
					'' AS 'Retries',
					0 AS ValidateAbandonedPackage,
					0 AS IsMarkedReturn

				

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
				@Amount AS 'Amount',
				0 AS 'SubStatusCode',
				0 AS RetriesMade,
				0 AS RetriesAllowed,
				'' AS 'Retries',
					0 AS ValidateAbandonedPackage,
					0 AS IsMarkedReturn
END
