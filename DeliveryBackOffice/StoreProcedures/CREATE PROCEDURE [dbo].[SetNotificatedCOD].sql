USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SetNotificatedCOD]    Script Date: 05/07/2021 09:10:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-07-05>
-- Description:	<Informe depósitos COD>
-- =============================================

CREATE PROCEDURE [dbo].[SetNotificatedCOD]
-- Add the parameters for the stored procedure here
	@CustomerId INT
AS
BEGIN
	-- control de registros actualizados
	DECLARE @RModified INT

	BEGIN TRANSACTION

		BEGIN TRY

			UPDATE pg
			SET pg.[Notificated] = 1
			FROM [dbo].[ProcessedGuideCOD] pg
			INNER JOIN [dbo].[DeliveryOrder] do
				ON do.[Guide_Serie] = pg.[GuideSerie] 
				AND do.[Guide_Number] = pg.[GuideNumber]
			WHERE do.[IdCustomer] = @CustomerId
				AND pg.[Notificated] = 0

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
				'Registros actualizados correctamente' AS 'Description', 
				@@TRANCOUNT AS 'NumTransferID'
		ELSE
			SELECT			  
				0 AS 'StatusCode',
				'No se actualizó ningún registro' AS 'Description', 
				0 AS 'NumTransferID'

		COMMIT TRANSACTION;			
	END
	ELSE
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
END
GO