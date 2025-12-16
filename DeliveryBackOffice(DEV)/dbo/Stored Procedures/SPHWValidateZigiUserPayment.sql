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
-- Author:		<Bilkar Morataya>
-- Create date: <2025-12-12>
-- Description:	<Optimización: consolidación de consultas y mejora de rendimiento>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWValidateZigiUserPayment]
	@GuideNumber INT,
	@GuideSerie NVARCHAR(50)
AS
BEGIN

	-- Variables para almacenar resultados de consultas únicas
	DECLARE @EnablePaidZigi INT = 1;
	DECLARE @isNeedBilling BIT = 1;
	DECLARE @DeliveryOrderInfo TABLE (
		IsCollect BIT,
		Collect_OnDelivery DECIMAL(18,2),
		HasCreditCardPaid BIT
	);
	
	-- Consulta única a DeliveryOrder con todas las validaciones necesarias
	INSERT INTO @DeliveryOrderInfo (IsCollect, Collect_OnDelivery, HasCreditCardPaid)
	SELECT 
		DOR.IsCollect,
		DOR.Collect_OnDelivery,
		CASE WHEN CCTBC.ReasonCode = '00' THEN 1 ELSE 0 END
	FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
	LEFT JOIN DeliveryBackOffice.dbo.CreditCardTransactionByCustomer CCTBC WITH(NOLOCK)  
		ON CCTBC.OrderNumber = DOR.Guide_Serie + CONVERT(VARCHAR, DOR.Guide_Number)
		AND CCTBC.ReasonCode = '00'
	WHERE DOR.Guide_Serie = @GuideSerie  
		AND DOR.Guide_Number = @GuideNumber;

	-- Si no existe la guía, error
	IF NOT EXISTS (SELECT 1 FROM @DeliveryOrderInfo)
	BEGIN
		SELECT 400 AS IdResult, 'Guia no encontrada' AS Message, 0 AS PaidZigi,
			@GuideSerie AS GuideSerie, @GuideNumber AS GuideNumber, 0 AS LinkCreated, 
			0 AS IsPay, '' AS LinkZigi, @isNeedBilling AS isNeedBilling;
		RETURN;
	END

	-- Calcular @EnablePaidZigi basado en las reglas de negocio
	SELECT 
		@EnablePaidZigi = CASE 
			WHEN HasCreditCardPaid = 1 AND Collect_OnDelivery = 0 THEN 0  -- Ya pagada con tarjeta y sin COD
			WHEN Collect_OnDelivery > 0 THEN 1  -- Tiene COD, habilitar Zigi
			ELSE @EnablePaidZigi  -- Mantener valor por defecto
		END
	FROM @DeliveryOrderInfo;

	-- Validar si la guía es elegible (debe ser collect o tener COD)
	IF EXISTS (SELECT 1 FROM @DeliveryOrderInfo WHERE IsCollect = 0 AND Collect_OnDelivery = 0)
	BEGIN
		SELECT 400 AS IdResult, 'opcion no habilitada' AS Message, 0 AS PaidZigi,
			@GuideSerie AS GuideSerie, @GuideNumber AS GuideNumber, 0 AS LinkCreated, 
			0 AS IsPay, '' AS LinkZigi, @isNeedBilling AS isNeedBilling;
		RETURN;
	END

	-- Cálculo de isNeedBilling
	IF EXISTS (
		SELECT 1
		FROM DeliveryBackOffice.dbo.invoiceDetail ID WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.invoiceHeader IH WITH (NOLOCK)
			ON IH.inv_pk_id = ID.dti_fk_header
		WHERE ID.dti_fk_orderSerie = @GuideSerie
		  AND ID.dti_fk_orderNumber = @GuideNumber
		  AND IH.inv_certificationFEL IS NOT NULL
		  AND LTRIM(RTRIM(IH.inv_certificationFEL)) <> ''
	)
	BEGIN
		SET @isNeedBilling = 0;
	END

	-- Consulta única a PaymentZigi para obtener toda la información necesaria
	DECLARE @ZigiStatus NVARCHAR(20), @ZigiLink NVARCHAR(500);
	
	SELECT 
		@ZigiStatus = ZigiLinkStatus,
		@ZigiLink = ISNULL(ZigiLink, '')
	FROM PaymentZigi WITH(NOLOCK) 
	WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber;

	-- Evaluar estados usando CASE en lugar de múltiples IF
	IF @ZigiStatus IS NULL
	BEGIN
		-- No existe registro en PaymentZigi
		SELECT 200 AS IdResult, 'Guia no tiene link asociado ' AS Message, @EnablePaidZigi AS PaidZigi,
			@GuideSerie AS GuideSerie, @GuideNumber AS GuideNumber, 0 AS LinkCreated, 
			0 AS IsPay, '' AS LinkZigi, @isNeedBilling AS isNeedBilling;
	END
	ELSE
	BEGIN
		-- Existe registro, evaluar según el estado
		SELECT 
			CASE @ZigiStatus
				WHEN 'CREATED' THEN 200
				WHEN 'PAID' THEN 400
				WHEN 'CANCELED' THEN 1
				WHEN 'FAILED' THEN 1
				ELSE 400
			END AS IdResult,
			CASE @ZigiStatus
				WHEN 'CREATED' THEN 'Guia link creado'
				WHEN 'PAID' THEN 'Link de Guia ha sido pagado'
				WHEN 'CANCELED' THEN 'Link HA SIDO DESHABILITADO'
				WHEN 'FAILED' THEN 'Link ha fallado'
				ELSE 'ERROR'
			END AS Message,
			@EnablePaidZigi AS PaidZigi,
			@GuideSerie AS GuideSerie,
			@GuideNumber AS GuideNumber,
			CASE @ZigiStatus
				WHEN 'CREATED' THEN 1
				WHEN 'PAID' THEN 1
				WHEN 'CANCELED' THEN 1
				WHEN 'FAILED' THEN 0
				ELSE 0
			END AS LinkCreated,
			CASE @ZigiStatus
				WHEN 'PAID' THEN 1
				ELSE 0
			END AS IsPay,
			CASE @ZigiStatus
				WHEN 'CREATED' THEN @ZigiLink
				WHEN 'PAID' THEN @ZigiLink
				WHEN 'CANCELED' THEN @ZigiLink
				WHEN 'FAILED' THEN @ZigiLink
				ELSE ''
			END AS LinkZigi,
			@isNeedBilling AS isNeedBilling;
	END

END