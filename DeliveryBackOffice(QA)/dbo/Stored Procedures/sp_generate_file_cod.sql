
CREATE PROCEDURE [dbo].[sp_generate_file_cod]
	@IdBank INT,
	@BatchCODId INT
AS
BEGIN
	--DECLARE @IdBank INT = 3; -- 31 33 5 3
	--DECLARE @BatchCODId INT = 17; -- 19 20 18 17
	DECLARE @Excluded INT = 0;
	DECLARE @EnabledRow INT = 1;
	DECLARE @IdCountry NVARCHAR(2) = 'GT';

	-- FORMATO BAC
	IF @IdBank = 31
	BEGIN
		SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cda.AccountNumber, ' ', ''), '-', ''), CHAR(1), ''), CHAR(2), ''), CHAR(3), ''), CHAR(9), ''), CHAR(10), ''), CHAR(13), '') 'CUENTA DEBITO',
			   RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(bd.AccountNumber)), CHAR(1), ''), CHAR(2), ''), CHAR(3), ''), CHAR(9), ''), CHAR(10), ''), CHAR(13), ''))) 'CUENTA CREDITO',
			   FORMAT(bd.CreditDate, 'dd/MM/yyyy') 'FECHA',
			   Amount 'MONTO',
			   Reference 'REFERENCIA',
			   RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(bd.AccountName)), ',', ''), CHAR(1), ''), CHAR(2), ''), CHAR(3), ''), CHAR(9), ''), CHAR(10), ''), CHAR(13), ''))) 'BENEFICIARIO',
			   ctt.TransactionType 'TIPO DE TRANSACCION',
			   cc.NumISO 'MONEDA ACH',
			   db.ACHCode 'CODIGO BANCO ACH',
			   cat.Description 'TIPO DE CUENTA OTRO BANCO',
			   IIF(cco.IdCatConceptCOD = 1, cco.Concept, CONCAT(cco.Concept, ' ', bd.GuideSerie, bd.GuideNumber)) 'CONCEPTO',
			   Password 'CONTRASEÑA'
		FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
		LEFT JOIN DeliveryBackOffice.dbo.CatDebitAccountCOD cda
			ON cda.IdCatDebitAccountCOD = bd.CatDebitAccountCODId
			AND cda.BankId = @IdBank
			AND cda.RowStatus = @EnabledRow
		LEFT JOIN DeliveryBackOffice.dbo.CatTransactionTypeCOD ctt
			ON ctt.IdCatTransactionTypeCOD = bd.CatTransactionTypeCODId
			AND ctt.BankId = @IdBank
			AND ctt.RowStatus = @EnabledRow
		LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD cc
			ON cc.IdCatCurrencyCOD = bd.CatCurrencyCODId
			AND cc.RowStatus = @EnabledRow
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank db
			ON db.Id_bank = bd.BankId
			AND db.Id_status = @EnabledRow
			AND db.Id_country = @IdCountry
		LEFT JOIN DeliveryBackOffice.dbo.CatAccountTypeCOD cat
			ON cat.IdCatAccountTypeCOD = bd.CatAccountTypeCODId
			AND cat.RowStatus = @EnabledRow
		LEFT JOIN DeliveryBackOffice.dbo.CatConceptCOD cco
			ON cco.IdCatConceptCOD = bd.CatConceptCODId
			AND cco.RowStatus = @EnabledRow
		WHERE bd.BatchCODId = @BatchCODId
		AND bd.Excluded = @Excluded;
	END

	-- FORMATO BANRURAL
	IF @IdBank = 5
	BEGIN
		SELECT bd.Reference 'REFERENCIA',
			   RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(bd.AccountNumber)), CHAR(1), ''), CHAR(2), ''), CHAR(3), ''), CHAR(9), ''), CHAR(10), ''), CHAR(13), ''))) 'CUENTA CREDITO',
			   Amount 'MONTO'
		FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
		WHERE bd.BatchCODId = @BatchCODId
		AND bd.Excluded = @Excluded;
	END

	-- FORMATO BI
	IF @IdBank = 33
	BEGIN
		SELECT bd.CatAccountTypeCODId 'TIPO DE CUENTA',
			   RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(bd.AccountNumber)), CHAR(1), ''), CHAR(2), ''), CHAR(3), ''), CHAR(9), ''), CHAR(10), ''), CHAR(13), ''))) 'CUENTA CREDITO',
			   RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(bd.AccountName)), ',', ''), CHAR(1), ''), CHAR(2), ''), CHAR(3), ''), CHAR(9), ''), CHAR(10), ''), CHAR(13), ''))) 'BENEFICIARIO',
			   Amount 'MONTO',
			   IIF(cco.IdCatConceptCOD = 1, cco.Concept, CONCAT(cco.Concept, ' ', bd.GuideSerie, bd.GuideNumber)) 'CONCEPTO'
		FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
		LEFT JOIN DeliveryBackOffice.dbo.CatConceptCOD cco
			ON cco.IdCatConceptCOD = bd.CatConceptCODId
			AND cco.RowStatus = @EnabledRow
		WHERE bd.BatchCODId = @BatchCODId
		AND bd.Excluded = @Excluded;
	END

	-- FORMATO GYT
	IF @IdBank = 3
	BEGIN
		SELECT bd.CatAccountTypeCODId 'TIPO DE CUENTA',
			   RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(bd.AccountNumber)), CHAR(1), ''), CHAR(2), ''), CHAR(3), ''), CHAR(9), ''), CHAR(10), ''), CHAR(13), ''))) 'CUENTA CREDITO',
			   RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(bd.AccountName)), ',', ''), CHAR(1), ''), CHAR(2), ''), CHAR(3), ''), CHAR(9), ''), CHAR(10), ''), CHAR(13), ''))) 'BENEFICIARIO',
			   Amount 'MONTO'
		FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
		WHERE bd.BatchCODId = @BatchCODId
		AND bd.Excluded = @Excluded;
	END
END
