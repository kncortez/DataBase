
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-08-18>
-- Description:	< Registrar datos de cabecera y detalle de VisaLink  >
-- =============================================

CREATE PROCEDURE [dbo].[SetPaymentLinkData]
	
	@PaymentLinkTitle NVARCHAR(50),
	@PaymentLink NVARCHAR(MAX),
	@PaymentLinkStatus NVARCHAR(20),
	@PaymentLinkRequest NVARCHAR(MAX),
	@PaymentLinkResponse NVARCHAR(MAX),
	@PaymentLinkDetail TblGuidePrice READONLY,
	@Token NVARCHAR(50)

AS
BEGIN

	DECLARE @VisaLinkHeader AS TABLE (
		IdPaymentLinkHeader INT
	);

	DECLARE @VisaLinkDetail AS TABLE (
		IdPaymentLinkDetail INT
	);
	
	BEGIN TRANSACTION
	BEGIN TRY

		IF( EXISTS (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[PaymentLinkHeader] PLH WITH(NOLOCK) WHERE PLH.PaymentLink = @PaymentLink) )
		BEGIN
			-- Ya existe el link
			INSERT INTO @VisaLinkHeader
			SELECT
				TOP 1
					PLH.IdPaymentLinkHeader
			FROM
				[DeliveryBackOffice].[dbo].[PaymentLinkHeader] PLH WITH(NOLOCK)
			WHERE
				PLH.PaymentLinkTitle = @PaymentLinkTitle

			INSERT INTO @VisaLinkDetail
			SELECT
				PLD.IdPaymentLinkDetail
			FROM
				[DeliveryBackOffice].[dbo].[PaymentLinkDetail] PLD WITH(NOLOCK)
				INNER JOIN
					@VisaLinkHeader VLH
					ON
						PLD.PaymentLinkHeaderId = VLH.IdPaymentLinkHeader

		END
		ELSE
		BEGIN
			-- No existe link

			INSERT INTO [DeliveryBackOffice].[dbo].[PaymentLinkHeader]
				(PaymentLinkTitle, PaymentLink, PaymentLinkStatus, PaymentLinkRequest, PaymentLinkRespose, RowStatus, TokenCreated, DateCreated)
			OUTPUT inserted.IdPaymentLinkHeader INTO @VisaLinkHeader(IdPaymentLinkHeader)
			VALUES
				(@PaymentLinkTitle, @PaymentLink, 'Activo', @PaymentLinkRequest, @PaymentLinkResponse, 1, @Token, GETDATE())

			IF( EXISTS(SELECT TOP 1 1 FROM @VisaLinkHeader) )
			BEGIN

				INSERT INTO [DeliveryBackOffice].[dbo].[PaymentLinkDetail]
					(PaymentLinkHeaderId, GuideSerie, GuideNumber, GuideTotalFinalAmount, RowStatus, TokenCreated, DateCreated)
				OUTPUT inserted.IdPaymentLinkDetail INTO @VisaLinkDetail(IdPaymentLinkDetail)
				SELECT
					VLH.IdPaymentLinkHeader, PLD.GuideSerie, PLD.GuideNumber, PLD.GuidePrice, 1, @Token, GETDATE()
				FROM
					@VisaLinkHeader VLH
					CROSS JOIN
						@PaymentLinkDetail PLD
			END

		END

		IF( EXISTS(SELECT TOP 1 1 FROM @VisaLinkHeader) AND EXISTS(SELECT TOP 1 1 FROM @VisaLinkDetail) )
		BEGIN

			IF(@@TRANCOUNT > 0)
				COMMIT TRANSACTION;

			SELECT
				CAST(1 AS BIT) [blnResult],
				@PaymentLink [PaymentLink],
				(SELECT TOP 1 VLH.IdPaymentLinkHeader FROM @VisaLinkHeader VLH) [PaymentLinkId]

		END
		ELSE
		BEGIN

			ROLLBACK TRANSACTION;

			SELECT
				CAST(0 AS BIT) [blnResult],
				'' [PaymentLink],
				-1 [PaymentLinkId]

		END

	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION;

		SELECT
			CAST(0 AS BIT) [blnResult],
			'' [PaymentLink],
			-1 [PaymentLinkId]

	END CATCH

END