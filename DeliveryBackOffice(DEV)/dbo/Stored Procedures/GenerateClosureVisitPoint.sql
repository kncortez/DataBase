-- =============================================
-- Author:		<Alejandro Rodríguez>
-- Create date: <2022-03-28>
-- Description:	<SP para generar el cierre de los express center por punto de visita>
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2025-11-04>
-- Description:	<Se agrega al cierre los elementos de pago mediante Zigi>
-- =============================================

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
	-- MODIFICACIÓN [2025-11-04] - Parámetros declarados para Zigi
	@TotalAmountZigiDeclared DECIMAL(18, 5) = 0,
	@TotalAmountCODZigiDeclared DECIMAL(18, 5) = 0,
	@TotalAmountFacturaZigiDeclared DECIMAL(18, 5) = 0
	-- FIN MODIFICACIÓN
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
	-- MODIFICACIÓN [2025-11-04] - Variables para Zigi
	DECLARE @TotalAmountZigi DECIMAL(18, 5);
	DECLARE @TotalAmountCODZigi DECIMAL(18, 5);
	DECLARE @TotalAmountFacturaZigi DECIMAL(18, 5);
	DECLARE @InvoiceAmountZigi INT;
	DECLARE @InvoiceAmountFacturaZigi INT;
	-- FIN MODIFICACIÓN

	SET @UserId2 =
		(
			SELECT TOP 1
				   vp.RegisterUserID
			FROM [dbo].RegisterUser usr
				LEFT JOIN [dbo].[RolByUserByAccount] rua
					ON rua.RuaIdUser = usr.UsrIdUser
					   AND rua.RuaRowStatus = 1
				INNER JOIN [dbo].Account ac
					ON ac.AccIdAccount = rua.RuaIdAccount
					   AND ac.AccRowStatus = 1
				INNER JOIN VisitPointByUser vp
					ON vp.RegisterUserID = usr.UsrIdUser
			WHERE ac.AccIdAccount = @UserId
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
		-- MODIFICACIÓN [2025-11-04] - Totales para Zigi
		@TotalAmountZigi = ISNULL(SUM(TotalAmountZigi), 0),
		@TotalAmountCODZigi = ISNULL(SUM(TotalAmountCODZigi), 0),
		@TotalAmountFacturaZigi = ISNULL(SUM(TotalAmountFacturaZigi), 0),
		@InvoiceAmountZigi = ISNULL(SUM(InvoiceAmountZigi), 0),
		@InvoiceAmountFacturaZigi = ISNULL(SUM(InvoiceAmountFacturaZigi), 0)
		-- FIN MODIFICACIÓN
	FROM AccountingClosuresHeader ACH
	WHERE CAST(ACH.DateCreated AS DATE) = CAST(GETDATE() AS DATE)
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
				TokenUpdated, DateUpdated,
				TotalAmountCODCash, TotalAmountCODCashDeclared,
				TotalAmountFacturaCash, TotalAmountFacturaCashDeclared,
				TotalAmountFacturaCard, TotalAmountFacturaCardDeclared,
				InvoiceAmountCash, InvoiceAmountCredit,
				InvoiceAmountFacturaCash, InvoiceAmountFacturaCard,
				InvoiceAmountCOD,
				-- MODIFICACIÓN [2025-11-04] - Campos para Zigi
				TotalAmountZigi, TotalAmountZigiDeclared,
				TotalAmountCODZigi, TotalAmountCODZigiDeclared,
				TotalAmountFacturaZigi, TotalAmountFacturaZigiDeclared,
				InvoiceAmountZigi, InvoiceAmountFacturaZigi
				-- FIN MODIFICACIÓN
			)
			VALUES
			(
				@UserId2, @ClosurerPOS, 
				@TotalAmountCash, @TotalAmountCashDeclared, 
				@TotalAmountCredit, @TotalAmountCreditDeclared,
				@VisitPointId, @Voucher1, @Bag1, @Voucher2, @Bag2, 1, 
				@TokenCreated, GETDATE(),
				NULL, NULL, 
				@TotalAmountCODCash, @TotalAmountCODCashDeclared, 
				@TotalAmountFacturaCash, @TotalAmountFacturaCashDeclared, 
				@TotalAmountFacturaCard, @TotalAmountFacturaCardDeclared,
				@InvoiceAmountCash, @InvoiceAmountCredit,
				@InvoiceAmountFacturaCash, @InvoiceAmountFacturaCard,
				@InvoiceAmountCOD,
				-- MODIFICACIÓN [2025-11-04] - Valores para Zigi
				@TotalAmountZigi, @TotalAmountZigiDeclared,
				@TotalAmountCODZigi, @TotalAmountCODZigiDeclared,
				@TotalAmountFacturaZigi, @TotalAmountFacturaZigiDeclared,
				@InvoiceAmountZigi, @InvoiceAmountFacturaZigi
				-- FIN MODIFICACIÓN
			);

			-- Variable que obtiene el ID del cierre generado
			SET @IdClosure =  SCOPE_IDENTITY();

			-- Inserta el ID del cierre de VisitPoint en los cierres que se hicieron durante el día
			UPDATE [dbo].[AccountingClosuresHeader]
			SET AccountingClosuresHeaderVisitPointId = @IdClosure
			WHERE CAST(DateCreated AS DATE) = CAST(GETDATE() AS DATE)
				AND VisitPoint = @VisitPointId
				AND AccountingClosuresHeaderVisitPointId IS NULL;

			SELECT 200 IdResult,
					   'Cierre generado exitosamente' Message,
					   Value 'URL',
					   @IdClosure 'IdCierre'
			FROM ConfigParams
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