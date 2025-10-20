/*
EXEC GetClosureList
@VisitPointId = -1
,@StartDate = '20210627'
,@EndDate = '20210627'
*/
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-07-05>
-- Description:	<Se agrega la moneda correspondiente al express center>
-- =============================================
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2025-10-17>
-- Description:	<Se agrega el método de pago Zigi en los totales>
-- Important:	<Algunos elementos del SP parece que no estaban versionados>
-- =============================================

CREATE PROCEDURE [dbo].[GetClosureList] 
    @VisitPointId INT,
    @StartDate DATETIME,
    @EndDate DATETIME
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

    SELECT ACH.IdAccountingClosuresHeader 'ClosureId',
           ACH.VisitPoint 'VisitPointId',
           VPC.DescriptionOfClient 'VisitPoinDescription',
           ACH.UserId,
           REU.UsrNickName 'UserDescription',
           ACH.DateCreated 'DateCreated',
           ACH.Voucher1,
           ACH.Bag1,
           ACH.Voucher2,
           ACH.Bag2,
           ACH.TotalAmountCash,
           ACH.TotalAmountCashDeclared,
           ACH.TotalAmountCredit,
           ACH.TotalAmountCreditDeclared,
           ACH.TotalAmountCODCash,
           -- MODIFICACIÓN 21/03/2022 OSCAR ALEJANDRO RODRÍGUEZ CALDERÓN
           ACH.TotalAmountCODCashDeclared,
           ACH.TotalAmountFacturaCash,
           ACH.TotalAmountFacturaCashDeclared,
           ACH.TotalAmountFacturaCard,
           ACH.TotalAmountFacturaCardDeclared,
           -- MODIFICACIÓN 17/10/2025 Bilkar Morataya
           ACH.TotalAmountZigi,
           ACH.TotalAmountZigiDeclared,
           ACH.TotalAmountCODZigi,
           ACH.TotalAmountCODZigiDeclared,
           ACH.TotalAmountFacturaZigi,
           ACH.TotalAmountFacturaZigiDeclared,
		   ISNULL(CCC.Symbol,'') AS CurrencySymbol
    -- FIN MODIFICACIÓN
    FROM DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
        INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC
            ON ACH.VisitPoint = VPC.CodeOfReference
        INNER JOIN DeliveryBackOffice.dbo.RegisterUser REU
            ON REU.UsrIdUser = ACH.UserId
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
			ON ISNULL(VPC.CountryId,'GT') = DC.Currency_IdCountry
		LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
			ON DC.IdCurrencyCOD = CCC.IdCatCurrencyCOD
    WHERE CAST(ACH.DateCreated AS DATE)
          BETWEEN CAST(@StartDate AS DATE) AND CAST(@EndDate AS DATE)
		  AND DC.DefaultPerCountry = 1
          AND
          (
              @VisitPointId = ACH.VisitPoint
              OR @VisitPointId = -1
          );

    SELECT @Account AS AccounExp,
		   @AccountCOD AS AccountCOD,
		   @AccountZigi AS AccountZigi,
		  Value 'URL'
    FROM ConfigParams
    WHERE Name = 'ClosureExpressCenter';

END;