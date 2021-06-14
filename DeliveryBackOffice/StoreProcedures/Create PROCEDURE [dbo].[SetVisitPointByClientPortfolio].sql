USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SetFinishReturn]    Script Date: 11/06/2021 10:24:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-06-11>
-- Description:	<Guarda, modifica y elimina la cartera del cliente>
-- ==============================================

Create PROCEDURE [dbo].[SetVisitPointByClientPortfolio]
	-- Add the parameters for the stored procedure here
	@TblAddressesList AS [TblAddressList] READONLY,
	@TblCODList AS [TblCODList] READONLY,
	@TblBillingList AS [TblBillingList] READONLY,

	@IdVisitPointByClientPortfolio int = 2,
	@FirstName nvarchar(50) = '',
	@SecondName nvarchar(50) = '',
	@LastName nvarchar(50) = '',
	@SecondLastName nvarchar(50) = '',
	@NirPhone nvarchar(10) = '',
	@Phone nvarchar(20) = '',
	@Email nvarchar(200) = '',
	@CUI nvarchar(100) = '',
	@IdAccount int = 1,
	@Status int  = 1,
	@Token varchar(200) = null

	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX)
	DECLARE @jsonResult1 NVARCHAR(MAX) 
	DECLARE @jsonResult2 NVARCHAR(MAX) 
	DECLARE @jsonError NVARCHAR(MAX) 
	DECLARE @jsonToken NVARCHAR(MAX)

		-- insertar en tabla temporal posbibles mensajes de respuesta
			--IF OBJECT_ID('tempdb.dbo.#UpdateNow', 'U') IS NOT NULL DROP TABLE #UpdateNow;
			IF OBJECT_ID('tempdb.dbo.#NowInsert', 'U') IS NOT NULL DROP TABLE #NowInsert;
		IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL DROP TABLE #responsemessage;
		
		 IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL DROP TABLE #Temp;
			select * INTO #responsemessage from (SELECT  200 AS IdResult
					,'Estado  cambiado correctamente' AS Message
					,'OK' as Id 
			union
			SELECT  500 AS IdResult
					,'Error faltal intente de nuevo mas tarde' AS Message
					,'Transac' as Id 
		 )  as errror

				 	BEGIN TRANSACTION
					BEGIN TRY
		
		--				--IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL DROP TABLE #Temp;

		-----------------------Cliente nuevo -----------------------------------------------
		if( @IdVisitPointByClientPortfolio = 0 )
		begin
		
						declare @VisitPointId int = (select IdVisitPointClient from VisitPointByUser where RegisterUserID = @IdAccount)
		--------------------------------------------- Registra en la tabla DeliveryOrderDetail la recoleccion de la guia  ---------------------------------
			print 'Registra en la tabla DeliveryOrderDetail la entrega de la guia'
						insert into VisitPointByClientPortfolio(
						
						     [FirstName]
						    ,[SecondName]
						    ,[LastName]
						    ,[SecondLastName]
						    ,[Email]
						    ,[NirPhone]
						    ,[Phone]
							,[CUI]
							,[VisitPointId]
						    ,[RowStatus]
						    ,[TokenCreated]
						    ,[DateCreated]
							,[TokenUpdated]
						    ,[DateUpdated]
						)
						values(@FirstName, @SecondName, @LastName, @SecondLastName, @Email,@NirPhone
						, @Phone, @CUI, @VisitPointId,@Status, @Token, GETDATE(),null, null)
						
					declare @VisitPointByClientPortfolioIdTransact int  = SCOPE_IDENTITY()


						insert into UserAddress(
							[UadIdTownship]
						    ,[UadIdAccount]
						    ,[UadIdCountry]
						    ,[UadFullName]
						    ,[UadAddress1]
						    ,[UadAddress2]
						    ,[UadNirPhone]
							,[UadPhone]
							,[UadAdditionalInstructions]
						    ,[UadRowStatus]
						    ,[UadTokenCreated]
						    ,[UadDateCreated]
							,[UadTokenUpdated]
						    ,[UadDateUpdated]
							,[CodeOfReference]
						    ,[IdCityPlace]
							,[VisitPointByClientPortfolioId]
						)
						select ni.IdTownship
						,ni.IdAccount
						,ni.IdCountry
						,ni.FullName
						,ni.Address1
						,ni.Address2
						,ni.NirPhone
						,ni.Phone
						,ni.AdditionalInstructions
						,ni.Status
						,ni.Token
						,GETDATE()
						,null
						,null
						,null
						,null
						,@VisitPointByClientPortfolioIdTransact
							from @TblAddressesList ni


							insert into BillingProfile(
							[BlpIdAccount]
						    ,[BlpName]
						    ,[BlpAddress]
						    ,[BlpTaxId]
						    ,[BlpRowStatus]
						    ,[BlpTokenCreated]
						    ,[BlpDateCreated]
							,[BlpTokenUpdated]
						    ,[BlpDateUpdated]
							,[VisitPointByClientPortfolioId]
						)
						select bi.IdAccount
						,bi.Name
						,bi.Address
						,bi.TaxId
						,bi.Status
						,bi.Token
						,GETDATE()
						,null
						,null
						,@VisitPointByClientPortfolioIdTransact
							from @TblBillingList bi


							insert into DeliveryFavCOD(
							[AliasFavCOD]
						    ,[NameAccountFavCOD]
						    ,[TypeAccountFavCOD]
						    ,[DocumentIdFavCOD]
						    ,[StatusFavCOD]
						    ,[IdAccountFavCOD]
						    ,[TokenCreated]
						    ,[DateCreated]
							,[TokenUpdate]
							,[DateUpdate]
						    ,[IdBank]
						    ,[NumberAccFavCOD]
							,[VisitPointByClientPortfolioId]
						)
						select ni.Alias
						,ni.NameAccount
						,ni.TypeAccount
						,ni.DocID
						,ni.Status
						,ni.IdAccount
						,ni.Token
						,GETDATE()
						,null
						,null
						,ni.IdBank
						,ni.NumberAcc
						,@VisitPointByClientPortfolioIdTransact
							from @TblCODList ni
		
		end

		----------------------------------END Cliente Nuevo---------------------------------------------


