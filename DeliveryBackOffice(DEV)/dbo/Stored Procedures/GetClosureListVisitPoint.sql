-- =============================================
-- Author:        <Alejandro Rodríguez>
-- Create date: <2022-03-29>
-- Description:    <SP para obtener la lista de cierres que se procesaron en un express center por VisitPoint>
-- Nota: Es una copia de GetClosureList
-- =============================================
-- =============================================
-- Author:        <Cristian Suazo>
-- Create date: <2024-07-04>
-- Description:    <Se agrega las cuentas y el simbolo de la moneda correspondiente para la vista de los cierres generales>
-- =============================================
-- =============================================
-- Author:        <Bilkar Morataya>
-- Create date: <2024-11-06>
-- Description:    <Se agrega campos para Zigi en la consulta de cierres>
-- =============================================
CREATE PROCEDURE [dbo].[GetClosureListVisitPoint]
@VisitPointId INT
,@StartDate datetime
,@EndDate datetime
AS
BEGIN
	
	DECLARE @IdCountry NVARCHAR(2),
		    @Account NVARCHAR(30),
			@AccountCOD NVARCHAR(30),
            @AccountZigi NVARCHAR(30);

	SELECT @IdCountry = CountryId 
	FROM VisitPointClient 
	WHERE CodeOfReference = @VisitPointId

	SELECT @Account = Name +' '+ '('+ AccountNumber +')' 
	FROM dbo.ClosureAccount 
	WHERE Description = 'Cuenta Express Center' AND ISNULL(IdCountry,'GT') = @IdCountry
	
	SELECT @AccountCOD = Name +' '+ '('+ AccountNumber +')' 
	FROM dbo.ClosureAccount 
	WHERE Description = 'Cuenta Área COD' AND ISNULL(IdCountry,'GT') = @IdCountry

	-- MODIFICACIÓN [17/10/2025] - Campos para Zigi
	SELECT @AccountZigi = Name +' '+ '('+ AccountNumber +')'
	FROM dbo.ClosureAccount
	WHERE Description = 'Cuenta Zigi' AND ISNULL(IdCountry,'GT') = @IdCountry

	SELECT ACH.IdAccountingClosuresHeaderVisitPoint 'ClosureId',
		ACH.VisitPoint 'VisitPointId',vpc.DescriptionOfClient 'VisitPoinDescription'
		,ACH.UserId,REU.UsrNickName 'UserDescription'
		,ACH.DateCreated 'DateCreated'
		,ACH.Voucher1,ACH.Bag1
		,ACH.Voucher2,ACH.Bag2
		,ACH.ClosurerPOS 'ClosurePOS'
		,ACH.TotalAmountCash
		,ACH.TotalAmountCashDeclared
		,ACH.TotalAmountCredit
		,ACH.TotalAmountCreditDeclared
		,ACH.TotalAmountCODCash
		-- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
		,ACH.TotalAmountCODCashDeclared
		,ACH.TotalAmountFacturaCash
		,ACH.TotalAmountFacturaCashDeclared
		,ACH.TotalAmountFacturaCard
		,ACH.TotalAmountFacturaCardDeclared
	     -- MODIFICACIÓN 17/10/2025 Bilkar Morataya
       ,ACH.TotalAmountZigi
       ,ACH.TotalAmountZigiDeclared
       ,ACH.TotalAmountCODZigi
       ,ACH.TotalAmountCODZigiDeclared
       ,ACH.TotalAmountFacturaZigi
       ,ACH.TotalAmountFacturaZigiDeclared
	     -- FIN MODIFICACIÓN
		,ISNULL(CCC.Symbol,'') CunrrencySymbol
	FROM DeliveryBackOffice.dbo.AccountingClosuresHeaderVisitPoint ACH
	INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC 
		ON ACH.VisitPoint = VPC.CodeOfReference
	INNER JOIN DeliveryBackOffice.dbo.RegisterUser REU 
		ON REU.UsrIdUser = ACH.UserId
	LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
		ON VPC.CountryId = DC.Currency_IdCountry
	LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
		ON DC.IdCurrencyCOD = CCC.IdCatCurrencyCOD
	WHERE CAST(ACH.DateCreated AS DATE) 
		BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
		AND (@VisitPointId = ACH.VisitPoint OR @VisitPointId = -1)
		AND DC.DefaultPerCountry = 1
		
	select @Account AS AccountExp,
		   @AccountCOD AS AccountCOD,
		   Value 'URL' from ConfigParams
	where Name = 'ClosureExpressCenter'

END
