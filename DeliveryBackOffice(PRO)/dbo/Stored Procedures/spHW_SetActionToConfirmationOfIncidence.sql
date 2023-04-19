
-- =============================================
-- Author:		<Andrés, Ruíz>
-- Create date: <2023-02-17>
-- Description:	< Método para ingresar acción bajo una confirmación de incidencia >
-- =============================================
CREATE PROCEDURE [dbo].[spHW_SetActionToConfirmationOfIncidence]
	
	@ConfirmationOfIncidenceId INT,
	@ActionObservation NVARCHAR(600) = '',
	@Token NVARCHAR(50)

AS
BEGIN

DECLARE @UpdatedData TABLE (
	DataId INT
)

BEGIN TRANSACTION
BEGIN TRY

	-- Revisar que confirmación de incidencia no haya sido procesada
	IF( NOT EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] COI WITH(NOLOCK) WHERE COI.IdConfirmationOfIncidence = @ConfirmationOfIncidenceId AND COI.ConfirmationOfIncidentToken LIKE '%TIMEOUT') )
	BEGIN

		-- Token de confirmación no ha expirado, aun se puede indicar acción
		UPDATE
			[DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]
		SET
			IsActionIssued = 1
			,ActionObservation = @ActionObservation
			,TokenUpdated = @Token
			,DateUpdated = GETDATE()
		OUTPUT inserted.IdConfirmationOfIncidence INTO @UpdatedData(DataId)
		WHERE
			IdConfirmationOfIncidence = @ConfirmationOfIncidenceId

		IF( EXISTS(SELECT TOP 1 1 FROM @UpdatedData) )
		BEGIN

			COMMIT TRANSACTION

			SELECT
				200 'resultCode',
				'Datos ingresados exitosamente a confirmación' 'resultMessage'

		END
		ELSE
		BEGIN

			ROLLBACK TRANSACTION

			SELECT
				204 'resultCode',
				'No se pudo ingresar datos a confirmación' 'resultMessage'

		END

	END
	ELSE
	BEGIN

		ROLLBACK TRANSACTION

		SELECT
			204 'resultCode',
			'Confimración de incidencia ya fue procesada en liquidación' 'resultMessage'

	END

END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION

	SELECT
		500 'resultCode',
		ERROR_MESSAGE() 'resultMessage'

END CATCH

END