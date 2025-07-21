-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <2025-07-03>
-- Description: <Validar incidencias de liquidaciones>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_SetTotalAmountDO]
	@TotalAmount DECIMAL(14,2),
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@Token NVARCHAR(250)
AS
BEGIN

    BEGIN TRANSACTION
	BEGIN TRY

		UPDATE DeliveryOrder
		SET PriceShippment = @TotalAmount,
			TokenUpdated = @Token,
			DateUpdated = GETDATE()
		WHERE Guide_Serie = @GuideSerie
			AND Guide_Number =  @GuideNumber

		IF @@ROWCOUNT = 0
		BEGIN
			SELECT
					'400' [StatusCode]
					,'Error al actualizar el monto total en la DeliveryOrder' [Message] 

		END
		ELSE
		BEGIN

			COMMIT TRANSACTION

			SELECT
					'200' [StatusCode]
					,'Se actualiza la guía correctamente.' [Message] 
		END
	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION

		SELECT
			'-1' [StatusCode]
		   ,ERROR_MESSAGE() [Message]

	END CATCH

END