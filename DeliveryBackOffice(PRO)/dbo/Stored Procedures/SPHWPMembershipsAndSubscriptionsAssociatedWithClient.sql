-- =============================================
-- Author:		<Author,Edelman vasquez>
-- Create date: <Create Date,2022-07-20>
-- Description:	<Description, lista de membresias y suscripciones asociadas al cliente>
-- =============================================
/*
	Actualización: Ordenar atributos de acuerdo a campo AttributePosition
	Autor: Jerson Ochoa - 30-12-2022
*/
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
					'"IdPayment": "' + CAST(ISNULL(M.CustomerPaymentid,0) AS VARCHAR), +'"'+  ',' +
					'"IdMembership":     "' + CAST(M.IdMembership AS VARCHAR),  +'"'+  ',' +
					'"Name": "' + CM.MembershipName, +'"'+  ',' +
					'"DateCreated": "' + CONVERT(NVARCHAR, ISNULL(M.LastPaymentDate, M.DateCreated), 103) +'"'+  ',' +
					'"ExpirationDate": "' + CONVERT(NVARCHAR, M.ExpirationDate, 103) +'"'+  ',' +
					'"Attibutos": [' + 
					(
						SELECT STUFF(
										(
											SELECT ',{' + '"Id":"' + CAST(CMA.IdCatMembershipAttribute AS VARCHAR) +'"'+  ',' +
														'"Descripcion":"' + CMA.MembershipAttributeDescription+'"'+ ',' +
														'"Posicion":"' +CAST(CMA.MembershipAttributePosition AS VARCHAR)+'"'+'}'
											FROM [dbo].[Membership] Maux WITH(NOLOCK)
											INNER JOIN [dbo].[CatMembershipAttribute] CMA WITH (NOLOCK)
											ON Maux.CatMembershipId = CMA.CatMembershipId
											WHERE Maux.IdMembership = M.IdMembership
											ORDER BY [CMA].[MembershipAttributePosition]
											FOR XML PATH(''), TYPE
										).value('.', 'varchar(max)'),
										1,
										1,
										''
									)
					) + ']}'                 
				FROM  [dbo].[Membership] M
				INNER JOIN [dbo].[CatMembership] CM WITH (NOLOCK)
					 ON M.CatMembershipId = CM.IdCatMembership
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
										'"IdSubscription":   "' + CAST(S.IdSubscription AS VARCHAR), +'"'+  ',' +
										'"Name": "' + CS.SubscriptionName, +'"'+  ',' +
										'"DateCreated": "' + CONVERT(NVARCHAR, ISNULL(S.LastPaymentDate, S.DateCreated), 103) +'"'+  ',' +
										'"ExpirationDate": "' + CONVERT(NVARCHAR, S.ExpirationDate, 103) +'"'+  ',' +
										'"Attibutos": ['+
										(
											SELECT STUFF(
															(
																SELECT ',{' + '"Id":"' + CAST(CSA.IdCatSubscriptionAttribute AS VARCHAR) +'"'+  ',' +
																			'"Descripcion":"' + CSA.SubscriptionAttributeDescription+'"'+ ',' +
																			'"Posicion":"' +CAST(CSA.SubscriptionAttributePosition AS VARCHAR)+'"'+'}'
																FROM [dbo].[Subscription] Saux WITH(NOLOCK)
																INNER JOIN [dbo].[CatSubscriptionAtribute] CSA WITH (NOLOCK)
																ON Saux.CatSubscriptionId = CSA.CatSubscriptionId
																WHERE Saux.IdSubscription = S.IdSubscription
																ORDER BY [CSA].[SubscriptionAttributePosition]
																FOR XML PATH(''), TYPE
															).value('.', 'varchar(max)'),
															1,
															1,
															''
														)
										) + ']' +
													'}]}'
													
						  
			
					FROM  [dbo].[Subscription]    S                 WITH (NOLOCK)
					INNER JOIN 
						 [dbo].[CatSubscription] CS                 WITH (NOLOCK)
					ON    S.CatSubscriptionId = CS.IdCatSubscription
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