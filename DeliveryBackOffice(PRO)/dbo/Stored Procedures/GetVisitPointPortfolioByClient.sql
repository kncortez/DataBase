
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2023-01-10>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================

CREATE PROCEDURE [dbo].[GetVisitPointPortfolioByClient]
	
	@AccountId BIGINT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from 6854
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET ARITHABORT ON;

	IF OBJECT_ID('tempdb.dbo.#VisitPointPortfolioMain', 'U') IS NOT NULL
        DROP TABLE #VisitPointPortfolioMain;
	IF OBJECT_ID('tempdb.dbo.#VisitPointPortfolioAddress', 'U') IS NOT NULL
        DROP TABLE #VisitPointPortfolioAddress;


	DECLARE @VisitPointClientId INT;

	SET @VisitPointClientId = (
		SELECT
			TOP 1 
				vp.IdVisitPointClient 
		FROM 
			[DeliveryBackOffice].[dbo].RegisterUser usr WITH(NOLOCK)
			LEFT JOIN 
				[DeliveryBackOffice].[dbo].[RolByUserByAccount] rua WITH(NOLOCK) 
				ON 
					rua.RuaIdUser = usr.UsrIdUser
					AND 
					rua.RuaRowStatus = 1
			INNER JOIN [DeliveryBackOffice].[dbo].[Account] ac WITH(NOLOCK) 
				ON 
					ac.AccIdAccount = rua.RuaIdAccount
					AND 
					ac.AccRowStatus = 1
			INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointByUser] vp WITH(NOLOCK) 
				ON 
					vp.RegisterUserID = usr.UsrIdUser
			WHERE 
				ac.AccIdAccount = @AccountId
	)

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
		ContactName NVARCHAR(200)
	)

	CREATE TABLE #VisitPointPortfolioAddress (
		VisitPointByClientPortfolioId BIGINT,
		IdAddress BIGINT,
		Province NVARCHAR(200),
		Township NVARCHAR(200),
		HeaderCode NVARCHAR(50),
		Address1 NVARCHAR(600),
		Phone NVARCHAR(200),
		AdditionalInstructions NVARCHAR(600),
		IdSettlement INT,
		SettlementDescription NVARCHAR(600),
		IdDeliveryOption INT,
		IsTDA BIT,
		HasSDD BIT,
		Hub NVARCHAR(50)
	)

	BEGIN TRY

		INSERT INTO
			#VisitPointPortfolioMain
			(
				IdVisitPointByClientPortfolio
				,InternalCode
				,FirstName
				,SecondName
				,LastName
				,SecondLastName
				,NirPhone
				,Phone
				,Email
				,CUI
				,ContactName
			)
		SELECT
			VPBCP.IdVisitPointByClientPortfolio
			,VPBCP.InternalCode
			,VPBCP.FirstName
			,VPBCP.SecondName
			,VPBCP.LastName
			,VPBCP.SecondLastName
			,VPBCP.NirPhone
			,VPBCP.Phone
			,VPBCP.Email
			,VPBCP.CUI
			,VPBCP.ContactName
		FROM
			[DeliveryBackOffice].[dbo].[VisitPointByClientPortfolio] VPBCP WITH(NOLOCK)
		WHERE 
			VPBCP.VisitPointId = @VisitPointClientId
			AND
			VPBCP.RowStatus = 1 

		INSERT INTO
			#VisitPointPortfolioAddress
			(
				VisitPointByClientPortfolioId
				,IdAddress
				,Province
				,Township
				,HeaderCode
				,Address1
				,Phone
				,AdditionalInstructions
				,IdSettlement
				,SettlementDescription
				,IdDeliveryOption
				,IsTDA
				,HasSDD
				,Hub
			)
		SELECT
			VPBCP.IdVisitPointByClientPortfolio
			,SUB.UadIdAddress
			,pr.ProvinceName
			,tw.TownshipName
			,tw.HeaderCode
			,SUB.UadAddress1
			,SUB.UadPhone
			,SUB.UadAdditionalInstructions
			,SUB.UadIdSettlement
			,st.Settlement
			,SUB.UadIdDeliveryOption
			,ISNULL(dsc.TDA,0) 'IsTDA'
			,ISNULL(dsc.SDD,0) 'HasSDD'
			,ISNULL(dsc.Hub,'') 'Hub'
		FROM
			[DeliveryBackOffice].[dbo].[VisitPointByClientPortfolio] VPBCP WITH(NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].UserAddress SUB WITH(NOLOCK)
				ON 
					SUB.VisitPointByClientPortfolioId = VPBCP.IdVisitPointByClientPortfolio 
					AND 
					SUB.UadRowStatus= 1
			LEFT JOIN [DeliveryBackOffice].[dbo].Township tw WITH(NOLOCK)
				ON 
					tw.IdTownship = SUB.UadIdTownship
			LEFT JOIN [DeliveryBackOffice].[dbo].Province pr WITH(NOLOCK)
				ON 
					pr.IdProvince = tw.IdProvince
			LEFT JOIN [DeliveryBackOffice].[dbo].Settlement st WITH(NOLOCK)
				ON 
					st.IdSettlement = SUB.UadIdSettlement AND st.SettlementSatus= 1
			LEFT JOIN [DeliveryBackOffice].[dbo].CatDeliveryOptions cdo WITH(NOLOCK)
				ON 
					cdo.IdDeliveryOption = SUB.UadIdDeliveryOption
			OUTER APPLY (
				SELECT
					TOP 1
						dsc.TDA
						,dsc.SDD
						,dsc.Hub
				FROM
					[DeliveryBackOffice].[dbo].DumpServiceCoverage dsc WITH(NOLOCK)
				WHERE 
					dsc.IdSettlement = st.IdSettlement AND dsc.RowStatus=1
			) dsc
		WHERE 
			VPBCP.VisitPointId = @VisitPointClientId
			AND
			VPBCP.RowStatus = 1 

		IF(EXISTS(SELECT TOP 1 1 FROM #VisitPointPortfolioMain) AND EXISTS(SELECT TOP 1 1 FROM #VisitPointPortfolioAddress))
		BEGIN

			SELECT
				200 'ResultCode',
				'Datos obtenidos exitosamente' 'ResultMessage'

			SELECT
				IdVisitPointByClientPortfolio
				,InternalCode
				,FirstName
				,SecondName
				,LastName
				,SecondLastName
				,NirPhone
				,Phone
				,Email
				,CUI
				,ContactName
			FROM
				#VisitPointPortfolioMain VPPM

			SELECT
				VPPA.VisitPointByClientPortfolioId
				,VPPA.IdAddress
				,VPPA.Province
				,VPPA.Township
				,VPPA.HeaderCode
				,VPPA.Address1
				,VPPA.Phone
				,VPPA.AdditionalInstructions
				,VPPA.IdSettlement
				,VPPA.SettlementDescription
				,VPPA.IdDeliveryOption
				,VPPA.IsTDA
				,VPPA.HasSDD
				,VPPA.Hub
			FROM
				#VisitPointPortfolioAddress VPPA

		END
		ELSE
		BEGIN

			SELECT
				204 'ResultCode',
				'Sin datos' 'ResultMessage'

		END

	END TRY
	BEGIN CATCH

		SELECT
			500 'ResultCode',
			ERROR_MESSAGE() 'ResultMessage'

	END CATCH
	
	IF OBJECT_ID('tempdb.dbo.#VisitPointPortfolioMain', 'U') IS NOT NULL
        DROP TABLE #VisitPointPortfolioMain;
	IF OBJECT_ID('tempdb.dbo.#VisitPointPortfolioAddress', 'U') IS NOT NULL
        DROP TABLE #VisitPointPortfolioAddress;

END