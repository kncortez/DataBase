
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-10-25>
-- Description: <Obtener informacion para el reporte de "Modificación de montos COD", filtrado por guía o rango de fechas>
-- =============================================
-- =============================================
-- Author:      <Oscar,Rodriguez>
-- Update date: <2024-06-03>
-- Description: <Se agregaron validaciones para filtro de guias por pais, y tipo de moneda de la operacion>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_reportCODto0]
    @Guide VARCHAR(15),
    @InitialDate DATE,
    @FinalDate DATE,
	@Country VARCHAR(15) = 'GT'
AS
BEGIN
    SELECT (alc.GuideSerie + CONVERT(varchar(20), alc.GuideNumber)) Guía,
        do.Sender_FirstName + ' ' + do.Sender_LastName Cliente,
        do.PriceShippment 'Valor envío', alc.Voucher, alc.AuthorizedBy,
        cr.Name Razón,
        lgnlbt.SSN_Username Usuario,
        alc.DateCreated, alc.OldCODAmount, alc.NewCODAmount,
		IIF(dc.Symbol IS NULL, IIF(@Country = 'GT','Q','L'), REPLACE(REPLACE(REPLACE(dc.Symbol,'.',''),'(',''),')','')) [Currency_Symbol]
    FROM DeliveryBackOffice.dbo.AuthorizationLogCOD alc
    INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do
    ON alc.GuideSerie = do.Guide_Serie and alc.GuideNumber = do.Guide_Number
    INNER JOIN DeliveryBackOffice.dbo.CatReason cr
    ON cr.IdCatReason = alc.ReasonId
    INNER JOIN DenariusUser_Dev.dbo.LGN_LogByToken lgnlbt WITH (NOLOCK)
    ON lgnlbt.SSN_IdToken = alc.TokenCreated
    LEFT JOIN DeliveryBackOffice.dbo.Cost c WITH (NOLOCK)
      ON c.GuideSerie = do.Guide_Serie
     AND c.GuideNumber = do.Guide_Number
	LEFT JOIN dbo.CatCurrencyCOD dc WITH (NOLOCK)
    ON dc.IdCatCurrencyCOD = ISNULL(c.ShippingCurrency,1)
    WHERE do.SenderCountryId = @Country 
	AND (CONCAT(alc.GuideSerie, CONVERT(VARCHAR, alc.GuideNumber)) = @Guide OR
    (CONVERT(DATE, alc.DateCreated) BETWEEN @InitialDate AND @FinalDate));
END