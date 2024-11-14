-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-10-04>
-- Description:	<Registra y valida si un servicio ya cuenta con una incidencia, de tomo de base SetIncidenceService>
-- =============================================
CREATE PROCEDURE SetIncidence_WebHookDispatch
    @TblIncidenceLink AS TblIncidenceLink READONLY,
    @Identifier NVARCHAR(20),
    @DescriptionIncidence varchar(200) = 'Problemas de ubicacion',
    @Accuracy NVARCHAR(200) = '44',
    @Latitude NVARCHAR(200) = '55798797342',
    @Longitude NVARCHAR(200) = '546689',
    @Token NVARCHAR(200) = '545656asdf564afd',
    @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
    BEGIN TRY
        DECLARE @StatusService INT,
                @StatusIncidence INT,
                @IncidenceTypeId INT

		DECLARE @ServiceManagementId INT = SUBSTRING(@Identifier, 4, LEN(@Identifier) - 3)

        -- Variables de incidencias terminales - 
        DECLARE @DuplicateId INT = (
                                       SELECT TOP 1
                                           CTI.IdIncidenceType
                                       FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI WITH (NOLOCK)
                                       WHERE CTI.NameIncidence = 'Servicio duplicado'
                                   );
        DECLARE @CanceledId INT = (
                                      SELECT TOP 1
                                          CTI.IdIncidenceType
                                      FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI WITH (NOLOCK)
                                      WHERE CTI.NameIncidence = 'Cliente cancelo servicio'
                                  );
        DECLARE @AlreadyPickedId INT = (
                                           SELECT TOP 1
                                               CTI.IdIncidenceType
                                           FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI WITH (NOLOCK)
                                           WHERE CTI.NameIncidence = 'Recolectada en otra ruta'
                                       );
        ----Variable de estado cancelado
        DECLARE @CanceledStatusId INT = (
                                            SELECT TOP 1
                                                CSS.IdServiceStatus
                                            FROM [DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH (NOLOCK)
                                            WHERE CSS.[Name] = 'Cancelado'
                                        );
        SET @StatusIncidence =
        (
            SELECT IdServiceStatus
            FROM CatServiceStatus WITH (NOLOCK)
            WHERE Name = 'Incidencia'
        );

        SET @IncidenceTypeId =
        (
            SELECT IdIncidenceType
            FROM CatTypeIncidence
            WHERE NameIncidence = @DescriptionIncidence
                  AND RowStatus = 1
				  AND ServiceType = 'PICKUP'
                  AND CountryId = @IdCountry
        );
        --Validamos que exista el servicio
        IF EXISTS
        (
            SELECT TOP 1 *
            FROM ServiceManagement WITH (NOLOCK)
            WHERE IdServiceManagement = @ServiceManagementId
        )
        BEGIN
            SELECT @StatusService = ServiceStatusId
            FROM ServiceManagement WITH (NOLOCK)
            WHERE IdServiceManagement = @ServiceManagementId

            --validamos el estado actual del servicio. Que sea diferente de incidencia
            IF (@StatusService != @StatusIncidence)
            BEGIN
                BEGIN TRANSACTION
                ------------Registramos la incidencia del servicio------------------
                INSERT INTO DeliveryBackOffice.dbo.IncidenceServices
                (
                    ServiceManagementId,
                    IncidenceTypeId,
                    DescriptionIncidence,
                    Latitude,
                    Longitude,
                    Accuracy,
                    RowStatus,
                    TokenCreated,
                    DateCreated,
                    TokenUpdated,
                    DateUpdated
                )
                VALUES
                (@ServiceManagementId,
                 @IncidenceTypeId,
                 @DescriptionIncidence,
                 @Latitude,
                 @Longitude,
                 @Accuracy,
                 1  ,
                 @Token,
                 GETDATE(),
                 NULL,
                 NULL
                )

                DECLARE @IdIncidence INT = SCOPE_IDENTITY()

                INSERT INTO DeliveryBackOffice.dbo.ProofIncidence
                (
                    IncidenceId,
                    PathIncidence,
                    RowStatus,
                    TokenCreated,
                    DateCreated,
                    TokenUpdated,
                    DateUpdated
                )
                SELECT @IdIncidence,
                       li.PathIncidence,
                       1,
                       @Token,
                       GETDATE(),
                       NULL,
                       NULL
                FROM @TblIncidenceLink li

                -------------Actualizar el estado del servicio a incidencia-------------------

                UPDATE ServiceManagement
                SET ServiceStatusId = @StatusIncidence,
                    DateUpdated = GETDATE(),
                    TokenUpdated = @Token, 
					CatPaymentTimeId = NULL
                WHERE IdServiceManagement = @ServiceManagementId

                ------------Inserta en EventService el comportamiento del Pickup------------------

                INSERT INTO EventService
                (
                    ServiceManagementId,
                    ServiceStatusId,
                    RowStauts,
                    TokenCreated,
                    DateCreated,
                    Observations
                )
                VALUES
                (@ServiceManagementId, @StatusIncidence, 1, @Token, GETDATE(), @DescriptionIncidence)

                IF @@TRANCOUNT > 0
				BEGIN
                    COMMIT TRANSACTION;
                SELECT 1 AS StatusCode,
                       'Incidencia registrada' AS Description
				END
				ELSE
				BEGIN
					ROLLBACK TRANSACTION;
				END
            END
			ELSE
			BEGIN
				SELECT 1 AS StatusCode,
                       'El servicio ya se encuentra con incidencia' AS Description
			END
        END
		ELSE
		BEGIN
			SELECT 1 AS StatusCode,
                  'Servicio no encontrado' AS Description
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