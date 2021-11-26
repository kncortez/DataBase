USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SetMoneyByDeliveryOrderBySettlement]    Script Date: 27/11/2021 10:56:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-11-26>
-- Description:	<Guarda información de las denominaciones registradas en liquidación ultima milla COD>
-- =============================================

CREATE PROCEDURE [dbo].[SetMoneyByDeliveryOrderBySettlement]
    -- Add the parameters for the stored procedure here
    @Money TblMoneyByDeliveryOrderBySettlement READONLY,
	@IdDeliveryOrderBySettlement INT
AS
BEGIN
	DECLARE @RModified INT

	BEGIN TRANSACTION

		BEGIN TRY

			INSERT INTO [dbo].[MoneyByDeliveryOrderBySettlement]
			SELECT IdCatMoney, @IdDeliveryOrderBySettlement, Quantity
			FROM @Money
			WHERE Quantity IS NOT NULL AND Quantity > 0

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
