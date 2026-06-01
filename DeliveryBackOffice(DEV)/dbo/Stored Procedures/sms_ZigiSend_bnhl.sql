-- =============================================
-- System:		<SMS_Sender>
-- Author:		<Walter Orozco>
-- Create date: <2025-08-21>
-- Description:	<Su funcion es verificar si existen mensajes pendientes de enviar por Zigi a Whatsapp del cliente.>
-- =============================================
CREATE PROCEDURE [dbo].[sms_ZigiSend_bnhl]
	@Token NVARCHAR(50) = 'SYS_ZigiSMSender'
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
    BEGIN TRANSACTION;

	--================================================================================================
	--=================================== CREACION TABLA TEMP ========================================
	--================================================================================================

	IF OBJECT_ID('tempdb..#WhatsappRecipientZigi') IS NOT NULL
		DROP TABLE #WhatsappRecipientZigi;

	CREATE TABLE #WhatsappRecipientZigi
	(
		[_Phone]          NVARCHAR(20)   NOT NULL,   
		[_StatusOrderId]  INT            NOT NULL,   
		[_LinkCreated]    BIT            NOT NULL,   
		[_LinkPaid]       BIT            NOT NULL,   
		[_FirstName]      NVARCHAR(100)  NULL,
		[_LastName]       NVARCHAR(100)  NULL,
		[_IdCountry]      NVARCHAR(10)   NULL,       
		[_NirPhone]       NVARCHAR(10)   NULL,       
		[_GuideSerie]     NVARCHAR(2)    NOT NULL,   
		[_GuideNumber]    INT            NOT NULL,
		[_Amount]         DECIMAL(10,2)  NULL,
		[_Currency]       NVARCHAR(10)   NULL,      
		[_LinkZigi]       NVARCHAR(MAX)  NULL,
		CONSTRAINT PK_WhatsappRecipientZigi PRIMARY KEY CLUSTERED ([_GuideSerie], [_GuideNumber])
	);

    print 'ingresa'
	-- Insertar pendientes de envio de link
	--INSERT INTO #WhatsappRecipientZigi
	SELECT 
		   DO.Receiver_Phone
		 , DO.StatusOrderId
		 , 1	--Tipo de mensaje: Solicitud de link
		 , 0
		 , IIF(DO.Receiver_FirstName = '',DO.Receiver_Alternant_FullName,DO.Receiver_FirstName)
		 , DO.Receiver_LastName
		 , DO.ReceiverCountryId
		 , DPC.PrefixNumber
		 , Z.GuideSerie
		 , Z.GuideNumber
		 , Z.PaidAmount
		 , CCC.Symbol
		 , Z.ZigiLink
	FROM DeliveryBackOffice.dbo.PaymentZigi Z WITH (NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
		ON Z.GuideSerie = DO.Guide_Serie AND Z.GuideNumber = DO.Guide_Number
	LEFT JOIN DeliveryBackOffice.dbo.DefaultValuesPerCountry DPC WITH(NOLOCK)
		ON DO.ReceiverCountryId = DPC.IdCountry
	LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
		ON DO.ReceiverCountryId = DC.Currency_IdCountry
	LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
		ON CCC.IdCatCurrencyCOD = DC.IdCurrencyCOD
	WHERE Z.RowStatus = 1 AND Z.LinkRequestSent = 0 AND Z.PaymentConfirmSent = 0 AND Z.ZigiLinkStatus = 'CREATED' AND DC.DefaultPerCountry = 1
	UNION 
	SELECT 
		   DO.Receiver_Phone
		 , DO.StatusOrderId
		 , 0
		 , 1	--Tipo de mensaje: Confirmacion de pago de link
		 , IIF(DO.Receiver_FirstName = '',DO.Receiver_Alternant_FullName,DO.Receiver_FirstName)
		 , DO.Receiver_LastName
		 , DO.ReceiverCountryId
		 , DPC.PrefixNumber
		 , Z.GuideSerie
		 , Z.GuideNumber
		 , Z.PaidAmount
		 , CCC.Symbol
		 , Z.ZigiLink
	FROM DeliveryBackOffice.dbo.PaymentZigi Z WITH (NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
		ON Z.GuideSerie = DO.Guide_Serie AND Z.GuideNumber = DO.Guide_Number
	LEFT JOIN DeliveryBackOffice.dbo.DefaultValuesPerCountry DPC WITH(NOLOCK)
		ON DO.ReceiverCountryId = DPC.IdCountry
	LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
		ON DO.ReceiverCountryId = DC.Currency_IdCountry
	LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
		ON CCC.IdCatCurrencyCOD = DC.IdCurrencyCOD
	WHERE Z.RowStatus = 1 AND Z.LinkRequestSent = 1 AND Z.PaymentConfirmSent = 0 AND Z.ZigiLinkStatus = 'PAID' AND DC.DefaultPerCountry = 1;
	print 'ingresa2'
	--================================================================================================
	--================================== ACTUALIZACION DE DATOS ======================================
	--================================================================================================

	UPDATE DeliveryBackOffice.dbo.PaymentZigi
	SET LinkRequestSent = 1, DateUpdated = GETDATE(), TokenUpdated = @Token
	WHERE RowStatus = 1 AND LinkRequestSent = 0 AND PaymentConfirmSent = 0 AND ZigiLinkStatus = 'CREATED';

	UPDATE DeliveryBackOffice.dbo.PaymentZigi
	SET PaymentConfirmSent = 1, DateUpdated = GETDATE(), TokenUpdated = @Token
	WHERE RowStatus = 1 AND LinkRequestSent = 1 AND PaymentConfirmSent = 0 AND ZigiLinkStatus = 'PAID';

	--================================================================================================
	--=================================== ENVIO DE INFORMACION =======================================
	--================================================================================================

	SELECT * FROM #WhatsappRecipientZigi
    
    COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

		INSERT INTO [DeliveryBackOffice].[dbo].[RoutePreparationLogError]
        (
            [ErrorDescription]
          , [ErrorNumber]
          , [ErrorProcedure]
          , [ErrorLine]
          , [GuideSerie]
          , [GuideNumber]
          , [TokenCreated]
          , [DateCreated]
        )
        VALUES
        (   CAST(ERROR_MESSAGE() AS NVARCHAR(300))  -- ErrorDescription - varchar(300)
          , ERROR_NUMBER()                         -- ErrorNumber - int
          , ERROR_PROCEDURE()                      -- ErrorProcedure - varchar(100)
          , ERROR_LINE()                           -- ErrorLine - int
          , NULL                                   -- GuideSerie - nvarchar(2)
          , NULL                                   -- GuideNumber - int
          , ''                                     -- TokenCreated - varchar(50)
          , GETDATE()                              -- DateCreated - datetime
            );

		-- Manejo de errores con PRINT
		DECLARE @ErrorMessage NVARCHAR(4000);
		SELECT @ErrorMessage = ERROR_MESSAGE();
		PRINT 'Error: ' + @ErrorMessage;
	END CATCH;
END