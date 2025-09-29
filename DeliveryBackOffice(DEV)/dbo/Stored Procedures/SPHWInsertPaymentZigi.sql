-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2025-11-04>
-- Description:	<ZIGI - Insertar informacion de nuevo link de pago zigi>
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2025-09-09>
-- Description:	<ZIGI - Se agrega la inserción de campos como PhoneNumber y IsGroup. Retorna el Id del registro, y devuelve el nuevo registro creado>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWInsertPaymentZigi]
    @GuideNumber        INT,
    @GuideSerie         NVARCHAR(2),
    @ZigiLinkStatus     NVARCHAR(20),
    @ZigiLink           NVARCHAR(MAX),
    @ZigiTransactionId  NVARCHAR(100),
    @ZigiReference      NVARCHAR(100),
    @ZigiPaymentLinkId  NVARCHAR(100),
    @PaidAmount         DECIMAL(10,2),
    @CollectValue       DECIMAL(10,2),
    @CODValue           DECIMAL(10,2),
    @Token              NVARCHAR(50),
    @PhoneNumber        NVARCHAR(20) = NULL,
    @IsGroup    BIT = 0
AS
BEGIN
    BEGIN TRY

        DECLARE @NewZigiPaymentId INT;

        -- DESACTIVA REGISTRO EN CASO DE CREAR OTRO (APLICA SOLO PARA MULTIGUIAS)
		-- IF @IsGroup = 1
		-- BEGIN

		    -- ACTUALIZACIÓN EN PaymentZigiMulti BASADA EN LOS RESULTADOS DE PaymentZigi (Guía, grupo, activo)
                UPDATE [dbo].[PaymentZigiMulti]
                SET RowStatus = 0
                WHERE Id_PaymentZigi IN (
                    SELECT ZigiPaymentId
                    FROM [dbo].[PaymentZigi]
                    WHERE GuideSerie = @GuideSerie
                      AND GuideNumber = @GuideNumber
                      AND IsGroup = 1
                      AND RowStatus = 1
                );

		    -- Desactiva registros previos --
		    UPDATE [dbo].[PaymentZigi] SET RowStatus = 0
                WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber
		                AND RowStatus = 1 AND ZigiLinkStatus != 'PAID';
		-- END;
        
        -- Inserción en la tabla PaymentZigi
        INSERT INTO [dbo].[PaymentZigi]
        (
            GuideNumber,
            GuideSerie,
            ZigiLinkStatus,
            ZigiLink,
            ZigiTransactionId,
            ZigiReference,
            ZigiPaymentLinkId,
            PaidAmount,
            CollectValue,
            CODValue,
            DateCreated,
            TokenCreated,
            PhoneNumber,
            IsGroup
        )
        VALUES
        (
            @GuideNumber,
            @GuideSerie,
            @ZigiLinkStatus,
            @ZigiLink,
            @ZigiTransactionId,
            @ZigiReference,
            @ZigiPaymentLinkId,
            @PaidAmount,
            @CollectValue,
            @CODValue,
            GETDATE(),
            @Token,
            @PhoneNumber,
            @IsGroup
        );

        -- Obtenemos el ID del registro recién insertado
        SET @NewZigiPaymentId = CONVERT(INT, SCOPE_IDENTITY());

        -- Devolvemos los resultados finales como confirmación
        SELECT 200 AS [IdResult],
            PZ.ZigiPaymentId as ZigiPaymentId,
            @NewZigiPaymentId as Id_PaymentZigi,
            'Link Creado' AS [Message],
			@ZigiLink		AS [ZigiLink],
			@GuideNumber	AS GuideNumber,
			@GuideSerie		AS GuideSerie,
			@PaidAmount		AS Amount,
			IIF(do.Receiver_FirstName = '',do.Receiver_Alternant_FullName,do.Receiver_FirstName) AS ReceiverName,
			do.Receiver_LastName AS ReceiverLastName,
			do.Receiver_Phone AS Phone,
			DO.ReceiverCountryId AS IdCountry,
			CC.Symbol,
			Pz.IsGroup
        FROM dbo.PaymentZigi PZ WITH (NOLOCK)
            LEFT JOIN DeliveryOrder DO WITH(NOLOCK)
                ON PZ.GuideSerie = DO.Guide_Serie AND PZ.GuideNumber = DO.Guide_Number
			LEFT JOIN Cost CS WITH(NOLOCK)
				ON CS.GuideNumber = DO.Guide_Number
			AND CS.GuideSerie = DO.Guide_Serie
			LEFT JOIN CatCurrencyCOD CC WITH(NOLOCK)
				ON ISNULL(CS.CodCurrency,1) = CC.IdCatCurrencyCOD
        WHERE PZ.ZigiPaymentId = @NewZigiPaymentId;

        RETURN;

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;