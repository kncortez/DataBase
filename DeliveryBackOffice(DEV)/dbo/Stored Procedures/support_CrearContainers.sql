/* =================================================
   SP:        [dbo].[support_CrearContainers]
   Propósito: Crear contenedores de forma masiva validando duplicados por descripcion.
   Autor:     Cristian De Leon
   Historia:  FDAPI-5286
   Fecha:     2026-02-16
============================================
=== CHANGELOG ================================
2026-02-16 | Historia/epica: FDAPI-5286 | Autor: Cristian De Leon |
-----
=========================================== */
CREATE OR ALTER PROCEDURE dbo.support_CrearContainers
(
    @CatTypeContainerId INT,          -- Tipo de contenedor
    @Prefijo            NVARCHAR(20),  -- BOX, LH, EXT, etc
    @StartNumber        INT,           -- Número inicial
    @Total              INT,           -- Cantidad a crear
    @CantidadCeros      INT,           -- Total de dígitos (ej. 5 -> 00301)
    @Usuario            NVARCHAR(50) = N'SYS-CDELEON'
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE 
        @i INT = 0,
        @NumeroActual INT,
        @NumberStr NVARCHAR(50),
        @ContainerDesc NVARCHAR(100);

    WHILE @i < @Total
    BEGIN
        SET @NumeroActual = @StartNumber + @i;

        SET @NumberStr =
            RIGHT(
                REPLICATE(N'0', @CantidadCeros) + CAST(@NumeroActual AS NVARCHAR),
                @CantidadCeros
            );

        SET @ContainerDesc = @Prefijo + @NumberStr;

        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.Container WITH (NOLOCK)
            WHERE containerdescription = @ContainerDesc
        )
        BEGIN
            INSERT INTO DeliveryBackOffice.dbo.Container
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

        SET @i = @i + 1;
    END
END;
GO
