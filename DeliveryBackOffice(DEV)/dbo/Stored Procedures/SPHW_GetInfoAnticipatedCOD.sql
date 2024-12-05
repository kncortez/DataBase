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

	--Validar que solo se pueda con cliente tipo corporativo/individual
	IF (@TypeCustomer != @RedistributionCustomer)
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

		SELECT 
			CASE 
				WHEN ACH.IsOldest < 365 THEN 
					CAST(ACH.IsOldest / 30 AS VARCHAR) + ' meses'
				ELSE 
					CASE 
						WHEN ACH.IsOldest % 365 = 0 THEN 
							CAST(ACH.IsOldest / 365 AS VARCHAR) + ' Años'
						ELSE 
							'+' + CAST(ACH.IsOldest / 365 AS VARCHAR) + ' Años'
				END
			END														AS 'Time'
			, CASE
				WHEN ACH.IsOldest < RH.IsOldest THEN 'FALSE'
				ELSE 'TRUE'
			 END													AS 'FlagTime'
			, ACH.MinGuidesPerMonth									AS 'Delivery'
			, CASE
				WHEN ACH.MinGuidesPerMonth < RH.MinGuidesPerMonth THEN 'FALSE'
				ELSE 'TRUE'
			 END													AS 'FlagDelivery'
			, ACH.DailyAmount										AS 'Amount'
			, CCC.Symbol											AS 'Currency'
			, ACH.ReturnPercent										AS 'Devolution'
			, CASE
				WHEN ACH.ReturnPercent > RH.ReturnPercent THEN 'FALSE'
				ELSE 'TRUE'
			 END													AS 'FlagDevolution'
			,CASE
				WHEN ACH.IsCODAnticipatedValid = 1 THEN 'TRUE'
				ELSE 'FALSE'
			 END													AS 'FlagApplicable'
			,ACH.AgaintsBalance										AS 'NegativeBalance'
		FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.AnticipatedCODHeader ACH WITH(NOLOCK)
			ON DO.IdCustomer = ACH.CustomerId
		LEFT JOIN DeliveryBackOffice.dbo.Cost C WITH(NOLOCK)
			ON DO.Guide_Serie = C.GuideSerie AND DO.Guide_Number = C.GuideNumber
		LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
			ON C.CodCurrency = CCC.IdCatCurrencyCOD
		LEFT JOIN DeliveryBackOffice.dbo.RatebyCustomer RBC WITH(NOLOCK)
			ON DO.IdCustomer = RBC.RbcIdCustomer
		LEFT JOIN DeliveryBackOffice.dbo.RateHeader RH WITH(NOLOCK)
			ON RBC.RbcIdRate = RH.RheId
		WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber

		IF(@FlagCreation = 1)
		BEGIN
			SELECT
				  DO.Collect_OnDelivery								AS 'AmountCOD'
				, DO.Collect_OnDelivery								AS 'AmountCODAnticipated'
				, 0.00												AS 'ComisionCOD'
				, ISNULL(ACC.AnticipatedCODComission,CP.Value)		AS 'ComisionCODAnticipated'
				, RH.GuideAmountCOD									AS 'MaxAmountCODAnticipated'
			FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
			LEFT JOIN DeliveryBackOffice.dbo.RatebyCustomer RBC WITH(NOLOCK)
				ON DO.IdCustomer = RBC.RbcIdCustomer
			LEFT JOIN DeliveryBackOffice.dbo.RateHeader RH WITH(NOLOCK)
				ON RBC.RbcIdRate = RH.RheId
			LEFT JOIN DeliveryBackOffice.dbo.AnticipatedCODComission ACC WITH(NOLOCK)
				ON RH.RheId = ACC.RateHeaderId
			LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CP WITH(NOLOCK)
				ON CP.Name = 'ValueCODComisison3Param' AND CP.IdCountry = DO.ReceiverCountryId
			WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber
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