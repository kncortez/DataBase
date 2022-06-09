



-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-02-06>
-- Description:	<Recotizacion>
-- =============================================


CREATE PROCEDURE [dbo].[SetCollectGuides]
	-- Add the parameters for the stored procedure here
	@InGuides   NVARCHAR(400) = 'FD22221,FD22361,FD22223,FD22359,FD22226',
	@IdAccount int = 2
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX) 

		-- insertar en tabla temporal posbibles mensajes de respuesta

		IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL DROP TABLE #responsemessage;
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

			IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
			IF OBJECT_ID('tempdb.dbo.#UpdateNow', 'U') IS NOT NULL DROP TABLE #UpdateNow;
			


			select SUBSTRING(Item, 1,2) ItemSerie,SUBSTRING(Item,3,len(Item)) ItemNumber 
				into #listGuides
				from DenariusDesktop_Dev.dbo.SplitUnlimited(@InGuides,',')

				select 
				GuideNumber,
				GuideSerie
				into #UpdateNow 
				From (select dop.GuideNumber, dop.GuideSerie from DeliveryOrderPaymentDetail dop
				left join #listGuides ls on (dop.GuideNumber = ls.ItemNumber and dop.GuideSerie  = ls.ItemSerie)
				 where GuideNumber in (select ItemNumber from #listGuides) 
						and GuideSerie in (select ItemSerie from #listGuides) and  ShipmentCompleted = 'false') as table1


			declare @IdCustomer int = (select IdCustomer from Account where AccIdAccount = @IdAccount)

			declare @Recot decimal (18,2) = (select top 1 rbh.RbhCollectedRate from RatebyCustomer rbc
			inner join RateByHub rbh on (rbc.RbcIdRate = rbh.RbhIdRate)
			where rbc.RbcIdCustomer = @IdCustomer)

			update DeliveryOrder set PriceShippment = isnull(PriceShippment,0) + isnull(@Recot,0), IsCollect = 1
			from #UpdateNow un
			inner join dbo.DeliveryOrder od on od.Guide_Serie =  un.GuideSerie and od.Guide_Number = un.GuideNumber


				
			DECLARE @jsonResult1 NVARCHAR(MAX) 



			set @jsonResult1 = (SELECT STUFF(( 
			select
			 ',{"Guide":"' +  Isnull(CONCAT(Guide_Serie, Guide_Number), 'N/A')+ '",' +
			 '"IsCollect":"' + isnull(convert( varchar, IsCollect), 'N/A')  +  '",' +
			 '"PrecioServicio":"' + CONVERT(varchar,cast( coalesce(PriceShippment ,'0')as money),1)  + --'",' +
							+ '"}'
			from DeliveryOrder 
			where  Guide_Number IN (select ItemNumber from #listGuides)  and   IsCollect = 1	
	
			FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
									) )
									print 'ingresa2'
										print @jsonResult

		-- retornar resultado en formato json
	If @jsonResult1 is null 

	begin

		set @jsonResult1 =(
					SELECT STUFF(( 
					SELECT '{{"IdResult":500,' 
					+ '"Message":" No se encontraron registros"}' 
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
	end

		select ('[' + @jsonResult1 +  ']') jsonResult1


			
			set @jsonResult =(
				SELECT STUFF(( 
				SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
				+ '"Message":"' + Message + '"}' from #responsemessage where Id ='OK'
				FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'),1,1,''
					  ) 
			)

		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			select ERROR_MESSAGE()
				-- retornar mensaje de error
			set @jsonResult =(
				SELECT STUFF(( 
				SELECT '{"IdResult":' +  convert(varchar,IdResult)    +',' 
				+ '"Message":"' + convert( nvarchar(max),ERROR_MESSAGE()) + '"}' from #responsemessage where Id ='Invalid'
				FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'),1,1,''
					  ) 
			)
		END CATCH;
		IF @@TRANCOUNT > 0 BEGIN
			COMMIT TRANSACTION;
			--- succesfull
		END
		
		-- destruir tablas temporales

		IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
		IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL DROP TABLE #responsemessage;
			IF OBJECT_ID('tempdb.dbo.#UpdateNow', 'U') IS NOT NULL DROP TABLE #UpdateNow;
		-- retornar resultado en formato json

				select ('[{' + @jsonResult +  ']') jsonResult

END




