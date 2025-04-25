-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2025-11-04>
-- Description:	<ZIGI - Obtener informacion de link de pago zigi por guia>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWGetInfoZigiPaymentLink]
	@GuideNumber INT,
	@GuideSerie NVARCHAR(50)
AS
BEGIN

	IF EXISTS(SELECT 1 FROM PaymentZigi WITH(NOLOCK) WHERE GuideNumber = @GuideNumber AND GuideSerie = @GuideSerie AND ZigiLinkStatus = 'PAID')
	BEGIN
		SELECT  201 AS IdResult,
			'Guia ha sido pagada' AS [Message],
			ZI.ZigiLink,
			ZI.GuideNumber,
			ZI.GuideSerie,
			ZI.PaidAmount AS Amount,
			IIF(DO.Receiver_FirstName = '',DO.Receiver_Alternant_FullName,DO.Receiver_FirstName) AS ReceiverName,
			DO.Receiver_LastName AS ReceiverLastName,
			DO.Receiver_Phone AS Phone,
			DO.ReceiverCountryId AS IdCountry,
			CC.Symbol 
		FROM PaymentZigi ZI WITH(NOLOCK)
		INNER JOIN DeliveryOrder DO WITH(NOLOCK)
		ON ZI.GuideNumber = DO.Guide_Number
		AND ZI.GuideSerie = DO.Guide_Serie
		LEFT JOIN Cost CS WITH(NOLOCK)
		ON CS.GuideNumber = ZI.GuideNumber
			AND CS.GuideSerie = ZI.GuideSerie
		LEFT JOIN CatCurrencyCOD CC
			ON ISNULL(CS.CodCurrency,1) = CC.IdCatCurrencyCOD
		WHERE ZI.GuideNumber = @GuideNumber 
		AND ZI.GuideSerie = @GuideSerie 
		AND ZI.ZigiLinkStatus = 'PAID'
		AND ZI.RowStatus = 1
		RETURN
	END

	SELECT  200 AS IdResult,
				'Guia tiene link asociado' AS [Message],
				ZI.ZigiLink,
				ZI.GuideNumber,
				ZI.GuideSerie,
				ZI.PaidAmount AS Amount,
				IIF(DO.Receiver_FirstName = '',DO.Receiver_Alternant_FullName,DO.Receiver_FirstName) AS ReceiverName,
				DO.Receiver_LastName AS ReceiverLastName,
				DO.Receiver_Phone AS Phone,
				DO.ReceiverCountryId AS IdCountry,
				CC.Symbol 
		FROM PaymentZigi ZI WITH(NOLOCK)
		INNER JOIN DeliveryOrder DO WITH(NOLOCK)
		ON ZI.GuideNumber = DO.Guide_Number
		AND ZI.GuideSerie = DO.Guide_Serie
		LEFT JOIN Cost CS WITH(NOLOCK)
		ON CS.GuideNumber = ZI.GuideNumber
			AND CS.GuideSerie = ZI.GuideSerie
		LEFT JOIN CatCurrencyCOD CC WITH(NOLOCK)
			ON ISNULL(CS.CodCurrency,1) = CC.IdCatCurrencyCOD
		WHERE ZI.GuideNumber = @GuideNumber 
		AND ZI.GuideSerie = @GuideSerie 
		AND ZI.ZigiLinkStatus = 'CREATED'
		AND ZI.RowStatus = 1
END
