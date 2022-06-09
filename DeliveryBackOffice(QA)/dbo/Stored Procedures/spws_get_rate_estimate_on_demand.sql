
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-08-05>
-- Description:	<Devuelve la opcion y precio shipping>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_rate_estimate_on_demand]
	-- Add the parameters for the stored procedure here
		    @CodApp as nvarchar(50) = 'SIFDCECOM300720201459',
			@IdDestiny as bigint  = 1454,
			@FechaCompra as datetime = '2020-08-02 11:43',
			@ProductWeight as decimal(18,2) = 56,
			@Country as nvarchar(2)   = 'GT',
			--fields complementaries optionals 
			@IdSource as bigint = 518, --zona 12 Guatemala
			@ObjectType as nvarchar(50)  = 'ANYTHING',
			@CountPieces as int = 1,
			@AmmountValue as decimal(18,2) = 1,
			@Currency as NVARCHAR(3) = 'GTQ',
			@CodeCredit as nvarchar(10) = '0',
			@IsFragil as bit  = 'FALSE',
			@IdMerchant as int = 6,
			@IdSellerDepot as int  = 0,
			@VPCodeOfReference as int = -1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdSettlement AS BIGINT = -1
	SET @IdSettlement = @IdDestiny;

	
	BEGIN TRY  


		--se identifica el Ecommerce en base al CodeApp enviado 
		select  IdEcommerce,
				EcomerceName,	
				IdCountry,	
				UserKey,	
				Passkey,	
				SecretKey,	
				EcommerceStatus,	
				IdCustomer
		into #Ecommrce
		from DeliveryBackOffice.[dbo].[Ecommerce] eco 
		where eco.UserKey = @CodApp --'SIFDCECOM300720201459'
		and eco.IdCountry = @Country
		and eco.EcommerceStatus = 'TRUE'
	
		declare @IdEcommerce as int = -1
		set @IdEcommerce  = (select top 1 ec.IdEcommerce from #Ecommrce ec where ec.EcommerceStatus = 'TRUE')
		
		print '[@FechaCompra]'
		print	@FechaCompra 
		print '[@ProductWeight]'
		print   @ProductWeight 
		print '[AmmountValue]'
		print   @AmmountValue
		print '[@IdSettlement]'
		print   @IdSettlement
		print '[@IdEcommerce]'
		print	@IdEcommerce
		print  '@IdMerchant'
		print   @IdMerchant
		print  '@IdSellerDepot'
		print   @IdSellerDepot
		print  '@VPCodeOfReference'
		print   @VPCodeOfReference

		--En caso no declaren el valor del origen de forma incial empezaremos con cotizaciones que salen de guatemala
		if (@IdSource = 0)
			set @IdSource = 518 --zona 12 Guatemala 
		
		select vpc.CodeOfReference  IdVPCodeOfReference,
				vpc.IdSettlement,
				vpc.IdKindOfVPClient,
				vpc.DescriptionOfClient,
				vpc.CustomerID
				into #VPClient
		from [dbo].[VisitPointClient] vpc
		where vpc.IdSettlement = @IdSource -- 1454 
		and vpc.CustomerID = @IdMerchant
		and (vpc.CodeOfReference = case when @VPCodeOfReference != -1 then @VPCodeOfReference else vpc.CodeOfReference end)

			select vpc.CodeOfReference  IdVPCodeOfReference,
				vpc.IdSettlement,
				vpc.IdKindOfVPClient,
				vpc.DescriptionOfClient,
				vpc.CustomerID
				into #VPClient2
		from [dbo].[VisitPointClient] vpc
		where vpc.CustomerID = @IdMerchant
		and (vpc.CodeOfReference = case when @VPCodeOfReference != -1 then @VPCodeOfReference else vpc.CodeOfReference end)
		
		declare @IdRedistributor as int = 0
		
		set @IdRedistributor = (select top 1 isnull(vp.IdVPCodeOfReference,0) 
								from #VPClient vp 
								where vp.IdSettlement = @IdSource 
								and vp.CustomerID = @IdMerchant 
								and (vp.IdVPCodeOfReference = case when @VPCodeOfReference != -1 then @VPCodeOfReference else vp.IdVPCodeOfReference end)
								)

		declare @IdKindOfVP as int = 0
		set @IdKindOfVP = (select top 1 isnull(vp.IdKindOfVPClient,0) 
								from #VPClient2 vp 
								where vp.IdVPCodeOfReference = @VPCodeOfReference )


	 	
		print '@IdRedistributor'
		print @IdRedistributor

		print '[@IdSource]'
		print   @IdSource 

		--SELECT sett.IdSettlement, sett.Settlement FROM DeliveryBackOffice.DBO.Settlement sett
		--WHERE sett.IdCountry = 'GT'
		--AND sett.Settlement like '%ZONA 12%'
		--AND sett.SettlementSatus = 'TRUE'
		----AND sett.IdSettlement = 1454

		--select * from #Ecommrce  --ox

		--Obtiene datos de la moneda enviada
		select  webcurr.CUR_IdCurrency    [IdCurrency],
				deskcurr.CUR_ExchangeRate [ExchangeRate],
				deskcurr.CUR_Name		  [CurrencyName],
				webcurr.CUR_ISO4217Code   [CurrencyISO4217],
				deskcurr.CUR_Symbol		  [CurrencySymbol],
				deskcurr.CUR_Country	  [CurrencyCountry]
		into #MonCurrency
		from DenariusWeb_Dev.dbo.currency webcurr WITH (NOLOCK)
		join DenariusDesktop_Dev.dbo.PRM_Currency deskcurr WITH (NOLOCK)
				on webcurr.CUR_IdCurrency = deskcurr.CUR_IdCurrency
		where webcurr.CUR_ISO4217Code = @Currency
		and deskcurr.CUR_Country = @Country

		--select * from #MonCurrency --ox

		--Identifico el rango de peso del producto
		declare @IdDimensional as int 
		set @IdDimensional  = -1 
		select  @IdDimensional = dim.IdDimensional FROM DeliveryBackOffice.dbo.DimensionalParameter dim WITH (NOLOCK)
		where dim.IdCountry = 'GT'
		and dim.DimensionalStatus = 'TRUE'
		AND dim.ByUnity = 'FALSE'
		and dim.ByRange = 'TRUE'
		and dim.IdUnit = 4 --LBS
		and (@ProductWeight >= dim.MinimunValue and @ProductWeight <= dim.MaximunValue )

		print '[@IdDimensional]'
		print   @IdDimensional 

		select sett.IdSettlement, 
					sett.IsSpecial,  
					schedsett.IdSegmentArea, 
					schedsett.ScheduledVisitSunday,
					schedsett.ScheduledVisitMonday ,
					schedsett.ScheduledVisitTuesday ,
					schedsett.ScheduledVisitWednesday, 
					schedsett.ScheduledVisitThursday ,
					schedsett.ScheduledVisitFriday ,
					schedsett.ScheduledVisitSaturday,
					schedsett.IdVisitPointClient
					into  #ScheduleDestiny
			from DeliveryBackOffice.DBO.Settlement sett 
				JOIN DeliveryBackOffice.DBO.ScheduledVisitSettlement schedsett 
						on sett.IdSettlement = schedsett.IdSettlement
				LEFT JOIN #VPClient vpclient 
						on schedsett.IdSettlement = vpclient.IdSettlement --detecta el origen / express center xela, gt, coban
						and sett.IdSettlement = vpclient.IdSettlement 
						and vpclient.IdVPCodeOfReference = schedsett.IdVisitPointClient
			where sett.IdSettlement = @IdSettlement
			and schedsett.SettScheduleVisitStatus = 'TRUE'
			and schedsett.IdVisitPointClient = (case when @IdRedistributor > 0 then @IdRedistributor else 999 end) 
			
		--select * from #ScheduleDestiny --ox
		--que dia de la semana fue la compra
		declare @DayEcomCheckOut as int
			set @DayEcomCheckOut  = (select DATEPART(weekday, @FechaCompra))

		declare @DayEcomPU as int  --hay que asumir que vamos todos los dias, excepto domingo 1. WeekDay
			set @DayEcomPU  = (select DATEPART(weekday, DATEADD(DAY,1,@FechaCompra)))

		print '@DayEcomPU'
		print  @DayEcomPU 
		print '@DayEcomCheckOut'
		print  @DayEcomCheckOut 

		--variable que servirá para almacenar los dias configurados de visita programada a una destino
		Declare @DayString varchar(50)=''
		select  @DayString = CONCAT('1-',ScheduledVisitSunday ,  ',' 
				  				  , '2-',ScheduledVisitMonday ,  ',' 
								  , '3-',ScheduledVisitTuesday , ',' 
								  , '4-',ScheduledVisitWednesday, ',' 
								  , '5-',ScheduledVisitThursday , ',' 
								  , '6-',ScheduledVisitFriday , ',' 
								  , '7-',ScheduledVisitSaturday)
		from #ScheduleDestiny DLDay

		print '[@DayString]'
		print   @DayString
		--variable tipo tabla temporal que servirá para mapear los dias de la semana vs los validos para visitar al cliente
		declare @Week table(_Day tinyint, _Valid bit)

		insert into @Week 
		select  cast(LEFT(d.Item ,1) as tinyint)_WEEKDAY,
				cast(RIGHT(d.Item ,1)as bit) _VALID  
		from DenariusDesktop_Dev.dbo.split(@DayString) d

		--variable que representara la cantidad de dias proximo a atender el servicio en modalidad next day, 
		--despues de haber recolectado en bodega cliente
		DECLARE @DAYS INT= 0
		
		--next day after PU
		select @DAYS=isnull((select top 1 w._Day from @week w 
							  where _Valid='TRUE'and w._Day > @DayEcomPU order by 1 asc)
					,isnull((select top 1 (case when w._Day = @DayEcomPU then 8 else w._Day end)from @week w 
							where _Valid='TRUE'order by 1 asc),8))
		--el numero 8 representa que pasa a la siguiente semana, es decir que va a los 8 dias

		print '[@DAYS] - next day after PU'
		print @DAYS
		--select * from #ScheduleDestiny destino
		
		--se almacena en tabla dinamica los valores que vamos a necesitar para una cotizacion
		select @IdEcommerce  IdEcommerce,
			   @IdSettlement IdSettlement,	
			   rate.IdRate,
			   rate.IdDimensional, 
			   rate.IdSegmentArea,
			   area.Abrevation [SegmentArea],
			   @ProductWeight ProductWeight,
			   params.MinimunValue,
			   params.MaximunValue,
			   params.IdUnit,
			   rate.PriceRate,
			   rate.ExceededRate,
			   (case when rate.ExceededRate = 'TRUE' 
						  then (@ProductWeight -  params.MinimunValue) 
					  else 0
				end) [Overweight],
			   ISNULL(rate.AdicionalCostPerUnit, 0) [AddCostPerUnit],
			   rate.FlatRateStatus,
			   @FechaCompra DATE_SALE, 
			   Cast(DATEADD(DAY,1,@FechaCompra) as datetime) DATE_PICKUP, 
			   Cast(DATEADD(DAY,@DAYS-1,@FechaCompra) as datetime) DATE_DELIVERY,
			   rate.IdCurrency,
			   rate.IdCountry,
			   rate.IdRateCategory,
			   category.TitleName [RateTitlePlan],
			   rate.DateFromValid,
			   rate.DateExpired
		into #EstimateRate
		from [dbo].[FlateRate] rate										with(nolock)
		join DeliveryBackOffice.dbo.SegmentArea area					with(nolock) 
								on rate.IdSegmentArea = area.IdSegmentArea
		left join DeliveryBackOffice.DBO.DimensionalParameter params	with(nolock) 
								on rate.IdDimensional = params.IdDimensional
		left join DeliveryBackOffice.DBO.RateCategory category			with(nolock) 
								on category.IdRateCategory  = rate.IdRateCategory
								and category.RateCatStatus= 'TRUE'
		where rate.FlatRateStatus = 'TRUE'
		and rate.IdDimensional = @IdDimensional
		and rate.IdSegmentArea = ( select top 1 destino.IdSegmentArea from #ScheduleDestiny destino )

		

		--select * from #EstimateRate --ox
		--Se almacena en datos generales los valores que se utilizaran de referencia 
		--para hacer los calculos de costos implicitos segun reglas negocio 
		select  RateEst.IdEcommerce			[IdEcommerce],	
				RateEst.IdSettlement		[IdSettlement],	
				RateEst.IdRate				[IdRate],
				RateEst.IdDimensional		[IdDimensional],
				RateEst.IdSegmentArea		[IdSegmentArea],
				RateEst.SegmentArea			[SegmentArea],	
				Dest.IsSpecial				[AreaIsSpecial],	
				RateEst.ProductWeight		[ProductWeight],	
				RateEst.MinimunValue		[MinimunValue],	
				RateEst.MaximunValue		[MaximunValue],	
				RateEst.IdUnit				[IdUnit],	
				RateEst.PriceRate			[PriceRate],	
				RateEst.ExceededRate		[ExceededRate],	
				RateEst.Overweight			[Overweight],	
				RateEst.AddCostPerUnit		[AddCostPerUnit],	
				RateEst.FlatRateStatus		[FlatRateStatus],	
				RateEst.DATE_SALE			[DateEcommerceSale], 
				RateEst.DATE_PICKUP			[DateEcommercePickUp], -- 
				RateEst.DATE_DELIVERY		[DateCarrierDelivery],
				RateEst.IdCurrency			[IdCurrency],	
				RateEst.IdCountry			[IdCountry],	
				RateEst.IdRateCategory		[IdRateCategory],	
				RateEst.RateTitlePlan		[RatePlanDescription],	
				RateEst.DateFromValid	    [FlatRateDateFromValid],
				RateEst.DateExpired			[FlatRateDateExpired],
				Dest.ScheduledVisitSunday	[SettlementScheduledVisitSunday],	
				Dest.ScheduledVisitMonday	[SettlementScheduledVisitMonday],	
				Dest.ScheduledVisitTuesday	[SettlementScheduledVisitTuesday],	
				Dest.ScheduledVisitWednesday [SettlementScheduledVisitWednesday],
				Dest.ScheduledVisitThursday	[SettlementScheduledVisitThursday],
				Dest.ScheduledVisitFriday	[SettlementScheduledVisitFriday],	
				Dest.ScheduledVisitSaturday	[SettlementScheduledVisitSaturday],	
				ecomm.EcomerceName			[EcomerceName],
				ecomm.UserKey				[EcomerceUser],
				@IdMerchant					[IdCustomer]
		into #GeneralDataRate
		from #EstimateRate RateEst 
		join #ScheduleDestiny Dest 
				on RateEst.IdSettlement = Dest.IdSettlement
		left join #Ecommrce ecomm 
				on RateEst.IdEcommerce = ecomm.IdEcommerce
				and ecomm.EcommerceStatus = 'TRUE'
		where RateEst.IdEcommerce = @IdEcommerce
		order by ecomm.IdEcommerce desc 

 		--CALCULO DE COSTOS
		----RECARGOS
				select Surcharges.IdSurcharge,
					   Surcharges.SurchargeDescription,
					   Surcharges.Quantity,
					   Surcharges.Price,
					   Surcharges.PercentVal,
					   Surcharges.Total,
					   Surcharges.Apply [Applica]
					   into #CostDetail
				from (
						--tarifa base
						select  NULL							[IdSurcharge],
								'TARIFA BASE'					[SurchargeDescription],
								1								[Quantity],
								gnrl.PriceRate					[Price],
								0								[PercentVal],
								(1 * gnrl.PriceRate) * (1 + 0)	[Total],
								Cast('TRUE' as bit)				[Apply]
						 from #GeneralDataRate gnrl
						 UNION
						 --Monto Asegurado
						select secure.IdSurcharge				[IdSurcharge],
								secure.SurchargeName			[SurchargeDescription],
								1								[Quantity],
								@AmmountValue 					[Price],
								(case when (select (@AmmountValue / cur.ExchangeRate) from #MonCurrency cur ) >= 100 --cien dolares
									  then (secure.PercentValue)
										else (0)
									end )						[PercentVal],
								(case when (select (@AmmountValue / cur.ExchangeRate) 
											from #MonCurrency cur ) >= 100
									  then 
											(((1 * @AmmountValue) * 
											  (case when (select (@AmmountValue / cur.ExchangeRate) 
														 from #MonCurrency cur ) >= 100 --cien dolares
													then (1 + (secure.PercentValue/100))
													else (0)
												end)) - @AmmountValue)
									 else  0
								end)							[Total],
								cast((case when 
										   (select (@AmmountValue / cur.ExchangeRate) 
											from #MonCurrency cur ) >= 100 --cien dolares
									 then  'TRUE'
									 else  'FALSE'
								end) as bit)					[Apply]
						 from #GeneralDataRate gnrl , 							
							  DeliveryBackOffice.dbo.Surcharge secure
						 WHERE IdSurcharge = 1 --ASEGURADO
						 --ESPECIAL O ZONA ROJA	
						 UNION
						 select redzone.IdSurcharge				[IdSurcharge],
								redzone.SurchargeName			[SurchargeDescription],
								1								[Quantity],
								gnrl.PriceRate					[Price],
								(case when gnrl.AreaIsSpecial = 'TRUE'
									  then (redzone.PercentValue)
									  else 0
								 end
								)								[PercentVal],
				
								(case when gnrl.AreaIsSpecial = 'TRUE'
									  then (((1 * gnrl.PriceRate) * 
											(case when gnrl.AreaIsSpecial = 'TRUE'
												  then (1 + (redzone.PercentValue)/100)
												  else (0)
											 end
											)) -  gnrl.PriceRate)
									   else (0)
								end)							[Total],
								gnrl.AreaIsSpecial				[Apply]
						 from #GeneralDataRate gnrl , 							
							  DeliveryBackOffice.dbo.Surcharge redzone
						 where IdSurcharge = 2 --ESPECIAL O ZONA ROJA	
						 --FRAGIL	--Es fragil o cuidado especial
						 UNION
						 select fragil.IdSurcharge				[IdSurcharge],
								fragil.SurchargeName			[SurchargeDescription],
								1								[Quantity],
								gnrl.PriceRate					[Price],
								(case when @IsFragil = 'TRUE'
									  then (fragil.PercentValue)
									  else (0)
								 end
								)								[PercentVal],
								(case when @IsFragil= 'TRUE'
									  then	(((1 * gnrl.PriceRate) * 
											(case when @IsFragil= 'TRUE'
													then (1 + (fragil.PercentValue)/100)
													else (0)
												end
											)) - gnrl.PriceRate)		
										else (0)
								end)							[Total],
								@IsFragil						[Apply]
						 from #GeneralDataRate gnrl , 							
							  DeliveryBackOffice.dbo.Surcharge fragil
						 where IdSurcharge = 3 --FRAGIL	
						 --SOBREPESO
						 UNION
						 select Overweight.IdSurcharge					[IdSurcharge],
								 Overweight.SurchargeName				[SurchargeDescription],
								gnrl.Overweight							[Quantity],
								gnrl.AddCostPerUnit						[Price],
								(case when gnrl.ExceededRate = 'TRUE'
									  then (Overweight.PercentValue)
									  else (0)
								 end
								)										[PercentVal],
								(case when gnrl.ExceededRate = 'TRUE'
									  then 
											((case when gnrl.Overweight > 0 
												   then  gnrl.Overweight
												   else 1
											   end) * gnrl.AddCostPerUnit)  
									  else (0)
								 end)									[Total],
								gnrl.ExceededRate 						[Apply]
						 from #GeneralDataRate gnrl , 							
							  DeliveryBackOffice.dbo.Surcharge Overweight
						 where IdSurcharge = 4 --SOBREPESO
				 ) Surcharges
				 
				 declare @TotalCostWithoutIVA decimal(18,2) = 0;  
				 set @TotalCostWithoutIVA = (select sum(DtlCost.Total) from #CostDetail DtlCost where DtlCost.Applica = 'TRUE');
				 
				 

				 select DtlCostServ.IdSurcharge,
						DtlCostServ.SurchargeDescription,
						DtlCostServ.Quantity,
						DtlCostServ.Price,
						DtlCostServ.PercentVal,
						DtlCostServ.Total,
						DtlCostServ.Applica
						into #IntegrationCost
				 from (
						select DtlIntg.IdSurcharge,
							DtlIntg.SurchargeDescription,
							DtlIntg.Quantity,
							DtlIntg.Price,
							DtlIntg.PercentVal,
							DtlIntg.Total,
							DtlIntg.Applica
						from #CostDetail DtlIntg
						UNION 
						--IVA IMPUESTO DE VALOR AGREGADO
						select iva.IdSurcharge						[IdSurcharge],
							iva.SurchargeName						[SurchargeDescription],
							1										[Quantity],
							@TotalCostWithoutIVA					[Price],
							iva.PercentValue						[PercentVal],
							(@TotalCostWithoutIVA * 
							(iva.PercentValue/100))					[Total],
							Cast('TRUE' as bit)						[Aplica]
						from DeliveryBackOffice.dbo.Surcharge iva
						where IdSurcharge = 6 --IVA
					)DtlCostServ
				 
				 

		BEGIN TRANSACTION;
			
			declare @TotalShipping as decimal (18,2) = 0;
			declare @IdRateEstimated as bigint = -1;
			
			print 'set @TotalShipping'
			print @TotalShipping
			
			--genero el valor totalde la cotización en base a detalle de costos calculados
			set @TotalShipping = (select sum(isnull(DtlCost.Total,0)) from #IntegrationCost DtlCost where DtlCost.Applica = 'TRUE');

			print 'Calc @TotalShipping'
			print @TotalShipping
			
			Print 'set @IdRateEstimated'
			Print @IdRateEstimated
			
			--select isnull(count(cotzn.IdRateEstimated),0) 
			--						from [DeliveryBackOffice].[dbo].[RateEstimate] cotzn
			--						where cotzn.IdEcommerce = @IdEcommerce
			--						and cotzn.IdSource = @IdSource
			--						and cotzn.IdDestiny = @IdDestiny
			--						and cotzn.CountPieces = @CountPieces
			--						and cotzn.UnitValue = @ProductWeight
			--						and cotzn.EcomValueAmmount = @AmmountValue
			--						and cotzn.EcomValueCurrency = @Currency
			--						--and cotzn.IdUnit =  4-- lbs
			--						--and cotzn.BaseRate = (select valgnrlrate.PriceRate from #GeneralDataRate valgnrlrate)
			--						and cotzn.EstimateTotalAmount = @TotalShipping
			--						and Cast(cotzn.DateCarrierDelivery as date) = (select Cast(valgnrlrate.DateCarrierDelivery as date) 
			--																		from #GeneralDataRate valgnrlrate)
			--						and DATEDIFF(day, Cast(cotzn.DateCreated as date), cast(getdate() as date)) <= 31 --la cotizacion este vigente en 31 dias

			--se verifica que no exista la cotizacion para esa fecha, origen, destino, precio, piezas y monto total
			set @IdRateEstimated = isnull((select top 1 cotzn.IdRateEstimated 
									from [DeliveryBackOffice].[dbo].[RateEstimate] cotzn
									where cotzn.IdEcommerce = @IdEcommerce
									and cotzn.IdSource = @IdSource
									and cotzn.IdDestiny = @IdDestiny
									and cotzn.CountPieces = @CountPieces
									and cotzn.UnitValue = @ProductWeight
									--and cotzn.IdUnit =  4-- lbs
									and cotzn.EcomValueAmmount = @AmmountValue
									and cotzn.EcomValueCurrency = @Currency
									--and cotzn.BaseRate = (select valgnrlrate.PriceRate from #GeneralDataRate valgnrlrate)
									and cotzn.EstimateTotalAmount = @TotalShipping
									and Cast(cotzn.DateCarrierDelivery as date) = (select Cast(valgnrlrate.DateCarrierDelivery as date) 
																					from #GeneralDataRate valgnrlrate)
									and DATEDIFF(day, Cast(cotzn.DateCreated as date), cast(getdate() as date)) <= 31 --la cotizacion este vigente en 31 dias
									order by cotzn.IdRateEstimated desc
								   ),0)
			
			print 'Validacion existencia @IdRateEstimated'
			print @IdRateEstimated 

			----se procede a registrar cotizacion
			if (@IdRateEstimated <= 0)
			begin 



				print 'inserta maestro rateestimate'
				--Maestro
				insert into [DeliveryBackOffice].[dbo].[RateEstimate]
						   ([IdSource]
						   ,[IdDestiny]
						   ,[ObjectType]
						   ,[CountPieces]
						   ,[UnitValue]
						   ,[IdUnit]
						   ,[CodeCredit]
						   ,[IdRate]
						   ,[BaseRate]
						   ,[EstimateTotalAmount]
						   ,[IdCustomer]
						   ,[IdEcommerce]
						   ,[DateService]
						   ,[EstimatedStatus]
						   ,[TokenCreated]
						   ,[DateCreated]
						   ,[TokenUpdated]
						   ,[DateUpdated]
						   ,[DateEcommerceSale]
						   ,[DateEcommercePickUp]
						   ,[DateCarrierDelivery]
						   ,[IdCurrency]
						   ,[IdCountry]
						   ,[IdRateCategory]
						   ,[RatePlanDescription]
						   ,[EcomValueAmmount]
						   ,[EcomValueCurrency]
						   ,[EcomValueRateExchange]
						   )
				select 	@IdSource						[IdSource], 
						@IdSettlement					[IdDestiny],
						@ObjectType						[ObjectType],
						@CountPieces					[CountPieces],
						HeaderRate.ProductWeight		[ProductWeight], 
						HeaderRate.IdUnit				[IdUnit], --4:lbs
						@CodeCredit						[CodeCredit],
						HeaderRate.IdRate				[IdRate],
						HeaderRate.PriceRate			[BaseRate],
						@TotalShipping					[EstimateTotalAmount],
						HeaderRate.IdCustomer			[IdCustomer],
						HeaderRate.IdEcommerce			[IdEcommerce],
						GETDATE()        				[DateService],
						'TRUE'							[EstimatedStatus],
						CONCAT('SYS-', 
						ISNULL(HeaderRate.EcomerceUser,
						'DEVFORZADL'))					[TokenCreated],
						GETDATE()						[DateCreated],
						NULL							[TokenUpdated],
						NULL							[DateUpdated],
						@FechaCompra					[DateEcommerceSale],   --when product sale in checkout ecommerce website
						HeaderRate.DateEcommercePickUp	[DateEcommercePickUp], -- when will the picking up in warehouse ecommerce be made
						HeaderRate.DateCarrierDelivery	[DateCarrierDelivery], -- when will the delivery be made
						HeaderRate.IdCurrency			[IdCurrency],
						HeaderRate.IdCountry			[IdCountry],
						HeaderRate.IdRateCategory		[IdRateCategory],
						HeaderRate.RatePlanDescription	[RatePlanDescription],
						@AmmountValue					[EcomValueAmmount],  --monto total valor producto
						cur.CurrencyISO4217				[Currency],    --moneda local pais
						cur.ExchangeRate				[ExchangeRate] --tasa cambio a dolares
				from #GeneralDataRate HeaderRate
				left join #MonCurrency cur 
						on cur.IdCurrency = HeaderRate.IdCurrency 
				where HeaderRate.IdCountry = cur.CurrencyCountry
 
				select @IdRateEstimated  = SCOPE_IDENTITY();
			
				print '@IdRateEstimated'
				print @IdRateEstimated  
			
				--Detalle
				if (@IdRateEstimated > 0)
				begin
						print 'se crea valor'
						declare @EcommUser as nvarchar(50) = 'SYS-ECOFORZADL';
						declare @IdRateCategory  as int = 2;

						select @EcommUser = gnrld.EcomerceUser , @IdRateCategory = gnrld.IdRateCategory
						from #GeneralDataRate gnrld
		
						insert into DeliveryBackOffice.[dbo].[RateEstimateDetail]
									([IdRateEstimate]
									,[IdSettlment]
									,[CountValue]
									,[IdSurcharge]
									,[SurchargeDescription]
									,[PriceRate]
									,[PercentValue]
									,[TotalAmount]
									,[IdRateCategory]
									,[Selected]
									,[DateExpire]
									,[EstimateDetailStatus]
									,[TokenCreated]
									,[DateCreated]
									,[TokenUpdated]
									,[DateUpdated])
								select @IdRateEstimated						[IdRateEstimate],		--<IdRateEstimate, bigint,>
										@IdSettlement						[IdSettlment],			--<IdSettlment, bigint,>
										DetailRate.[Quantity]				[CountValue],			--<CountValue, decimal(18,2),>
										DetailRate.[IdSurcharge]			[IdSurcharge],			--<IdSurcharge, int,>
										DetailRate.[SurchargeDescription]	[SurchargeDescription], --<SurchargeDescription, nvarchar(50),>
										DetailRate.[Price]					[PriceRate],			--<PriceRate, decimal(18,2),>
										DetailRate.[PercentVal]				[PercentValue],			--<PercentValue, decimal(18,2),>
										DetailRate.[Total]					[TotalAmount],			--<TotalAmount, decimal(18,2),>
										(@IdRateCategory)					[IdRateCategory],		--<IdRateCategory, int,>
										DetailRate.[Applica]					[Selected],				--<Selected, bit,>
										DATEADD(DAY, 31, GETDATE())			[DateExpire],			--<DateExpire, datetime,>
										'TRUE'								[EstimateDetailStatus], --<EstimateDetailStatus, bit,>
										CONCAT('SYS-',
										(ISNULL(@EcommUser,'DEVFORZADL')))	[TokenCreated],			--<TokenCreated, nvarchar(50),>
										GETDATE()							[DateCreated],			--<DateCreated, datetime,>
										NULL								[TokenUpdated],			--<TokenUpdated, nvarchar(50),>
										NULL								[DateUpdated]			--<DateUpdated, datetime,>
								from #IntegrationCost DetailRate
								where DetailRate.[Applica] = 'TRUE'
					
						--COMMIT TRANSACTION;
					end
				--else
				--BEGIN
				--	--		ROLLBACK TRANSACTION; 
				--	--END
			end
			--else
			--begin 
			--	COMMIT TRANSACTION;
			--end
			COMMIT;
			
			print 'Borrando tablas temporales'
			print '#Ecommrce,  #VPClient,#MonCurrency, #ScheduleDestiny,#EstimateRate, #GeneralDataRate, #CostDetail, #ScheduleDestiny, #IntegrationCost' 
			
			IF OBJECT_ID('tempdb.dbo.#Ecommrce', 'U') IS NOT NULL DROP TABLE #Ecommrce;
			IF OBJECT_ID('tempdb.dbo.#VPClient', 'U') IS NOT NULL DROP TABLE #VPClient;
			IF OBJECT_ID('tempdb.dbo.#MonCurrency', 'U') IS NOT NULL DROP TABLE #MonCurrency;
			IF OBJECT_ID('tempdb.dbo.#ScheduleDestiny', 'U') IS NOT NULL DROP TABLE #ScheduleDestiny;
			IF OBJECT_ID('tempdb.dbo.#EstimateRate', 'U') IS NOT NULL DROP TABLE #EstimateRate;
			IF OBJECT_ID('tempdb.dbo.#GeneralDataRate', 'U') IS NOT NULL DROP TABLE #GeneralDataRate;
			IF OBJECT_ID('tempdb.dbo.#CostDetail', 'U') IS NOT NULL DROP TABLE #CostDetail;
			IF OBJECT_ID('tempdb.dbo.#ScheduleDestiny', 'U') IS NOT NULL DROP TABLE #ScheduleDestiny;
			IF OBJECT_ID('tempdb.dbo.#IntegrationCost', 'U') IS NOT NULL DROP TABLE #IntegrationCost;
	
		    select  hdrctz.[IdRateEstimated], 
					hdrctz.[IdSource], 
					hdrctz.[IdDestiny], 
					hdrctz.[ObjectType], 
					hdrctz.[CountPieces], 
					hdrctz.[UnitValue], 
					hdrctz.[IdUnit], 
					hdrctz.[CodeCredit], 
					hdrctz.[IdRate], 
					hdrctz.[BaseRate], 
					hdrctz.[EstimateTotalAmount], 
					hdrctz.[IdCustomer], 
					hdrctz.[IdEcommerce], 
					hdrctz.[DateService], 
					hdrctz.[EstimatedStatus], 
					hdrctz.[TokenCreated], 
					hdrctz.[DateCreated], 
					hdrctz.[TokenUpdated], 
					hdrctz.[DateUpdated], 
					hdrctz.[DateEcommerceSale], 
					hdrctz.[DateEcommercePickUp], 
					hdrctz.[DateCarrierDelivery], 
					hdrctz.[IdCurrency], 
					hdrctz.[IdCountry], 
					hdrctz.[IdRateCategory], 
					hdrctz.[RatePlanDescription],
					hdrctz.[EcomValueAmmount],
					hdrctz.[EcomValueCurrency],
					hdrctz.[EcomValueRateExchange]
			from RateEstimate hdrctz
			where hdrctz.IdRateEstimated = @IdRateEstimated

			select  dtlctz.[IdRateEstimateDetail], 
					dtlctz.[IdRateEstimate], 
					dtlctz.[IdSettlment],  
					dtlctz.[CountValue], 
					dtlctz.[IdSurcharge], 
					dtlctz.[SurchargeDescription], 
					dtlctz.[PriceRate], 
					dtlctz.[PercentValue], 
					dtlctz.[TotalAmount], 
					dtlctz.[IdRateCategory], 
					dtlctz.[Selected], 
					dtlctz.[DateExpire], 
					dtlctz.[EstimateDetailStatus], 
					dtlctz.[TokenCreated], 
					dtlctz.[DateCreated], 
					dtlctz.[TokenUpdated], 
					dtlctz.[DateUpdated]
			from RateEstimateDetail dtlctz
			where dtlctz.IdRateEstimate = @IdRateEstimated
			and dtlctz.EstimateDetailStatus = 'TRUE'
			and Cast(dtlctz.DateExpire as date) > Cast(getdate() as date)

			print 'Valida @IdSellerDepot > 0'
			print @IdSellerDepot 
			IF (@IdSellerDepot > 0 )
			BEGIN
				print 'Valida  IdKindOfVPClient = 5'
				IF ((SELECT IdKindOfVPClient
					FROM DeliveryBackOffice.dbo.VisitPointClient vpc 
						  LEFT JOIN DeliveryBackOffice.dbo.SellerDepot bodega
									on bodega.IdSettlement =  vpc.idsettlement
									and bodega.idvisitpointclient = vpc.CodeOfReference
					WHERE vpc.IdSettlement = @IdSource ---2126 
					AND bodega.idsellerdepot = @IdSellerDepot -- 26
					and (vpc.CodeOfReference = case when @VPCodeOfReference != -1 then @VPCodeOfReference else vpc.CodeOfReference end)
					or bodega.IdSellerDepot is null
					) = 5 )
						--api client
					BEGIN
						PRINT 'ENTRO A CONSUMO API CLIENT'
						--Devuelve en un tercer select datos para el origen
						select  Cast(pob.IdSettlement as varchar) IdSettlementSource, 
								pob.Settlement SettlementSource,
								Cast(pob.IdTownship as varchar) IdTownShipSource, 
								mun.TownshipName TownshipNameSource, 
								Cast(pob.IdProvince as varchar) IdProvinceSource, 
								dep.ProvinceName IdProvinceNameSource, 
								dep.IdCountry  IdCountrySource,
								dep.ProvinceAbbreviation ProvinceAbrreviationSource,
								hub.HubAbbreviation  HubAbbreviationSource,
								ISNULL(Cast(vpc.CodeOfReference as varchar), '') SourceCodeOfReferenceID,
								ISNULL(vpc.ContactName,'')  SourceVPCName,
								ISNULL(vpc.DescriptionOfClient,'')  SourceEXPCName,
								ISNULL(Cast(vpc.CustomerID as varchar), '')  SouceVPCustomerID,
								ISNULL(UPPER(client.abbreviation), '') AbbrvCustomerName,
								ISNULL(Cast(vpc.VisitPointId as varchar), '') SourceVPCVisitPointId,
								UPPER(bodega.Address) DepotAddress
						from DeliveryBackOffice.dbo.Settlement pob
							JOIN DeliveryBackOffice.dbo.Township mun
								on pob.IdTownship = mun.IdTownship
							JOIN DeliveryBackOffice.dbo.Province dep
								on	mun.IdProvince = dep.IdProvince
								and dep.ProvinceStatus = 'TRUE'
							JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbh
								on mun.IdTownship = tbh.IdTownship
								and tbh.StatustownshipHub = 'TRUE'
								AND tbh.TownshipHubDefault = 'TRUE'
							LEFT JOIN DeliveryBackOffice.dbo.HubLogistics hub
								on tbh.IdHublogistic = hub.IdHubLogistic
							LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vpc
								on pob.IdSettlement = vpc.IdSettlement
							LEFT JOIN DeliveryBackOffice.dbo.Customer client
								on vpc.CustomerID = client.IdCustomer
							LEFT JOIN DeliveryBackOffice.dbo.SellerDepot bodega
							  on bodega.IdSettlement =  vpc.idsettlement
								and bodega.idvisitpointclient = vpc.CodeOfReference
						where pob.SettlementSatus = 'TRUE'
						and pob.IdSettlement = @IdSource
						and bodega.idsellerdepot = @IdSellerDepot

						print '@IdSettlement'
						print @IdSettlement
						
						print '@IdSellerDepot'
						print @IdSellerDepot

						print 'fin select api client'
					END 
					ELSE
					BEGIN
						
						SELECT   '500' AS ErrorNumber  
								,'SELLER CONFIG NO FUNCTIONAL' AS ErrorSeverity  
								,'500' AS ErrorState  
								,'' AS ErrorProcedure  
								,'768' AS ErrorLine  
								,'Seller Depot not configured' AS ErrorMessage,
								'' IdSettlementSource, 
								'' SettlementSource,
								'' IdTownShipSource, 
								'' TownshipNameSource, 
								'' IdProvinceSource, 
								'' IdProvinceNameSource, 
								'' IdCountrySource,
								'' ProvinceAbrreviationSource,
								'' HubAbbreviationSource,
								'' SourceCodeOfReferenceID,
								'' SourceVPCName,
								'' SourceEXPCName,
								'' SouceVPCustomerID,
								'' AbbrvCustomerName,
								'' SourceVPCVisitPointId,
								'' DepotAddress



					END 
			END
			ELSE
			BEGIN

				IF (@IdKindOfVP = 4 ) -- cliente corporativo
					BEGIN
						select top 1 Cast(pob.IdSettlement as varchar) IdSettlementSource, 
							pob.Settlement SettlementSource,
							Cast(pob.IdTownship as varchar) IdTownShipSource, 
							mun.TownshipName TownshipNameSource, 
							Cast(pob.IdProvince as varchar) IdProvinceSource, 
							dep.ProvinceName IdProvinceNameSource, 
							dep.IdCountry  IdCountrySource,
							dep.ProvinceAbbreviation ProvinceAbrreviationSource,
							hub.HubAbbreviation  HubAbbreviationSource,
							ISNULL(Cast(vpc.CodeOfReference as varchar), '') SourceCodeOfReferenceID,
							ISNULL(vpc.ContactName,'')  SourceVPCName,
							ISNULL(vpc.DescriptionOfClient,'')  SourceEXPCName,
							ISNULL(Cast(vpc.CustomerID as varchar), '')  SouceVPCustomerID,
							'' AbbrvCustomerName,
							ISNULL(Cast(vpc.VisitPointId as varchar), '') SourceVPCVisitPointId,
							'' DepotAddress
						from DeliveryBackOffice.dbo.Settlement pob
						left JOIN DeliveryBackOffice.dbo.Township mun on pob.IdTownship = mun.IdTownship
						left JOIN DeliveryBackOffice.dbo.Province dep on	mun.IdProvince = dep.IdProvince and dep.ProvinceStatus = 'TRUE'
						left JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbh on mun.IdTownship = tbh.IdTownship and tbh.StatustownshipHub = 'TRUE' AND tbh.TownshipHubDefault = 'TRUE'
						LEFT JOIN DeliveryBackOffice.dbo.HubLogistics hub on tbh.IdHublogistic = hub.IdHubLogistic
						LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vpc on vpc.CodeOfReference = @VPCodeOfReference
						LEFT JOIN DeliveryBackOffice.dbo.Customer client on vpc.CustomerID = client.IdCustomer
						where pob.SettlementSatus = 'TRUE'
						and pob.IdSettlement = @IdSource
						 and vpc.CustomerID= @IdMerchant
						-- and (vpc.CodeOfReference = case when @VPCodeOfReference != -1 then @VPCodeOfReference else vpc.CodeOfReference end)
					end
				else
				begin
					--Devuelve en un tercer select datos para el origen
					select top 1 Cast(pob.IdSettlement as varchar) IdSettlementSource, 
							pob.Settlement SettlementSource,
							Cast(pob.IdTownship as varchar) IdTownShipSource, 
							mun.TownshipName TownshipNameSource, 
							Cast(pob.IdProvince as varchar) IdProvinceSource, 
							dep.ProvinceName IdProvinceNameSource, 
							dep.IdCountry  IdCountrySource,
							dep.ProvinceAbbreviation ProvinceAbrreviationSource,
							hub.HubAbbreviation  HubAbbreviationSource,
							ISNULL(Cast(vpc.CodeOfReference as varchar), '') SourceCodeOfReferenceID,
							ISNULL(vpc.ContactName,'')  SourceVPCName,
							ISNULL(vpc.DescriptionOfClient,'')  SourceEXPCName,
							ISNULL(Cast(vpc.CustomerID as varchar), '')  SouceVPCustomerID,
							ISNULL(UPPER(client.abbreviation), '') AbbrvCustomerName,
							ISNULL(Cast(vpc.VisitPointId as varchar), '') SourceVPCVisitPointId,
							'' DepotAddress
					from DeliveryBackOffice.dbo.Settlement pob
						JOIN DeliveryBackOffice.dbo.Township mun
							on pob.IdTownship = mun.IdTownship
						JOIN DeliveryBackOffice.dbo.Province dep
							on	mun.IdProvince = dep.IdProvince
							and dep.ProvinceStatus = 'TRUE'
						JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbh
							on mun.IdTownship = tbh.IdTownship
							and tbh.StatustownshipHub = 'TRUE'
							AND tbh.TownshipHubDefault = 'TRUE'
						LEFT JOIN DeliveryBackOffice.dbo.HubLogistics hub
							on tbh.IdHublogistic = hub.IdHubLogistic
						LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vpc
							on pob.IdSettlement = vpc.IdSettlement
						LEFT JOIN DeliveryBackOffice.dbo.Customer client
							on vpc.CustomerID = client.IdCustomer
					where pob.SettlementSatus = 'TRUE'
					--and pob.IdSettlement = @IdSource
					and vpc.CustomerID= @IdMerchant
					and (vpc.CodeOfReference = case when @VPCodeOfReference != -1 then @VPCodeOfReference else vpc.CodeOfReference end)
				end
			END

			
			--Devuelve en un cuarto select datos para el destino
			select  top 1 Cast(pob.IdSettlement as varchar) IdSettlementDestiny, 
					pob.Settlement SettlementDestiny,
					Cast(pob.IdTownship as varchar) IdTownShipDestiny, 
					mun.TownshipName TownshipNameDestiny, 
					Cast(pob.IdProvince as varchar)  IdProvinceDestiny, 
					dep.ProvinceName IdProvinceNameDestiny, 
					dep.IdCountry  IdCountryDestiny,
					dep.ProvinceAbbreviation ProvinceAbrreviationDestiny,
					hub.HubAbbreviation  HubAbbreviationDestiny,
					ISNULL(Cast(vpc.CodeOfReference as varchar), '') DestinyCodeOfReferenceID,
					ISNULL(vpc.ContactName,'')  DestinyVPCName,
					ISNULL(Cast(vpc.CustomerID as varchar), '')  DestinyVPCustomerID,
					ISNULL(Cast(vpc.VisitPointId as varchar), '') DestinyVPCVisitPointId
			from DeliveryBackOffice.dbo.Settlement pob
				JOIN DeliveryBackOffice.dbo.Township mun
					on pob.IdTownship = mun.IdTownship
				JOIN DeliveryBackOffice.dbo.Province dep
					on	mun.IdProvince = dep.IdProvince
					and dep.ProvinceStatus = 'TRUE'
				LEFT JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbh
					on mun.IdTownship = tbh.IdTownship
					and tbh.StatustownshipHub = 'TRUE'
					AND tbh.TownshipHubDefault = 'TRUE'
				LEFT JOIN DeliveryBackOffice.dbo.HubLogistics hub
					on tbh.IdHublogistic = hub.IdHubLogistic
				LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vpc
					on pob.IdSettlement = vpc.IdSettlement
			where pob.SettlementSatus = 'TRUE'
			and pob.IdSettlement = @IdDestiny



			
	END TRY  
	BEGIN CATCH  
		SELECT   Cast(ERROR_NUMBER() as nvarchar) AS ErrorNumber  
				,Cast(ERROR_SEVERITY() as nvarchar) AS ErrorSeverity  
				,Cast(ERROR_STATE() as nvarchar) AS ErrorState  
				,Cast(ERROR_PROCEDURE() as nvarchar) AS ErrorProcedure  
				,Cast(ERROR_LINE() as nvarchar) AS ErrorLine  
				,Cast(ERROR_MESSAGE() as nvarchar) AS ErrorMessage;
		ROLLBACK TRANSACTION;
	END CATCH;   

END
