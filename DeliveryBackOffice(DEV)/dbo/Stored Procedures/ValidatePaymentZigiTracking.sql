-- =============================================
-- System:		<API>
-- Author:		<Walter Orozco>
-- Create date: <2025-08-11>
-- Description:	<ZIGI - Validar telefono, pago y link zigi para flujo de tracking WhatsApp pago con Zigi.>
-- Create date: <2025-08-21>
-- Description:	<Se agrega actualizacion de la bandera para solicitud de link zigi enviado por whatsapp.>
-- =============================================
-- =============================================
-- System:		<API>
-- Author:		<Bilkar Morataya>
-- Create date: <2025-12-17>
-- Description:	<Se agrega en la respuesta el campo del linkde Zigi>
-- =============================================
-- =============================================
-- System:		<API>
-- Author:		<Bilkar Morataya>
-- Create date: <2025-01-13>
-- Description:	<Se restringe a no permitir pagos si ya existe un pago para la guia aunque sea de forma parcial>
-- =============================================
CREATE PROCEDURE [dbo].[ValidatePaymentZigiTracking]
    @GuideNumber        INT,
    @GuideSerie         NVARCHAR(2),
    @NirPhone			INT,
    @Phone				INT,
	@Token				NVARCHAR(200) = 'SYS-TrackingZigi'
