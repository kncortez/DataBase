-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-11-22>
-- Description:	<Registrar transacción de liquidación para material devuelto>
-- =============================================
CREATE PROCEDURE [dbo].[sps_settlement_guide_returned]
    @GuideSerie AS VARCHAR(2)
  , @GuideNumber AS INT
  , @Token NVARCHAR(50)
  , @IdManifest INT
AS
BEGIN
    DECLARE @RModified INT;
    DECLARE @Amount DECIMAL(14, 2);
    DECLARE @IsMarkedReturn BIT = 0;

    BEGIN TRANSACTION;

    BEGIN TRY

        SET @Amount =
        (
            SELECT Collect_OnDelivery
            FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
            WHERE Guide_Serie = @GuideSerie
                  AND Guide_Number = @GuideNumber
        );

        -- actualizar guía debido al proceso de liquidación
        UPDATE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]
        SET Settlement_Collect_OnDelivery = @Amount
          , SettlementCollect_TokenCreated = @Token
          , SettlementCollect_DateCreated = GETDATE()
          , Guide_Settlement = 1 -- guía liquidada en bodega
          , Guide_Returned = 1   -- guía liquidada vía material devuelto
          , Guide_Delivered = 0  -- guía liquidada vía comprobante de entrega
          , StatusOrderId = 8
        WHERE Guide_Serie = @GuideSerie
              AND Guide_Number = @GuideNumber
              AND ID_DeliveryOrderBySettlement = @IdManifest;

        SET @RModified = @@ROWCOUNT;

        -- registrar checkpoint histórico de devolución
        INSERT INTO [dbo].[DeliveryOrderDetail]
        (
            [Guide_Serie]
          , [Guide_Number]
          , [StatusOrderId]
          , [UserCreated]
          , [DateCreated]
          , [DateCreatedInSystem]
          , [Observations]
          , [Temperature_Celsius]
        )
        VALUES
        (   @GuideSerie, @GuideNumber, 8 -- retornado a Forza
          , @Token, GETDATE(), GETDATE(), NULL, NULL);

        -- registrar último checkpoint de devolución
        UPDATE DeliveryBackOffice.dbo.DeliveryOrder
        SET StatusOrderId = 8
        WHERE Guide_Serie = @GuideSerie
              AND Guide_Number = @GuideNumber;


        --FDAPI-1374 <Oscar Morales 2023-02-16> 
        -- invalidar token de incidencias
        UPDATE coi
        SET coi.ConfirmationOfIncidentToken += 'TIMEOUT'
        FROM ConfirmationOfIncidence   coi
            INNER JOIN DeliveryAttempt da WITH (NOLOCK)
                ON coi.IdConfirmationOfIncidence = da.ConfirmationOfIncidenceId
            WHERE da.Guide_Serie = @GuideSerie
            AND da.Guide_Number = @GuideNumber
            AND da.ID_DeliveryOrderBySettlement = @IdManifest;
        -- FIN FDAPI-1374 <Oscar Morales 2023-02-16>

        --FDD-1071 <Oscar Morales 2023-02-16> 
        --Detectar desacatos courier
        UPDATE coi
        SET CourierContempt = 1
          , TokenUpdated = @Token
          , DateUpdated = GETDATE()
        FROM ConfirmationOfIncidence   coi
            INNER JOIN DeliveryAttempt da WITH (NOLOCK)
                ON coi.IdConfirmationOfIncidence = da.ConfirmationOfIncidenceId
        WHERE coi.IsActionIssued = 1
        AND da.Guide_Serie = @GuideSerie
        AND da.Guide_Number = @GuideNumber
        AND da.ID_DeliveryOrderBySettlement = @IdManifest;
        --FIN FDD-1071 <Oscar Morales 2023-02-16> 

        --FDD-1071 <Oscar Morales 2023-02-22> 
        --Detectar marcado como devolución por cliente

        IF EXISTS
        (
            SELECT 1
            FROM ConfirmationOfIncidence   coi
                INNER JOIN DeliveryAttempt da WITH (NOLOCK)
                    ON coi.IdConfirmationOfIncidence = da.ConfirmationOfIncidenceId     
            WHERE coi.ClientConfirmsReturn = 1
            AND da.Guide_Serie = @GuideSerie
            AND da.Guide_Number = @GuideNumber
            AND da.ID_DeliveryOrderBySettlement = @IdManifest
        )
        BEGIN
            DECLARE @StatusReturn TINYINT =
                    (
                        SELECT StatusOrderId
                        FROM StatusOrder
                        WHERE OrderDescription = 'Declarado para Devolución'
                              AND RowStatus = 1
                    );
            SET @IsMarkedReturn = 1;

            -- registrar checkpoint histórico de devolución
            INSERT INTO [dbo].[DeliveryOrderDetail]
            (
                [Guide_Serie]
              , [Guide_Number]
              , [StatusOrderId]
              , [UserCreated]
              , [DateCreated]
              , [DateCreatedInSystem]
              , [Observations]
              , [Temperature_Celsius]
            )
            VALUES
            (@GuideSerie, @GuideNumber, @StatusReturn, @Token, GETDATE(), GETDATE(), NULL, NULL);

            -- registrar último checkpoint de devolución
            UPDATE DeliveryOrder
            SET StatusOrderId = @StatusReturn
            WHERE Guide_Serie = @GuideSerie
                  AND Guide_Number = @GuideNumber;

        END;
        --FDD-1073 <Oscar Morales 2023-02-22> 

        --FDD-1075 <Oscar Morales 2023-02-24> 
        --Actualizar inténtos de entrega/devolución 

        --Si no existe el registro, crearlo
        IF NOT EXISTS
        (
            SELECT 1
            FROM DeliveryOrderAttemptData WITH (NOLOCK)
            WHERE GuideSerie = @GuideSerie
                  AND GuideNumber = @GuideNumber
                  AND RowStatus = 1
        )
        BEGIN
            INSERT INTO [dbo].[DeliveryOrderAttemptData]
            (
                [GuideSerie]
              , [GuideNumber]
              , [GuideDeliveryAttemptCount]
              , [GuideDeliveryMaxAttemptCount]
              , [GuideReturnAttemptCount]
              , [GuideReturnMaxAttemptCount]
              , [RowStatus]
              , [DateCreated]
              , [TokenCreated]
              , [DateUptaded]
              , [TokenUpdated]
            )
            SELECT TOP 1
                   do.Guide_Serie
                 , do.Guide_Number
                 , CASE
                       WHEN coi.IdConfirmationOfIncidence IS NOT NULL
                            AND so.OrderDescription = 'Incidencia Validada' /* 'Intento de entrega fallida'*/
                            AND
                            (
                                do.IsLastMileReturn IS NULL
                                OR do.IsLastMileReturn = 0
                                OR coi.ClientConfirmsReturn = 1
                            ) THEN
                           1
                       ELSE
                           0
                   END
                 , rh.Attempt
                 , CASE
                       WHEN coi.IdConfirmationOfIncidence IS NOT NULL
                            AND so.OrderDescription = 'Intento de entrega fallida'
                            AND do.IsLastMileReturn = 1
                            AND
                            (
                                coi.ClientConfirmsReturn IS NULL
                                OR coi.ClientConfirmsReturn = 0
                            ) THEN
                           1
                       ELSE
                           0
                   END
                 , rh.AttemptReturn
                 , 1
                 , GETDATE()
                 , @Token
                 , NULL
                 , NULL
            FROM DeliveryOrder                    do WITH (NOLOCK)
                LEFT JOIN VisitPointClient        vpc WITH (NOLOCK)
                    ON do.Sender_ID = vpc.CodeOfReference
                INNER JOIN RatebyCustomer         rbc WITH (NOLOCK)
                    ON ISNULL(do.IdCustomer, vpc.CustomerID) = rbc.RbcIdCustomer
                       AND rbc.RbcRowStatus = 1
                       AND
                       (
                           rbc.RbcCodeOfReference = vpc.CodeOfReference
                           OR rbc.RbcCodeOfReference IS NULL
                       )
                INNER JOIN RateHeader             rh WITH (NOLOCK)
                    ON rbc.RbcIdRate = rh.RheId
                INNER JOIN DeliveryAttempt        da WITH (NOLOCK)
                    ON do.Guide_Serie = da.Guide_Serie
                       AND do.Guide_Number = da.Guide_Number
                       AND da.ID_DeliveryOrderBySettlement = @IdManifest
                LEFT JOIN ConfirmationOfIncidence coi WITH (NOLOCK)
                    ON da.ConfirmationOfIncidenceId = coi.IdConfirmationOfIncidence
                LEFT JOIN StatusOrder             so
                    ON coi.StatusOrderId = so.StatusOrderId
            WHERE do.Guide_Serie = @GuideSerie
                  AND do.Guide_Number = @GuideNumber
            ORDER BY rbc.RbcCodeOfReference DESC;
        END;
        ELSE
        BEGIN
            UPDATE doad
            SET doad.GuideDeliveryAttemptCount = CASE
                                                     WHEN 
                                                     so.OrderDescription = 'Incidencia Validada' 
														  AND ISNULL(cti.IncidenceClasificationId,0)=1   THEN
                                                         doad.GuideDeliveryAttemptCount + 1
                                                     ELSE
                                                         doad.GuideDeliveryAttemptCount
                                                 END
              , doad.GuideReturnAttemptCount = CASE
                                                   WHEN do.IsLastMileReturn = 1
                                                        AND
                                                        (
                                                            coi.ClientConfirmsReturn IS NULL
                                                            OR coi.ClientConfirmsReturn = 0
                                                        ) THEN
                                                       doad.GuideReturnAttemptCount + 1
                                                   ELSE
                                                       doad.GuideReturnAttemptCount
                                               END
              , doad.DateUptaded = GETDATE()
              , doad.TokenUpdated = @Token
            FROM DeliveryOrderAttemptData          doad
                INNER JOIN DeliveryOrder           do WITH (NOLOCK)
                    ON doad.GuideSerie = do.Guide_Serie
                       AND doad.GuideNumber = do.Guide_Number
                INNER JOIN DeliveryAttempt         da WITH (NOLOCK)
                    ON doad.GuideSerie = da.Guide_Serie
                       AND doad.GuideNumber = da.Guide_Number
                       AND da.ID_DeliveryOrderBySettlement = @IdManifest
                INNER JOIN ConfirmationOfIncidence coi WITH (NOLOCK)
                    ON da.ConfirmationOfIncidenceId = coi.IdConfirmationOfIncidence
                       AND coi.IsDenied = 0 --no esté denegada
                INNER JOIN StatusOrder             so
                    ON coi.StatusOrderId = so.StatusOrderId
                 INNER JOIN dbo.CatTypeIncidence cti WITH (NOLOCK)
				    ON da.ID_Incident = cti.IdIncidenceType
				       AND ISNULL(cti.IncidenceClasificationId,0)=1
            WHERE doad.GuideSerie = @GuideSerie
                  AND doad.GuideNumber = @GuideNumber
                  AND
                  (
                      so.OrderDescription = 'Incidencia Validada'
                      OR so.OrderDescription = 'Intento de entrega fallida'
                  );

        --select * from StatusOrder

        END;
    --FIN FDD-1075 <Oscar Morales 2023-02-24> 
    END TRY
    BEGIN CATCH
        SELECT 0                                             AS 'StatusCode'
             , ERROR_MESSAGE()                               AS 'Description'
             , CONVERT(BIGINT, 0)                            AS 'NumTransferID'
             , @GuideSerie + CONVERT(NVARCHAR, @GuideNumber) AS 'Guide'
             , @Amount                                       AS 'Amount'
             , 0                                             AS 'SubStatusCode';
        ROLLBACK TRANSACTION;
    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN
        IF (@RModified > 0)
            SELECT 1                                             AS 'StatusCode'
                 , 'Registro guardado correctamente'             AS 'Description'
                 , @@TRANCOUNT                                   AS 'NumTransferID'
                 , @GuideSerie + CONVERT(NVARCHAR, @GuideNumber) AS 'Guide'
                 , @Amount                                       AS 'Amount'
                 , 0                                             AS 'SubStatusCode'
                 , CASE
                       WHEN DOR.IsLastMileReturn = 1 THEN
                           ISNULL(doad.GuideReturnAttemptCount, 1)
                       ELSE
                           ISNULL(doad.GuideDeliveryAttemptCount, 1)
                   END                                           AS RetriesMade    --Numero intentos de entrega fallidas
                 , CASE
                       WHEN DOR.IsLastMileReturn = 1 THEN
                           ISNULL(doad.GuideReturnMaxAttemptCount, 2)
                       ELSE
                           ISNULL(doad.GuideDeliveryMaxAttemptCount, 2)
                   END                                           AS RetriesAllowed ---Numero de intentos permitidos
                 , ''                                            'Retries'
                 , CASE
                       WHEN DOR.IsLastMileReturn = 1 THEN
                           1
                       ELSE
                           0
                   END                                           ValidateAbandonedPackage
                 , CASE
                       WHEN @IsMarkedReturn = 1 THEN
                           1
                       ELSE
                           0
                   END                                           IsMarkedReturn
                 , CASE
                       WHEN COI.LiquidatorRemarks IS NULL THEN
                           'Sin Observaciones'
                       WHEN COI.LiquidatorRemarks = '' THEN
                           'Sin Observaciones'
                       ELSE
                           COI.LiquidatorRemarks
                   END                                           AS LiquidatorRemarks
            FROM DeliveryOrder                            DOR WITH (NOLOCK)
                INNER JOIN DeliveryOrderAttemptData       doad WITH (NOLOCK)
                    ON doad.GuideSerie = DOR.Guide_Serie
                       AND doad.GuideNumber = DOR.Guide_Number
                       AND doad.RowStatus = 1
                LEFT JOIN [dbo].[DeliveryAttempt]         DA WITH (NOLOCK)
                    ON DOR.Guide_Serie = DA.Guide_Serie
                       AND DOR.Guide_Number = DA.Guide_Number
                LEFT JOIN [dbo].[ConfirmationOfIncidence] COI WITH (NOLOCK)
                    ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
            WHERE DOR.Guide_Serie = @GuideSerie
                  AND DOR.Guide_Number = @GuideNumber;



        ELSE
            SELECT 0                                             AS 'StatusCode'
                 , 'Registro no encontrado'                      AS 'Description'
                 , 0                                             AS 'NumTransferID'
                 , @GuideSerie + CONVERT(NVARCHAR, @GuideNumber) AS 'Guide'
                 , @Amount                                       AS 'Amount'
                 , 0                                             AS 'SubStatusCode'
                 , 0                                             AS RetriesMade
                 , 0                                             AS RetriesAllowed
                 , ''                                            AS 'Retries'
                 , 0                                             AS ValidateAbandonedPackage
                 , 0                                             AS IsMarkedReturn;



        COMMIT TRANSACTION;
    END;
    ELSE
        SELECT 0                                             AS 'StatusCode'
             , ERROR_MESSAGE()                               AS 'Description'
             , CONVERT(BIGINT, 0)                            AS 'NumTransferID'
             , @GuideSerie + CONVERT(NVARCHAR, @GuideNumber) AS 'Guide'
             , @Amount                                       AS 'Amount'
             , 0                                             AS 'SubStatusCode'
             , 0                                             AS RetriesMade
             , 0                                             AS RetriesAllowed
             , ''                                            AS 'Retries'
             , 0                                             AS ValidateAbandonedPackage
             , 0                                             AS IsMarkedReturn;
END;
