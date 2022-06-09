
-- =============================================
-- Author:		<Ruiz,Andres>
-- Create date: <2022-04-06>
-- Description:	< Actualiza el registro de ubicaciones del Courier >
-- =============================================

CREATE PROCEDURE [dbo].[UpdateCourierLocation]
	@IdCourier INT,
	@CourierToken NVARCHAR(50),
	@NewAccuracy NVARCHAR(20),
	@NewLatitude NVARCHAR(20),
	@NewLongitude NVARCHAR(20)
AS
BEGIN

	-- Variable de control de flujo
	DECLARE @IdLastRegistry INT = -1;

	-- Variables de respuesta
	DECLARE @JsonResult NVARCHAR(MAX) = NULL;
	
	BEGIN TRANSACTION
		BEGIN TRY

			-- Actualizar registros anteriores
			UPDATE
				LCL
			SET
				LCL.RowStatus = 0
				,LCL.TokenUpdated = @CourierToken
				,LCL.DateUpdated = GETDATE()
			FROM
				[DeliveryBackOffice].[dbo].[LogCourierLocation] LCL
			WHERE
				LCL.CourierId = @IdCourier
				AND
				LCL.RowStatus = 1

			-- Insertar última ubicación
			INSERT INTO
				[DeliveryBackOffice].[dbo].[LogCourierLocation] 
				(CourierId, Accuracy, Latitude, Longitude, RowStatus, TokenCreated, DateCreated)
			VALUES
				(@IdCourier, @NewAccuracy, @NewLatitude, @NewLongitude, 1, @CourierToken, GETDATE())

			SET @IdLastRegistry = SCOPE_IDENTITY()

			IF(@@TRANCOUNT > 0)
				COMMIT TRANSACTION

			SET @JsonResult = (
				SELECT STUFF
				(
					(
						SELECT 
							',{' +
							'"blnResult"' + ':' + '1' + ',' +
							'"resultRegistry"' + ':' + CONVERT(NVARCHAR, @IdLastRegistry) + ',' +
							+ '}'
						FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),
					1,
					1,
					''
				)
			);

			IF(ISNULL(@JsonResult,'') = '' OR ISNULL(@IdLastRegistry,-1) <= 0)
			BEGIN
			
				SET @JsonResult = (
					SELECT STUFF
					(
						(
							SELECT 
								',{' +
								'"blnResult"' + ':' + '0' + ',' +
								'"ErrorNumber"' + ':' + '-1' + ',' +
								'"ErrorSeverity"' + ':' + '-1' + ',' +
								'"ErrorState"' + ':' + '-1' + ',' +
								'"ErrorProcedure"' + ':' + '"UpdateCourierLocation"' + ',' +
								'"ErrorLine"' + ':' + '-1' + ',' +
								'"ErrorMessage"' + ':' + '"No se genero correctamente el registro"' + ',' +
								+ '}'
							FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),
						1,
						1,
						''
					)
				);

			END

			SELECT
				'['+ @JsonResult +']' 'JsonResult'

		END TRY
		BEGIN CATCH

			ROLLBACK TRANSACTION
			
			SET @JsonResult = (
				SELECT STUFF
				(
					(
						SELECT 
							',{' +
							'"blnResult"' + ':' + '0' + ',' +
							'"ErrorNumber"' + ':' + CONVERT(NVARCHAR, ERROR_NUMBER()) + ',' +
							'"ErrorSeverity"' + ':' + CONVERT(NVARCHAR, ERROR_SEVERITY()) + ',' +
							'"ErrorState"' + ':' + CONVERT(NVARCHAR, ERROR_STATE()) + ',' +
							'"ErrorProcedure"' + ':"' + ERROR_PROCEDURE() + '",' +
							'"ErrorLine"' + ':' + CONVERT(NVARCHAR, ERROR_LINE()) + ',' +
							'"ErrorMessage"' + ':"' + ERROR_MESSAGE() + '",' +
							+ '}'
						FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),
					1,
					1,
					''
				)
			);

			SELECT
				'[' + @JsonResult + ']' 'JsonResult'

		END CATCH

END;