-- =============================================
-- Author:		<Cristian Azurdia>
-- Update date: <2024-09-26>
-- Description: <Genera listado de incidencias en liquidaciones>

-- =============================================
CREATE PROCEDURE [dbo].[spHM_GetSettlementIncidenceValidate]
	@RouteId INT = 0,
	@CourierId INT = 0,
	@IncidenceId INT = 0,
	@HubId INT = 0,
	@UserId INT = 0,
	@CountryId VARCHAR(5) = 'GT'
AS
BEGIN

	SET NOCOUNT ON;

	select	 msi.IdManifestSettlementIncidence         [id]
			,cr.CodeRoute                              [CodeRoute]
			,msi.ManifestNumber						   [ManifestNumber]
			,CONCAT(sr.First_Name, ' ', sr.Last_Name)  [Pilot]
			,cti.NameIncidence						   [NameIncidence]
			,msi.DateCreated						   [DateCreated]
			,CONCAT(ccc.Symbol,msi.TotalAmount)   [TotalAmount]
			,msi.GuidesQuantity	                       [GuidesQuantity]
			,msi.TotalNumberOfPieces                   [TotalNumberOfPieces]
			,v2.ManagementLevelName                    [Validated]
			,ISNULL(v.Validator,'')                    [Validator]
			,ISNULL(msi.DateValidator,'')              [DateValidator]
			,IIF(msi.IncidenceApproved = 0 , 'Pendiente', 'Aprobada') [IncidenceApproved]
			,msi.IncidenceComment
			,IIF( msi.IncidenceApproved = 1, 0, IIF(msi.TotalAmount <= isNull(U.MaxAmount,100000), 1, 0)) [Enabled] 
			--,msi.isCOD
	FROM ManifestSettlementIncidence								msi WITH (NOLOCK)
		INNER JOIN [DeliveryBackOffice].[dbo].CatRoute				cr	WITH (NOLOCK)
			on cr.IdRoute = msi.CatRouteId
		INNER JOIN [DeliveryBackOffice].[dbo].SenderReceiver		sr	WITH (NOLOCK)
			on sr.ID = msi.CourierId
		INNER JOIN [DeliveryBackOffice].[dbo].CatTypeIncidence		cti	WITH (NOLOCK) 
			on cti.IdIncidenceType = msi.CatManifestSettlementIncidenceTypeId
		LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryCurrency]     de	WITH (NOLOCK)
			ON  de.Currency_IdCountry = ISNULL(cr.CountryId,'GT')
			AND de.DefaultPerCountry = 1
		LEFT JOIN [DeliveryBackOffice].[dbo].[CurrencyExchangeRates] ce WITH (NOLOCK)
			ON ce.TargetCurrency = de.IdCurrencyCOD
			and CONVERT(date,ce.ExchangeDate) = CONVERT(date,getdate())
		LEFT JOIN [DeliveryBackOffice].[dbo].[CatCurrencyCOD]		ccc WITH (NOLOCK)
			ON ccc.IdCatCurrencyCOD = de.IdCurrencyCOD
		outer apply(
			SELECT iu.IdUser                                   [IdUser]     
				   ,CONCAT(p.PerFirstName, ' ', p.PerLastName) [Validator]
			FROM		RegisterUser        ru    WITH(NOLOCK)
			INNER JOIN  InternalUser        iu    WITH(NOLOCK)
				ON iu.RegisterUserID  = ru.UsrIdUser
			INNER JOIN Person p				 WITH (NOLOCK)
				ON P.PerIdPerson = ru.UsrIdPerson
			WHERE  iu.IdUser = msi.IdValidator
		) V
		outer apply(
			SELECT ManagementLevelName 
			FROM CatManagementLevel 
			WHERE MinAmount <= msi.TotalAmount 
			  AND msi.TotalAmount  <= isnull(MaxAmount,100000)
			  AND CountryId = @CountryId
		)v2
		outer apply(
			SELECT ISNULL(cml.MaxAmount,0)      [MaxAmount]
			FROM		InternalUser			iu   WITH(NOLOCK)
			INNER JOIN  RegisterUser            ru    WITH(NOLOCK)
				ON iu.RegisterUserID  = ru.UsrIdUser
			LEFT JOIN ManagementLevelByUser     mlbu  WITH(NOLOCK)
				ON ru.UsrIdUser = mlbu.RegisterUserId
				AND mlbu.RowStatus = 1
			LEFT JOIN	CatManagementLevel		cml	 WITH(NOLOCK)
				ON mlbu.CatManagementLevelId = cml.IdCatManagementLevel
				AND cml.RowStatus = 1
			WHERE iu.IdUser = @UserId
		) U
	WHERE msi.RowStatus = 1
		AND ( @RouteId = 0 or cr.IdRoute = @RouteId )
		AND ( @CourierId = 0 or sr.ID = @CourierId )
		AND ( @IncidenceId = 0 or cti.IdIncidenceType = @IncidenceId )
		AND ( @HubId = 0 or cr.IdRoute = @HubId )
		AND  msi.CountryId = @CountryId
	ORDER BY msi.DateCreated desc;

END