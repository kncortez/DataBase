-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2025-09-04>
-- Description:	<ZIGI - Valida si el usuario ha pagado con zigi>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWValidateZigiUserPayment]
	@GuideNumber INT,
	@GuideSerie NVARCHAR(50)
AS
BEGIN

	--validar si ya fue pagada en rastreo
	DECLARE @EnablePaidZigi INT = 1;
	IF EXISTS(SELECT 1 FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DOR WITH (NOLOCK)
					 INNER JOIN [DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer] CCTBC WITH(NOLOCK)  
						ON CCTBC.OrderNumber = DOR.Guide_Serie + CONVERT(VARCHAR,DOR.Guide_Number)
					 where DOR.Guide_Serie = @GuideSerie  
						AND DOR.Guide_Number = @GuideNumber
						AND CCTBC.ReasonCode = '00')
	BEGIN
		SET @EnablePaidZigi = 0;
	END
	--verificar guia collect
	IF NOT EXISTS (SELECT 1 FROM DeliveryOrder WITH(NOLOCK) WHERE Guide_Number = @GuideNumber AND Guide_Serie = @GuideSerie AND IsCollect = 1 )
	BEGIN
		SELECT 400 [IdResult],
			'la guia no es collect' AS [Message],
			0				AS [PaidZigi],
			@GuideNumber	AS GuideNumber,
			@GuideSerie		AS GuideSerie,
			0				AS [LinkCreated],
			0				AS [IsPay],
			''				AS [LinkZigi];
		RETURN;
	END
	
	IF NOT EXISTS (SELECT 1 FROM PaymentZigi WITH(NOLOCK) WHERE GuideNumber = @GuideNumber AND GuideSerie = @GuideSerie)
	BEGIN
		SELECT 200 [IdResult],
			'Guia no tiene link asociado ' AS [Message],
			@EnablePaidZigi	AS [PaidZigi],
			@GuideNumber	AS GuideNumber,
			@GuideSerie		AS GuideSerie,
			0				AS [LinkCreated],
			0				AS [IsPay],
			''				AS [LinkZigi];
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM PaymentZigi WITH(NOLOCK) WHERE GuideNumber = @GuideNumber AND GuideSerie = @GuideSerie AND ZigiLinkStatus = 'CREATED')
	BEGIN
		SELECT 200 [IdResult],
			'Guia link creado' AS [Message],
			@EnablePaidZigi	AS [PaidZigi],
			@GuideNumber	AS GuideNumber,
			@GuideSerie		AS GuideSerie,
			1				AS [LinkCreated],
			0				AS [IsPay],
			ZigiLink		AS [LinkZigi]
		FROM PaymentZigi WITH(NOLOCK)
		WHERE GuideNumber = @GuideNumber 
		AND GuideSerie = @GuideSerie 
		AND ZigiLinkStatus = 'CREATED';
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM PaymentZigi WITH(NOLOCK) WHERE GuideNumber = @GuideNumber AND GuideSerie = @GuideSerie AND ZigiLinkStatus = 'PAID')
	BEGIN
		SELECT 400 AS [IdResult],
			'Link de Guia ha sido pagado'	AS [Message],
			@EnablePaidZigi	AS [PaidZigi],
			@GuideNumber	AS GuideNumber,
			@GuideSerie		AS GuideSerie,
			1				AS [LinkCreated],
			1				AS [IsPay],
			ZigiLink		AS [LinkZigi]
		FROM PaymentZigi WITH(NOLOCK) 
		WHERE GuideNumber = @GuideNumber 
		AND GuideSerie = @GuideSerie 
		AND ZigiLinkStatus = 'PAID'
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM PaymentZigi WITH(NOLOCK) WHERE GuideNumber = @GuideNumber AND GuideSerie = @GuideSerie AND ZigiLinkStatus = 'CANCELED')
	BEGIN
		SELECT 1 AS [IdResult],
			'Link HA SIDO DESHABILITADO'	AS [Message],
			@EnablePaidZigi	AS [PaidZigi],
			@GuideNumber	AS GuideNumber,
			@GuideSerie		AS GuideSerie,
			1				AS [LinkCreated],
			0				AS [IsPay],
			ZigiLink		AS [LinkZigi]
			FROM PaymentZigi WITH(NOLOCK) 
			WHERE GuideNumber = @GuideNumber 
			AND GuideSerie = @GuideSerie 
			AND ZigiLinkStatus = 'CANCELED'
		RETURN;
	END
	IF EXISTS (SELECT 1 FROM PaymentZigi WITH(NOLOCK) WHERE GuideNumber = @GuideNumber AND GuideSerie = @GuideSerie AND ZigiLinkStatus = 'FAILED')
	BEGIN
		SELECT 1 AS [IdResult],
			'Link ha fallado'	AS [Message],
			@EnablePaidZigi	AS [PaidZigi],
			@GuideNumber	AS GuideNumber,
			@GuideSerie		AS GuideSerie,
			0				AS [LinkCreated],
			0				AS [IsPay],
			ZigiLink		AS [LinkZigi]
			FROM PaymentZigi WITH(NOLOCK) 
			WHERE GuideNumber = @GuideNumber 
			AND GuideSerie = @GuideSerie 
			AND ZigiLinkStatus = 'FAILED'
		RETURN;
	END
	ELSE
	BEGIN
		SELECT 400 AS [IdResult],
			'ERROR'	AS [Message],
			0				AS [PaidZigi],
			@GuideNumber	AS GuideNumber,
			@GuideSerie		AS GuideSerie,
			0				AS [LinkCreated],
			0				AS [IsPay],
			''				AS [LinkZigi]
		RETURN;
	END
END