----------------------------------------------------Start Client New COD,Billing,Addres----------------------------
if( @IdVisitPointByClientPortfolio > 0 )
		begin
		
						--declare @VisitPointId int = (select IdVisitPointClient from VisitPointByUser where IdVisitPointByUser = @IdAccount)

						update VisitPointByClientPortfolio set FirstName = @FirstName, SecondName = @FirstName, LastName = @LastName, SecondLastName = @SecondLastName,
						Email = @Email, NirPhone = @NirPhone, Phone = @Phone, CUI = @CUI, VisitPointId = @VisitPointId, TokenUpdated = @Token , DateUpdated = GETDATE(),
						RowStatus = @Status
						where IdVisitPointByClientPortfolio = @IdVisitPointByClientPortfolio
						
						
						
						
						insert into UserAddress(
							[UadIdTownship]
						    ,[UadIdAccount]
						    ,[UadIdCountry]
						    ,[UadFullName]
						    ,[UadAddress1]
						    ,[UadAddress2]
						    ,[UadNirPhone]
							,[UadPhone]
							,[UadAdditionalInstructions]
						    ,[UadRowStatus]
						    ,[UadTokenCreated]
						    ,[UadDateCreated]
							,[UadTokenUpdated]
						    ,[UadDateUpdated]
							,[CodeOfReference]
						    ,[IdCityPlace]
							,[VisitPointByClientPortfolioId]
						)
						select 
						ni.IdTownship
						,ni.IdAccount
						,ni.IdCountry
						,ni.FullName
						,ni.Address1
						,ni.Address2
						,ni.NirPhone
						,ni.Phone
						,ni.AdditionalInstructions
						,ni.Status
						,ni.Token
						,GETDATE()
						,null
						,null
						,null
						,null
						,ni.IdVisitPointByClientPortfolio
							from @TblAddressesList ni
							where ni.IdAddress = 0 and ni.Status > 0

							update UserAddress set UadIdTownship = ni.IdTownship, UadIdAccount = ni.IdAccount , UadIdCountry = ni.IdCountry, UadFullName = ni.FullName, UadAddress1 = ni.Address1,
							UadAddress2 = ni.Address2, UadNirPhone = ni.NirPhone, UadPhone = ni.Phone,UadAdditionalInstructions = ni.AdditionalInstructions, UadRowStatus = ni.Status, UadTokenUpdated = ni.Token,
							UadDateUpdated = GETDATE(), VisitPointByClientPortfolioId = ni.IdVisitPointByClientPortfolio
							from @TblAddressesList ni
							where ni.IdAddress > 0 and VisitPointByClientPortfolioId = ni.IdVisitPointByClientPortfolio




							insert into BillingProfile(
							[BlpIdAccount]
						    ,[BlpName]
						    ,[BlpAddress]
						    ,[BlpTaxId]
						    ,[BlpRowStatus]
						    ,[BlpTokenCreated]
						    ,[BlpDateCreated]
							,[BlpTokenUpdated]
						    ,[BlpDateUpdated]
							,[VisitPointByClientPortfolioId]
						)
						select bi.IdAccount
						,bi.Name
						,bi.Address
						,bi.TaxId
						,bi.Status
						,bi.Token
						,GETDATE()
						,null
						,null
						,bi.IdVisitPointByClientPortfolio
							from @TblBillingList bi
							where bi.IdBilling = 0 and bi.Status > 0


								update BillingProfile set BlpIdAccount = ni.IdAccount, BlpName = ni.Name , BlpAddress = ni.Address, BlpTaxId = ni.TaxId, 
								BlpRowStatus = ni.Status, BlpTokenUpdated = ni.Token,
							BlpDateUpdated = GETDATE(), VisitPointByClientPortfolioId = ni.IdVisitPointByClientPortfolio
							from @TblBillingList ni
							where ni.IdBilling > 0 and VisitPointByClientPortfolioId = ni.IdVisitPointByClientPortfolio



							insert into DeliveryFavCOD(
							[AliasFavCOD]
						    ,[NameAccountFavCOD]
						    ,[TypeAccountFavCOD]
						    ,[DocumentIdFavCOD]
						    ,[StatusFavCOD]
						    ,[IdAccountFavCOD]
						    ,[TokenCreated]
						    ,[DateCreated]
							,[TokenUpdate]
							,[DateUpdate]
						    ,[IdBank]
						    ,[NumberAccFavCOD]
							,[VisitPointByClientPortfolioId]
						)
						select ni.Alias
						,ni.NameAccount
						,ni.TypeAccount
						,ni.DocID
						,ni.Status
						,ni.IdAccount
						,ni.Token
						,GETDATE()
						,null
						,null
						,ni.IdBank
						,ni.NumberAcc
						,ni.IdVisitPointByClientPortfolio
							from @TblCODList ni
							where ni.Id = 0 and ni.Status > 0


								update DeliveryFavCOD set AliasFavCOD = ni.Alias, NameAccountFavCOD = ni.NameAccount , TypeAccountFavCOD = ni.TypeAccount, DocumentIdFavCOD = ni.DocID, 
								StatusFavCOD = ni.Status, IdAccountFavCOD = ni.IdAccount , TokenUpdate = ni.Token,
								 DateUpdate= GETDATE(), IdBank = ni.IdBank, NumberAccFavCOD = ni.NumberAcc ,
								 VisitPointByClientPortfolioId = ni.IdVisitPointByClientPortfolio
							from @TblCODList ni
							where ni.Id > 0 and VisitPointByClientPortfolioId = ni.IdVisitPointByClientPortfolio
		
		end
			
		-- retornar resultado en formato json
		
					END TRY
					BEGIN CATCH
						ROLLBACK TRANSACTION
							select ERROR_MESSAGE()
								-- retornar mensaje de error
							set @jsonResult =(
								SELECT STUFF(( 
								SELECT '"IdResult":' +  convert(varchar,IdResult)    +',' 
								+ '"Message":"' + convert( nvarchar(max),ERROR_MESSAGE()) + '"}' from #responsemessage where Id ='Invalid'
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,''
									  ) 
							)
					END CATCH;
					IF @@TRANCOUNT > 0 BEGIN
						COMMIT TRANSACTION;
						
					

						set @jsonResult = (SELECT STUFF(( 
							SELECT  
						',"Messege":"Cambios realizados exitosamente"}'

						FOR XML PATH(''), TYPE
										).value('.', 'varchar(max)'),1,1,''
												) )
				
				
				--- succesfull
					END
				
		 			select ('[{' + @jsonResult +  ']') jsonResult

					
		 -----------------------------------------------
		
		--------------------
	
--		DROP TABLE #Temp

		-- destruir tablas temporales

		IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
		IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL DROP TABLE #responsemessage;
		IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL DROP TABLE #Temp;

		-- retornar resultado en formato json

				

END

