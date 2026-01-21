/* =================================================
   SP:        [dbo].[SetGuidesToPayBatchCOD]
   Propósito: Set datos lote COD
   Autor:     Oscar Morales
   Historia:  <>
   Fecha:     <2021-06-23>
   === CHANGELOG ============================
2025-12-30 | Historia/épica: <FDAPI-4760> | Autor: Tito Garcia |
2525-03-17 | Historia/épica: <Se agrego optimizacion en base a indicaciones del DBA para la optimizacion del proceso de generacion de lotes COD> | Autor: Oscar Rodriguez |
2024-12-12 | Historia/épica: <Se agrego actualizacion de estado PAGADO para guias COD Anticipado> | Autor: Oscar Rodriguez |
2024-12-19 | Historia/épica: <Se agregaron validaciones para COD Pagado en COD Anticipado> | Autor: Oscar Rodriguez  |
=========================================== */
CREATE PROCEDURE [dbo].[SetGuidesToPayBatchCOD]
	@BatchCODId INT,
	@TotalAmount DECIMAL(18,2),
	@AuthorizationNumber NVARCHAR(50),
	@AuthorizationDate DATETIME,
	@TokenCreated NVARCHAR(50),
	@Valid INT,
	@StationId INT = NULL
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @ValidateOperation INT = 0 -- control transacción
	DECLARE @Times INT = 0-- cantidad de veces que aparece el registro

	IF @StationId <= 0
		SET	@StationId = NULL;

	BEGIN TRANSACTION
	BEGIN TRY
		
		DECLARE @StatusOrderAnticipatedCOD INT = 53; --StatusOrder --> 'COD Pagado Anticipado'
		IF @Valid = 0
			SET @Times = (
				SELECT COUNT(1)
				FROM [dbo].[BatchDetailCOD] WITH(NOLOCK)
				WHERE [AuthorizationNumber] = @AuthorizationNumber
			)

		IF @Times = 0
		BEGIN
			UPDATE [dbo].[BatchCOD] 
			SET [TotalAmountIncluded] = @TotalAmount
			WHERE [IdBatchCOD] = @BatchCODId;

			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation+1

			UPDATE [dbo].[BatchDetailCOD]
			SET [AuthorizationNumber] = @AuthorizationNumber,
				[AuthorizationDate] = @AuthorizationDate,
				[CreditDate] = CONVERT(DATE,@AuthorizationDate)
			WHERE [BatchCODId] = @BatchCODId 
				AND [Excluded] = 0;

			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation+1

			UPDATE dop
			SET dop.[IdStatus] = 0,
				dop.[TokenUpdate] = @TokenCreated,
				dop.[DateUpdate] = GETDATE()
			FROM [dbo].[DeliveryOrderPaid] dop WITH(NOLOCK)
				INNER JOIN DeliveryBackOffice.dbo.BatchDetailCOD bdc WITH(NOLOCK) 
					ON bdc.GuideSerie = dop.Guide_Serie 
						AND bdc.GuideNumber = dop.Guide_Number
			WHERE bdc.BatchCODId = @BatchCODId
				AND bdc.Excluded = 0;

			IF ((SELECT IsAnticipatedCOD FROM DeliveryBackOffice.dbo.BatchCOD WITH(NOLOCK) WHERE IdBatchCOD = @BatchCODId) = 1)
			BEGIN

				-- Inserta el estado "COD Pagado Anticipado" en tabla DeliveryOrderDetail.
				INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
				  (
				  Guide_Serie,
				  Guide_number,
				  StatusOrderId,
				  UserCreated,
				  DateCreated,
				  StationId
				  )
				SELECT GuideSerie,GuideNumber,@StatusOrderAnticipatedCOD, @TokenCreated,GETDATE(),@StationId 
				FROM [dbo].[BatchDetailCOD] WITH(NOLOCK)
				WHERE [BatchCODId] = @BatchCODId 
					AND Excluded=0 
					AND CatConceptCODId =2;

				UPDATE ACD
				SET ACD.BalanceStatus = 'PAGADO',
					DateUpdated = GETDATE(),
					TokenUpdated = @TokenCreated
				FROM DeliveryBackOffice.dbo.AnticipatedCODDetail ACD WITH(NOLOCK)
					INNER JOIN [dbo].[BatchDetailCOD] BDC WITH(NOLOCK)
				    	ON BDC.GuideSerie = ACD.GuideSerie 
							AND BDC.GuideNumber = ACD.GuideNumber
				WHERE BDC.[BatchCODId] = @BatchCODId
						
                DECLARE @TempData TblAnticipatedCODCustomerBalance;

				INSERT INTO @TempData
				(
					CustomerId,
					PortfolioId
				)
				SELECT DISTINCT ach.CustomerId, ach.PortfolioId
				FROM DeliveryBackOffice.dbo.AnticipatedCODDetail acd WITH(NOLOCK)
					INNER JOIN [dbo].[BatchDetailCOD] BDC WITH(NOLOCK) 
						ON BDC.GuideSerie = ACD.GuideSerie 
							AND BDC.GuideNumber = ACD.GuideNumber
					INNER JOIN DeliveryBackOffice.dbo.AnticipatedCODHeader ach WITH(NOLOCK) 
						ON ach.IdAnticipatedCODHeader = acd.AnticipatedCODHeaderId
				WHERE BDC.[BatchCODId] = @BatchCODId

				EXEC spUpdateBalanceByIdClient @TempData

                DELETE 
                    FROM @TempData
			END
			ELSE
			BEGIN
				-- Cambia el estado de la guia en tabla DeliveryOrder a 25 "COD Pagado".
				UPDATE [dbo].[DeliveryOrder]
				SET StatusOrderId = 25
				WHERE [Guide_Number] IN 
				(SELECT GuideNumber 
					FROM [dbo].[BatchDetailCOD]  WITH(NOLOCK)
					WHERE [BatchCODId] = @BatchCODId 
						AND Excluded=0 
						AND CatConceptCODId =2) --OR, Se comento por proyecto COD Anticipado

				-- Inserta el estado 25 "COD Pagado" en tabla DeliveryOrderDetail.
				INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
				  (
				  Guide_Serie,
				  Guide_number,
				  StatusOrderId,
				  UserCreated,
				  DateCreated,
				  StationId
				  )
				SELECT GuideSerie,GuideNumber,25, @TokenCreated,GETDATE(), @StationId 
				FROM [dbo].[BatchDetailCOD] WITH(NOLOCK)
				WHERE [BatchCODId] = @BatchCODId 
					AND Excluded=0 
					AND CatConceptCODId =2
			END
		
		-----------------WEBHOOK.INI-----------------------		
		DECLARE @WebhookCustomerTable AS TABLE(
			CustomerId INT,
			CustomerEndpointId BIGINT,
			WebhookType INT,
			GuideSerie NVARCHAR(2),
			GuideNumber INT,
			GuideStatusId TINYINT
		)
		BEGIN TRY
			DECLARE @GuideStatusChangeWebhook INT = (SELECT TOP 1 WT.IdWebhookType FROM [DeliveryBackOffice].[dbo].[WebhookType] WT WITH(NOLOCK) WHERE WT.WebhookName = 'GuideStatusChange' AND WT.RowStatus = 1);

			-- Clientes de las guías por procesar
			INSERT INTO 
				@WebhookCustomerTable
				(CustomerId, GuideSerie, GuideNumber, GuideStatusId)
			SELECT
				DISTINCT
					DO.IdCustomer,
					BDCOD.GuideSerie,
					BDCOD.GuideNumber,
					DO.StatusOrderId
			FROM [DeliveryBackOffice].[dbo].[BatchDetailCOD] BDCOD WITH(NOLOCK)
				INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
					ON BDCOD.GuideSerie = DO.Guide_Serie
						AND	BDCOD.GuideNumber = DO.Guide_Number						
			WHERE
				BDCOD.BatchCODId = @BatchCODId 
				AND Excluded = 0 
				AND CatConceptCODId = 2;

			-- Ingresar endpoints de cliente
			UPDATE @WebhookCustomerTable
			SET
				CustomerEndpointId = WE.IdWebhookEndpoint
				,WebhookType = @GuideStatusChangeWebhook
			FROM [DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH(NOLOCK)
				INNER JOIN @WebhookCustomerTable WCT
					ON WE.CustomerId = WCT.CustomerId
			WHERE WE.WebhookTypeId = @GuideStatusChangeWebhook;

			DECLARE @ResponseTable AS TABLE (
				InsertedId BIGINT
			);

			INSERT INTO 
				[DeliveryBackOffice].[dbo].[WebhookTrackingQueue]
				(
					[GuideSerie]
					,[GuideNumber]
					,[CustomerId]
					,[StatusOrderId]
					,[WebhookEndpointId]
					,[HasNotified]
					,[TokenCreated]
					,[DateCreated]
				)
			OUTPUT inserted.IdWebhookTrackingQueue INTO @ResponseTable (InsertedId)
			SELECT
				WCT.GuideSerie
				,WCT.GuideNumber
				,WCT.CustomerId
				,WCT.GuideStatusId
				,WCT.CustomerEndpointId
				,0
				,@TokenCreated
				,GETDATE()
			FROM @WebhookCustomerTable WCT
				LEFT JOIN [DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBU WITH(NOLOCK)
					ON WCT.CustomerId = WRBU.CustomerId
						AND WCT.GuideStatusId = WRBU.StatusOrderId
						AND WCT.WebhookType = WRBU.WebhookTypeId
				LEFT JOIN [DeliveryBackOffice].[dbo].[WebhookTrackingQueue] WTQ WITH(NOLOCK)
					ON WCT.GuideSerie = WTQ.GuideSerie
						AND WCT.GuideNumber = WTQ.GuideNumber
						AND WCT.GuideStatusId = WTQ.StatusOrderId
						AND WTQ.RowStatus = 1
			WHERE WRBU.IdWebhookRestrinctionByUser IS NOT NULL
				AND WTQ.IdWebhookTrackingQueue IS NULL

		END TRY
		BEGIN CATCH

		END CATCH
		-------------------WEBHOOK.FIN------------------------------	

			--------------------------------------------------------------------------------

			INSERT INTO [dbo].[DeliveryOrderPaid]
					([Guide_Serie]
					,[Guide_Number]
					,[Deposit_Number]
					,[IsVirtualDeposit]
					,[IdStatus]
					,[TokenCreated]
					,[DateCreated]
					,[TokenUpdate]
					,[DateUpdate]
					,[IdDeliveryOrderPaidHeader]
					,[DocumentType])
				SELECT bd.[GuideSerie]
					,bd.[GuideNumber]
					,@AuthorizationNumber
					,1
					,1
					,@TokenCreated
					,@AuthorizationDate
					,NULL
					,NULL
					,NULL
					,NULL
				FROM [dbo].[BatchDetailCOD] AS bd WITH(NOLOCK)
				WHERE bd.[BatchCODId] = @BatchCODId 
					AND bd.[Excluded] = 0;

				IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation+1

				UPDATE do
				SET do.[Deposit_Number] = @AuthorizationNumber
				,do.[Guide_Collected] = 1
				FROM [dbo].[DeliveryOrder] AS do WITH(NOLOCK)
					INNER JOIN [dbo].[BatchDetailCOD] AS bd WITH(NOLOCK)
						ON do.[Guide_Serie] = bd.[GuideSerie] 
							AND do.[Guide_Number] = bd.[GuideNumber]
				WHERE bd.[BatchCODId] = @BatchCODId 
					AND bd.[Excluded] = 0;
				
				IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation+1
		END
		ELSE
			SET @ValidateOperation = -1 --Registro ya existe
	END TRY
	BEGIN CATCH
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
		ROLLBACK TRANSACTION
	END CATCH;

	IF @@TRANCOUNT > 0
	BEGIN
		IF(@ValidateOperation = 4)
		BEGIN 
			SELECT			  
				1 AS 'StatusCode',
				'Registros guardados correctamente' AS 'Description', 
				@ValidateOperation AS 'NumTransferID'
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			IF(@ValidateOperation = -1)
			BEGIN
				SELECT 
					0 AS 'StatusCode',
					'El registro ya existe' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'
			END
			ELSE
			BEGIN
				SELECT 
					-1 AS 'StatusCode',
					'Error al actualizar registros' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'
			END
			
			ROLLBACK TRANSACTION
		END
	END


	 SET NOCOUNT OFF
END