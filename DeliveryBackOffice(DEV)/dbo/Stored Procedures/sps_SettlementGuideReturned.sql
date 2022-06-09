



-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2020-11-22>
-- Description:	<Registrar transacción de liquidación para material devuelto>
-- =============================================
CREATE PROCEDURE [dbo].[sps_SettlementGuideReturned]
		@GuideSerie AS VARCHAR(2),
		@GuideNumber AS INT,
		@Token NVARCHAR(50),
		@IdManifest INT
AS
BEGIN
	DECLARE @RModified INT
	DECLARE @Amount DECIMAL (14,2)

	BEGIN TRANSACTION

		BEGIN TRY
			
			SET @Amount = (SELECT Collect_OnDelivery FROM DeliveryBackOffice.dbo.DeliveryOrder WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber)

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
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
					@Amount AS 'Amount',
					0 AS 'SubStatusCode'
					, COUNT(*)		AS RetriesMade--Numero intentos de entrega fallidas
					, (case when RH.Attempt is NULL then 2 else RH.Attempt end)		AS RetriesAllowed ---Numero de intentos permitidos
				FROM DeliveryOrder DOR
					LEFT JOIN DBO.DeliveryOrderDetail DORD  ON DOR.Guide_Serie=DORD.Guide_Serie AND DOR.Guide_Number=DORD.Guide_Number
					AND DORD.StatusOrderId= (select StatusOrderId from dbo.StatusOrder where OrderDescription ='Intento de entrega fallida')
					LEFT JOIN DBO.Customer CU ON DOR.IdCustomer=CU.IdCustomer
					LEFT JOIN DBO.RatebyCustomer RC ON CU.IdCustomer=RC.RbcIdCustomer
					LEFT JOIN RateHeader RH ON RC.RbcIdRate=RH.RheId								
				WHERE DOR.Guide_Serie=@GuideSerie AND DOR.Guide_Number=@GuideNumber
				GROUP BY DOR.Guide_Serie,DOR.Guide_Number,CU.IdCustomer,RH.Attempt,DORD.StatusOrderId

			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
					@Amount AS 'Amount',
					0 AS 'SubStatusCode',
					0 AS RetriesMade,
					0 AS RetriesAllowed

				

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
				0 AS RetriesAllowed
END
