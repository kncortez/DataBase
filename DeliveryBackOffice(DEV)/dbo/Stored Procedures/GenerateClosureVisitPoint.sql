/* =================================================
   SP:        [dbo].[GenerateClosureVisitPoint]
   Propósito: SP para generar el cierre de los express center por punto de visita
   Autor:     Alejandro Rodríguez
   Historia:  
   Fecha:     2022-03-28
============================================
=== CHANGELOG ================================
2026-04-20 | Historia/épica: <FDAPI-5784> | Autor: Keila Cortéz |
-----
2025-11-04 | Description: <Se agrega al cierre los elementos de pago mediante Zigi> | Autor: Bilkar Morataya |
-----
2022-03-28 | Description: <SP para generar el cierre de los express center por punto de visita> | Autor: Alejandro Rodríguez |
-----
============================================ */
CREATE PROCEDURE [dbo].[GenerateClosureVisitPoint]
    @VisitPointId INT = 4246,
    @UserId INT,
    @TokenCreated NVARCHAR(50),
    @ClosurerPOS NVARCHAR(50) = NULL,
    @Voucher1 NVARCHAR(50) = NULL,
    @Bag1 NVARCHAR(50) = NULL,
    @Voucher2 NVARCHAR(50) = NULL,
    @Bag2 NVARCHAR(50) = NULL,
    @TotalAmountCashDeclared DECIMAL(18, 5),
    @TotalAmountCreditDeclared DECIMAL(18, 5),
	@TotalAmountCODCashDeclared DECIMAL(18, 5),
	@TotalAmountFacturaCashDeclared DECIMAL(18,5),
	@TotalAmountFacturaCardDeclared DECIMAL(18,5),
	@TotalAmountZigiDeclared DECIMAL(18, 5) = 0,
	@TotalAmountCODZigiDeclared DECIMAL(18, 5) = 0,
	@TotalAmountFacturaZigiDeclared DECIMAL(18, 5) = 0
