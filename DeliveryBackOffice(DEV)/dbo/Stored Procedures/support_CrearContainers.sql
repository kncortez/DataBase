CREATE PROCEDURE dbo.support_CrearContainers
(
    @CatTypeContainerId INT,        -- Tipo de contenedor
    @Prefijo           VARCHAR(20), -- BOX, LH, EXT, etc
    @StartNumber       INT,         -- Número inicial
    @Total             INT,         -- Cantidad a crear
    @CantidadCeros     INT,         -- Total de dígitos (ej. 5 -> 00301)
    @Usuario           VARCHAR(50) = 'SYS-CDELEON'
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @i INT = 0,
        @NumeroActual INT,
        @NumberStr VARCHAR(50),
        @ContainerDesc VARCHAR(100);

    WHILE @i < @Total
    BEGIN
        SET @NumeroActual = @StartNumber + @i;

        SET @NumberStr =
            RIGHT(
                REPLICATE('0', @CantidadCeros) + CAST(@NumeroActual AS VARCHAR),
                @CantidadCeros
            );

        SET @ContainerDesc = @Prefijo + @NumberStr;

        /*  Validación de duplicados por ContainerDescription */
        IF NOT EXISTS (
            SELECT 1
            FROM Container WITH (NOLOCK)
            WHERE containerdescription = @ContainerDesc
        )
        BEGIN
            INSERT INTO Container
            (
                cattypecontainerid,
                containernumber,
                containerdescription,
                rowstatus,
                Tokencreated,
                datecreated,
                tokeupdated,
                Dateupdated
            )
            VALUES
            (
                @CatTypeContainerId,
                @NumberStr,
                @ContainerDesc,
                1,
                @Usuario,
                GETDATE(),
                NULL,
                NULL
            );
        END
        -- Si existe, no inserta y continúa

        SET @i = @i + 1;
    END
END;
GO