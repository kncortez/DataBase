USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_get_daily_route]    Script Date: 11/06/2021 13:56:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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

	set @VisitPointId   = (select top 1 vp.IdVisitPointClient FROM [dbo].RegisterUser usr
						   LEFT JOIN [dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = usr.UsrIdUser
						                                               AND rua.RuaRowStatus = 1
						   INNER JOIN [dbo].Account ac ON ac.AccIdAccount = rua.RuaIdAccount
						                                  AND ac.AccRowStatus = 1
							 INNER join VisitPointByUser vp ON vp.RegisterUserID = usr.UsrIdUser
							where ac.AccIdAccount = @IdAccount)




	set @jsonResult2 = (SELECT STUFF(( 
						select  distinct
									',
									{									
                                    "IdIdVisitPointByClientPortfolio":"' +  CONVERT( varchar, vcp.IdVisitPointByClientPortfolio)  + '",' +
									'"FirstName":"' + convert( nvarchar,isnull(vcp.FirstName,''))  + '",' +
									'"SecondName":"' +  isnull( convert(varchar, vcp.SecondName) , '') + '",' +
									'"LastName":"' +  isnull( convert(varchar, vcp.LastName) , '') + '",' +
									'"SecondLastName":"'  +  isnull( convert(varchar, vcp.SecondLastName) , '') + '",' +
									'"NirPhone":"' + isnull( convert(varchar, vcp.NirPhone) , '') + '",' +
									'"Phone":"' +  isnull( convert(varchar, vcp.Phone) , '') + '",' +
									'"Email":"' + isnull( convert(varchar, vcp.Email) , '') + '",' +
									'"CUI":"' + isnull( convert(varchar, vcp.CUI) , '') + '",' +
									'"Status":"' +   isnull( convert(varchar, vcp.RowStatus) , ' ')  + '",' +
									'"Token":"' + isnull( convert(varchar, vcp.TokenCreated) , ' ') + '",' +
									'"Billing":[' +
									STUFF((    SELECT ',{ "IdBilling":"'  +  isnull( convert(varchar, SUB.BlpIdBilling) , ' ')  + '",' +
														'"IdAccount":"' + isnull( convert(varchar, SUB.BlpIdAccount) , ' ') + '",' +
														'"Name":"' + isnull( convert(varchar, SUB.BlpName) , ' ') + '",' +
														'"Address":"' + isnull( convert(varchar, SUB.BlpAddress) , ' ') + '",' +
														'"TaxId":"' + isnull( convert(varchar, SUB.BlpTaxId) , ' ') + '",' +
														'"Status":"' + isnull( convert(varchar, SUB.BlpRowStatus) , ' ') + '",' +
														'"Token":"' + isnull( convert(varchar, SUB.BlpTokenCreated) , ' ') + '",' +
														'"IdVisitPointByClientPortfolio":"' +   isnull( convert(varchar, SUB.VisitPointByClientPortfolioId) , ' ')  
														+'"}'
												
													 FROM dbo.BillingProfile SUB
													 WHERE
													 SUB.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
													 FOR XML PATH('') 
													 ), 1, 1, '' )
									
									
									 + '],' +
									'"cod":[' + 
									STUFF((    SELECT ',{ "Id":"'  +  isnull( convert(varchar, SUB.IdDeliveryFavCOD) , ' ')  + '",' +
														'"IdAccount":"' + isnull( convert(varchar, SUB.IdAccountFavCOD) , ' ') + '",' +
														'"IdBank":"' + isnull( convert(varchar, SUB.IdBank) , ' ') + '",' +
														'"NameAccount":"' + isnull( convert(varchar, SUB.NameAccountFavCOD) , ' ') + '",' +
														'"TypeAccount":"' + isnull( convert(varchar, SUB.TypeAccountFavCOD) , ' ') + '",' +
														'"DocID":"' + isnull( convert(varchar, SUB.DocumentIdFavCOD) , ' ') + '",' +
														'"Alias":"' + isnull( convert(varchar, SUB.AliasFavCOD) , ' ') + '",' +
														'"Token":"' + isnull( convert(varchar, SUB.TokenCreated) , ' ') + '",' +
														'"TokenUpdate":"' + isnull( convert(varchar, SUB.TokenUpdate) , ' ') + '",' +
														'"NumberAcc":"' + isnull( convert(varchar, SUB.NumberAccFavCOD) , ' ') + '",' +
														'"Status":"' + isnull( convert(varchar, SUB.StatusFavCOD) , ' ') + '",' +
														'"IdVisitPointByClientPortfolio":"' +   isnull( convert(varchar, SUB.VisitPointByClientPortfolioId) , ' ')  
														+'"}'
													 FROM dbo.DeliveryFavCOD SUB
													 --join  dbo.DeliveryBank db on db.Id_bank = SUB.IdBank
													 WHERE
													 SUB.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
													 FOR XML PATH('') 
													 ), 1, 1, '' )
									
									  + '],' +
									'"Addresses":[' + 
									
									STUFF((    SELECT ',{ "IdAddress":"'  +  isnull( convert(varchar, SUB.UadIdAddress) , ' ')  + '",' +
														'"IdTownship":"' + isnull( convert(varchar, SUB.UadIdTownship) , ' ') + '",' +
														'"Province":"' + isnull( convert(varchar, pr.ProvinceName) , ' ') + '",' +
														'"Township":"' + isnull( convert(varchar, tw.TownshipName) , ' ') + '",' +
														'"HeaderCode":"' + isnull( convert(varchar, tw.HeaderCode) , ' ') + '",' +
														'"IdAccount":"' + isnull( convert(varchar, SUB.UadIdAccount) , ' ') + '",' +
														'"IdCountry":"' + isnull( convert(varchar, SUB.UadIdCountry) , ' ') + '",' +
														'"FullName":"' + isnull( convert(varchar, SUB.UadFullName) , ' ') + '",' +
														'"Address1":"' + isnull( convert(varchar, SUB.UadAddress1) , ' ') + '",' +
														'"Address2":"' + isnull( convert(varchar, SUB.UadAddress2) , ' ') + '",' +
														'"NirPhone":"' + isnull( convert(varchar, SUB.UadNirPhone) , ' ') + '",' +
														'"Phone":"' + isnull( convert(varchar, SUB.UadPhone) , ' ') + '",' +
														'"AdditionalInstructions":"' + isnull( convert(varchar, SUB.UadAdditionalInstructions) , ' ') + '",' +
														'"Status":"' + isnull( convert(varchar, SUB.UadRowStatus) , ' ') + '",' +
														'"Token":"' + isnull( convert(varchar, SUB.UadTokenCreated) , ' ') + '",' +
														'"IdVisitPointByClientPortfolio":"' +   isnull( convert(varchar, SUB.VisitPointByClientPortfolioId) , ' ')  
														+'"}'
													 FROM UserAddress SUB
													 join Township tw on tw.IdTownship = SUB.UadIdTownship
													 join Province pr on pr.IdProvince = tw.IdProvince
													 WHERE
													 SUB.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
													 FOR XML PATH('') 
													 ), 1, 1, '' )
									
									  
										+']'+ '}' 
									from  VisitPointByClientPortfolio vcp
									inner join UserAddress uad on  uad.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
									inner join DeliveryFavCOD dfc on dfc.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
									inner join BillingProfile bp on bp.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
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

						IF OBJECT_ID('tempdb.dbo.#GuideService', 'U') IS NOT NULL DROP TABLE #GuideService;

						--select ('[' + COALESCE(@jsonResult,'') 
						--+ CASE WHEN @jsonResult IS NOT NULL THEN ',' ELSE '' END 
						--+ CASE WHEN @jsonResult2 IS NOT NULL THEN ',' ELSE ''',' END    
						--+ COALESCE(@jsonResult3,'') + ']') jsonResult




END





