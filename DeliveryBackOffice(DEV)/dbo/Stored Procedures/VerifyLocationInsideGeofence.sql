

-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-05-11>
-- Description:	< Verifica si el punto indicado existe dentro de una geocerca especificada >
-- =============================================

CREATE PROCEDURE [dbo].[VerifyLocationInsideGeofence]
	@Latitude NVARCHAR(20),
	@Longitude NVARCHAR(20),
	@Geofence INT = 1 -- Geocerca de GT = 1
AS
BEGIN

	BEGIN TRY

		IF (
			RTRIM(LTRIM(ISNULL(@Latitude, ''))) <> ''
			AND RTRIM(LTRIM(ISNULL(@Longitude, ''))) <> ''
			)
		BEGIN
			DECLARE @TargetGeofence GEOMETRY;
			DECLARE @TargetGeofenceAsText NVARCHAR(MAX);

			DECLARE @TargetPoint GEOMETRY;
			DECLARE @TargetPointAsText NVARCHAR(MAX) = CONCAT('POINT (', @Longitude, ' ', @Latitude, ')');

			SET @TargetGeofenceAsText
			= (CONCAT(
			'POLYGON ((', (SELECT
					STUFF((SELECT
							', '
							+ CONCAT(
							CAST(P.PointLongitude AS DECIMAL(9, 6)),
							' ',
							CAST(P.PointLatitude AS DECIMAL(9, 6))
							)
						FROM [DeliveryBackOffice].[dbo].[Geofence] G WITH (NOLOCK)
						INNER JOIN [DeliveryBackOffice].[dbo].[GeofencePoint] GP WITH (NOLOCK)
							ON G.IdGeofence = GP.IdGeofence
							AND GP.RowStatus = 1
						INNER JOIN [DeliveryBackOffice].[dbo].[Point] P WITH (NOLOCK)
							ON GP.IdPoint = P.IdPoint
							AND P.RowStatus = 1
						WHERE G.RowStatus = 1
						AND G.IdGeofence = @Geofence 
						ORDER BY GP.GeofencePointOrder ASC
						FOR XML PATH (''), TYPE)
					.value('.', 'varchar(max)'),
					1,
					1,
					''
					))
			,
			'))'
			)
			);

			SET @TargetGeofence = GEOMETRY::STGeomFromText(@TargetGeofenceAsText, 0);

			SET @TargetPoint = GEOMETRY::STGeomFromText(@TargetPointAsText, 0);

			DECLARE @IsValidLocation BIT
			= CASE
				WHEN @TargetPoint.STIntersection(@TargetGeofence).ToString() = 'GEOMETRYCOLLECTION EMPTY' THEN 0
				ELSE 1
			END;
		END;

		IF (@IsValidLocation = 1)
		BEGIN

			SELECT 
				1 [blnResult]

		END
		ELSE
		BEGIN

			SELECT 
				0 [blnResult]

		END

	END TRY
	BEGIN CATCH

		SELECT
			0 [blnResult]

	END CATCH;


END
