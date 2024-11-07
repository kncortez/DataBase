-- =============================================
-- Author:      Daniel Ramirez
-- Create date: 2024/10/17
-- Description: Se agregaron validaciones de lotes
-- =============================================
CREATE PROCEDURE [dbo].[GetBatchGuideRemissionByCountry]
(
    @IdManifest      BIGINT, --@IdLinehaulRoutePreparation
    @User            NVARCHAR(100) = 'SYSTEM'
)
AS
BEGIN


BEGIN TRY
    BEGIN TRANSACTION;

        DECLARE @Batch                BIGINT,
                @InitialRange         BIGINT,
                @FinalRange           BIGINT,
                @CAI                  NVARCHAR(100),
                @LastProcessed        BIGINT,
                @GuideCertification   NVARCHAR(75),
                @Code                 INT = 0,
                @Message              NVARCHAR(250),
                @StationDispatchedId  INT = 0

        /*
          InvoiceBatchHeader
          status = 1 y enable = 1 es cuando el lote esta habilidado y activo
          status = 0 y enable = 1 es un error - no contemplado
          status = 1 y enable = 0 es cuando no se puede facturar, porque se detuvo facturación (Ya viene lote nuevo ejemplo)
        */

        --Obtener estación relacionada al manifiesto
        SELECT @StationDispatchedId = ISNULL(lrp.StationDispatchedId,0)
          FROM DeliveryBackOffice.dbo.LinehaulRoutePreparation lrp 
               LEFT JOIN [DeliveryBackOffice].[dbo].[CatStation] ct ON lrp.StationDispatchedId = ct.IdStation
         WHERE lrp.IdLinehaulRoutePreparation = @IdManifest

        EXEC [ValidateBatchGuideRemission] @TypeDocument    = 8,
                                           @IdStation       = @StationDispatchedId,
                                           @Code            = @Code OUTPUT,
                                           @Message         = @Message OUTPUT

        -- Si todas las validaciones fueron correctas
        IF @Code = 1
        BEGIN
             SELECT  @GuideCertification = CONCAT(RIGHT('000' + CAST(ibh.Establishment AS VARCHAR), 3), '-',
                                                  RIGHT('000' + CAST(ibh.Emision_Point AS VARCHAR), 3),'-',
                                                  RIGHT('00' + CAST(ibh.TypeDocument AS VARCHAR), 2),'-')
                     ,@Batch             = ibh.Id_Lote
                     ,@InitialRange      = ibh.InitialRange
                     ,@FinalRange        = ibh.FinalRange
                     ,@CAI = ibh.CAI
                     ,@LastProcessed = ibh.Last_Process + 1
               FROM [DeliveryBackOffice].[dbo].[InvoiceBatchRelationships] ibr WITH(NOLOCK) -- Relacion Lote <-> IdStation
                    INNER JOIN [DeliveryBackOffice].[dbo].[InvoiceBatchHeader] ibh WITH(NOLOCK)
                       ON ibr.Id_Lote = ibh.Id_Lote
              WHERE ibr.[IdStation] = @StationDispatchedId
                AND ibr.[RowStatus] = 1
                AND ibh.[Enable] = 1
                AND ibh.[Status] = 1
                AND ibh.[RowStatus] = 1
                AND ibh.[TypeDocument] = 8

             --Actualizamos el último procesado 
             UPDATE [DeliveryBackOffice].[dbo].[InvoiceBatchHeader]
                SET Last_Process = @LastProcessed
              WHERE Id_Lote = @Batch

             --Insertamos Factura Procesada
             INSERT INTO [DeliveryBackOffice].[dbo].[InvoiceBatchDetailLinehaul] 
                    (
                     IdBatch,
                     ProcessedCorrelative,
                     LinehaulRoutePreparationId,
                     SendManifest,
                     RowStatus,
                     TokenCreated,
                     DateCreated
                    )
             VALUES (
                     @Batch,
                     @LastProcessed,
                     @IdManifest,
                     0,
                     1,
                     @user,
                     GETDATE()
                    );
        END

        IF @Code <> 0
        BEGIN
             SELECT CONCAT(@GuideCertification, RIGHT('00000000' + CAST(@LastProcessed AS VARCHAR), 8)) AS 'CertificationGuideRemission',
                    @CAI AS 'CAI',
                    @LastProcessed AS'ProcessedCorrelative',
                    @Code AS StatusCode,
                    @Message AS [Message]
        END

    COMMIT TRANSACTION 
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN 
        ROLLBACK TRANSACTION;
    END

    SELECT '' AS 'CertificationGuideRemission',
           '' AS 'CAI',
           '' AS'ProcessedCorrelative',
           0 AS StatusCode,
           ERROR_MESSAGE() AS [Message]

END CATCH
END;