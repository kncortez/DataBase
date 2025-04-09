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
	--verificar guia collect
	IF NOT EXISTS (SELECT 1 FROM DeliveryOrder WHERE Guide_Number = @GuideNumber AND Guide_Serie = @GuideSerie AND IsCollect = 1 )
	BEGIN
		SELECT 400 [IdResult],
			'la guia no es collect' AS [Message],
			0				AS [PaidZigi],
			@GuideNumber	AS GuideNumber,
			@GuideSerie		AS GuideSerie;
		RETURN;
	END
	
	IF NOT EXISTS (SELECT 1 FROM PaymentZigi WHERE GuideNumber = @GuideNumber AND GuideSerie = @GuideSerie)
	BEGIN
		SELECT 200 [IdResult],
			'Guia no tiene link asociado ' AS [Message],
			1				AS [PaidZigi],
			@GuideNumber	AS GuideNumber,
			@GuideSerie		AS GuideSerie;
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM PaymentZigi WHERE GuideNumber = @GuideNumber AND GuideSerie = @GuideSerie AND ZigiLinkStatus = 'CREATED')
	BEGIN
		SELECT 200 [IdResult],
			'Guia link creado' AS [Message],
			1				AS [PaidZigi],
			@GuideNumber	AS GuideNumber,
			@GuideSerie		AS GuideSerie;
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM PaymentZigi WHERE GuideNumber = @GuideNumber AND GuideSerie = @GuideSerie AND ZigiLinkStatus = 'PAID')
	BEGIN
		SELECT 400 AS [IdResult],
			'Link de Guia ha sido pagado'	AS [Message],
			0				AS [PaidZigi],
			@GuideNumber	AS GuideNumber,
			@GuideSerie		AS GuideSerie;
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM PaymentZigi WHERE GuideNumber = @GuideNumber AND GuideSerie = @GuideSerie AND ZigiLinkStatus = 'CANCELED')
	BEGIN
		SELECT 1 AS [IdResult],
			'Link HA SIDO DESHABILITADO'	AS [Message],
			0				AS [PaidZigi],
			@GuideNumber	AS GuideNumber,
			@GuideSerie		AS GuideSerie;
		RETURN;
	END
	ELSE
	BEGIN
		SELECT 400 AS [IdResult],
			'ERROR'	AS [Message],
			0				AS [PaidZigi],
			@GuideNumber	AS GuideNumber,
			@GuideSerie		AS GuideSerie;
		RETURN;
	END
END