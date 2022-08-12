
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-08-18>
-- Description:	< Recupera datos de ubicación basado en la estación del usuario >
-- =============================================

CREATE PROCEDURE [dbo].[GetStationLocation]
	@StationId INT
AS
BEGIN

	-- Variables de respuesta
	DECLARE @TransactionResult BIT = 1;
	DECLARE @LocationData AS TABLE(
		LocationOrigin NVARCHAR(30),
		LatitudeLocation NVARCHAR(50),
		LongitudeLocation NVARCHAR(50)
	);

	-- Obtener datos de ubicación de estación
	BEGIN TRY

		INSERT INTO
			@LocationData
			(LocationOrigin, LatitudeLocation, LongitudeLocation)
		SELECT
			(
				CASE
					WHEN HL.IdHubLogistic IS NOT NULL THEN 'OriginByHub'
					WHEN VPC.IdVisitPointClient IS NOT NULL THEN 'OriginByVisitPointClient'
					ELSE 'OriginByCalculation'
				END
			) 'LocationOrigin',
			(
				CASE
					WHEN HL.IdHubLogistic IS NOT NULL THEN LTRIM(RTRIM(ISNULL(HL.HubLatitude,'')))
					WHEN VPC.IdVisitPointClient IS NOT NULL THEN LTRIM(RTRIM(ISNULL(VPC.Latitude,'')))
					ELSE ''
				END
			) 'LatitudeLocation',
			(
				CASE
					WHEN HL.IdHubLogistic IS NOT NULL THEN LTRIM(RTRIM(ISNULL(HL.HubLongitude,'')))
					WHEN VPC.IdVisitPointClient IS NOT NULL THEN LTRIM(RTRIM(ISNULL(VPC.Longitude,'')))
					ELSE ''
				END
			) 'LongitudeLocation'
		FROM
			[DeliveryBackOffice].[dbo].[CatStation] CS WITH(NOLOCK)
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[HubLogistics] HL WITH(NOLOCK)
				ON
					CS.HubLogisticId = HL.IdHubLogistic
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
				ON
					CS.CodeOfReference = VPC.CodeOfReference
		WHERE
			CS.IdStation = @StationId
			AND
			CS.RowStatus = 1

		IF( NOT EXISTS (SELECT TOP 1 1 FROM @LocationData) )
		BEGIN

	
			-- No existe ubicación registrada en base de datos
			-- Indicar que es necesario cálcular ubicación de origen
			INSERT INTO 
				@LocationData
			VALUES
				('ErrorInOrigin','','')

			SET @TransactionResult = 0;

		END
		ELSE IF( 
					((SELECT TOP 1 LD.LatitudeLocation FROM @LocationData LD) = '') 
					AND 
					((SELECT TOP 1 LD.LongitudeLocation FROM @LocationData LD) = '') 
				)
		BEGIN
	
			-- No existe ubicación registrada en base de datos
			-- Indicar que es necesario cálcular ubicación de origen
			UPDATE 
				@LocationData
			SET
				LocationOrigin = 'ErrorInOrigin'

			SET @TransactionResult = 0;

		END

		SELECT
			@TransactionResult [blnResult],
			LD.LocationOrigin,
			LD.LatitudeLocation,
			LD.LongitudeLocation
		FROM
			@LocationData LD
		
	END TRY
	BEGIN CATCH

		SET @TransactionResult = 0;

		SELECT
			@TransactionResult [blnResult],
			'',
			'',
			''

	END CATCH
END