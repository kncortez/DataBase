-- =============================================
-- Author:		<Bidcar,Herrera>
-- Create date: <2023-09-12>
-- Description:	<Obtener datos para Sistema de Control de Calidad>
-- =============================================
CREATE PROCEDURE [dbo].[GetQualityControlData]
    @GuideSerie NVARCHAR(2) = ''
  , @GuideNumber INT
  , @TblHubLogistic TblHubLogistic READONLY
  , @TblCustomerType TblCustomerType READONLY
  , @TblCustomer     TblCustomer     READONLY
  , @TblVisitPointClient TblVisitPointClient READONLY
  
AS
BEGIN

    SET ARITHABORT ON;
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

		/**********************************************************************************************************************************
		************************************************ CONSTRUCCION ENCABEZADO **********************************************************
		***********************************************************************************************************************************/
        IF (ISNULL(@GuideNumber, 0) <= 0)
        BEGIN
			
			/******************************************************************************************************************************
			****************************************** CONSULTA EN BASE A LISTADO DE HUBS *************************************************
			*******************************************************************************************************************************/

            INSERT INTO @Cards
            (
                [Type]
              , [Description]
              , [Pending]
              , [Delivered]
              , [ConfirmationIncidents]
              , [UnConfirmationIncidents]
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
            FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]			ds WITH (NOLOCK)
                LEFT JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] dsd WITH (NOLOCK)
                    ON dsd.ID_DeliveryOrderBySettlement = ds.ID
                LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder]            ord WITH (NOLOCK)
                    ON ord.Guide_Serie = dsd.Guide_Serie
                    AND ord.Guide_Number = dsd.Guide_Number
                LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrder]				std WITH (NOLOCK)
                    ON std.StatusOrderId = ord.StatusOrderId
				LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData] atd WITH (NOLOCK)
                    ON atd.GuideSerie = ord.Guide_Serie
                    AND atd.GuideNumber = ord.Guide_Number
				 INNER JOIN [DeliveryBackOffice].[dbo].[SenderReceiver]         sr WITH (NOLOCK)
                    ON sr.ID = ds.ID_Courier
				LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]			vpc WITH (NOLOCK)
					ON vpc.CodeOfReference = ord.Sender_ID
				LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]					cus WITH (NOLOCK)
					ON cus.IdCustomer = vpc.CustomerID
                LEFT JOIN [DeliveryBackOffice].[dbo].[Township]					tw WITH (NOLOCK)
                    ON tw.IdTownship = ord.ReceiverIdTownship
				OUTER APPLY
				(
					SELECT TOP 1
						   HBL.IdHubLogistic
					FROM [DeliveryBackOffice].[dbo].[DumpServiceCoverage]       dum WITH (NOLOCK)
					LEFT JOIN [DeliveryBackOffice].[dbo].[HubLogistics]			HBL WITH (NOLOCK)
						ON dum.Hub = HBL.HubAbbreviation
					WHERE ( NOT EXISTS(SELECT 1 FROM @TblHubLogistic) OR HBL.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic ) )
						 AND dum.HeaderCode = tw.HeaderCode
						 AND HBL.HubStatus = 1
				)																HUbs
                OUTER APPLY
				(
					SELECT TOP 1
						   ddd.Guide_Serie
						 , ddd.Guide_Number
						 , ddd.DateCreatedInSystem
						 , ddd.DeliveryAttemptId
						 , tk.SSN_IdUser
						 , tk.SSN_Username
					FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]		ddd WITH (NOLOCK)
						LEFT JOIN [DenariusUser_Dev].[dbo].[LGN_LogByToken]		tk WITH (NOLOCK)
							ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated
					WHERE CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
						  AND ddd.Guide_Serie = ord.Guide_Serie
						  AND ddd.Guide_Number = ord.Guide_Number
						  AND ddd.StatusOrderId = 45
					ORDER BY CONVERT(DATE, ddd.DateCreatedInSystem) DESC
				)																IncidenceTbl
                LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt]          att WITH (NOLOCK)
                    ON att.ID = IncidenceTbl.DeliveryAttemptId
                LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence]         cti WITH (NOLOCK)
                    ON cti.IdIncidenceType =  CONVERT(int, att.ID_Incident)
                LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]  cfi WITH (NOLOCK)
                    ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId                                     
                LEFT JOIN [DeliveryBackOffice].[dbo].[CatIncidenceClasification] cic WITH (NOLOCK)
                    ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            WHERE CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
				  AND dsd.RowStatus = 1
				  AND ds.Date_Received IS NULL
				  AND ord.IsLastMileReturn = 0 --NO INCLUIR DEVOLUCIÓN   
				  AND IncidenceTbl.SSN_IdUser IS NULL
				  AND ( NOT EXISTS (SELECT 1 FROM @TblCustomerType) OR cus.IdCustomerType IN (SELECT IdCustomerType FROM @TblCustomerType) )
				  AND ( NOT EXISTS (SELECT 1 FROM @TblCustomer)    OR cus.IdCustomer IN (SELECT IdCustomer FROM @TblCustomer) )
				  AND ( NOT EXISTS (SELECT 1 FROM @TblVisitPointClient) OR vpc.CodeOfReference IN (SELECT IdVisitPointClient FROM @TblVisitPointClient) )
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
			UNION ALL
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
            FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]						ord WITH (NOLOCK)
				LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData]	atd WITH (NOLOCK)
                    ON	atd.GuideSerie = ord.Guide_Serie
                    AND atd.GuideNumber = ord.Guide_Number
                LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]		ddd WITH (NOLOCK)
                    ON ddd.Guide_Serie = ord.Guide_Serie
                    AND ddd.Guide_Number = ord.Guide_Number
				 LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrder]				std WITH (NOLOCK)
                    ON std.StatusOrderId = ord.StatusOrderId
                LEFT JOIN [DenariusUser_Dev].[dbo].[LGN_LogByToken]				tk WITH (NOLOCK)
                    ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated
                LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt]			att WITH (NOLOCK)
                    ON att.ID = ddd.DeliveryAttemptId
                LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence]         cti WITH (NOLOCK)
                    ON cti.IdIncidenceType = CONVERT(INT, att.ID_Incident)
				LEFT JOIN [DeliveryBackOffice].[dbo].[CatIncidenceClasification]	cic WITH (NOLOCK)
                    ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
                LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]	cfi WITH (NOLOCK)
                    ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
				LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]								vpc WITH (NOLOCK)
					ON vpc.CodeOfReference = ord.Sender_ID
				LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]										cus WITH (NOLOCK)
					ON cus.IdCustomer = vpc.CustomerID
                LEFT JOIN [DeliveryBackOffice].[dbo].[Township]					tw WITH (NOLOCK)
                    ON tw.IdTownship = ord.ReceiverIdTownship
                OUTER APPLY
				(
					SELECT TOP 1
						   HBL.IdHubLogistic
					FROM [DeliveryBackOffice].[dbo].[DumpServiceCoverage]		dum WITH (NOLOCK)
					INNER JOIN [DeliveryBackOffice].[dbo].[HubLogistics]		HBL WITH (NOLOCK)
						ON	dum.Hub = CONVERT(NVARCHAR(50),HBL.HubAbbreviation)						
					WHERE ( NOT EXISTS(SELECT 1 FROM @TblHubLogistic) OR HBL.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic ) )
					  AND dum.HeaderCode = tw.HeaderCode
					  AND HBL.HubStatus = 1
				)																HUbs
            WHERE	CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
					AND	ddd.StatusOrderId = 45
					AND ddd.SystemOrigin in (2) 
					AND ord.IsLastMileReturn = 0
					AND ( NOT EXISTS (SELECT 1 FROM @TblCustomerType) OR cus.IdCustomerType IN (SELECT IdCustomerType FROM @TblCustomerType) )
					AND ( NOT EXISTS (SELECT 1 FROM @TblCustomer)    OR cus.IdCustomer IN (SELECT IdCustomer FROM @TblCustomer) )
					AND ( NOT EXISTS (SELECT 1 FROM @TblVisitPointClient) OR vpc.CodeOfReference IN (SELECT IdVisitPointClient FROM @TblVisitPointClient) )
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

			/*******************************************************************************************************************************
			*********************************************** CONSULTA EN BASE A GUIA ********************************************************
			********************************************************************************************************************************/
            INSERT INTO @Cards
            (
                [Type]
              , [Description]
              , [Pending]
              , [Delivered]
              , [ConfirmationIncidents]
              , [UnConfirmationIncidents]
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
            FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]			ds WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[SenderReceiver]				sr WITH (NOLOCK)
                ON sr.ID = ds.ID_Courier
            LEFT JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]		dsd WITH (NOLOCK)
                ON dsd.ID_DeliveryOrderBySettlement = ds.ID               
            LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder]				ord WITH (NOLOCK)
                ON ord.Guide_Serie = dsd.Guide_Serie
                AND ord.Guide_Number = dsd.Guide_Number
			LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData]		atd WITH (NOLOCK)
                ON  atd.GuideSerie = ord.Guide_Serie
                AND atd.GuideNumber = ord.Guide_Number
			LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrder]					std WITH (NOLOCK)
                ON std.StatusOrderId = ord.StatusOrderId			           
            LEFT JOIN [DeliveryBackOffice].[dbo].[Township]						tw WITH (NOLOCK)
                ON tw.IdTownship = ord.ReceiverIdTownship
            OUTER APPLY
            (
                SELECT TOP 1
                       HBL.IdHubLogistic
                FROM [DeliveryBackOffice].[dbo].[DumpServiceCoverage]           dum WITH (NOLOCK)
                LEFT JOIN [DeliveryBackOffice].[dbo].[HubLogistics]				HBL WITH (NOLOCK)
					ON dum.Hub = HBL.HubAbbreviation
					AND HBL.HubStatus = 1
                WHERE dum.HeaderCode = tw.HeaderCode
            )																	HUbs
            OUTER APPLY
            (
                SELECT TOP 1
                       ddd.Guide_Serie
                     , ddd.Guide_Number
                     , ddd.DateCreatedInSystem
                     , ddd.DeliveryAttemptId
                     , tk.SSN_IdUser
                     , tk.SSN_Username
                FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]		ddd WITH (NOLOCK)
                LEFT JOIN [DenariusUser_Dev].[dbo].[LGN_LogByToken]			tk WITH (NOLOCK)
					ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated
                WHERE CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
					  AND ddd.Guide_Serie = ord.Guide_Serie
                      AND ddd.Guide_Number = ord.Guide_Number
                      AND ddd.StatusOrderId = 45
                ORDER BY ddd.DateCreatedInSystem DESC
            )																IncidenceTbl
            LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt]          att WITH (NOLOCK)
                ON att.ID = IncidenceTbl.DeliveryAttemptId
			LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]		cfi WITH (NOLOCK)
                ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId 
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence]			cti WITH (NOLOCK)
                ON cti.IdIncidenceType = CONVERT(INT,att.ID_Incident)  			
            LEFT JOIN [DeliveryBackOffice].[dbo].[CatIncidenceClasification] cic WITH (NOLOCK)
                ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
            WHERE CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
				  AND ds.Date_Received IS NULL   				  
				  AND dsd.RowStatus = 1
                  AND dsd.Guide_Serie = @GuideSerie
                  AND dsd.Guide_Number = @GuideNumber
				  AND ord.IsLastMileReturn = 0 
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
            FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]								ord WITH (NOLOCK)
				INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]				ddd WITH (NOLOCK)
                    ON ddd.Guide_Serie = ord.Guide_Serie
                    AND ddd.Guide_Number = ord.Guide_Number
				LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData]			atd WITH (NOLOCK)
                    ON atd.GuideSerie = ord.Guide_Serie
                    AND atd.GuideNumber = ord.Guide_Number
				LEFT JOIN [DenariusUser_Dev].[dbo].[LGN_LogByToken]						tk WITH (NOLOCK)
                    ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated 
				LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrder]						std WITH (NOLOCK)
                    ON std.StatusOrderId = ord.StatusOrderId
				LEFT JOIN [DeliveryBackOffice].[dbo].[Township]							tw WITH (NOLOCK)
                    ON tw.IdTownship = ord.ReceiverIdTownship
				OUTER APPLY
				(
					SELECT TOP 1
						   HBL.IdHubLogistic
					FROM [DeliveryBackOffice].[dbo].[DumpServiceCoverage]				dum WITH (NOLOCK)
						LEFT JOIN [DeliveryBackOffice].[dbo].[HubLogistics] HBL WITH (NOLOCK)
						ON dum.Hub = HBL.HubAbbreviation						
					WHERE dum.HeaderCode = tw.HeaderCode						
					  AND HBL.HubStatus = 1
				)																		HUbs
				LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt]					att WITH (NOLOCK)
                    ON att.ID = ddd.DeliveryAttemptId
				LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]			cfi WITH (NOLOCK)
                    ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId  
                LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence]					cti WITH (NOLOCK)
                    ON cti.IdIncidenceType = CONVERT(INT,att.ID_Incident)                
				LEFT JOIN [DeliveryBackOffice].[dbo].[CatIncidenceClasification]		cic WITH (NOLOCK)
                    ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId                                              
            WHERE ord.Guide_Serie = @GuideSerie
				AND ord.Guide_Number = @GuideNumber
				AND ord.IsLastMileReturn = 0
				AND	CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
				AND ddd.StatusOrderId = 45
				AND ddd.SystemOrigin in (2,5) 
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

		/*******************************************************************************************************************************
		************************************************* CREACIÓN DE MATRIZ ***********************************************************
		********************************************* ESTADOS LOGISTICA INVERSA ********************************************************
		********************************************************************************************************************************/

        IF NOT EXISTS (SELECT 1 FROM @Cards WHERE Type = 'EPE')
        BEGIN
            INSERT @Cards
            (
                [Type]
              , [Description]
              , [Pending]
              , [Delivered]
              , [ConfirmationIncidents]
              , [UnConfirmationIncidents]
            )
            VALUES
            ('EPE', 'Entregas Pendientes', 0, 0, 0, 0);
        END;

        IF NOT EXISTS (SELECT 1 FROM @Cards WHERE Type = 'EEF')
        BEGIN
            INSERT @Cards
            (
                [Type]
              , [Description]
              , [Pending]
              , [Delivered]
              , [ConfirmationIncidents]
              , [UnConfirmationIncidents]
            )
            VALUES
            ('EEF', 'Entregas Efectivas', 0, 0, 0, 0);
        END;

        IF NOT EXISTS (SELECT 1 FROM @Cards WHERE Type = 'IPR')
        BEGIN
            INSERT @Cards
            (
                [Type]
              , [Description]
              , [Pending]
              , [Delivered]
              , [ConfirmationIncidents]
              , [UnConfirmationIncidents]
            )
            VALUES
            ('IPR', 'Incidencias Procesadas', 0, 0, 0, 0);
        END;

        IF NOT EXISTS (SELECT 1 FROM @Cards WHERE Type = 'IPP')
        BEGIN
            INSERT @Cards
            (
                [Type]
              , [Description]
              , [Pending]
              , [Delivered]
              , [ConfirmationIncidents]
              , [UnConfirmationIncidents]
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

		/*************** IMPRESION DE LOS RESULTADOS A MOSTRAR EN LAS CARDS ***************/
        SELECT [Type]
			  ,[Description]
			  ,[OrderCard]
			  ,[Pending]
			  ,[Delivered]
			  ,[ConfirmationIncidents]
			  ,[UnConfirmationIncidents]
        FROM
        (
            SELECT [Type]
                 , [Description]
                 , [OrderCard]
                 , SUM(Pending)                 [Pending]
                 , SUM(Delivered)               [Delivered]
                 , SUM(ConfirmationIncidents)   [ConfirmationIncidents]
                 , SUM(UnConfirmationIncidents) [UnConfirmationIncidents]
            FROM @Cards
            GROUP BY [Type]
                   , [Description]
                   , [OrderCard]
        ) AS TBL
        ORDER BY TBL.OrderCard;

        /**********************************************************************************************************************************
		************************************************** CONSTRUCCION DETALLE ***********************************************************
		***********************************************************************************************************************************/
        IF (ISNULL(@GuideNumber, 0) <= 0)
        BEGIN
			
			/******************************************************************************************************************************
			****************************************** CONSULTA EN BASE A LISTADO DE HUBS *************************************************
			*******************************************************************************************************************************/
			
            SELECT 
					[Pending]
					,[Delivered]
					,[ConfirmationIncidents]
					,[UnConfirmationIncidents]
					,[ID]
					,[ID_Courier]
					,[Date_Received]
					,[IdRoute]
					,[ID_Incident]
					,[IdUser]
					,[Username]
					,[RouteDescription]
					,[User]
					,[GuideSerie]
					,[GuideNumber]
					,[SenderName]
					,[ReceiverName]
					,[SenderPhone]
					,[ReceiverPhone]
					,[ReceiverAddress]
					,[TypeOfIncident]
					,[Incident]
					,[EventDate]
					,[Attempts]
					,[PriceShippment]
					,[CollectOnDelivery]
					,[OrderDescription]
					,[StatusOfIncident]
					,[IdHubLogistic]
					,[Pendiente]
					,[CourierPhone]
            FROM
            (
                SELECT IIF(ord.StatusOrderId = 4, 1, 0)                                                 [Pending]
                     , IIF(ord.StatusOrderId != 4 AND IncidenceTbl.DeliveryAttemptId IS NULL, 1, 0)     [Delivered]
                     , IIF(cfi.IsConfirmed = 1, 1, 0)                                                   [ConfirmationIncidents]
                     , IIF(cfi.IsConfirmed = 0, 1, 0)                                                   [UnConfirmationIncidents]
                     , ds.ID																			[ID]
                     , ds.ID_Courier																	[ID_Courier]
                     , ds.Date_Received																	[Date_Received]
                     , IIF(IncidenceTbl.SSN_IdUser IS NULL, ISNULL(ds.ID_Courier, 1), 0)                [IdRoute]
					 , att.ID_Incident																	[ID_Incident]
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
                                 COALESCE(sr.First_Name, '')
                               , ' '
                               , COALESCE(sr.Last_Name, '')
                             )                                                                          [User]
                     , ord.Guide_Serie                                                                  [GuideSerie]
                     , ord.Guide_Number                                                                 [GuideNumber]
                     , ord.Sender_FirstName + ' ' + ord.Sender_LastName                                 [SenderName]
                     , COALESCE(ord.Receiver_FirstName, '') + ' ' + COALESCE(ord.Receiver_LastName, '') [ReceiverName]
                     , ord.Sender_Phone                                                                 [SenderPhone]
                     , ord.Receiver_Phone                                                               [ReceiverPhone]
                     , ord.Receiver_Address                                                             [ReceiverAddress]
                     , ISNULL(cic.IncidenceTypeName, '')                                                [TypeOfIncident]
                     , cti.NameIncidence                                                                [Incident]
                     , IncidenceTbl.DateCreatedInSystem                                                 [EventDate]
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
                                                       , IIF(cti.IncidenceClasificationId <> 1,atd.GuideDeliveryAttemptCount,atd.GuideDeliveryAttemptCount+1))
                                                 )
                                        , '/'
                                        , CONVERT(NVARCHAR(4), atd.GuideDeliveryMaxAttemptCount)
                                      )
                        END
                       )                                                                                [Attempts]
                     , ord.PriceShippment																[PriceShippment]
                     , ord.Collect_OnDelivery                                                           [CollectOnDelivery]
                     , std.OrderDescription																[OrderDescription]
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
                     , HUbs.IdHubLogistic																[IdHubLogistic]
                     , IIF(ord.StatusOrderId = 4, 1, 0)                                                 [Pendiente]
                     , sr.Phone                                                                         [CourierPhone]
                FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]								ds WITH (NOLOCK)
                    LEFT JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]						dsd WITH (NOLOCK)
                        ON dsd.ID_DeliveryOrderBySettlement = ds.ID                   
                    LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder]            					ord WITH (NOLOCK)
                        ON ord.Guide_Serie = dsd.Guide_Serie
                        AND ord.Guide_Number = dsd.Guide_Number
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData]						atd WITH (NOLOCK)
                        ON atd.GuideSerie = ord.Guide_Serie
                        AND atd.GuideNumber = ord.Guide_Number
					INNER JOIN [DeliveryBackOffice].[dbo].[SenderReceiver]								sr WITH (NOLOCK)
                        ON sr.ID = ds.ID_Courier
					LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrder]									std WITH (NOLOCK)
                        ON std.StatusOrderId = ord.StatusOrderId
					LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]								vpc WITH (NOLOCK)
						ON vpc.CodeOfReference = ord.Sender_ID
					LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]										cus WITH (NOLOCK)
						ON cus.IdCustomer = vpc.CustomerID
                    LEFT JOIN [DeliveryBackOffice].[dbo].[Township]										tw  WITH (NOLOCK)
                        ON tw.IdTownship = ord.ReceiverIdTownship                  
					OUTER APPLY
					(
						SELECT TOP 1
							   HBL.IdHubLogistic
						FROM [DeliveryBackOffice].[dbo].[DumpServiceCoverage]							dum WITH (NOLOCK)
						INNER JOIN [DeliveryBackOffice].[dbo].[HubLogistics] HBL WITH (NOLOCK)
							ON  dum.Hub = CONVERT(NVARCHAR, HBL.HubAbbreviation)
						WHERE ( NOT EXISTS(SELECT 1 FROM @TblHubLogistic) OR HBL.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic ) )
							AND HBL.HubStatus = 1
							AND dum.HeaderCode = tw.HeaderCode
					)                                          HUbs
                    OUTER APPLY
					(
						SELECT TOP 1
							   ddd.Guide_Serie
							 , ddd.Guide_Number
							 , ddd.DateCreatedInSystem
							 , ddd.DeliveryAttemptId
							 , tk.SSN_IdUser
							 , tk.SSN_Username
						FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]							ddd WITH (NOLOCK)
							LEFT JOIN [DenariusUser_Dev].[dbo].[LGN_LogByToken] tk WITH (NOLOCK)
								ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated
						WHERE ddd.Guide_Serie = ord.Guide_Serie
							  AND ddd.Guide_Number = ord.Guide_Number
							  AND ddd.StatusOrderId = 45
							  AND CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())							  		
						ORDER BY ddd.DateCreatedInSystem DESC
					)																					IncidenceTbl
                    LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt]								att WITH (NOLOCK)
                        ON att.ID = IncidenceTbl.DeliveryAttemptId
					LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]						cfi WITH (NOLOCK)
                        ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                    LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence]								cti WITH (NOLOCK)
                        ON cti.IdIncidenceType = CONVERT(INT, att.ID_Incident)
					LEFT JOIN [DeliveryBackOffice].[dbo].[CatIncidenceClasification]					cic WITH (NOLOCK)
                        ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId               				
                WHERE CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
					  AND ds.Date_Received IS NULL
					  AND dsd.RowStatus = 1
					  AND ord.IsLastMileReturn = 0
					  AND IncidenceTbl.SSN_IdUser IS NULL
					  AND ( NOT EXISTS (SELECT 1 FROM @TblCustomerType) OR cus.IdCustomerType IN (SELECT IdCustomerType FROM @TblCustomerType) )
					  AND ( NOT EXISTS (SELECT 1 FROM @TblCustomer)    OR cus.IdCustomer IN (SELECT IdCustomer FROM @TblCustomer) )
					  AND ( NOT EXISTS (SELECT 1 FROM @TblVisitPointClient) OR vpc.CodeOfReference IN (SELECT IdVisitPointClient FROM @TblVisitPointClient) )
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
				  , att.ID_Incident
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
                  , IIF(ord.StatusOrderId = 4, 1, 0)                                                 [Pendiente]
                  , ''                                                                               [CourierPhone]
                FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]                            ord WITH (NOLOCK)
					INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]            ddd WITH (NOLOCK)
                        ON ddd.Guide_Serie = ord.Guide_Serie
                        AND ddd.Guide_Number = ord.Guide_Number
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData]        atd WITH (NOLOCK)
                        ON atd.GuideSerie = ord.Guide_Serie
                        AND atd.GuideNumber = ord.Guide_Number
					LEFT JOIN [DenariusUser_Dev].[dbo].[LGN_LogByToken] tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated 
					INNER JOIN [DeliveryBackOffice].[dbo].[StatusOrder]                    std WITH (NOLOCK)
                        ON std.StatusOrderId = ord.StatusOrderId
					LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]				   vpc WITH (NOLOCK)
						ON vpc.CodeOfReference = ord.Sender_ID
					LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]						   cus WITH (NOLOCK)
						ON cus.IdCustomer = vpc.CustomerID
					LEFT JOIN [DeliveryBackOffice].[dbo].[Township]                        tw WITH (NOLOCK)
                        ON tw.IdTownship = ord.ReceiverIdTownship
					OUTER APPLY
					(
						SELECT TOP 1
							   HBL.IdHubLogistic
						FROM [DeliveryBackOffice].[dbo].[DumpServiceCoverage]               dum WITH (NOLOCK)
							INNER JOIN [DeliveryBackOffice].[dbo].[HubLogistics]			HBL WITH (NOLOCK)
								ON dum.Hub = HBL.HubAbbreviation								
						WHERE   ( NOT EXISTS(SELECT 1 FROM @TblHubLogistic) OR HBL.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic ) )
								AND dum.HeaderCode = tw.HeaderCode
								AND HBL.HubStatus = 1
					)																		HUbs                   
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt]					att WITH (NOLOCK)
                        ON att.ID = ddd.DeliveryAttemptId										
					LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence]					cti WITH (NOLOCK)
                        ON cti.IdIncidenceType = CONVERT(INT, att.ID_Incident)
                    LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]			cfi WITH (NOLOCK)
                        ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
					LEFT JOIN [DeliveryBackOffice].[dbo].[CatIncidenceClasification]		cic WITH (NOLOCK)
                        ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId                                                                    
                WHERE	CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
						AND ddd.StatusOrderId = 45 
                        AND ddd.SystemOrigin = 2 --desktop
						AND ord.IsLastMileReturn = 0
						AND ( NOT EXISTS (SELECT 1 FROM @TblCustomerType) OR cus.IdCustomerType IN (SELECT IdCustomerType FROM @TblCustomerType) )
						AND ( NOT EXISTS (SELECT 1 FROM @TblCustomer)    OR cus.IdCustomer IN (SELECT IdCustomer FROM @TblCustomer) )
						AND ( NOT EXISTS (SELECT 1 FROM @TblVisitPointClient) OR vpc.CodeOfReference IN (SELECT IdVisitPointClient FROM @TblVisitPointClient) )
            ) Tbl
			ORDER BY TBL.EventDate
            --ORDER BY Tbl.ID
            --       , Tbl.ID_Courier
            --       , Tbl.Date_Received;
        END;
        ELSE
        BEGIN

			/*******************************************************************************************************************************
			*********************************************** CONSULTA EN BASE A GUIA ********************************************************
			********************************************************************************************************************************/

            SELECT   [Pending]
					,[Delivered]
					,[ConfirmationIncidents]
					,[UnConfirmationIncidents]
					,[ID]
					,[ID_Courier]
					,[Date_Received]
					,[Id_Incident]
					,[IdRoute]
					,[IdUser]
					,[Username]
					,[RouteDescription]
					,[User]
					,[User]
					,[GuideSerie]
					,[GuideNumber]
					,[SenderName]
					,[ReceiverName]
					,[SenderPhone]
					,[ReceiverPhone]
					,[ReceiverAddress]
					,[TypeOfIncident]
					,[Incident]
					,[EventDate]
					,[Attempts]
					,[PriceShippment]
					,[CollectOnDelivery]
					,[OrderDescription]
					,[StatusOfIncident]
					,[IdHubLogistic]
					,[Pendiente]
					,[CourierPhone]
            FROM
            (
                SELECT
                    IIF(ord.StatusOrderId = 4, 1, 0)                                                [Pending]
                  , IIF(ord.StatusOrderId != 4 AND IncidenceTbl.DeliveryAttemptId IS NULL, 1, 0)    [Delivered]
                  , IIF(cfi.IsConfirmed = 1, 1, 0)                                                  [ConfirmationIncidents]
                  , IIF(cfi.IsConfirmed = 0, 1, 0)                                                  [UnConfirmationIncidents]
                  , ds.ID																			[ID]
                  , ds.ID_Courier																	[ID_Courier]
                  , ds.Date_Received																[Date_Received]
                  , att.ID_Incident																	[Id_Incident]
                  , IIF(IncidenceTbl.SSN_IdUser IS NULL, ISNULL(ds.ID_Courier, 1), 0)               [IdRoute]
                  , IncidenceTbl.SSN_IdUser                                                         [IdUser]
                  , IncidenceTbl.SSN_Username                                                       [Username]
                  , (CASE
                         WHEN IncidenceTbl.SSN_IdUser IS NULL THEN
                             'Vendedor Rutero'
                         ELSE
                             'Usuario Desktop'
                     END
                    )                                                                                [RouteDescription]
                  , CONCAT(
                              COALESCE(sr.First_Name, '')
                            , ' '
                            , COALESCE(sr.Last_Name, '')
                          )                                                                          [User]
                  , ord.Guide_Serie                                                                  [GuideSerie]
                  , ord.Guide_Number                                                                 [GuideNumber]
                  , ord.Sender_FirstName + ' ' + ord.Sender_LastName                                 [SenderName]
                  , COALESCE(ord.Receiver_FirstName, '') + ' ' + COALESCE(ord.Receiver_LastName, '') [ReceiverName]
                  , ord.Sender_Phone                                                                 [SenderPhone]
                  , ord.Receiver_Phone                                                               [ReceiverPhone]
                  , ord.Receiver_Address                                                             [ReceiverAddress]
                  , ISNULL(cic.IncidenceTypeName, '')                                                [TypeOfIncident]
                  , cti.NameIncidence                                                                [Incident]
                  , IncidenceTbl.DateCreatedInSystem                                                 [EventDate]
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
                                                       , IIF(cti.IncidenceClasificationId <> 1,atd.GuideDeliveryAttemptCount,atd.GuideDeliveryAttemptCount+1))
                                              )
                                     , '/'
                                     , CONVERT(NVARCHAR(4), atd.GuideDeliveryMaxAttemptCount)
                                   )
                     END
                    )                                                                               [Attempts]
                  , ord.PriceShippment																[PriceShippment]
                  , ord.Collect_OnDelivery                                                          [CollectOnDelivery]
                  , std.OrderDescription															[OrderDescription]
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
                    )                                                                               [StatusOfIncident]
                  , HUbs.IdHubLogistic																[IdHubLogistic]
                  , IIF(ord.StatusOrderId = 4, 1, 0)                                                [Pendiente]
                  , sr.Phone                                                                        [CourierPhone]
                FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]				ds WITH (NOLOCK)
                    INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]	dsd WITH (NOLOCK)
                        ON dsd.ID_DeliveryOrderBySettlement = ds.ID                        
                    INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder]				ord WITH (NOLOCK)
                        ON ord.Guide_Serie = dsd.Guide_Serie
                        AND ord.Guide_Number = dsd.Guide_Number
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData]		atd WITH (NOLOCK)
                        ON atd.GuideSerie = ord.Guide_Serie
                        AND atd.GuideNumber = ord.Guide_Number
                    INNER JOIN [DeliveryBackOffice].[dbo].[StatusOrder]					std WITH (NOLOCK)
                        ON std.StatusOrderId = ord.StatusOrderId
					INNER JOIN [DeliveryBackOffice].[dbo].[SenderReceiver]				sr WITH (NOLOCK)
                        ON sr.ID = ds.ID_Courier
                    LEFT JOIN [DeliveryBackOffice].[dbo].[Township]						tw WITH (NOLOCK)
                        ON tw.IdTownship = ord.ReceiverIdTownship
                    OUTER APPLY
					(
						SELECT TOP 1
							   HBL.IdHubLogistic
						FROM [DeliveryBackOffice].[dbo].[DumpServiceCoverage]           dum WITH (NOLOCK)
							INNER JOIN [DeliveryBackOffice].[dbo].[HubLogistics]		HBL WITH (NOLOCK)
								ON dum.Hub = HBL.HubAbbreviation				
						WHERE dum.HeaderCode = tw.HeaderCode
							AND HBL.HubStatus = 1
					)																	HUbs
                    OUTER APPLY
					(
						SELECT TOP 1
							   ddd.Guide_Serie
							 , ddd.Guide_Number
							 , ddd.DateCreatedInSystem
							 , ddd.DeliveryAttemptId
							 , tk.SSN_IdUser
							 , tk.SSN_Username
						FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]			ddd WITH (NOLOCK)
							LEFT JOIN [DenariusUser_Dev].[dbo].[LGN_LogByToken]			tk WITH (NOLOCK)
								ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated
						WHERE CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
							  AND ddd.Guide_Serie = ord.Guide_Serie
							  AND ddd.Guide_Number = ord.Guide_Number
							  AND ddd.StatusOrderId = 45
						ORDER BY ddd.DateCreatedInSystem DESC
					)																IncidenceTbl
                    LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt]			att WITH (NOLOCK)
                        ON att.ID = IncidenceTbl.DeliveryAttemptId
                    LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]	cfi WITH (NOLOCK)
                        ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
					LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence]         cti WITH (NOLOCK)
                        ON cti.IdIncidenceType = CONVERT(INT, att.ID_Incident)                                    
                    LEFT JOIN [DeliveryBackOffice].[dbo].[CatIncidenceClasification] cic WITH (NOLOCK)
                        ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
                WHERE CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
					  AND ds.Date_Received IS NULL
                      AND dsd.Guide_Serie = @GuideSerie
                      AND dsd.Guide_Number = @GuideNumber
					  AND dsd.RowStatus = 1
					  AND ord.IsLastMileReturn = 0   
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
                     , HUbs.IdHubLogistic																[IdHubLogistic]	
                     , IIF(ord.StatusOrderId = 4, 1, 0)                                                 [Pendiente]
                     , ''                                                                               [CourierPhone]
                FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]								ord WITH (NOLOCK)
                    INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]				ddd WITH (NOLOCK)
                        ON ddd.Guide_Serie = ord.Guide_Serie
                        AND ddd.Guide_Number = ord.Guide_Number
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData]			atd WITH (NOLOCK)
                        ON atd.GuideSerie = ord.Guide_Serie
                        AND atd.GuideNumber = ord.Guide_Number
					INNER JOIN [DeliveryBackOffice].[dbo].[StatusOrder]						std WITH (NOLOCK)
                        ON std.StatusOrderId = ord.StatusOrderId                  			
                    LEFT JOIN [DenariusUser_Dev].[dbo].[LGN_LogByToken] tk WITH (NOLOCK)
                        ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ddd.UserCreated) --ddd.UserCreated
                    LEFT JOIN [DeliveryBackOffice].[dbo].[Township]							tw WITH (NOLOCK)
                        ON tw.IdTownship = ord.ReceiverIdTownship
                    OUTER APPLY
					(
						SELECT TOP 1
							   HBL.IdHubLogistic
						FROM [DeliveryBackOffice].[dbo].[DumpServiceCoverage]				dum WITH (NOLOCK)
							INNER JOIN [DeliveryBackOffice].[dbo].[HubLogistics]			HBL WITH (NOLOCK)
								ON dum.Hub = HBL.HubAbbreviation								
						WHERE dum.HeaderCode = tw.HeaderCode
							AND HBL.HubStatus = 1
					)																		HUbs
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt]					att WITH (NOLOCK)
                        ON att.ID = ddd.DeliveryAttemptId
					LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]			cfi WITH (NOLOCK)
                        ON cfi.IdConfirmationOfIncidence = att.ConfirmationOfIncidenceId
                    LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence]					cti WITH (NOLOCK)
                        ON cti.IdIncidenceType = CONVERT(INT, att.ID_Incident)
                    LEFT JOIN [DeliveryBackOffice].[dbo].[CatIncidenceClasification]		cic WITH (NOLOCK)
                        ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
                WHERE CONVERT(DATE, ddd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
                      AND ddd.SystemOrigin = 2 -- desktop
                      AND ddd.StatusOrderId = 45
					  AND ord.Guide_Serie = @GuideSerie
                      AND ord.Guide_Number = @GuideNumber
                      AND ord.IsLastMileReturn = 0
            ) Tbl
			ORDER BY TBL.EventDate
            --ORDER BY Tbl.ID
            --       , Tbl.ID_Courier
            --       , Tbl.Date_Received;

        END;

    END TRY
    BEGIN CATCH


        SELECT CAST(0 AS BIT)                    AS 'boolResult'
             , ERROR_MESSAGE()                   AS 'DescriptionResult'
             , CONVERT(BIGINT, 0)                AS 'NumTransferID'
             , CONCAT(@GuideSerie, @GuideNumber) AS 'Guide';

    END CATCH;

END;