-- =============================================
-- System:		<SMS_Sender>
-- Author:		<Walter Orozco>
-- Create date: <2025-08-21>
-- Description:	<Su funcion es verificar si existen mensajes pendientes de enviar por Zigi a Whatsapp del cliente.>
-- =============================================
-- System:		<SMS_Sender>
-- Author:		<Bilkar Morataya>
-- Create date: <2025-08-28>
-- Description:	<Se agregan 2 campos de la tabla DefaultValuesPerCountry para obtener la expresion regular y el numero de Whatsapp y que sea dinámico>
-- =============================================
-- System:		<SMS_Sender>
-- Author:		<Bilkar Morataya>
-- Create date: <2025-09-03>
-- Description:	<El campo WhatsappNumber puede venir el asignado para la guía, o si se personalizó, usará el que viene desde la tabla PaymentZigi, esto último beneficia a links pedidos desde EXC para uniguías y multiguías>
-- =============================================
-- System:		<SMS_Sender>
-- Author:		<Bilkar Morataya>
-- Create date: <2025-09-10>
-- Description:	<El campo TypeTransaction indica si es "del paquete" o "de la transacción", esto para el mensaje de Whatsapp, IsGroup para definir si es un grupo de guías o una guía individual>
-- =============================================

CREATE PROCEDURE [dbo].[sms_ZigiSend]
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
		[_GuideSerie]     NVARCHAR(3)    NOT NULL,
		[_GuideNumber]    INT            NOT NULL,
		[_Amount]         DECIMAL(10,2)  NULL,
		[_Currency]       NVARCHAR(10)   NULL,      
		[_LinkZigi]       NVARCHAR(MAX)  NULL,
		[_RegxMovilPhone] NVARCHAR(50)  NULL,
		[_WhatsappNumber] NVARCHAR(15)   NULL,
        [_IsGroup]        BIT            NOT NULL DEFAULT 0,
        [_TypeTransaction]  NVARCHAR(100) NULL,
		CONSTRAINT PK_WhatsappRecipientZigi PRIMARY KEY CLUSTERED ([_GuideSerie], [_GuideNumber])
	);

    
	-- Insertar pendientes de envio de link
	INSERT INTO #WhatsappRecipientZigi
	SELECT 
		   ISNULL(Z.PhoneNumber, DO.Receiver_Phone) as Phone
		 , DO.StatusOrderId
		 , 1	--Tipo de mensaje: Solicitud de link
		 , 0
		 , IIF(DO.Receiver_FirstName = '',DO.Receiver_Alternant_FullName,DO.Receiver_FirstName)
		 , DO.Receiver_LastName
		 , DO.ReceiverCountryId
		 , DPC.PrefixNumber
		 , CASE
                WHEN Z.IsGroup = 1 THEN
                        'MFD'		-- Si IsGroup es 1, usa MFD como serie, para identificar multiguías
                ELSE Z.GuideSerie 	-- Si IsGroup es 0, solo usa GuideNumber
            END AS GuideSerie
		 , CASE
                WHEN Z.IsGroup = 1 THEN
                        Z.ZigiPaymentId	-- Si IsGroup es 1, usa el Id del registro en PaymentZigi, para identificar multiguías
                ELSE Z.GuideNumber 		-- Si IsGroup es 0, solo usa GuideNumber
            END AS GuideNumber
		 , Z.PaidAmount
		 , CCC.Symbol
		 , Z.ZigiLink
		 , DPC.RegxMovilPhone
		 , DPC.WhatsappNumber
	     , Z.IsGroup
	     , CASE
                WHEN z.IsGroup = 0 THEN 'del paquete'
	            ELSE 'de la transacción'
	        END AS TypeTransaction
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
		   ISNULL(Z.PhoneNumber, DO.Receiver_Phone) as Phone
		 , DO.StatusOrderId
		 , 0
		 , 1	--Tipo de mensaje: Confirmacion de pago de link
		 , IIF(DO.Receiver_FirstName = '',DO.Receiver_Alternant_FullName,DO.Receiver_FirstName)
		 , DO.Receiver_LastName
		 , DO.ReceiverCountryId
	     , DPC.PrefixNumber
		 , CASE
                WHEN Z.IsGroup = 1 THEN
                        'MFD'		-- Si IsGroup es 1, usa MFD como serie, para identificar multiguías
                ELSE Z.GuideSerie 	-- Si IsGroup es 0, solo usa GuideNumber
            END AS GuideSerie
		 , CASE
                WHEN Z.IsGroup = 1 THEN
                        Z.ZigiPaymentId	-- Si IsGroup es 1, usa el Id del registro en PaymentZigi, para identificar multiguías
                ELSE Z.GuideNumber 		-- Si IsGroup es 0, solo usa GuideNumber
            END AS GuideNumber
		 , Z.PaidAmount
		 , CCC.Symbol
		 , Z.ZigiLink
		 , DPC.RegxMovilPhone
		 , DPC.WhatsappNumber
	     , Z.IsGroup
	     , CASE
                WHEN z.IsGroup = 0 THEN 'del paquete'
	                ELSE 'de la transacción'
	        END AS TypeTransaction
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