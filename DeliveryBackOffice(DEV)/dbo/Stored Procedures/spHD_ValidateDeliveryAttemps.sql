-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-11-29>
-- Description:	<Obtiene listado de guías que no poseen reintentos de entrega y se marcan como devolución.>
-- =============================================
ALTER PROCEDURE [dbo].[spHD_ValidateDeliveryAttemps]
    -- Add the parameters for the stored procedure here
    @DeliveryOrderBySettlementId BIGINT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Tabla de incidencias forzadas a devolución
    DECLARE @ReturnIncidence TABLE
    (
        IncidenceId INT
    );

    DECLARE @TblUpdatesGuides AS TABLE
    (
        IsLastMileReturn BIT
      , StatusOrderId    TINYINT
      , GuideNumber      INT
      , GuideSerie       NVARCHAR(2)
      , TypeService      NVARCHAR(3)
    );

    -- Insert statements for procedure here
    DECLARE @TblGuides AS TABLE
    (
        GuideSerie NVARCHAR(2)
      , GuideNumber INT
      , FlowGuide TINYINT
    );

    INSERT INTO @ReturnIncidence
    (
        [IncidenceId]
    )
    SELECT [CTI].[IdIncidenceType]
    FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI WITH (NOLOCK)
    WHERE [CTI].[NameIncidence] = 'Destinatario rechaza paquete' COLLATE Latin1_General_CI_AI
          AND [CTI].[RowStatus] = 1
          AND [CTI].[ServiceType] = 'DELIVERY' COLLATE Latin1_General_CI_AI;

    INSERT INTO @ReturnIncidence
    (
        [IncidenceId]
    )
    SELECT [CTI].[IdIncidenceType]
    FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI WITH (NOLOCK)
    WHERE [CTI].[NameIncidence] = 'Remitente solicita devolución' COLLATE Latin1_General_CI_AI
          AND [CTI].[RowStatus] = 1
          AND [CTI].[ServiceType] = 'DELIVERY' COLLATE Latin1_General_CI_AI;


    DECLARE @STATUSDECLAREDRETURNED_DO INT =
            (
                SELECT TOP 1
                       SO.StatusOrderId
                FROM dbo.StatusOrder SO WITH (NOLOCK)
                WHERE OrderDescription = 'Declarado para Devolución'
            );

    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO @TblGuides
        SELECT DISTINCT
               dsd.Guide_Serie
             , dsd.Guide_Number
             , CASE
                   WHEN do.IsLastMileReturn IS NULL
                        OR do.IsLastMileReturn = 0 THEN
                       CASE
                           WHEN doad.GuideDeliveryAttemptCount >= doad.GuideDeliveryMaxAttemptCount
                                OR coi.ClientConfirmsReturn = 1 THEN
                               2
                           WHEN [da].[ID_Incident] IN
                                (
                                    SELECT [RI].[IncidenceId] FROM @ReturnIncidence RI
                                )
                                AND ISNULL(coi.IsDenied, 0) = 0
                                AND ISNULL(coi.IsConfirmed, 0) = 1 THEN
                               2
                           ELSE
                               1
                       END
                   ELSE
                       1
               END FlowGuide
        FROM DeliverySettlementDetail           dsd WITH (NOLOCK)
            INNER JOIN DeliveryOrder            do WITH (NOLOCK)
                ON dsd.Guide_Serie = do.Guide_Serie
                   AND dsd.Guide_Number = do.Guide_Number
            INNER JOIN DeliveryOrderAttemptData doad WITH (NOLOCK)
                ON dsd.Guide_Serie = doad.GuideSerie
                   AND dsd.Guide_Number = doad.GuideNumber
                   AND doad.RowStatus = 1
            INNER JOIN DeliveryAttempt          da WITH (NOLOCK)
                ON dsd.Guide_Serie = da.Guide_Serie
                   AND dsd.Guide_Number = da.Guide_Number
                   AND da.ID_DeliveryOrderBySettlement = dsd.ID_DeliveryOrderBySettlement
            LEFT JOIN ConfirmationOfIncidence   coi WITH (NOLOCK)
                ON da.ConfirmationOfIncidenceId = coi.IdConfirmationOfIncidence
        WHERE dsd.ID_DeliveryOrderBySettlement = @DeliveryOrderBySettlementId
              AND dsd.RowStatus = 1
              AND dsd.Guide_Returned = 1;


     -- Marcar las que ya no tienen intentos de entrega disponibles como devolución
     UPDATE do
        SET IsLastMileReturn = 1
          , StatusOrderId = @STATUSDECLAREDRETURNED_DO
          , guide_number = do.guide_number
          , guide_serie = do.guide_serie
          , TypeService = do.TypeService
            OUTPUT 
            INSERTED.IsLastMileReturn,
            INSERTED.StatusOrderId,
            INSERTED.guide_number,
            INSERTED.guide_serie,
            INSERTED.TypeService
            INTO @TblUpdatesGuides
       FROM DeliveryOrder   do
            INNER JOIN @TblGuides  tg
                ON do.Guide_Serie = tg.GuideSerie
                   AND do.Guide_Number = tg.GuideNumber
            LEFT JOIN dbo.DeliveryOrderAttemptData DOA
                ON do.Guide_Serie = DOA.GuideSerie
                   AND do.Guide_Number = DOA.GuideNumber
                   AND DOA.GuideDeliveryAttemptCount = DOA.GuideDeliveryMaxAttemptCount
            INNER JOIN dbo.DeliveryAttempt         DA
                ON do.Guide_Serie = DA.Guide_Serie
                   AND do.Guide_Number = DA.Guide_Number
            INNER JOIN dbo.ConfirmationOfIncidence COI
                ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
      WHERE (tg.FlowGuide = 2
             OR COI.ClientConfirmsReturn = 1);

     UPDATE acodh
        SET acodh.AgaintsBalance = ISNULL(acodh.AgaintsBalance,0) + ISNULL(bdcod.Amount,0)
       FROM @TblGuides tg
            INNER JOIN @TblUpdatesGuides tug
                    ON tug.GuideSerie = tg.GuideSerie
                   AND tug.GuideNumber = tg.GuideNumber
            INNER JOIN AnticipatedCODDetail acodd WITH(NOLOCK)
                    ON tg.GuideSerie = acodd.GuideSerie
                   AND tg.GuideNumber = acodd.GuideNumber
                   AND acodd.RowStatus = 1
            INNER JOIN AnticipatedCODHeader acodh WITH(NOLOCK)
                    ON acodh.IdAnticipatedCODHeader = acodd.AnticipatedCODHeaderId
            INNER JOIN BatchDetailCOD bdcod WITH(NOLOCK)
                    ON bdcod.GuideSerie = tug.GuideSerie
                   AND bdcod.GuideNumber = tug.GuideNumber
            OUTER APPLY (
                         SELECT TOP 1 dod.StatusOrderId
                           FROM DeliveryOrderDetail dod
                                INNER JOIN StatusOrder so ON dod.statusorderid = so.StatusOrderId
                          WHERE dod.guide_serie = tg.GuideSerie
                            AND dod.guide_number = tg.GuideNumber
                            AND dod.RowStatus = 1
                            AND so.RowStatus = 1
                            AND so.OrderDescription = 'Recepcionado en Express Center COD Anticipado'--Recepcionado en Express Center COD Anticipado
                        ) StatusRegister
            OUTER APPLY (
                         SELECT TOP 1 StatusOrderId
                           FROM StatusOrder so
                           WHERE so.RowStatus = 1
                            AND so.OrderDescription = 'Recepcionado en Express Center COD Anticipado'--Recepcionado en Express Center COD Anticipado
                        ) StatusValue
        WHERE tg.FlowGuide = 2
          AND tug.IsLastMileReturn = 1
          AND tug.TypeService = 'COD'
          AND bdcod.Excluded = 0
          AND bdcod.CatTransactionTypeCODId = 2
          AND ISNULL(StatusRegister.StatusOrderId,tug.StatusOrderId) = StatusValue.StatusOrderId

       UPDATE acodh
          SET acodh.BalanceStatus = 'DEVOLUCION'
         FROM AnticipatedCODDetail acodh
            INNER JOIN @TblUpdatesGuides tug
                    ON tug.GuideSerie = acodh.GuideSerie
                   AND tug.GuideNumber = acodh.GuideNumber
            INNER JOIN AnticipatedCODHeader acod WITH(NOLOCK)
                    ON acod.IdAnticipatedCODHeader = acodh.AnticipatedCODHeaderId
            INNER JOIN BatchDetailCOD bdcod WITH(NOLOCK)
                    ON bdcod.GuideSerie = tug.GuideSerie
                   AND bdcod.GuideNumber = tug.GuideNumber
        where bdcod.Excluded = 0
          AND bdcod.CatTransactionTypeCODId = 2

        INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
        (
            Guide_Serie
          , Guide_Number
          , StatusOrderId
          , UserCreated
          , DateCreated
          , DateCreatedInSystem
          , RowStatus
        )
        SELECT DISTINCT
               tg.GuideSerie
             , tg.GuideNumber
             , @STATUSDECLAREDRETURNED_DO
             , 'spHD_ValidateDeliveryAttemps'
             , GETDATE()
             , GETDATE()
             , 1
        FROM @TblGuides                             tg
            INNER JOIN dbo.DeliveryOrderAttemptData DOA WITH (NOLOCK)
                ON tg.GuideSerie = DOA.GuideSerie
                   AND tg.GuideNumber = DOA.GuideNumber
                   AND DOA.GuideDeliveryAttemptCount = DOA.GuideDeliveryMaxAttemptCount
            LEFT JOIN dbo.DeliveryAttempt           DA WITH (NOLOCK)
                ON tg.GuideSerie = DA.Guide_Serie
                   AND tg.GuideNumber = DA.Guide_Number
            INNER JOIN dbo.ConfirmationOfIncidence  COI WITH (NOLOCK)
                ON DA.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
        WHERE tg.FlowGuide = 2
              OR COI.ClientConfirmsReturn = 1;

        COMMIT TRANSACTION;

        SELECT 1                                    'StatusCode'
             , 'Registros obtenidos correctamente.' 'Description';

        SELECT GuideSerie  Guide_Serie
             , GuideNumber Guide_Number
        FROM @TblGuides
        WHERE FlowGuide = 2;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        SELECT 0               'StatusCode'
             , ERROR_MESSAGE() 'Description';
    END CATCH;
END;