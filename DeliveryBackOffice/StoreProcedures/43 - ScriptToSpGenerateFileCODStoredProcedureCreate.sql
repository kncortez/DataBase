USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sp_generate_file_cod]    Script Date: 25/06/2021 23:26:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_generate_file_cod]
	@IdBank INT,
	@BatchCODId INT
AS
BEGIN
	--DECLARE @IdBank INT = 3; -- 31 33 5 3
	--DECLARE @BatchCODId INT = 17; -- 19 20 18 17

	-- Insert statements for procedure here
	IF OBJECT_ID('tempdb.dbo.#TableResultBACTemp', 'U') IS NOT NULL DROP TABLE #TableResultBACTemp;
	IF OBJECT_ID('tempdb.dbo.#TableResultBANRURALTemp', 'U') IS NOT NULL DROP TABLE #TableResultBANRURALTemp;
	IF OBJECT_ID('tempdb.dbo.#TableResultBITemp', 'U') IS NOT NULL DROP TABLE #TableResultBITemp;
	IF OBJECT_ID('tempdb.dbo.#TableResultGYTTemp', 'U') IS NOT NULL DROP TABLE #TableResultGYTTemp;

	IF @IdBank = 31
	BEGIN
		SELECT (SELECT cda.AccountNumber
				FROM DeliveryBackOffice.dbo.CatDebitAccountCOD cda
				WHERE cda.IdCatDebitAccountCOD = bd.CatDebitAccountCODId
				AND cda.BankId = @IdBank
				AND cda.RowStatus = 1) 'CUENTA DEBITO',
			   (SELECT dcba.DCBA_Num_account
			    FROM DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba
			    WHERE dcba.DCBA_Id = bd.CreditAccountId
			    AND dcba.DCBA_Bank_Id = @IdBank
			    AND dcba.DCBA_Id_estado = 1) 'CUENTA CREDITO',
			   FORMAT(bd.CreditDate, 'dd/MM/yyyy') 'FECHA',
			   Amount 'MONTO',
			   Reference 'REFERENCIA',
			   ISNULL((SELECT dcba.DCBA_Nom_account
					   FROM DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba
					   WHERE dcba.DCBA_Id = bd.CreditAccountId
					   AND dcba.DCBA_Bank_Id = @IdBank
					   AND dcba.DCBA_Id_estado = 1), 'SIN NOMBRE') 'BENEFICIARIO',
			   (SELECT ctt.TransactionType
				FROM DeliveryBackOffice.dbo.CatTransactionTypeCOD ctt
				WHERE ctt.IdCatTransactionTypeCOD = bd.CatTransactionTypeCODId
				AND ctt.BankId = @IdBank
				AND ctt.RowStatus = 1) 'TIPO DE TRANSACCION',
			   (SELECT cc.NumISO
				FROM DeliveryBackOffice.dbo.CatCurrencyCOD cc
				WHERE cc.IdCatCurrencyCOD = bd.CatCurrencyCODId
				AND cc.RowStatus = 1) 'MONEDA ACH',
			   (SELECT db.ACHCode
				FROM DeliveryBackOffice.dbo.DeliveryBank db
				WHERE db.Id_bank = bd.BankId
				AND db.Id_status = 1
				AND db.Id_country = 'GT') 'CODIGO BANCO ACH',
			   (SELECT cat.Description
				FROM DeliveryBackOffice.dbo.CatAccountTypeCOD cat
				WHERE cat.IdCatAccountTypeCOD = bd.CatAccountTypeCODId
				AND cat.RowStatus = 1) 'TIPO DE CUENTA OTRO BANCO',
			   (SELECT cco.Concept
				FROM DeliveryBackOffice.dbo.CatConceptCOD cco
				WHERE cco.IdCatConceptCOD = bd.CatConceptCODId
				AND cco.RowStatus = 1) 'CONCEPTO',
			   Password 'CONTRASEÑA'
		INTO #TableResultBACTemp
		FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
		WHERE bd.BatchCODId = @BatchCODId;

		SELECT * FROM #TableResultBACTemp;
	END

	IF @IdBank = 5
	BEGIN
		SELECT (ROW_NUMBER() OVER(ORDER BY bd.CreditAccountId)) 'REFERENCIA',
			   (SELECT dcba.DCBA_Num_account
			    FROM DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba
			    WHERE dcba.DCBA_Id = bd.CreditAccountId
			    AND dcba.DCBA_Bank_Id = @IdBank
			    AND dcba.DCBA_Id_estado = 1) 'CUENTA CREDITO',
			   Amount 'MONTO'
		INTO #TableResultBANRURALTemp
		FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
		WHERE bd.BatchCODId = @BatchCODId;

		SELECT * FROM #TableResultBANRURALTemp;
	END

	IF @IdBank = 33
	BEGIN
		SELECT bd.CatAccountTypeCODId 'TIPO DE CUENTA',
			   (SELECT dcba.DCBA_Num_account
			    FROM DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba
			    WHERE dcba.DCBA_Id = bd.CreditAccountId
			    AND dcba.DCBA_Bank_Id = @IdBank
			    AND dcba.DCBA_Id_estado = 1) 'CUENTA CREDITO',
			   ISNULL((SELECT dcba.DCBA_Nom_account
					   FROM DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba
					   WHERE dcba.DCBA_Id = bd.CreditAccountId
					   AND dcba.DCBA_Bank_Id = @IdBank
					   AND dcba.DCBA_Id_estado = 1), 'SIN NOMBRE') 'BENEFICIARIO',
			   Amount 'MONTO',
			   (SELECT cco.Concept
				FROM DeliveryBackOffice.dbo.CatConceptCOD cco
				WHERE cco.IdCatConceptCOD = bd.CatConceptCODId
				AND cco.RowStatus = 1) 'CONCEPTO'
		INTO #TableResultBITemp
		FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
		WHERE bd.BatchCODId = @BatchCODId;

		SELECT * FROM #TableResultBITemp;
	END

	IF @IdBank = 3
	BEGIN
		SELECT bd.CatAccountTypeCODId 'TIPO DE CUENTA',
			   (SELECT dcba.DCBA_Num_account
			    FROM DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba
			    WHERE dcba.DCBA_Id = bd.CreditAccountId
			    AND dcba.DCBA_Bank_Id = @IdBank
			    AND dcba.DCBA_Id_estado = 1) 'CUENTA CREDITO',
			   ISNULL((SELECT dcba.DCBA_Nom_account
					   FROM DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba
					   WHERE dcba.DCBA_Id = bd.CreditAccountId
					   AND dcba.DCBA_Bank_Id = @IdBank
					   AND dcba.DCBA_Id_estado = 1), 'SIN NOMBRE') 'BENEFICIARIO',
			   Amount 'MONTO'
		INTO #TableResultGYTTemp
		FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
		WHERE bd.BatchCODId = @BatchCODId;

		SELECT * FROM #TableResultGYTTemp;
	END
END


GO


