-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2025-11-04>
-- Description:	<ZIGI - Insertar informacion de nuevo link de pago zigi>
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
    @IsGroup            BIT = 0,
    @GeneratedMethod    NVARCHAR(100) = 'Identificación pendiente'
AS
BEGIN
    BEGIN TRY
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
            TokenCreated
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
            @Token
        );
		SELECT 200 [IdResult],
			'Link Creado' AS [Message],
			@ZigiLink		AS [ZigiLink],
			@GuideNumber	AS GuideNumber,
			@GuideSerie		AS GuideSerie,
			@PaidAmount		AS Amount,
			IIF(do.Receiver_FirstName = '',do.Receiver_Alternant_FullName,do.Receiver_FirstName) AS ReceiverName,
			do.Receiver_LastName AS ReceiverLastName,
			do.Receiver_Phone AS Phone,
			DO.ReceiverCountryId AS IdCountry,
			CC.Symbol
			FROM DeliveryOrder DO WITH(NOLOCK)
			LEFT JOIN Cost CS WITH(NOLOCK)
				ON CS.GuideNumber = DO.Guide_Number
			AND CS.GuideSerie = DO.Guide_Serie
			LEFT JOIN CatCurrencyCOD CC WITH(NOLOCK)
				ON ISNULL(CS.CodCurrency,1) = CC.IdCatCurrencyCOD
			WHERE DO.Guide_Number = @GuideNumber
			AND DO.Guide_Serie = @GuideSerie

		RETURN;
    END TRY
    BEGIN CATCH
        -- Capturar información del error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        
    END CATCH;
END;