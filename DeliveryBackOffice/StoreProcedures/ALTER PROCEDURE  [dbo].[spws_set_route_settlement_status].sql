USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_set_route_settlement_status]    Script Date: 21/04/2021 11:26:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-03-04>
-- Description:	<Cambia de estado de recolectado a ingreso a instalaciones>
-- =============================================

ALTER PROCEDURE  [dbo].[spws_set_route_settlement_status]
@InGuides   NVARCHAR(400) = 'FD22221,FD22361,FD22223,FD22359,FD22226'
,@Token nvarchar(100) = ''

AS
BEGIN
	DECLARE @RModified INT
	declare @GModif int = 0

	BEGIN TRANSACTION
		BEGIN TRY
				IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
				IF OBJECT_ID('tempdb.dbo.#UpdOrd', 'U') IS NOT NULL DROP TABLE #UpdOrd;
								--select SUBSTRING(Item, 1,2) ItemSerie,SUBSTRING(Item,3,len(Item)) ItemNumber 
								--	into #listGuides
								--	from DenariusDesktop_Dev.dbo.SplitUnlimited(@InGuides,',')

								--declare @InGuides   NVARCHAR(400) = 'FD198907-3,FD198910-1,FD198910-2,FD198941-1'

								select SUBSTRING(Item, 1,2) ItemSerie,
								SUBSTRING(Item,3, iif(CHARINDEX('-',Item)=0, (len(item)) , (CHARINDEX('-',Item)- 3))) ItemNumber,
								SUBSTRING(Item, CHARINDEX('-',Item)+1,len(item)) ItemPiece
								 --, 
								--SUBSTRING(Item,CHARINDEX('-',Item),len(Item)) ItemPiece, 
								--CHARINDEX('-',Item) charinde,  
								--len(Item) len
										into #listGuides
										from DenariusDesktop_Dev.dbo.SplitUnlimited(@InGuides,',')


								declare @stattus int  = (select StatusOrderId from StatusOrder where StatusOrderId= 11)

								--declare @countpiecestattus int = (select count(GuideNumber) from DeliveryOrderPiece where GuideNumber = @InGuides and StatusOrderId = 11)
								--declare @countguide int = (select count(GuideNumber) from DeliveryOrderPiece where GuideNumber = @InGuides )

								--select 
								--Guide,
								--Piece
								--INTO  #UpdOrd from (select dop.GuideNumber,COUNT(dop.GuideNumber) Guide, COUNT(ls.ItemPiece) Piece  from DeliveryOrderPiece dop
								--left join #listGuides ls on (dop.GuideNumber = ls.ItemNumber and dop.NoPiece = ls.ItemPiece )
								--where dop.GuideNumber in (select ItemNumber from #listGuides)
								--group by dop.GuideNumber) as tabla1--, dop.NoPiece


								--update  dbo.DeliveryOrder set StatusOrderId =  @stattus
								--from #tbltemp ls
								--where ls.Guide = ls.Piece
								--DECLARE @piece int = (select count(ItemPiece) from #listGuides)

								--if(@piece > 0)
								--begin
										update  dbo.DeliveryOrderPiece set StatusOrderId =  @stattus
										from dbo.DeliveryOrderPiece ord
										 inner join #listGuides ls on (ord.GuideNumber = ls.ItemNumber and ord.GuideSerie = ls.ItemSerie and ord.NoPiece = ls.ItemPiece)

										 SET @RModified = @@ROWCOUNT

								--end
								--else
								--begin 
								--		update  dbo.DeliveryOrderPiece set StatusOrderId =  @stattus
								--		from dbo.DeliveryOrderPiece ord
								--		 inner join #listGuides ls on (ord.GuideNumber = ls.ItemNumber and ord.GuideSerie = ls.ItemSerie)
								--end
								---variable que cuenta cuantas piezas estan asociadas a las guias.
								declare @val int = (select count (GuideNumber) from DeliveryOrderPiece where GuideNumber in (select ItemNumber from #listGuides))
								---variable que cuenta cuantas piezas ya cambiaron de estado arribo a instalaciones (11).
								declare @valu int = (select count (GuideNumber) from DeliveryOrderPiece where GuideNumber in (select ItemNumber from #listGuides) and StatusOrderId = @stattus)

								--declare @value int = (select count (GuideNumber) from DeliveryOrderPiece where GuideNumber in (select ItemNumber from #listGuides))

											---	 insertar checkpoint de arribo a instalaciones.	
								insert into dbo.DeliveryOrderDetail
								( [Guide_Serie]
								,[Guide_Number]
								  ,[StatusOrderId]
								  ,[UserCreated]
								  ,[DateCreated]
								  ,[DateCreatedInSystem]
								  ,[Observations]
								  ,[Temperature_Celsius]
								  ,[PieceId])
								select ls.ItemSerie
								,ls.ItemNumber
								,@stattus
								,@Token
								,GETDATE()
								,null
								,null
								,null
								,ls.ItemPiece
								from #listGuides ls

								SET @RModified = @@ROWCOUNT
							
							if(@val = @valu)
							begin
								update  dbo.DeliveryOrder set StatusOrderId =  @stattus
								from #listGuides ls
								where Guide_Number = ls.ItemNumber    ---  in (select ItemNumber from #listGuides)
								SET @GModif = @@ROWCOUNT
							end

				END TRY
					BEGIN CATCH

							SELECT 
						0 AS 'StatusCode', 
					--	ERROR_MESSAGE() AS 'Description', 
					--	CONVERT(BIGINT, 0) AS 'NumTransferID',
						@InGuides + convert(nvarchar,@InGuides) AS 'Guide',
						0 AS 'SubStatusCode'
						ROLLBACK TRANSACTION

						 select 'No se guardo el registro' as StatusCode 
							--select ERROR_MESSAGE()
								-- retornar mensaje de error
						
					END CATCH;
					IF @@TRANCOUNT > 0 BEGIN
						COMMIT TRANSACTION;
						IF (@RModified > 0)
							begin
							
							SELECT			  
								1 AS 'StatusCode',
							--	'Registro guardado correctamente' AS 'Description', 
							--	@@TRANCOUNT AS 'NumTransferID',
								@InGuides AS 'Guide',
								--@Amount AS 'Amount',
								0 AS 'SubStatusCode'

							Select @GModif as CONT
								
							end

						ELSE
							SELECT			  
								0 AS 'StatusCode',
							--	'Registro no encontrado' AS 'Description', 
							--	0 AS 'NumTransferID',
								@InGuides AS 'Guide',
								--@Amount AS 'Amount',
								0 AS 'SubStatusCode'

						
			END


END
