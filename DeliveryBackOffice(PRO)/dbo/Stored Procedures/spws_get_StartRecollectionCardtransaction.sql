
CREATE PROCEDURE [dbo].[spws_get_StartRecollectionCardtransaction]
 @System						as int					= 1 
,@Currency						as int					= 320
,@IdCustomer					as int					= 1  	  	
,@Token							as nvarchar(50)    	    = ''
,@NumberGuides 					as varchar(MAX)			= ''/*123-54*/
,@SerieGuides					as varchar(Max)			= ''/*FD-FD*/
,@DateCreated					as datetime				
AS
BEGIN
	DECLARE @IdTransaction BIGINT= 0, @TEMPOrderNumber VARCHAR(38), @TOTALPAGAR INT = 0;
	select @IdTransaction = count(1) from DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
	SELECT @TEMPOrderNumber = 'TMP'+CONVERT(VARCHAR,@IdTransaction)  
	/*VALIDAR QUE NO EXISTA EL PAGO POR DETALLE*/
	DECLARE @TBGUIDES TABLE (ITERATOR int Identity(1,1), GuideNumber INT , SerieGuide VARCHAR(2));
		;WITH CTE
			AS (
			SELECT Split.a.value('.', 'NVARCHAR(MAX)') GuideNumber,
			       ROW_NUMBER() OVER(ORDER BY
			                        (
			                            SELECT NULL
			                        )) RN
			FROM
			(
			    SELECT CAST('<X>'+REPLACE(@NumberGuides, ',', '</X><X>')+'</X>' AS XML) AS String
			) AS A
			CROSS APPLY String.nodes('/X') AS Split(a)),
			CTE1
			AS (
			SELECT Split.a.value('.', 'NVARCHAR(MAX)') SerieGuide,
			       ROW_NUMBER() OVER(ORDER BY
			                        (
			                            SELECT NULL
			                        )) RN
			FROM
			(
			    SELECT CAST('<X>'+REPLACE(@SerieGuides, ',', '</X><X>')+'</X>' AS XML) AS String
			) AS A
			CROSS APPLY String.nodes('/X') AS Split(a))
			INSERT INTO @TBGUIDES (GuideNumber, SerieGuide)
			       SELECT C.GuideNumber,
			              C1.SerieGuide
			       FROM CTE C
			            LEFT JOIN CTE1 C1 ON C1.RN = C.RN;

			SELECT @TOTALPAGAR = COUNT(1) FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomerDetail O
			JOIN @TBGUIDES T
			ON O.ProductNumber = T.GuideNumber AND O.SerieNumber = T.SerieGuide
			join DeliveryBackOffice.dbo.DeliveryOrder D
			on D.Guide_Number = T.GuideNumber and D.Guide_Serie = T.SerieGuide
			where D.IsCollect <> 1 or D.IsCollect is null;
			
			IF (@TOTALPAGAR = 0) ---INTENTO 1 DE PAGO
			BEGIN
				/*GENERANDO NUM DE HORDEN*/
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
				 @System					--[System]					
				 ,'XXXXXXXXXXXXXXXX'		--,CardNumber 
				 ,'X'						--,TypeCardNumber
				 ,@Currency					--,Currency
				 ,@TEMPOrderNumber			--,OrderNumber
				 ,@IdCustomer				--CustomerReference
				 ,0							--,ReferenceNumber
				 ,''						--,ECIIndicator
				 ,''						--,Authenticationresult
				 ,''						--,TransactionStain
				 ,''					    --,CAVV
				 ,1							--,RowStatus
				 ,@Token					   --,TokenCreated
				 ,@DateCreated				--,DateCreated
				)
				
				SET @IdTransaction = isnull(@@Identity,0)
				SELECT @TOTALPAGAR = COUNT(1) FROM @TBGUIDES T
			   /*SE GENERA INSERT MASIVO*/
			   INSERT INTO 
			   DeliveryBackOffice.dbo.CreditCardTransactionByCustomerDetail
			    (
				OrderNumber
				,ProductNumber
				,SerieNumber
				)
				SELECT distinct 'HR'+CONVERT(VARCHAR,@IdTransaction), T.GuideNumber, T.SerieGuide FROM @TBGUIDES T
				join DeliveryBackOffice.dbo.DeliveryOrder D
			on D.Guide_Number = T.GuideNumber and D.Guide_Serie = T.SerieGuide
			where D.IsCollect <> 1 or D.IsCollect is null;
			 

				UPDATE DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
				SET OrderNumber =  'HR'+CONVERT(VARCHAR,@IdTransaction)
				WHERE IdTransaction = @IdTransaction

			     select 'HR'+CONVERT(VARCHAR,@IdTransaction) OrderNumber, @TOTALPAGAR TOTAL; 
			END
			ELSE IF (@TOTALPAGAR > 0) ---REINTENTO DE PAGO
			BEGIN
			DECLARE @TMPOrderNumber VARCHAR(50) = '';
			 --validar si el pago es exitoso o sino generar otro No. de orden
			SELECT top 1 @TMPOrderNumber = ISNULL(O.OrderNumber,'HR0') FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomerDetail O
			JOIN @TBGUIDES T
			ON  O.ProductNumber = T.GuideNumber AND O.SerieNumber = T.SerieGuide;

			SELECT @TOTALPAGAR = COUNT(1) FROM 
			DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
			WHERE OrderNumber = @TMPOrderNumber  And (StatusSend <> 1 or StatusSend is null)
			
			
	

			select @TMPOrderNumber OrderNumber, @TOTALPAGAR TOTAL;
			END 
END
