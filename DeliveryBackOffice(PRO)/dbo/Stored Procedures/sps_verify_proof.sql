
-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-08-13>
-- Description:	<Actualiza estado para indicar si la evidencia fotográfica es aceptada o refutada>
-- =============================================
CREATE PROCEDURE [dbo].[sps_verify_proof]
		@GuideSerie AS VARCHAR(2),
		@GuideNumber AS INT,
		@Accepted AS BIT,
		@UserVerified AS NVARCHAR(50)
AS
BEGIN
	DECLARE @RModified INT
	DECLARE @Id BIGINT

	BEGIN TRANSACTION

		BEGIN TRY
			
			UPDATE [DeliveryBackOffice].[dbo].[DeliveryAttempt] SET Verified = 1, Accepted = @Accepted, User_Verified = @UserVerified , Date_Verified = GETDATE()
			WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber

			SET @RModified = @@ROWCOUNT
			
		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
				@Id AS 'RowID'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@RModified > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					CONVERT(BIGINT, @@TRANCOUNT) AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
					@Id AS 'RowID'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID',
					@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
					@Id AS 'RowID'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide',
				@Id AS 'RowID'
END
