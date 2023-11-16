
-- =============================================
-- Author:		<Bidcar,Herrera>
-- Create date: <2023-09-12>
-- Description:	<Obtener datos para Sistema de Control de Calidad>
-- =============================================
CREATE PROCEDURE [dbo].[GetQualityControlData]
    @GuideSerie NVARCHAR(2) = ''
  , @GuideNumber INT
  , @TblHubLogistic TblHubLogistic READONLY
AS
BEGIN
    BEGIN TRY
        --Tabla de cards filtrada por hub y guía

        DECLARE @Cards AS TABLE
        (
            Type NVARCHAR(5)
          , Description NVARCHAR(100)
          , Pending INT
          , Delivered INT
          , ConfirmationIncidents INT
          , UnConfirmationIncidents INT
          , OrderCard INT
        );

        IF (@GuideNumber IS NULL OR @GuideNumber <= 0)
        BEGIN
            INSERT INTO @Cards
            (
                Type
              , Description
              , Pending
              , Delivered
              , ConfirmationIncidents
              , UnConfirmationIncidents
            )
            SELECT --TOP 1000
                IIF(ord.StatusOrderId = 4
                  , 'EPE'
                  , IIF(
                        ord.StatusOrderId != 4
                        AND IncidenceTbl.DeliveryAttemptId IS NULL
                      , 'EEF'
                      , IIF(cfi.IsConfirmed = 1, 'IPR', 'IPP')))                                                   [Type]
              , IIF(ord.StatusOrderId = 4
                  , 'Entregas Pendientes'
                  , IIF(
                        ord.StatusOrderId != 4
                        AND IncidenceTbl.DeliveryAttemptId IS NULL
                      , 'Entregas Efectivas'
                      , IIF(cfi.IsConfirmed = 1, 'Incidencias Procesadas', 'Incidencias Pendientes de Procesar'))) [Description]
              , SUM(IIF(ord.StatusOrderId = 4, 1, 0))                                                              [Pending]
              , SUM(IIF(ord.StatusOrderId = 4, 0, IIF(IncidenceTbl.DeliveryAttemptId IS NULL, 1, 0)))              [Delivered]
              , SUM(IIF(ISNULL(cfi.IsConfirmed, 0) = 1, 1, 0))                                                     [ConfirmationIncidents]   --ConfirmedIncidents
              , SUM(IIF(ISNULL(cfi.IsConfirmed, 1) = 1, 0, 1))                                                     [UnConfirmationIncidents] --UnconfirmedIncidents
            FROM dbo.DeliveryOrderBySettlement          ds WITH (NOLOCK)
                INNER JOIN dbo.DeliverySettlementDetail dsd WITH (NOLOCK)
                    ON dsd.ID_DeliveryOrderBySettlement = ds.ID
                       AND dsd.RowStatus = 1
                INNER JOIN dbo.DeliveryOrder            ord WITH (NOLOCK)
                    ON ord.Guide_Serie = dsd.Guide_Serie
                       AND ord.Guide_Number = dsd.Guide_Number
                       AND ord.IsLastMileReturn = 0
                INNER JOIN dbo.StatusOrder              std WITH (NOLOCK)
                    ON std.StatusOrderId = ord.StatusOrderId
                OUTER APPLY
            (
                SELECT TOP 1
                       ddd.Guide_Serie
                     , ddd.Guide_Number
                     , ddd.DateCreatedInSystem
                     , ddd.DeliveryAttemptId
                     , tk.SSN_IdUser
                     , tk.SSN_Username
                FROM dbo.DeliveryOrderDetail                      ddd WITH (NOLOCK)
                    LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated
                WHERE ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND ddd.StatusOrderId = 45
                      AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
                ORDER BY CONVERT(DATE, ddd.DateCreatedInSystem) DESC
            )                                           IncidenceTbl
                LEFT JOIN dbo.DeliveryAttempt          att
                    ON att.ID = IncidenceTbl.DeliveryAttemptId
                LEFT JOIN dbo.CatTypeIncidence         cti WITH (NOLOCK)
                    ON cti.IdIncidenceType = att.ID_Incident
                LEFT JOIN dbo.DeliveryOrderAttemptData atd WITH (NOLOCK)
                    ON atd.GuideSerie = ord.Guide_Serie
                       AND atd.GuideNumber = ord.Guide_Number
                LEFT JOIN dbo.ConfirmationOfIncidence  cfi WITH (NOLOCK)
                    ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                INNER JOIN dbo.SenderReceiver          sr WITH (NOLOCK)
                    ON sr.ID = ds.ID_Courier
                LEFT JOIN dbo.Township                 tw WITH (NOLOCK)
                    ON tw.IdTownship = ord.ReceiverIdTownship
                OUTER APPLY
            (
                SELECT TOP 1
                       HBL.IdHubLogistic
                FROM dbo.DumpServiceCoverage                       dum WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                        ON dum.Hub = HBL.HubAbbreviation
                           AND HBL.HubStatus = 1
                WHERE dum.HeaderCode = tw.HeaderCode
            )                                          HUbs
                LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                    ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            WHERE CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
                  AND HUbs.IdHubLogistic IN
                      (
                          SELECT IdHubLogistics FROM @TblHubLogistic
                      )
                  AND ds.Date_Received IS NULL
                  AND IncidenceTbl.SSN_IdUser IS NULL
            GROUP BY IIF(ord.StatusOrderId = 4
                       , 'EPE'
                       , IIF(
                             ord.StatusOrderId != 4
                             AND IncidenceTbl.DeliveryAttemptId IS NULL
                           , 'EEF'
                           , IIF(cfi.IsConfirmed = 1, 'IPR', 'IPP')))
                   , IIF(ord.StatusOrderId = 4
                       , 'Entregas Pendientes'
                       , IIF(
                             ord.StatusOrderId != 4
                             AND IncidenceTbl.DeliveryAttemptId IS NULL
                           , 'Entregas Efectivas'
                           , IIF(cfi.IsConfirmed = 1, 'Incidencias Procesadas', 'Incidencias Pendientes de Procesar')))
            UNION
            SELECT --TOP 1000
                IIF(ord.StatusOrderId = 4
                  , 'EPE'
                  , IIF(ord.StatusOrderId != 4 AND ddd.DeliveryAttemptId IS NULL
                        , 'EEF'
                        , IIF(cfi.IsConfirmed = 1, 'IPR', 'IPP')))                                                 [Type]
              , IIF(ord.StatusOrderId = 4
                  , 'Entregas Pendientes'
                  , IIF(
                        ord.StatusOrderId != 4
                        AND ddd.DeliveryAttemptId IS NULL
                      , 'Entregas Efectivas'
                      , IIF(cfi.IsConfirmed = 1, 'Incidencias Procesadas', 'Incidencias Pendientes de Procesar'))) [Description]
              , SUM(IIF(ord.StatusOrderId = 4, 1, 0))                                                              [Pending]
              , SUM(IIF(ord.StatusOrderId = 4, 0, IIF(ddd.DeliveryAttemptId IS NULL, 1, 0)))                       [Delivered]
              , SUM(IIF(ISNULL(cfi.IsConfirmed, 0) = 1, 1, 0))                                                     [ConfirmationIncidents]   --ConfirmedIncidents
              , SUM(IIF(ISNULL(cfi.IsConfirmed, 1) = 1, 0, 1))                                                     [UnConfirmationIncidents] --UnconfirmedIncidents
            FROM dbo.DeliveryOrder                            ord WITH (NOLOCK)
                INNER JOIN dbo.StatusOrder                    std WITH (NOLOCK)
                    ON std.StatusOrderId = ord.StatusOrderId
                INNER JOIN dbo.DeliveryOrderDetail            ddd WITH (NOLOCK)
                    ON ddd.Guide_Serie = ord.Guide_Serie
                       AND ddd.Guide_Number = ord.Guide_Number
                       AND ddd.StatusOrderId = 45
                       AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
                       AND ddd.SystemOrigin = 2 --desktop					
                LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                    ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated


                LEFT JOIN dbo.DeliveryAttempt                 att
                    ON att.ID = ddd.DeliveryAttemptId
                LEFT JOIN dbo.CatTypeIncidence                cti WITH (NOLOCK)
                    ON cti.IdIncidenceType = att.ID_Incident
                LEFT JOIN dbo.DeliveryOrderAttemptData        atd WITH (NOLOCK)
                    ON atd.GuideSerie = ord.Guide_Serie
                       AND atd.GuideNumber = ord.Guide_Number
                LEFT JOIN dbo.ConfirmationOfIncidence         cfi WITH (NOLOCK)
                    ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                LEFT JOIN dbo.Township                        tw WITH (NOLOCK)
                    ON tw.IdTownship = ord.ReceiverIdTownship
                OUTER APPLY
            (
                SELECT TOP 1
                       HBL.IdHubLogistic
                FROM dbo.DumpServiceCoverage                       dum WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                        ON dum.Hub = HBL.HubAbbreviation
                           AND HBL.HubStatus = 1
                WHERE dum.HeaderCode = tw.HeaderCode
            )                                                 HUbs
                LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                    ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            WHERE CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
                  AND ddd.SystemOrigin = 2 -- desktop
                  AND HUbs.IdHubLogistic IN
                      (
                          SELECT IdHubLogistics FROM @TblHubLogistic
                      )
                  AND ord.IsLastMileReturn = 0
            GROUP BY IIF(ord.StatusOrderId = 4
                       , 'EPE'
                       , IIF(ord.StatusOrderId != 4 AND ddd.DeliveryAttemptId IS NULL
                             , 'EEF'
                             , IIF(cfi.IsConfirmed = 1, 'IPR', 'IPP')))
                   , IIF(ord.StatusOrderId = 4
                       , 'Entregas Pendientes'
                       , IIF(
                             ord.StatusOrderId != 4
                             AND ddd.DeliveryAttemptId IS NULL
                           , 'Entregas Efectivas'
                           , IIF(cfi.IsConfirmed = 1, 'Incidencias Procesadas', 'Incidencias Pendientes de Procesar')));


        END;
        ELSE
        BEGIN
            INSERT INTO @Cards
            (
                Type
              , Description
              , Pending
              , Delivered
              , ConfirmationIncidents
              , UnConfirmationIncidents
            )
            SELECT --TOP 1000
                IIF(ord.StatusOrderId = 4
                  , 'EPE'
                  , IIF(
                        ord.StatusOrderId != 4
                        AND IncidenceTbl.DeliveryAttemptId IS NULL
                      , 'EEF'
                      , IIF(cfi.IsConfirmed = 1, 'IPR', 'IPP')))                                                   [Type]
              , IIF(ord.StatusOrderId = 4
                  , 'Entregas Pendientes'
                  , IIF(
                        ord.StatusOrderId != 4
                        AND IncidenceTbl.DeliveryAttemptId IS NULL
                      , 'Entregas Efectivas'
                      , IIF(cfi.IsConfirmed = 1, 'Incidencias Procesadas', 'Incidencias Pendientes de Procesar'))) [Description]
              , SUM(IIF(ord.StatusOrderId = 4, 1, 0))                                                              [Pending]
              , SUM(IIF(ord.StatusOrderId = 4, 0, IIF(IncidenceTbl.DeliveryAttemptId IS NULL, 1, 0)))              [Delivered]
              , SUM(IIF(ISNULL(cfi.IsConfirmed, 0) = 1, 1, 0))                                                     [ConfirmationIncidents] --ConfirmedIncidents
              , SUM(IIF(ISNULL(cfi.IsConfirmed, 1) = 1, 0, 1))                                                     [UnConfirmationIncidents]
            FROM dbo.DeliveryOrderBySettlement          ds WITH (NOLOCK)
                INNER JOIN dbo.DeliverySettlementDetail dsd WITH (NOLOCK)
                    ON dsd.ID_DeliveryOrderBySettlement = ds.ID
                       AND dsd.RowStatus = 1
                INNER JOIN dbo.DeliveryOrder            ord WITH (NOLOCK)
                    ON ord.Guide_Serie = dsd.Guide_Serie
                       AND ord.Guide_Number = dsd.Guide_Number
                       AND ord.IsLastMileReturn = 0
                INNER JOIN dbo.StatusOrder              std WITH (NOLOCK)
                    ON std.StatusOrderId = ord.StatusOrderId
                OUTER APPLY
            (
                SELECT TOP 1
                       ddd.Guide_Serie
                     , ddd.Guide_Number
                     , ddd.DateCreatedInSystem
                     , ddd.DeliveryAttemptId
                     , tk.SSN_IdUser
                     , tk.SSN_Username
                FROM dbo.DeliveryOrderDetail                      ddd WITH (NOLOCK)
                    LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated
                WHERE ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND ddd.StatusOrderId = 45
                      AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
                ORDER BY ddd.DateCreatedInSystem DESC
            )                                           IncidenceTbl
                LEFT JOIN dbo.DeliveryAttempt          att
                    ON att.ID = IncidenceTbl.DeliveryAttemptId
                LEFT JOIN dbo.CatTypeIncidence         cti WITH (NOLOCK)
                    ON cti.IdIncidenceType = att.ID_Incident
                LEFT JOIN dbo.DeliveryOrderAttemptData atd WITH (NOLOCK)
                    ON atd.GuideSerie = ord.Guide_Serie
                       AND atd.GuideNumber = ord.Guide_Number
                LEFT JOIN dbo.ConfirmationOfIncidence  cfi WITH (NOLOCK)
                    ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                INNER JOIN dbo.SenderReceiver          sr WITH (NOLOCK)
                    ON sr.ID = ds.ID_Courier
                LEFT JOIN dbo.Township                 tw WITH (NOLOCK)
                    ON tw.IdTownship = ord.ReceiverIdTownship
                OUTER APPLY
            (
                SELECT TOP 1
                       HBL.IdHubLogistic
                FROM dbo.DumpServiceCoverage                       dum WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                        ON dum.Hub = HBL.HubAbbreviation
                           AND HBL.HubStatus = 1
                WHERE dum.HeaderCode = tw.HeaderCode
            )                                          HUbs
                LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                    ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            WHERE CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
                  AND dsd.Guide_Serie = @GuideSerie
                  AND dsd.Guide_Number = @GuideNumber
                  AND ds.Date_Received IS NULL
                  AND IncidenceTbl.SSN_IdUser IS NULL
            GROUP BY IIF(ord.StatusOrderId = 4
                       , 'EPE'
                       , IIF(
                             ord.StatusOrderId != 4
                             AND IncidenceTbl.DeliveryAttemptId IS NULL
                           , 'EEF'
                           , IIF(cfi.IsConfirmed = 1, 'IPR', 'IPP')))
                   , IIF(ord.StatusOrderId = 4
                       , 'Entregas Pendientes'
                       , IIF(
                             ord.StatusOrderId != 4
                             AND IncidenceTbl.DeliveryAttemptId IS NULL
                           , 'Entregas Efectivas'
                           , IIF(cfi.IsConfirmed = 1, 'Incidencias Procesadas', 'Incidencias Pendientes de Procesar')))
            UNION
            SELECT --TOP 1000
                IIF(ord.StatusOrderId = 4
                  , 'EPE'
                  , IIF(ord.StatusOrderId != 4 AND ddd.DeliveryAttemptId IS NULL
                        , 'EEF'
                        , IIF(cfi.IsConfirmed = 1, 'IPR', 'IPP')))                                                 [Type]
              , IIF(ord.StatusOrderId = 4
                  , 'Entregas Pendientes'
                  , IIF(
                        ord.StatusOrderId != 4
                        AND ddd.DeliveryAttemptId IS NULL
                      , 'Entregas Efectivas'
                      , IIF(cfi.IsConfirmed = 1, 'Incidencias Procesadas', 'Incidencias Pendientes de Procesar'))) [Description]
              , SUM(IIF(ord.StatusOrderId = 4, 1, 0))                                                              [Pending]
              , SUM(IIF(ord.StatusOrderId = 4, 0, IIF(ddd.DeliveryAttemptId IS NULL, 1, 0)))                       [Delivered]
              , SUM(IIF(ISNULL(cfi.IsConfirmed, 0) = 1, 1, 0))                                                     [ConfirmationIncidents] --ConfirmedIncidents
              , SUM(IIF(ISNULL(cfi.IsConfirmed, 1) = 1, 0, 1))                                                     [UnConfirmationIncidents]
            FROM dbo.DeliveryOrder                            ord WITH (NOLOCK)
                INNER JOIN dbo.StatusOrder                    std WITH (NOLOCK)
                    ON std.StatusOrderId = ord.StatusOrderId
                INNER JOIN dbo.DeliveryOrderDetail            ddd WITH (NOLOCK)
                    ON ddd.Guide_Serie = ord.Guide_Serie
                       AND ddd.Guide_Number = ord.Guide_Number
                       AND ddd.StatusOrderId = 45
                       AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
                       AND ddd.SystemOrigin = 2 --desktop					
                LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                    ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated
                LEFT JOIN dbo.DeliveryAttempt                 att
                    ON att.ID = ddd.DeliveryAttemptId
                LEFT JOIN dbo.CatTypeIncidence                cti WITH (NOLOCK)
                    ON cti.IdIncidenceType = att.ID_Incident
                LEFT JOIN dbo.DeliveryOrderAttemptData        atd WITH (NOLOCK)
                    ON atd.GuideSerie = ord.Guide_Serie
                       AND atd.GuideNumber = ord.Guide_Number
                LEFT JOIN dbo.ConfirmationOfIncidence         cfi WITH (NOLOCK)
                    ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                LEFT JOIN dbo.Township                        tw WITH (NOLOCK)
                    ON tw.IdTownship = ord.ReceiverIdTownship
                OUTER APPLY
            (
                SELECT TOP 1
                       HBL.IdHubLogistic
                FROM dbo.DumpServiceCoverage                       dum WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                        ON dum.Hub = HBL.HubAbbreviation
                           AND HBL.HubStatus = 1
                WHERE dum.HeaderCode = tw.HeaderCode
            )                                                 HUbs
                LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                    ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            WHERE CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
                  AND ddd.SystemOrigin = 2 -- desktop
                  AND ord.Guide_Serie = @GuideSerie
                  AND ord.Guide_Number = @GuideNumber
                  AND ord.IsLastMileReturn = 0
            GROUP BY IIF(ord.StatusOrderId = 4
                       , 'EPE'
                       , IIF(ord.StatusOrderId != 4 AND ddd.DeliveryAttemptId IS NULL
                             , 'EEF'
                             , IIF(cfi.IsConfirmed = 1, 'IPR', 'IPP')))
                   , IIF(ord.StatusOrderId = 4
                       , 'Entregas Pendientes'
                       , IIF(
                             ord.StatusOrderId != 4
                             AND ddd.DeliveryAttemptId IS NULL
                           , 'Entregas Efectivas'
                           , IIF(cfi.IsConfirmed = 1, 'Incidencias Procesadas', 'Incidencias Pendientes de Procesar')));

        END;

        IF NOT EXISTS (SELECT 1 FROM @Cards WHERE Type = 'EPE')
        BEGIN
            INSERT @Cards
            (
                Type
              , Description
              , Pending
              , Delivered
              , ConfirmationIncidents
              , UnConfirmationIncidents
            )
            VALUES
            ('EPE', 'Entregas Pendientes', 0, 0, 0, 0);
        END;

        IF NOT EXISTS (SELECT 1 FROM @Cards WHERE Type = 'EEF')
        BEGIN
            INSERT @Cards
            (
                Type
              , Description
              , Pending
              , Delivered
              , ConfirmationIncidents
              , UnConfirmationIncidents
            )
            VALUES
            ('EEF', 'Entregas Efectivas', 0, 0, 0, 0);
        END;

        IF NOT EXISTS (SELECT 1 FROM @Cards WHERE Type = 'IPR')
        BEGIN
            INSERT @Cards
            (
                Type
              , Description
              , Pending
              , Delivered
              , ConfirmationIncidents
              , UnConfirmationIncidents
            )
            VALUES
            ('IPR', 'Incidencias Procesadas', 0, 0, 0, 0);
        END;

        IF NOT EXISTS (SELECT 1 FROM @Cards WHERE Type = 'IPP')
        BEGIN
            INSERT @Cards
            (
                Type
              , Description
              , Pending
              , Delivered
              , ConfirmationIncidents
              , UnConfirmationIncidents
            )
            VALUES
            ('IPP', 'Incidencias Pendientes de Procesar', 0, 0, 0, 0);
        END;

        UPDATE @Cards
        SET OrderCard = 1
        WHERE Type = 'EPE';

        UPDATE @Cards
        SET OrderCard = 2
        WHERE Type = 'EEF';

        UPDATE @Cards
        SET OrderCard = 3
        WHERE Type = 'IPR';

        UPDATE @Cards
        SET OrderCard = 4
        WHERE Type = 'IPP';

        SELECT *
        FROM
        (
            SELECT Type
                 , Description
                 , OrderCard
                 , SUM(Pending)                 Pending
                 , SUM(Delivered)               Delivered
                 , SUM(ConfirmationIncidents)   ConfirmationIncidents
                 , SUM(UnConfirmationIncidents) UnConfirmationIncidents
            FROM @Cards
            GROUP BY Type
                   , Description
                   , OrderCard
        ) AS TBL
        ORDER BY TBL.OrderCard;


        --Tabla de rutas filtrada por hub y guía
        IF (@GuideNumber IS NULL OR @GuideNumber <= 0)
        BEGIN
            SELECT --TOP 1000
                IIF(IncidenceTbl.SSN_IdUser IS NULL, ISNULL(ds.ID_Courier, 1), 0)                     [IdRoute]
              , IncidenceTbl.SSN_IdUser                                                               [IdUser]
              , IncidenceTbl.SSN_Username                                                             [Username]
              , (CASE
                     WHEN IncidenceTbl.SSN_IdUser IS NULL THEN
                         'Vendedor Rutero'
                     ELSE
                         'Usuario Desktop'
                 END
                )                                                                                     [RouteDescription]
              , IIF(IncidenceTbl.SSN_IdUser IS NULL
                  , CONCAT(
                              COALESCE(DeliveryBackOffice.dbo.CapitalizeFirstLetter(sr.First_Name), '')
                            , ' '
                            , COALESCE(DeliveryBackOffice.dbo.CapitalizeFirstLetter(sr.Last_Name), '')
                          )
                  , '')                                                                               [User]
              , SUM(IIF(ord.StatusOrderId = 4, 1, 0))                                                 [Pending]
              , SUM(IIF(ord.StatusOrderId = 4, 0, IIF(IncidenceTbl.DeliveryAttemptId IS NULL, 1, 0))) [Delivered]
              , SUM(IIF(ISNULL(cfi.IsConfirmed, 0) = 1, 1, 0))                                        [ConfirmedIncidents]
              , SUM(IIF(ISNULL(cfi.IsConfirmed, 1) = 1, 0, 1))                                        [UnconfirmedIncidents]
            FROM dbo.DeliveryOrderBySettlement          ds WITH (NOLOCK)
                INNER JOIN dbo.DeliverySettlementDetail dsd WITH (NOLOCK)
                    ON dsd.ID_DeliveryOrderBySettlement = ds.ID
                       AND dsd.RowStatus = 1
                INNER JOIN dbo.DeliveryOrder            ord WITH (NOLOCK)
                    ON ord.Guide_Serie = dsd.Guide_Serie
                       AND ord.Guide_Number = dsd.Guide_Number
                       AND ord.IsLastMileReturn = 0
                INNER JOIN dbo.StatusOrder              std WITH (NOLOCK)
                    ON std.StatusOrderId = ord.StatusOrderId
                OUTER APPLY
            (
                SELECT ddd.Guide_Serie
                     , ddd.Guide_Number
                     , ddd.DateCreatedInSystem
                     , ddd.DeliveryAttemptId
                     , tk.SSN_IdUser
                     , tk.SSN_Username
                FROM dbo.DeliveryOrderDetail                      ddd WITH (NOLOCK)
                    LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated
                WHERE ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND ddd.StatusOrderId = 45
                      AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
            )                                           IncidenceTbl
                LEFT JOIN dbo.DeliveryAttempt          att
                    ON att.ID = IncidenceTbl.DeliveryAttemptId
                LEFT JOIN dbo.CatTypeIncidence         cti WITH (NOLOCK)
                    ON cti.IdIncidenceType = att.ID_Incident
                LEFT JOIN dbo.DeliveryOrderAttemptData atd WITH (NOLOCK)
                    ON atd.GuideSerie = ord.Guide_Serie
                       AND atd.GuideNumber = ord.Guide_Number
                LEFT JOIN dbo.ConfirmationOfIncidence  cfi WITH (NOLOCK)
                    ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                INNER JOIN dbo.SenderReceiver          sr WITH (NOLOCK)
                    ON sr.ID = ds.ID_Courier
                LEFT JOIN dbo.Township                 tw WITH (NOLOCK)
                    ON tw.IdTownship = ord.ReceiverIdTownship
                OUTER APPLY
            (
                SELECT TOP 1
                       HBL.IdHubLogistic
                FROM dbo.DumpServiceCoverage                       dum WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                        ON dum.Hub = HBL.HubAbbreviation
                           AND HBL.HubStatus = 1
                WHERE dum.HeaderCode = tw.HeaderCode
            )                                          HUbs
                LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                    ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            WHERE CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
                  AND HUbs.IdHubLogistic IN
                      (
                          SELECT IdHubLogistics FROM @TblHubLogistic
                      )
                  AND ds.Date_Received IS NULL
                  AND IncidenceTbl.SSN_IdUser IS NULL
            GROUP BY ISNULL(ds.ID_Courier, 1)
                   , IncidenceTbl.SSN_IdUser
                   , IncidenceTbl.SSN_Username
                   , (CASE
                          WHEN IncidenceTbl.SSN_IdUser IS NULL THEN
                              'Vendedor Rutero'
                          ELSE
                              'Usuario Desktop'
                      END
                     )
                   , CONCAT(
                               COALESCE(DeliveryBackOffice.dbo.CapitalizeFirstLetter(sr.First_Name), '')
                             , ' '
                             , COALESCE(DeliveryBackOffice.dbo.CapitalizeFirstLetter(sr.Last_Name), '')
                           )
            UNION
            SELECT --TOP 1000
                0                                                                            [IdRoute]
              , tk.SSN_IdUser                                                                [IdUser]
              , tk.SSN_Username                                                              [Username]
              , (CASE
                     WHEN tk.SSN_IdUser IS NULL THEN
                         'Vendedor Rutero'
                     ELSE
                         'Usuario Desktop'
                 END
                )                                                                            [RouteDescription]
              , ''                                                                           [User]
              , SUM(IIF(ord.StatusOrderId = 4, 1, 0))                                        [Pending]
              , SUM(IIF(ord.StatusOrderId = 4, 0, IIF(ddd.DeliveryAttemptId IS NULL, 1, 0))) [Delivered]
              , SUM(IIF(ISNULL(cfi.IsConfirmed, 0) = 1, 1, 0))                               [ConfirmedIncidents]
              , SUM(IIF(ISNULL(cfi.IsConfirmed, 1) = 1, 0, 1))                               [UnconfirmedIncidents]
            FROM dbo.DeliveryOrder                            ord WITH (NOLOCK)
                INNER JOIN dbo.StatusOrder                    std WITH (NOLOCK)
                    ON std.StatusOrderId = ord.StatusOrderId
                INNER JOIN dbo.DeliveryOrderDetail            ddd WITH (NOLOCK)
                    ON ddd.Guide_Serie = ord.Guide_Serie
                       AND ddd.Guide_Number = ord.Guide_Number
                       AND ddd.StatusOrderId = 45
                       AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
                       AND ddd.SystemOrigin = 2 --desktop					
                LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                    ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated


                LEFT JOIN dbo.DeliveryAttempt                 att
                    ON att.ID = ddd.DeliveryAttemptId
                LEFT JOIN dbo.CatTypeIncidence                cti WITH (NOLOCK)
                    ON cti.IdIncidenceType = att.ID_Incident
                LEFT JOIN dbo.DeliveryOrderAttemptData        atd WITH (NOLOCK)
                    ON atd.GuideSerie = ord.Guide_Serie
                       AND atd.GuideNumber = ord.Guide_Number
                LEFT JOIN dbo.ConfirmationOfIncidence         cfi WITH (NOLOCK)
                    ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                LEFT JOIN dbo.Township                        tw WITH (NOLOCK)
                    ON tw.IdTownship = ord.ReceiverIdTownship
                OUTER APPLY
            (
                SELECT TOP 1
                       HBL.IdHubLogistic
                FROM dbo.DumpServiceCoverage                       dum WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                        ON dum.Hub = HBL.HubAbbreviation
                           AND HBL.HubStatus = 1
                WHERE dum.HeaderCode = tw.HeaderCode
            )                                                 HUbs
                LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                    ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            WHERE ord.IsLastMileReturn = 0
                  AND HUbs.IdHubLogistic IN
                      (
                          SELECT IdHubLogistics FROM @TblHubLogistic
                      )
            -- AND ds.Date_Received IS NULL
            GROUP BY
                --ISNULL(ds.ID_Courier, 1),
                tk.SSN_IdUser
              , tk.SSN_Username
              , (CASE
                     WHEN tk.SSN_IdUser IS NULL THEN
                         'Vendedor Rutero'
                     ELSE
                         'Usuario Desktop'
                 END
                );
        END;
        ELSE
        BEGIN
            SELECT --TOP 1000
                IIF(IncidenceTbl.SSN_IdUser IS NULL, ISNULL(ds.ID_Courier, 1), 0)                     [IdRoute]
              , IncidenceTbl.SSN_IdUser                                                               [IdUser]
              , IncidenceTbl.SSN_Username                                                             [Username]
              , (CASE
                     WHEN IncidenceTbl.SSN_IdUser IS NULL THEN
                         'Vendedor Rutero'
                     ELSE
                         'Usuario Desktop'
                 END
                )                                                                                     [RouteDescription]
              , IIF(IncidenceTbl.SSN_IdUser IS NULL
                  , IIF(IncidenceTbl.SSN_IdUser IS NULL
                      , CONCAT(
                                  COALESCE(DeliveryBackOffice.dbo.CapitalizeFirstLetter(sr.First_Name), '')
                                , ' '
                                , COALESCE(DeliveryBackOffice.dbo.CapitalizeFirstLetter(sr.Last_Name), '')
                              )
                      , '')
                  , '')                                                                               [User]
              , SUM(IIF(ord.StatusOrderId = 4, 1, 0))                                                 [Pending]
              , SUM(IIF(ord.StatusOrderId = 4, 0, IIF(IncidenceTbl.DeliveryAttemptId IS NULL, 1, 0))) [Delivered]
              , SUM(IIF(ISNULL(cfi.IsConfirmed, 0) = 1, 1, 0))                                        [ConfirmedIncidents]
              , SUM(IIF(ISNULL(cfi.IsConfirmed, 1) = 1, 0, 1))                                        [UnconfirmedIncidents]
            FROM dbo.DeliveryOrderBySettlement          ds WITH (NOLOCK)
                INNER JOIN dbo.DeliverySettlementDetail dsd WITH (NOLOCK)
                    ON dsd.ID_DeliveryOrderBySettlement = ds.ID
                       AND dsd.RowStatus = 1
                INNER JOIN dbo.DeliveryOrder            ord WITH (NOLOCK)
                    ON ord.Guide_Serie = dsd.Guide_Serie
                       AND ord.Guide_Number = dsd.Guide_Number
                       AND ord.IsLastMileReturn = 0
                INNER JOIN dbo.StatusOrder              std WITH (NOLOCK)
                    ON std.StatusOrderId = ord.StatusOrderId
                OUTER APPLY
            (
                SELECT TOP 1
                       ddd.Guide_Serie
                     , ddd.Guide_Number
                     , ddd.DateCreatedInSystem
                     , ddd.DeliveryAttemptId
                     , tk.SSN_IdUser
                     , tk.SSN_Username
                FROM dbo.DeliveryOrderDetail                      ddd WITH (NOLOCK)
                    LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated
                WHERE ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND ddd.StatusOrderId = 45
                      AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
                ORDER BY CONVERT(DATE, ddd.DateCreatedInSystem) DESC
            )                                           IncidenceTbl
                LEFT JOIN dbo.DeliveryAttempt          att
                    ON att.ID = IncidenceTbl.DeliveryAttemptId
                LEFT JOIN dbo.CatTypeIncidence         cti WITH (NOLOCK)
                    ON cti.IdIncidenceType = att.ID_Incident
                LEFT JOIN dbo.DeliveryOrderAttemptData atd WITH (NOLOCK)
                    ON atd.GuideSerie = ord.Guide_Serie
                       AND atd.GuideNumber = ord.Guide_Number
                LEFT JOIN dbo.ConfirmationOfIncidence  cfi WITH (NOLOCK)
                    ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                INNER JOIN dbo.SenderReceiver          sr WITH (NOLOCK)
                    ON sr.ID = ds.ID_Courier
                LEFT JOIN dbo.Township                 tw WITH (NOLOCK)
                    ON tw.IdTownship = ord.ReceiverIdTownship
                OUTER APPLY
            (
                SELECT TOP 1
                       HBL.IdHubLogistic
                FROM dbo.DumpServiceCoverage                       dum WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                        ON dum.Hub = HBL.HubAbbreviation
                           AND HBL.HubStatus = 1
                WHERE dum.HeaderCode = tw.HeaderCode
            )                                          HUbs
                LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                    ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            WHERE CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
                  AND dsd.Guide_Serie = @GuideSerie
                  AND dsd.Guide_Number = @GuideNumber
                  AND IncidenceTbl.SSN_IdUser IS NULL
            GROUP BY ISNULL(ds.ID_Courier, 1)
                   , IncidenceTbl.SSN_IdUser
                   , IncidenceTbl.SSN_Username
                   , (CASE
                          WHEN IncidenceTbl.SSN_IdUser IS NULL THEN
                              'Vendedor Rutero'
                          ELSE
                              'Usuario Desktop'
                      END
                     )
                   , CONCAT(
                               COALESCE(DeliveryBackOffice.dbo.CapitalizeFirstLetter(sr.First_Name), '')
                             , ' '
                             , COALESCE(DeliveryBackOffice.dbo.CapitalizeFirstLetter(sr.Last_Name), '')
                           )
            UNION
            SELECT --TOP 1000
                0                                                                            [IdRoute]
              , tk.SSN_IdUser                                                                [IdUser]
              , tk.SSN_Username                                                              [Username]
              , (CASE
                     WHEN tk.SSN_IdUser IS NULL THEN
                         'Vendedor Rutero'
                     ELSE
                         'Usuario Desktop'
                 END
                )                                                                            [RouteDescription]
              , ''                                                                           [User]
              , SUM(IIF(ord.StatusOrderId = 4, 1, 0))                                        [Pending]
              , SUM(IIF(ord.StatusOrderId = 4, 0, IIF(ddd.DeliveryAttemptId IS NULL, 1, 0))) [Delivered]
              , SUM(IIF(ISNULL(cfi.IsConfirmed, 0) = 1, 1, 0))                               [ConfirmedIncidents]
              , SUM(IIF(ISNULL(cfi.IsConfirmed, 1) = 1, 0, 1))                               [UnconfirmedIncidents]
            FROM dbo.DeliveryOrder                            ord WITH (NOLOCK)
                INNER JOIN dbo.StatusOrder                    std WITH (NOLOCK)
                    ON std.StatusOrderId = ord.StatusOrderId
                INNER JOIN dbo.DeliveryOrderDetail            ddd WITH (NOLOCK)
                    ON ddd.Guide_Serie = ord.Guide_Serie
                       AND ddd.Guide_Number = ord.Guide_Number
                       AND ddd.StatusOrderId = 45
                       AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
                       AND ddd.SystemOrigin = 2 --desktop					
                LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                    ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated


                LEFT JOIN dbo.DeliveryAttempt                 att
                    ON att.ID = ddd.DeliveryAttemptId
                LEFT JOIN dbo.CatTypeIncidence                cti WITH (NOLOCK)
                    ON cti.IdIncidenceType = att.ID_Incident
                LEFT JOIN dbo.DeliveryOrderAttemptData        atd WITH (NOLOCK)
                    ON atd.GuideSerie = ord.Guide_Serie
                       AND atd.GuideNumber = ord.Guide_Number
                LEFT JOIN dbo.ConfirmationOfIncidence         cfi WITH (NOLOCK)
                    ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                LEFT JOIN dbo.Township                        tw WITH (NOLOCK)
                    ON tw.IdTownship = ord.ReceiverIdTownship
                OUTER APPLY
            (
                SELECT TOP 1
                       HBL.IdHubLogistic
                FROM dbo.DumpServiceCoverage                       dum WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                        ON dum.Hub = HBL.HubAbbreviation
                           AND HBL.HubStatus = 1
                WHERE dum.HeaderCode = tw.HeaderCode
            )                                                 HUbs
                LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                    ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            WHERE ord.Guide_Serie = @GuideSerie
                  AND ord.Guide_Number = @GuideNumber
                  AND ord.IsLastMileReturn = 0
            GROUP BY tk.SSN_IdUser
                   , tk.SSN_Username
                   , (CASE
                          WHEN tk.SSN_IdUser IS NULL THEN
                              'Vendedor Rutero'
                          ELSE
                              'Usuario Desktop'
                      END
                     );
        END;
        --Tabla de detalle de rutas filtrada por hub y guía
        IF (@GuideNumber IS NULL OR @GuideNumber <= 0)
        BEGIN
            SELECT *
            FROM
            (
                SELECT IIF(ord.StatusOrderId = 4, 1, 0)                                                 Pending
                     , IIF(ord.StatusOrderId != 4 AND IncidenceTbl.DeliveryAttemptId IS NULL, 1, 0)     Delivered
                     , IIF(cfi.IsConfirmed = 1, 1, 0)                                                   ConfirmationIncidents
                     , IIF(cfi.IsConfirmed = 0, 1, 0)                                                   UnConfirmationIncidents
                     , ds.ID
                     , ds.ID_Courier
                     , ds.Date_Received
                     , IIF(IncidenceTbl.SSN_IdUser IS NULL, ISNULL(ds.ID_Courier, 1), 0)                [IdRoute]
                     , IncidenceTbl.SSN_IdUser                                                          [IdUser]
                     , IncidenceTbl.SSN_Username                                                        [Username]
                     , (CASE
                            WHEN IncidenceTbl.SSN_IdUser IS NULL THEN
                                'Vendedor Rutero'
                            ELSE
                                'Usuario Desktop'
                        END
                       )                                                                                [RouteDescription]
                     , CONCAT(
                                 COALESCE(DeliveryBackOffice.dbo.CapitalizeFirstLetter(sr.First_Name), '')
                               , ' '
                               , COALESCE(DeliveryBackOffice.dbo.CapitalizeFirstLetter(sr.Last_Name), '')
                             )                                                                          [User]
                     , ord.Guide_Serie                                                                  [GuideSerie]
                     , ord.Guide_Number                                                                 [GuideNumber]
                     , ord.Sender_FirstName + ' ' + ord.Sender_LastName                                 [SenderName]
                     , COALESCE(ord.Receiver_FirstName, '') + ' ' + COALESCE(ord.Receiver_LastName, '') [ReceiverName]
                     , ord.Sender_Phone                                                                 [SenderPhone]
                     , ord.Receiver_Phone                                                               [ReceiverPhone]
                     , ord.Receiver_Address                                                             [ReceiverAddress]
                     , ISNULL(cic.IncidenceTypeName, '')                                                [TypeOfIncident]
                     , cti.NameIncidence                                                                Incident
                     , IncidenceTbl.DateCreatedInSystem                                                 EventDate
                     , (CASE
                            WHEN cti.NameIncidence IS NULL THEN
                                NULL
                            ELSE
                                CONCAT(
                                          CONVERT(
                                                     NVARCHAR(4)
                                                   , IIF(
                                                         atd.GuideDeliveryAttemptCount = atd.GuideDeliveryMaxAttemptCount
                                                       , atd.GuideDeliveryAttemptCount
                                                       , atd.GuideDeliveryAttemptCount + 1)
                                                 )
                                        , '/'
                                        , CONVERT(NVARCHAR(4), atd.GuideDeliveryMaxAttemptCount)
                                      )
                        END
                       )                                                                                [Attempts]
                     , ord.PriceShippment
                     , ord.Collect_OnDelivery                                                           [CollectOnDelivery]
                     , std.OrderDescription
                     , (CASE
                            WHEN cfi.IsConfirmed IS NULL THEN
                                NULL
                            WHEN cfi.IsConfirmed = 0 THEN
                                'Pendiente'
                            ELSE
                     (CASE
                          WHEN cfi.IsDenied = 1 THEN
                              'Rechazada'
                          ELSE
                              'Aprobada'
                      END
                     )
                        END
                       )                                                                                [StatusOfIncident]
                     , HUbs.IdHubLogistic
                     , IIF(ord.StatusOrderId = 4, 1, 0)                                                 Pendiente
                FROM dbo.DeliveryOrderBySettlement          ds WITH (NOLOCK)
                    INNER JOIN dbo.DeliverySettlementDetail dsd WITH (NOLOCK)
                        ON dsd.ID_DeliveryOrderBySettlement = ds.ID
                           AND dsd.RowStatus = 1
                    INNER JOIN dbo.DeliveryOrder            ord WITH (NOLOCK)
                        ON ord.Guide_Serie = dsd.Guide_Serie
                           AND ord.Guide_Number = dsd.Guide_Number
                           AND ord.IsLastMileReturn = 0
                    INNER JOIN dbo.StatusOrder              std WITH (NOLOCK)
                        ON std.StatusOrderId = ord.StatusOrderId
                    OUTER APPLY
                (
                    SELECT TOP 1
                           ddd.Guide_Serie
                         , ddd.Guide_Number
                         , ddd.DateCreatedInSystem
                         , ddd.DeliveryAttemptId
                         , tk.SSN_IdUser
                         , tk.SSN_Username
                    FROM dbo.DeliveryOrderDetail                      ddd WITH (NOLOCK)
                        LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                            ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated
                    WHERE ddd.Guide_Serie = ord.Guide_Serie
                          AND ddd.Guide_Number = ord.Guide_Number
                          AND ddd.StatusOrderId = 45
                          AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
                    ORDER BY CONVERT(DATE, ddd.DateCreatedInSystem) DESC
                )                                           IncidenceTbl
                    LEFT JOIN dbo.DeliveryAttempt          att
                        ON att.ID = IncidenceTbl.DeliveryAttemptId
                    LEFT JOIN dbo.CatTypeIncidence         cti WITH (NOLOCK)
                        ON cti.IdIncidenceType = att.ID_Incident
                    LEFT JOIN dbo.DeliveryOrderAttemptData atd WITH (NOLOCK)
                        ON atd.GuideSerie = ord.Guide_Serie
                           AND atd.GuideNumber = ord.Guide_Number
                    LEFT JOIN dbo.ConfirmationOfIncidence  cfi WITH (NOLOCK)
                        ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                    INNER JOIN dbo.SenderReceiver          sr WITH (NOLOCK)
                        ON sr.ID = ds.ID_Courier
                    LEFT JOIN dbo.Township                 tw WITH (NOLOCK)
                        ON tw.IdTownship = ord.ReceiverIdTownship
                    OUTER APPLY
                (
                    SELECT TOP 1
                           HBL.IdHubLogistic
                    FROM dbo.DumpServiceCoverage                       dum WITH (NOLOCK)
                        INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                            ON dum.Hub = HBL.HubAbbreviation
                               AND HBL.HubStatus = 1
                    WHERE dum.HeaderCode = tw.HeaderCode
                )                                          HUbs
                    LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                        ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
                WHERE CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
                      AND HUbs.IdHubLogistic IN
                          (
                              SELECT IdHubLogistics FROM @TblHubLogistic
                          )
                      AND ds.Date_Received IS NULL
                      AND IncidenceTbl.SSN_IdUser IS NULL
                UNION
                SELECT --TOP 1000
                    IIF(ord.StatusOrderId = 4, 1, 0)                                                 Pending
                  , IIF(ord.StatusOrderId != 4 AND ddd.DeliveryAttemptId IS NULL, 1, 0)              Delivered
                  , IIF(cfi.IsConfirmed = 1, 1, 0)                                                   ConfirmationIncidents
                  , IIF(cfi.IsConfirmed = 0, 1, 0)                                                   UnConfirmationIncidents
                  , 0                                                                                ID
                  , 0                                                                                ID_Courier
                  , NULL                                                                             Date_Received
                  , 0                                                                                [IdRoute]
                  , tk.SSN_IdUser                                                                    [IdUser]
                  , tk.SSN_Username                                                                  [Username]
                  , (CASE
                         WHEN tk.SSN_IdUser IS NULL THEN
                             'Vendedor Rutero'
                         ELSE
                             'Usuario Desktop'
                     END
                    )                                                                                [RouteDescription]
                  , ''                                                                               [User]
                  , ord.Guide_Serie                                                                  [GuideSerie]
                  , ord.Guide_Number                                                                 [GuideNumber]
                  , ord.Sender_FirstName + ' ' + ord.Sender_LastName                                 [SenderName]
                  , COALESCE(ord.Receiver_FirstName, '') + ' ' + COALESCE(ord.Receiver_LastName, '') [ReceiverName]
                  , ord.Sender_Phone                                                                 [SenderPhone]
                  , ord.Receiver_Phone                                                               [ReceiverPhone]
                  , ord.Receiver_Address                                                             [ReceiverAddress]
                  , ISNULL(cic.IncidenceTypeName, '')                                                [TypeOfIncident]
                  , cti.NameIncidence                                                                Incident
                  , ddd.DateCreatedInSystem                                                          EventDate
                  , (CASE
                         WHEN cti.NameIncidence IS NULL THEN
                             NULL
                         ELSE
                             CONCAT(
                                       CONVERT(
                                                  NVARCHAR(4)
                                                , IIF(atd.GuideDeliveryAttemptCount = atd.GuideDeliveryMaxAttemptCount
                                                    , atd.GuideDeliveryAttemptCount
                                                    , atd.GuideDeliveryAttemptCount + 1)
                                              )
                                     , '/'
                                     , CONVERT(NVARCHAR(4), atd.GuideDeliveryMaxAttemptCount)
                                   )
                     END
                    )                                                                                [Attempts]
                  , ord.PriceShippment
                  , ord.Collect_OnDelivery                                                           [CollectOnDelivery]
                  , std.OrderDescription
                  , (CASE
                         WHEN cfi.IsConfirmed IS NULL THEN
                             NULL
                         WHEN cfi.IsConfirmed = 0 THEN
                             'Pendiente'
                         ELSE
                  (CASE
                       WHEN cfi.IsDenied = 1 THEN
                           'Rechazada'
                       ELSE
                           'Aprobada'
                   END
                  )
                     END
                    )                                                                                [StatusOfIncident]
                  , HUbs.IdHubLogistic
                  , IIF(ord.StatusOrderId = 4, 1, 0)                                                 Pendiente
                FROM dbo.DeliveryOrder                            ord WITH (NOLOCK)
                    INNER JOIN dbo.StatusOrder                    std WITH (NOLOCK)
                        ON std.StatusOrderId = ord.StatusOrderId
                    INNER JOIN dbo.DeliveryOrderDetail            ddd WITH (NOLOCK)
                        ON ddd.Guide_Serie = ord.Guide_Serie
                           AND ddd.Guide_Number = ord.Guide_Number
                           AND ddd.StatusOrderId = 45
                           AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
                           AND ddd.SystemOrigin = 2 --desktop					
                    LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated
                    LEFT JOIN dbo.DeliveryAttempt                 att
                        ON att.ID = ddd.DeliveryAttemptId
                    LEFT JOIN dbo.CatTypeIncidence                cti WITH (NOLOCK)
                        ON cti.IdIncidenceType = att.ID_Incident
                    LEFT JOIN dbo.DeliveryOrderAttemptData        atd WITH (NOLOCK)
                        ON atd.GuideSerie = ord.Guide_Serie
                           AND atd.GuideNumber = ord.Guide_Number
                    LEFT JOIN dbo.ConfirmationOfIncidence         cfi WITH (NOLOCK)
                        ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                    LEFT JOIN dbo.Township                        tw WITH (NOLOCK)
                        ON tw.IdTownship = ord.ReceiverIdTownship
                    OUTER APPLY
                (
                    SELECT TOP 1
                           HBL.IdHubLogistic
                    FROM dbo.DumpServiceCoverage                       dum WITH (NOLOCK)
                        INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                            ON dum.Hub = HBL.HubAbbreviation
                               AND HBL.HubStatus = 1
                    WHERE dum.HeaderCode = tw.HeaderCode
                )                                                 HUbs
                    LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                        ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
                WHERE ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND HUbs.IdHubLogistic IN
                          (
                              SELECT IdHubLogistics FROM @TblHubLogistic
                          )
                      AND ord.IsLastMileReturn = 0


       UNION
		  SELECT --TOP 1000
                    IIF(ord.StatusOrderId = 4, 1, 0)                                                 Pending
                  , IIF(ord.StatusOrderId != 4 AND ddd.DeliveryAttemptId IS NULL, 1, 0)              Delivered
                  , IIF(cfi.IsConfirmed = 1, 1, 0)                                                   ConfirmationIncidents
                  , IIF(cfi.IsConfirmed = 0, 1, 0)                                                   UnConfirmationIncidents
                  , 0                                                                                ID
                  , 0                                                                                ID_Courier
                  , NULL                                                                             Date_Received
                  , 0                                                                                [IdRoute]
				  ,att.ID_Incident
                  , IU.RegisterUserID                                                                    [IdUser]
                  , IU.Username                                                                  [Username]
                  , 'Expres Center'                                                                  [RouteDescription]
                  , ''                                                                               [User]
                  , ord.Guide_Serie                                                                  [GuideSerie]
                  , ord.Guide_Number                                                                 [GuideNumber]
                  , ord.Sender_FirstName + ' ' + ord.Sender_LastName                                 [SenderName]
                  , COALESCE(ord.Receiver_FirstName, '') + ' ' + COALESCE(ord.Receiver_LastName, '') [ReceiverName]
                  , ord.Sender_Phone                                                                 [SenderPhone]
                  , ord.Receiver_Phone                                                               [ReceiverPhone]
                  , ord.Receiver_Address                                                             [ReceiverAddress]
                  , ISNULL(cic.IncidenceTypeName, '')                                                [TypeOfIncident]
                  , cti.NameIncidence                                                                Incident
                  , ddd.DateCreatedInSystem                                                          EventDate
                  , (CASE
                         WHEN cti.NameIncidence IS NULL THEN
                             NULL
                         ELSE
                             CONCAT(
                                       CONVERT(
                                                  NVARCHAR(4)
                                                , IIF(atd.GuideDeliveryAttemptCount = atd.GuideDeliveryMaxAttemptCount
                                                    , atd.GuideDeliveryAttemptCount
                                                    , IIF(cti.IncidenceClasificationId <> 1,atd.GuideDeliveryAttemptCount,atd.GuideDeliveryAttemptCount+1))
                                              )
                                     , '/'
                                     , CONVERT(NVARCHAR(4), atd.GuideDeliveryMaxAttemptCount)
                                   )
                     END
                    )                                                                                [Attempts]
                  , ord.PriceShippment
                  , ord.Collect_OnDelivery                                                           [CollectOnDelivery]
                  , std.OrderDescription
                  , (CASE
                         WHEN cfi.IsConfirmed IS NULL THEN
                             NULL
                         WHEN cfi.IsConfirmed = 0 THEN
                             'Pendiente'
                         ELSE
                  (CASE
                       WHEN cfi.IsDenied = 1 THEN
                           'Rechazada'
                       ELSE
                           'Aprobada'
                   END
                  )
                     END
                    )                                                                                [StatusOfIncident]
                  , HUbs.IdHubLogistic
                  , IIF(ord.StatusOrderId = 4, 1, 0)                                                 Pendiente,
                  '' CourierPhone
                FROM dbo.DeliveryOrder                            ord WITH (NOLOCK)
                    INNER JOIN dbo.StatusOrder                    std WITH (NOLOCK)
                        ON std.StatusOrderId = ord.StatusOrderId
                    INNER JOIN dbo.DeliveryOrderDetail            ddd WITH (NOLOCK)
                        ON ddd.Guide_Serie = ord.Guide_Serie
                           AND ddd.Guide_Number = ord.Guide_Number
                           AND ddd.StatusOrderId = 45
                           AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
                           AND ddd.SystemOrigin = 5 --Express center					
                    LEFT JOIN dbo.TokenLog TG  WITH (NOLOCK)
                        ON TG.TknIdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated
				    LEFT JOIN dbo.RegisterUser RS WITH (NOLOCK)
                        ON TG.TknIdUser = RS.UsrIdUser
					LEFT JOIN dbo.InternalUser IU WITH (NOLOCK)
                       ON RS.UsrIdUser = IU.RegisterUserID
                    LEFT JOIN dbo.DeliveryAttempt                 att WITH (NOLOCK)
                        ON att.ID = ddd.DeliveryAttemptId
                    LEFT JOIN dbo.CatTypeIncidence                cti WITH (NOLOCK)
                        ON cti.IdIncidenceType = att.ID_Incident
                    LEFT JOIN dbo.DeliveryOrderAttemptData        atd WITH (NOLOCK)
                        ON atd.GuideSerie = ord.Guide_Serie
                           AND atd.GuideNumber = ord.Guide_Number
                    LEFT JOIN dbo.ConfirmationOfIncidence         cfi WITH (NOLOCK)
                        ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                    LEFT JOIN dbo.Township                        tw WITH (NOLOCK)
                        ON tw.IdTownship = ord.ReceiverIdTownship
                    OUTER APPLY
                (
                    SELECT TOP 1
                           HBL.IdHubLogistic
                    FROM dbo.DumpServiceCoverage                       dum WITH (NOLOCK)
                        INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                            ON dum.Hub = HBL.HubAbbreviation
                               AND HBL.HubStatus = 1
                    WHERE dum.HeaderCode = tw.HeaderCode
                )                                                 HUbs
                    LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                        ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
                WHERE ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND HUbs.IdHubLogistic IN
                          (
                              SELECT IdHubLogistics FROM @TblHubLogistic
                          )
                      AND ord.IsLastMileReturn = 0



            ) Tbl
            ORDER BY Tbl.ID
                   , Tbl.ID_Courier
                   , Tbl.Date_Received;
        END;
        ELSE
        BEGIN
            SELECT *
            FROM
            (
                SELECT --TOP 1000
                    IIF(ord.StatusOrderId = 4, 1, 0)                                                 Pending
                  , IIF(ord.StatusOrderId != 4 AND IncidenceTbl.DeliveryAttemptId IS NULL, 1, 0)     Delivered
                  , IIF(cfi.IsConfirmed = 1, 1, 0)                                                   ConfirmationIncidents
                  , IIF(cfi.IsConfirmed = 0, 1, 0)                                                   UnConfirmationIncidents
                  , ds.ID
                  , ds.ID_Courier
                  , ds.Date_Received
                  , att.ID_Incident
                  , IIF(IncidenceTbl.SSN_IdUser IS NULL, ISNULL(ds.ID_Courier, 1), 0)                [IdRoute]
                  , IncidenceTbl.SSN_IdUser                                                          [IdUser]
                  , IncidenceTbl.SSN_Username                                                        [Username]
                  , (CASE
                         WHEN IncidenceTbl.SSN_IdUser IS NULL THEN
                             'Vendedor Rutero'
                         ELSE
                             'Usuario Desktop'
                     END
                    )                                                                                [RouteDescription]
                  , CONCAT(
                              COALESCE(DeliveryBackOffice.dbo.CapitalizeFirstLetter(sr.First_Name), '')
                            , ' '
                            , COALESCE(DeliveryBackOffice.dbo.CapitalizeFirstLetter(sr.Last_Name), '')
                          )                                                                          [User]
                  , ord.Guide_Serie                                                                  [GuideSerie]
                  , ord.Guide_Number                                                                 [GuideNumber]
                  , ord.Sender_FirstName + ' ' + ord.Sender_LastName                                 [SenderName]
                  , COALESCE(ord.Receiver_FirstName, '') + ' ' + COALESCE(ord.Receiver_LastName, '') [ReceiverName]
                  , ord.Sender_Phone                                                                 [SenderPhone]
                  , ord.Receiver_Phone                                                               [ReceiverPhone]
                  , ord.Receiver_Address                                                             [ReceiverAddress]
                  , ISNULL(cic.IncidenceTypeName, '')                                                [TypeOfIncident]
                  , cti.NameIncidence                                                                Incident
                  , IncidenceTbl.DateCreatedInSystem                                                 EventDate
                  , (CASE
                         WHEN cti.NameIncidence IS NULL THEN
                             NULL
                         ELSE
                             CONCAT(
                                       CONVERT(
                                                  NVARCHAR(4)
                                                , IIF(atd.GuideDeliveryAttemptCount = atd.GuideDeliveryMaxAttemptCount
                                                    , atd.GuideDeliveryAttemptCount
                                                    , atd.GuideDeliveryAttemptCount + 1)
                                              )
                                     , '/'
                                     , CONVERT(NVARCHAR(4), atd.GuideDeliveryMaxAttemptCount)
                                   )
                     END
                    )                                                                                [Attempts]
                  , ord.PriceShippment
                  , ord.Collect_OnDelivery                                                           [CollectOnDelivery]
                  , std.OrderDescription
                  , (CASE
                         WHEN cfi.IsConfirmed IS NULL THEN
                             NULL
                         WHEN cfi.IsConfirmed = 0 THEN
                             'Pendiente'
                         ELSE
                  (CASE
                       WHEN cfi.IsDenied = 1 THEN
                           'Rechazada'
                       ELSE
                           'Aprobada'
                   END
                  )
                     END
                    )                                                                                [StatusOfIncident]
                  , HUbs.IdHubLogistic
                  , IIF(ord.StatusOrderId = 4, 1, 0)                                                 Pendiente
                FROM dbo.DeliveryOrderBySettlement          ds WITH (NOLOCK)
                    INNER JOIN dbo.DeliverySettlementDetail dsd WITH (NOLOCK)
                        ON dsd.ID_DeliveryOrderBySettlement = ds.ID
                           AND dsd.RowStatus = 1
                    INNER JOIN dbo.DeliveryOrder            ord WITH (NOLOCK)
                        ON ord.Guide_Serie = dsd.Guide_Serie
                           AND ord.Guide_Number = dsd.Guide_Number
                           AND ord.IsLastMileReturn = 0
                    INNER JOIN dbo.StatusOrder              std WITH (NOLOCK)
                        ON std.StatusOrderId = ord.StatusOrderId
                    OUTER APPLY
                (
                    SELECT TOP 1
                           ddd.Guide_Serie
                         , ddd.Guide_Number
                         , ddd.DateCreatedInSystem
                         , ddd.DeliveryAttemptId
                         , tk.SSN_IdUser
                         , tk.SSN_Username
                    FROM dbo.DeliveryOrderDetail                      ddd WITH (NOLOCK)
                        LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                            ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated
                    WHERE ddd.Guide_Serie = ord.Guide_Serie
                          AND ddd.Guide_Number = ord.Guide_Number
                          AND ddd.StatusOrderId = 45
                          AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
                    ORDER BY CONVERT(DATE, ddd.DateCreatedInSystem) DESC
                )                                           IncidenceTbl
                    LEFT JOIN dbo.DeliveryAttempt          att
                        ON att.ID = IncidenceTbl.DeliveryAttemptId
                    LEFT JOIN dbo.CatTypeIncidence         cti WITH (NOLOCK)
                        ON cti.IdIncidenceType = att.ID_Incident
                    LEFT JOIN dbo.DeliveryOrderAttemptData atd WITH (NOLOCK)
                        ON atd.GuideSerie = ord.Guide_Serie
                           AND atd.GuideNumber = ord.Guide_Number
                    LEFT JOIN dbo.ConfirmationOfIncidence  cfi WITH (NOLOCK)
                        ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                    INNER JOIN dbo.SenderReceiver          sr WITH (NOLOCK)
                        ON sr.ID = ds.ID_Courier
                    LEFT JOIN dbo.Township                 tw WITH (NOLOCK)
                        ON tw.IdTownship = ord.ReceiverIdTownship
                    OUTER APPLY
                (
                    SELECT TOP 1
                           HBL.IdHubLogistic
                    FROM dbo.DumpServiceCoverage                       dum WITH (NOLOCK)
                        INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                            ON dum.Hub = HBL.HubAbbreviation
                               AND HBL.HubStatus = 1
                    WHERE dum.HeaderCode = tw.HeaderCode
                )                                          HUbs
                    LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                        ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
                WHERE CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
                      AND dsd.Guide_Serie = @GuideSerie
                      AND dsd.Guide_Number = @GuideNumber
                      AND ds.Date_Received IS NULL
                      AND IncidenceTbl.SSN_IdUser IS NULL
                UNION
                SELECT IIF(ord.StatusOrderId = 4, 1, 0)                                                 Pending
                     , IIF(ord.StatusOrderId != 4 AND ddd.DeliveryAttemptId IS NULL, 1, 0)              Delivered
                     , IIF(cfi.IsConfirmed = 1, 1, 0)                                                   ConfirmationIncidents
                     , IIF(cfi.IsConfirmed = 0, 1, 0)                                                   UnConfirmationIncidents
                     , 0                                                                                ID
                     , 0                                                                                ID_Courier
                     , NULL                                                                             Date_Received
                     , att.ID_Incident
                     , 0                                                                                [IdRoute]
                     , tk.SSN_IdUser                                                                    [IdUser]
                     , tk.SSN_Username                                                                  [Username]
                     , (CASE
                            WHEN tk.SSN_IdUser IS NULL THEN
                                'Vendedor Rutero'
                            ELSE
                                'Usuario Desktop'
                        END
                       )                                                                                [RouteDescription]
                     , ''                                                                               [User]
                     , ord.Guide_Serie                                                                  [GuideSerie]
                     , ord.Guide_Number                                                                 [GuideNumber]
                     , ord.Sender_FirstName + ' ' + ord.Sender_LastName                                 [SenderName]
                     , COALESCE(ord.Receiver_FirstName, '') + ' ' + COALESCE(ord.Receiver_LastName, '') [ReceiverName]
                     , ord.Sender_Phone                                                                 [SenderPhone]
                     , ord.Receiver_Phone                                                               [ReceiverPhone]
                     , ord.Receiver_Address                                                             [ReceiverAddress]
                     , ISNULL(cic.IncidenceTypeName, '')                                                [TypeOfIncident]
                     , cti.NameIncidence                                                                Incident
                     , ddd.DateCreatedInSystem                                                          EventDate
                     , (CASE
                            WHEN cti.NameIncidence IS NULL THEN
                                NULL
                            ELSE
                                CONCAT(
                                          CONVERT(
                                                     NVARCHAR(4)
                                                   , IIF(
                                                         atd.GuideDeliveryAttemptCount = atd.GuideDeliveryMaxAttemptCount
                                                       , atd.GuideDeliveryAttemptCount
                                                       , atd.GuideDeliveryAttemptCount + 1)
                                                 )
                                        , '/'
                                        , CONVERT(NVARCHAR(4), atd.GuideDeliveryMaxAttemptCount)
                                      )
                        END
                       )                                                                                [Attempts]
                     , ord.PriceShippment
                     , ord.Collect_OnDelivery                                                           [CollectOnDelivery]
                     , std.OrderDescription
                     , (CASE
                            WHEN cfi.IsConfirmed IS NULL THEN
                                NULL
                            WHEN cfi.IsConfirmed = 0 THEN
                                'Pendiente'
                            ELSE
                     (CASE
                          WHEN cfi.IsDenied = 1 THEN
                              'Rechazada'
                          ELSE
                              'Aprobada'
                      END
                     )
                        END
                       )                                                                                [StatusOfIncident]
                     , HUbs.IdHubLogistic
                     , IIF(ord.StatusOrderId = 4, 1, 0)                                                 Pendiente
                FROM dbo.DeliveryOrder                            ord WITH (NOLOCK)
                    INNER JOIN dbo.StatusOrder                    std WITH (NOLOCK)
                        ON std.StatusOrderId = ord.StatusOrderId
                    INNER JOIN dbo.DeliveryOrderDetail            ddd WITH (NOLOCK)
                        ON ddd.Guide_Serie = ord.Guide_Serie
                           AND ddd.Guide_Number = ord.Guide_Number
                           AND ddd.StatusOrderId = 45
                           AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
                           AND ddd.SystemOrigin = 2 --desktop					
                    LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated
                    LEFT JOIN dbo.DeliveryAttempt                 att
                        ON att.ID = ddd.DeliveryAttemptId
                    LEFT JOIN dbo.CatTypeIncidence                cti WITH (NOLOCK)
                        ON cti.IdIncidenceType = att.ID_Incident
                    LEFT JOIN dbo.DeliveryOrderAttemptData        atd WITH (NOLOCK)
                        ON atd.GuideSerie = ord.Guide_Serie
                           AND atd.GuideNumber = ord.Guide_Number
                    LEFT JOIN dbo.ConfirmationOfIncidence         cfi WITH (NOLOCK)
                        ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                    LEFT JOIN dbo.Township                        tw WITH (NOLOCK)
                        ON tw.IdTownship = ord.ReceiverIdTownship
                    OUTER APPLY
                (
                    SELECT TOP 1
                           HBL.IdHubLogistic
                    FROM dbo.DumpServiceCoverage                       dum WITH (NOLOCK)
                        INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                            ON dum.Hub = HBL.HubAbbreviation
                               AND HBL.HubStatus = 1
                    WHERE dum.HeaderCode = tw.HeaderCode
                )                                                 HUbs
                    LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                        ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
                WHERE CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
                      AND ddd.SystemOrigin = 2 -- desktop
                      AND ord.Guide_Serie = @GuideSerie
                      AND ord.Guide_Number = @GuideNumber
                      AND ord.IsLastMileReturn = 0
            ) Tbl
            ORDER BY Tbl.ID
                   , Tbl.ID_Courier
                   , Tbl.Date_Received;

        END;

    END TRY
    BEGIN CATCH


        SELECT CAST(0 AS BIT)                    AS 'boolResult'
             , ERROR_MESSAGE()                   AS 'DescriptionResult'
             , CONVERT(BIGINT, 0)                AS 'NumTransferID'
             , CONCAT(@GuideSerie, @GuideNumber) AS 'Guide';

    END CATCH;

END;