AS
BEGIN

	DECLARE @UserId2 INT;
	DECLARE @TotalAmountCash DECIMAL(18, 5);
    DECLARE @TotalAmountCredit DECIMAL(18, 5);
	DECLARE @TotalAmountFacturaCash DECIMAL(18,5);
	DECLARE @TotalAmountFacturaCard DECIMAL(18,5);
	DECLARE @TotalAmountCODCash DECIMAL(18, 5);
	DECLARE @InvoiceAmountCash INT;
	DECLARE @InvoiceAmountCredit INT;
	DECLARE @InvoiceAmountFacturaCash INT;
	DECLARE @InvoiceAmountFacturaCard INT;
	DECLARE @InvoiceAmountCOD INT;
	DECLARE @TotalAmountZigi DECIMAL(18, 5);
	DECLARE @TotalAmountCODZigi DECIMAL(18, 5);
	DECLARE @TotalAmountFacturaZigi DECIMAL(18, 5);
	DECLARE @InvoiceAmountZigi INT;
	DECLARE @InvoiceAmountFacturaZigi INT;
	DECLARE @LastWorkingDate DATE;
	DECLARE @IsCNC BIT = 0;

	SELECT @IsCNC = 1
	FROM DeliveryBackOffice.dbo.VisitPointClient WITH(NOLOCK)
	WHERE CodeOfReference = @VisitPointId
	  AND IdKindOfVPClient IN (3,14,25);

	IF (@IsCNC = 1)
	BEGIN
		SELECT @LastWorkingDate = MIN(CAST(ACH.ClosureDate AS DATE))
		FROM DeliveryBackOffice.dbo.AccountingClosuresHeader ACH WITH(NOLOCK)
		WHERE ACH.VisitPoint = @VisitPointId
		  AND ACH.AccountingClosuresHeaderVisitPointId IS NULL
	END
	ELSE
	BEGIN
		SET @LastWorkingDate = CAST(GETDATE() AS DATE);
	END

	SET @UserId2 =
		(
			SELECT TOP 1
				   vp.RegisterUserID
			FROM DeliveryBackOffice.dbo.RegisterUser usr WITH(NOLOCK)
				LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount rua WITH(NOLOCK)
					ON rua.RuaIdUser = usr.UsrIdUser
					   AND rua.RuaRowStatus = 1
				INNER JOIN DeliveryBackOffice.dbo.Account ac WITH(NOLOCK)
					ON ac.AccIdAccount = rua.RuaIdAccount
				INNER JOIN DeliveryBackOffice.dbo.VisitPointByUser vp WITH(NOLOCK)
					ON vp.RegisterUserID = usr.UsrIdUser
			WHERE ac.AccIdAccount = @UserId
					AND ac.AccRowStatus = 1
		);

	SELECT	@TotalAmountCash =ISNULL(SUM(TotalAmountCash), 0),
		@TotalAmountCredit = ISNULL(SUM(TotalAmountCredit), 0),
		@TotalAmountFacturaCash = ISNULL(SUM(TotalAmountFacturaCash), 0),
		@TotalAmountFacturaCard = ISNULL(SUM(TotalAmountFacturaCard), 0),
		@TotalAmountCODCash = ISNULL(SUM(TotalAmountCODCash), 0),
		@InvoiceAmountCash = ISNULL(SUM(InvoiceAmountCash), 0),
		@InvoiceAmountCredit = ISNULL(SUM(InvoiceAmountCredit), 0),
		@InvoiceAmountFacturaCash = ISNULL(SUM(InvoiceAmountFacturaCash), 0),
		@InvoiceAmountFacturaCard = ISNULL(SUM(InvoiceAmountFacturaCard), 0),
		@InvoiceAmountCOD = ISNULL(SUM(InvoiceAmountCOD), 0),
		@TotalAmountZigi = ISNULL(SUM(TotalAmountZigi), 0),
		@TotalAmountCODZigi = ISNULL(SUM(TotalAmountCODZigi), 0),
		@TotalAmountFacturaZigi = ISNULL(SUM(TotalAmountFacturaZigi), 0),
		@InvoiceAmountZigi = ISNULL(SUM(InvoiceAmountZigi), 0),
		@InvoiceAmountFacturaZigi = ISNULL(SUM(InvoiceAmountFacturaZigi), 0)
	FROM DeliveryBackOffice.dbo.AccountingClosuresHeader ACH
	  WHERE CAST(ACH.ClosureDate AS DATE) = @LastWorkingDate
		AND ACH.VisitPoint = @VisitPointId
		AND ACH.AccountingClosuresHeaderVisitPointId IS NULL

	-- Variable para guardar el ID del cierre que se generó
	DECLARE @IdClosure INT = 0;

	BEGIN TRANSACTION
	BEGIN TRY
		-- Validar que existan datos para generar el cierre
		IF ((@TotalAmountCash + @TotalAmountCredit + @TotalAmountFacturaCash + @TotalAmountFacturaCard + @TotalAmountCODCash + @TotalAmountZigi + @TotalAmountCODZigi + @TotalAmountFacturaZigi) > 0)
		BEGIN
			INSERT INTO DeliveryBackOffice.dbo.AccountingClosuresHeaderVisitPoint
			(
				UserId, ClosurerPOS,
				TotalAmountCash, TotalAmountCashDeclared,
				TotalAmountCredit, TotalAmountCreditDeclared,
				VisitPoint, Voucher1, Bag1, Voucher2, Bag2, RowStatus,
				TokenCreated, DateCreated,
				ClosureDate,
				TokenUpdated, DateUpdated,
				TotalAmountCODCash, TotalAmountCODCashDeclared,
				TotalAmountFacturaCash, TotalAmountFacturaCashDeclared,
				TotalAmountFacturaCard, TotalAmountFacturaCardDeclared,
				InvoiceAmountCash, InvoiceAmountCredit,
				InvoiceAmountFacturaCash, InvoiceAmountFacturaCard,
				InvoiceAmountCOD,
				TotalAmountZigi, TotalAmountZigiDeclared,
				TotalAmountCODZigi, TotalAmountCODZigiDeclared,
				TotalAmountFacturaZigi, TotalAmountFacturaZigiDeclared,
				InvoiceAmountZigi, InvoiceAmountFacturaZigi
			)
			VALUES
			(
				@UserId2, @ClosurerPOS, 
				@TotalAmountCash, @TotalAmountCashDeclared, 
				@TotalAmountCredit, @TotalAmountCreditDeclared,
				@VisitPointId, @Voucher1, @Bag1, @Voucher2, @Bag2, 1, 
				@TokenCreated, GETDATE(), 
				@LastWorkingDate,
				NULL, NULL, 
				@TotalAmountCODCash, @TotalAmountCODCashDeclared, 
				@TotalAmountFacturaCash, @TotalAmountFacturaCashDeclared, 
				@TotalAmountFacturaCard, @TotalAmountFacturaCardDeclared,
				@InvoiceAmountCash, @InvoiceAmountCredit,
				@InvoiceAmountFacturaCash, @InvoiceAmountFacturaCard,
				@InvoiceAmountCOD,
				@TotalAmountZigi, @TotalAmountZigiDeclared,
				@TotalAmountCODZigi, @TotalAmountCODZigiDeclared,
				@TotalAmountFacturaZigi, @TotalAmountFacturaZigiDeclared,
				@InvoiceAmountZigi, @InvoiceAmountFacturaZigi
			);

			-- Variable que obtiene el ID del cierre generado
			SET @IdClosure =  SCOPE_IDENTITY();

			-- Inserta el ID del cierre de VisitPoint en los cierres que se hicieron durante el día
			UPDATE DeliveryBackOffice.dbo.AccountingClosuresHeader
			SET AccountingClosuresHeaderVisitPointId = @IdClosure
			WHERE CAST(ClosureDate AS DATE) = @LastWorkingDate
				AND VisitPoint = @VisitPointId
				AND AccountingClosuresHeaderVisitPointId IS NULL;

			SELECT 200 IdResult,
					   'Cierre generado exitosamente' Message,
					   Value 'URL',
					   @IdClosure 'IdCierre'
			FROM DeliveryBackOffice.dbo.ConfigParams
			WHERE Name = 'ClosureExpressCenter';
		END
		ELSE
		BEGIN
			SELECT 500 IdResult,
				   'No existen datos para generar cierre' Message;
		END

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		PRINT 'SE HIZO ROLLBACK';
        ROLLBACK TRANSACTION;

		SELECT 409 IdResult,
			   ERROR_MESSAGE() Message;
	END CATCH
	
	IF @@TRANCOUNT > 0
    BEGIN
        COMMIT TRANSACTION;
    END;
    
END