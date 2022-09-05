
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-09-05>
-- Description:	< Actualizar el estado de despliegue de tutoriales >
-- =============================================
CREATE PROCEDURE [dbo].[SetTutorialStatusOfAccount]
	@AccountId BIGINT,
	@TutorialId INT,
	@Token NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @UpdatedTutorialByAccount AS TABLE(
		IdUpdated BIGINT
	);
	
	BEGIN TRANSACTION
	BEGIN TRY

		UPDATE 
			[DeliveryBackOffice].[dbo].[TutorialByAccount]
		SET
			ToDisplay = 0,
			TokenUpdated = @Token,
			DateUpdated = GETDATE()
		OUTPUT inserted.IdTutorialByAccount INTO @UpdatedTutorialByAccount (IdUpdated)
		WHERE
			AccountId = @AccountId
			AND
			TutorialId = @TutorialId
			AND
			ToDisplay = 1;

		IF ( EXISTS(SELECT TOP 1 1 FROM @UpdatedTutorialByAccount) )
		BEGIN

			SELECT
				CAST(1 AS BIT) [blnResult],
				'Se ha actualizado exitosamente el tutorial del usuario' [resultMessage]

		END
		ELSE 
		BEGIN

			SELECT
				CAST(1 AS BIT) [blnResult],
				'Se ha actualizado exitosamente el tutorial del usuario' [resultMessage]

		END
			
	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION;

		SELECT
			CAST(0 AS BIT) [blnResult],
			ERROR_MESSAGE() [resultMessage]

	END CATCH

END