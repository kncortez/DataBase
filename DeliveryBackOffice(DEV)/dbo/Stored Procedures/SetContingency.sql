

-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-11-29>
-- Description:	<Guarda información de las contingencias registradas en liquidación ultima milla COD>
-- =============================================

CREATE PROCEDURE [dbo].[SetContingency]
    -- Add the parameters for the stored procedure here
	@IdDeliveryOrderBySettlement INT,
    @Type VARCHAR(10),
    @Value DECIMAL(10,2),
    @Description NVARCHAR(500),
    @Token NVARCHAR(50)
AS
BEGIN
	DECLARE @RModified INT

	BEGIN TRANSACTION

		BEGIN TRY

			INSERT INTO [dbo].[Contingency]
                        ([DeliveryOrderBySettlementId]
                        ,[Type]
                        ,[Value]
                        ,[Description]
                        ,[TokenCreated]
                        ,[DateCreated])
			VALUES 
                    (@IdDeliveryOrderBySettlement
                    ,@Type
                    ,@Value
                    ,@Description
                    ,@Token
                    ,GETDATE()
                    )

			SET @RModified = @@ROWCOUNT

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
			IF (@RModified > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registros guardados correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registros no guardados' AS 'Description', 
					0 AS 'NumTransferID'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'

END;