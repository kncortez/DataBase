-- =============================================
-- Author:		<Bidcar,Herrera>
-- Create date: <2023-09-12>
-- Description:	<Obtener datos para Sistema de Control de Calidad>
-- =============================================
-- Modified:	<Brandon,Pedroza>
-- Create date: <2024-07-08>
-- Description:	<Se agregan campos que indican el simbolo de moneda que tiene asociada la guia>
-- =============================================
CREATE PROCEDURE [dbo].[GetQualityControlData]
    @GuideSerie NVARCHAR(2) = ''
  , @GuideNumber INT
  , @TblHubLogistic TblHubLogistic   READONLY
  , @TblCustomerType TblCustomerType READONLY
  , @TblCustomer     TblCustomer     READONLY
  , @TblVisitPointClient TblVisitPointClient READONLY
  , @TblIncidenceType TblIncidenceType READONLY
AS
BEGIN

    SET ARITHABORT ON;
    BEGIN TRY
        
		SELECT	--top 100
				[Type]
			   ,[Description]
			   ,[OrderCard]
			   ,[CARDS].[Pending]
			   ,[CARDS].[Delivered]
			   ,[CARDS].[ConfirmationIncidents]
			   ,SUM([CARDS].[UnConfirmationIncidents]) [UnConfirmationIncidents]
		FROM
			(
				SELECT 'EPE' [Type], 'Entregas Pendientes'  [Description], 1 [OrderCard], COUNT(1) [Pending], 0 [Delivered], 0 [ConfirmationIncidents], 0 [UnConfirmationIncidents]
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]								ds WITH (NOLOCK)
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]						dsd WITH (NOLOCK)
						ON dsd.ID_DeliveryOrderBySettlement = ds.ID
					CROSS APPLY
					(
						SELECT TOP 1
							   ordd.Guide_Serie
							 , ordd.Guide_Number
							 , ord.Sender_ID
							 , ord.ReceiverIdTownship
						FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]									ord WITH (NOLOCK)
							INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]					ordd WITH (NOLOCK)
								ON  ordd.Guide_Serie  = ord.Guide_Serie
								AND ordd.Guide_Number = ord.Guide_Number
						WHERE	ord.IsLastMileReturn	= 0 --NO INCLUIR DEVOLUCIÓN
								AND ordd.Guide_Serie	= dsd.Guide_Serie
								AND ordd.Guide_Number	= dsd.Guide_Number
								AND ord.StatusOrderId	= 4
								AND CONVERT(DATE, ordd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
						ORDER BY ordd.DateCreatedInSystem DESC
					)																					del
					LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]								vpc WITH (NOLOCK)
							ON vpc.CodeOfReference = del.Sender_ID
					LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]										cus WITH (NOLOCK)
							ON cus.IdCustomer = vpc.CustomerID
					LEFT JOIN [DeliveryBackOffice].[dbo].[Township]										tw WITH (NOLOCK)
						ON tw.IdTownship = del.ReceiverIdTownship
					OUTER APPLY
					(
						SELECT TOP 1
								HBL.IdHubLogistic
						FROM dbo.DumpServiceCoverage													dum WITH (NOLOCK)
							INNER JOIN DeliveryBackOffice.dbo.HubLogistics								HBL WITH (NOLOCK)
								ON dum.Hub = HBL.HubAbbreviation
							    AND HBL.HubStatus = 1
						WHERE dum.HeaderCode = tw.HeaderCode
					)																					HUbs
				WHERE	CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
						AND dsd.RowStatus = 1
						--AND NOT EXISTS (SELECT 1 FROM @TblIncidenceType)
						--AND ( @GuideSerie = '' OR dsd.Guide_Serie = @GuideSerie)
						--AND ( @GuideNumber = 0 OR dsd.Guide_Number = @GuideNumber)
						--AND ( NOT EXISTS (SELECT 1 FROM @TblHubLogistic)  OR Hubs.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic) )
						--AND ( NOT EXISTS (SELECT 1 FROM @TblHubLogistic)  OR Hubs.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic) )
						--AND ( NOT EXISTS (SELECT 1 FROM @TblCustomerType) OR cus.IdCustomerType IN (SELECT IdCustomerType FROM @TblCustomerType) )
						--AND ( NOT EXISTS (SELECT 1 FROM @TblCustomer)     OR cus.IdCustomer IN (SELECT IdCustomer FROM @TblCustomer) )
						--AND ( NOT EXISTS (SELECT 1 FROM @TblVisitPointClient) OR vpc.CodeOfReference IN (SELECT IdVisitPointClient FROM @TblVisitPointClient) )
				UNION ALL
				SELECT 'EEF' [Type], 'Entregas Efectivas'  [Description], 2 [OrderCard], 0 [Pending], COUNT(1) [Delivered], 0 [ConfirmationIncidents], 0 [UnConfirmationIncidents]
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]								ds WITH (NOLOCK)
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]						dsd WITH (NOLOCK)
						ON dsd.ID_DeliveryOrderBySettlement = ds.ID
					CROSS APPLY
					(
						SELECT TOP 1
							   ordd.Guide_Serie
							 , ordd.Guide_Number
							 , ord.Sender_ID
							 , ord.ReceiverIdTownship
						FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]									ord WITH (NOLOCK)
							INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]					ordd WITH (NOLOCK)
								ON  ordd.Guide_Serie  = ord.Guide_Serie
								AND ordd.Guide_Number = ord.Guide_Number
						WHERE	ord.IsLastMileReturn	= 0 --NO INCLUIR DEVOLUCIÓN
								AND ordd.Guide_Serie	= dsd.Guide_Serie
								AND ordd.Guide_Number	= dsd.Guide_Number
								AND ord.StatusOrderId	 in (5,24,25)  --Entregado/COD liquidado/COD pagado
								AND CONVERT(DATE, ordd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
						ORDER BY ordd.DateCreatedInSystem DESC
					)																					del													
					LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]								vpc WITH (NOLOCK)
							ON vpc.CodeOfReference = del.Sender_ID
					LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]										cus WITH (NOLOCK)
							ON cus.IdCustomer = vpc.CustomerID
					LEFT JOIN [DeliveryBackOffice].[dbo].[Township]										tw WITH (NOLOCK)
						ON tw.IdTownship = del.ReceiverIdTownship
					OUTER APPLY
					(
						SELECT TOP 1
								HBL.IdHubLogistic
						FROM dbo.DumpServiceCoverage													dum WITH (NOLOCK)
							INNER JOIN DeliveryBackOffice.dbo.HubLogistics								HBL WITH (NOLOCK)
								ON dum.Hub = HBL.HubAbbreviation
							    AND HBL.HubStatus = 1
						WHERE dum.HeaderCode = tw.HeaderCode
					)																					HUbs
				WHERE	CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
						AND dsd.RowStatus = 1	
						AND ( @GuideSerie = '' OR dsd.Guide_Serie = @GuideSerie)
						AND ( @GuideNumber = 0 OR dsd.Guide_Number = @GuideNumber)
						--AND NOT EXISTS (SELECT 1 FROM @TblIncidenceType)
						--AND ( NOT EXISTS (SELECT 1 FROM @TblHubLogistic)  OR Hubs.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic) )
						--AND ( NOT EXISTS (SELECT 1 FROM @TblCustomerType) OR cus.IdCustomerType IN (SELECT IdCustomerType FROM @TblCustomerType) )
						--AND ( NOT EXISTS (SELECT 1 FROM @TblCustomer)     OR cus.IdCustomer IN (SELECT IdCustomer FROM @TblCustomer) )
						--AND ( NOT EXISTS (SELECT 1 FROM @TblVisitPointClient) OR vpc.CodeOfReference IN (SELECT IdVisitPointClient FROM @TblVisitPointClient) )
				UNION ALL
				SELECT 'IPR' [Type], 'Incidencias Procesadas'  [Description], 3 [OrderCard], 0 [Pending], 0 [Delivered], COUNT(1) [ConfirmationIncidents], 0 [UnConfirmationIncidents]
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]								ds WITH (NOLOCK)
					INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]						dsd WITH (NOLOCK)
						ON dsd.ID_DeliveryOrderBySettlement = ds.ID
					CROSS APPLY
					(
						SELECT TOP 1
							   ordd.Guide_Serie
							 , ordd.Guide_Number
							 , ordd.DeliveryAttemptId
							 , ord.Sender_ID
							 , ord.ReceiverIdTownship
						FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]									ord WITH (NOLOCK)
							INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]					ordd WITH (NOLOCK)
								ON  ordd.Guide_Serie  = ord.Guide_Serie
								AND ordd.Guide_Number = ord.Guide_Number
						WHERE	ord.IsLastMileReturn	= 0 --NO INCLUIR DEVOLUCIÓN
								AND ordd.Guide_Serie	= dsd.Guide_Serie
								AND ordd.Guide_Number	= dsd.Guide_Number
								AND ordd.StatusOrderId	= 50
								AND CONVERT(DATE, ordd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
						ORDER BY ordd.DateCreatedInSystem DESC
					)                                                                                   del
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt]								da  WITH (NOLOCK)
						ON [DA].[ID] = [del].[DeliveryAttemptId]
					LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]						coi WITH (NOLOCK)
						ON [COI].[IdConfirmationOfIncidence] = [DA].[ConfirmationOfIncidenceId]
					LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence]								cti WITH (NOLOCK)
							ON cti.IdIncidenceType = CONVERT(INT, da.ID_Incident)
					LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]								vpc WITH (NOLOCK)
							ON vpc.CodeOfReference = del.Sender_ID
					LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]										cus WITH (NOLOCK)
							ON cus.IdCustomer = vpc.CustomerID
					LEFT JOIN [DeliveryBackOffice].[dbo].[Township]										tw WITH (NOLOCK)
						ON tw.IdTownship = del.ReceiverIdTownship
					OUTER APPLY
					(
						SELECT TOP 1
								HBL.IdHubLogistic
						FROM dbo.DumpServiceCoverage													dum WITH (NOLOCK)
							INNER JOIN DeliveryBackOffice.dbo.HubLogistics								HBL WITH (NOLOCK)
								ON dum.Hub = HBL.HubAbbreviation
							    AND HBL.HubStatus = 1
						WHERE dum.HeaderCode = tw.HeaderCode
					)																					HUbs
				WHERE	CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
						AND [coi].[IsConfirmed] = 1
						AND [coi].[RowStatus] = 1
						--AND ( 
						--			(
						--				NOT EXISTS (SELECT 1 FROM @TblIncidenceType) OR
						--			    (SELECT COUNT(*) FROM @TblIncidenceType) = 1 AND (SELECT IdIncidenceType FROM @TblIncidenceType) = 0
						--			)
						--			OR
						--			(
						--				-- Mostrar solo los valores que coincidan con @TblIncidenceType si tiene otros valores (excluyendo 0)
						--				EXISTS (SELECT 1 FROM @TblIncidenceType WHERE IdIncidenceType <> 0)
						--				AND IdIncidenceType IN (SELECT IdIncidenceType FROM @TblIncidenceType WHERE IdIncidenceType <> 0)
						--			)
						--	)
						AND ( @GuideSerie = '' OR dsd.Guide_Serie = @GuideSerie)
						AND ( @GuideNumber = 0 OR dsd.Guide_Number = @GuideNumber)
						--AND ( NOT EXISTS (SELECT 1 FROM @TblHubLogistic)  OR Hubs.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic) )
						--AND ( NOT EXISTS (SELECT 1 FROM @TblCustomerType) OR cus.IdCustomerType IN (SELECT IdCustomerType FROM @TblCustomerType) )
						--AND ( NOT EXISTS (SELECT 1 FROM @TblCustomer)     OR cus.IdCustomer IN (SELECT IdCustomer FROM @TblCustomer) )
						--AND ( NOT EXISTS (SELECT 1 FROM @TblVisitPointClient) OR vpc.CodeOfReference IN (SELECT IdVisitPointClient FROM @TblVisitPointClient) )
				UNION ALL
				SELECT 'IPP' [Type], 'Incidencia Pendientes de Procesar'  [Description], 4 [OrderCard], 0 [Pending], 0 [Delivered], 0 [ConfirmationIncidents], COUNT(1) [UnConfirmationIncidents]
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]								ds WITH (NOLOCK)
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]						dsd WITH (NOLOCK)
						ON dsd.ID_DeliveryOrderBySettlement = ds.ID
					CROSS APPLY
					(
						SELECT TOP 1
							   ordd.Guide_Serie
							 , ordd.Guide_Number
							 , ordd.DeliveryAttemptId
							 , ord.Sender_ID
							 , ord.ReceiverIdTownship
						FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]									ord WITH (NOLOCK)
							INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]					ordd WITH (NOLOCK)
								ON  ordd.Guide_Serie  = ord.Guide_Serie
								AND ordd.Guide_Number = ord.Guide_Number
						WHERE	ord.IsLastMileReturn	= 0 --NO INCLUIR DEVOLUCIÓN
								AND ordd.Guide_Serie	= dsd.Guide_Serie
								AND ordd.Guide_Number	= dsd.Guide_Number
								AND ordd.StatusOrderId	= 45
								AND ordd.SystemOrigin   in(3)
								AND CONVERT(DATE, ordd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
						ORDER BY ordd.DateCreatedInSystem DESC
					)                                                                                   del
					RIGHT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt]								da WITH (NOLOCK)
						ON [DA].[ID] = [del].[DeliveryAttemptId]
					LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]						coi WITH (NOLOCK)
						ON [COI].[IdConfirmationOfIncidence] = [DA].[ConfirmationOfIncidenceId]
					LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence]								cti WITH (NOLOCK)
							ON cti.IdIncidenceType = CONVERT(INT, da.ID_Incident)
					LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]								vpc WITH (NOLOCK)
							ON vpc.CodeOfReference = del.Sender_ID
					LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]										cus WITH (NOLOCK)
							ON cus.IdCustomer = vpc.CustomerID
					LEFT JOIN [DeliveryBackOffice].[dbo].[Township]										tw WITH (NOLOCK)
						ON tw.IdTownship = del.ReceiverIdTownship
					OUTER APPLY
					(
						SELECT TOP 1
								HBL.IdHubLogistic
						FROM dbo.DumpServiceCoverage													dum WITH (NOLOCK)
							INNER JOIN DeliveryBackOffice.dbo.HubLogistics								HBL WITH (NOLOCK)
								ON dum.Hub = HBL.HubAbbreviation
							    AND HBL.HubStatus = 1
						WHERE dum.HeaderCode = tw.HeaderCode
					)																					HUbs
				WHERE	CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
						AND [coi].[IsConfirmed] = 0
						AND [coi].[RowStatus] = 1
						--AND ( 
						--		(-- Mostrar todo si @TblIncidenceType está vacío
						--			NOT EXISTS (SELECT 1 FROM @TblIncidenceType)
						--			-- Mostrar todo si @TblIncidenceType contiene únicamente 0
						--			OR EXISTS (SELECT 1 FROM @TblIncidenceType WHERE IdIncidenceType = 0 AND NOT EXISTS (SELECT 1 FROM @TblIncidenceType WHERE IdIncidenceType <> 0))
						--		)
						--		OR
						--		(
						--			-- Mostrar solo los valores que coincidan con @TblIncidenceType si tiene otros valores (excluyendo 0)
						--			EXISTS (SELECT 1 FROM @TblIncidenceType WHERE IdIncidenceType <> 0)
						--			AND IdIncidenceType IN (SELECT IdIncidenceType FROM @TblIncidenceType WHERE IdIncidenceType <> 0)
						--		)
						--)
						AND ( @GuideSerie = '' OR dsd.Guide_Serie = @GuideSerie)
						AND ( @GuideNumber = 0 OR dsd.Guide_Number = @GuideNumber)
						--AND ( NOT EXISTS (SELECT 1 FROM @TblHubLogistic)  OR Hubs.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic) )
						--AND ( NOT EXISTS (SELECT 1 FROM @TblCustomerType) OR cus.IdCustomerType IN (SELECT IdCustomerType FROM @TblCustomerType) )
						--AND ( NOT EXISTS (SELECT 1 FROM @TblCustomer)     OR cus.IdCustomer IN (SELECT IdCustomer FROM @TblCustomer) )
						--AND ( NOT EXISTS (SELECT 1 FROM @TblVisitPointClient) OR vpc.CodeOfReference IN (SELECT IdVisitPointClient FROM @TblVisitPointClient) )
				UNION ALL
				SELECT 'IPP' [Type], 'Incidencia Pendientes de Procesar'  [Description], 4 [OrderCard], 0 [Pending], 0 [Delivered], 0 [ConfirmationIncidents], COUNT(1) [UnConfirmationIncidents]
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]											ord WITH (NOLOCK)
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData]						atd WITH (NOLOCK)
						ON	atd.GuideSerie = ord.Guide_Serie
						AND atd.GuideNumber = ord.Guide_Number
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]							ordd WITH (NOLOCK)
						ON  ordd.Guide_Serie = ord.Guide_Serie
						AND ordd.Guide_Number = ord.Guide_Number
					RIGHT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt]								da WITH (NOLOCK)
						ON [DA].[ID] = [ordd].[DeliveryAttemptId]
					LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]						coi WITH (NOLOCK)
						ON [COI].[IdConfirmationOfIncidence] = [DA].[ConfirmationOfIncidenceId]
					LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence]								cti WITH (NOLOCK)
						ON cti.IdIncidenceType = CONVERT(INT, da.ID_Incident)
					LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]								vpc WITH (NOLOCK)
						ON vpc.CodeOfReference = ord.Sender_ID
					LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]										cus WITH (NOLOCK)
						ON cus.IdCustomer = vpc.CustomerID
					LEFT JOIN [DeliveryBackOffice].[dbo].[Township]										tw WITH (NOLOCK)
						ON tw.IdTownship = ord.ReceiverIdTownship
					OUTER APPLY
					(
						SELECT TOP 1
								HBL.IdHubLogistic
						FROM dbo.DumpServiceCoverage													dum WITH (NOLOCK)
							INNER JOIN DeliveryBackOffice.dbo.HubLogistics								HBL WITH (NOLOCK)
								ON dum.Hub = HBL.HubAbbreviation
							    AND HBL.HubStatus = 1
						WHERE dum.HeaderCode = tw.HeaderCode
					)																					HUbs
				WHERE	CONVERT(DATE, ordd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
						AND ord.StatusOrderId = 45
						AND ord.IsLastMileReturn = 0
						AND ordd.SystemOrigin in (2)
						AND [coi].[IsConfirmed] = 0
						AND [coi].[RowStatus] = 1
						--AND ( 
						--			(
						--				NOT EXISTS (SELECT 1 FROM @TblIncidenceType) OR
						--			    (SELECT COUNT(*) FROM @TblIncidenceType) = 1 AND (SELECT IdIncidenceType FROM @TblIncidenceType) = 0
						--			)
						--			OR
						--			(
						--				-- Mostrar solo los valores que coincidan con @TblIncidenceType si tiene otros valores (excluyendo 0)
						--				EXISTS (SELECT 1 FROM @TblIncidenceType WHERE IdIncidenceType <> 0)
						--				AND IdIncidenceType IN (SELECT IdIncidenceType FROM @TblIncidenceType WHERE IdIncidenceType <> 0)
						--			)
						--	)
						AND ( @GuideSerie = '' OR ord.Guide_Serie = @GuideSerie)
						AND ( @GuideNumber = 0 OR ord.Guide_Number = @GuideNumber)
						--AND ( NOT EXISTS (SELECT 1 FROM @TblHubLogistic)  OR Hubs.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic) )
						--AND ( NOT EXISTS (SELECT 1 FROM @TblCustomerType) OR cus.IdCustomerType IN (SELECT IdCustomerType FROM @TblCustomerType) )
						--AND ( NOT EXISTS (SELECT 1 FROM @TblCustomer)     OR cus.IdCustomer IN (SELECT IdCustomer FROM @TblCustomer) )
						--AND ( NOT EXISTS (SELECT 1 FROM @TblVisitPointClient) OR vpc.CodeOfReference IN (SELECT IdVisitPointClient FROM @TblVisitPointClient) )
		
			) AS CARDS
			GROUP BY	 [Type]
						,[Description]
						,[OrderCard]
						,[CARDS].[Pending]
						,[CARDS].[Delivered]
						,[CARDS].[ConfirmationIncidents]
			ORDER BY	[OrderCard]

        /**********************************************************************************************************************************
		************************************************** CONSTRUCCION DETALLE ***********************************************************
		***********************************************************************************************************************************/
	    DECLARE @Detail TABLE (
		Pending int
		,[Delivered] int
		,[ConfirmationIncidents] int
		,[UnConfirmationIncidents] INT
		,[ID] bigint
		,[ID_Courier] int
		,[Date_Received] DATETIME
		,[IdRoute]  int
		,[ID_Incident] int
		,[IdUser] int
		,[Username] NVARCHAR(50)
		,[RouteDescription] NVARCHAR(200)
		,[User] NVARCHAR(100)
		,[GuideSerie] NVARCHAR(2)
		,[GuideNumber] int
		,[SenderName] NVARCHAR(50)
		,[ReceiverName]  NVARCHAR(50)
		,[SenderPhone] NVARCHAR(50)
		,[ReceiverPhone] NVARCHAR(50)
		,[ReceiverAddress] NVARCHAR(600)
		,[TypeOfIncident] NVARCHAR(50)
		,[Incident] NVARCHAR(50)
		,[EventDate] DATETIME
		,[Attempts] NVARCHAR(10)
		,[PriceShippment]  DECIMAL(14,2)
		,[ShippmentCurrencySymbol] NVARCHAR(2)
		,[CollectOnDelivery] DECIMAL(14,2)
		,[CODCurrencySymbol] NVARCHAR(2)
		,[OrderDescription] NVARCHAR(50)
		,[StatusOfIncident] NVARCHAR(50)
		,[IdHubLogistic] int
		,[Pendiente]  int
		,[CourierPhone] NVARCHAR(50)
		,[Customer] int
		,[CodeOfReference] NVARCHAR(50)
		,[CustomerType] int
		,[IdIncidenceType] int
		)

		INSERT INTO @Detail				
		SELECT TOP 100  --EN RUTA Y ENTREGAS
				IIF(del.StatusOrderId = 4,1,0) [Pending]
				,IIF(del.StatusOrderId<>4,1,0) [Delivered]
				, 0 [ConfirmationIncidents]
				, 0 [UnConfirmationIncidents]
				, ds.ID																			[ID]
				, ds.ID_Courier																	[ID_Courier]
				, ds.Date_Received																[Date_Received]
				, IIF(tk.SSN_IdUser IS NULL, ISNULL(ds.ID_Courier, 1), 0)						[IdRoute]
				, NULL																			[ID_Incident]
				, NULL																			[IdUser]
				, NULL																			[Username]
				, (CASE
                    WHEN tk.SSN_IdUser IS NULL THEN
                        'Vendedor Rutero'
                    ELSE
                        'Usuario Desktop'
                END
                )                                                                                [RouteDescription]
                , CONCAT(
                            COALESCE(sr.First_Name, '')
                        , ' '
                        , COALESCE(sr.Last_Name, '')
                        )																			[User]
				, del.Guide_Serie																	[GuideSerie]
                , del.Guide_Number																	[GuideNumber]
                , del.[Sender]																		[SenderName]
                , del.[Receiver]																	[ReceiverName]
                , del.Sender_Phone																	[SenderPhone]
                , del.Receiver_Phone																[ReceiverPhone]
                , del.Receiver_Address																[ReceiverAddress]
                , ''																				[TypeOfIncident]
                , ''																				[Incident]
				, dsd.DateCreated																	[EventDate]
				, ''																				[Attempts]
                , del.PriceShippment																[PriceShippment]
				, del.ShippmentCurrencySymbol														[ShippmentCurrencySymbol]
                , del.Collect_OnDelivery															[CollectOnDelivery]
				, del.CODCurrencySymbol																[CODCurrencySymbol]
                , std.OrderDescription																[OrderDescription]
                , ''																				[StatusOfIncident]
                , HUbs.IdHubLogistic																[IdHubLogistic]
                , 1																					[Pendiente]
                , sr.Phone																			[CourierPhone]
				, cus.IdCustomer																	[Customer]
				, del.CodeOfReference																[CodeOfReference]
				, cus.IdCustomerType																[CustomerType]
				, 0																					[IdIncidenceType]
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]								ds WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]					dsd WITH (NOLOCK)
				ON dsd.ID_DeliveryOrderBySettlement = ds.ID						
			CROSS APPLY
			(
				SELECT TOP 1
						ordd.Guide_Serie
						, ordd.Guide_Number
						, ordd.StatusOrderId
						, vpc.CustomerID
						, vpc.CodeOfReference
						, ord.Sender_ID
						, ord.Sender_FirstName + ' ' + ord.Sender_LastName  [Sender]
						, ord.Sender_Phone
						, COALESCE(ord.Receiver_FirstName, '') + ' ' + COALESCE(ord.Receiver_LastName, '') [Receiver]
						, ord.Receiver_Phone
						, ord.Receiver_Address 
						, ord.ReceiverIdTownship
						, ord.PriceShippment						
						, cur.Symbol		[ShippmentCurrencySymbol]
						, ord.Collect_OnDelivery
						, curCOD.Symbol		[CODCurrencySymbol]
						, ordd.UserCreated
						, ordd.DateCreatedInSystem
						, ordd.DeliveryAttemptId
						, tk.SSN_IdUser
						, tk.SSN_Username
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]									ord WITH (NOLOCK)
					INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]					ordd WITH (NOLOCK)
						ON  ordd.Guide_Serie  = ord.Guide_Serie
						AND ordd.Guide_Number = ord.Guide_Number
					INNER JOIN [DeliveryBackOffice].[dbo].[Cost]								co WITH (NOLOCK)
						ON ord.Guide_Number= co.GuideNumber and ord.Guide_Serie = co.GuideSerie
					LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]						cur WITH (NOLOCK)
						on ISNULL(co.ShippingCurrency,1) = cur.IdCatCurrencyCOD 
					LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]						curCOD WITH (NOLOCK)
						on ISNULL(co.CodCurrency,1) = curCOD.IdCatCurrencyCOD 
					LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]						vpc WITH (NOLOCK)
						ON vpc.CodeOfReference = ord.Sender_ID
					LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken								tk WITH (NOLOCK)
						ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ordd.UserCreated) --ddd.UserCreated
						AND tk.SSN_IdUser IS NULL
				WHERE	ord.IsLastMileReturn	= 0 --NO INCLUIR DEVOLUCIÓN
						AND ordd.Guide_Serie	= dsd.Guide_Serie
						AND ordd.Guide_Number	= dsd.Guide_Number
						AND ord.StatusOrderId	in (4,5,24,25) --En Rutea/Entregado/COD liquidado/COD pagado
						AND CONVERT(DATE, ordd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
				ORDER BY ordd.DateCreatedInSystem DESC
			)																					del
			LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiver]								sr WITH (NOLOCK)
                ON sr.ID = ds.ID_Courier
			LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrder]									std WITH (NOLOCK)
                ON std.StatusOrderId = del.StatusOrderId
			LEFT JOIN [DenariusUser_Dev].[dbo].[LGN_LogByToken]									tk WITH (NOLOCK)
				ON tk.SSN_IdToken = CONVERT(VARCHAR(50), dsd.TokenCreated) 
				AND tk.SSN_IdUser IS NULL
			LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]										cus WITH (NOLOCK)
					ON cus.IdCustomer = del.CustomerID
			LEFT JOIN [DeliveryBackOffice].[dbo].[Township]										tw WITH (NOLOCK)
				ON tw.IdTownship = del.ReceiverIdTownship
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
		WHERE	CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
				AND dsd.RowStatus = 1
				--AND ds.Date_Received IS NULL
		AND NOT EXISTS (SELECT 1 FROM @TblIncidenceType)
		AND ( @GuideSerie = '' OR del.Guide_Serie = @GuideSerie)
		AND ( @GuideNumber = 0 OR del.Guide_Number = @GuideNumber)
		AND ( NOT EXISTS (SELECT 1 FROM @TblHubLogistic)   OR Hubs.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic) )
		AND ( NOT EXISTS (SELECT 1 FROM @TblCustomerType)  OR cus.IdCustomerType IN (SELECT IdCustomerType FROM @TblCustomerType) )
		AND ( NOT EXISTS (SELECT 1 FROM @TblCustomer)      OR 
			  cus.IdCustomer IN (
								SELECT IdCustomer FROM @TblCustomer
								UNION 
								SELECT DISTINCT A2.CustomerID IdCustomer
									FROM [DeliveryBackOffice].[dbo].[Customer] A1
									INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] A2
											ON A2.CustomerID = A1.IdCustomer
									WHERE	IdCustomerType = 2 
											AND 81 IN (SELECT IdCustomer FROM @TblCustomer)
											AND IdCustomer <> 81
											AND A2.StatusClient = 1
											AND A2.IdKindOfVPClient = 1 
								)
			)
		AND ( NOT EXISTS (SELECT 1 FROM @TblVisitPointClient) OR CodeOfReference IN (SELECT IdVisitPointClient FROM @TblVisitPointClient) )	
		ORDER BY DSD.DateCreated DESC
			
		INSERT INTO @Detail				
		SELECT	TOP 100  --CONFIRMADAS NO INCLUYE DESKTOP
					0 [Pending]
				, 0 [Delivered]
				, 1 [ConfirmationIncidents]
				, 0 [UnConfirmationIncidents]
				, ds.ID																			[ID]
				, ds.ID_Courier																	[ID_Courier]
				, ds.Date_Received																[Date_Received]
				, da.ID_Incident																	[Id_Incident]
				, IIF(del.SSN_IdUser IS NULL, ISNULL(ds.ID_Courier, 1), 0)						[IdRoute]
				, del.SSN_IdUser																	[IdUser]
				, del.SSN_Username																[Username]
				, (CASE
						WHEN del.SSN_IdUser IS NULL THEN
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
				, del.Guide_Serie                                                                  [GuideSerie]
				, del.Guide_Number                                                                 [GuideNumber]
				, del.[Sender]																	 [SenderName]
				, del.[Receiver]																	 [ReceiverName]
				, del.Sender_Phone                                                                 [SenderPhone]
				, del.Receiver_Phone                                                               [ReceiverPhone]
				, del.Receiver_Address                                                             [ReceiverAddress]
				, ISNULL(cic.IncidenceTypeName, '')                                                [TypeOfIncident]
				, cti.NameIncidence                                                                [Incident]
				, del.DateCreatedInSystem															 [EventDate]
				, (CASE
						WHEN cti.NameIncidence IS NULL THEN
							NULL
						ELSE
							CONCAT(
									CONVERT(
												NVARCHAR(4)
											, IIF(
														del.GuideDeliveryAttemptCount = del.GuideDeliveryMaxAttemptCount
													, del.GuideDeliveryAttemptCount
													, IIF(cti.IncidenceClasificationId <> 1, del.GuideDeliveryAttemptCount, del.GuideDeliveryAttemptCount+1))
											)
									, '/'
									, CONVERT(NVARCHAR(4), del.GuideDeliveryMaxAttemptCount)
								)
					END
				)                                                                               [Attempts]
				, del.PriceShippment																[PriceShippment]
				, del.ShippmentCurrencySymbol													[ShippmentCurrencySymbol]
				, del.Collect_OnDelivery                                                          [CollectOnDelivery]
				, del.CODCurrencySymbol															[CODCurrencySymbol]
				, std.OrderDescription															[OrderDescription]
				, 'Aprobada'                                                                      [StatusOfIncident]
				, HUbs.IdHubLogistic																[IdHubLogistic]
				, 0																				[Pendiente]
				, sr.Phone                                                                        [CourierPhone]
				, cus.IdCustomer																	[Customer]
				, del.CodeOfReference                                                             [CodeOfReference]
				, cus.IdCustomerType                                                              [CustomerType]
				, cti.IdIncidenceType																[IdIncidenceType]
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]								ds WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]					dsd WITH (NOLOCK)
				ON dsd.ID_DeliveryOrderBySettlement = ds.ID
				--AND dsd.RowStatus = 1
			CROSS APPLY
			(
				SELECT TOP 1
						ordd.Guide_Serie
						, ordd.Guide_Number
						, ordd.StatusOrderId
						, vpc.CustomerID
						, vpc.CodeOfReference
						, ord.Sender_ID
						, ord.Sender_FirstName + ' ' + ord.Sender_LastName  [Sender]
						, ord.Sender_Phone
						, COALESCE(ord.Receiver_FirstName, '') + ' ' + COALESCE(ord.Receiver_LastName, '') [Receiver]
						, ord.Receiver_Phone
						, ord.Receiver_Address 
						, ord.ReceiverIdTownship
						, ord.PriceShippment
						, cur.Symbol			[ShippmentCurrencySymbol]
						, ord.Collect_OnDelivery
						, curCOD.Symbol			[CODCurrencySymbol]
						, ordd.UserCreated
						, ordd.DateCreatedInSystem
						, ordd.DeliveryAttemptId
						, atd.GuideDeliveryAttemptCount
						, atd.GuideDeliveryMaxAttemptCount
						, tk.SSN_IdUser
						, tk.SSN_Username
						,ordd.DateCreated
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]									ord WITH (NOLOCK)
					INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]					ordd WITH (NOLOCK)
						ON  ordd.Guide_Serie  = ord.Guide_Serie
						AND ordd.Guide_Number = ord.Guide_Number
					INNER JOIN [DeliveryBackOffice].[dbo].[Cost]								co WITH (NOLOCK)
						ON ord.Guide_Number= co.GuideNumber and ord.Guide_Serie = co.GuideSerie
					LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]						cur WITH (NOLOCK)
						on ISNULL(co.ShippingCurrency,1) = cur.IdCatCurrencyCOD 
					LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]						curCOD WITH (NOLOCK)
						on ISNULL(co.CodCurrency,1) = curCOD.IdCatCurrencyCOD 
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData]				atd WITH (NOLOCK)
						ON atd.GuideSerie	= ord.Guide_Serie
						AND atd.GuideNumber = ord.Guide_Number
					LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]						vpc WITH (NOLOCK)
						ON vpc.CodeOfReference = ord.Sender_ID
					LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken								tk WITH (NOLOCK)
						ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ordd.UserCreated) --ddd.UserCreated
						AND tk.SSN_IdUser IS NULL
				WHERE	ordd.StatusOrderId	= 50
						AND ordd.Guide_Serie	= dsd.Guide_Serie
						AND ordd.Guide_Number	= dsd.Guide_Number
						AND CONVERT(DATE, ordd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
				ORDER BY ordd.DateCreatedInSystem DESC
			)																					del
		LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiver]									sr WITH (NOLOCK)
			ON sr.ID = ds.ID_Courier
		LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrder]										std WITH (NOLOCK)
            ON std.StatusOrderId = del.StatusOrderId
		LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt]									da WITH (NOLOCK)
			ON [DA].[ID] = [del].[DeliveryAttemptId]
		LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]							coi WITH (NOLOCK)
			ON [COI].[IdConfirmationOfIncidence] = [da].[ConfirmationOfIncidenceId]
		LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence]									cti WITH (NOLOCK)
                ON cti.IdIncidenceType = CONVERT(INT, da.ID_Incident)                                    
        LEFT JOIN [DeliveryBackOffice].[dbo].[CatIncidenceClasification]						cic WITH (NOLOCK)
            ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
		LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]											cus WITH (NOLOCK)
				ON cus.IdCustomer = del.CustomerID
		LEFT JOIN [DeliveryBackOffice].[dbo].[Township]											tw WITH (NOLOCK)
            ON tw.IdTownship = del.ReceiverIdTownship
		OUTER APPLY
			(
				SELECT TOP 1
						HBL.IdHubLogistic
				FROM dbo.DumpServiceCoverage													dum WITH (NOLOCK)
					INNER JOIN DeliveryBackOffice.dbo.HubLogistics								HBL WITH (NOLOCK)
						ON dum.Hub = HBL.HubAbbreviation
						AND HBL.HubStatus = 1
				WHERE dum.HeaderCode = tw.HeaderCode
			)																					HUbs
		WHERE	CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
				--AND dsd.RowStatus = 1
				--AND ds.Date_Received IS NULL
				AND [coi].[IsConfirmed] = 1
				AND [coi].[RowStatus] = 1
		AND ( NOT EXISTS (SELECT 1 FROM @TblHubLogistic)   OR Hubs.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic) )
		AND ( NOT EXISTS (SELECT 1 FROM @TblCustomerType)  OR cus.IdCustomerType IN (SELECT IdCustomerType FROM @TblCustomerType) )
		AND ( NOT EXISTS (SELECT 1 FROM @TblCustomer)      OR 
			  cus.IdCustomer IN (
								SELECT IdCustomer FROM @TblCustomer
								UNION 
								SELECT DISTINCT A2.CustomerID IdCustomer
									FROM [DeliveryBackOffice].[dbo].[Customer] A1
									INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] A2
											ON A2.CustomerID = A1.IdCustomer
									WHERE	IdCustomerType = 2 
											AND 81 IN (SELECT IdCustomer FROM @TblCustomer)
											AND IdCustomer <> 81
											AND A2.StatusClient = 1
											AND A2.IdKindOfVPClient = 1 
								)
			)
		AND ( NOT EXISTS (SELECT 1 FROM @TblVisitPointClient) OR CodeOfReference IN (SELECT IdVisitPointClient FROM @TblVisitPointClient) )				
		AND ( NOT EXISTS (SELECT 1 FROM @TblIncidenceType) OR IdIncidenceType IN (SELECT IdIncidenceType FROM @TblIncidenceType) )				
		ORDER BY DEL.DateCreated ASC

		/*
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]												ord WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]								ordd WITH (NOLOCK)
                ON  ordd.Guide_Serie = ord.Guide_Serie
                AND ordd.Guide_Number = ord.Guide_Number
				AND ord.StatusOrderId = 45
				AND ordd.SystemOrigin in (2) --DESKTOP
			LEFT JOIN [DenariusUser_Dev].[dbo].[LGN_LogByToken]										tk WITH (NOLOCK)
				ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ordd.UserCreated)
			LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData]							atd WITH (NOLOCK)
                ON atd.GuideSerie = ord.Guide_Serie
				AND atd.GuideNumber = ord.Guide_Number
			LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrder]										std WITH (NOLOCK)
                ON std.StatusOrderId = ord.StatusOrderId
			LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]									vpc WITH (NOLOCK)
				ON vpc.CodeOfReference = ord.Sender_ID
			LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]											cus WITH (NOLOCK)
				ON cus.IdCustomer = vpc.CustomerID
			LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt]									da WITH (NOLOCK)
				ON [DA].[ID] = [ordd].[DeliveryAttemptId]
			LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]							coi WITH (NOLOCK)
				ON [COI].[IdConfirmationOfIncidence] = [DA].[ConfirmationOfIncidenceId]
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence]									cti WITH (NOLOCK)
                ON cti.IdIncidenceType = CONVERT(INT, da.ID_Incident)
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatIncidenceClasification]						cic WITH (NOLOCK)
                ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
			LEFT JOIN [DeliveryBackOffice].[dbo].[Township]											tw WITH (NOLOCK)
                ON tw.IdTownship = ord.ReceiverIdTownship
			OUTER APPLY
				(
					SELECT TOP 1
							HBL.IdHubLogistic
					FROM dbo.DumpServiceCoverage													dum WITH (NOLOCK)
						INNER JOIN DeliveryBackOffice.dbo.HubLogistics								HBL WITH (NOLOCK)
							ON dum.Hub = HBL.HubAbbreviation
							AND HBL.HubStatus = 1
					WHERE dum.HeaderCode = tw.HeaderCode
				)																					HUbs
		WHERE	CONVERT(DATE, ordd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
				AND [coi].[IsConfirmed] = 0
				AND [coi].[RowStatus] = 1
				AND ( 
							(
								NOT EXISTS (SELECT 1 FROM @TblIncidenceType) OR
								(SELECT COUNT(*) FROM @TblIncidenceType) = 1 AND (SELECT IdIncidenceType FROM @TblIncidenceType) = 0
							)
							OR
							(
								-- Mostrar solo los valores que coincidan con @TblIncidenceType si tiene otros valores (excluyendo 0)
								EXISTS (SELECT 1 FROM @TblIncidenceType WHERE IdIncidenceType <> 0)
								AND IdIncidenceType IN (SELECT IdIncidenceType FROM @TblIncidenceType WHERE IdIncidenceType <> 0)
							)
					)
				AND ( NOT EXISTS (SELECT 1 FROM @TblHubLogistic)   OR Hubs.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic) )
				AND ( NOT EXISTS (SELECT 1 FROM @TblCustomerType)  OR cus.IdCustomerType IN (SELECT IdCustomerType FROM @TblCustomerType) )
				AND ( NOT EXISTS (SELECT 1 FROM @TblCustomer)      OR 
					  cus.IdCustomer IN (
										SELECT IdCustomer FROM @TblCustomer
										UNION 
										SELECT DISTINCT A2.CustomerID IdCustomer
											FROM [DeliveryBackOffice].[dbo].[Customer] A1
											INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] A2
													ON A2.CustomerID = A1.IdCustomer
											WHERE	IdCustomerType = 2 
													AND 81 IN (SELECT IdCustomer FROM @TblCustomer)
													AND IdCustomer <> 81
													AND A2.StatusClient = 1
													AND A2.IdKindOfVPClient = 1 
										)
					)
				AND ( NOT EXISTS (SELECT 1 FROM @TblVisitPointClient) OR CodeOfReference IN (SELECT IdVisitPointClient FROM @TblVisitPointClient) )				
				ORDER BY ordd.DateCreated ASC*/
			
			
		INSERT INTO @Detail
		SELECT	TOP 100  --NO CONFIRMADAS NO INCLUYE DESKTOP
					0 [Pending]
				, 0 [Delivered]
				, 0 [ConfirmationIncidents]
				, 1 [UnConfirmationIncidents]
				, ds.ID																			[ID]
				, ds.ID_Courier																	[ID_Courier]
				, ds.Date_Received																[Date_Received]
				, da.ID_Incident																	[Id_Incident]
				, IIF(del.SSN_IdUser IS NULL, ISNULL(ds.ID_Courier, 1), 0)						[IdRoute]
				, del.SSN_IdUser																	[IdUser]
				, del.SSN_Username																[Username]
				, (CASE
						WHEN del.SSN_IdUser IS NULL THEN
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
				, del.Guide_Serie                                                                  [GuideSerie]
				, del.Guide_Number                                                                 [GuideNumber]
				, del.[Sender]																	 [SenderName]
				, del.[Receiver]																	 [ReceiverName]
				, del.Sender_Phone                                                                 [SenderPhone]
				, del.Receiver_Phone                                                               [ReceiverPhone]
				, del.Receiver_Address                                                             [ReceiverAddress]
				, ISNULL(cic.IncidenceTypeName, '')                                                [TypeOfIncident]
				, cti.NameIncidence                                                                [Incident]
				, del.DateCreatedInSystem															 [EventDate]
				, (CASE
						WHEN cti.NameIncidence IS NULL THEN
							NULL
						ELSE
							CONCAT(
									CONVERT(
												NVARCHAR(4)
											, IIF(
														del.GuideDeliveryAttemptCount = del.GuideDeliveryMaxAttemptCount
													, del.GuideDeliveryAttemptCount
													, IIF(cti.IncidenceClasificationId <> 1, del.GuideDeliveryAttemptCount, del.GuideDeliveryAttemptCount+1))
											)
									, '/'
									, CONVERT(NVARCHAR(4), del.GuideDeliveryMaxAttemptCount)
								)
					END
				)                                                                               [Attempts]
				, del.PriceShippment																[PriceShippment]
				, del.ShippmentCurrencySymbol													[ShippmentCurrencySymbol]
				, del.Collect_OnDelivery                                                          [CollectOnDelivery]
				, del.CODCurrencySymbol															[CODCurrencySymbol]
				, std.OrderDescription															[OrderDescription]
				, IIF( [coi].[IsDenied] = 0, 'Pendiente' , 'Rechazada' )                          [StatusOfIncident]
				, HUbs.IdHubLogistic																[IdHubLogistic]
				, 0																				[Pendiente]
				, sr.Phone                                                                        [CourierPhone]
				, cus.IdCustomer																	[Customer]
				, del.CodeOfReference                                                             [CodeOfReference]
				, cus.IdCustomerType                                                              [CustomerType]
				, cti.IdIncidenceType																[IdIncidenceType]
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement]								ds WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail]					dsd WITH (NOLOCK)
				ON dsd.ID_DeliveryOrderBySettlement = ds.ID
				--AND dsd.RowStatus = 1
			CROSS APPLY
			(
				SELECT TOP 1
						ordd.Guide_Serie
						, ordd.Guide_Number
						, ordd.StatusOrderId
						, vpc.CustomerID
						, vpc.CodeOfReference
						, ord.Sender_ID
						, ord.Sender_FirstName + ' ' + ord.Sender_LastName  [Sender]
						, ord.Sender_Phone
						, COALESCE(ord.Receiver_FirstName, '') + ' ' + COALESCE(ord.Receiver_LastName, '') [Receiver]
						, ord.Receiver_Phone
						, ord.Receiver_Address 
						, ord.ReceiverIdTownship
						, ord.PriceShippment
						, cur.Symbol			[ShippmentCurrencySymbol]
						, ord.Collect_OnDelivery
						, curCOD.Symbol			[CODCurrencySymbol]
						, ordd.UserCreated
						, ordd.DateCreatedInSystem
						, ordd.DeliveryAttemptId
						, atd.GuideDeliveryAttemptCount
						, atd.GuideDeliveryMaxAttemptCount
						, tk.SSN_IdUser
						, tk.SSN_Username
						, ordd.DateCreated
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]									ord WITH (NOLOCK)
					INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]					ordd WITH (NOLOCK)
						ON  ordd.Guide_Serie  = ord.Guide_Serie
						AND ordd.Guide_Number = ord.Guide_Number
					INNER JOIN [DeliveryBackOffice].[dbo].[Cost]								co WITH (NOLOCK)
						ON ord.Guide_Number= co.GuideNumber and ord.Guide_Serie = co.GuideSerie
					LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]						cur WITH (NOLOCK)
						on ISNULL(co.ShippingCurrency,1) = cur.IdCatCurrencyCOD 
					LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]						curCOD WITH (NOLOCK)
						on ISNULL(co.CodCurrency,1) = curCOD.IdCatCurrencyCOD 
					LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData]				atd WITH (NOLOCK)
						ON  atd.GuideSerie	= ord.Guide_Serie
						AND atd.GuideNumber = ord.Guide_Number
					LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]						vpc WITH (NOLOCK)
						ON vpc.CodeOfReference = ord.Sender_ID
					LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken								tk WITH (NOLOCK)
						ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ordd.UserCreated) --ddd.UserCreated
						AND tk.SSN_IdUser IS NULL
				WHERE	ordd.StatusOrderId		= 45
						AND ordd.Guide_Serie	= dsd.Guide_Serie
						AND ordd.Guide_Number	= dsd.Guide_Number
						AND ordd.SystemOrigin in (3)
						AND CONVERT(DATE, ordd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
				ORDER BY ordd.DateCreatedInSystem DESC
		)																						del
		LEFT JOIN [DeliveryBackOffice].[dbo].[SenderReceiver]									sr WITH (NOLOCK)
            ON sr.ID = ds.ID_Courier
		LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrder]										std WITH (NOLOCK)
            ON std.StatusOrderId = del.StatusOrderId				
		LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt]									da WITH (NOLOCK)
			ON [DA].[ID] = [del].[DeliveryAttemptId]
		LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]							coi WITH (NOLOCK)
			ON [COI].[IdConfirmationOfIncidence] = [DA].[ConfirmationOfIncidenceId]
		LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence]									cti WITH (NOLOCK)
            ON cti.IdIncidenceType = CONVERT(INT, da.ID_Incident)                                    
        LEFT JOIN [DeliveryBackOffice].[dbo].[CatIncidenceClasification]						cic WITH (NOLOCK)
            ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
		LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]											cus WITH (NOLOCK)
			ON cus.IdCustomer = del.CustomerID
		LEFT JOIN [DeliveryBackOffice].[dbo].[Township]											tw WITH (NOLOCK)
            ON tw.IdTownship = del.ReceiverIdTownship
		OUTER APPLY
			(
				SELECT TOP 1
						HBL.IdHubLogistic
				FROM dbo.DumpServiceCoverage													dum WITH (NOLOCK)
					INNER JOIN DeliveryBackOffice.dbo.HubLogistics								HBL WITH (NOLOCK)
						ON dum.Hub = HBL.HubAbbreviation
						AND HBL.HubStatus = 1
				WHERE dum.HeaderCode = tw.HeaderCode
			)																					HUbs
	WHERE	CONVERT(DATE, ds.Date_Dispatched) = CONVERT(DATE, GETDATE())
			AND dsd.RowStatus = 1
			AND ds.Date_Received IS NULL
			AND [coi].[IsConfirmed] = 0
			AND [coi].[RowStatus] = 1
			AND ( 
							(
								NOT EXISTS (SELECT 1 FROM @TblIncidenceType) OR
								(SELECT COUNT(*) FROM @TblIncidenceType) = 1 AND (SELECT IdIncidenceType FROM @TblIncidenceType) = 0
							)
							OR
							(
								-- Mostrar solo los valores que coincidan con @TblIncidenceType si tiene otros valores (excluyendo 0)
								EXISTS (SELECT 1 FROM @TblIncidenceType WHERE IdIncidenceType <> 0)
								AND IdIncidenceType IN (SELECT IdIncidenceType FROM @TblIncidenceType WHERE IdIncidenceType <> 0)
							)
					)
			AND ( NOT EXISTS (SELECT 1 FROM @TblHubLogistic)   OR Hubs.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic) )
			AND ( NOT EXISTS (SELECT 1 FROM @TblCustomerType)  OR cus.IdCustomerType IN (SELECT IdCustomerType FROM @TblCustomerType) )
			AND ( NOT EXISTS (SELECT 1 FROM @TblCustomer)      OR 
				  cus.IdCustomer IN (
									SELECT IdCustomer FROM @TblCustomer
									UNION 
									SELECT DISTINCT A2.CustomerID IdCustomer
										FROM [DeliveryBackOffice].[dbo].[Customer] A1
										INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] A2
												ON A2.CustomerID = A1.IdCustomer
										WHERE	IdCustomerType = 2 
												AND 81 IN (SELECT IdCustomer FROM @TblCustomer)
												AND IdCustomer <> 81
												AND A2.StatusClient = 1
												AND A2.IdKindOfVPClient = 1 
									)
				)
			AND ( NOT EXISTS (SELECT 1 FROM @TblVisitPointClient) OR CodeOfReference IN (SELECT IdVisitPointClient FROM @TblVisitPointClient) )				
		ORDER BY del.DateCreated ASC

		INSERT INTO @Detail
		SELECT	  --NO CONFIRMADAS DESKTOP
					0 [Pending]
					, 0 [Delivered]
					, 0 [ConfirmationIncidents]
					, 1 [UnConfirmationIncidents]
					, 0																				[ID]
					, 0																				[ID_Courier]
					, NULL																			[Date_Received]
					, da.ID_Incident																	[Id_Incident]
					, 0																				[IdRoute]
					, tk.SSN_IdUser																	[IdUser]
					, tk.SSN_Username																	[Username]
					, (CASE
							WHEN tk.SSN_IdUser IS NULL THEN
								'Vendedor Rutero'
							ELSE
								'Usuario Desktop'
						END
					)                                                                                [RouteDescription]
					,''		                                                                         [User]
					, ord.Guide_Serie                                                                  [GuideSerie]
					, ord.Guide_Number                                                                 [GuideNumber]
					, ord.Sender_FirstName + ' ' + ord.Sender_LastName                                 [SenderName]
					, COALESCE(ord.Receiver_FirstName, '') + ' ' + COALESCE(ord.Receiver_LastName, '') [ReceiverName]
					, ord.Sender_Phone                                                                 [SenderPhone]
					, ord.Receiver_Phone                                                               [ReceiverPhone]
					, ord.Receiver_Address                                                             [ReceiverAddress]
					, ISNULL(cic.IncidenceTypeName, '')                                                [TypeOfIncident]
					, cti.NameIncidence                                                                [Incident]
					, ordd.DateCreatedInSystem														 [EventDate]
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
					,cur.Symbol																		[ShippmentCurrencySymbol]
					, ord.Collect_OnDelivery                                                          [CollectOnDelivery]
					,curCOD.Symbol																	[CODCurrencySymbol]
					, std.OrderDescription															[OrderDescription]
					, IIF( [coi].[IsDenied] = 0, 'Pendiente' , 'Rechazada' )                          [StatusOfIncident]
					, HUbs.IdHubLogistic																[IdHubLogistic]
					, 0																				[Pendiente]
					, ''		                                                                        [CourierPhone]
					, cus.IdCustomer																	[Customer]
					, vpc.CodeOfReference                                                             [CodeOfReference]
					, cus.IdCustomerType                                                              [CustomerType]
					, cti.IdIncidenceType																[IdIncidenceType]
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrder]												ord WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]								ordd WITH (NOLOCK)
                ON  ordd.Guide_Serie = ord.Guide_Serie
                AND ordd.Guide_Number = ord.Guide_Number
				AND ord.StatusOrderId = 45
				AND ordd.SystemOrigin in (2) --DESKTOP
			INNER JOIN [DeliveryBackOffice].[dbo].[Cost]								co WITH (NOLOCK)
				ON ord.Guide_Number= co.GuideNumber and ord.Guide_Serie = co.GuideSerie
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]						cur WITH (NOLOCK)
				on ISNULL(co.ShippingCurrency,1) = cur.IdCatCurrencyCOD 
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]						curCOD WITH (NOLOCK)
				on ISNULL(co.CodCurrency,1) = curCOD.IdCatCurrencyCOD 						
			LEFT JOIN [DenariusUser_Dev].[dbo].[LGN_LogByToken]										tk WITH (NOLOCK)
				ON tk.SSN_IdToken = CONVERT(VARCHAR(50), ordd.UserCreated)
			LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData]							atd WITH (NOLOCK)
                ON atd.GuideSerie = ord.Guide_Serie
				AND atd.GuideNumber = ord.Guide_Number
			LEFT JOIN [DeliveryBackOffice].[dbo].[StatusOrder]										std WITH (NOLOCK)
                ON std.StatusOrderId = ord.StatusOrderId
			LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient]									vpc WITH (NOLOCK)
				ON vpc.CodeOfReference = ord.Sender_ID
			LEFT JOIN [DeliveryBackOffice].[dbo].[Customer]											cus WITH (NOLOCK)
				ON cus.IdCustomer = vpc.CustomerID
			LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt]									da WITH (NOLOCK)
				ON [DA].[ID] = [ordd].[DeliveryAttemptId]
			LEFT JOIN [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]							coi WITH (NOLOCK)
				ON [COI].[IdConfirmationOfIncidence] = [DA].[ConfirmationOfIncidenceId]
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence]									cti WITH (NOLOCK)
                ON cti.IdIncidenceType = CONVERT(INT, da.ID_Incident)
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatIncidenceClasification]						cic WITH (NOLOCK)
                ON cic.IdCatIncidenceClasification = cti.IncidenceClasificationId
			LEFT JOIN [DeliveryBackOffice].[dbo].[Township]											tw WITH (NOLOCK)
                ON tw.IdTownship = ord.ReceiverIdTownship
			OUTER APPLY
				(
					SELECT TOP 1
							HBL.IdHubLogistic
					FROM dbo.DumpServiceCoverage													dum WITH (NOLOCK)
						INNER JOIN DeliveryBackOffice.dbo.HubLogistics								HBL WITH (NOLOCK)
							ON dum.Hub = HBL.HubAbbreviation
							AND HBL.HubStatus = 1
					WHERE dum.HeaderCode = tw.HeaderCode
				)																					HUbs
		WHERE	CONVERT(DATE, ordd.DateCreatedInSystem) = CONVERT(DATE, GETDATE())
				AND [coi].[IsConfirmed] = 0
				AND [coi].[RowStatus] = 1
				AND ( 
							(
								NOT EXISTS (SELECT 1 FROM @TblIncidenceType) OR
								(SELECT COUNT(*) FROM @TblIncidenceType) = 1 AND (SELECT IdIncidenceType FROM @TblIncidenceType) = 0
							)
							OR
							(
								-- Mostrar solo los valores que coincidan con @TblIncidenceType si tiene otros valores (excluyendo 0)
								EXISTS (SELECT 1 FROM @TblIncidenceType WHERE IdIncidenceType <> 0)
								AND IdIncidenceType IN (SELECT IdIncidenceType FROM @TblIncidenceType WHERE IdIncidenceType <> 0)
							)
					)
				AND ( NOT EXISTS (SELECT 1 FROM @TblHubLogistic)   OR Hubs.IdHubLogistic IN ( SELECT IdHubLogistics FROM @TblHubLogistic) )
				AND ( NOT EXISTS (SELECT 1 FROM @TblCustomerType)  OR cus.IdCustomerType IN (SELECT IdCustomerType FROM @TblCustomerType) )
				AND ( NOT EXISTS (SELECT 1 FROM @TblCustomer)      OR 
					  cus.IdCustomer IN (
										SELECT IdCustomer FROM @TblCustomer
										UNION 
										SELECT DISTINCT A2.CustomerID IdCustomer
											FROM [DeliveryBackOffice].[dbo].[Customer] A1
											INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] A2
													ON A2.CustomerID = A1.IdCustomer
											WHERE	IdCustomerType = 2 
													AND 81 IN (SELECT IdCustomer FROM @TblCustomer)
													AND IdCustomer <> 81
													AND A2.StatusClient = 1
													AND A2.IdKindOfVPClient = 1 
										)
					)
				AND ( NOT EXISTS (SELECT 1 FROM @TblVisitPointClient) OR CodeOfReference IN (SELECT IdVisitPointClient FROM @TblVisitPointClient) )				
				ORDER BY ordd.DateCreated ASC

		SELECT * FROM @Detail

    END TRY
    BEGIN CATCH


        SELECT CAST(0 AS BIT)                    AS 'boolResult'
             , ERROR_MESSAGE()                   AS 'DescriptionResult'
             , CONVERT(BIGINT, 0)                AS 'NumTransferID'
             , CONCAT(@GuideSerie, @GuideNumber) AS 'Guide';

    END CATCH;

END;