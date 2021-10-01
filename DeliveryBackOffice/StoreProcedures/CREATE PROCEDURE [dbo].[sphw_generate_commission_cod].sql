USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sphw_generate_commission_cod]    Script Date: 30/09/2021 15:44:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Morales,Oscar>
-- Create date: <2021-09-30>
-- Description:	<Generar archivos de comisiones COD>
-- =============================================

CREATE PROCEDURE [dbo].[sphw_generate_commission_cod]
	-- Add the parameters for the stored procedure here
	@CommissionId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Excluded INT = 0
	DECLARE @EnabledRow INT = 1
	DECLARE @IdCountry NVARCHAR(2) = 'GT'

	DECLARE @IdBank INT = 31

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
		AND bd.CatConceptCODId = 1 --Comisiones
		AND bd.CommissionId = @CommissionId
		GROUP BY cda.AccountNumber
		,bd.AccountNumber
		,bd.AccountName
		,ctt.TransactionType 
		,cc.NumISO 
		,db.ACHCode 
		,cat.Description 
		,cco.Concept
		,Password  ;

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
		AND bd.CatConceptCODId = 1 --Comisiones
		AND bd.CommissionId = @CommissionId
		ORDER BY bd.CreditDate DESC;

	SET NOCOUNT OFF;
END
GO
