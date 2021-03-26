USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_Categories_Vehicle_Route]    Script Date: 25/03/2021 09:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-03-23>
-- Description:	<Se guarda la información del detalle y maestro de las rutas >
-- =============================================
--drop PROCEDURE [dbo].[sps_Categories_Vehicle_Route]
CREATE PROCEDURE [dbo].[sps_Categories_Vehicle_Route]
	@TblZoneByRoute nvarchar(MAX),
	@TblVehicleCategoryByRoute  nvarchar(MAX),
	@NameRoute varchar(50) = 'TEST',
	@Description varchar(100) = 'TEST',
	@Token varchar (50)= 'TEST',
	@IdTypeRoute int = 1

AS
BEGIN

	declare	@IdRoute int = 1
	declare @ValidateFilter as int = 0	

     set @ValidateFilter = (select top 1 COUNT(CodeRoute) from CatRoute where CodeRoute = @NameRoute and RowStatus = 1)


	if(@ValidateFilter = 0 )
			begin 
				BEGIN TRANSACTION
				BEGIN TRY
			


						IF OBJECT_ID('tempdb.dbo.#listCategory', 'U') IS NOT NULL DROP TABLE #listCategory;
						IF OBJECT_ID('tempdb.dbo.#listZone', 'U') IS NOT NULL DROP TABLE #listZone;
						--IF OBJECT_ID('tempdb.dbo.#UpdOrd', 'U') IS NOT NULL DROP TABLE #UpdOrd;
								--select SUBSTRING(Item, 1,2) ItemSerie,SUBSTRING(Item,3,len(Item)) ItemNumber 
								--	into #listGuides
								--	from DenariusDesktop_Dev.dbo.SplitUnlimited(@InGuides,',')

								--declare @InGuides   NVARCHAR(400) = 'FD198907-3,FD198910-1,FD198910-2,FD198941-1'

								select SUBSTRING(Item, 1,2) ItemIdVehicle

								 --, 
								--SUBSTRING(Item,CHARINDEX('-',Item),len(Item)) ItemPiece, 
								--CHARINDEX('-',Item) charinde,  
								--len(Item) len
										into #listCategory
										from DenariusDesktop_Dev.dbo.SplitUnlimited(@TblVehicleCategoryByRoute,',')



								select  SUBSTRING(Item,1, iif(CHARINDEX('-',Item)=0, (len(item)) , (CHARINDEX('-',Item)- 1))) ItemId ,--SUBSTRING(Item, 1,3) ItemId,
							--	SUBSTRING(Item,4, iif(CHARINDEX('-',Item)=0, (len(item)) , (CHARINDEX('-',Item)- 4))) Itemzone
								SUBSTRING(Item, CHARINDEX('-',Item)+1,len(item)) Itemzone
								 --, 
								--SUBSTRING(Item,CHARINDEX('-',Item),len(Item)) ItemPiece, 
								--CHARINDEX('-',Item) charinde,  
								--len(Item) len
										into #listZone
										from DenariusDesktop_Dev.dbo.SplitUnlimited(@TblZoneByRoute,',')
	
			
				insert into CatRoute (CodeRoute, Description, IdTownship, IdTypeRoute, Zone, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated) 
				values(@NameRoute, @Description, null, @IdTypeRoute, null, 1, @Token, GETDATE(),null, null)
				set @IdRoute = SCOPE_IDENTITY()


				insert into dbo.ZoneByRoute
				(  [RouteId]
			      ,[TownshipId]
			      ,[Zone]
			      ,[RowStauts]
			      ,[TokenCreated]
			      ,[DateCreated]
				  ,[TokenUpdated]
				  ,[DateUpdated]
				  )
				  select @IdRoute
				,lz.ItemId
				,lz.Itemzone
				,1
				,@Token
				,GETDATE()	
				,null
				,null
				  from #listZone lz

				  insert into dbo.VehicleCategoryByRoute
				(  [RouteId]
			      ,[CatVehicleCategoriesId]
			      ,[RowStauts]
			      ,[TokenCreated]
			      ,[DateCreated]
				  ,[TokenUpdated]
				  ,[DateUpdated]
				  )
				  select @IdRoute
				,ct.ItemIdVehicle
				,1
				,@Token
				,GETDATE()	
				,null
				,null
				  from #listCategory ct


				  END TRY
				
				BEGIN CATCH
						
						ROLLBACK TRANSACTION
						 select ERROR_MESSAGE()
						 select '401' as StatusCode 

						END CATCH;
						
						IF @@TRANCOUNT > 0
					BEGIN
						COMMIT TRANSACTION;
						select '200' as StatusCode 
					END
	
			end 
		
			else if(@ValidateFilter >= 1 )
			begin 
				  select '406' as StatusCode 
			end 
					
		


END
