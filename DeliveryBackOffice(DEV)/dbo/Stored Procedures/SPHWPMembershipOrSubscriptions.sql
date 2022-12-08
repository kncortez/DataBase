-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <Create Date,12/07/2022>
-- Description:	<Description,muestra las membresias y credenciales disponibles con su respectivo detalle>
-- =============================================
CREATE PROCEDURE [dbo].[SPHWPMembershipOrSubscriptions]
-- Add the parameters for the stored procedure here
  
    @Type  AS NVARCHAR(50),
	@Token AS NVARCHAR(50)
 
     
  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @JsonResponse NVARCHAR(MAX) = '';
    -- Insert statements for procedure here 

	IF (@Type = 'MEMBERSHIP')
	BEGIN
				SET @JsonResponse =  
					( 
				SELECT STUFF((
				SELECT DISTINCT ',{'+ 
							
							 '"Data" : [{'+
										'"Id":   "' + CAST(CM.IdCatMembership AS VARCHAR), +'"'+  ',' +
										'"Name": "' + CM.MembershipName, +'"'+  ',' +
										'"Attibutos": ['+
														 
														 											( 
												SELECT STUFF((
															SELECT ','+ 
					
																	'{'+
								


																		 '"Id":"' + CAST(CMA.IdCatMembershipAttribute AS VARCHAR) +'"'+  ',' +
																		 '"Descripcion":"' + CMA.MembershipAttributeDescription+'"'+ ',' +
																		 '"Valor":"' + CAST(CMA.MembershipAttributeValue AS VARCHAR)+'"'+  ',' +
																		 '"Posicion":"' +CAST(CMA.MembershipAttributePosition AS VARCHAR)+'"'+ 
											
																		'}' 
							  
			
																from  [dbo].[CatMembershipAttribute] CMA     where CatMembershipId= CM.IdCatMembership

																FOR XML PATH(''), TYPE 
													) 
																.value('.', 'varchar(max)'),1,1,'' 
													)
												) +



													']'+  ',' +
									   
										'"Costo":"' + CAST(CM.MembershipCost AS VARCHAR)+'"'+  ',' +
										'"Tiempo de validez":"'+CAST(CM.MembershipValidity AS VARCHAR)+'"'+  
							         '}]' +
						  '}'
			
				FROM 
					 [dbo].[CatMembership] CM                  WITH (NOLOCK)
				INNER JOIN
					 [dbo].[CatMembershipAttribute] CMA 	   WITH (NOLOCK)
				ON CM.IdCatMembership = CMA.CatMembershipId
				
			--	ORDER BY CM.IdCatMembership Desc
				FOR XML PATH(''), TYPE 
				) 
						.value('.', 'varchar(max)'),1,1,'' 
						)
				)

		END 

		IF (@Type = 'Subscription')
		BEGIN
					SET @JsonResponse =  
						( 
					SELECT  STUFF((
					SELECT DISTINCT ',{'+ 
					
								 '"Data" : [{'+
											'"Id":   "' + CAST(CS.IdCatSubscription AS VARCHAR), +'"'+  ',' +
											'"Name": "' + CS.SubscriptionName, +'"'+  ',' +
											'"Attibutos": ['+
															

															 	( 
																	SELECT STUFF((
																	SELECT ','+ 
					
																			 '{'+
																				'"Id":"' + CAST(CSA.IdCatSubscriptionAttribute AS VARCHAR) +'"'+  ',' +
																				 '"Descripcion":"' + CSA.SubscriptionAttributeDescription+'"'+ ',' +
																				 '"Valor":"' + CAST(CSA.SubscriptionAttributeValue AS VARCHAR)+'"'+  ',' +
																				 '"Posicion":"' +CAST(CSA.SubscriptionAttributePosition AS VARCHAR)+'"'+ 
											
																			 '}' 
							  
			
																			from  [dbo].[CatSubscriptionAtribute] CSA    where CatSubscriptionId = CS.IdCatSubscription

																				FOR XML PATH(''), TYPE 
																				) 
																						.value('.', 'varchar(max)'),1,1,'' 
																						)
																)
																+

														']'+  ',' +
									   
											'"Costo":"' + CAST(CS.SubscriptionCost AS VARCHAR)+'"'+  ',' +
											'"Tiempo de validez":"'+CAST(CS.SubscriptionValidity AS VARCHAR)+'"'+  
										 '}]' +
							  '}'
			
					FROM 
						 [dbo].[CatSubscription] CS                 WITH (NOLOCK)
					INNER JOIN
						 [dbo].[CatSubscriptionAtribute] CSA  	    WITH (NOLOCK)
					ON CS.IdCatSubscription = CSA.CatSubscriptionId
					--ORDER BY CS.IdCatSubscription Desc

					FOR XML PATH(''), TYPE 
					) 
							.value('.', 'varchar(max)'),1,1,'' 
							)
					)

			END 


  IF (@JsonResponse  IS NULL OR @JsonResponse='' )
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
        END;

       
		  SELECT  ( '[' + @JsonResponse + ']' )  JsonOutput 
END