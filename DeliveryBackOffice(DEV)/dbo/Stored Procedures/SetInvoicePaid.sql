-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-05-17>
-- Description:	<Establece los registros necesarios para una factura pagada>
-- =============================================
CREATE PROCEDURE [dbo].[SetInvoicePaid]
	-- Add the parameters for the stored procedure here
	@invoiceHeaderId BIGINT,
	@CatTypeProductName NVARCHAR(200), --Guía, Servicio
	@CatTypeChargeName NVARCHAR(200), --Envío, Recolección
	@CatModuleName NVARCHAR(200),
	@TypeOfInOutOfMoneyName  VARCHAR(50), -- pago en efectivo, pago con tarjeta...
	@CatInvoiceTypeName NVARCHAR(50),
	@Token VARCHAR(50)
AS
BEGIN
	DECLARE @RModified INT = 0
	DECLARE @ErrorMessage NVARCHAR(100)
	DECLARE @EnvioTypeInvoice INT
	DECLARE @ComisionTypeInvoice INT
	DECLARE @GuideSerie NVARCHAR(2)
	DECLARE @GuideNumber INT

	BEGIN TRANSACTION
	BEGIN TRY
		SELECT 
			@EnvioTypeInvoice = IdCatInvoiceType
		FROM CatInvoiceType 
		WHERE [Name] = 'Envío'

		SELECT 
			@ComisionTypeInvoice = IdCatInvoiceType
		FROM CatInvoiceType 
		WHERE [Name] = 'Comisión COD'

		--Obtener las guías de la factura
		DECLARE @tblGuides AS TABLE(
			GuideSerie NVARCHAR(2) NULL,
			GuideNumber INT NULL
		)

		INSERT INTO @tblGuides
		SELECT DISTINCT dti_fk_orderSerie, dti_fk_orderNumber
		FROM invoiceDetail
		WHERE dti_fk_header = @invoiceHeaderId

		--Si tiene guías
		IF (SELECT COUNT(1) FROM @tblGuides) > 0
		BEGIN 
			--Si es una factura de envío
			IF (SELECT IdCatInvoiceType FROM CatInvoiceType WHERE [Name] = @CatInvoiceTypeName) = @EnvioTypeInvoice
			BEGIN
				DECLARE @CostId INT
				DECLARE @PriceShippment DECIMAL(14,2)
				DECLARE @IsError BIT = 0

				WHILE (SELECT COUNT(1) FROM @tblGuides) > 0
				BEGIN
					SELECT TOP 1
						@GuideSerie = GuideSerie,
						@GuideNumber = GuideNumber
					FROM @tblGuides

					SELECT 
						@PriceShippment = PriceShippment
					FROM DeliveryOrder WITH(NOLOCK)
					WHERE Guide_Serie = @GuideSerie
						AND Guide_Number = @GuideNumber

					SELECT 
						@CostId = IdCost
					FROM  Cost
					WHERE ProductNumber = CONCAT(@GuideSerie, @GuideNumber)
						AND RowStatus = 1

					IF @CostId IS NOT NULL
					BEGIN 
						UPDATE Cost
						SET TotalAmountPaid = @PriceShippment
							,TokenUpdated = @Token
							,DateUpdated = GETDATE()
						WHERE IdCost = @CostId
					END
					ELSE
					BEGIN 

						INSERT INTO [dbo].[Cost]
									([IdProduct]
									,[ProductNumber]
									,[IdTypeCharge]
									,[TotalAmount]
									,[PaymentDate]
									,[IdModule]
									,[RowStatus]
									,[TokenCreated]
									,[DateCreated]
									,[TokenUpdated]
									,[DateUpdated]
									,[TotalAmountPaid]
									,[CODAmount]
									,[ReturnAmount]
									,[ReturnPaid])
								VALUES
									((SELECT IdTypeProduct FROM CatTypeProduct WHERE [Name] = @CatTypeProductName)
									,CONCAT(@GuideSerie, @GuideNumber)
									,(SELECT IdTypeCharge FROM CatTypeCharge WHERE [Name] = @CatTypeChargeName)
									,@PriceShippment
									,GETDATE()
									,(SELECT TOP 1 ModIdModule FROM CatModule WHERE ModPath = @CatModuleName ORDER BY ModDateCreated DESC)
									,1
									,@Token
									,GETDATE()
									,NULL
									,NULL
									,@PriceShippment
									,NULL
									,NULL
									,NULL)

						SET @CostId = SCOPE_IDENTITY()
					END

					DECLARE @CostDetailId INT

					IF @CostId IS NOT NULL
					BEGIN 
						--buscar el detalle
						SELECT 
							@CostDetailId = IdCostDetail
						FROM CostDetail
						WHERE IdCost = @CostId
							AND RowStatus = 1

						IF @CostDetailId IS NOT NULL
						BEGIN
							UPDATE CostDetail
								SET Amount = @PriceShippment
									,IdTypeOfMoney = (SELECT tio_pk_id FROM ctgTypeOfInOutOfMoney WHERE tio_pk_name = @TypeOfInOutOfMoneyName)
									,TokenUpdated = @Token
									,DateUpdated = GETDATE()
							WHERE IdCostDetail = @CostDetailId

							SET @RModified = @RModified + @@ROWCOUNT
						END
						ELSE
						BEGIN
							INSERT INTO [dbo].[CostDetail]
										([IdCost]
										,[IdTypeOfMoney]
										,[Amount]
										,[Voucher]
										,[RowStatus]
										,[TokenCreated]
										,[DateCreated]
										,[TokenUpdated]
										,[DateUpdated]
										,[Responsible])
									VALUES
										(@CostId
										,(SELECT tio_pk_id FROM ctgTypeOfInOutOfMoney WHERE tio_pk_name = @TypeOfInOutOfMoneyName)
										,@PriceShippment
										,NULL
										,1
										,@Token
										,GETDATE()
										,NULL
										,NULL
										,NULL)

							SET @CostDetailId = SCOPE_IDENTITY()
							SET @RModified = @RModified + @@ROWCOUNT
						END

						IF @CostDetailId IS NULL
						BEGIN 
							SET @IsError = 1
						SET @ErrorMessage = 'Error instertando CostDetail.'
						END
						
					END
					ELSE
					BEGIN 
						SET @IsError = 1
						SET @ErrorMessage = 'Error instertando Cost.'
					END

					DELETE FROM @tblGuides
					WHERE GuideSerie =@GuideSerie AND GuideNumber = @GuideNumber
				END

				IF @IsError = 1
				BEGIN
					SET @RModified = 0
				END
			END
			ELSE IF (SELECT IdCatInvoiceType FROM CatInvoiceType WHERE [Name] = @CatInvoiceTypeName) = @ComisionTypeInvoice
			BEGIN
				DECLARE @AmountCommission DECIMAL(8,2) = 0

				--buscar monto de comisión en los lotes
				WHILE (SELECT COUNT(1) FROM @tblGuides) > 0
				BEGIN
					SELECT TOP 1
						@GuideSerie = GuideSerie,
						@GuideNumber = GuideNumber
					FROM @tblGuides

					SELECT 
						@AmountCommission = @AmountCommission + Commission
					FROM BatchDetailCOD
					WHERE GuideSerie = @GuideSerie
						AND GuideNumber = @GuideNumber
						AND CatConceptCODId = (SELECT IdCatConceptCOD FROM CatConceptCOD WHERE Concept = 'COMISION Y ENVIO')
						AND RowStatus = 1

					DELETE FROM @tblGuides
					WHERE GuideSerie =@GuideSerie AND GuideNumber = @GuideNumber
				END
				
				IF @AmountCommission > 0
				BEGIN

					DECLARE @IdPaymentCommissionCOD INT
					SELECT TOP 1
						@IdPaymentCommissionCOD
					FROM PaymentCommissionCOD
					WHERE invoiceHeaderId = @invoiceHeaderId
						AND RowStatus = 1
					ORDER BY DateCreated DESC

					--Si existe el registro
					IF @IdPaymentCommissionCOD IS NOT NULL
					BEGIN
						--deshabilitar registros anteriores del detalle
						UPDATE PaymentCommissionCODDetail
						SET RowStatus = 0
						WHERE PaymentCommissionCODId = @IdPaymentCommissionCOD
					END
					ELSE
					BEGIN

						INSERT INTO [dbo].[PaymentCommissionCOD]
									([invoiceHeaderId]
									,[CatTypeProductId]
									,[TotalAmount]
									,[PaymentDate]
									,[CatModuleId]
									,[TotalAmountPaid]
									,[RowStatus]
									,[TokenCreated]
									,[DateCreated]
									,[TokenUpdated]
									,[DateUpdated])
								VALUES
									(@invoiceHeaderId
									,(SELECT IdTypeProduct FROM CatTypeProduct WHERE [Name] = @CatTypeProductName)
									,@AmountCommission
									,GETDATE()
									,(SELECT TOP 1 ModIdModule FROM CatModule WHERE ModPath = @CatModuleName ORDER BY ModDateCreated DESC)
									,@AmountCommission
									,1
									,@Token
									,GETDATE()
									,NULL
									,NULL)
							SET @IdPaymentCommissionCOD = SCOPE_IDENTITY();

					END

					IF @IdPaymentCommissionCOD IS NOT NULL
					BEGIN
						--inserta detalle
						INSERT INTO [dbo].[PaymentCommissionCODDetail]
										([PaymentCommissionCODId]
										,[ctgTypeOfInOutOfMoneyId]
										,[Amount]
										,[Voucher]
										,[RowStatus]
										,[TokenCreated]
										,[DateCreated]
										,[TokenUpdated]
										,[DateUpdated])
									VALUES
										(@IdPaymentCommissionCOD
										,(SELECT tio_pk_id FROM ctgTypeOfInOutOfMoney WHERE tio_pk_name = @TypeOfInOutOfMoneyName)
										,@AmountCommission
										,NULL
										,1
										,@Token
										,GETDATE()
										,NULL
										,NULL)

						SET @RModified = @@ROWCOUNT
					END
					ELSE
					BEGIN
						SET @ErrorMessage = 'Error instertando PaymentCommissionCOD.'
					END
				END
				ELSE
				BEGIN
					SET @ErrorMessage = 'No se ha cálculado el monto de la comisión en COD.'
				END
			END
		END	
		ELSE
		BEGIN
			SET @ErrorMessage = 'No se encontró la factura o no contiene guías en su detalle.'
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
	END CATCH

	IF(@@trancount > 0)
	BEGIN
		IF (@RModified > 0)
		BEGIN
			COMMIT TRANSACTION;
			SELECT			  
				200 AS 'StatusCode',
				'Registro guardados correctamente' AS 'Description', 
				@@TRANCOUNT AS 'NumTransferID'
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION
			SELECT			  
				0 AS 'StatusCode',
				CONCAT('Registros no guardados.', ' ', @ErrorMessage) AS 'Description', 
				0 AS 'NumTransferID'
		END
	END
	ELSE
	BEGIN
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
	END
END
