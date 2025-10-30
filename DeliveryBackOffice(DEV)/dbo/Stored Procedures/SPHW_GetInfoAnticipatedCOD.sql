-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-11-28>
-- Description:	<COD Anticipado - Método para obtener información de COD anticipado en portal EXC generación/recepeción de guías.>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetInfoAnticipatedCOD]
@GuideSerie NVARCHAR(4),
@GuideNumber INT,
@FlagCreation INT
AS
BEGIN
BEGIN TRY

	DECLARE @CustomerPortfolio INT = NULL;
	DECLARE @ComisionCODCalculate  DECIMAL(12, 2) = NULL;
	--Guarda el Identificador del cliente de la guía
	DECLARE @IdCustomer INT = (
		SELECT IdCustomer FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
		WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
	)

	--Guarda el tipo de cliente
	DECLARE @TypeCustomer INT = (
		SELECT IdCustomerType FROM DeliveryBackOffice.dbo.Customer WITH(NOLOCK)
		WHERE IdCustomer = @IdCustomer
	)

	--Guarda el tipo de cliente
	DECLARE @RedistributionCustomer INT = (
		SELECT IdCustomerType FROM DeliveryBackOffice.dbo.CustomerType WITH(NOLOCK)
		WHERE Description = 'REDISTRIBUIDOR'
	)
	
	--Obtiene el país de la guía
	DECLARE @IdCountrySender NVARCHAR(2) = 
	(
		SELECT SenderCountryId FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
		WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
	)

	--Guarda datos si es cliente tipo cartera
	IF(@TypeCustomer = @RedistributionCustomer)
	BEGIN
		SET @CustomerPortfolio = (
			SELECT DO.VisitpointClientPortfolioId
			FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
			LEFT JOIN DeliveryBackOffice.dbo.VisitPointByClientPortfolio VPCP WITH(NOLOCK)
				ON DO.VisitpointClientPortfolioId = VPCP.IdVisitPointByClientPortfolio
			LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
				ON VPCP.VisitPointId = VPC.IdVisitPointClient
				AND VPC.IdKindOfVPBusiness IN (
					  SELECT IdKindOfVPBusiness
					  FROM DeliveryBackOffice.dbo.KindOfVPBusiness
					  WHERE Shorthand = 'EXP'
				  )
			WHERE DO.Guide_Serie = @GuideSerie
			  AND DO.Guide_Number = @GuideNumber
		);
	END;

	print('@CustomerPortfolio')
	print(@CustomerPortfolio)

	--Validar que solo se pueda con cliente tipo corporativo/individual o cartera
	IF ((@TypeCustomer != @RedistributionCustomer) OR (@CustomerPortfolio > 0))
	BEGIN 
		
		SELECT
			  200	AS 'IdResult'
			, 'Success'	AS 'Message'

		--SE GUARDA LAS REGLAS PARA COD ANTICIPADO EN ESTE SCRIPT Y SE ENVIAN PARA QUE LAS MUESTRE FRONTEND EN PORTAL EXC (VER CONDICIONES COD ANTICIPADO)
		DECLARE @Rules TABLE (
			RuleID INT,
			RuleText NVARCHAR(500)
		);

		-- Insertar reglas en la tabla tipo variable
		INSERT INTO @Rules (RuleID, RuleText)
		VALUES 
			(1, N'El remitente deberá tener 3 meses de antigüedad de hacer envíos.'),
			(2, N'Deberá haber hecho 25 o más envíos en el último mes.'),
			(3, N'El remitente podrá optar a un monto COD Anticipado diario de hasta el monto promedio de COD diario de su último mes (Total COD mensual / Total de días que hizo envíos en el mes). El resto de sus envíos los deberá hacer por COD Inmediato.'),
			(4, N'El monto máximo de COD anticipado por guía será de Q800. Si es superior deberá ser COD Inmediato.'),
			(5, N'Los envíos con COD Anticipado que no se puedan hacer la entrega efectiva, procederán como devolución al remitente, quedando el monto pagado como un saldo en contra del remitente, el cual se le descontará del o los próximos envíos con COD para saldar su cuenta.'),
			(6, N'Un remitente no podrá hacer envíos COD Anticipado si tiene saldo en contra.'),
			(7, N'El porcentaje de devolución para poder ser un remitente aplicable a COD Anticipado debe ser debajo de 4% promedio los últimos 3 meses.');

		SELECT * FROM @Rules;

		DECLARE @CODRateDefault DECIMAL(12, 2) =
							(
								SELECT CONVERT(DECIMAL(12, 2), ISNULL(cf.Value, '0')) val
								FROM DeliveryBackOffice.dbo.ConfigParams cf WITH(NOLOCK)
								WHERE cf.Name = 'CODRateDef'
										AND Status = 1
										AND cf.IdCountry = @IdCountrySender
							);
		DECLARE @CODExemptDefault DECIMAL(12, 2) =
							(
								SELECT CONVERT(DECIMAL(12, 2), ISNULL(cf.Value, '0')) val
								FROM DeliveryBackOffice.dbo.ConfigParams cf WITH(NOLOCK)
								WHERE cf.Name = 'CODExemptDef'
										AND Status = 1
										AND cf.IdCountry = @IdCountrySender
							);
		DECLARE @IdSegmentDefault INT =
						(
							SELECT TOP 1
									CrsId
							FROM dbo.CatRateSegment WITH(NOLOCK)
							WHERE CrsShortName = 'FOR'
									AND CrsRowStatus = 'true'
						);

		DECLARE @MinCODCommissionAmount DECIMAL(12, 2) =
						(
							SELECT CONVERT(DECIMAL(12, 2), ISNULL(cf.Value, '0')) val
							FROM DeliveryBackOffice.dbo.ConfigParams cf WITH(NOLOCK)
							WHERE cf.Name = 'MinCODCommissionAmount'
									AND Status = 1
									AND ISNULL(cf.IdCountry,'GT') = @IdCountrySender
						);

		--CALCULO DE COMISION COD INMEDIATO
		IF(@FlagCreation = 1)
		BEGIN

			SET @ComisionCODCalculate =
			(
				SELECT
				CASE
					WHEN (DO.Collect_OnDelivery - ISNULL(RCO.CODExempt, @CODExemptDefault)) > 0
					THEN
						CASE
							WHEN OP.Deposit_Number IS NULL
							THEN
								CASE
									WHEN ISNULL(VPC.ExcludeCommissionCOD, ISNULL(C.ExcludeCommissionCOD, 0)) = 1
									THEN 0
									ELSE
									 (CONVERT
										(DECIMAL(12, 2), 
											(
												(DO.Collect_OnDelivery) * ISNULL(RCO.CODRate, @CODRateDefault) / 100
											)
										)
									)
								END
							ELSE 0
						END
					ELSE 0
				END
				FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
				LEFT JOIN dbo.VisitPointClient            VPC WITH (NOLOCK)
					ON VPC.CodeOfReference = DO.Sender_ID
				LEFT JOIN DeliveryBackOffice.dbo.RatebyCustomer RBC WITH(NOLOCK)
					ON RBC.RbcIdCustomer = ISNULL(DO.IdCustomer, VPC.CustomerID)
						AND RBC.RbcRowStatus = 1 AND RBC.RbcCodeOfReference IS NULL
				LEFT JOIN dbo.RatebyCustomer RBC2 WITH (NOLOCK)
					ON RBC2.RbcIdCustomer = ISNULL(DO.IdCustomer, VPC.CustomerID)
						AND RBC2.RbcRowStatus = 1 AND RBC2.RbcCodeOfReference = DO.Sender_ID
				--COD inmediato
				LEFT JOIN dbo.Customer C WITH (NOLOCK)
					ON C.IdCustomer = ISNULL(DO.IdCustomer, VPC.CustomerID)
				LEFT JOIN dbo.CatTypeService CSV WITH (NOLOCK)
					ON CSV.CtsShortName = IIF(DO.TypeService = 'EXP', 'NDD', ISNULL(DO.TypeService, 'NDD'))
						AND CSV.CtsRowStatus = 'true'
				LEFT JOIN dbo.CatRateSegment CSG WITH (NOLOCK)
					ON CSG.CrsShortName = dbo.fn_get_segment(DO.Guide_Serie, DO.Guide_Number)
						AND CSG.CrsRowStatus = 'true'
				LEFT JOIN dbo.RateCOD RCO WITH (NOLOCK)
					ON RCO.RateId = ISNULL(RBC2.RbcIdRate, RBC.RbcIdRate)
						AND RCO.TypeServiceId = CSV.CtsId
						AND RCO.TypeSegmentId = ISNULL(CSG.CrsId, @IdSegmentDefault)
						AND RCO.RowStatus = 1
				LEFT JOIN dbo.DeliveryOrderPaid OP WITH (NOLOCK)
					ON OP.Guide_Serie = DO.Guide_Serie
						AND OP.Guide_Number = DO.Guide_Number
						AND OP.IdStatus = 'true'
				LEFT JOIN dbo.DeliveryOrderPaymentDetail PYT WITH (NOLOCK)
					ON PYT.GuideSerie = DO.Guide_Serie AND PYT.GuideNumber = DO.Guide_Number
				WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber
			)
		END;

		IF(@CustomerPortfolio > 0) --CLIENTE TIPO CARTERA
		BEGIN
			SELECT TOP 1
				CASE 
					WHEN ACH.IsOldest < 365 THEN 
						 CASE 
							WHEN ACH.IsOldest / 30 = 1 THEN 
								CAST(ACH.IsOldest / 30 AS VARCHAR) + ' mes' -- Singular para 1 mes
							ELSE 
								CAST(ACH.IsOldest / 30 AS VARCHAR) + ' meses' -- Plural para más de 1 mes o 0 meses
						END
					ELSE 
						CASE 
							WHEN ACH.IsOldest % 365 = 0 THEN 
								CAST(ACH.IsOldest / 365 AS VARCHAR) + ' Años'
							ELSE 
								'+' + CAST(ACH.IsOldest / 365 AS VARCHAR) + ' Años'
					END
				END														AS 'Time'
				, CASE
					WHEN ACH.IsOldest < ISNULL(RH.IsOldest,CP3.Value)
					THEN 'FALSE'
					ELSE 'TRUE'
				 END													AS 'FlagTime'
				, ACH.MinGuidesPerMonth									AS 'Delivery'
				, CASE
					WHEN ACH.MinGuidesPerMonth < ISNULL(RH.MinGuidesPerMonth,CP.Value)
					THEN 'FALSE'
					ELSE 'TRUE'
				 END													AS 'FlagDelivery'
				, ACH.DailyAmount										AS 'Amount'
				, ACH.ReturnPercent										AS 'Devolution'
				, CASE
					WHEN ACH.ReturnPercent > ISNULL(RH.ReturnPercent,CP2.Value) 
					THEN 'FALSE'
					ELSE 'TRUE'
				 END													AS 'FlagDevolution'
				,CASE
					WHEN ACH.IsCODAnticipatedValid = 1 THEN 'TRUE'
					ELSE 'FALSE'
				 END													AS 'FlagApplicable'
				,ISNULL(ACH.AgaintsBalance,0.0)							AS 'NegativeBalance'
			FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.AnticipatedCODHeader ACH WITH(NOLOCK)
				ON DO.VisitpointClientPortfolioId = ACH.PortfolioId
			LEFT JOIN DeliveryBackOffice.dbo.RatebyCustomer RBC WITH(NOLOCK)
				ON DO.IdCustomer = RBC.RbcIdCustomer
			LEFT JOIN DeliveryBackOffice.dbo.RateHeader RH WITH(NOLOCK)
				ON RBC.RbcIdRate = RH.RheId
			LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CP WITH(NOLOCK)
				ON CP.Name = 'MinGuidesPerMonthParam' AND CP.Status = 1 
					AND ISNULL(CP.IdCountry,'GT') = @IdCountrySender
			LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CP2 WITH(NOLOCK)
				ON CP2.Name = 'ReturnPercentParam' AND CP2.Status = 1 
					AND ISNULL(CP2.IdCountry,'GT') = @IdCountrySender
			LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CP3 WITH(NOLOCK)
				ON CP3.Name = 'IsOldestParam' AND CP3.Status = 1 
					AND ISNULL(CP3.IdCountry,'GT') = @IdCountrySender
			WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber
			AND RH.RheRowStatus = 1 AND ACH.RowStatus = 1

			IF(@FlagCreation = 1)
			BEGIN

				SELECT
					  CCC.Symbol                                        AS 'Currency'
					, DO.Collect_OnDelivery								AS 'AmountCOD'
					, DO.Collect_OnDelivery								AS 'AmountCODAnticipated'
					, 
					CASE
						WHEN DO.TypeService != 'COD'
						THEN 0
						WHEN ISNULL(@ComisionCODCalculate, 0)	< ISNULL(@MinCODCommissionAmount, 0)	
						THEN ISNULL(@MinCODCommissionAmount, 0)
						ELSE ISNULL(@ComisionCODCalculate, 0)
					END AS 'ComisionCOD'
					,
					CASE
						WHEN 
							(ACC.AnticipatedCODComission IS NOT NULL AND ACC.AnticipatedCODComission > 0.00)
							AND (ACC.InitialRange <= DO.Collect_OnDelivery AND DO.Collect_OnDelivery <= ACC.FinalRange)
						THEN
							ACC.AnticipatedCODComission
						ELSE
							CASE
								WHEN
									CPmin1.Value >= DO.Collect_OnDelivery AND DO.Collect_OnDelivery <= CPmax1.Value
								THEN
									CAST(CPv1.value AS DECIMAL)
								WHEN
									CPmin2.Value >= DO.Collect_OnDelivery AND DO.Collect_OnDelivery <= CPmax2.Value
								THEN
									CAST(CPv2.value AS DECIMAL)
								ELSE
									CAST(CPv3.value AS DECIMAL)
							END
					END													        AS 'ComisionCODAnticipated'
					, ISNULL(RH.GuideAmountCOD,CAST(CPV4.value AS DECIMAL))		AS 'MaxAmountCODAnticipated'
					, CASE
						WHEN VPC.ExcludePriceShippingCOD = 1 OR C.ExcludePriceShippingCOD = 1
						THEN
							0
						ELSE
							DO.PriceShippment
					  END												AS 'Shipping'
				FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
				LEFT JOIN DeliveryBackOffice.dbo.Cost CO WITH(NOLOCK)
					ON DO.Guide_Serie = CO.GuideSerie 
					AND DO.Guide_Number = CO.GuideNumber
				LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
					ON CO.CodCurrency = CCC.IdCatCurrencyCOD
				LEFT JOIN dbo.VisitPointClient            VPC WITH (NOLOCK)
					ON VPC.CodeOfReference = DO.Sender_ID
				LEFT JOIN DeliveryBackOffice.dbo.RatebyCustomer RBC WITH(NOLOCK)
					ON RBC.RbcIdCustomer = ISNULL(DO.IdCustomer, VPC.CustomerID)
						AND RBC.RbcRowStatus = 1 AND RBC.RbcCodeOfReference IS NULL
				LEFT JOIN DeliveryBackOffice.dbo.RateHeader RH WITH(NOLOCK)
					ON RBC.RbcIdRate = RH.RheId
				LEFT JOIN DeliveryBackOffice.dbo.AnticipatedCODComission ACC WITH(NOLOCK)
					ON RH.RheId = ACC.RateHeaderId
				LEFT JOIN dbo.Customer C WITH (NOLOCK)
					ON C.IdCustomer = ISNULL(DO.IdCustomer, VPC.CustomerID)
				--Son rangos por default que tenemos si en dado caso el tarifario no cumple su rango
				LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmin1 WITH(NOLOCK)
					ON CPmin1.IdCountry = DO.ReceiverCountryId AND CPmin1.Name = 'MinRangeCODComisison1Param'
				LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmin2 WITH(NOLOCK)
					ON CPmin2.IdCountry = DO.ReceiverCountryId AND CPmin2.Name = 'MinRangeCODComisison2Param'
				LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmax1 WITH(NOLOCK)
					ON CPmax1.IdCountry = DO.ReceiverCountryId AND CPmax1.Name = 'MaxRangeCODComisison1Param'
				LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmax2 WITH(NOLOCK)
					ON CPmax2.IdCountry = DO.ReceiverCountryId AND CPmax2.Name = 'MaxRangeCODComisison2Param'
				LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPv1 WITH(NOLOCK)
					ON CPv1.IdCountry = DO.ReceiverCountryId AND CPv1.Name = 'ValueCODComisison1Param'
				LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPv2 WITH(NOLOCK)
					ON CPv2.IdCountry = DO.ReceiverCountryId AND CPv2.Name = 'ValueCODComisison2Param'
				LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPv3 WITH(NOLOCK)
					ON CPv3.IdCountry = DO.ReceiverCountryId AND CPv3.Name = 'ValueCODComisison3Param'
				LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPV4 WITH(NOLOCK)
					ON CPV4.IdCountry = DO.ReceiverCountryId AND CPV4.Name = 'GuideAmountCODAnticipatedParam'
				WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber
			END;

			--Consulta para obtener el valor de saldo disponible
			SELECT 
			COALESCE((
				SELECT 
					ACH.DailyAmount - SUM(ACD.CollectOnDelivery)
				FROM DeliveryBackOffice.dbo.AnticipatedCODDetail ACD WITH(NOLOCK)
				INNER JOIN DeliveryBackOffice.dbo.AnticipatedCODHeader ACH WITH(NOLOCK)
					ON ACD.AnticipatedCODHeaderId = ACH.IdAnticipatedCODHeader
				WHERE ACH.PortfolioId = @CustomerPortfolio AND ACD.RowStatus = 1 
				  AND ACH.RowStatus = 1
				  AND ACD.DateCreated >= CAST(GETDATE() AS DATE) 
				  AND ACD.DateCreated < DATEADD(DAY, 1, CAST(GETDATE() AS DATE))
				GROUP BY ACH.DailyAmount),
				(SELECT TOP 1 ACH.DailyAmount
				 FROM DeliveryBackOffice.dbo.AnticipatedCODHeader ACH WITH(NOLOCK)
				 WHERE ACH.PortfolioId = @CustomerPortfolio AND ACH.RowStatus = 1),0
				) AS 'AvailableBalance';

		END;
		ELSE --CLIENTE TIPO CORPORATIVO/INDIVIDUAL
		BEGIN
			SELECT TOP 1
				CASE 
					WHEN ACH.IsOldest < 365 THEN 
						CASE 
							WHEN ACH.IsOldest / 30 = 1 THEN 
								CAST(ACH.IsOldest / 30 AS VARCHAR) + ' mes' -- Singular para 1 mes
							ELSE 
								CAST(ACH.IsOldest / 30 AS VARCHAR) + ' meses' -- Plural para más de 1 mes o 0 meses
						END
					ELSE 
						CASE 
							WHEN ACH.IsOldest % 365 = 0 THEN 
								CAST(ACH.IsOldest / 365 AS VARCHAR) + ' Años'
							ELSE 
								'+' + CAST(ACH.IsOldest / 365 AS VARCHAR) + ' Años'
					END
				END														AS 'Time'
				, CASE
					WHEN ACH.IsOldest < ISNULL(RH.IsOldest,CP3.Value)
					THEN 'FALSE'
					ELSE 'TRUE'
				 END													AS 'FlagTime'
				, ACH.MinGuidesPerMonth									AS 'Delivery'
				, CASE
					WHEN ACH.MinGuidesPerMonth < ISNULL(RH.MinGuidesPerMonth,CP.Value)
					THEN 'FALSE'
					ELSE 'TRUE'
				 END													AS 'FlagDelivery'
				, ACH.DailyAmount										AS 'Amount'
				, ACH.ReturnPercent										AS 'Devolution'
				, CASE
					WHEN ACH.ReturnPercent > ISNULL(RH.ReturnPercent,CP2.Value) 
					THEN 'FALSE'
					ELSE 'TRUE'
				 END													AS 'FlagDevolution'
				,CASE
					WHEN ACH.IsCODAnticipatedValid = 1 THEN 'TRUE'
					ELSE 'FALSE'
				 END													AS 'FlagApplicable'
				,ISNULL(ACH.AgaintsBalance,0.0)							AS 'NegativeBalance'
			FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
			INNER JOIN DeliveryBackOffice.dbo.AnticipatedCODHeader ACH WITH(NOLOCK)
				ON DO.IdCustomer = ACH.CustomerId
			LEFT JOIN DeliveryBackOffice.dbo.RatebyCustomer RBC WITH(NOLOCK)
				ON DO.IdCustomer = RBC.RbcIdCustomer
			LEFT JOIN DeliveryBackOffice.dbo.RateHeader RH WITH(NOLOCK)
				ON RBC.RbcIdRate = RH.RheId
			LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CP WITH(NOLOCK)
				ON CP.Name = 'MinGuidesPerMonthParam' AND CP.Status = 1 
					AND ISNULL(CP.IdCountry,'GT') = @IdCountrySender
			LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CP2 WITH(NOLOCK)
				ON CP2.Name = 'ReturnPercentParam' AND CP2.Status = 1 
					AND ISNULL(CP2.IdCountry,'GT') = @IdCountrySender
			LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CP3 WITH(NOLOCK)
				ON CP3.Name = 'IsOldestParam' AND CP3.Status = 1 
					AND ISNULL(CP3.IdCountry,'GT') = @IdCountrySender
			WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber
			AND RH.RheRowStatus = 1 AND ACH.RowStatus = 1

			IF(@FlagCreation = 1)
			BEGIN
				SELECT
					  CCC.Symbol                                        AS 'Currency'
					, DO.Collect_OnDelivery								AS 'AmountCOD'
					, DO.Collect_OnDelivery								AS 'AmountCODAnticipated'
					, 
					CASE
						WHEN DO.TypeService != 'COD'
						THEN 0
						WHEN ISNULL(@ComisionCODCalculate, 0)	< ISNULL(@MinCODCommissionAmount, 0)	
						THEN ISNULL(@MinCODCommissionAmount, 0)
						ELSE ISNULL(@ComisionCODCalculate, 0)
					END AS 'ComisionCOD'
					,
					CASE
						WHEN 
							(ACC.AnticipatedCODComission IS NOT NULL AND ACC.AnticipatedCODComission > 0.00)
							AND (ACC.InitialRange <= DO.Collect_OnDelivery AND DO.Collect_OnDelivery <= ACC.FinalRange)
						THEN
							ACC.AnticipatedCODComission
						ELSE
							CASE
								WHEN
									CPmin1.Value >= DO.Collect_OnDelivery AND DO.Collect_OnDelivery <= CPmax1.Value
								THEN
									CAST(CPv1.value AS DECIMAL)
								WHEN
									CPmin2.Value >= DO.Collect_OnDelivery AND DO.Collect_OnDelivery <= CPmax2.Value
								THEN
									CAST(CPv2.value AS DECIMAL)
								ELSE
									CAST(CPv3.value AS DECIMAL)
							END
					END													        AS 'ComisionCODAnticipated'
					, ISNULL(RH.GuideAmountCOD,CAST(CPV4.value AS DECIMAL))		AS 'MaxAmountCODAnticipated'
					, CASE
						WHEN VPC.ExcludePriceShippingCOD = 1 OR C.ExcludePriceShippingCOD = 1
						THEN
							0
						ELSE
							DO.PriceShippment
					  END												AS 'Shipping'
				FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
				LEFT JOIN DeliveryBackOffice.dbo.Cost CO WITH(NOLOCK)
					ON DO.Guide_Serie = CO.GuideSerie 
					AND DO.Guide_Number = CO.GuideNumber
				LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
					ON CO.CodCurrency = CCC.IdCatCurrencyCOD
				LEFT JOIN dbo.VisitPointClient            VPC WITH (NOLOCK)
					ON VPC.CodeOfReference = DO.Sender_ID
				LEFT JOIN DeliveryBackOffice.dbo.RatebyCustomer RBC WITH(NOLOCK)
					ON RBC.RbcIdCustomer = ISNULL(DO.IdCustomer, VPC.CustomerID)
						AND RBC.RbcRowStatus = 1 AND RBC.RbcCodeOfReference IS NULL
				LEFT JOIN DeliveryBackOffice.dbo.RateHeader RH WITH(NOLOCK)
					ON RBC.RbcIdRate = RH.RheId
				LEFT JOIN DeliveryBackOffice.dbo.AnticipatedCODComission ACC WITH(NOLOCK)
					ON RH.RheId = ACC.RateHeaderId
				LEFT JOIN dbo.Customer C WITH (NOLOCK)
					ON C.IdCustomer = ISNULL(DO.IdCustomer, VPC.CustomerID)
				--Son rangos por default que tenemos si en dado caso el tarifario no cumple su rango
				LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmin1 WITH(NOLOCK)
					ON CPmin1.IdCountry = DO.ReceiverCountryId AND CPmin1.Name = 'MinRangeCODComisison1Param'
				LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmin2 WITH(NOLOCK)
					ON CPmin2.IdCountry = DO.ReceiverCountryId AND CPmin2.Name = 'MinRangeCODComisison2Param'
				LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmax1 WITH(NOLOCK)
					ON CPmax1.IdCountry = DO.ReceiverCountryId AND CPmax1.Name = 'MaxRangeCODComisison1Param'
				LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmax2 WITH(NOLOCK)
					ON CPmax2.IdCountry = DO.ReceiverCountryId AND CPmax2.Name = 'MaxRangeCODComisison2Param'
				LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPv1 WITH(NOLOCK)
					ON CPv1.IdCountry = DO.ReceiverCountryId AND CPv1.Name = 'ValueCODComisison1Param'
				LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPv2 WITH(NOLOCK)
					ON CPv2.IdCountry = DO.ReceiverCountryId AND CPv2.Name = 'ValueCODComisison2Param'
				LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPv3 WITH(NOLOCK)
					ON CPv3.IdCountry = DO.ReceiverCountryId AND CPv3.Name = 'ValueCODComisison3Param'
				LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPV4 WITH(NOLOCK)
					ON CPV4.IdCountry = DO.ReceiverCountryId AND CPV4.Name = 'GuideAmountCODAnticipatedParam'
				WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber
			END;

			--Consulta para obtener el valor de saldo disponible
			SELECT 
			COALESCE((
				SELECT 
					ACH.DailyAmount - SUM(ACD.CollectOnDelivery)
				FROM DeliveryBackOffice.dbo.AnticipatedCODDetail ACD WITH(NOLOCK)
				INNER JOIN DeliveryBackOffice.dbo.AnticipatedCODHeader ACH WITH(NOLOCK)
					ON ACD.AnticipatedCODHeaderId = ACH.IdAnticipatedCODHeader
				WHERE ACH.CustomerId = @IdCustomer AND ACD.RowStatus = 1 
				  AND ACH.RowStatus = 1
				  AND ACD.DateCreated >= CAST(GETDATE() AS DATE) 
				  AND ACD.DateCreated < DATEADD(DAY, 1, CAST(GETDATE() AS DATE))
				GROUP BY ACH.DailyAmount
			),
			(SELECT TOP 1 ACH.DailyAmount
				 FROM DeliveryBackOffice.dbo.AnticipatedCODHeader ACH WITH(NOLOCK)
				 WHERE ACH.CustomerId = @IdCustomer AND ACH.RowStatus = 1),0
			) AS 'AvailableBalance';

		END;
	END;
	ELSE
	BEGIN
		SELECT
			  201															AS 'IdResult'
			, 'No es un tipo de cliente corporativo/individual/cartera.'	AS 'Message'
	END;

END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;