-----
-- Historia: HW-31
-- Se modifica para poder enviar como referencia para el archivo 
-- de BAC el número de guía en lugar del correlativo que se tenía
----
CREATE PROCEDURE [dbo].[GetGenerateFileCOD]
	@IdBank INT,
	@BatchCODId INT
AS
BEGIN
	-- Insert statements for procedure here
	IF OBJECT_ID('tempdb.dbo.#TableResultBACTemp', 'U') IS NOT NULL DROP TABLE #TableResultBACTemp;
	IF OBJECT_ID('tempdb.dbo.#TableResultBANRURALTemp', 'U') IS NOT NULL DROP TABLE #TableResultBANRURALTemp;
	IF OBJECT_ID('tempdb.dbo.#TableResultBITemp', 'U') IS NOT NULL DROP TABLE #TableResultBITemp;
	IF OBJECT_ID('tempdb.dbo.#TableResultGYTTemp', 'U') IS NOT NULL DROP TABLE #TableResultGYTTemp;

	IF @IdBank = 31
	BEGIN
		SELECT REPLACE(REPLACE((SELECT cda.AccountNumber
							    FROM DeliveryBackOffice.dbo.CatDebitAccountCOD cda
								WHERE cda.IdCatDebitAccountCOD = bd.CatDebitAccountCODId
								AND cda.BankId = @IdBank
								AND cda.RowStatus = 1),
							   ' ', ''
							  ), 
						'-', ''
					  ) 'CUENTA DEBITO',
			  REPLACE(REPLACE(ISNULL((SELECT dcba.DCBA_Num_account
									  FROM DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba
									  WHERE dcba.DCBA_Id = bd.CreditAccountId
									  AND dcba.DCBA_Bank_Id = @IdBank
									  AND dcba.DCBA_Id_estado = 1),
									 (SELECT ISNULL(cd.CODAccountNumber, cs.CODAccountNumber) 
									  FROM dbo.DeliveryOrder ord
									  LEFT JOIN dbo.VisitPointClient vp ON vp.CodeOfReference = ord.Sender_ID
									  LEFT JOIN dbo.Customer cs ON cs.IdCustomer = vp.CustomerID
									  LEFT JOIN dbo.Customer cd ON cd.IdCustomer = ord.IdCustomer
									  WHERE ord.Guide_Serie = bd.GuideSerie AND ord.Guide_Number = bd.GuideNumber)
									 ),
								' ', ''
							 ), 
					   '-', ''
					 ) 'CUENTA CREDITO',
			   FORMAT(bd.CreditDate, 'dd/MM/yyyy') 'FECHA',
			   Amount 'MONTO',
			   bd.BatchCODId 'REFERENCIA',
			   REPLACE(ISNULL((SELECT dcba.DCBA_Nom_account
							   FROM DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba
							   WHERE dcba.DCBA_Id = bd.CreditAccountId
							   AND dcba.DCBA_Bank_Id = @IdBank
							   AND dcba.DCBA_Id_estado = 1),
							  (SELECT ISNULL(cd.CODAccountName, cs.CODAccountName) 
							   FROM dbo.DeliveryOrder ord
							   LEFT JOIN dbo.VisitPointClient vp ON vp.CodeOfReference = ord.Sender_ID
							   LEFT JOIN dbo.Customer cs ON cs.IdCustomer = vp.CustomerID
							   LEFT JOIN dbo.Customer cd ON cd.IdCustomer = ord.IdCustomer
							   WHERE ord.Guide_Serie = bd.GuideSerie AND ord.Guide_Number = bd.GuideNumber)
							 ), 
						',', ''
					  ) 'BENEFICIARIO',
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
		SELECT 
				CAST(bd.BatchCODId AS VARCHAR(200)) 'REFERENCIA',
			    REPLACE(REPLACE(ISNULL((SELECT dcba.DCBA_Num_account
									 FROM DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba
									 WHERE dcba.DCBA_Id = bd.CreditAccountId
									 AND dcba.DCBA_Bank_Id = @IdBank
									 AND dcba.DCBA_Id_estado = 1),
									(SELECT ISNULL(cd.CODAccountNumber, cs.CODAccountNumber) 
									 FROM dbo.DeliveryOrder ord
									 LEFT JOIN dbo.VisitPointClient vp ON vp.CodeOfReference = ord.Sender_ID
									 LEFT JOIN dbo.Customer cs ON cs.IdCustomer = vp.CustomerID
									 LEFT JOIN dbo.Customer cd ON cd.IdCustomer = ord.IdCustomer
									 WHERE ord.Guide_Serie = bd.GuideSerie AND ord.Guide_Number = bd.GuideNumber)
								   ),
								' ', ''
							), 
						 '-', ''
					   ) 'CUENTA CREDITO',
			   Amount 'MONTO'
		INTO #TableResultBANRURALTemp
	    FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
		WHERE bd.BatchCODId = @BatchCODId;

		SELECT * FROM #TableResultBANRURALTemp;
	END

	IF @IdBank = 33
	BEGIN
		SELECT bd.CatAccountTypeCODId 'TIPO DE CUENTA',
			   REPLACE(REPLACE(ISNULL((SELECT dcba.DCBA_Num_account
									FROM DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba
									WHERE dcba.DCBA_Id = bd.CreditAccountId
									AND dcba.DCBA_Bank_Id = @IdBank
									AND dcba.DCBA_Id_estado = 1),
								   (SELECT ISNULL(cd.CODAccountNumber, cs.CODAccountNumber) 
									FROM dbo.DeliveryOrder ord
									LEFT JOIN dbo.VisitPointClient vp ON vp.CodeOfReference = ord.Sender_ID
									LEFT JOIN dbo.Customer cs ON cs.IdCustomer = vp.CustomerID
									LEFT JOIN dbo.Customer cd ON cd.IdCustomer = ord.IdCustomer
									WHERE ord.Guide_Serie = bd.GuideSerie AND ord.Guide_Number = bd.GuideNumber)
								  ),
								' ', ''
						   ), 
						'-', ''
					  ) 'CUENTA CREDITO',
			   REPLACE(ISNULL((SELECT dcba.DCBA_Nom_account
							   FROM DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba
							   WHERE dcba.DCBA_Id = bd.CreditAccountId
							   AND dcba.DCBA_Bank_Id = @IdBank
							   AND dcba.DCBA_Id_estado = 1), 
							  (SELECT ISNULL(cd.CODAccountName, cs.CODAccountName) 
							   FROM dbo.DeliveryOrder ord
							   LEFT JOIN dbo.VisitPointClient vp ON vp.CodeOfReference = ord.Sender_ID
							   LEFT JOIN dbo.Customer cs ON cs.IdCustomer = vp.CustomerID
							   LEFT JOIN dbo.Customer cd ON cd.IdCustomer = ord.IdCustomer
							   WHERE ord.Guide_Serie = bd.GuideSerie AND ord.Guide_Number = bd.GuideNumber)
							 ), 
						',', ''
					  ) 'BENEFICIARIO',
			   Amount 'MONTO',
			   CONCAT( (SELECT cco.Concept
				FROM DeliveryBackOffice.dbo.CatConceptCOD cco
				WHERE cco.IdCatConceptCOD = bd.CatConceptCODId
				AND cco.RowStatus = 1),' Ref ', CAST(bd.BatchCODId AS VARCHAR(200)) ,  ' Guía ', bd.GuideSerie , CAST(bd.GuideNumber AS VARCHAR(200))) 'CONCEPTO'
		INTO #TableResultBITemp
		FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
		WHERE bd.BatchCODId = @BatchCODId;

		SELECT * FROM #TableResultBITemp;
	END

	IF @IdBank = 3
	BEGIN
		SELECT bd.CatAccountTypeCODId 'TIPO DE CUENTA',
			   REPLACE(REPLACE(ISNULL((SELECT dcba.DCBA_Num_account
								    FROM DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba
								    WHERE dcba.DCBA_Id = bd.CreditAccountId
								    AND dcba.DCBA_Bank_Id = @IdBank
								    AND dcba.DCBA_Id_estado = 1),
								   (SELECT ISNULL(cd.CODAccountNumber, cs.CODAccountNumber) 
									FROM dbo.DeliveryOrder ord
									LEFT JOIN dbo.VisitPointClient vp ON vp.CodeOfReference = ord.Sender_ID
									LEFT JOIN dbo.Customer cs ON cs.IdCustomer = vp.CustomerID
									LEFT JOIN dbo.Customer cd ON cd.IdCustomer = ord.IdCustomer
									WHERE ord.Guide_Serie = bd.GuideSerie AND ord.Guide_Number = bd.GuideNumber)
								  ),
								' ', ''
						   ), 
						'-', ''
					  ) 'CUENTA CREDITO',
			   REPLACE(ISNULL((SELECT dcba.DCBA_Nom_account
							   FROM DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba
							   WHERE dcba.DCBA_Id = bd.CreditAccountId
							   AND dcba.DCBA_Bank_Id = @IdBank
							   AND dcba.DCBA_Id_estado = 1), 
							  (SELECT ISNULL(cd.CODAccountName, cs.CODAccountName) 
							   FROM dbo.DeliveryOrder ord
							   LEFT JOIN dbo.VisitPointClient vp ON vp.CodeOfReference = ord.Sender_ID
							   LEFT JOIN dbo.Customer cs ON cs.IdCustomer = vp.CustomerID
							   LEFT JOIN dbo.Customer cd ON cd.IdCustomer = ord.IdCustomer
							   WHERE ord.Guide_Serie = bd.GuideSerie AND ord.Guide_Number = bd.GuideNumber)
							 ), 
						',', ''
					  ) 'BENEFICIARIO',
			   Amount 'MONTO'
		INTO #TableResultGYTTemp
		FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
		WHERE bd.BatchCODId = @BatchCODId;

		SELECT * FROM #TableResultGYTTemp;
	END
END