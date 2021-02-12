USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[GetServiceRecolectUpdateStatus]    Script Date: 07/02/2021 18:59:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-02-06>
-- Description:	<Recotizacion>
-- =============================================


ALTER PROCEDURE [dbo].[GetServiceRecolectUpdateStatus]
	-- Add the parameters for the stored procedure here
	@InGuides   NVARCHAR(400) = 'FD22221,FD22361,FD22223,FD22359,FD22226',

	@Iscollected bit = true,
	@status int = 15,
	@ShipmentCompleted bit = false
	
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

			select SUBSTRING(Item, 1,2) ItemSerie,SUBSTRING(Item,3,len(Item)) ItemNumber 
				into #listGuides
				from DenariusDesktop_Dev.dbo.SplitUnlimited(@InGuides,',')

		

			update DeliveryOrder set  IsCollect = @Iscollected, StatusOrderId = @status 
			from #listGuides ls
			inner join dbo.DeliveryOrder od on od.Guide_Serie =  ls.ItemSerie and od.Guide_Number = ls.ItemNumber

			update DeliveryOrderPaymentDetail set ShipmentCompleted = @ShipmentCompleted
			from #listGuides ls
			inner join dbo.DeliveryOrderPaymentDetail od on od.GuideSerie =  ls.ItemSerie and od.GuideNumber = ls.ItemNumber

				
			DECLARE @jsonResult1 NVARCHAR(MAX) 



			set @jsonResult1 = (SELECT STUFF(( 
			select
			 ',{"Guide":"' +  Isnull(CONCAT(Guide_Serie, Guide_Number), 'N/A')+ '",' +
			 '"Status":"' + isnull(convert( varchar, StatusOrderId), 'N/A')  +  '",' +
			 '"ShipmentCompleted":"' + isnull(CONVERT(varchar, ShipmentCompleted ), 'N/A') + --'",' +
							+ '"}'
			from DeliveryOrder ord
			inner join DeliveryOrderPaymentDetail dopd on (dopd.GuideNumber = ord.Guide_Number and dopd.GuideSerie  = ord.Guide_Serie)
			where ord.Guide_Number IN (select ItemNumber from #listGuides) 	
	
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

		-- retornar resultado en formato json

				select ('[{' + @jsonResult +  ']') jsonResult

END



GO


