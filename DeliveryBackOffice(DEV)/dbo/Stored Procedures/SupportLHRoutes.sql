
CREATE PROCEDURE SupportLHRoutes
    @CatRouteId INT,
    @HubOriginId INT,
    @HubDestinyId INT,
    @RowStatus INT,
    @Token VARCHAR(200)
AS
BEGIN
    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar que la ruta exista
        IF NOT EXISTS (SELECT 1 FROM dbo.CatRoute WITH(NOLOCK) WHERE IDROUTE = @CatRouteId)
        BEGIN
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            RAISERROR('La Ruta no existe.', 16, 1);
            RETURN;
        END;
		-- DESTINO NO PUEDE SER IGUAL AL ORIGEN
		IF @HubOriginId = @HubDestinyId
		BEGIN
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		RAISERROR('DESTINO NO PUEDE SER IGUAL AL ORIGEN.', 16, 1);
		RETURN;
		END



        DECLARE @CoverageState INT;

        DECLARE @ExistsExact INT = (
            SELECT COUNT(*) 
            FROM LinehaulCoverage WITH(NOLOCK)
            WHERE CatRouteId = @CatRouteId
              AND HubOriginId = @HubOriginId
              AND HubDestinyId = @HubDestinyId
        );

        DECLARE @ExistsSameOrigin INT = (
            SELECT COUNT(*) 
            FROM LinehaulCoverage WITH(NOLOCK)
            WHERE CatRouteId = @CatRouteId
              AND HubOriginId = @HubOriginId
        );

        DECLARE @ExistsRoute INT = (
            SELECT COUNT(*)
            FROM LinehaulCoverage WITH(NOLOCK)
            WHERE CatRouteId = @CatRouteId
        );

        -- Determinar estado
        IF @ExistsExact > 0                  
            SET @CoverageState = 2;          -- Existe origen + destino
        ELSE IF @ExistsSameOrigin > 0        
            SET @CoverageState = 1;          -- Existe origen pero otro destino
        ELSE IF @ExistsRoute > 0             
            SET @CoverageState = 0;          -- Misma ruta, otro origen
        ELSE
            SET @CoverageState = NULL;       -- No existe nada aún


        -- Caso 2: Update (origen + destino exacto)
        IF @CoverageState = 2
        BEGIN
            UPDATE LinehaulCoverage
            SET RowStatus = @RowStatus,
                DateUpdated = GETDATE(),
                TokenUpdated = @Token
            WHERE CatRouteId = @CatRouteId
              AND HubOriginId = @HubOriginId
              AND HubDestinyId = @HubDestinyId;
        END

        -- Caso 1: Insert con mismo origen, destino diferente
        ELSE IF @CoverageState = 1
        BEGIN
            INSERT INTO LinehaulCoverage
            (
                CatRouteId, 
				HubOriginId, 
				HubDestinyId,
                ReportEmails, 
				RowStatus,
                TokenCreated, 
				DateCreated,
                TokenUpdated, 
				DateUpdated,
                ReportPhones
            )
            VALUES
            (
                @CatRouteId, 
				@HubOriginId, 
				@HubDestinyId,
                '', 
				@RowStatus,
                @Token, 
				GETDATE(),
                NULL, 
				NULL,
                NULL
            );
        END

        -- Caso inicial: No existe ninguna cobertura aún
        ELSE IF @CoverageState IS NULL
        BEGIN
            INSERT INTO LinehaulCoverage
            (
                CatRouteId, 
				HubOriginId, 
				HubDestinyId,
                ReportEmails, 
				RowStatus,
                TokenCreated, 
				DateCreated,
                TokenUpdated, 
				DateUpdated,
                ReportPhones
            )
            VALUES
            (
                @CatRouteId, 
				@HubOriginId, 
				@HubDestinyId,
                '', 
				@RowStatus,
                @Token, 
				GETDATE(),
                NULL, 
				NULL,
                NULL
            );
        END

        -- Caso 3: Ruta existe pero con otro origen ? error
        ELSE IF @CoverageState = 0
        BEGIN
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            RAISERROR('No se permite otro origen para la misma ruta.', 16, 1);
            RETURN;
        END;

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
        SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;

