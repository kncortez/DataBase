-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2025-09-04>
-- Description:	<ZIGI - Valida si el usuario ha pagado con zigi>
-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2025-24-06>
-- Description:	<ZIGI - Habiliar opcion para guias prepago + cod>
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2025-12-01>
-- Description:	<Se agrega a las consultas el campo de isNeedBilling para identificar si necesitará ser facturado (o ya está facturado), se reordena el código>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWValidateZigiUserPayment]
	@GuideNumber INT,
	@GuideSerie NVARCHAR(50)
AS
BEGIN

	---------------------------------------------------------
	-- Cálculo de isNeedBilling
	---------------------------------------------------------
	DECLARE @isNeedBilling BIT = 1;

	IF EXISTS (
		SELECT 1
		FROM DeliveryBackOffice.dbo.invoiceDetail ID WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.invoiceHeader IH WITH (NOLOCK)
			ON IH.inv_pk_id = ID.dti_fk_header
		WHERE ID.dti_fk_orderSerie  = @GuideSerie
		  AND ID.dti_fk_orderNumber = @GuideNumber
		  AND IH.inv_certificationFEL IS NOT NULL
		  AND LTRIM(RTRIM(IH.inv_certificationFEL)) <> ''
	)
	BEGIN
		SET @isNeedBilling = 0;
	END


	---------------------------------------------------------
	-- Validación si ya fue pagada con tarjeta (rastreo)
	---------------------------------------------------------
	DECLARE @EnablePaidZigi INT = 1;

	IF EXISTS (
		SELECT 1
		FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.CreditCardTransactionByCustomer CCTBC WITH(NOLOCK)
			ON CCTBC.OrderNumber = DOR.Guide_Serie + CONVERT(VARCHAR, DOR.Guide_Number)
		WHERE DOR.Guide_Serie = @GuideSerie
		  AND DOR.Guide_Number = @GuideNumber
		  AND CCTBC.ReasonCode = '00'
	)
	BEGIN
		SET @EnablePaidZigi = 0;
	END


	---------------------------------------------------------
	-- Si hay COD, habilitar Zigi
	---------------------------------------------------------
	IF EXISTS(
		SELECT 1
		FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
		WHERE DOR.Guide_Serie = @GuideSerie
		  AND DOR.Guide_Number = @GuideNumber
		  AND DOR.Collect_OnDelivery > 0
	)
	BEGIN
		SET @EnablePaidZigi = 1;
	END

	---------------------------------------------------------
	-- Verificar si la guía no es collect (rechazar)
	---------------------------------------------------------
	IF EXISTS (
		SELECT 1
		FROM DeliveryOrder WITH(NOLOCK)
		WHERE Guide_Number = @GuideNumber
		  AND Guide_Serie = @GuideSerie
		  AND IsCollect = 0
		  AND Collect_OnDelivery = 0
	)
	BEGIN
		SELECT 400 AS IdResult,
		       'opcion no habilitada' AS Message,
		       0 AS PaidZigi,
		       @GuideNumber AS GuideNumber,
		       @GuideSerie AS GuideSerie,
		       0 AS LinkCreated,
		       0 AS IsPay,
		       '' AS LinkZigi,
		       @isNeedBilling AS isNeedBilling;
		RETURN;
	END


	---------------------------------------------------------
	-- Si no existe registro en PaymentZigi
	---------------------------------------------------------
	IF NOT EXISTS (
		SELECT 1 FROM PaymentZigi WITH(NOLOCK)
		WHERE GuideNumber = @GuideNumber
		  AND GuideSerie = @GuideSerie
	)
	BEGIN
		SELECT 200 AS IdResult,
		       'Guia no tiene link asociado ' AS Message,
		       @EnablePaidZigi AS PaidZigi,
		       @GuideNumber AS GuideNumber,
		       @GuideSerie AS GuideSerie,
		       0 AS LinkCreated,
		       0 AS IsPay,
		       '' AS LinkZigi,
		       @isNeedBilling AS isNeedBilling;
		RETURN;
	END


	---------------------------------------------------------
	-- CREATED
	---------------------------------------------------------
	IF EXISTS (
		SELECT 1 FROM PaymentZigi WITH(NOLOCK)
		WHERE GuideNumber = @GuideNumber
		  AND GuideSerie = @GuideSerie
		  AND ZigiLinkStatus = 'CREATED'
	)
	BEGIN
		SELECT 200 AS IdResult,
		       'Guia link creado' AS Message,
		       @EnablePaidZigi AS PaidZigi,
		       @GuideNumber AS GuideNumber,
		       @GuideSerie AS GuideSerie,
		       1 AS LinkCreated,
		       0 AS IsPay,
		       ZigiLink AS LinkZigi,
		       @isNeedBilling AS isNeedBilling
		FROM PaymentZigi WITH(NOLOCK)
		WHERE GuideNumber = @GuideNumber
		  AND GuideSerie = @GuideSerie
		  AND ZigiLinkStatus = 'CREATED';
		RETURN;
	END


	---------------------------------------------------------
	-- PAID
	---------------------------------------------------------
	IF EXISTS (
		SELECT 1 FROM PaymentZigi WITH(NOLOCK)
		WHERE GuideNumber = @GuideNumber
		  AND GuideSerie = @GuideSerie
		  AND ZigiLinkStatus = 'PAID'
	)
	BEGIN
		SELECT 400 AS IdResult,
		       'Link de Guia ha sido pagado' AS Message,
		       @EnablePaidZigi AS PaidZigi,
		       @GuideNumber AS GuideNumber,
		       @GuideSerie AS GuideSerie,
		       1 AS LinkCreated,
		       1 AS IsPay,
		       ZigiLink AS LinkZigi,
		       @isNeedBilling AS isNeedBilling
		FROM PaymentZigi WITH(NOLOCK)
		WHERE GuideNumber = @GuideNumber
		  AND GuideSerie = @GuideSerie
		  AND ZigiLinkStatus = 'PAID';
		RETURN;
	END


	---------------------------------------------------------
	-- CANCELED
	---------------------------------------------------------
	IF EXISTS (
		SELECT 1 FROM PaymentZigi WITH(NOLOCK)
		WHERE GuideNumber = @GuideNumber
		  AND GuideSerie = @GuideSerie
		  AND ZigiLinkStatus = 'CANCELED'
	)
	BEGIN
		SELECT 1 AS IdResult,
		       'Link HA SIDO DESHABILITADO' AS Message,
		       @EnablePaidZigi AS PaidZigi,
		       @GuideNumber AS GuideNumber,
		       @GuideSerie AS GuideSerie,
		       1 AS LinkCreated,
		       0 AS IsPay,
		       ZigiLink AS LinkZigi,
		       @isNeedBilling AS isNeedBilling
		FROM PaymentZigi WITH(NOLOCK)
		WHERE GuideNumber = @GuideNumber
		  AND GuideSerie = @GuideSerie
		  AND ZigiLinkStatus = 'CANCELED';
		RETURN;
	END


	---------------------------------------------------------
	-- FAILED
	---------------------------------------------------------
	IF EXISTS (
		SELECT 1 FROM PaymentZigi WITH(NOLOCK)
		WHERE GuideNumber = @GuideNumber
		  AND GuideSerie = @GuideSerie
		  AND ZigiLinkStatus = 'FAILED'
	)
	BEGIN
		SELECT 1 AS IdResult,
		       'Link ha fallado' AS Message,
		       @EnablePaidZigi AS PaidZigi,
		       @GuideNumber AS GuideNumber,
		       @GuideSerie AS GuideSerie,
		       0 AS LinkCreated,
		       0 AS IsPay,
		       ZigiLink AS LinkZigi,
		       @isNeedBilling AS isNeedBilling
		FROM PaymentZigi WITH(NOLOCK)
		WHERE GuideNumber = @GuideNumber
		  AND GuideSerie = @GuideSerie
		  AND ZigiLinkStatus = 'FAILED';
		RETURN;
	END


	---------------------------------------------------------
	-- ERROR GENÉRICO
	---------------------------------------------------------
	BEGIN
		SELECT 400 AS IdResult,
		       'ERROR' AS Message,
		       0 AS PaidZigi,
		       @GuideNumber AS GuideNumber,
		       @GuideSerie AS GuideSerie,
		       0 AS LinkCreated,
		       0 AS IsPay,
		       '' AS LinkZigi,
		       @isNeedBilling AS isNeedBilling;
		RETURN;
	END

END