-- =============================================
-- Author:		<Author,Edelman vasquez>
-- Create date: <Create Date,2022-07-20>
-- Description:	<Description, lista de membresias y suscripciones asociadas al cliente>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWPMembershipsAndSubscriptionsAssociatedWithClient]
	-- Add the parameters for the stored procedure here
	@IdAcount AS BIGINT,
	@Token AS  NVARCHAR(50),
	@Type  AS NVARCHAR(50) = ''

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		DECLARE @JsonResponse NVARCHAR(MAX) = '';
		DECLARE @Membresia INT = (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[Membership] WHERE AccountId = @IdAcount )​;
			-- Insert statements for procedure here 

		IF (@Membresia = 1 AND @Type ='Membership')
		BEGIN

			SET @JsonResponse =  
					( 
				SELECT STUFF((
				SELECT ',{'+
							            '"IdResult": 200',+  ',' +
										'"Type": "MEMBERSHIP"',+  ',' +
										'"IdCard": "' + CAST(ISNULL(M.CustomerPaymentid,0) AS VARCHAR), +'"'+  ',' +
										'"Id":     "' + CAST(CM.IdCatMembership AS VARCHAR),  +'"'+  ',' +
										'"Name":   "' + CM.MembershipName, +'"'+  ',' +
										'"Attibutos": [{'+
														 '"Id":"' + CAST(CMA.IdCatMembershipAttribute AS VARCHAR) +'"'+  ',' +
														 '"Descripcion":"' + CMA.MembershipAttributeDescription+'"'+ ',' +
														 '"Valor":"' + CAST(CMA.MembershipAttributeValue AS VARCHAR)+'"'+  ',' +
														 '"Posicion":"' +CAST(CMA.MembershipAttributePosition AS VARCHAR)+'"'+  ',' +
										                 '"Costo":"' + CAST(CM.MembershipCost AS VARCHAR)+'"'+  ',' +
														 '"StatusMembershipt":"' + CAST(M.RowStatus AS VARCHAR)+'"'+  ',' +
														 '"ExpirationDate":"' + CAST(FORMAT(M.ExpirationDate,'dd/MM/yyyy') AS VARCHAR)+'"'+  ',' +
														 '"DateCreated":"' + CAST(FORMAT(M.DateCreated,'dd/MM/yyyy') AS VARCHAR)+'"'+  ',' +
														 '"IsAutoRenewable":"' + CAST(M.IsAutoRenewable AS VARCHAR)+'"'+  ',' +
										                 '"Tiempodevalidez":"'+CAST(CM.MembershipValidity AS VARCHAR)+'"'+  
							                           '}]}' 
						
			                          
				FROM  [dbo].[Membership] M
				INNER JOIN 
					 [dbo].[CatMembership] CM                  WITH (NOLOCK)
					 ON M.CatMembershipId = CM.IdCatMembership
				INNER JOIN
					 [dbo].[CatMembershipAttribute] CMA 	   WITH (NOLOCK)
				ON CM.IdCatMembership = CMA.CatMembershipId
				WHERE M.AccountId = @IdAcount
				ORDER BY CM.IdCatMembership Desc
				FOR XML PATH(''), TYPE 
				) 
						.value('.', 'varchar(max)'),1,1,'' 
						)
				)
				SELECT  ( '[' + @JsonResponse + ']' )  JsonOutput 

          END
		  ELSE IF  (@Membresia = 1 AND @Type ='Subscription')
		  BEGIN

				SET @JsonResponse =  
						( 
					SELECT STUFF((
					SELECT ',{'+ 
							
							 
							            '"IdResult": 200',+  ',' +
								            '"Subscription" : [{' +
											'"IdCard": "' + CAST(ISNULL(S.CustomerPaymentId,0) AS VARCHAR),  +'"'+  ',' +
											'"Id":   "' + CAST(CS.IdCatSubscription AS VARCHAR), +'"'+  ',' +
											'"Name": "' + CS.SubscriptionName, +'"'+  ',' +
											'"Attibutos": [{'+
															 '"Id":"' + CAST(CSA.IdCatSubscriptionAttribute AS VARCHAR) +'"'+  ',' +
															 '"Descripcion":"' + CSA.SubscriptionAttributeDescription+'"'+ ',' +
															 '"Valor":"' + CAST(CSA.SubscriptionAttributeValue AS VARCHAR)+'"'+  ',' +
															 '"Posicion":"' +CAST(CSA.SubscriptionAttributePosition AS VARCHAR)+'"'+  ',' +  
													         '"Costo":"' + CAST(CS.SubscriptionCost AS VARCHAR)+'"'+  ',' +
															 '"StatusSubcription":"' + CAST(S.RowStatus AS VARCHAR)+'"'+  ',' +
															 '"ExpirationDate":"' + CONVERT(VARCHAR,S.ExpirationDate, 103 )+'"'+  ',' +
														     '"DateCreated":"' +  CONVERT(VARCHAR,S.DateCreated, 103 )+'"'+  ',' +
															 '"IsAutoRenewable":"' + CAST(S.IsAutoRenewable AS VARCHAR)+'"'+  ',' +
											                 '"Tiempodevalidez":"'+CAST(CS.SubscriptionValidity AS VARCHAR)+'"'  +

														  '}]' +
														'}]}'
													
						  
			
					FROM  [dbo].[Subscription]    S                 WITH (NOLOCK)
					INNER JOIN 
						 [dbo].[CatSubscription] CS                 WITH (NOLOCK)
					ON    S.CatSubscriptionId = CS.IdCatSubscription
					INNER JOIN
						 [dbo].[CatSubscriptionAtribute] CSA  	    WITH (NOLOCK)
					ON CS.IdCatSubscription = CSA.CatSubscriptionId
					WHERE S.AccountId = @IdAcount
					ORDER BY CS.IdCatSubscription Desc

					FOR XML PATH(''), TYPE 
					) 
							.value('.', 'varchar(max)'),1,1,'' 
							)
					)

							
								SELECT  ( '[' + @JsonResponse + ']' )  JsonOutput 
					
		END
		ELSE
		  BEGIN
		   SET @JsonResponse  =
					(
						SELECT STUFF(
										(
											SELECT '{{"IdResult":500,' + '"Message":"No se encontraron registros"}'
											FOR XML PATH(''), TYPE
										).value('.', 'varchar(max)'),
										1,
										1,
										''
									)
					);

              SELECT  ( '[' + @JsonResponse + ']' )  JsonOutput 
			 END;
		

END