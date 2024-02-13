-- =============================================
-- Author:		<Bidcar,Herrera>
-- Create date: <2023-09-12>
-- Description:	<Obtener datos para Sistema de Control de Calidad>z
-- =============================================

--declare @p1 dbo.TblHubLogistic
--insert into @p1 values(1)
--insert into @p1 values(22)

--exec dbo.GetQualityControlData @GuideSerie=NULL
--,@GuideNumber = null,@TblHubLogistic=@p1	


CREATE PROCEDURE [dbo].[GetQualityControlData_Performance]
    @GuideSerie NVARCHAR(2) = '',
    @GuideNumber INT,
    @TblHubLogistic TblHubLogistic READONLY
AS
BEGIN
    BEGIN TRY

        IF (@GuideNumber IS NULL OR @GuideNumber <= 0)
        BEGIN
            SELECT --TOP 1000
                IIF(ord.StatusOrderId = 4,
                    'EPE',
                    IIF(
                        ord.StatusOrderId != 4
                        AND IncidenceTbl.DeliveryAttemptId IS NULL,
                        'EEF',
                        IIF(cfi.IsConfirmed = 1, 'IPR', 'IPP'))) [Type],
                IIF(ord.StatusOrderId = 4,
                    'Entregas Pendientes',
                    IIF(
                        ord.StatusOrderId != 4
                        AND IncidenceTbl.DeliveryAttemptId IS NULL,
                        'Entregas Efectivas',
                        IIF(cfi.IsConfirmed = 1, 'Incidencias Procesadas', 'Incidencias Pendientes de Procesar'))) [Description],
                SUM(IIF(ord.StatusOrderId = 4, 1, 0)) [Pending],
                SUM(IIF(ord.StatusOrderId = 4, 0, IIF(IncidenceTbl.DeliveryAttemptId IS NULL, 1, 0))) [Delivered],
                SUM(IIF(ISNULL(cfi.IsConfirmed, 0) = 1, 1, 0)) [ConfirmedIncidents],
                SUM(IIF(ISNULL(cfi.IsConfirmed, 1) = 1, 0, 1)) [UnconfirmedIncidents]
            FROM dbo.DeliveryOrderBySettlement ds WITH (NOLOCK)
                INNER JOIN dbo.DeliverySettlementDetail dsd WITH (NOLOCK)
                    ON dsd.ID_DeliveryOrderBySettlement = ds.ID
                       AND dsd.RowStatus = 1
                INNER JOIN dbo.DeliveryOrder ord WITH (NOLOCK)
                    ON ord.Guide_Serie = dsd.Guide_Serie
                       AND ord.Guide_Number = dsd.Guide_Number
                       AND ord.IsLastMileReturn = 0
                INNER JOIN dbo.StatusOrder std WITH (NOLOCK)
                    ON std.StatusOrderId = ord.StatusOrderId
                OUTER APPLY
            (
                SELECT ddd.Guide_Serie,
                       ddd.Guide_Number,
                       ddd.DateCreatedInSystem,
                       ddd.DeliveryAttemptId,
                       tk.SSN_IdUser,
                       tk.SSN_Username
                FROM dbo.DeliveryOrderDetail ddd WITH (NOLOCK)
                    LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated)--ddd.UserCreated  
                WHERE ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND ddd.StatusOrderId = 45
                      AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE()) 
				/*UNION
				 SELECT ddd.Guide_Serie,
                       ddd.Guide_Number,
                       ddd.DateCreatedInSystem,
                       ddd.DeliveryAttemptId,
                       tk.SSN_IdUser,
                       tk.SSN_Username
                FROM dbo.DeliveryOrderDetail ddd WITH (NOLOCK)
                    LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = ddd.UserCreated
                WHERE ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND ddd.StatusOrderId = 45
                      AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE()) */
            ) IncidenceTbl
                LEFT JOIN dbo.DeliveryAttempt att
                    ON att.ID = IncidenceTbl.DeliveryAttemptId
                LEFT JOIN dbo.CatTypeIncidence cti WITH (NOLOCK)
                    ON cti.IdIncidenceType = att.ID_Incident
                LEFT JOIN dbo.DeliveryOrderAttemptData atd WITH (NOLOCK)
                    ON atd.GuideSerie = ord.Guide_Serie
                       AND atd.GuideNumber = ord.Guide_Number
                LEFT JOIN dbo.ConfirmationOfIncidence cfi WITH (NOLOCK)
                    ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                INNER JOIN dbo.SenderReceiver sr WITH (NOLOCK)
                    ON sr.ID = ds.ID_Courier
                LEFT JOIN dbo.Township tw WITH (NOLOCK)
                    ON tw.IdTownship = ord.ReceiverIdTownship
                OUTER APPLY
            (
                SELECT TOP 1
                       HBL.IdHubLogistic
                FROM dbo.DumpServiceCoverage dum WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                        ON dum.Hub = HBL.HubAbbreviation
                           AND HBL.HubStatus = 1
                WHERE dum.HeaderCode = tw.HeaderCode
            ) HUbs
                LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                    ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            WHERE CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
                  AND HUbs.IdHubLogistic IN
                      (
                          SELECT IdHubLogistics FROM @TblHubLogistic
                      )
                  AND ds.Date_Received IS NULL
            GROUP BY IIF(ord.StatusOrderId = 4,
                         'EPE',
                         IIF(
                             ord.StatusOrderId != 4
                             AND IncidenceTbl.DeliveryAttemptId IS NULL,
                             'EEF',
                             IIF(cfi.IsConfirmed = 1, 'IPR', 'IPP'))),
                     IIF(ord.StatusOrderId = 4,
                         'Entregas Pendientes',
                         IIF(
                             ord.StatusOrderId != 4
                             AND IncidenceTbl.DeliveryAttemptId IS NULL,
                             'Entregas Efectivas',
                             IIF(cfi.IsConfirmed = 1, 'Incidencias Procesadas', 'Incidencias Pendientes de Procesar')));
        END;
        ELSE
        BEGIN
            SELECT --TOP 1000
                IIF(ord.StatusOrderId = 4,
                    'EPE',
                    IIF(
                        ord.StatusOrderId != 4
                        AND IncidenceTbl.DeliveryAttemptId IS NULL,
                        'EEF',
                        IIF(cfi.IsConfirmed = 1, 'IPR', 'IPP'))) [Type],
                IIF(ord.StatusOrderId = 4,
                    'Entregas Pendientes',
                    IIF(
                        ord.StatusOrderId != 4
                        AND IncidenceTbl.DeliveryAttemptId IS NULL,
                        'Entregas Efectivas',
                        IIF(cfi.IsConfirmed = 1, 'Incidencias Procesadas', 'Incidencias Pendientes de Procesar'))) [Description],
                SUM(IIF(ord.StatusOrderId = 4, 1, 0)) [Pending],
                SUM(IIF(ord.StatusOrderId = 4, 0, IIF(IncidenceTbl.DeliveryAttemptId IS NULL, 1, 0))) [Delivered],
                SUM(IIF(ISNULL(cfi.IsConfirmed, 0) = 1, 1, 0)) [ConfirmedIncidents],
                SUM(IIF(ISNULL(cfi.IsConfirmed, 1) = 1, 0, 1)) [UnconfirmedIncidents]
            FROM dbo.DeliveryOrderBySettlement ds WITH (NOLOCK)
                INNER JOIN dbo.DeliverySettlementDetail dsd WITH (NOLOCK)
                    ON dsd.ID_DeliveryOrderBySettlement = ds.ID
                       AND dsd.RowStatus = 1
                INNER JOIN dbo.DeliveryOrder ord WITH (NOLOCK)
                    ON ord.Guide_Serie = dsd.Guide_Serie
                       AND ord.Guide_Number = dsd.Guide_Number
                       AND ord.IsLastMileReturn = 0
                INNER JOIN dbo.StatusOrder std WITH (NOLOCK)
                    ON std.StatusOrderId = ord.StatusOrderId
                OUTER APPLY
            (
                SELECT ddd.Guide_Serie,
                       ddd.Guide_Number,
                       ddd.DateCreatedInSystem,
                       ddd.DeliveryAttemptId,
                       tk.SSN_IdUser,
                       tk.SSN_Username
                FROM dbo.DeliveryOrderDetail ddd WITH (NOLOCK)
                    LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated)--ddd.UserCreated
                WHERE ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND ddd.StatusOrderId = 45
                      AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
				/*UNION
                 SELECT ddd.Guide_Serie,
                       ddd.Guide_Number,
                       ddd.DateCreatedInSystem,
                       ddd.DeliveryAttemptId,
                       tk.SSN_IdUser,
                       tk.SSN_Username
                FROM dbo.DeliveryOrderDetail ddd WITH (NOLOCK)
                    LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = ddd.UserCreated
                WHERE ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND ddd.StatusOrderId = 45
                      AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())*/
            ) IncidenceTbl
                LEFT JOIN dbo.DeliveryAttempt att
                    ON att.ID = IncidenceTbl.DeliveryAttemptId
                LEFT JOIN dbo.CatTypeIncidence cti WITH (NOLOCK)
                    ON cti.IdIncidenceType = att.ID_Incident
                LEFT JOIN dbo.DeliveryOrderAttemptData atd WITH (NOLOCK)
                    ON atd.GuideSerie = ord.Guide_Serie
                       AND atd.GuideNumber = ord.Guide_Number
                LEFT JOIN dbo.ConfirmationOfIncidence cfi WITH (NOLOCK)
                    ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                INNER JOIN dbo.SenderReceiver sr WITH (NOLOCK)
                    ON sr.ID = ds.ID_Courier
                LEFT JOIN dbo.Township tw WITH (NOLOCK)
                    ON tw.IdTownship = ord.ReceiverIdTownship
                OUTER APPLY
            (
                SELECT TOP 1
                       HBL.IdHubLogistic
                FROM dbo.DumpServiceCoverage dum WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                        ON dum.Hub = HBL.HubAbbreviation
                           AND HBL.HubStatus = 1
                WHERE dum.HeaderCode = tw.HeaderCode
            ) HUbs
                LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                    ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            WHERE CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
                  AND dsd.Guide_Serie = @GuideSerie
                  AND dsd.Guide_Number = @GuideNumber
                  AND ds.Date_Received IS NULL
            GROUP BY IIF(ord.StatusOrderId = 4,
                         'EPE',
                         IIF(
                             ord.StatusOrderId != 4
                             AND IncidenceTbl.DeliveryAttemptId IS NULL,
                             'EEF',
                             IIF(cfi.IsConfirmed = 1, 'IPR', 'IPP'))),
                     IIF(ord.StatusOrderId = 4,
                         'Entregas Pendientes',
                         IIF(
                             ord.StatusOrderId != 4
                             AND IncidenceTbl.DeliveryAttemptId IS NULL,
                             'Entregas Efectivas',
                             IIF(cfi.IsConfirmed = 1, 'Incidencias Procesadas', 'Incidencias Pendientes de Procesar')));
        END;
        -- Q2
        IF (@GuideNumber IS NULL OR @GuideNumber <= 0)
        BEGIN
            SELECT --TOP 1000
                ISNULL(ds.ID_Courier, 1) [IdRoute],
                IncidenceTbl.SSN_IdUser [IdUser],
                IncidenceTbl.SSN_Username [Username],
                (CASE
                     WHEN IncidenceTbl.SSN_IdUser IS NULL THEN
                         'Vendedor Rutero'
                     ELSE
                         'Usuario Desktop'
                 END
                ) [RouteDescription],
                CONCAT(sr.First_Name, sr.Last_Name) [User],
                SUM(IIF(ord.StatusOrderId = 4, 1, 0)) [Pending],
                SUM(IIF(ord.StatusOrderId = 4, 0, IIF(IncidenceTbl.DeliveryAttemptId IS NULL, 1, 0))) [Delivered],
                SUM(IIF(ISNULL(cfi.IsConfirmed, 0) = 1, 1, 0)) [ConfirmedIncidents],
                SUM(IIF(ISNULL(cfi.IsConfirmed, 1) = 1, 0, 1)) [UnconfirmedIncidents]
            FROM dbo.DeliveryOrderBySettlement ds WITH (NOLOCK)
                INNER JOIN dbo.DeliverySettlementDetail dsd WITH (NOLOCK)
                    ON dsd.ID_DeliveryOrderBySettlement = ds.ID
                       AND dsd.RowStatus = 1
                INNER JOIN dbo.DeliveryOrder ord WITH (NOLOCK)
                    ON ord.Guide_Serie = dsd.Guide_Serie
                       AND ord.Guide_Number = dsd.Guide_Number
                       AND ord.IsLastMileReturn = 0
                INNER JOIN dbo.StatusOrder std WITH (NOLOCK)
                    ON std.StatusOrderId = ord.StatusOrderId
                OUTER APPLY
            (
                SELECT ddd.Guide_Serie,
                       ddd.Guide_Number,
                       ddd.DateCreatedInSystem,
                       ddd.DeliveryAttemptId,
                       tk.SSN_IdUser,
                       tk.SSN_Username
                FROM dbo.DeliveryOrderDetail ddd WITH (NOLOCK)
                    LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated)--ddd.UserCreated
                WHERE ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND ddd.StatusOrderId = 45
                      AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
				/*UNION
				 SELECT ddd.Guide_Serie,
                       ddd.Guide_Number,
                       ddd.DateCreatedInSystem,
                       ddd.DeliveryAttemptId,
                       tk.SSN_IdUser,
                       tk.SSN_Username
                FROM dbo.DeliveryOrderDetail ddd WITH (NOLOCK)
                    LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = ddd.UserCreated
                WHERE ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND ddd.StatusOrderId = 45
                      AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())*/
            ) IncidenceTbl
                LEFT JOIN dbo.DeliveryAttempt att
                    ON att.ID = IncidenceTbl.DeliveryAttemptId
                LEFT JOIN dbo.CatTypeIncidence cti WITH (NOLOCK)
                    ON cti.IdIncidenceType = att.ID_Incident
                LEFT JOIN dbo.DeliveryOrderAttemptData atd WITH (NOLOCK)
                    ON atd.GuideSerie = ord.Guide_Serie
                       AND atd.GuideNumber = ord.Guide_Number
                LEFT JOIN dbo.ConfirmationOfIncidence cfi WITH (NOLOCK)
                    ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                INNER JOIN dbo.SenderReceiver sr WITH (NOLOCK)
                    ON sr.ID = ds.ID_Courier
                LEFT JOIN dbo.Township tw WITH (NOLOCK)
                    ON tw.IdTownship = ord.ReceiverIdTownship
                OUTER APPLY
            (
                SELECT TOP 1
                       HBL.IdHubLogistic
                FROM dbo.DumpServiceCoverage dum WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                        ON dum.Hub = HBL.HubAbbreviation
                           AND HBL.HubStatus = 1
                WHERE dum.HeaderCode = tw.HeaderCode
            ) HUbs
                LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                    ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            WHERE CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
                  AND HUbs.IdHubLogistic IN
                      (
                          SELECT IdHubLogistics FROM @TblHubLogistic
                      )
                  AND ds.Date_Received IS NULL
            GROUP BY ISNULL(ds.ID_Courier, 1),
                     IncidenceTbl.SSN_IdUser,
                     IncidenceTbl.SSN_Username,
                     (CASE
                          WHEN IncidenceTbl.SSN_IdUser IS NULL THEN
                              'Vendedor Rutero'
                          ELSE
                              'Usuario Desktop'
                      END
                     ),
                     CONCAT(sr.First_Name, sr.Last_Name);
        END;
        ELSE
        BEGIN
            SELECT --TOP 1000
                ISNULL(ds.ID_Courier, 1) [IdRoute],
                IncidenceTbl.SSN_IdUser [IdUser],
                IncidenceTbl.SSN_Username [Username],
                (CASE
                     WHEN IncidenceTbl.SSN_IdUser IS NULL THEN
                         'Vendedor Rutero'
                     ELSE
                         'Usuario Desktop'
                 END
                ) [RouteDescription],
                CONCAT(sr.First_Name, sr.Last_Name) [User],
                SUM(IIF(ord.StatusOrderId = 4, 1, 0)) [Pending],
                SUM(IIF(ord.StatusOrderId = 4, 0, IIF(IncidenceTbl.DeliveryAttemptId IS NULL, 1, 0))) [Delivered],
                SUM(IIF(ISNULL(cfi.IsConfirmed, 0) = 1, 1, 0)) [ConfirmedIncidents],
                SUM(IIF(ISNULL(cfi.IsConfirmed, 1) = 1, 0, 1)) [UnconfirmedIncidents]
            FROM dbo.DeliveryOrderBySettlement ds WITH (NOLOCK)
                INNER JOIN dbo.DeliverySettlementDetail dsd WITH (NOLOCK)
                    ON dsd.ID_DeliveryOrderBySettlement = ds.ID
                       AND dsd.RowStatus = 1
                INNER JOIN dbo.DeliveryOrder ord WITH (NOLOCK)
                    ON ord.Guide_Serie = dsd.Guide_Serie
                       AND ord.Guide_Number = dsd.Guide_Number
                       AND ord.IsLastMileReturn = 0
                INNER JOIN dbo.StatusOrder std WITH (NOLOCK)
                    ON std.StatusOrderId = ord.StatusOrderId
                OUTER APPLY
            (
                SELECT ddd.Guide_Serie,
                       ddd.Guide_Number,
                       ddd.DateCreatedInSystem,
                       ddd.DeliveryAttemptId,
                       tk.SSN_IdUser,
                       tk.SSN_Username
                FROM dbo.DeliveryOrderDetail ddd WITH (NOLOCK)
                    LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated)--ddd.UserCreated
                WHERE ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND ddd.StatusOrderId = 45
                      AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
				/*UNION
				 SELECT ddd.Guide_Serie,
                       ddd.Guide_Number,
                       ddd.DateCreatedInSystem,
                       ddd.DeliveryAttemptId,
                       tk.SSN_IdUser,
                       tk.SSN_Username
                FROM dbo.DeliveryOrderDetail ddd WITH (NOLOCK)
                    LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = ddd.UserCreated
                WHERE ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND ddd.StatusOrderId = 45
                      AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())*/
            ) IncidenceTbl
                LEFT JOIN dbo.DeliveryAttempt att
                    ON att.ID = IncidenceTbl.DeliveryAttemptId
                LEFT JOIN dbo.CatTypeIncidence cti WITH (NOLOCK)
                    ON cti.IdIncidenceType = att.ID_Incident
                LEFT JOIN dbo.DeliveryOrderAttemptData atd WITH (NOLOCK)
                    ON atd.GuideSerie = ord.Guide_Serie
                       AND atd.GuideNumber = ord.Guide_Number
                LEFT JOIN dbo.ConfirmationOfIncidence cfi WITH (NOLOCK)
                    ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                INNER JOIN dbo.SenderReceiver sr WITH (NOLOCK)
                    ON sr.ID = ds.ID_Courier
                LEFT JOIN dbo.Township tw WITH (NOLOCK)
                    ON tw.IdTownship = ord.ReceiverIdTownship
                OUTER APPLY
            (
                SELECT TOP 1
                       HBL.IdHubLogistic
                FROM dbo.DumpServiceCoverage dum WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                        ON dum.Hub = HBL.HubAbbreviation
                           AND HBL.HubStatus = 1
                WHERE dum.HeaderCode = tw.HeaderCode
            ) HUbs
                LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                    ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            WHERE CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
                  AND dsd.Guide_Serie = @GuideSerie
                  AND dsd.Guide_Number = @GuideNumber
            GROUP BY ISNULL(ds.ID_Courier, 1),
                     IncidenceTbl.SSN_IdUser,
                     IncidenceTbl.SSN_Username,
                     (CASE
                          WHEN IncidenceTbl.SSN_IdUser IS NULL THEN
                              'Vendedor Rutero'
                          ELSE
                              'Usuario Desktop'
                      END
                     ),
                     CONCAT(sr.First_Name, sr.Last_Name);
        END;



        --Q3
        IF (@GuideNumber IS NULL OR @GuideNumber <= 0)
        BEGIN
            SELECT --TOP 1000
                ISNULL(ds.ID_Courier, 1) [IdRoute],
                IncidenceTbl.SSN_IdUser [IdUser],
                IncidenceTbl.SSN_Username [Username],
                (CASE
                     WHEN IncidenceTbl.SSN_IdUser IS NULL THEN
                         'Vendedor Rutero'
                     ELSE
                         'Usuario Desktop'
                 END
                ) [RouteDescription],
                CONCAT(sr.First_Name, sr.Last_Name) [User],
                ord.Guide_Serie [GuideSerie],
                ord.Guide_Number [GuideNumber],
                ord.Sender_FirstName + ' ' + ord.Sender_LastName [SenderName],
                ord.Receiver_FirstName + ' ' + ord.Receiver_LastName [ReceiverName],
                ord.Sender_Phone [SenderPhone],
                ord.Receiver_Phone [ReceiverPhone],
                ord.Receiver_Address [ReceiverAddress],
                ISNULL(cic.IncidenceTypeName, 'N/A') [TypeOfIncident],
                cti.NameIncidence Incident,
                IncidenceTbl.DateCreatedInSystem EventDate,
                (CASE
                     WHEN cti.NameIncidence IS NULL THEN
                         NULL
                     ELSE
                         CONCAT(
                                   CONVERT(NVARCHAR(4), atd.GuideDeliveryAttemptCount + 1),
                                   '/',
                                   CONVERT(NVARCHAR(4), atd.GuideDeliveryMaxAttemptCount)
                               )
                 END
                ) [Attempts],
                --, atd.GuideDeliveryAttemptCount
                --, atd.GuideDeliveryMaxAttemptCount
                ord.PriceShippment,
                ord.Collect_OnDelivery [CollectOnDelivery],
                std.OrderDescription,
                (CASE
                     WHEN cfi.IsConfirmed IS NULL THEN
                         NULL
                     WHEN cfi.IsConfirmed = 0 THEN
                         'Pendiente'
                     ELSE
                (CASE
                     WHEN cfi.IsValid = 1 THEN
                         'Real'
                     ELSE
                         'Falsa'
                 END
                )
                 END
                ) [StatusOfIncident],
                HUbs.IdHubLogistic,
                IIF(ord.StatusOrderId = 4, 1, 0) Pendiente
            FROM dbo.DeliveryOrderBySettlement ds WITH (NOLOCK)
                INNER JOIN dbo.DeliverySettlementDetail dsd WITH (NOLOCK)
                    ON dsd.ID_DeliveryOrderBySettlement = ds.ID
                       AND dsd.RowStatus = 1
                INNER JOIN dbo.DeliveryOrder ord WITH (NOLOCK)
                    ON ord.Guide_Serie = dsd.Guide_Serie
                       AND ord.Guide_Number = dsd.Guide_Number
                       AND ord.IsLastMileReturn = 0
                INNER JOIN dbo.StatusOrder std WITH (NOLOCK)
                    ON std.StatusOrderId = ord.StatusOrderId
                OUTER APPLY
            (
                SELECT ddd.Guide_Serie,
                       ddd.Guide_Number,
                       ddd.DateCreatedInSystem,
                       ddd.DeliveryAttemptId,
                       tk.SSN_IdUser,
                       tk.SSN_Username
                FROM dbo.DeliveryOrderDetail ddd WITH (NOLOCK)
                    LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated)--ddd.UserCreated
                WHERE ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND ddd.StatusOrderId = 45
                      AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
				/*UNION
                 SELECT ddd.Guide_Serie,
                       ddd.Guide_Number,
                       ddd.DateCreatedInSystem,
                       ddd.DeliveryAttemptId,
                       tk.SSN_IdUser,
                       tk.SSN_Username
                FROM dbo.DeliveryOrderDetail ddd WITH (NOLOCK)
                    LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = ddd.UserCreated
                WHERE ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND ddd.StatusOrderId = 45
                      AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())*/
            ) IncidenceTbl
                LEFT JOIN dbo.DeliveryAttempt att
                    ON att.ID = IncidenceTbl.DeliveryAttemptId
                LEFT JOIN dbo.CatTypeIncidence cti WITH (NOLOCK)
                    ON cti.IdIncidenceType = att.ID_Incident
                LEFT JOIN dbo.DeliveryOrderAttemptData atd WITH (NOLOCK)
                    ON atd.GuideSerie = ord.Guide_Serie
                       AND atd.GuideNumber = ord.Guide_Number
                LEFT JOIN dbo.ConfirmationOfIncidence cfi WITH (NOLOCK)
                    ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                INNER JOIN dbo.SenderReceiver sr WITH (NOLOCK)
                    ON sr.ID = ds.ID_Courier
                LEFT JOIN dbo.Township tw WITH (NOLOCK)
                    ON tw.IdTownship = ord.ReceiverIdTownship
                OUTER APPLY
            (
                SELECT TOP 1
                       HBL.IdHubLogistic
                FROM dbo.DumpServiceCoverage dum WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                        ON dum.Hub = HBL.HubAbbreviation
                           AND HBL.HubStatus = 1
                WHERE dum.HeaderCode = tw.HeaderCode
            ) HUbs
                LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                    ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            WHERE CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
                  AND HUbs.IdHubLogistic IN
                      (
                          SELECT IdHubLogistics FROM @TblHubLogistic
                      )
                  AND ds.Date_Received IS NULL
            ORDER BY ds.ID,
                     ds.ID_Courier,
                     ds.Date_Received;
        END;
        ELSE
        BEGIN
            SELECT --TOP 1000
                att.ID_Incident,
                ISNULL(ds.ID_Courier, 1) [IdRoute],
                IncidenceTbl.SSN_IdUser [IdUser],
                IncidenceTbl.SSN_Username [Username],
                (CASE
                     WHEN IncidenceTbl.SSN_IdUser IS NULL THEN
                         'Vendedor Rutero'
                     ELSE
                         'Usuario Desktop'
                 END
                ) [RouteDescription],
                CONCAT(sr.First_Name, sr.Last_Name) [User],
                ord.Guide_Serie [GuideSerie],
                ord.Guide_Number [GuideNumber],
                ord.Sender_FirstName + ' ' + ord.Sender_LastName [SenderName],
                ord.Receiver_FirstName + ' ' + ord.Receiver_LastName [ReceiverName],
                ord.Sender_Phone [SenderPhone],
                ord.Receiver_Phone [ReceiverPhone],
                ord.Receiver_Address [ReceiverAddress],
                ISNULL(cic.IncidenceTypeName, 'N/A') [TypeOfIncident],
                cti.NameIncidence Incident,
                IncidenceTbl.DateCreatedInSystem EventDate,
                (CASE
                     WHEN cti.NameIncidence IS NULL THEN
                         NULL
                     ELSE
                         CONCAT(
                                   CONVERT(NVARCHAR(4), atd.GuideDeliveryAttemptCount + 1),
                                   '/',
                                   CONVERT(NVARCHAR(4), atd.GuideDeliveryMaxAttemptCount)
                               )
                 END
                ) [Attempts],
                --, atd.GuideDeliveryAttemptCount
                --, atd.GuideDeliveryMaxAttemptCount
                ord.PriceShippment,
                ord.Collect_OnDelivery [CollectOnDelivery],
                std.OrderDescription,
                (CASE
                     WHEN cfi.IsConfirmed IS NULL THEN
                         NULL
                     WHEN cfi.IsConfirmed = 0 THEN
                         'Pendiente'
                     ELSE
                (CASE
                     WHEN cfi.IsValid = 1 THEN
                         'Real'
                     ELSE
                         'Falsa'
                 END
                )
                 END
                ) [StatusOfIncident],
                HUbs.IdHubLogistic,
                IIF(ord.StatusOrderId = 4, 1, 0) Pendiente
            FROM dbo.DeliveryOrderBySettlement ds WITH (NOLOCK)
                INNER JOIN dbo.DeliverySettlementDetail dsd WITH (NOLOCK)
                    ON dsd.ID_DeliveryOrderBySettlement = ds.ID
                       AND dsd.RowStatus = 1
                INNER JOIN dbo.DeliveryOrder ord WITH (NOLOCK)
                    ON ord.Guide_Serie = dsd.Guide_Serie
                       AND ord.Guide_Number = dsd.Guide_Number
                       AND ord.IsLastMileReturn = 0
                INNER JOIN dbo.StatusOrder std WITH (NOLOCK)
                    ON std.StatusOrderId = ord.StatusOrderId
                OUTER APPLY
            (
                SELECT ddd.Guide_Serie,
                       ddd.Guide_Number,
                       ddd.DateCreatedInSystem,
                       ddd.DeliveryAttemptId,
                       tk.SSN_IdUser,
                       tk.SSN_Username
                FROM dbo.DeliveryOrderDetail ddd WITH (NOLOCK)
                    LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated)--ddd.UserCreated
                WHERE ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND ddd.StatusOrderId = 45
                      AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
				/*UNION
                SELECT ddd.Guide_Serie,
                       ddd.Guide_Number,
                       ddd.DateCreatedInSystem,
                       ddd.DeliveryAttemptId,
                       tk.SSN_IdUser,
                       tk.SSN_Username
                FROM dbo.DeliveryOrderDetail ddd WITH (NOLOCK)
                    LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = ddd.UserCreated
                WHERE ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND ddd.StatusOrderId = 45
                      AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())*/
            ) IncidenceTbl
                LEFT JOIN dbo.DeliveryAttempt att
                    ON att.ID = IncidenceTbl.DeliveryAttemptId
                LEFT JOIN dbo.CatTypeIncidence cti WITH (NOLOCK)
                    ON cti.IdIncidenceType = att.ID_Incident
                LEFT JOIN dbo.DeliveryOrderAttemptData atd WITH (NOLOCK)
                    ON atd.GuideSerie = ord.Guide_Serie
                       AND atd.GuideNumber = ord.Guide_Number
                LEFT JOIN dbo.ConfirmationOfIncidence cfi WITH (NOLOCK)
                    ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                INNER JOIN dbo.SenderReceiver sr WITH (NOLOCK)
                    ON sr.ID = ds.ID_Courier
                LEFT JOIN dbo.Township tw WITH (NOLOCK)
                    ON tw.IdTownship = ord.ReceiverIdTownship
                OUTER APPLY
            (
                SELECT TOP 1
                       HBL.IdHubLogistic
                FROM dbo.DumpServiceCoverage dum WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.HubLogistics HBL WITH (NOLOCK)
                        ON dum.Hub = HBL.HubAbbreviation
                           AND HBL.HubStatus = 1
                WHERE dum.HeaderCode = tw.HeaderCode
            ) HUbs
                LEFT JOIN dbo.CatIncidenceClasification cic WITH (NOLOCK)
                    ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            WHERE CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
                  AND dsd.Guide_Serie = @GuideSerie
                  AND dsd.Guide_Number = @GuideNumber
                  AND ds.Date_Received IS NULL
            ORDER BY ds.ID,
                     ds.ID_Courier,
                     ds.Date_Received;
        END;


    END TRY
    BEGIN CATCH


        SELECT CAST(0 AS BIT) AS 'boolResult',
               ERROR_MESSAGE() AS 'DescriptionResult',
               CONVERT(BIGINT, 0) AS 'NumTransferID',
               CONCAT(@GuideSerie, @GuideNumber) AS 'Guide';

    END CATCH;

END;