AS
BEGIN
    BEGIN TRY
		DECLARE @PhoneStr     NVARCHAR(15) = CAST(@Phone    AS NVARCHAR(15));
		DECLARE @NirPhoneStr  NVARCHAR(5)  = CAST(@NirPhone AS NVARCHAR(5));
		DECLARE @LinkCreated INT = 0;
		DECLARE @LinkPaid INT = 0;
		DECLARE @GuidePaid INT = 0;
		DECLARE @IdDeliveryOption INT = 0;
		DECLARE @ReceiverPhone NVARCHAR(200);
        DECLARE @ZigiLink NVARCHAR(500) = NULL;

        SET @IdDeliveryOption = (
            SELECT TOP 1 C.IdDeliveryOption
            FROM [DeliveryBackOffice].[dbo].[CatDeliveryOptions] C WITH (NOLOCK)
			LEFT JOIN DeliveryBackOffice.dbo.DefaultValuesPerCountry D WITH(NOLOCK)
				ON D.PrefixNumber = @NirPhone
            WHERE C.[Name] = 'Express Center' AND C.IdCountry = D.IdCountry
        ); 

		SET @ReceiverPhone = (SELECT Receiver_Phone FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK) 
		WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber);

		SET @ReceiverPhone = REPLACE(@ReceiverPhone, '+', '');
		SET @ReceiverPhone = REPLACE(@ReceiverPhone, '-', '');
		SET @ReceiverPhone = REPLACE(@ReceiverPhone, ' ', '');

		SELECT
		  @LinkCreated = COALESCE(MAX(CASE WHEN ZigiLinkStatus = 'CREATED' THEN 1 END), 0),
		  @LinkPaid    = COALESCE(MAX(CASE WHEN ZigiLinkStatus = 'PAID'    THEN 1 END), 0)
		FROM DeliveryBackOffice.dbo.PaymentZigi WITH (NOLOCK)
		WHERE GuideSerie = @GuideSerie
		  AND GuideNumber = @GuideNumber;

        SELECT TOP (1)
            @ZigiLink = PZ.ZigiLink
        FROM DeliveryBackOffice.dbo.PaymentZigi PZ WITH (NOLOCK)
        WHERE PZ.GuideSerie = @GuideSerie
          AND PZ.GuideNumber = @GuideNumber
        ORDER BY PZ.DateUpdated DESC;

		
		-- SET	@LinkPaid = CASE WHEN EXISTS
			-- (SELECT 1 FROM DeliveryBackOffice.dbo.PaymentZigi PZ WITH (NOLOCK)
			-- WHERE PZ.Guide_Serie = @GuideSerie AND PZ.Guide_Number = @GuideNumber AND PZ.ZigiLinkStatus = 'PAID') 
			-- THEN 1 ELSE 0 END;

		SET @GuidePaid = CASE WHEN EXISTS (
			SELECT 1 FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DOR WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[CreditCardTransactionByCustomer] CCTBC WITH(NOLOCK)
				ON CCTBC.OrderNumber = DOR.Guide_Serie + CONVERT(VARCHAR,DOR.Guide_Number) AND CCTBC.ReasonCode = '00'
			WHERE DOR.Guide_Serie = @GuideSerie AND DOR.Guide_Number = @GuideNumber
			
			-- ESTE UNION FUE NECESARIO PARA EVITAR UN OR EN LA CONDICION
			UNION
			
			SELECT 1 FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DOR WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[Cost] Cost WITH(NOLOCK)
				ON Cost.GuideSerie = DOR.Guide_Serie AND Cost.GuideNumber = DOR.Guide_Number
			INNER JOIN [DeliveryBackOffice].[dbo].[CostDetail] CostDetail WITH(NOLOCK)
				ON CostDetail.IdCost = Cost.IdCost
			WHERE DOR.Guide_Serie = @GuideSerie AND DOR.Guide_Number = @GuideNumber
			AND CostDetail.IdTypeOfMoney IN ('1', '2', '6', '7', '8', '9', '10')
		) THEN 1 ELSE 0 END;

		IF((@ReceiverPhone = @NirPhoneStr + @PhoneStr) OR (@ReceiverPhone = @PhoneStr))
		BEGIN
			IF(@LinkCreated = 0)
			BEGIN
				IF(@LinkPaid = 0 AND @GuidePaid = 0)
				BEGIN

					SELECT 
						200																										AS	[IdResult]
						, '¡Listo! Hemos generado tu link de pago'																AS	[Title]
						, 'En breve recibirás un mensaje por WhatsApp con el enlace para realizar tu pago de forma segura.' 	AS	[Message]
                        , @ZigiLink                                                                                              AS  [ZigiLink]
						, CASE
							WHEN DO.IdDeliveryOption = @IdDeliveryOption 
							THEN 0
							ELSE
								 IIF(KVP.KindOfVPName = 'Express Center',0, 
									IIF(DO.IsLastMileReturn = 1,0, 
										ISNULL(DO.Collect_OnDelivery,0)
										)
									)
						END [CODValue]
						,CASE 
							WHEN DO.IdDeliveryOption = @IdDeliveryOption 
							THEN 0
							ELSE 
								IIF(KVP.KindOfVPName = 'Express Center',0,ISNULL(DO.PriceShippment, 0))
						END AS [CollectValue]
					FROM DeliveryBackOffice.dbo.DeliveryOrder				DO	WITH(NOLOCK)
					LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] VP	WITH (NOLOCK)
						ON VP.CodeOfReference = DO.Receiver_ID
					LEFT JOIN [DeliveryBackOffice].[dbo].[KindOfVPClient]	KVP WITH (NOLOCK)
						ON kvp.IdKindOfVPClient = VP.IdKindOfVPClient
					WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber					
					
				END
				ELSE
				BEGIN

					-- Actualizar bandera para envio de mensaje por WhatsApp
					UPDATE DeliveryBackOffice.dbo.PaymentZigi
					SET LinkRequestSent = 0, DateUpdated = GETDATE(), TokenUpdated = @Token
					WHERE RowStatus = 1 AND LinkRequestSent = 1 AND PaymentConfirmSent = 0 AND ZigiLinkStatus = 'CREATED' 
					AND GuideNumber = @GuideNumber AND GuideSerie = @GuideSerie;

					SELECT
						  201																AS	[IdResult]
						, 'Este envío ya fue pagado'										AS	[Title]
						, 'La guía ' + @GuideSerie + CAST(@GuideNumber AS NVARCHAR(20)) + 
						  ' ya fue pagada. Gracias por utilizar nuestros servicios.'		AS	[Message]
                        , ''                                                       AS  [ZigiLink]
				END
			END
			ELSE
			BEGIN
				SELECT
					  203																									AS	[IdResult]
					, '¡Listo! Hemos enviado tu link de pago'																AS	[Title]
					, 'En breve recibirás un mensaje por WhatsApp con el enlace para realizar tu pago de forma segura.' 	AS	[Message]
                    , @ZigiLink                                                                                          AS  [ZigiLink]
			END
		END
		ELSE
		BEGIN
			SELECT
				  202										AS	[IdResult]
				, 'Télefono no coincide'					AS	[Title]
				, 'El número de télefono no coincide.'		AS	[Message]
                , CAST(NULL AS NVARCHAR(500))              AS  [ZigiLink]
		END;

    END TRY
    BEGIN CATCH

		SELECT
			  409																				AS	[IdResult]
			, 'No se pudo generar el link de pago'												AS	[Title]
			, 'Ocurrió un inconveniente al crear el link de pago para la guía '
			  + @GuideSerie + CAST(@GuideNumber AS NVARCHAR(20)) 
			  + '. Por favor, inténtalo más tarde o comunícate con nuestro equipo de atención.' AS	[Message]
            , CAST(NULL AS NVARCHAR(500))                                                        AS  [ZigiLink]

        -- Capturar información del error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
		
    END CATCH;
END;