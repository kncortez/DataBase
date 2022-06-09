
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-01-03>
-- Description:	< Ingresa la información de parametros (Ventanas horarias) a una guía.>
-- =============================================

CREATE PROCEDURE [dbo].[SetGuideParameters]
	@GuidesParameters TblParameterGuide READONLY,
	@Token NVARCHAR(50)
AS
BEGIN

	DECLARE @UpdatedSDFG INT = NULL;

	BEGIN TRANSACTION
		BEGIN TRY

			UPDATE
				SDFG
			SET
				SDFG.StartTime = CAST(GP.GuideServiceWindow1Start AS TIME)
				,SDFG.EndTime = CAST(GP.GuideServiceWindow1End AS TIME)
				,SDFG.StartTime2 = CAST(GP.GuideServiceWindow2Start AS TIME)
				,SDFG.EndTime2 = CAST(GP.GuideServiceWindow2End AS TIME)
				,SDFG.TokenUpdated = @Token
				,SDFG.DateUpdated = GETDATE()
			FROM
				[DeliveryBackOffice].[dbo].[ServiceDataForGuide] SDFG
				JOIN
					@GuidesParameters GP
					ON
					SDFG.GuideSerie = GP.GuideSerie
					AND
					SDFG.GuideNumber = GP.GuideNumber

			SET @UpdatedSDFG = @@ROWCOUNT;

		END TRY
		BEGIN CATCH
			SELECT
				500 'IdResult',
				ERROR_MESSAGE() 'Description'
			ROLLBACK TRANSACTION
		END CATCH
		IF(@@TRANCOUNT > 0)
		BEGIN
			IF(@UpdatedSDFG > 0)
			BEGIN
				SELECT
					200 'IdResult',
					'Parametros de tiempo actualizados para las visitas' 'Description'
				COMMIT TRANSACTION
			END
			ELSE
			BEGIN
				SELECT
					400 'IdResult',
					'No se realizo ningun update' 'Description'
				ROLLBACK TRANSACTION
			END
		END
		ELSE
		BEGIN
			SELECT
				500 'IdResult',
				'No se proceso la transacción' 'Description'
			ROLLBACK TRANSACTION
		END
	--END TRANSACTION
END