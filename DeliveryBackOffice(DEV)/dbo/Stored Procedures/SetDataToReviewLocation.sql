

-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-02-22>
-- Description:	< actualiza los registros de la tabla historica de ubicaciones con nuevos datos >
-- =============================================
CREATE PROCEDURE [dbo].[SetDataToReviewLocation]
	@DataToReview TblLocationReview READONLY,
	@TypeOfReview INT -- 1 : Número de seguridad social | 2 : Teléfono
AS
BEGIN

	IF(@TypeOfReview = 1)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
	
			-- ACTUALIZAR REGISTROS EXISTENTES
			UPDATE
				LR
			SET
				LR.Accuracy = DTR.LocationAccuracy
				,LR.Latitud = DTR.LocationLatitude
				,LR.Longitude = DTR.LocationLongitude
				,LR.TokenUpdated = 'SYS-HERMESLOCATIONREVIEWERupdate'
				,LR.DateUpdated = GETDATE()
			FROM
				@DataToReview DTR
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[LocationRecord] LR
					ON
						DTR.LocationSocialSecurity = LR.SocialSecurityId
			WHERE
				LR.IdLocationRecord IS NOT NULL
				AND
				DTR.IsUpdateCandidate = 1
				AND
				CAST(LR.Accuracy AS DECIMAL) > CAST(DTR.LocationAccuracy AS DECIMAL)

			-- INGRESAR DATOS A REVISAR DE REGISTROS EXISTENTES
			UPDATE
				LR
			SET
				LR.AccuracyToReview = DTR.LocationAccuracy
				,LR.AddressToReview = DTR.LocationAddress
				,LR.LatitudeToReview = DTR.LocationLatitude
				,LR.LongitudeToReview = DTR.LocationLongitude
				,LR.TokenUpdated = 'SYS-HERMESLOCATIONREVIEWERupdate'
				,LR.DateUpdated = GETDATE()
			FROM
				@DataToReview DTR
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[LocationRecord] LR
					ON
						DTR.LocationSocialSecurity = LR.SocialSecurityId
			WHERE
				LR.IdLocationRecord IS NOT NULL
				AND
				DTR.IsUpdateCandidate = 0

			-- INSERTAR NUEVOS REGISTROS NO EXISTENTES
			INSERT INTO [DeliveryBackOffice].[dbo].[LocationRecord] 
				(SocialSecurityId, Address, Accuracy, Latitud, Longitude, RowStatus, TokenCreated, DateCreated)
			SELECT
				DTR.LocationSocialSecurity, DTR.LocationAddress, DTR.LocationAccuracy, DTR.LocationLatitude, DTR.LocationLongitude, 1, 'SYS-HERMESLOCATIONREVIEWER', GETDATE()
			FROM
				@DataToReview DTR
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[LocationRecord] LR
					ON
						DTR.LocationSocialSecurity = LR.SocialSecurityId
			WHERE
				LR.IdLocationRecord IS NULL


			IF(@@TRANCOUNT > 0)
				COMMIT TRANSACTION

			SELECT
				1 [blnResult],
				'Datos actualizados de forma exitosa' AS [Description]
		END TRY
		BEGIN CATCH
			 SELECT 
				0 [blnResult],
				ERROR_NUMBER() AS [ErrorNumber],
				ERROR_SEVERITY() AS [ErrorSeverity],
				ERROR_STATE() AS [ErrorState],
				ERROR_PROCEDURE() AS [ErrorProcedure],
				ERROR_LINE() AS [ErrorLine],
				ERROR_MESSAGE() AS [ErrorMessage];

			ROLLBACK TRANSACTION
		END CATCH
	END
	ELSE IF(@TypeOfReview = 2)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
	
			-- ACTUALIZAR REGISTROS EXISTENTES
			UPDATE
				LR
			SET
				LR.Accuracy = DTR.LocationAccuracy
				,LR.Latitud = DTR.LocationLatitude
				,LR.Longitude = DTR.LocationLongitude
				,LR.TokenUpdated = 'SYS-HERMESLOCATIONREVIEWERupdate'
				,LR.DateUpdated = GETDATE()
			FROM
				@DataToReview DTR
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[LocationRecord] LR
					ON
						DTR.LocationPhone = LR.Phone
			WHERE
				LR.IdLocationRecord IS NOT NULL
				AND
				DTR.IsUpdateCandidate = 1
				AND
				CAST(LR.Accuracy AS DECIMAL) > CAST(DTR.LocationAccuracy AS DECIMAL)

			-- INGRESAR DATOS A REVISAR DE REGISTROS EXISTENTES
			UPDATE
				LR
			SET
				LR.AccuracyToReview = DTR.LocationAccuracy
				,LR.AddressToReview = DTR.LocationAddress
				,LR.LatitudeToReview = DTR.LocationLatitude
				,LR.LongitudeToReview = DTR.LocationLongitude
				,LR.TokenUpdated = 'SYS-HERMESLOCATIONREVIEWERupdate'
				,LR.DateUpdated = GETDATE()
			FROM
				@DataToReview DTR
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[LocationRecord] LR
					ON
						DTR.LocationPhone = LR.Phone
			WHERE
				LR.IdLocationRecord IS NOT NULL
				AND
				DTR.IsUpdateCandidate = 0

			-- INSERTAR NUEVOS REGISTROS NO EXISTENTES
			INSERT INTO [DeliveryBackOffice].[dbo].[LocationRecord] 
				(Phone, Address, Accuracy, Latitud, Longitude, RowStatus, TokenCreated, DateCreated)
			SELECT
				DTR.LocationPhone, DTR.LocationAddress, DTR.LocationAccuracy, DTR.LocationLatitude, DTR.LocationLongitude, 1, 'SYS-HERMESLOCATIONREVIEWER', GETDATE()
			FROM
				@DataToReview DTR
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[LocationRecord] LR
					ON
						DTR.LocationPhone = LR.Phone
			WHERE
				LR.IdLocationRecord IS NULL


			IF(@@TRANCOUNT > 0)
				COMMIT TRANSACTION

			SELECT
				1 [blnResult],
				'Datos actualizados de forma exitosa' AS [Description]
		END TRY
		BEGIN CATCH
			 SELECT 
				0 [blnResult],
				ERROR_NUMBER() AS [ErrorNumber],
				ERROR_SEVERITY() AS [ErrorSeverity],
				ERROR_STATE() AS [ErrorState],
				ERROR_PROCEDURE() AS [ErrorProcedure],
				ERROR_LINE() AS [ErrorLine],
				ERROR_MESSAGE() AS [ErrorMessage];

			ROLLBACK TRANSACTION
		END CATCH
	END

END
