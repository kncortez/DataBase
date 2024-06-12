		UPDATE DeliveryCurrency
		SET IdCurrencyCOD=1, Currency_TokenUpdate = 'SYS-BPEDROZA', Currency_DateUpdate = GETDATE()
		WHERE Currency_Id IN (1)

		UPDATE DeliveryCurrency
		SET IdCurrencyCOD=2,Currency_TokenUpdate = 'SYS-BPEDROZA', Currency_DateUpdate = GETDATE()
		WHERE Currency_Id IN (2,5,7,10)

		UPDATE DeliveryCurrency
		SET IdCurrencyCOD=3, Currency_TokenUpdate = 'SYS-BPEDROZA', Currency_DateUpdate = GETDATE()
		WHERE Currency_Id IN (3,11,12,13)

		UPDATE DeliveryCurrency
		SET IdCurrencyCOD=4, Currency_TokenUpdate = 'SYS-BPEDROZA', Currency_DateUpdate = GETDATE()
		WHERE Currency_Id IN (9)