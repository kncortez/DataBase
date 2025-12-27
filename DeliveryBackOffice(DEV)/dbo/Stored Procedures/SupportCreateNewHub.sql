CREATE PROCEDURE SupportCreateNewHub
    @HubName NVARCHAR(200),
    @HubAbbreviation NVARCHAR(10),
    @CountryId CHAR(2),
    @StationName NVARCHAR(100),
    @DescriptionCC NVARCHAR(500) = NULL,
    @HubLatitude DECIMAL(10,6) = NULL,
    @HubLongitude DECIMAL(10,6) = NULL,
    @IsGateway BIT = 0,
    @TokenCreated NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @IdStation INT;
    DECLARE @IdHubLogistic INT;
    DECLARE @CurrentDate DATETIME = GETDATE();
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- 1. Insertar en CatStation
        INSERT INTO CatStation (
            StationName,
            CountryId,
            StationType,
            HubLogisticId,
            CodeOfReference,
            RowStatus,
            TokenCreated,
            DateCreated,
            TokenUpdated,
            DateUpdated
        )
        VALUES (
            @StationName,
            @CountryId,
            1,
            NULL,
            NULL,
            1,
            @TokenCreated,
            @CurrentDate,
            NULL,
            NULL
        );
        
        -- Obtener el ID de la estación recién creada
        SET @IdStation = SCOPE_IDENTITY();
        
        -- 2. Insertar en HubLogistics
        INSERT INTO HubLogistics (
            HubName,
            HubAbbreviation,
            HubStatus,
            IdStation,
            IdCountry,
            TokenCreated,
            DateCreated,
            TokenUpdate,
            DateUpdated,
            IsGateway,
            HubLatitude,
            HubLongitude,
            DescriptionCC
        )
        VALUES (
            @HubName,
            @HubAbbreviation,
            1,
            @IdStation,
            @CountryId,
            @TokenCreated,
            @CurrentDate,
            NULL,
            NULL,
            @IsGateway,
            @HubLatitude,
            @HubLongitude,
            @DescriptionCC
        );
        
        -- Obtener el ID del hub recién creado
        SET @IdHubLogistic = SCOPE_IDENTITY();
        
        -- 3. Actualizar CatStation con el HubLogisticId
        UPDATE CatStation
        SET HubLogisticId = @IdHubLogistic,
            TokenUpdated = @TokenCreated,
            DateUpdated = @CurrentDate
        WHERE IdStation = @IdStation;
        
        COMMIT TRANSACTION;
        
        -- Retornar los IDs creados
        SELECT 
            @IdStation AS IdStation,
            @IdHubLogistic AS IdHubLogistic,
            'SUCCESS' AS Status,
            'Hub y Estación creados correctamente' AS Message;
            
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Retornar el error
        SELECT 
            NULL AS IdStation,
            NULL AS IdHubLogistic,
            'ERROR' AS Status,
            ERROR_MESSAGE() AS Message;
    END CATCH
END;
GO