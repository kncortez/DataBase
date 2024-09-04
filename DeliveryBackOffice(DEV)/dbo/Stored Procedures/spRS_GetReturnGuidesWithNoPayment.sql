
-- =============================================
-- Author:		<Andrés, Ruíz>
-- Create date: <2023-03-30>
-- Description:	<Retorna los tipos de una ruta>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-08-19>
-- Description:	<Filtra los datos por pais>
-- =============================================
CREATE PROCEDURE [dbo].[spRS_GetReturnGuidesWithNoPayment]

	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
	@IdCountry NVARCHAR(2) = 'GT'

AS
BEGIN

	DECLARE @ReturnStatusId INT = (
		SELECT 
			TOP (1) 
				SO.[StatusOrderId] 
		FROM 
			[DeliveryBackOffice].[dbo].[StatusOrder] SO  WITH(NOLOCK) 
		WHERE
			SO.[OrderDescription] = 'Devuelto'  COLLATE Latin1_General_CI_AI 
	)
	DECLARE @ReturnEXCStatusId INT = (
		SELECT 
			TOP (1) 
				SO.[StatusOrderId] 
		FROM 
			[DeliveryBackOffice].[dbo].[StatusOrder] SO  WITH(NOLOCK) 
		WHERE
			SO.[OrderDescription] = 'Devuelto en express center'  COLLATE Latin1_General_CI_AI 
	)

	-- Manejo de fechas
	IF(@EndDate IS NULL)
	BEGIN

		SET @EndDate = DATEADD(SECOND,-1,DATEADD(DAY,1,CAST(CAST(GETDATE() AS DATE) AS DATETIME)))

	END
	ELSE 
	BEGIN

		SET @EndDate = DATEADD(SECOND,-1,DATEADD(DAY,1,CAST(CAST(@EndDate AS DATE) AS DATETIME)))

	END

	IF(@StartDate IS NULL)
	BEGIN

		SET @StartDate = CAST(CAST(DATEADD(DAY,-0,@EndDate) AS DATE) AS DATETIME)

	END
	ELSE
	BEGIN

		SET @StartDate = CAST(CAST(@StartDate AS DATE) AS DATETIME)

	END

	IF(DATEDIFF(DAY,@StartDate, @EndDate) > 7)
	BEGIN

		SET @StartDate = CAST(CAST(DATEADD(DAY,-7,@EndDate) AS DATE) AS DATETIME)

	END

	IF OBJECT_ID('tempdb.dbo.#PreFilteredGuide', 'U') IS NOT NULL 
		DROP TABLE #PreFilteredGuide;
	IF OBJECT_ID('tempdb.dbo.#FilteredGuide', 'U') IS NOT NULL 
		DROP TABLE #FilteredGuide;

	DECLARE @ServiceCoverage TABLE (
		HeaderCode NVARCHAR(10),
		HubId INT
	);

	CREATE TABLE #PreFilteredGuide(
		GuideSerie NVARCHAR(2)
		,GuideNumber INT
		,DateCreated DATETIME
		,UserCreated NVARCHAR(50)
	);

	CREATE NONCLUSTERED INDEX IDX_TMP_PreFilteredGuide_Giode ON [#PreFilteredGuide] ([GuideSerie], [GuideNumber])

	CREATE TABLE #FilteredGuide(
		GuideSerie NVARCHAR(2)
		,GuideNumber INT
		,StatusOrder INT
		,ActualStatusOrder INT
		,DateStatus DATETIME
		,TokenStatus NVARCHAR(200)
		,SystemId INT
		,IsCollect BIT
		,SenderName NVARCHAR(600)
		,ReceiverName NVARCHAR(600)
		,ServicePrice DECIMAL(18,2)
		,OriginHub INT
		,CurrencySymbol NVARCHAR(2)
	);

	CREATE NONCLUSTERED INDEX IDX_TMP_FilteredGuide_Giode ON [#FilteredGuide] ([GuideSerie], [GuideNumber])
	CREATE NONCLUSTERED INDEX IDX_TMP_FilteredGuide_Token ON [#FilteredGuide] ([TokenStatus])

	INSERT INTO	@ServiceCoverage
	(
		[HeaderCode],
		[HubId]
	)
	SELECT
		[DSC].[HeaderCode]
		,MAX([HL].[IdHubLogistic])
	FROM
		[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC  WITH(NOLOCK) 
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[HubLogistics] HL  WITH(NOLOCK) 
			ON
				[DSC].[Hub] = [HL].[HubAbbreviation]
	WHERE ISNULL(HL.IdCountry,'GT') = @IdCountry
	GROUP BY
		[DSC].[HeaderCode]
	
	-- Guías en estado devuelto
	INSERT INTO [#PreFilteredGuide]
	(
		[GuideSerie],
		[GuideNumber],
		[DateCreated],
		[UserCreated]
	)
	SELECT 
		DISTINCT
			[DOD].[Guide_Serie],
			[DOD].[Guide_Number],
			[DOD].[DateCreated],
			[DOD].[UserCreated]
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD  WITH(NOLOCK) 
		INNER JOIN
			[DeliveryBackOffice].[dbo].[Cost] Co  WITH(NOLOCK) 
			ON
				[Co].[GuideSerie] = [DOD].[Guide_Serie] 
				AND 
				[Co].[GuideNumber] = [DOD].[Guide_Number]
				AND
				[Co].[TotalAmountPaid] IS NULL
		INNER JOIN DeliveryOrder DO WITH (NOLOCK)
			ON DOD.Guide_Serie = DO.Guide_Serie
			AND DOD.Guide_Number = DO.Guide_Number
		INNER JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD  WITH(NOLOCK) 
			ON
				[DOD].[Guide_Serie] = [DOPD].[GuideSerie]
				AND
				[DOD].[Guide_Number] = [DOPD].[GuideNumber]
				AND
				[DOPD].[TimePlaId] <> 4
	WHERE
		[DOD].[DateCreated] BETWEEN @StartDate AND @EndDate
		AND
		[DOD].[StatusOrderId] = @ReturnStatusId
		AND ISNULL(DO.SenderCountryId,'GT') = @IdCountry
	
	-- Guías en estado devuelto en express center
	INSERT INTO [#PreFilteredGuide]
	(
		[GuideSerie],
		[GuideNumber],
		[DateCreated],
		[UserCreated]
	)
	SELECT 
		DISTINCT
			[DOD].[Guide_Serie],
			[DOD].[Guide_Number],
			[DOD].[DateCreated],
			[DOD].[UserCreated]
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD  WITH(NOLOCK) 
		INNER JOIN
			[DeliveryBackOffice].[dbo].[Cost] Co  WITH(NOLOCK) 
			ON
				[Co].[GuideSerie] = [DOD].[Guide_Serie] 
				AND 
				[Co].[GuideNumber] = [DOD].[Guide_Number]
				AND
				[Co].[TotalAmountPaid] IS NULL
		INNER JOIN DeliveryOrder DO WITH (NOLOCK)
			ON DOD.Guide_Serie = DO.Guide_Serie
			AND DOD.Guide_Number = DO.Guide_Number
		INNER JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD  WITH(NOLOCK) 
			ON
				[DOD].[Guide_Serie] = [DOPD].[GuideSerie]
				AND
				[DOD].[Guide_Number] = [DOPD].[GuideNumber]
				AND
				[DOPD].[TimePlaId] <> 4
	WHERE
		[DOD].[DateCreated] BETWEEN @StartDate AND @EndDate
		AND
		[DOD].[StatusOrderId] = @ReturnEXCStatusId
		AND ISNULL(DO.SenderCountryId,'GT') = @IdCountry

	------ Guías en estado devuelto
	INSERT INTO [#FilteredGuide]
	(
		[GuideSerie],
		[GuideNumber],
		[StatusOrder],
		[ActualStatusOrder],
		[DateStatus],
		[TokenStatus],
		[SystemId],
		[IsCollect],
		[SenderName],
		[ReceiverName],
		[ServicePrice],
		[OriginHub],
		CurrencySymbol
	)
	SELECT 
		[DOD].[GuideSerie],
		[DOD].[GuideNumber],
		[DO].[StatusOrderId],
		[DO].[StatusOrderId],
		[DOD].[DateCreated],
		[DOD].[UserCreated],
		[DO].[CatSystemId],
		[DO].[IsCollect],
		LTRIM(RTRIM(CONCAT([DO].[Sender_FirstName],' ',[DO].[Sender_LastName]))),
		LTRIM(RTRIM(CONCAT([DO].[Receiver_FirstName],' ',[DO].[Receiver_LastName]))),
		[DO].[PriceShippment],
		[SC].[HubId],
		CASE WHEN ISNULL(DO.SenderCountryId,'GT') = 'GT' THEN 'Q.' ELSE 'L.' END CurrencySymbol
	FROM
		[#PreFilteredGuide] DOD
		INNER JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
			ON
				[DO].[Guide_Serie] = [DOD].[GuideSerie] 
				AND 
				[DO].[Guide_Number] = [DOD].[GuideNumber]
		INNER JOIN
			[DeliveryBackOffice].[dbo].[Province] Prv  WITH(NOLOCK) 
			ON
				[DO].[Sender_Department] = [Prv].[ProvinceName]  COLLATE Latin1_General_CI_AI 
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[Township] TwnByCode  WITH(NOLOCK) 
			ON
				[TwnByCode].[IdTownship] = [DO].[SenderIdTownship] 
				AND
				[Prv].[IdProvince] = [TwnByCode].[IdProvince]
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[Township] TwnByName  WITH(NOLOCK) 
			ON
				[TwnByName].[TownshipName] = DO.[Sender_Town]  COLLATE Latin1_General_CI_AI 
				AND
				[Prv].[IdProvince] = [TwnByName].[IdProvince]
		LEFT JOIN
			@ServiceCoverage SC
			ON
				[SC].[HeaderCode] = ISNULL([TwnByCode].[HeaderCode], [TwnByName].[HeaderCode])
		WHERE ISNULL(DO.SenderCountryId,'GT') = @IdCountry

	------ Guías en estado devuelto en express center
	INSERT INTO [#FilteredGuide]
	(
		[GuideSerie],
		[GuideNumber],
		[StatusOrder],
		[ActualStatusOrder],
		[DateStatus],
		[TokenStatus],
		[SystemId],
		[IsCollect],
		[SenderName],
		[ReceiverName],
		[ServicePrice],
		[OriginHub],
		CurrencySymbol
	)
	SELECT 
		[DOD].[GuideSerie],
		[DOD].[GuideNumber],
		[DO].[StatusOrderId],
		[DO].[StatusOrderId],
		[DOD].[DateCreated],
		[DOD].[UserCreated],
		[DO].[CatSystemId],
		[DO].[IsCollect],
		LTRIM(RTRIM(CONCAT([DO].[Sender_FirstName],' ',[DO].[Sender_LastName]))),
		LTRIM(RTRIM(CONCAT([DO].[Receiver_FirstName],' ',[DO].[Receiver_LastName]))),
		[DO].[PriceShippment],
		[SC].[HubId],
		CASE WHEN ISNULL(DO.SenderCountryId,'GT') = 'GT' THEN 'Q.' ELSE 'L.' END CurrencySymbol
	FROM
		[#PreFilteredGuide] DOD
		INNER JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
			ON
				[DO].[Guide_Serie] = [DOD].[GuideSerie] 
				AND 
				[DO].[Guide_Number] = [DOD].[GuideNumber]
		INNER JOIN
			[DeliveryBackOffice].[dbo].[Province] Prv  WITH(NOLOCK) 
			ON
				[DO].[Sender_Department] = [Prv].[ProvinceName]  COLLATE Latin1_General_CI_AI 
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[Township] TwnByCode  WITH(NOLOCK) 
			ON
				[TwnByCode].[IdTownship] = [DO].[SenderIdTownship] 
				AND
				[Prv].[IdProvince] = [TwnByCode].[IdProvince]
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[Township] TwnByName  WITH(NOLOCK) 
			ON
				[TwnByName].[TownshipName] = DO.[Sender_Town]  COLLATE Latin1_General_CI_AI 
				AND
				[Prv].[IdProvince] = [TwnByName].[IdProvince]
		LEFT JOIN
			@ServiceCoverage SC
			ON
				[SC].[HeaderCode] = ISNULL([TwnByCode].[HeaderCode], [TwnByName].[HeaderCode])
		WHERE ISNULL(DO.SenderCountryId,'GT') = @IdCountry

	SELECT
		ISNULL([CS].[SysNameSystem], 'Hermes Integraciones') [System]
		,CONCAT([DOD].[GuideSerie], [DOD].[GuideNumber]) [Guide]
		,(
			CASE
				WHEN [DOD].[IsCollect] = 1 THEN 'Si'
				ELSE 'No'
			END
		) [Collect]
		,[DOD].[SenderName] [Sender]
		,[DOD].[ReceiverName] [Receiver]
		,[DOD].[DateStatus] [DateReturn]
		,[SO].[OrderDescription] [ActualStatusOrder]
		,[DOD].[ServicePrice]
		,MAX(COALESCE([LGNLBT].[SSN_Username], [IU].[Username], (LTRIM(RTRIM(CONCAT( [SR].[First_Name],' ',[SR].[Last_Name])))))) [ReturnResponsible]
		,[HL].[HubAbbreviation] [OriginHub],
		DOD.CurrencySymbol
	FROM
		[#FilteredGuide] DOD
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK) 
			ON
				[DOD].[SystemId] = [CS].[SysIdSystem]
		INNER JOIN
			[DeliveryBackOffice].[dbo].[HubLogistics] HL  WITH(NOLOCK) 
			ON
				[DOD].[OriginHub] = [HL].[IdHubLogistic]
		INNER JOIN
			[DeliveryBackOffice].[dbo].[StatusOrder] SO  WITH(NOLOCK) 
			ON
				[DOD].[StatusOrder] = [SO].[StatusOrderId]
		-- Token desde Courier
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[LogTokenPOD] LTPOD  WITH(NOLOCK) 
			ON
				DOD.[TokenStatus] = [LTPOD].[LogTokenPOD]
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[SenderReceiver] SR  WITH(NOLOCK) 
			ON
				[LTPOD].[IdCourierman] = SR.[ID]
		-- Token desde Web
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[TokenLog] TL  WITH(NOLOCK) 
			ON
				[DOD].[TokenStatus] = [TL].[TknIdToken]
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[RegisterUser] RU  WITH(NOLOCK) 
			ON
				[RU].[UsrIdUser] = [TL].[TknIdUser]
		LEFT JOIN
			[DeliveryBackOffice].[dbo].[InternalUser] IU  WITH(NOLOCK) 
			ON
				[IU].[RegisterUserID] = [RU].[UsrIdUser]
		-- Token desde Desktop
		LEFT JOIN
			[DenariusUser_Dev].[dbo].[LGN_LogByToken] LGNLBT  WITH(NOLOCK) 
			ON
				[DOD].[TokenStatus] = [LGNLBT].[SSN_IdToken]
	GROUP BY
		[CS].[SysNameSystem]
		,[DOD].[GuideSerie]
		,[DOD].[GuideNumber]
		,[DOD].[IsCollect]
		,[DOD].[SenderName]
		,[DOD].[ReceiverName]
		,[DOD].[DateStatus]
		,[SO].[OrderDescription]
		,[DOD].[ServicePrice]
		,[HL].[HubAbbreviation]
		,DOD.CurrencySymbol
	ORDER BY
		[DOD].[GuideNumber] DESC
	
	IF OBJECT_ID('tempdb.dbo.#PreFilteredGuide', 'U') IS NOT NULL 
		DROP TABLE #PreFilteredGuide;
	IF OBJECT_ID('tempdb.dbo.#FilteredGuide', 'U') IS NOT NULL 
		DROP TABLE #FilteredGuide;

END;