/*
-- =============================================
-- Author:		<Jorge,Murillo>
-- Create date: <2021-02-10>
-- Description:	<Override a group guides>
-- =============================================
*/
-- Author:		<Edelman Vásquez>
-- Update date: <07/06/2022>
-- Description:	<Control de Anulación de guías y cupones>
-- =============================================

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
	DECLARE @STATUSGUIDE VARCHAR(50);
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
			
			--Variabes Membresías y suscripciones
			DECLARE @MembershipId INT
			DECLARE @SubscriptionId INT
			DECLARE @MembershipSubscriptionLogId BIGINT
			-------------------------------------

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
						INNER JOIN @TBGUIDES T
						ON T.GuideNumber = D.ProductNumber AND RTRIM(LTRIM(D.SerieNumber)) = RTRIM(LTRIM(T.SerieGuide))
						WHERE T.ITERATOR = @IDENTYGUIDES

				   --SELECT @ESTADO						
					IF (@ESTADO = 0)
						BEGIN--SI ES PARTE DE UN LOTTE DE PAGADO CON TARJETA
							SELECT @ESTADO = CASE WHEN COUNT(1)  > 0 THEN 3 ELSE 0 END FROM DeliveryBackOffice.dbo.DeliveryOrder O
							INNER JOIN @TBGUIDES T
							ON T.GuideNumber = O.Guide_Number AND RTRIM(LTRIM(O.Guide_Serie)) = RTRIM(LTRIM(T.SerieGuide)) AND O.StatusOrderId  = 15 OR O.StatusOrderId  = 1
							WHERE T.ITERATOR = @IDENTYGUIDES
				
						END
				END
				IF (@ESTADO = 3)
				BEGIN
				------Validación para saber si una guía tiene cupón redimido y no permita anulación
				    --PENDIENTE DE PAGO
					

	           SET @STATUSGUIDE =(
							SELECT 
								  CASE
									WHEN  PC.RedeemedDate IS NOT NULL AND PC.RowStatus = 1  AND
										  PC.GuideNumberDestination <>  CAST(@NumberGuides AS INT)		THEN  'CANJEADO'
									WHEN  PC.RedeemedDate IS NULL AND  
										  PC.GuideNumberOrigin = CAST(@NumberGuides AS INT)  AND 
										  PC.RowStatus = 1  																							THEN  'Guía Origen'
									WHEN  PC.RowStatus = 0												THEN  'ANULADO'
	           
									WHEN  PC.GuideNumberDestination IS NOT NULL AND PC.RowStatus = 1 
										  AND   PC.GuideNumberDestination = CAST(@NumberGuides AS INT)  THEN  'Guía Destino'
										 ELSE  SO.OrderDescription
								 END ESTATUSGUIDE 
							FROM 
									 [DeliveryBackOffice].[dbo].PromoCoupon PC WITH (NOLOCK)
								INNER JOIN
									 [DeliveryBackOffice].[dbo].CatPromo CP	   WITH (NOLOCK)
								ON   PC.CatPromoId = CP.IdPromo
								RIGHT JOIN [DeliveryBackOffice].[dbo].DeliveryOrder DO WITH (NOLOCK) 
								ON  PC.GuideSerieOrigin = DO.Guide_Serie AND PC.GuideNumberOrigin = DO.Guide_Number 
								 INNER JOIN 
									 [DeliveryBackOffice].[dbo].StatusOrder SO WITH (NOLOCK)
								ON   DO.StatusOrderId = SO.StatusOrderId
							WHERE	
									DO.Guide_Number = CAST(@NumberGuides AS INT)   AND
									DO.Guide_Serie  = @SerieGuides 
					     )
				
			------------------------------------------------------------
			    IF (@STATUSGUIDE = 'CANJEADO')
					BEGIN
					---No se pueden anular guías que tengan cumpones redimidos----
					   SET @TOTAL = @TOTAL + 0;
					END
                    ELSE IF (@STATUSGUIDE = 'Guía Origen')
					BEGIN
					------- Anular cupon y guía de Origen -----------------
							UPDATE DeliveryBackOffice.dbo.DeliveryOrder
								SET StatusOrderId  = 7
							where Guide_Serie = (select T.SerieGuide from @TBGUIDES T where T.ITERATOR = @IDENTYGUIDES)  and Guide_Number = (select T.GuideNumber from @TBGUIDES T where T.ITERATOR = @IDENTYGUIDES) 


							UPDATE
							[DeliveryBackOffice].[dbo].[PromoCoupon]
								SET
									SystemDestination = NULL
									,CustomerDestination = NULL
									,VisitPointClientDestination = NULL
									,VisitPointClientPortfolioDestination = NULL
									,GuideSerieDestination = NULL
									,GuideNumberDestination = NULL
									,ServiceManagementDestination = NULL
									,RedeemedDate = NULL
									,OriginalAmount = NULL
									,DiscountAmount = NULL
									,FinalAmount = NULL
									,DateUpdated = GETDATE()
									,TokenUpdated = @Token
								WHERE    GuideSerieDestination  =  @SerieGuides
							         AND GuideNumberDestination =  CAST(@NumberGuides AS INT) 	

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

							--Membresías y suscripciones
							--Oscar Morales 25/07/2022
							SET @MembershipSubscriptionLogId = NULL

							SELECT
								@MembershipSubscriptionLogId = msl.IdMembershipSubscriptionLog
							   ,@MembershipId = msl.MembershipId
							   ,@SubscriptionId = msl.SubscriptionId
							FROM MembershipSubscriptionLog msl
							INNER JOIN @TBGUIDES tb
								ON tb.SerieGuide = msl.LogGuideSerie
								AND tb.GuideNumber = msl.LogGuideNumber
							WHERE tb.ITERATOR = @IDENTYGUIDES
							AND msl.RowStatus = 1

							IF @MembershipSubscriptionLogId IS NOT NULL
							BEGIN

								UPDATE MembershipSubscriptionLog 
								SET RowStatus = 0
									,TokenUpdated = @Token
									,DateUpdated = GETDATE()
								WHERE IdMembershipSubscriptionLog = @MembershipSubscriptionLogId

								IF @SubscriptionId IS NULL
								BEGIN
					
									UPDATE Membership 
									SET ActualServiceCount = ActualServiceCount - 1
										,TokenUpdated = @Token
										,DateUpdated = GETDATE()
									WHERE IdMembership = @MembershipId
								END
								ELSE
								BEGIN
					
									UPDATE Subscription
									SET ActualServiceCount = ActualServiceCount - 1
										,TokenUpdated = @Token
										,DateUpdated = GETDATE()
									WHERE IdSubscription = @SubscriptionId
								END

							END
							--Termina Membresías y suscripciones

							SET @TOTAL = @TOTAL + 1;
							
					 END
					  ELSE IF (@STATUSGUIDE = 'ANULADO')
					     BEGIN
						 ---- GUÍA YA FUE ANULADA
							SET @TOTAL = @TOTAL + 0;
						 END 
                      ELSE IF (@STATUSGUIDE = 'Guía Destino')
					     BEGIN
						
							 ------- Anular cupon y guía de Destino -----------------
								UPDATE DeliveryBackOffice.dbo.DeliveryOrder
									SET StatusOrderId  = 7
								where Guide_Serie = (select T.SerieGuide from @TBGUIDES T where T.ITERATOR = @IDENTYGUIDES)  and Guide_Number = (select T.GuideNumber from @TBGUIDES T where T.ITERATOR = @IDENTYGUIDES) 


								UPDATE
								[DeliveryBackOffice].[dbo].[PromoCoupon]
									SET
										SystemDestination = NULL
										,CustomerDestination = NULL
										,VisitPointClientDestination = NULL
										,VisitPointClientPortfolioDestination = NULL
										,GuideSerieDestination = NULL
										,GuideNumberDestination = NULL
										,ServiceManagementDestination = NULL
										,RedeemedDate = NULL
										,OriginalAmount = NULL
										,DiscountAmount = NULL
										,FinalAmount = NULL
										,DateUpdated = GETDATE()
										,TokenUpdated = @Token
									WHERE    GuideSerieDestination  = @SerieGuides 
										 AND GuideNumberDestination =  CAST(@NumberGuides AS INT)

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

								--Membresías y suscripciones
								--Oscar Morales 25/07/2022
								SET @MembershipSubscriptionLogId = NULL

								SELECT
									@MembershipSubscriptionLogId = msl.IdMembershipSubscriptionLog
								   ,@MembershipId = msl.MembershipId
								   ,@SubscriptionId = msl.SubscriptionId
								FROM MembershipSubscriptionLog msl
								INNER JOIN @TBGUIDES tb
									ON tb.SerieGuide = msl.LogGuideSerie
									AND tb.GuideNumber = msl.LogGuideNumber
								WHERE tb.ITERATOR = @IDENTYGUIDES
								AND msl.RowStatus = 1

								IF @MembershipSubscriptionLogId IS NOT NULL
								BEGIN

									UPDATE MembershipSubscriptionLog 
									SET RowStatus = 0
										,TokenUpdated = @Token
										,DateUpdated = GETDATE()
									WHERE IdMembershipSubscriptionLog = @MembershipSubscriptionLogId

									IF @SubscriptionId IS NULL
									BEGIN
					
										UPDATE Membership 
										SET ActualServiceCount = ActualServiceCount - 1
											,TokenUpdated = @Token
											,DateUpdated = GETDATE()
										WHERE IdMembership = @MembershipId
									END
									ELSE
									BEGIN
					
										UPDATE Subscription
										SET ActualServiceCount = ActualServiceCount - 1
											,TokenUpdated = @Token
											,DateUpdated = GETDATE()
										WHERE IdSubscription = @SubscriptionId
									END

								END
								--Termina Membresías y suscripciones

								SET @TOTAL = @TOTAL + 1;
						 END   
						 --------Anular guía con estado Solicitado -----
						  ELSE IF (@STATUSGUIDE = 'Solicitado')
					     BEGIN
						
							
								UPDATE DeliveryBackOffice.dbo.DeliveryOrder
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

								--Membresías y suscripciones
								--Oscar Morales 25/07/2022
								SET @MembershipSubscriptionLogId = NULL

								SELECT
									@MembershipSubscriptionLogId = msl.IdMembershipSubscriptionLog
								   ,@MembershipId = msl.MembershipId
								   ,@SubscriptionId = msl.SubscriptionId
								FROM MembershipSubscriptionLog msl
								INNER JOIN @TBGUIDES tb
									ON tb.SerieGuide = msl.LogGuideSerie
									AND tb.GuideNumber = msl.LogGuideNumber
								WHERE tb.ITERATOR = @IDENTYGUIDES
								AND msl.RowStatus = 1

								IF @MembershipSubscriptionLogId IS NOT NULL
								BEGIN

									UPDATE MembershipSubscriptionLog 
									SET RowStatus = 0
										,TokenUpdated = @Token
										,DateUpdated = GETDATE()
									WHERE IdMembershipSubscriptionLog = @MembershipSubscriptionLogId

									IF @SubscriptionId IS NULL
									BEGIN
					
										UPDATE Membership 
										SET ActualServiceCount = ActualServiceCount - 1
											,TokenUpdated = @Token
											,DateUpdated = GETDATE()
										WHERE IdMembership = @MembershipId
									END
									ELSE
									BEGIN
					
										UPDATE Subscription
										SET ActualServiceCount = ActualServiceCount - 1
											,TokenUpdated = @Token
											,DateUpdated = GETDATE()
										WHERE IdSubscription = @SubscriptionId
									END

								END
								--Termina Membresías y suscripciones

									SET @TOTAL = @TOTAL + 1;
						 END  
						  --------Anular guía con estado Generado -----
						  ELSE IF (@STATUSGUIDE = 'Generado')
					     BEGIN
						
							
								UPDATE DeliveryBackOffice.dbo.DeliveryOrder
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

								--Membresías y suscripciones
								--Oscar Morales 25/07/2022
								SET @MembershipSubscriptionLogId = NULL

								SELECT
									@MembershipSubscriptionLogId = msl.IdMembershipSubscriptionLog
								   ,@MembershipId = msl.MembershipId
								   ,@SubscriptionId = msl.SubscriptionId
								FROM MembershipSubscriptionLog msl
								INNER JOIN @TBGUIDES tb
									ON tb.SerieGuide = msl.LogGuideSerie
									AND tb.GuideNumber = msl.LogGuideNumber
								WHERE tb.ITERATOR = @IDENTYGUIDES
								AND msl.RowStatus = 1

								IF @MembershipSubscriptionLogId IS NOT NULL
								BEGIN

									UPDATE MembershipSubscriptionLog 
									SET RowStatus = 0
										,TokenUpdated = @Token
										,DateUpdated = GETDATE()
									WHERE IdMembershipSubscriptionLog = @MembershipSubscriptionLogId

									IF @SubscriptionId IS NULL
									BEGIN
					
										UPDATE Membership 
										SET ActualServiceCount = ActualServiceCount - 1
											,TokenUpdated = @Token
											,DateUpdated = GETDATE()
										WHERE IdMembership = @MembershipId
									END
									ELSE
									BEGIN
					
										UPDATE Subscription
										SET ActualServiceCount = ActualServiceCount - 1
											,TokenUpdated = @Token
											,DateUpdated = GETDATE()
										WHERE IdSubscription = @SubscriptionId
									END

								END
								--Termina Membresías y suscripciones

									SET @TOTAL = @TOTAL + 1;
						 END 
						ELSE
						BEGIN
						------------ ESTADOS NO CONTEMPLADOS PARA PERMITIR LA ANULACIÓN
							SET @TOTAL = @TOTAL +0;
						END
							
				END 
				--Pieces
					DECLARE @TempGuide NVARCHAR(MAX) = (select T.GuideNumber from @TBGUIDES T where T.ITERATOR = @IDENTYGUIDES);
					DECLARE @TempSerie NVARCHAR(MAX) = (select T.SerieGuide from @TBGUIDES T where T.ITERATOR = @IDENTYGUIDES);
					

					
					UPDATE DeliveryBackOffice.dbo.DeliveryOrderPiece
					SET StatusOrderId=7
					WHERE GuideNumber=@TempGuide AND GuideSerie = @TempSerie
					

          IF EXISTS (SELECT * FROM DeliveryBackOffice.dbo.GuideBatch WITH (NOLOCK) WHERE  GuideNumber=@TempGuide AND RowStatus=1)

          BEGIN

          UPDATE DeliveryBackOffice.dbo.GuideBatch
					SET RowStatus=0, Status=0
					WHERE GuideNumber=@TempGuide and GuideSeries = @TempSerie

          END

				--finish while for pieces
				SET @IDENTYGUIDES = @IDENTYGUIDES + 1;
				SET @COUNTGUIDES = @COUNTGUIDES  - 1;
			END 

			SELECT FormatJson = '{ "TOTAL":'+CONVERT(VARCHAR,@TOTAL)+'}'

END
