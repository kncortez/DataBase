-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2025-11-04>
-- Description:	<ZIGI - Obtener informacion de link de pago zigi por guia>
-- =============================================
-- =============================================
-- System:		<API>
-- Author:		<Walter Orozco>
-- Create date: <2025-08-21>
-- Description:	<Se agrega actualizacion de la bandera para solicitud de link zigi enviado por whatsapp.>
-- =============================================
-- =============================================
-- System:		<API>
-- Author:		<Bilkar Morataya>
-- Create date: <2025-09-03>
-- Description:	<Si se recibe PhoneNumber distinto a null, se usa el recibido y se modifica en la tabla PaymentZigi para ser usado; si es null, se usa el de la tabla DeliveryOrder.>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWGetInfoZigiPaymentLink]
(
  @GuideNumber INT
 ,@GuideSerie NVARCHAR(50)
 ,@Token NVARCHAR(200) = 'SYS-SPHWGetInfoZigiPaymentLink'
 ,@PhoneNumber NVARCHAR(20) = NULL
)
AS
BEGIN

	IF EXISTS(SELECT 1 FROM PaymentZigi WHERE GuideNumber = @GuideNumber AND GuideSerie = @GuideSerie AND ZigiLinkStatus = 'PAID')
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
	LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
		ON DO.ReceiverCountryId = DC.Currency_IdCountry
	LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CC WITH(NOLOCK)
		ON DC.IdCurrencyCOD = CC.IdCatCurrencyCOD
	WHERE ZI.GuideNumber = @GuideNumber 
	AND ZI.GuideSerie = @GuideSerie 
	AND DC.DefaultPerCountry = 1
	AND ZI.ZigiLinkStatus = 'PAID'
	AND ZI.RowStatus = 1
	RETURN
	END

	-- Actualizar bandera para envio de mensaje por WhatsApp
	UPDATE DeliveryBackOffice.dbo.PaymentZigi
	SET LinkRequestSent = 0, DateUpdated = GETDATE(), TokenUpdated = @Token
	WHERE RowStatus = 1 AND LinkRequestSent = 1 AND PaymentConfirmSent = 0 AND ZigiLinkStatus = 'CREATED' 
	AND GuideNumber = @GuideNumber AND GuideSerie = @GuideSerie;

	-- ACTUALIZAR PhoneNumber en la tabla PaymentZigi, aunque no se haya enviado, esto favorece el flujo de Zigi desde EXC
	UPDATE DeliveryBackOffice.dbo.PaymentZigi
	SET PhoneNumber = @PhoneNumber
	WHERE RowStatus = 1 AND PaymentConfirmSent = 0 AND ZigiLinkStatus = 'CREATED' 
	AND GuideNumber = @GuideNumber AND GuideSerie = @GuideSerie;

	SELECT  200 AS IdResult,
				'Guia tiene link asociado' AS [Message],
				ZI.ZigiLink,
				ZI.GuideNumber,
				ZI.GuideSerie,
				ZI.PaidAmount AS Amount,
				IIF(DO.Receiver_FirstName = '',DO.Receiver_Alternant_FullName,DO.Receiver_FirstName) AS ReceiverName,
				DO.Receiver_LastName AS ReceiverLastName,
				ISNULL(ZI.PhoneNumber, DO.Receiver_Phone) AS Phone,
				DO.ReceiverCountryId AS IdCountry,
				CC.Symbol 
		FROM PaymentZigi ZI WITH(NOLOCK)
		INNER JOIN DeliveryOrder DO WITH(NOLOCK)
		ON ZI.GuideNumber = DO.Guide_Number
		AND ZI.GuideSerie = DO.Guide_Serie
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
			ON DO.ReceiverCountryId = DC.Currency_IdCountry
		LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CC WITH(NOLOCK)
			ON DC.IdCurrencyCOD = CC.IdCatCurrencyCOD
		WHERE ZI.GuideNumber = @GuideNumber 
		AND ZI.GuideSerie = @GuideSerie 
		AND DC.DefaultPerCountry = 1
		AND ZI.ZigiLinkStatus = 'CREATED'
		AND ZI.RowStatus = 1
END