USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sps_edit_guide]    Script Date: 14/10/2020 14:03:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-10-14>
-- Description:	<Actualizar información de incidencia de contacto para el área de SAC>
-- =============================================
CREATE PROCEDURE [dbo].[sps_contact_incident]
		@GuideSerie AS VARCHAR(2),
		@GuideNumber AS INT,
		@IDContactIncident TINYINT,
		@Token NVARCHAR(50)
AS
BEGIN
	DECLARE @RModified INT

	BEGIN TRANSACTION

		BEGIN TRY
			BEGIN
				
				-- Actualizar datos
				UPDATE DeliveryBackOffice.dbo.DeliveryOrder
				SET ID_ContactIncident = @IDContactIncident,
					Contact_Confirmed = 0,
					User_Contact = @Token,
					Date_Contact = GETDATE()
				WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
							
				SET @RModified = @@ROWCOUNT

			END				
		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@RModified > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide'
END
GO


