


-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-19>
-- Description:	<Asigna un estado a una guia de trasporte>
-- =============================================


CREATE PROCEDURE [dbo].[GetServiceRecolectPay]
	-- Add the parameters for the stored procedure here
	@InGuides   NVARCHAR(400) = 'FD22221,FD22361,FD22223,FD22359,FD22226'

	
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


				DECLARE @jsonResult1 NVARCHAR(MAX) 



			set @jsonResult1 = (SELECT STUFF(( 
			select
			 ',{"Guide":"' +  Isnull(CONVERT(varchar, CONCAT(GuideSerie,GuideNumber)), 'N/A')+ '",' +
			 '"ShipmentCompleted":"' + isnull(CONVERT(varchar,CASE WHEN ShipmentCompleted = 1 THEN 'SI' ELSE 'NO' END), 'N/A')  +  '",' +
			 '"RecollectionCompleted":"' + isnull(CONVERT(varchar,CASE WHEN RecollectionCompleted = 1 THEN 'SI' ELSE 'NO' END), 'N/A')  +  '",' +
			 '"IdHeaderRecolection":"' + isnull(CONVERT(varchar, IdHeaderRecolection), 'N/A')  +  '",' +
			 '"PaidGuide":"' + isnull(CONVERT(varchar,CASE WHEN PaidGuide = 1 THEN 'SI' ELSE 'NO' END), 'N/A')  + --'",' +
							+ '"}'
			from DeliveryOrderPaymentDetail 
			where  GuideNumber IN (select ItemNumber from #listGuides) 	


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



