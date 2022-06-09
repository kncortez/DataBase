

CREATE PROCEDURE [dbo].[sphd_reportCODto0]
	@Guide VARCHAR(15),
	@InitialDate DATE,
	@FinalDate DATE
AS
BEGIN
	SELECT (alc.GuideSerie + CONVERT(varchar(20), alc.GuideNumber)) Guía,
		do.Sender_FirstName + ' ' + do.Sender_LastName Cliente,
		do.PriceShippment 'Valor envío', alc.Voucher, alc.AuthorizedBy,
		cr.Name Razón,
		lgnlbt.SSN_Username Usuario,
		alc.DateCreated, alc.OldCODAmount, alc.NewCODAmount
	FROM DeliveryBackOffice.dbo.AuthorizationLogCOD alc
	INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do
	ON alc.GuideSerie = do.Guide_Serie and alc.GuideNumber = do.Guide_Number
	INNER JOIN DeliveryBackOffice.dbo.CatReason cr
	ON cr.IdCatReason = alc.ReasonId
	INNER JOIN DenariusUser_Dev.dbo.LGN_LogByToken lgnlbt
	ON lgnlbt.SSN_IdToken = alc.TokenCreated
	WHERE (alc.GuideSerie + CONVERT(VARCHAR, alc.GuideNumber) = @Guide) OR
	(CONVERT(DATE, alc.DateCreated) BETWEEN @InitialDate AND @FinalDate)
END
