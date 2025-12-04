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
-- =============================================
-- System:		<API>
-- Author:		<Bilkar Morataya>
-- Create date: <2025-09-09>
-- Description:	<Validación de estatus de link tanto para Uniguías y Multiguías de EXC>
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
    SET NOCOUNT ON;

	-- =============================================
    -- 1. Verificar si ya está pagado y retornar información completa
    -- =============================================
	IF EXISTS(SELECT 1 FROM PaymentZigi WHERE GuideNumber = @GuideNumber AND GuideSerie = @GuideSerie AND ZigiLinkStatus = 'PAID')
	BEGIN
			SELECT  201 AS IdResult,
			'Guia ha sido pagada' AS [Message],
			ZI.ZigiLink,
			CASE WHEN @GuideSerie = 'MFD' THEN ZI.ZigiPaymentId ELSE ZI.GuideNumber END AS GuideNumber,
			CASE WHEN @GuideSerie = 'MFD' THEN @GuideSerie ELSE ZI.GuideSerie END AS GuideSerie,
			ZI.PaidAmount AS Amount,
			IIF(DO.Receiver_FirstName = '',DO.Receiver_Alternant_FullName,DO.Receiver_FirstName) AS ReceiverName,
			DO.Receiver_LastName AS ReceiverLastName,
			DO.Receiver_Phone AS Phone,
			DO.ReceiverCountryId AS IdCountry,
			CC.Symbol,
			1 AS IsPay,
			ZI.ZigiTransactionId AS ZigiTransactionId,
			ZI.ZigiReference AS ZigiReference,
			ZI.IsGroup AS IsGroup,
			ZI.GeneratedMethod AS GeneratedMethod
	FROM PaymentZigi ZI WITH(NOLOCK)
	INNER JOIN DeliveryOrder DO WITH(NOLOCK)
	ON ZI.GuideNumber = DO.Guide_Number
	AND ZI.GuideSerie = DO.Guide_Serie
	LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
		ON DO.ReceiverCountryId = DC.Currency_IdCountry
	LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CC WITH(NOLOCK)
		ON DC.IdCurrencyCOD = CC.IdCatCurrencyCOD
	WHERE (
            (ZI.GuideNumber = @GuideNumber
                AND ZI.GuideSerie = @GuideSerie)
            -- Para Multiguías agrupadas en un solo link Zigi: VERIFICAR SI @GuideSerie es = MFD, se evalua ZI.ZigiPaymentId con @GuideNumber
               OR (@GuideSerie = 'MFD' AND ZI.ZigiPaymentId = @GuideNumber)
        )
	AND DC.DefaultPerCountry = 1
	AND ZI.ZigiLinkStatus = 'PAID'
	AND ZI.RowStatus = 1
	RETURN
	END

    -- =============================================
    -- 2. Actualizar banderas y teléfono si aplica
    -- =============================================
    UPDATE DeliveryBackOffice.dbo.PaymentZigi
    SET LinkRequestSent = 0,
        DateUpdated = GETDATE(),
        TokenUpdated = @Token
    WHERE RowStatus = 1 
      AND LinkRequestSent = 1 
      AND PaymentConfirmSent = 0 
      AND ZigiLinkStatus = 'CREATED'
      AND GuideNumber = @GuideNumber 
      AND GuideSerie = @GuideSerie;

    UPDATE DeliveryBackOffice.dbo.PaymentZigi
    SET PhoneNumber = @PhoneNumber
    WHERE RowStatus = 1 
      AND PaymentConfirmSent = 0 
      AND ZigiLinkStatus = 'CREATED'
      AND GuideNumber = @GuideNumber 
      AND GuideSerie = @GuideSerie;

    -- =============================================
    -- 3. Seleccionar la información del link para guías con estado CREATED
    -- =============================================
	SELECT  200 AS IdResult,
				'Guia tiene link asociado' AS [Message],
				ZI.ZigiLink,
				CASE WHEN @GuideSerie = 'MFD' THEN ZI.ZigiPaymentId ELSE ZI.GuideNumber END AS GuideNumber,
				CASE WHEN @GuideSerie = 'MFD' THEN @GuideSerie ELSE ZI.GuideSerie END AS GuideSerie,
				ZI.PaidAmount AS Amount,
				IIF(DO.Receiver_FirstName = '',DO.Receiver_Alternant_FullName,DO.Receiver_FirstName) AS ReceiverName,
				DO.Receiver_LastName AS ReceiverLastName,
				ISNULL(ZI.PhoneNumber, DO.Receiver_Phone) AS Phone,
				DO.ReceiverCountryId AS IdCountry,
				CC.Symbol,
				0 AS IsPay,
				ZI.ZigiTransactionId AS ZigiTransactionId,
				ZI.ZigiReference AS ZigiReference,
				ZI.IsGroup AS IsGroup,
				ZI.GeneratedMethod AS GeneratedMethod
		FROM PaymentZigi ZI WITH(NOLOCK)
		INNER JOIN DeliveryOrder DO WITH(NOLOCK)
		ON ZI.GuideNumber = DO.Guide_Number
		AND ZI.GuideSerie = DO.Guide_Serie
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
			ON DO.ReceiverCountryId = DC.Currency_IdCountry
		LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CC WITH(NOLOCK)
			ON DC.IdCurrencyCOD = CC.IdCatCurrencyCOD
		WHERE (
                (ZI.GuideNumber = @GuideNumber AND ZI.GuideSerie = @GuideSerie)
		        -- Para Multiguías agrupadas en un solo link Zigi: VERIFICAR SI @GuideSerie es = MFD, se evalua ZI.ZigiPaymentId con @GuideNumber
               OR (@GuideSerie = 'MFD' AND ZI.ZigiPaymentId = @GuideNumber)
        )
		AND DC.DefaultPerCountry = 1
		AND ZI.ZigiLinkStatus = 'CREATED'
		AND ZI.RowStatus = 1
END
