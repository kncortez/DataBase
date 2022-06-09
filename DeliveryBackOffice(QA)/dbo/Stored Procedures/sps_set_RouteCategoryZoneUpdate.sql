-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-03-23>
-- Description:	<Se actualiza la información del detalle y maestro de las rutas >
-- =============================================

create PROCEDURE [dbo].[sps_set_RouteCategoryZoneUpdate]
	@Route int = 1 ,
	@Token varchar (50)= 'TEST',
	@routes nvarchar(MAX),
	@vehicle  nvarchar(MAX),
	--@NameRoute varchar(50) = 'TEST',
	@description varchar(100) = 'TEST',
	
	@typeroute int = 1

AS
BEGIN


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
						
						if(@vehicle <> ' ')
						begin 
								select SUBSTRING(Item, 1,2) ItemIdVehicle

								 --, 
								--SUBSTRING(Item,CHARINDEX('-',Item),len(Item)) ItemPiece, 
								--CHARINDEX('-',Item) charinde,  
								--len(Item) len
										into #listCategory
										from DenariusDesktop_Dev.dbo.SplitUnlimited(@vehicle,',')


										
									  insert into dbo.VehicleCategoryByRoute
									(  [RouteId]
								      ,[CatVehicleCategoriesId]
								      ,[RowStauts]
								      ,[TokenCreated]
								      ,[DateCreated]
									  ,[TokenUpdated]
									  ,[DateUpdated]
									  )
									  select @Route
									,ct.ItemIdVehicle
									,1
									,@Token
									,GETDATE()
									,null
									,null	
									  from #listCategory ct
						end 

							if(@routes <> ' ')
						begin 


								select  SUBSTRING(Item,1, iif(CHARINDEX('-',Item)=0, (len(item)) , (CHARINDEX('-',Item)- 1))) ItemId ,--SUBSTRING(Item, 1,3) ItemId,
							--	SUBSTRING(Item,4, iif(CHARINDEX('-',Item)=0, (len(item)) , (CHARINDEX('-',Item)- 4))) Itemzone
								SUBSTRING(Item, CHARINDEX('-',Item)+1,len(item)) Itemzone
								 --, 
								--SUBSTRING(Item,CHARINDEX('-',Item),len(Item)) ItemPiece, 
								--CHARINDEX('-',Item) charinde,  
								--len(Item) len
										into #listZone
										from DenariusDesktop_Dev.dbo.SplitUnlimited(@routes,',')




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
										  select @Route
										,lz.ItemId
										,lz.Itemzone
										,1
										,@Token
										,GETDATE()
										,null
										,null
										  from #listZone lz
							end
			
				update  CatRoute set  Description = @description,  IdTypeRoute = @typeroute,  TokenUpdated = @Token, DateUpdated = GETDATE() 
				where IdRoute = @Route



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
		

					
		


END
