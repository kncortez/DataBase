USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SetGuidesToPayBatchCOD]    Script Date: 27/09/2021 10:42:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-06-23>
-- Description:	<Set datos lote COD>
-- =============================================
ALTER PROCEDURE [dbo].[SetGuidesToPayBatchCOD]
-- Add the parameters for the stored procedure here
	@BatchCODId int,
	@TotalAmount decimal(18,2),
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
			WHERE [BatchCODId] = @BatchCODId;

			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation+1

			UPDATE [dbo].[DeliveryOrderPaid]
			SET [IdStatus] = 0,
				[TokenUpdate] = @TokenCreated,
				[DateUpdate] = GETDATE()
			WHERE CONCAT([Guide_Serie], [Guide_Number]) IN (SELECT CONCAT(GuideSerie, GuideNumber)
															FROM [dbo].[BatchDetailCOD]
															WHERE [BatchCODId] = @BatchCODId);
			
			IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation+1

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
				WHERE bd.[BatchCODId] = @BatchCODId;

				IF COALESCE(@@ROWCOUNT,0) > 0
				SET @ValidateOperation = @ValidateOperation+1

				UPDATE do
				SET do.[Deposit_Number] = @AuthorizationNumber
				,do.[Guide_Collected] = 1
				FROM [dbo].[DeliveryOrder] AS do
				INNER JOIN [dbo].[BatchDetailCOD] AS bd 
				ON do.[Guide_Serie] = bd.[GuideSerie] 
				AND do.[Guide_Number] = bd.[GuideNumber]
				WHERE bd.[BatchCODId] = @BatchCODId;
				
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
		IF(@ValidateOperation = 5)
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