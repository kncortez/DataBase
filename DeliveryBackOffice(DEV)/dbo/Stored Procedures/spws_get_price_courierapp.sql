
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-08>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================




CREATE PROCEDURE [dbo].[spws_get_price_courierapp]
	-- Add the parameters for the stored procedure here
	-- Add the parameters for the stored procedure here
	@Token VARCHAR(200),
	@IdPickup   bigint,
	@InGuides  nvarchar(max) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonSummary NVARCHAR(MAX) 
	DECLARE @jsonDetail NVARCHAR(MAX) 

	DECLARE @jsonResult NVARCHAR(MAX) 

	
	DECLARE @jsonResult1 NVARCHAR(MAX) 
	DECLARE @jsonResult2 NVARCHAR(MAX) 
	DECLARE @jsonError NVARCHAR(MAX) 
	DECLARE @jsonToken NVARCHAR(MAX)

	declare @PickupRate decimal(12,2) =  (SELECT top 1 isnull(ct.Value,15) FROM dbo.CatToCharge ct where ct.Name ='PickupRate') -- tarifa de recoleccion 
	
	IF OBJECT_ID('tempdb.dbo.#BrainProcessedGuides', 'U') IS NOT NULL DROP TABLE #BrainProcessedGuides;
	IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL DROP TABLE #Temp;

	declare @TokenAct int  = (select top 1 RowStatus from LogTokenPOD where LogTokenPOD LIKE '%' + @Token + '%' order by DateCreated desc)
	declare @hourtoken int = (select top 1 DATEDIFF(HOUR, DateCreated, GETDATE() ) as horas from LogTokenPOD where LogTokenPOD  LIKE '%' + @Token + '%' order by DateCreated desc)
	

	if ((@TokenAct = 1 and @hourtoken <= 8) )
	begin 
			CREATE TABLE #Temp (
			    Guide      VARCHAR(255),
			    Message       VARCHAR(255),
			)
			
			INSERT INTO #Temp (Guide, Message)
			EXEC  [dbo].[spws_get_validate_guides_pickup]
				@InGuides  = @InGuides,
				@IdPickup = @IdPickup,
				@Token = @Token

			 declare @test int = (select COUNT(*) from #Temp)

			if (@test = 0)
			begin
			
				DECLARE @GuidesOfTransaction AS TABLE (
					GuideSerie NVARCHAR(2),
					GuideNumber INT
				)

				CREATE TABLE #BrainProcessedGuides (
					GuideSerie NVARCHAR(2),
					GuideNumber INT,
					IsCollect BIT,
					Price DECIMAL(18,2),
					COD DECIMAL(18,2),
					AmountPaid DECIMAL(18,2),
					CODPaid DECIMAL(18,2),
					CODIsPaid BIT,
					PaymentTime INT,
					TimeSequence INT,
					FelNumber NVARCHAR(50),
					IsPaid BIT,
					IsCustomer INT,
					ConditionPayment NVARCHAR(200),
					HaveCredit BIT,
					CollectCOD BIT,
					ReturnRate DECIMAL(5,2),
					AmountToPay DECIMAL(18,2),
					CODAmount DECIMAL(18,2),
					ReturnRates DECIMAL(5,2)
				)

				INSERT INTO #BrainProcessedGuides
				EXEC
					[dbo].[spws_get_guide_pending_payment]
					@InGuides	-- Guías recibidas
					,2			-- Tiempo de pago 2 - En recolección
					,0			-- No es retorno
					,''			-- Codeapp
					,1			-- Identificador de modulo donde proviene
					,@Token		-- Token de courier

				set @jsonDetail = (SELECT STUFF(( 
										
										select distinct
											',{"GuideSerie":"' +   isnull(tbl.GuideSerie,'N/A') + '",' +
											'"GuideNumber":"' + Isnull(CONVERT(varchar, tbl.GuideNumber), 'N/A') + '",' + 
											'"Amount":"' +isnull(convert(varchar, tbl.AmountToPay),'0.00') +  '",' +
											'"PickupRate":"' + convert(varchar,'0.00') + 
											+ '"}'
										from #BrainProcessedGuides tbl
										group by tbl.GuideSerie, tbl.GuideNumber, tbl.AmountToPay
										FOR XML PATH(''), TYPE
															).value('.', 'varchar(max)'),1,1,''
																	) )
									
									-- no agrupar para resumen
									
										set @jsonSummary = (SELECT STUFF(( 
										
										select 
											',{"Amount":"' + convert(varchar,isnull(SUM(tbl.AmountToPay),0)) + '",' +
											'"PickupRate":"' + convert(varchar,ISNULL(@PickupRate, 0)) + '",' +
											'"Collect":"' + 'false' + 
											+ '"}'
										from #BrainProcessedGuides tbl
										FOR XML PATH(''), TYPE
															).value('.', 'varchar(max)'),1,1,''
																	) )
									
										------ unir encabezado y detalle para resultado
									
											        SET @jsonResult =
									                    (
									                        SELECT STUFF(
									                    (
									                        SELECT '{"IdResult":200' + ',' + '"Summary":[' + @jsonSummary + '],' + '"Detail":[' + @jsonDetail + ']' + '' FOR XML PATH(''), TYPE
									                    ).value('.', 'varchar(max)'), 1, 1, '')
									                    );
										
									
									
									
										-- retornar resultado en formato json
									If @jsonResult is null 
									begin
									-- it was chanced idResult from 412 to 204 18/02/2022
										set @jsonResult =(
													SELECT STUFF(( 
													SELECT '{"IdResult":204,' 
													+ '"Message":" No se encontraron registros"' 
											
													FOR XML PATH(''), TYPE
													).value('.', 'varchar(max)'),1,1,''
															) 
													)
									end
										--end 18/02/2022
										select ('{' + @jsonResult +  '}') jsonResult


		end

				else if(@test>0)
					begin
							 set @jsonResult1 =(
											SELECT STUFF(( 
											SELECT ',{"Error":"' +  isnull(convert(varchar,Guide), 'N/A' )  +  + '"}' 
											from #Temp where Guide in (select Guide from #Temp)
											FOR XML PATH(''), TYPE
											).value('.', 'varchar(max)'),1,1,''
												  ) 
										)
								
								print @jsonResult1
							
							 set @jsonResult2 =(
											SELECT STUFF(( 
											SELECT ',{"Message":"' + isnull(convert( nvarchar(max),Message), 'N/A') +  + '"}' 
											from #Temp where Guide in (select Guide from #Temp)
											FOR XML PATH(''), TYPE
											).value('.', 'varchar(max)'),1,1,''
												  ) 
										)

								print @jsonResult2
							  SET @jsonError =
							                (
							                    SELECT STUFF(
							                (
							                    SELECT '{"IdResult":412' + ',' + '"Guides":[' + @jsonResult1 + '],' + '"Messege":[' + @jsonResult2 + ']' + '' FOR XML PATH(''), TYPE
							                ).value('.', 'varchar(max)'), 1, 1, '')
							                );
							print @jsonError
							
							select ('{' + @jsonError +  '}') jsonError

					end

		end

	else if(@TokenAct = 0 or @TokenAct is null or @hourtoken > 8)
	begin 
		print 'token inválido'
		SET @jsonToken = (
		SELECT STUFF((
		SELECT  
		',{"IdError":' + '403' + ',' +
		'"DescriptionError":"' + 'Token inválido'  + '"' +	  	  
		'}' 
		FOR XML PATH(''), TYPE
		).value('.', 'varchar(max)'),1,1,''
		) 
		)
		select '['+ @jsonToken + ']' jsonToken
	
		return
	end

END
--select * from dbo.RouteAssigment