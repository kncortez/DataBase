-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-06-23>
-- Description:	<Set datos lote COD>
-- =============================================
CREATE PROCEDURE [dbo].[SetGuidesToPayBatchCOD]
-- Add the parameters for the stored procedure here
	@BatchCODId INT,
	@TotalAmount DECIMAL(18,2),
	@AuthorizationNumber nvarchar(50),
	@AuthorizationDate datetime,
	@TokenCreated nvarchar(50),
	@Valid int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	
	DECLARE @ValidateOperation INT = 0 -- control transacción
	DECLARE @Times INT = 0-- cantidad de veces que aparece el registro

	BEGIN TRANSACTION
	BEGIN TRY
		
		IF @Valid = 0
			SET @Times = (
				SELECT COUNT(1)
				FROM [dbo].[BatchDetailCOD]
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
			WHERE [BatchCODId] = @BatchCODId AND [Excluded] = 0;

			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation+1

			UPDATE [dbo].[DeliveryOrderPaid]
			SET [IdStatus] = 0,
				[TokenUpdate] = @TokenCreated,
				[DateUpdate] = GETDATE()
			WHERE CONCAT([Guide_Serie], [Guide_Number]) IN (SELECT CONCAT(GuideSerie, GuideNumber)
															FROM [dbo].[BatchDetailCOD]
															WHERE [BatchCODId] = @BatchCODId AND [Excluded] = 0);

			-- Cambia el estado de la guia en tabla DeliveryOrder a 25 "COD Pagado".
			UPDATE [dbo].[DeliveryOrder]
			SET StatusOrderId = 25
			WHERE [Guide_Number] IN 
			(SELECT GuideNumber FROM [dbo].[BatchDetailCOD] 
			WHERE [BatchCODId] = @BatchCODId AND Excluded=0 AND CatConceptCODId =2)

			-- Inserta el estado 25 "COD Pagado" en tabla DeliveryOrderDetail.
			INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
              (
              Guide_Serie,
              Guide_number,
              StatusOrderId,
              UserCreated,
              DateCreated
              )
      SELECT GuideSerie,GuideNumber,25, @TokenCreated,GETDATE() FROM [dbo].[BatchDetailCOD] 
	    WHERE [BatchCODId] = @BatchCODId AND Excluded=0 AND CatConceptCODId =2

		
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
			FROM
				[DeliveryBackOffice].[dbo].[BatchDetailCOD] BDCOD WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
					ON
						BDCOD.GuideNumber = DO.Guide_Number
						AND
						BDCOD.GuideSerie = DO.Guide_Serie
			WHERE
				BDCOD.BatchCODId = @BatchCODId 
				AND 
				Excluded = 0 
				AND 
				CatConceptCODId = 2;

			-- Ingresar endpoints de cliente
			UPDATE
				@WebhookCustomerTable
			SET
				CustomerEndpointId = WE.IdWebhookEndpoint
				,WebhookType = @GuideStatusChangeWebhook
			FROM
				[DeliveryBackOffice].[dbo].[WebhookEndpoint] WE WITH(NOLOCK)
				INNER JOIN
					@WebhookCustomerTable WCT
					ON
						WE.CustomerId = WCT.CustomerId
						AND
						WE.WebhookTypeId = @GuideStatusChangeWebhook;

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
			FROM
				@WebhookCustomerTable WCT
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[WebhookRestrinctionByUser] WRBU WITH(NOLOCK)
					ON
						WCT.CustomerId = WRBU.CustomerId
						AND
						WCT.GuideStatusId = WRBU.StatusOrderId
						AND
						WCT.WebhookType = WRBU.WebhookTypeId
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[WebhookTrackingQueue] WTQ WITH(NOLOCK)
					ON
						WCT.GuideSerie = WTQ.GuideSerie
						AND
						WCT.GuideNumber = WTQ.GuideNumber
						AND
						WCT.GuideStatusId = WTQ.StatusOrderId
						AND 
						WTQ.RowStatus = 1
			WHERE
				WRBU.IdWebhookRestrinctionByUser IS NOT NULL
				AND
				WTQ.IdWebhookTrackingQueue IS NULL

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
				FROM [dbo].[BatchDetailCOD] AS bd
				WHERE bd.[BatchCODId] = @BatchCODId AND bd.[Excluded] = 0;

				IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation+1

				UPDATE do
				SET do.[Deposit_Number] = @AuthorizationNumber
				,do.[Guide_Collected] = 1
				FROM [dbo].[DeliveryOrder] AS do
				INNER JOIN [dbo].[BatchDetailCOD] AS bd 
				ON do.[Guide_Serie] = bd.[GuideSerie] 
				AND do.[Guide_Number] = bd.[GuideNumber]
				WHERE bd.[BatchCODId] = @BatchCODId AND bd.[Excluded] = 0;
				
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