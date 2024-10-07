-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-10-03>
-- Description:	<Actualiza la informacion encontrada que envia el WeebHook Dispatch>
-- =============================================
CREATE PROCEDURE [dbo].[SetWeebHook_Dispatch]
    @Identifier NVARCHAR(20),
    @Token VARCHAR(200) = NULL,
    @PuSignaturePath NVARCHAR(250) = ' ',
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @PickupLatitude NVARCHAR(20) = NULL,
    @PickupLongitude NVARCHAR(20) = NULL,
	@Status INT
AS
BEGIN
    BEGIN TRY
        DECLARE @StatusRecolect INT,
                @StatusDelivered INT,
				@StatusIncidence INT,
				@StatusRoute INT

        DECLARE @KeyLocal INT = SUBSTRING(@Identifier, 4, LEN(@Identifier) - 3)

			-- Variables para verificar ubicación en geocerca
		DECLARE @FixedLatitude NVARCHAR(20) = @PickupLatitude;
		DECLARE @FixedLongitude NVARCHAR(20) = @PickupLongitude;

		BEGIN TRY

        IF (
               RTRIM(LTRIM(ISNULL(@PickupLatitude, ''))) <> ''
               AND RTRIM(LTRIM(ISNULL(@PickupLongitude, ''))) <> ''
           )
        BEGIN
            DECLARE @TargetGeofence GEOMETRY;
            DECLARE @TargetGeofenceAsText NVARCHAR(MAX);

            DECLARE @TargetPoint GEOMETRY;
            DECLARE @TargetPointAsText NVARCHAR(MAX) = CONCAT('POINT (', @PickupLongitude, ' ', @PickupLatitude, ')');

            SET @TargetGeofenceAsText
                = (CONCAT(
                             'POLYGON ((',
                   (
                       SELECT STUFF(
                                       (
                                           SELECT ', '
                                                  + CONCAT(
                                                              CAST(P.PointLongitude AS DECIMAL(9, 6)),
                                                              ' ',
                                                              CAST(P.PointLatitude AS DECIMAL(9, 6))
                                                          )
                                           FROM [DeliveryBackOffice].[dbo].[Geofence] G WITH (NOLOCK)
                                               INNER JOIN [DeliveryBackOffice].[dbo].[GeofencePoint] GP WITH (NOLOCK)
                                                   ON G.IdGeofence = GP.IdGeofence             
                                               INNER JOIN [DeliveryBackOffice].[dbo].[Point] P WITH (NOLOCK)
                                                   ON GP.IdPoint = P.IdPoint                  
                                           WHERE G.RowStatus = 1
												 AND GP.RowStatus = 1
												 AND P.RowStatus = 1
                                                 AND G.IdGeofence = 1 -- Geocerca de GT
                                           ORDER BY GP.GeofencePointOrder ASC
                                           FOR XML PATH(''), TYPE
                                       ).value('.', 'varchar(max)'),
                                       1,
                                       1,
                                       ''
                                   )
                   ),
                             '))'
                         )
                  );

            SET @TargetGeofence = geometry::STGeomFromText(@TargetGeofenceAsText, 0);

            SET @TargetPoint = geometry::STGeomFromText(@TargetPointAsText, 0);

            DECLARE @IsValidLocation BIT
                = CASE
                      WHEN @TargetPoint.STIntersection(@TargetGeofence).ToString() = 'GEOMETRYCOLLECTION EMPTY' THEN
                          0
                      ELSE
                          1
                  END;

            IF (@IsValidLocation = 0)
            BEGIN
                SET @FixedLatitude = NULL;
                SET @FixedLongitude = NULL;
            END;
        END;

    END TRY
    BEGIN CATCH
        PRINT 'ERROR IN GEOLOCATION';

        SET @FixedLatitude = NULL;
        SET @FixedLongitude = NULL;
    END CATCH;

		SET @StatusRoute = 
		(
			SELECT IdServiceStatus
            FROM CatServiceStatus WITH (NOLOCK)
            WHERE Name = 'Asignado a Ruta'
		)
        SET @StatusRecolect =
        (
            SELECT IdServiceStatus
            FROM CatServiceStatus WITH (NOLOCK)
            WHERE Name = 'Recolectado'
        )
        SET @StatusDelivered =
        (
            SELECT IdServiceStatus
            FROM CatServiceStatus WITH (NOLOCK)
            WHERE Name = 'Entregado '
        )

		SET @StatusIncidence =
        (
            SELECT IdServiceStatus
            FROM CatServiceStatus WITH (NOLOCK)
            WHERE Name = 'Incidencia '
        )

        IF EXISTS
        (
            SELECT *
            FROM ServiceManagement WITH (NOLOCK)
            WHERE IdServiceManagement = @KeyLocal
        )
        BEGIN
            BEGIN TRANSACTION
				UPDATE ServiceManagement
                SET ServiceStatusId = CASE WHEN @Status = 1 THEN @StatusRoute
										   WHEN @Status = 2 THEN @StatusDelivered
										   --WHEN @Status = 4 THEN @StatusDelivered
									END,
                    PuSignaturePath = @PuSignaturePath,
                    CiPuDate = @StartDate,
                    CoPuDate = @EndDate,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE IdServiceManagement = @KeyLocal;
			IF @@RowCount > 0
			COMMIT TRANSACTION;
            SELECT 1 AS StatusCode,
                   'Resgistros actualizados' AS Description
        END
        ELSE
        BEGIN
            SELECT 0 AS StatusCode,
                   'Resgistro no encontrado' AS Description
        END
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 0 AS StatusCode,
               ERROR_MESSAGE() AS Description,
               ERROR_LINE() AS ErrorLine
    END CATCH
END