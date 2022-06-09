
-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-05-13>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================


CREATE PROCEDURE [dbo].[GetVisitPointByClientPortfolio]
	
	@IdAccount int,
	@Token VARCHAR(200)=''

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX) = null
	DECLARE @jsonResult2 NVARCHAR(MAX) = null
	DECLARE @jsonResult3 NVARCHAR(MAX) = null
	DECLARE @jsonResultErrror NVARCHAR(MAX) = null


	declare @VisitPointId int 

	set @VisitPointId   = (select top 1 vp.IdVisitPointClient FROM [dbo].RegisterUser usr with (nolock)
						   LEFT JOIN [dbo].[RolByUserByAccount] rua with (nolock) ON rua.RuaIdUser = usr.UsrIdUser
						                                               AND rua.RuaRowStatus = 1
						   INNER JOIN [dbo].Account ac with (nolock) ON ac.AccIdAccount = rua.RuaIdAccount
						                                  AND ac.AccRowStatus = 1
							 INNER join VisitPointByUser vp with (nolock) ON vp.RegisterUserID = usr.UsrIdUser
							where ac.AccIdAccount = @IdAccount)




	set @jsonResult2 = (SELECT STUFF(( 
						select  distinct
									',
									{									
                                    "IdVisitPointByClientPortfolio":"' +  CONVERT( varchar, vcp.IdVisitPointByClientPortfolio)  + '",' +
									'"InternalCode":"'+ISNULL(vcp.InternalCode,'')+'",'+
									'"FirstName":"' +  dbo.fnt_String_Escape(convert( NVARCHAR(50),[dbo].[fn_replace_special_characters](isnull(vcp.FirstName,''))),'json')  + '",' +
									'"SecondName":"' +  dbo.fnt_String_Escape( isnull( convert(varchar, [dbo].[fn_replace_special_characters](ISNULL(vcp.SecondName,''))),'json') , '') + '",' +
									'"LastName":"' +   dbo.fnt_String_Escape(isnull( convert(varchar, [dbo].[fn_replace_special_characters](ISNULL(vcp.LastName,''))),'json') , '') + '",' +
									'"SecondLastName":"'  +  dbo.fnt_String_Escape( isnull( convert(varchar, [dbo].[fn_replace_special_characters](ISNULL(vcp.SecondLastName,''))),'json') , '') + '",' +
									'"NirPhone":"' +  dbo.fnt_String_Escape(isnull( convert(varchar, vcp.NirPhone),'json') , '') + '",' +
									'"Phone":"' +  dbo.fnt_String_Escape( isnull( convert(varchar, [dbo].[fn_replace_special_characters](ISNULL(vcp.Phone,''))),'json') , '') + '",' +
									'"Email":"' +  dbo.fnt_String_Escape(isnull( convert(VARCHAR(50), REPLACE(vcp.Email,'"','')),'json') , '') + '",' +
									'"CUI":"' +  dbo.fnt_String_Escape(isnull( convert(varchar, vcp.CUI),'json') , '') + '",' +
									'"Status":"' +   isnull( convert(varchar, vcp.RowStatus) , ' ')  + '",' +
									'"Token":"' + isnull( convert(varchar, vcp.TokenCreated) , ' ') + '",' +
                  '"TaxId":"' + isnull( vcp.TaxId , ' ') + '",' +
                  '"ContactName":"' + dbo.fnt_String_Escape(REPLACE(ISNULL(vcp.ContactName, ' '),'"',''),'json') + '",' +
									'"Billing":[' +
								ISNULL(	STUFF((    SELECT ',{ "IdBilling":"'  +  isnull( convert(varchar, SUB.BlpIdBilling) , ' ')  + '",' +
														'"IdAccount":"' +  dbo.fnt_String_Escape( isnull( convert(varchar, SUB.BlpIdAccount) , ' '),'json') + '",' +
														'"Name":"' +  dbo.fnt_String_Escape(isnull( convert(varchar, [dbo].[fn_replace_special_characters](SUB.BlpName)) , ' '),'json') + '",' +
														'"Address":"' +  dbo.fnt_String_Escape(isnull( convert(varchar, [dbo].[fn_replace_special_characters](SUB.BlpAddress)) ,'json'), ' ') + '",' +
														'"TaxId":"' + isnull( convert(varchar, SUB.BlpTaxId) , ' ') + '",' +
														'"Status":"' + isnull( convert(varchar, SUB.BlpRowStatus) , ' ') + '",' +
														'"Token":"' + isnull( convert(varchar, SUB.BlpTokenCreated) , ' ') + '",' +
														'"IdVisitPointByClientPortfolio":"' +   isnull( convert(varchar, SUB.VisitPointByClientPortfolioId) , ' ')  
														+'"}'
												
													 FROM dbo.BillingProfile SUB with (nolock)
													 WHERE
													 SUB.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio and SUB.BlpRowStatus= 1
													 FOR XML PATH(''), TYPE).value('.', 'varchar(max)'), 1, 1, '' ), 
													 
													  ' '
													  )
									
									
									 + '],' +
									'"cod":[' + 
									isnull(STUFF((    SELECT ',{ "Id":"'  +  isnull( convert(varchar, SUB.IdDeliveryFavCOD) , ' ')  + '",' +
														'"IdAccount":"' + isnull( convert(varchar, SUB.IdAccountFavCOD) , ' ') + '",' +
														'"IdBank":"' + isnull( convert(varchar, SUB.IdBank) , ' ') + '",' +
														'"NameBank":"'  +  isnull(convert(varchar, DB.Name),'') + '",' +
														'"NameAccount":"'  + dbo.fnt_String_Escape( isnull( convert(varchar, [dbo].[fn_replace_special_characters](ISNULL(SUB.NameAccountFavCOD,''))),'json') , ' ') + '",' +
														'"TypeAccount":"'  + dbo.fnt_String_Escape( isnull( convert(varchar, SUB.TypeAccountFavCOD),'json') , ' ') + '",' +
														'"DocID":"' +  dbo.fnt_String_Escape(isnull( convert(varchar, SUB.DocumentIdFavCOD),'json') , ' ') + '",' +
														'"Alias":"' +  dbo.fnt_String_Escape(isnull( convert(varchar, SUB.AliasFavCOD) , ' '),'json') + '",' +
														'"Token":"' + isnull( convert(varchar, SUB.TokenCreated) , ' ') + '",' +
														'"TokenUpdate":"' + isnull( convert(varchar, SUB.TokenUpdate) , ' ') + '",' +
														'"NumberAcc":"' + isnull( convert(varchar, SUB.NumberAccFavCOD) , ' ') + '",' +
														'"Status":"' + isnull( convert(varchar, SUB.StatusFavCOD) , ' ') + '",' +
														'"IdVisitPointByClientPortfolio":"' +   isnull( convert(varchar, SUB.VisitPointByClientPortfolioId) , ' ')  
														+'"}'
													 FROM dbo.DeliveryFavCOD SUB with (nolock), dbo.DeliveryBank DB with (nolock)
													 --join  dbo.DeliveryBank db on db.Id_bank = SUB.IdBank
													 WHERE
													 SUB.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio and SUB.StatusFavCOD= 1 and DB.Id_bank = SUB.IdBank
													 FOR XML PATH(''), TYPE).value('.', 'varchar(max)'), 1, 1, '' ),
													 
													 ' '
													 
													 )
									
									  + '],' +
									'"Addresses":[' + 
									
							ISNULL(		STUFF((    SELECT DISTINCT ',{ "IdAddress":"'  +  isnull( convert(varchar, SUB.UadIdAddress) , ' ')  + '",' +
														'"IdTownship":"' + isnull( convert(varchar, SUB.UadIdTownship) , ' ') + '",' +
														'"IdProvince":"' + isnull( convert(varchar, pr.IdProvince) , ' ') + '",' +
														'"Province":"' + isnull( convert(varchar, pr.ProvinceName) , ' ') + '",' +
														'"Township":"' + isnull( convert(varchar, tw.TownshipName) , ' ') + '",' +
														'"HeaderCode":"' + isnull( convert(varchar, tw.HeaderCode) , ' ') + '",' +
														'"IdAccount":"' + isnull( convert(varchar, SUB.UadIdAccount) , ' ') + '",' +
														'"IdCountry":"' + isnull( convert(varchar, SUB.UadIdCountry) , ' ') + '",' +
														'"FullName":"' +  dbo.fnt_String_Escape(REPLACE([dbo].[fn_replace_special_characters](ISNULL(SUB.UadFullName,'')),'"',''),'json') + '",' +
														'"Address1":"' +  dbo.fnt_String_Escape(REPLACE([dbo].[fn_replace_special_characters](ISNULL(SUB.UadAddress1,'')),'"',''),'json')+ '",' +
														'"Address2":"' +  dbo.fnt_String_Escape(REPLACE([dbo].[fn_replace_special_characters](ISNULL(SUB.UadAddress2,'')),'"',''),'json') + '",' +
														'"NirPhone":"' +  dbo.fnt_String_Escape(REPLACE(ISNULL(SUB.UadNirPhone,''),'"',''),'json')+ '",' +
														'"Phone":"' +  dbo.fnt_String_Escape(REPLACE([dbo].[fn_replace_special_characters](ISNULL(SUB.UadPhone,'')),'"',''),'json') + '",' +
														'"AdditionalInstructions":"' + dbo.fnt_String_Escape(REPLACE([dbo].[fn_replace_special_characters](ISNULL(SUB.UadAdditionalInstructions,'')),'"',''),'json')  + '",' +
														'"Status":"' + isnull( convert(varchar, SUB.UadRowStatus) , ' ') + '",' +
														'"Token":"' + isnull( convert(VARCHAR(100), SUB.UadTokenCreated) , ' ') + '",' +
                            '"IdSettlement":"' + isnull( convert(varchar, SUB.UadIdSettlement) , '') + '",' +
                            '"SettlementDescription":"' + isnull( st.Settlement , '') + '",' +
                            '"IdDeliveryOption":"' + isnull( convert(varchar, SUB.UadIdDeliveryOption) , ' ') + '",' +
							'"DescriptionDeliveryOption":"' + isnull( cdo.Name , ' ') + '",' +
                            '"IsTDA":"' + CASE WHEN dsc.TDA = 1 THEN 'TRUE' ELSE 'FALSE' END+ '",' +
                            '"HasSDD":"' + CASE WHEN dsc.SDD = 1 THEN 'TRUE' ELSE 'FALSE' END+ '",' +
							'"Hub":"' + ISNULL(dsc.Hub,'') + '",' +
														'"IdVisitPointByClientPortfolio":"' +   isnull( convert(varchar, SUB.VisitPointByClientPortfolioId) , ' ')  
														+'"}'
													 FROM UserAddress SUB with (nolock)
													right join Township tw with (nolock) on tw.IdTownship = SUB.UadIdTownship
													right join Province pr with (nolock) on pr.IdProvince = tw.IdProvince
                          LEFT JOIN Settlement st with (nolock) ON st.IdSettlement = SUB.UadIdSettlement AND st.SettlementSatus= 1
                          LEFT JOIN CatDeliveryOptions cdo with (nolock) ON cdo.IdDeliveryOption = SUB.UadIdDeliveryOption
                          LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage dsc with (nolock) ON dsc.IdSettlement = st.IdSettlement AND dsc.RowStatus=1
													 WHERE
													 SUB.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio and SUB.UadRowStatus= 1
													 FOR XML PATH(''), TYPE).value('.', 'varchar(max)'), 1, 1, '' ),
													 
													 ' '
													 
													 )
									
									  
										+']'+ '}' 
									from  VisitPointByClientPortfolio vcp with (nolock)
									left join UserAddress uad with (nolock) on  uad.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
									AND uad.UadRowStatus=1
									left join DeliveryFavCOD dfc with (nolock) on dfc.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
									left join BillingProfile bp with (nolock) on bp.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
									where vcp.RowStatus = 1 and vcp.VisitPointId = @VisitPointId
								


								FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,''
											) )
	
	
					
						If @jsonResult is null and @jsonResult2 is null and @jsonResult3 is null
						begin
							set @jsonResultErrror =(
										SELECT STUFF(( 
										SELECT '{{"IdResult":500,' 
										+ '"Message":" No se encontraron registros"}' 
										FOR XML PATH(''), TYPE
										).value('.', 'varchar(max)'),1,1,''
											  ) 
										)
						end

						
						
							select ('[' + COALESCE(@jsonResultErrror,'') 
						+ CASE WHEN @jsonResult IS NOT NULL and @jsonResult2 Is null and @jsonResult3 Is null THEN CONCAT( @jsonResult ,'')  ELSE '' END 
						+ CASE WHEN @jsonResult IS NOT NULL and (@jsonResult2 IS NOT NULL OR @jsonResult3 IS NOT NULL) THEN CONCAT( @jsonResult ,',')  ELSE '' END 
						+ CASE WHEN @jsonResult2 IS NOT NULL and @jsonResult3 Is null THEN CONCAT( @jsonResult2 ,'')  ELSE '' END
						+ CASE WHEN @jsonResult2 IS NOT NULL and @jsonResult3 IS NOT NULL THEN CONCAT( @jsonResult2 ,',') ELSE '' END 
						+ COALESCE(@jsonResult3,'') +  ']') jsonResult

						--zIF OBJECT_ID('tempdb.dbo.#GuideService', 'U') IS NOT NULL DROP TABLE #GuideService;

						--select ('[' + COALESCE(@jsonResult,'') 
						--+ CASE WHEN @jsonResult IS NOT NULL THEN ',' ELSE '' END 
						--+ CASE WHEN @jsonResult2 IS NOT NULL THEN ',' ELSE ''',' END    
						--+ COALESCE(@jsonResult3,'') + ']') jsonResult




END





