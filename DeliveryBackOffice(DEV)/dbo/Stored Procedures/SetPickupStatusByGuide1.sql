-- =============================================
-- Author:		<Luis Ardón>
-- Create date: <2023-11-25>
-- Modify:      <Carlos Vicente>
-- Modify on:   <2023-12-11>
-- Description:	<Establecer estado de recolectado a traves del número de guía>
-- =============================================
CREATE PROCEDURE [dbo].[SetPickupStatusByGuide1]
    @GuideSerie AS NVARCHAR(2),
    @GuideNumber AS BIGINT,
    @tokenCreated AS NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRAN;
    BEGIN TRY
        DECLARE @StatusRequested TINYINT = 15;
        --Verficacion de guia
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.DeliveryOrder WITH (NOLOCK)
            WHERE Guide_Number = @GuideNumber
                  AND Guide_Serie = @GuideSerie
        )
        BEGIN
            RAISERROR('Número de guia inválido', 16, 1);
            RETURN;
        END;

        --Verificacion de guia en estado solicitado 
        IF NOT EXISTS
        (
            SELECT 
                1
            FROM 
                dbo.DeliveryOrder WITH (NOLOCK)
            WHERE Guide_Number = @GuideNumber
                  AND Guide_Serie = @GuideSerie
                  AND StatusOrderId = @StatusRequested
        )
        BEGIN
            RAISERROR('La guía no se encuentra en estado solicitado', 16, 1);
            RETURN;
        END;

        --Cambio de estado a recolectado
        DECLARE @StateCollected TINYINT = 2;

        --Insercción de registro en bitacora
        INSERT INTO dbo.DeliveryOrderDetail
        (
            Guide_Serie,
            Guide_Number,
            StatusOrderId,
            UserCreated,
            DateCreated,
            DateCreatedInSystem,
            Observations,
            Temperature_Celsius,
            PieceId,
            RowStatus,
            DeliveryAttemptId,
            SystemOrigin
        )
        VALUES
        (   @GuideSerie,     -- Guide_Serie - nvarchar(2)
            @GuideNumber,    -- Guide_Number - int
            @StateCollected, -- StatusOrderId - tinyint
            @tokenCreated,   -- UserCreated - nvarchar(50)
            GETDATE(),       -- DateCreated - datetime
            GETDATE(),       -- DateCreatedInSystem - datetime
            NULL,            -- Observations - nvarchar(200)
            NULL,            -- Temperature_Celsius - decimal(5, 2)
            NULL,            -- PieceId - int
            1,               -- RowStatus - bit
            NULL,            -- DeliveryAttemptId - bigint
            NULL             -- SystemOrigin - int
            );

        --Actualizacion de registro
        UPDATE dbo.DeliveryOrder
        SET StatusOrderId = @StateCollected
        WHERE Guide_Number = @GuideNumber
              AND Guide_Serie = @GuideSerie;

        COMMIT TRAN;
        SELECT 200 AS 'responseCode',
               'Proceso realizado exitosamente' AS responseMessage;

    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        SELECT 204 AS 'responseCode',
               ERROR_MESSAGE() AS 'responseMessage';
    END CATCH;
END;