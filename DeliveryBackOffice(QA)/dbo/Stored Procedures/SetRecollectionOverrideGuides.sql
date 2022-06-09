/*
-- =============================================
-- Author:		<Jorge,Murillo>
-- Create date: <2021-02-10>
-- Description:	<Override a group guides>
-- =============================================
*/

CREATE PROCEDURE [dbo].[SetRecollectionOverrideGuides]
 @System						as int					= 1 
,@IdCustomer					as int					= 1  	  	
,@Token							as nvarchar(50)    	    = ''
,@NumberGuides 					as varchar(MAX)			= ''
,@SerieGuides					as varchar(Max)			= ''
AS
BEGIN

SET NOCOUNT ON;
	/*VALIDAR QUE NO EXISTA EL PAGO POR DETALLE*/
	DECLARE @COUNTGUIDES INT = 0, @IDENTYGUIDES INT = 1, @TOTAL INT = 0;
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


			SELECT @COUNTGUIDES = COUNT(1) FROM @TBGUIDES
			
			while (@COUNTGUIDES > 0)
			BEGIN 
			    /*ANULAR GUIA INDIVIDUAL*/
				DECLARE @ESTADO INT = 0;
				/*
				select @ESTADO = isnull(O.ShipmentCompleted,0) from DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail O
				JOIN  @TBGUIDES T
				ON T.GuideNumber = O.GuideNumber AND RTRIM(LTRIM(O.GuideSerie)) = RTRIM(LTRIM(T.SerieGuide))
				WHERE T.ITERATOR = @IDENTYGUIDES
				*/
				SELECT @ESTADO = CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END  FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
				WHERE OrderNumber = (SELECT (RTRIM(LTRIM(SerieGuide))+ CONVERT(varchar,T.GuideNumber)) AS OrderNumber FROM @TBGUIDES T WHERE T.ITERATOR = @IDENTYGUIDES)

				
				IF (@ESTADO = 0)
				BEGIN
					--NO PAGADO CON TARJETA INDIVIDUAL
					SELECT @ESTADO = CASE WHEN COUNT(1) > 0 THEN 2 ELSE 0 END FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomerDetail D
						JOIN @TBGUIDES T
						ON T.GuideNumber = D.ProductNumber AND RTRIM(LTRIM(D.SerieNumber)) = RTRIM(LTRIM(T.SerieGuide))
						WHERE T.ITERATOR = @IDENTYGUIDES

				   --SELECT @ESTADO						
					IF (@ESTADO = 0)
					BEGIN--SI ES PARTE DE UN LOTTE DE PAGADO CON TARJETA
						SELECT @ESTADO = CASE WHEN COUNT(1)  > 0 THEN 3 ELSE 0 END FROM DeliveryBackOffice.dbo.DeliveryOrder O
						JOIN @TBGUIDES T
						ON T.GuideNumber = O.Guide_Number AND RTRIM(LTRIM(O.Guide_Serie)) = RTRIM(LTRIM(T.SerieGuide)) AND O.StatusOrderId  = 15 OR O.StatusOrderId  = 1
						WHERE T.ITERATOR = @IDENTYGUIDES
				
					END
				END
				IF (@ESTADO = 3)
				BEGIN
				    --PENDIENTE DE PAGO
					update DeliveryBackOffice.dbo.DeliveryOrder
					SET StatusOrderId  = 7
					where Guide_Serie = (select T.SerieGuide from @TBGUIDES T where T.ITERATOR = @IDENTYGUIDES)  and Guide_Number = (select T.GuideNumber from @TBGUIDES T where T.ITERATOR = @IDENTYGUIDES) 

					insert into DeliveryBackOffice.dbo.DeliveryOrderDetail 
					(Guide_Serie
					,Guide_Number
					,StatusOrderId
					,UserCreated
					,DateCreated
					,DateCreatedInSystem
					)
					SELECT 
					SerieGuide, 
					GuideNumber,
					7,
					@Token,
					GETDATE(),
					GETDATE()
					FROM @TBGUIDES 
					WHERE ITERATOR = @IDENTYGUIDES
					/*
					select @TOTAL = count(1) from DeliveryBackOffice.dbo.DeliveryOrderDetail
					where Guide_Serie = (select T.SerieGuide from @TBGUIDES T where T.ITERATOR = @IDENTYGUIDES) 
					and  Guide_Number = (select T.GuideNumber from @TBGUIDES T where T.ITERATOR = @IDENTYGUIDES)
					and StatusOrderId = 7;*/
					SET @TOTAL = @TOTAL + 1;
				END 
				--While for pieces
					DECLARE @TempGuide NVARCHAR(MAX) = (select T.GuideNumber from @TBGUIDES T where T.ITERATOR = @IDENTYGUIDES);
					DECLARE @TempSerie NVARCHAR(MAX) = (select T.SerieGuide from @TBGUIDES T where T.ITERATOR = @IDENTYGUIDES);
					DECLARE @Pieces BIGINT = (SELECT COUNT(*) FROM DeliveryBackOffice.dbo.DeliveryOrderPiece WHERE GuideNumber=@TempGuide AND GuideSerie = @TempSerie);

					WHILE (@Pieces>0)
					BEGIN
					UPDATE DeliveryBackOffice.dbo.DeliveryOrderPiece
					SET StatusOrderId=7
					WHERE GuideNumber=@TempGuide AND GuideSerie = @TempSerie
					SET @Pieces = @Pieces  - 1;
					END

          IF EXISTS (SELECT * FROM DeliveryBackOffice.dbo.GuideBatch WITH (NOLOCK) WHERE  GuideNumber=@TempGuide AND RowStatus=1)

          BEGIN

          UPDATE DeliveryBackOffice.dbo.GuideBatch
					SET RowStatus=0, Status=0
					WHERE GuideNumber=@TempGuide

          END

				--finish while for pieces
				SET @IDENTYGUIDES = @IDENTYGUIDES + 1;
				SET @COUNTGUIDES = @COUNTGUIDES  - 1;
			END 

			SELECT FormatJson = '{ "TOTAL":'+CONVERT(VARCHAR,@TOTAL)+'}'

END