/* =================================================
   SP:        [dbo].[spws_get_StartRecollectionCardtransaction]
   Propósito: Genera o recupera una orden de pago para recolecciones con tarjeta
   Autor:     
   Historia:  
   Fecha:     
============================================

=== CHANGELOG ============================
2026-03-05 | FDAPI-5772 | Autor: Brenda Echeverria |
-----
=========================================== */

CREATE PROCEDURE [dbo].[spws_get_StartRecollectionCardtransaction]
 @System		as int			= 1 
,@Currency		as int			= 320
,@IdCustomer	as int			= 1  	  	
,@Token			as nvarchar(50) = ''
,@NumberGuides 	as varchar(MAX)	= ''
,@SerieGuides	as varchar(Max)	= ''
,@DateCreated	as datetime				
AS
BEGIN
	DECLARE @IdTransaction BIGINT= 0; 
	DECLARE @TEMPOrderNumber VARCHAR(38);
	DECLARE @TOTALPAGAR INT = 0;

	select @IdTransaction = count(1) from DeliveryBackOffice.dbo.CreditCardTransactionByCustomer WITH(NOLOCK);

	SELECT @TEMPOrderNumber = 'TMP'+CONVERT(VARCHAR,@IdTransaction);
		
	DECLARE @TBGUIDES TABLE 
	(
		ITERATOR int Identity(1,1) 
		,GuideNumber INT 
		,SerieGuide NVARCHAR(2)
	);

	;WITH CTE AS 
	(
		SELECT 
			Split.a.value('.', 'NVARCHAR(MAX)') GuideNumber,
			ROW_NUMBER() OVER
			(
				ORDER BY ( SELECT NULL)
			) RN
		FROM
		(
			SELECT 
				CAST('<X>'+REPLACE(@NumberGuides, ',', '</X><X>')+'</X>' AS XML) AS String
		) AS A
		CROSS APPLY String.nodes('/X') AS Split(a)
	),
	CTE1 AS 
	(
		SELECT 
			Split.a.value('.', 'NVARCHAR(MAX)') SerieGuide,
			ROW_NUMBER() OVER
			(
				ORDER BY ( SELECT NULL )
			) RN
		FROM
		(
			SELECT 
				CAST('<X>'+REPLACE(@SerieGuides, ',', '</X><X>')+'</X>' AS XML) AS String
		) AS A
		CROSS APPLY String.nodes('/X') AS Split(a)
	)
	INSERT INTO @TBGUIDES 
	(	
		GuideNumber, 
		SerieGuide
	)
	SELECT 
		C.GuideNumber,
		C1.SerieGuide
	FROM CTE C
	LEFT JOIN CTE1 C1 
		ON C1.RN = C.RN;

	SELECT
    @TOTALPAGAR = COUNT(1)
	FROM
	(
		SELECT CCTBC.ProductNumber
		FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomerDetail CCTBC WITH(NOLOCK)
		INNER JOIN @TBGUIDES GUIDE
			ON CCTBC.SerieNumber = GUIDE.SerieGuide
			AND CCTBC.ProductNumber = GUIDE.GuideNumber
		INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DO
			ON DO.Guide_Serie = GUIDE.SerieGuide
			AND DO.Guide_Number = GUIDE.GuideNumber
		WHERE DO.IsCollect <> 1

		UNION ALL

		SELECT CCTBC.ProductNumber
		FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomerDetail CCTBC WITH(NOLOCK)
		INNER JOIN @TBGUIDES GUIDE
			ON CCTBC.SerieNumber = GUIDE.SerieGuide
			AND CCTBC.ProductNumber = GUIDE.GuideNumber
		INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DO
			ON DO.Guide_Serie = GUIDE.SerieGuide
			AND DO.Guide_Number = GUIDE.GuideNumber
		WHERE DO.IsCollect IS NULL
	) AS GUIDESTOPAY;
		
	IF (@TOTALPAGAR = 0) ---INTENTO 1 DE PAGO
	BEGIN
		Insert Into DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
		(
			[System]
			,CardNumber 
			,TypeCardNumber
			,Currency
			,OrderNumber
			,CustomerReference
			,ReferenceNumber
			,ECIIndicator
			,Authenticationresult
			,TransactionStain
			,CAVV
			,RowStatus
			,TokenCreated
			,DateCreated
		)
		values 
		(
			@System					
			,'XXXXXXXXXXXXXXXX'	
			,'X'				
			,@Currency			
			,@TEMPOrderNumber	
			,@IdCustomer		
			,0					
			,''					
			,''					
			,''					
			,''					
			,1					
			,@Token				
			,@DateCreated		
		)
		
		SET @IdTransaction = isnull(@@Identity,0)
		
		SELECT @TOTALPAGAR = COUNT(1) FROM @TBGUIDES
		
		INSERT INTO 
		DeliveryBackOffice.dbo.CreditCardTransactionByCustomerDetail
		(
			OrderNumber
			,ProductNumber
			,SerieNumber
		)
		SELECT DISTINCT
		GUIDESTOPAY.TransactionNumber,
		GUIDESTOPAY.GuideNumber,
		GUIDESTOPAY.SerieGuide
		FROM
		(
			SELECT
				CONCAT('HR' , @IdTransaction) AS TransactionNumber,
				GUIDE.GuideNumber,
				GUIDE.SerieGuide
			FROM @TBGUIDES GUIDE
				INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
					ON DO.Guide_Number = GUIDE.GuideNumber
					AND DO.Guide_Serie = GUIDE.SerieGuide
			WHERE DO.IsCollect <> 1

			UNION ALL

			SELECT
				CONCAT('HR' ,  @IdTransaction) AS TransactionNumber,
				GUIDE.GuideNumber,
				GUIDE.SerieGuide
			FROM @TBGUIDES GUIDE
				INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
					ON DO.Guide_Number = GUIDE.GuideNumber
					AND DO.Guide_Serie = GUIDE.SerieGuide
			WHERE DO.IsCollect IS NULL
		) AS GUIDESTOPAY;
		

		UPDATE DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
		SET OrderNumber =  CONCAT('HR' , @IdTransaction)
		WHERE IdTransaction = @IdTransaction

		SELECT CONCAT('HR',@IdTransaction) OrderNumber, @TOTALPAGAR TOTAL; 
	END
	ELSE 
		IF (@TOTALPAGAR > 0) ---REINTENTO DE PAGO
		BEGIN
			DECLARE @TMPOrderNumber VARCHAR(50) = '';

			--validar si el pago es exitoso o sino generar otro No. de orden
			SELECT top 1 @TMPOrderNumber = ISNULL(CCTBC.OrderNumber,'HR0') 
			FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomerDetail CCTBC WITH(NOLOCK)
				INNER JOIN @TBGUIDES GUIDE
					ON  CCTBC.ProductNumber = GUIDE.GuideNumber 
					AND CCTBC.SerieNumber = GUIDE.SerieGuide;

			SELECT @TOTALPAGAR = COUNT(1) 
			FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomer CCTBC WITH(NOLOCK)
			WHERE CCTBC.OrderNumber = @TMPOrderNumber  
			AND (CCTBC.StatusSend <> 1 or CCTBC.StatusSend is null)
	
			select @TMPOrderNumber OrderNumber, @TOTALPAGAR TOTAL;
		END 
END
