
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2023-01-10>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================
-- Author:		<Jerson Ochoa>
-- Update date: <2023-03-20>
-- Description:	<Optimización de proceso y aplicación de filtro>
-- =============================================

CREATE PROCEDURE [dbo].[GetVisitPointPortfolioByClient]
	
	@AccountId BIGINT,
	@FilterText NVARCHAR(25) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from 6854
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb.dbo.#VisitPointPortfolioMain', 'U') IS NOT NULL
        DROP TABLE #VisitPointPortfolioMain;


	DECLARE @VisitPointClientId INT;

	SET @VisitPointClientId = (	SELECT		TOP 1 [vp].[IdVisitPointClient] 
								FROM		[DeliveryBackOffice].[dbo].[RegisterUser] usr WITH(NOLOCK)
								LEFT JOIN	[DeliveryBackOffice].[dbo].[RolByUserByAccount] rua WITH(NOLOCK) 
									ON		[rua].[RuaIdUser] = [usr].[UsrIdUser]
									AND		[rua].[RuaRowStatus] = 1
								INNER JOIN	[DeliveryBackOffice].[dbo].[Account] ac WITH(NOLOCK) 
									ON		[ac].[AccIdAccount] = [rua].[RuaIdAccount]
									AND		[ac].[AccRowStatus] = 1
								INNER JOIN	[DeliveryBackOffice].[dbo].[VisitPointByUser] vp WITH(NOLOCK) 
									ON		[vp].[RegisterUserID] = [usr].[UsrIdUser]
								WHERE		[ac].[AccIdAccount] = @AccountId);

	-- Final response
	-- A nivel de base de datos si existen clientes que poseen más de mil registros
	CREATE TABLE #VisitPointPortfolioMain (
		IdVisitPointByClientPortfolio BIGINT,
		InternalCode NVARCHAR(200),
		FirstName NVARCHAR(200),
		SecondName NVARCHAR(200),
		LastName NVARCHAR(200),
		SecondLastName NVARCHAR(200),
		NirPhone NVARCHAR(50),
		Phone NVARCHAR(200),
		Email NVARCHAR(200),
		CUI NVARCHAR(200),
		ContactName NVARCHAR(200),
		IdAddress BIGINT,
		Province NVARCHAR(200),
		Township NVARCHAR(200),
		HeaderCode NVARCHAR(50),
		Address1 NVARCHAR(600),
		AdditionalInstructions NVARCHAR(600),
		IdSettlement INT,
		SettlementDescription NVARCHAR(600),
		IdDeliveryOption INT,
		IsTDA BIT,
		HasSDD BIT,
		Hub NVARCHAR(50)
	)

	INSERT INTO #VisitPointPortfolioMain (	[IdVisitPointByClientPortfolio],
											[InternalCode],
											[FirstName],
											[SecondName],
											[LastName],
											[SecondLastName],
											[NirPhone],
											[Phone],
											[Email],
											[CUI],
											[ContactName],
											[IdAddress],
											[Province],
											[Township],
											[HeaderCode],
											[Address1],
											[AdditionalInstructions],
											[IdSettlement],
											[SettlementDescription],
											[IdDeliveryOption],
											[IsTDA],
											[HasSDD],
											[Hub]
											)
	SELECT									TOP 100
											[VPBCP].[IdVisitPointByClientPortfolio],
											[VPBCP].[InternalCode],
											[VPBCP].[FirstName],
											[VPBCP].[SecondName],
											[VPBCP].[LastName],
											[VPBCP].[SecondLastName],
											[VPBCP].[NirPhone],
											[VPBCP].[Phone],
											[VPBCP].[Email],
											[VPBCP].[CUI],
											[VPBCP].[ContactName],
											[SUB].[UadIdAddress],
											[pr].[ProvinceName],
											[tw].[TownshipName],
											[tw].[HeaderCode],
											[SUB].[UadAddress1],
											[SUB].[UadAdditionalInstructions],
											[SUB].[UadIdSettlement],
											[st].[Settlement],
											[SUB].[UadIdDeliveryOption],
											ISNULL([dsc].[TDA],0) 'IsTDA',
											ISNULL([dsc].[SDD],0) 'HasSDD',
											ISNULL([dsc].[Hub],'') 'Hub'
	FROM									[DeliveryBackOffice].[dbo].[VisitPointByClientPortfolio] VPBCP WITH(NOLOCK)
	LEFT JOIN								[DeliveryBackOffice].[dbo].[UserAddress] SUB WITH(NOLOCK)
		ON									[SUB].[VisitPointByClientPortfolioId] = [VPBCP].[IdVisitPointByClientPortfolio] 
		AND									[SUB].[UadRowStatus] = 1
	LEFT JOIN								[DeliveryBackOffice].[dbo].[Township] tw WITH(NOLOCK)
		ON									[tw].[IdTownship] = [SUB].[UadIdTownship]
	LEFT JOIN								[DeliveryBackOffice].[dbo].[Province] pr WITH(NOLOCK)
		ON									[pr].[IdProvince] = [tw].[IdProvince]
	LEFT JOIN								[DeliveryBackOffice].[dbo].Settlement st WITH(NOLOCK)
		ON									[st].[IdSettlement] = [SUB].[UadIdSettlement] 
		AND									[st].[SettlementSatus] = 1
	LEFT JOIN								[DeliveryBackOffice].[dbo].[CatDeliveryOptions] cdo WITH(NOLOCK)
		ON									[cdo].[IdDeliveryOption] = [SUB].[UadIdDeliveryOption]
	OUTER APPLY (	SELECT TOP 1			[dsc].[TDA],
											[dsc].[SDD],
											[dsc].[Hub]
					FROM					[DeliveryBackOffice].[dbo].[DumpServiceCoverage] dsc WITH(NOLOCK)
					WHERE					[dsc].[IdSettlement] = [st].[IdSettlement] AND [dsc].[RowStatus] = 1
				) dsc
	WHERE									[VPBCP].[VisitPointId] = @VisitPointClientId
		AND									[VPBCP].[RowStatus] = 1 
		AND									(
												(@FilterText IS NULL OR LOWER([VPBCP].[InternalCode]) LIKE CONCAT('%', LOWER(@FilterText) , '%'))
											OR	(@FilterText IS NULL OR LOWER([VPBCP].[FirstName]) LIKE CONCAT('%', LOWER(@FilterText) , '%'))
											OR	(@FilterText IS NULL OR LOWER([VPBCP].[SecondName]) LIKE CONCAT('%', LOWER(@FilterText) , '%'))
											OR	(@FilterText IS NULL OR LOWER([VPBCP].[LastName]) LIKE CONCAT('%', LOWER(@FilterText) , '%'))
											OR	(@FilterText IS NULL OR LOWER([VPBCP].[SecondLastName]) LIKE CONCAT('%', LOWER(@FilterText) , '%'))
											OR	(@FilterText IS NULL OR LOWER([VPBCP].[Phone]) LIKE CONCAT('%', LOWER(@FilterText) , '%'))
											OR	(@FilterText IS NULL OR LOWER([VPBCP].[CUI]) LIKE CONCAT('%', LOWER(@FilterText) , '%'))
											OR	(@FilterText IS NULL OR LOWER([SUB].[UadAddress1]) LIKE CONCAT('%', LOWER(@FilterText) , '%'))
											OR	(@FilterText IS NULL OR LOWER([SUB].[UadAddress2]) LIKE CONCAT('%', LOWER(@FilterText) , '%'))
											)
												
												;

	SELECT	[IdVisitPointByClientPortfolio],
			[InternalCode],
			[FirstName],
			[SecondName],
			[LastName],
			[SecondLastName],
			[NirPhone],
			[Phone],
			[Email],
			[CUI],
			[ContactName],
			[IdAddress],
			[Province],
			[Township],
			[HeaderCode],
			[Address1],
			[Phone],
			[AdditionalInstructions],
			[IdSettlement],
			[SettlementDescription],
			[IdDeliveryOption],
			[IsTDA],
			[HasSDD],
			[Hub]
	FROM	#VisitPointPortfolioMain;
	
	IF OBJECT_ID('tempdb.dbo.#VisitPointPortfolioMain', 'U') IS NOT NULL
        DROP TABLE #VisitPointPortfolioMain;

END