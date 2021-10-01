USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sphw_generate_file_cod]    Script Date: 30/09/2021 14:56:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec sphw_generate_file_cod 31,0,1

ALTER PROCEDURE [dbo].[sphw_generate_file_cod]
	@IdBank INT,
	@BatchCODId INT,
	@CatConceptCODId INT = 2
AS
BEGIN
	--DECLARE @IdBank INT = 3; -- 31 33 5 3
	--DECLARE @BatchCODId INT = 17; -- 19 20 18 17
	DECLARE @Excluded INT = 0;
	DECLARE @EnabledRow INT = 1;
	DECLARE @IdCountry NVARCHAR(2) = 'GT';
	DECLARE @CatConceptCODDeposit INT = 2;
	DECLARE @CommissionId INT

	-- FORMATO BAC
	IF @IdBank = 31 AND @BatchCODId = -1 AND @CatConceptCODId = 1
	BEGIN
		SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cda.AccountNumber, ' ', ''), '-', ''), CHAR(1), ''), CHAR(2), ''), CHAR(3), ''), CHAR(9), ''), CHAR(10), ''), CHAR(13), '') 'CUENTA DEBITO',
			   RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(bd.AccountNumber)), CHAR(1), ''), CHAR(2), ''), CHAR(3), ''), CHAR(9), ''), CHAR(10), ''), CHAR(13), ''))) 'CUENTA CREDITO',
			   FORMAT(MAX(bd.CreditDate), 'dd/MM/yyyy') 'FECHA',
			   SUM(Amount) 'MONTO',
			   MAX(Reference) 'REFERENCIA',
			   RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(bd.AccountName)), ',', ''), CHAR(1), ''), CHAR(2), ''), CHAR(3), ''), CHAR(9), ''), CHAR(10), ''), CHAR(13), ''))) 'BENEFICIARIO',
			   ctt.TransactionType 'TIPO DE TRANSACCION',
			   cc.NumISO 'MONEDA ACH',
			   db.ACHCode 'CODIGO BANCO ACH',
			   cat.Description 'TIPO DE CUENTA OTRO BANCO',
			   cco.Concept 'CONCEPTO',
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
		WHERE 		
		bd.Excluded = @Excluded
		AND bd.CatConceptCODId = @CatConceptCODId
		AND ISNULL(bd.CommissionNotified,0) = 0
		AND  FORMAT(bd.CreditDate, 'dd/MM/yyyy') = FORMAT(GETDATE(), 'dd/MM/yyyy')
		GROUP BY cda.AccountNumber
		,bd.AccountNumber
		,bd.AccountName
		,ctt.TransactionType 
		,cc.NumISO 
		,db.ACHCode 
		,cat.Description 
		,cco.Concept
		,Password  ;
	END
	--FORMATO BAC DETALLE INTERNO
	IF @IdBank = 31 AND @BatchCODId = 0  AND @CatConceptCODId = 1
	BEGIN

		-- Se obtiene el siguiente Id de comisión
		SET @CommissionId = NEXT VALUE FOR DeliveryBackOffice.dbo.COD_CommissionId;

		-- Se guarda el Id de comisión y fecha en BatchDetailCOD de los servicios que se guardaran en el archivo
		UPDATE DeliveryBackOffice.dbo.BatchDetailCOD
		SET CommissionId = @CommissionId,
			CommissionDate = GETDATE()
		WHERE IdBatchDetailCOD IN (
			SELECT bd.IdBatchDetailCOD
			FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
			WHERE 
			--bd.BatchCODId = @BatchCODId
			--AND 
			bd.Excluded = @Excluded
			AND bd.CatConceptCODId = @CatConceptCODId
			AND ISNULL(bd.CommissionNotified,0) = 0
			AND  FORMAT(bd.CreditDate, 'dd/MM/yyyy') = FORMAT(GETDATE(), 'dd/MM/yyyy')
		)


		SELECT 
		       REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cda.AccountNumber, ' ', ''), '-', ''), CHAR(1), ''), CHAR(2), ''), CHAR(3), ''), CHAR(9), ''), CHAR(10), ''), CHAR(13), '') 'CUENTA DEBITO',
			   RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(bd.AccountNumber)), CHAR(1), ''), CHAR(2), ''), CHAR(3), ''), CHAR(9), ''), CHAR(10), ''), CHAR(13), ''))) 'CUENTA CREDITO',
			   FORMAT(bd.CreditDate, 'dd/MM/yyyy') 'FECHA',
			   bd.Amount 'MONTO',
			   bd.Reference 'REFERENCIA',
			   RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(bd.AccountName)), ',', ''), CHAR(1), ''), CHAR(2), ''), CHAR(3), ''), CHAR(9), ''), CHAR(10), ''), CHAR(13), ''))) 'BENEFICIARIO',
			   ctt.TransactionType 'TIPO DE TRANSACCION',
			   cc.NumISO 'MONEDA ACH',
			   db.ACHCode 'CODIGO BANCO ACH',
			   cat.Description 'TIPO DE CUENTA OTRO BANCO',
			   IIF(cco.IdCatConceptCOD = 1, cco.Concept, CONCAT(cco.Concept, ' ', bd.GuideSerie, bd.GuideNumber, ' Ref ', CAST(bd.BatchCODId AS VARCHAR(300)))) 'CONCEPTO',
			   bd.Password 'CONTRASEÑA',
			   CONCAT(bd.GuideSerie, bd.GuideNumber) 'GUIA',
			   bd.BatchCODId 'LOTE',
			   CONCAT(do.Sender_FirstName,' ',do.Sender_LastName) 'NOMBRE CLIENTE',
			   ISNULL(RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(LTRIM(bdc.AccountName)), ',', ''), CHAR(1), ''), CHAR(2), ''), CHAR(3), ''), CHAR(9), ''), CHAR(10), ''), CHAR(13), ''))) ,'') 'NOMBRE CUENTA CLIENTE',
			   ISNULL(invh.inv_SAPDocEntry,0) 'DOCUMENTO EN SAP (DocEntry)',
			   ISNULL(invh.inv_serieFEL,'') 'SERIE FEL',
			   ISNULL(invh.inv_numberFEL,'') 'NÚMERO FEL',
			   ISNULL(invh.inv_certificationFEL,'') 'CERTIFIACDO FEL'
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
		LEFT JOIN  DeliveryBackOffice.dbo.DeliveryOrder do
			ON bd.GuideSerie = do.Guide_Serie AND bd.GuideNumber = do.Guide_Number
		LEFT JOIN DeliveryBackOffice.dbo.BatchDetailCOD bdc
		ON  bdc.GuideSerie = bd.GuideSerie AND bdc.GuideNumber = bd.GuideNumber AND bdc.BankId <> 31
		LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail invd
			ON invd.dti_fk_orderSerie = bd.GuideSerie and invd.dti_fk_orderNumber = bd.GuideNumber
		LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader invh
			ON invh.inv_pk_id = invd.dti_fk_header
		WHERE 
		--bd.BatchCODId = @BatchCODId
		--AND 
		bd.Excluded = @Excluded
		AND bd.CatConceptCODId = @CatConceptCODId
		AND ISNULL(bd.CommissionNotified,0) = 0
		AND  FORMAT(bd.CreditDate, 'dd/MM/yyyy') = FORMAT(GETDATE(), 'dd/MM/yyyy')
		ORDER BY bd.CreditDate DESC;
	END
	--FORMATO BAC NORMAL
	IF @IdBank = 31 AND @CatConceptCODId = 2
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
			   IIF(cco.IdCatConceptCOD = 1, cco.Concept, CONCAT(cco.Concept, ' ', bd.GuideSerie, bd.GuideNumber, ' Ref ', CAST(bd.BatchCODId AS VARCHAR(300)))) 'CONCEPTO',
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
		AND bd.Excluded = @Excluded
		AND bd.CatConceptCODId = @CatConceptCODDeposit;
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
			   IIF(cco.IdCatConceptCOD = 1, cco.Concept, CONCAT(cco.Concept, ' ', bd.GuideSerie, bd.GuideNumber, ' Ref ', CAST(bd.BatchCODId AS VARCHAR(300)))) 'CONCEPTO'
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
