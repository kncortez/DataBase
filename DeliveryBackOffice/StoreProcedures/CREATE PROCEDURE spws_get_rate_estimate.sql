-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-08-05>
-- Description:	<Devuelve la opcion y precio shipping>
-- =============================================
CREATE PROCEDURE spws_get_rate_estimate
	-- Add the parameters for the stored procedure here
		    @IdEcommerce as int = 2,
			@IdDestiny as bigint  = 1454,
			@FechaCompra as datetime = '2020-08-02 11:43',
			@ProductWeight as int = 56,
			--fields complementaries optionals 
			@IdSource as int = 518, --zona 12 Guatemala
			@ObjectType as nvarchar(50)  = 'ANYTHING',
			@CountPieces as int = 1,
			@UnitValue as decimal(5,2) = 1,
			@Currency as NVARCHAR(3) = 'GTQ',
			@Country as nvarchar(2)   = 'GT',
			@CodeCredit as nvarchar(10) = '0',
			@IsFragil as bit  = 'FALSE'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdSettlement AS BIGINT = -1

	SET @IdSettlement = @IdDestiny;

    -- Insert statements for procedure here
	
	--select @FechaCompra [@FechaCompra], @ProductWeight [@ProductWeight], @IdSettlement [@IdSettlement]

	--Obtiene datos de la moneda enviada
	select webcurr.CUR_IdCurrency     [IdCurrency],
			deskcurr.CUR_ExchangeRate [ExchangeRate],
			deskcurr.CUR_Name		  [CurrencyName],
			webcurr.CUR_ISO4217Code   [CurrencyISO4217],
			deskcurr.CUR_Symbol		  [CurrencySymbol],
			deskcurr.CUR_Country	  [CurrencyCountry]
	INTO #MonCurrency
	from DenariusWeb_Dev.dbo.currency webcurr
	join DenariusDesktop_Dev.dbo.PRM_Currency deskcurr
			on webcurr.CUR_IdCurrency = deskcurr.CUR_IdCurrency
	where webcurr.CUR_ISO4217Code = @Currency
	and deskcurr.CUR_Country = @Country


		--SELECT sett.IdSettlement, sett.Settlement FROM DeliveryBackOffice.DBO.Settlement sett
		--WHERE sett.IdCountry = 'GT'
		--AND sett.Settlement like '%ZONA 12%'
		--AND sett.SettlementSatus = 'TRUE'
		----AND sett.IdSettlement = 1454

	--Identifico el rango de peso del producto
	DECLARE @IdDimensional as int 
	SELECT  @IdDimensional = dim.IdDimensional FROM DeliveryBackOffice.dbo.DimensionalParameter dim WITH (NOLOCK)
	where dim.IdCountry = 'GT'
	and dim.DimensionalStatus = 'TRUE'
	AND dim.ByUnity = 'FALSE'
	and dim.ByRange = 'TRUE'
	and dim.IdUnit = 4 --LBS
	and (@ProductWeight >= dim.MinimunValue and @ProductWeight <= dim.MaximunValue )


	SELECT sett.IdSettlement, 
		   sett.IsSpecial,  
		   schedsett.IdSegmentArea, 
		   schedsett.ScheduledVisitSunday,
		   schedsett.ScheduledVisitMonday ,
		   schedsett.ScheduledVisitTuesday ,
		   schedsett.ScheduledVisitWednesday, 
		   schedsett.ScheduledVisitThursday ,
		   schedsett.ScheduledVisitFriday ,
		   schedsett.ScheduledVisitSaturday 
		   INTO #ScheduleDestiny
	FROM DeliveryBackOffice.DBO.Settlement sett with(nolock) JOIN
	DeliveryBackOffice.DBO.ScheduledVisitSettlement schedsett WITH(NOLOCK) on sett.IdSettlement = schedsett.IdSettlement
	WHERE sett.IdSettlement = @IdSettlement
	and schedsett.SettScheduleVisitStatus = 'TRUE'

	--que dia de la semana fue la compra
	declare @DayEcomCheckOut as int
	set @DayEcomCheckOut  = (select DATEPART(weekday, @FechaCompra))

	declare @DayEcomPU as int  --hay que asumir que vamos todos los dias, excepto domingo 1. WeekDay
	set @DayEcomPU  = (select DATEPART(weekday, DATEADD(DAY,1,@FechaCompra)))

	PRINT '@DayEcomPU'
	PRINT @DayEcomPU 
	PRINT '@DayEcomCheckOut'
	PRINT @DayEcomCheckOut 


	Declare @DayString varchar(50)=''
	select @DayString = CONCAT('1-',ScheduledVisitSunday ,  ',' 
							 , '2-',ScheduledVisitMonday ,  ',' 
							 , '3-',ScheduledVisitTuesday , ',' 
							 , '4-',ScheduledVisitWednesday, ',' 
							 , '5-',ScheduledVisitThursday , ',' 
							 , '6-',ScheduledVisitFriday , ',' 
							 , '7-',ScheduledVisitSaturday)
	from #ScheduleDestiny DLDay

	declare @Week table(_Day tinyint, _Valid bit)

	insert into @Week 
	select  cast(LEFT(d.Item ,1) as tinyint)_WEEKDAY,
			cast(RIGHT(d.Item ,1)as bit) _VALID  
	from DenariusDesktop_Dev.dbo.split(@DayString) d

	DECLARE @DAYS INT= 0

	--next day after PU
	select @DAYS=isnull((select top 1 w._Day from @week w 
						  where _Valid='TRUE'and w._Day > @DayEcomPU order by 1 asc)
				,isnull((select top 1 (case when w._Day = @DayEcomPU then 8 else w._Day end)from @week w 
						where _Valid='TRUE'order by 1 asc),8))

	--select * from #ScheduleDestiny destino

	SELECT @IdEcommerce IdEcommerce,
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
		   DATEADD(DAY,1,@FechaCompra) DATE_PICKUP, 
		   DATEADD(DAY,@DAYS-1,@FechaCompra) DATE_DELIVERY,
		   rate.IdCurrency,
		   rate.IdCountry,
		   rate.IdRateCategory,
		   category.TitleName [RateTitlePlan],
		   rate.DateFromValid,
		   rate.DateExpired
		   INTO #EstimateRate
	FROM [dbo].[FlateRate] rate										with(nolock)
	JOIN DeliveryBackOffice.dbo.SegmentArea area					with(nolock) 
							on rate.IdSegmentArea = area.IdSegmentArea
	LEFT JOIN DeliveryBackOffice.DBO.DimensionalParameter params	with(nolock) 
							on rate.IdDimensional = params.IdDimensional
	LEFT JOIN DeliveryBackOffice.DBO.RateCategory category			with(nolock) 
							on category.IdRateCategory  = rate.IdRateCategory
							and category.RateCatStatus= 'TRUE'
	WHERE rate.FlatRateStatus = 'TRUE'
	AND rate.IdDimensional = @IdDimensional
	AND rate.IdSegmentArea = ( select destino.IdSegmentArea from #ScheduleDestiny destino )

	SELECT  RateEst.IdEcommerce			[IdEcommerce],	
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
			RateEst.DATE_SALE			[DateEcommerceSale], --whe
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
			ecomm.IdCustomer			[IdCustomer]
			INTO #GeneralDataRate
	  FROM #EstimateRate RateEst JOIN 
		   #ScheduleDestiny Dest 
							ON RateEst.IdSettlement = Dest.IdSettlement
			LEFT JOIN DeliveryBackOffice.[dbo].[Ecommerce] ecomm 
							ON	RateEst.IdEcommerce = ecomm.IdEcommerce
								AND ecomm.EcommerceStatus = 'TRUE'
	   WHERE RateEst.IdEcommerce = @IdEcommerce
	   ORDER BY ecomm.IdEcommerce DESC 

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
		select  NULL							[IdSurcharge],
				'TARIFA BASE'					[SurchargeDescription],
				1								[Quantity],
				gnrl.PriceRate					[Price],
			    0								[PercentVal],
				(1 * gnrl.PriceRate) * (1 + 0)	[Total],
				Cast('TRUE' as bit)				[Apply]
		 from #GeneralDataRate gnrl
		 --tarifa base
		 UNION
		 select secure.IdSurcharge				[IdSurcharge],
				secure.SurchargeName			[SurchargeDescription],
				1								[Quantity],
				gnrl.PriceRate					[Price],
			    (case when (select (@UnitValue / cur.ExchangeRate) from #MonCurrency cur ) >= 100 --cien dolares
				      then (secure.PercentValue)
					    else (0)
				    end )						[PercentVal],
				
				(case when (select (@UnitValue / cur.ExchangeRate) 
						    from #MonCurrency cur ) >= 100
					  then 
							(((1 * gnrl.PriceRate) * 
							  (case when (select (@UnitValue / cur.ExchangeRate) 
										 from #MonCurrency cur ) >= 100 --cien dolares
									then (1 + (secure.PercentValue/100))
									else (0)
								end)) - gnrl.PriceRate)
					 else  0
				end)							[Total],
				cast((case when 
					       (select (@UnitValue / cur.ExchangeRate) 
						    from #MonCurrency cur ) >= 100 --cien dolares
					 then  'TRUE'
					 else  'FALSE'
				end) as bit)					[Apply]
		 from #GeneralDataRate gnrl , 							
		      DeliveryBackOffice.dbo.Surcharge secure
		 WHERE IdSurcharge = 1 --ASEGURADO
		 --Monto Asegurado
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
		 --Especial
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
		 --Es fragil o cuidado especial
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

		 BEGIN TRANSACTION;
	DECLARE @IdRateEstimated as bigint = -1;
	DECLARE @TotalShipping as decimal (18,2) = 0;

	SET @TotalShipping = (select sum(DtlCost.Total) from #CostDetail DtlCost where DtlCost.Applica = 'TRUE');
	 --DESCUENTOS
	 --SELECT * FROM DeliveryBackOffice.dbo.SpecialDiscount

--Maestro
	INSERT INTO [dbo].[RateEstimate]
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
           ,[RatePlanDescription])
	select 	@IdSource						[IdSource], 
	        @IdSettlement					[IdDestiny],
			@ObjectType						[ObjectType],
            @CountPieces					[CountPieces],
            @UnitValue						[UnitValue], 
			HeaderRate.IdUnit				[IdUnit],
			@CodeCredit						[CodeCredit],
            HeaderRate.IdRate				[IdRate],
			HeaderRate.PriceRate			[BaseRate],
		    @TotalShipping					[EstimateTotalAmount],
			HeaderRate.IdEcommerce			[IdEcommerce],
            HeaderRate.IdCustomer			[IdCustomer],
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
			HeaderRate.RatePlanDescription	[RatePlanDescription]
	from #GeneralDataRate HeaderRate
 
	select @IdRateEstimated  = SCOPE_IDENTITY();
	if (@IdRateEstimated > 0)
	begin
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
					   DetailRate.[IdSurcharge]				[IdSurcharge],			--<IdSurcharge, int,>
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
					   NULL									[TokenUpdated],			--<TokenUpdated, nvarchar(50),>
					   NULL									[DateUpdated]			--<DateUpdated, datetime,>
				from #CostDetail DetailRate
				where DetailRate.[Applica] = 'TRUE'

			COMMIT TRANSACTION;
	END
	ELSE
	BEGIN
			ROLLBACK TRANSACTION; 
	END

	   drop table if exists #MonCurrency
	   drop table if exists #ScheduleDestiny
       drop table if exists #EstimateRate
	   drop table if exists #GeneralDataRate
	   drop table if exists #CostDetail
	
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
			hdrctz.[RatePlanDescription]
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


END
GO
