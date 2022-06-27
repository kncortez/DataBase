
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-13>
-- Description:	<Devuelve la opcion y precio shipping>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_rate_estimate_by_hub_by_piece]
	-- Add the parameters for the stored procedure here
			@CodApp as nvarchar(50) = '' ,
		    @IdCustomer as int = 0, -- 6 express center
			@HeaderCodeDestiny as varchar(10)  = '',
			@HeaderCodeSource as varchar(10)  = '',
			@FechaCompra as datetime = '2020-08-03 11:51',
			@ProductWeight as decimal(18,2) = 12,
			@Country as nvarchar(2)   = 'GT',
			--fields complementaries optionals 
			@ObjectType as nvarchar(50)  = 'bateries | bateries | bateries |',
			@CountPieces as int = 3,
			@AmmountValue as decimal(18,2) = 195,
			@WeightValue as decimal(18,2) = 0,
			@Currency as NVARCHAR(3) = 'GTQ',
			@CodeCredit as nvarchar(10) = '0',
			@IsFragile as bit  = 'FALSE',
			@IsCollected as bit  = 'FALSE',
			@IsInsurance as bit  = 'FALSE',
			@WeigthParcels as nvarchar(300),
			@InsuranceAmount as decimal (18,2) =0,
			@IsCreditCardPayment as bit = 'false'
			,@Zone as int =0
			,@AddressParse as varchar(600)= ''
			,@IdSettlementDestiny as int =0

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	BEGIN TRY  
		declare @Time as time = convert(time,@FechaCompra)

		declare @CreditCardRate decimal(12,2) =  (SELECT top 1 isnull(ct.Value,15) FROM dbo.CatToCharge ct where ct.Name ='CreditCardRate') -- tarifa de recoleccion 

		print 'credit rate'
		print @CreditCardRate
-- declare @TimeLimitDate as time = '29:59:59'

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
	
		if @IdCustomer = 0 -- si el Id Customer es 0 lo obtiene con base al CodApp
			set @IdCustomer  = (select top 1 ec.IdCustomer from #Ecommrce ec where ec.EcommerceStatus = 'TRUE')

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


		
		DECLARE @IdRateSegment  int = 0
		declare @HubSource int =0
		declare @HubDestiny  int =0
		declare @TownshipSource int =0
		declare @TownshipDestiny int =0


		select twn.IdTownship 
			,twn.IdProvince
			,thb.IdHublogistic
			,thb.IdRateSegment
			into #HubSource
				from dbo.Township twn
		join dbo.TownshipByHubLogistic thb on thb.IdTownship = twn.IdTownship
		where twn.HeaderCode = @HeaderCodeSource and thb.StatusTownshipHub =1

		select  twn.IdTownship
			,twn.IdProvince
			,thb.IdHublogistic
			,thb.IdRateSegment
			into #HubDestiny
			from dbo.Township twn
		join dbo.TownshipByHubLogistic thb on thb.IdTownship = twn.IdTownship
		where twn.HeaderCode = @HeaderCodeDestiny and thb.StatusTownshipHub =1

		set @HubSource = (select top 1 IdHublogistic from #HubSource)
		set @HubDestiny = (select top 1 IdHublogistic from #HubDestiny)

		set @TownshipSource = (select top 1 IdTownship from #HubSource)
		set @TownshipDestiny = (select top 1 IdTownship from #HubDestiny)

		Declare @IVA as decimal(12,2)= (select top 1 (sur.PercentValue) from dbo.Surcharge sur where sur.IdSurcharge = 6) 

		-------------------------------Obtener descuento --------------------------------------------------------------------------

		declare @IdTypeCustomer int  =(select top 1 cus.IdCustomerType from dbo.Customer cus where cus.IdCustomer = @IdCustomer)

		select Top 1
		ss.Name as DicountName
		,ss.IsGlobal  as IsGlobla
		,sd.UnitId as IdUnit
		,sd.Value as Value
		, unt.Prefix as Unit
		, sd.TypeDiscountId  as idTypeDiscount
		,tyd.ShortName as TypeDiscount
		into #Dicounts
		from dbo.SpecialSale ss
			inner join dbo.SpecialSaleDetail sd on sd.SpecialSaleId = ss.IdSpecialSale and sd.RowStatus =1
			left join dbo.Unit unt on unt.IdUnit = sd.UnitId
			left join dbo.CatTypeDiscount tyd on tyd.IdCatTypeDiscount = sd.TypeDiscountId
			left join dbo.SpecialSaleTarget tgt on tgt.SpecialSaleId = ss.IdSpecialSale
		where 
		ss.RowStatus = 1  
		and getdate() between ss.StartDate and ss.FinishDate 
		and (ss.IsGlobal =  1  or tgt.CustomerId = @IdCustomer or tgt.CustomerTypeid = @IdTypeCustomer  ) 
		order by ss.Priority DESC

		declare @Value decimal (12,2)  =0

		declare @TypeDiscount varchar(20) = (select top 1 ds.TypeDiscount from #Dicounts ds)
		declare @DiscountName varchar(100) = (select top 1 ds.DicountName from #Dicounts ds)
		set @Value =(select top 1 isnull(ds.Value,0) from #Dicounts ds)
		declare @Unit varchar(10) = (select top 1 ds.Unit from #Dicounts ds)

		--------------------------------------.-------------------------------------------------------------------------------------

		------------------------- Determinar si el servico es TDA ------------------------------------------------------------------
		
		--DECLARE @Tsettlement table (IdSettlement bigint )
		Declare @IsTDA bit ='false'

		IF OBJECT_ID('tempdb.dbo.#ItemAddress', 'U') IS NOT NULL DROP TABLE #ItemAddress;
		IF OBJECT_ID('tempdb.dbo.#SettlementList', 'U') IS NOT NULL DROP TABLE #SettlementList;

			-- Quitar Departamento y Municipio de la direccion para tener un mejor resultado en la coincidencia
		set @AddressParse = ( select  REPLACE(REPLACE(isnull(@AddressParse,''), twn.TownshipName, ''), prv.ProvinceName,'') from  Township twn 
			left join Province prv on prv.IdProvince = twn.IdProvince
		where twn.HeaderCode = @HeaderCodeDestiny and twn.TownshipStatus ='true')


		DECLARE @IdSettlement bigint;
	if @IdSettlementDestiny=0  --  no se envio el id settlement desde front por lo tanto intenta determinarlo con base a la dirección
	begin
		-- separar en un arrglo la direccion 
		 
		select Item
		into #ItemAddress
		from DenariusDesktop_Dev.dbo.SplitUnlimited(@AddressParse,' ')


		if @Zone =0 -- si no trae zona verificar por direccion
		begin
			select TOP 1 ST.IdSettlement  , COUNT(ST.IdSettlement) AS mas_popular, ST.Settlement
			into #SettlementList
			from #ItemAddress i
				left join dbo.Township tw on tw.HeaderCode = @HeaderCodeDestiny
				left join dbo.Settlement st on st.IdTownship = tw.IdTownship and st.Settlement like concat('%', i.Item, '%')
			where len(i.Item)>3 and st.IdSettlement is not null
			GROUP BY ST.IdSettlement, ST.Settlement
			ORDER BY 2 DESC

			set @IdSettlement =(select top 1 IdSettlement from #SettlementList)


		end
		else
		begin
			set @IdSettlement = (select top 1 st.IdSettlement
			from dbo.Township tw
				left join dbo.Settlement st on st.IdTownship = tw.IdTownship
			where tw.HeaderCode = @HeaderCodeDestiny 
			and st.Settlement like concat('%Zona ', @Zone ,'%')
			order by IdSettlement )

		end

		if @IdSettlement is null
		begin 
			set @IdSettlement =  (select top 1 st.IdSettlement
			from dbo.Township tw
			left join dbo.Settlement st on st.IdTownship = tw.IdTownship
			where tw.HeaderCode = @HeaderCodeDestiny 
			order by IdSettlement)
		end
	end
	else
	begin
		set @IdSettlement = @IdSettlementDestiny
	end

	

	IF OBJECT_ID('tempdb.dbo.#ItemAddress', 'U') IS NOT NULL DROP TABLE #ItemAddress;
	IF OBJECT_ID('tempdb.dbo.#SettlementList', 'U') IS NOT NULL DROP TABLE #SettlementList;

	


		set @IsTDA = isnull( ( select top 1 iif(cov.TDA =0,'false','true') from dbo.DumpServiceCoverage cov
		where cov.IdSettlement =  @IdSettlement and cov.RowStatus = 1),'false')

		declare @IdRateGroup int = ( iif(@IsTDA ='false',1,(select top 1 RateGroup from dbo.CatTypeService  where CtsShortName = 'TDA' and CtsRowStatus = 1 )))
		
		--select @IdSettlement as settleme, @IsTDA as tda, @IdRateGroup as gurp
		--------------------------------------.-------------------------------------------------------------------------------------

		IF OBJECT_ID('tempdb.dbo.#Weights', 'U') IS NOT NULL DROP TABLE #Weights;

			select cast(Item as decimal(18,2)) as Item 
				into #Weights
				from DenariusDesktop_Dev.dbo.SplitUnlimited(@WeigthParcels,',')

		select 
			--cts.CtsShortName as ServiceShortName,
				cts.CtsName as Segment,
				cts.CtsDescription as Description,
			cts.CtsId as IdService,
				cts.CtsName  as ServiceName,
				cts.CtsShortName as ServiceShortName,
				(rdt.RbhRate * @CountPieces ) as Rate
				, iif(@IsFragile = 'true',
				(CASE
				WHEN 	rdt.RbhFragileRate > 1 THEN rdt.RbhFragileRate
				ELSE  round((rdt.RbhFragileRate * rdt.RbhRate),2)
				END),0) AS FragileRate,

				iif(@IsInsurance = 'true', iif(@InsuranceAmount > 800,
				(CASE
				WHEN 	rdt.RbhInsuranceRate > 1 THEN rdt.RbhInsuranceRate
				ELSE  round((rdt.RbhInsuranceRate *@InsuranceAmount ),2)
				END),0),0) AS InsuranceRate,

				iif(@IsCreditCardPayment = 'true', isnull( @CreditCardRate,0),0) AS CreditCardRate,

				iif(@IsCollected = 'true',
				(CASE
				WHEN 	rdt.RbhCollectedRate > 1 THEN (rdt.RbhCollectedRate * @CountPieces)
				ELSE  round((rdt.RbhCollectedRate * rdt.RbhRate * @CountPieces ),2)
				END),0) AS CollectedRate,rdt.RbhWeightLimit as limit,
				iif(@WeightValue> rdt.RbhWeightLimit,(@WeightValue - rdt.RbhWeightLimit) *  rdt.RbhWeightAdditionalRate ,0) as WeightAdditionalRate,
				iif(@WeightValue> rdt.RbhWeightLimit,(@WeightValue - rdt.RbhWeightLimit)  ,0) as WeightAdditional

				,(select (rdt.RbhRate* @CountPieces * sur.PercentValue /100 ) from dbo.Surcharge sur where sur.IdSurcharge = 6) as Taxes 
				,(select ( sur.PercentValue) from dbo.Surcharge sur where sur.IdSurcharge = 6)AS TaxPorcent, rdt.RbhCollectedRate,  @CountPieces as pieces, rdt.RbhWeightAdditionalRate as AditionalRate
			--	, convert(datetime, @Time, 108)  as hora  , isnull(convert(datetime, shu.SbhCollectionTimeLimit, 108) ,convert(datetime, '23:59:59', 108)) as LimitTime

			,isnull(iif(@TypeDiscount = 'BSD',  
					iif( @Unit ='Pct',
							(rdt.RbhRate * @CountPieces ) * @Value /100  
						,@Value)
				, iif( @Unit ='Pct',
							(rdt.RbhRate * @CountPieces ) * @Value /100  
						,@Value) ),0) as discount


			 into #GeneralRate
				from dbo.RatebyCustomer rbc
				 join dbo.RateByHub rdt on rdt.RbhIdRate   = rbc.RbcIdRate
				join dbo.CatTypeService cts on cts.CtsId = rdt.RbhIdTypeService
				
			where rdt.RbhIdHubSource = @HubSource 
			and rdt.RbhIdHubDestiny = @HubDestiny 
			and  rbc.RbcIdCustomer = @IdCustomer  
			and rdt.RbhRowStatus = 1 -- tarifa activa
			and rbc.RbcRowStatus =1 -- asignacion activa
			and  (rdt.RbhIdTypeService in(select CtsId from dbo.CatTypeService  where RateGroup = @IdRateGroup and CtsRowStatus = 1) )

		--	select CtsId from dbo.CatTypeService  where RateGroup = @IdRateGroup and CtsRowStatus = 1
		--	select @HubSource as hus, @HubDestiny as hud ,@IdCustomer as cust, @IdRateGroup as gyro
			select Idservice, sum(iif((item- limit)>0,(item- limit),0)) as exceso 
			into #Exceso 
			from #GeneralRate
			left join #Weights on 1=1
			group by IdService

		--	select * from #GeneralRate


		BEGIN TRANSACTION;
			
			declare @IdRateEstimated as bigint = -1;

		

			--se verifica que no exista la cotizacion para esa fecha, origen, destino, precio, piezas y monto total
			set @IdRateEstimated = isnull((select top 1 cotzn.IdRateEstimated 
									from [DeliveryBackOffice].[dbo].[RateEstimate] cotzn
									where cotzn.IdEcommerce = @IdEcommerce
									and cotzn.IdTownshipSource = @TownshipSource
									and cotzn.IdTownshipDestiny = @TownshipDestiny
									and cotzn.CountPieces = @CountPieces
									and cotzn.UnitValue = @ProductWeight
									--and cotzn.IdUnit =  4-- lbs
									and cotzn.EcomValueAmmount = @AmmountValue
									and cotzn.EcomValueCurrency = @Currency
									--and cotzn.BaseRate = (select valgnrlrate.PriceRate from #GeneralDataRate valgnrlrate)
									and cotzn.EstimateTotalAmount =0
									and DATEDIFF(day, Cast(cotzn.DateCreated as date), cast(getdate() as date)) <= 31 --la cotizacion este vigente en 31 dias
									order by cotzn.IdRateEstimated desc
								   ),0)			

			print @IdRateEstimated 

			----se procede a registrar cotizacion
			if (@IdRateEstimated <= 0)
			begin 
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
						   ,IdTownshipSource
						   ,IdTownshipDestiny
						   )
				select 	null						[IdSource], 
						null					[IdDestiny],
						@ObjectType						[ObjectType],
						@CountPieces					[CountPieces],
						@ProductWeight		[ProductWeight], 
						4				[IdUnit], --4:lbs
						@CodeCredit						[CodeCredit],
						null				[IdRate],
						HeaderRate.Rate			[BaseRate],
						(HeaderRate.Rate +HeaderRate.FragileRate + HeaderRate.InsuranceRate + HeaderRate.CollectedRate + HeaderRate.WeightAdditionalRate)				[EstimateTotalAmount],
						@IdCustomer			[IdCustomer],
						@IdEcommerce			[IdEcommerce],
						GETDATE()        				[DateService],
						'TRUE'							[EstimatedStatus],
						CONCAT('SYS-', @CodApp,'DEVFORZADL')					[TokenCreated],
						GETDATE()						[DateCreated],
						NULL							[TokenUpdated],
						NULL							[DateUpdated],
						@FechaCompra					[DateEcommerceSale],   --when product sale in checkout ecommerce website
						@FechaCompra	[DateEcommercePickUp], -- when will the picking up in warehouse ecommerce be made
						DATEADD(DAY,1,@FechaCompra)	[DateCarrierDelivery], -- when will the delivery be made
						cur.IdCurrency			[IdCurrency],
						 @Country			[IdCountry],
						HeaderRate.IdService		[IdRateCategory],
						HeaderRate.ServiceName	[RatePlanDescription],
						@AmmountValue					[EcomValueAmmount],  --monto total valor producto
						cur.CurrencyISO4217				[Currency],    --moneda local pais
						cur.ExchangeRate				[ExchangeRate], --tasa cambio a dolares
						@TownshipSource		[IdTownshipSource],
						@TownshipDestiny		[IdTownshipDestiny]
				from #GeneralRate HeaderRate
				left join #MonCurrency cur 
						on cur.CurrencyISO4217 = @Currency
				where @Country= cur.CurrencyCountry
 
				select @IdRateEstimated  = SCOPE_IDENTITY();
			
				print '@IdRateEstimated'
				print @IdRateEstimated  
			
				--Detalle
				if (@IdRateEstimated > 0)
				begin
						print 'se crea valor'
						declare @EcommUser as nvarchar(50) = 'SYS-ECOFORZADL';
						declare @IdRateCategory  as int = 2;
		
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
										null						[IdSettlment],			--<IdSettlment, bigint,>
										DetailRate.WeightAdditional			[CountValue],			--<CountValue, decimal(18,2),>
										NULL			[IdSurcharge],			--<IdSurcharge, int,>
										'TARIFA BASE'	[SurchargeDescription], --<SurchargeDescription, nvarchar(50),>
										DetailRate.Rate					[PriceRate],			--<PriceRate, decimal(18,2),>
										0			[PercentValue],			--<PercentValue, decimal(18,2),>
										DetailRate.Rate					[TotalAmount],			--<TotalAmount, decimal(18,2),>
										DetailRate.IdService					[IdRateCategory],		--<IdRateCategory, int,>
										1					[Selected],				--<Selected, bit,>
										DATEADD(DAY, 31, GETDATE())			[DateExpire],			--<DateExpire, datetime,>
										'TRUE'								[EstimateDetailStatus], --<EstimateDetailStatus, bit,>
										CONCAT('SYS-',
										(ISNULL(@CodApp,'DEVFORZADL')))	[TokenCreated],			--<TokenCreated, nvarchar(50),>
										GETDATE()							[DateCreated],			--<DateCreated, datetime,>
										NULL								[TokenUpdated],			--<TokenUpdated, nvarchar(50),>
										NULL								[DateUpdated]			--<DateUpdated, datetime,>

								from #GeneralRate DetailRate where DetailRate.Rate>0
								union
								select @IdRateEstimated						[IdRateEstimate],		--<IdRateEstimate, bigint,>
										null						[IdSettlment],			--<IdSettlment, bigint,>
										DetailRate.WeightAdditional			[CountValue],			--<CountValue, decimal(18,2),>
										NULL			[IdSurcharge],			--<IdSurcharge, int,>
										'IVA'	[SurchargeDescription], --<SurchargeDescription, nvarchar(50),>
										DetailRate.Rate					[PriceRate],			--<PriceRate, decimal(18,2),>
										0			[PercentValue],			--<PercentValue, decimal(18,2),>
										DetailRate.Taxes					[TotalAmount],			--<TotalAmount, decimal(18,2),>
										DetailRate.IdService					[IdRateCategory],		--<IdRateCategory, int,>
										1					[Selected],				--<Selected, bit,>
										DATEADD(DAY, 31, GETDATE())			[DateExpire],			--<DateExpire, datetime,>
										'TRUE'								[EstimateDetailStatus], --<EstimateDetailStatus, bit,>
										CONCAT('SYS-',
										(ISNULL(@CodApp,'DEVFORZADL')))	[TokenCreated],			--<TokenCreated, nvarchar(50),>
										GETDATE()							[DateCreated],			--<DateCreated, datetime,>
										NULL								[TokenUpdated],			--<TokenUpdated, nvarchar(50),>
										NULL								[DateUpdated]			--<DateUpdated, datetime,>

								from #GeneralRate DetailRate where DetailRate.Taxes>0
								UNION
								select @IdRateEstimated						[IdRateEstimate],		--<IdRateEstimate, bigint,>
										null						[IdSettlment],			--<IdSettlment, bigint,>
										DetailRate.WeightAdditional			[CountValue],			--<CountValue, decimal(18,2),>
										NULL			[IdSurcharge],			--<IdSurcharge, int,>
										'FRAGIL'	[SurchargeDescription], --<SurchargeDescription, nvarchar(50),>
										DetailRate.Rate					[PriceRate],			--<PriceRate, decimal(18,2),>
										0			[PercentValue],			--<PercentValue, decimal(18,2),>
										DetailRate.FragileRate					[TotalAmount],			--<TotalAmount, decimal(18,2),>
										DetailRate.IdService					[IdRateCategory],		--<IdRateCategory, int,>
										1					[Selected],				--<Selected, bit,>
										DATEADD(DAY, 31, GETDATE())			[DateExpire],			--<DateExpire, datetime,>
										'TRUE'								[EstimateDetailStatus], --<EstimateDetailStatus, bit,>
										CONCAT('SYS-',
										(ISNULL(@CodApp,'DEVFORZADL')))	[TokenCreated],			--<TokenCreated, nvarchar(50),>
										GETDATE()							[DateCreated],			--<DateCreated, datetime,>
										NULL								[TokenUpdated],			--<TokenUpdated, nvarchar(50),>
										NULL								[DateUpdated]			--<DateUpdated, datetime,>

								from #GeneralRate DetailRate where DetailRate.FragileRate>0
								UNION
								select @IdRateEstimated						[IdRateEstimate],		--<IdRateEstimate, bigint,>
										null						[IdSettlment],			--<IdSettlment, bigint,>
										DetailRate.WeightAdditional			[CountValue],			--<CountValue, decimal(18,2),>
										NULL			[IdSurcharge],			--<IdSurcharge, int,>
										'SOBRECARGO PESO'	[SurchargeDescription], --<SurchargeDescription, nvarchar(50),>
										DetailRate.Rate					[PriceRate],			--<PriceRate, decimal(18,2),>
										0			[PercentValue],			--<PercentValue, decimal(18,2),>
										DetailRate.WeightAdditionalRate					[TotalAmount],			--<TotalAmount, decimal(18,2),>
										DetailRate.IdService					[IdRateCategory],		--<IdRateCategory, int,>
										1					[Selected],				--<Selected, bit,>
										DATEADD(DAY, 31, GETDATE())			[DateExpire],			--<DateExpire, datetime,>
										'TRUE'								[EstimateDetailStatus], --<EstimateDetailStatus, bit,>
										CONCAT('SYS-',
										(ISNULL(@CodApp,'DEVFORZADL')))	[TokenCreated],			--<TokenCreated, nvarchar(50),>
										GETDATE()							[DateCreated],			--<DateCreated, datetime,>
										NULL								[TokenUpdated],			--<TokenUpdated, nvarchar(50),>
										NULL								[DateUpdated]			--<DateUpdated, datetime,>

								from #GeneralRate DetailRate where DetailRate.WeightAdditionalRate>0
								UNION
								select @IdRateEstimated						[IdRateEstimate],		--<IdRateEstimate, bigint,>
										null						[IdSettlment],			--<IdSettlment, bigint,>
										DetailRate.WeightAdditional			[CountValue],			--<CountValue, decimal(18,2),>
										NULL			[IdSurcharge],			--<IdSurcharge, int,>
										'COMISION PAGO EN DESTINO'	[SurchargeDescription], --<SurchargeDescription, nvarchar(50),>
										DetailRate.Rate					[PriceRate],			--<PriceRate, decimal(18,2),>
										0			[PercentValue],			--<PercentValue, decimal(18,2),>
										DetailRate.CollectedRate					[TotalAmount],			--<TotalAmount, decimal(18,2),>
										DetailRate.IdService					[IdRateCategory],		--<IdRateCategory, int,>
										1					[Selected],				--<Selected, bit,>
										DATEADD(DAY, 31, GETDATE())			[DateExpire],			--<DateExpire, datetime,>
										'TRUE'								[EstimateDetailStatus], --<EstimateDetailStatus, bit,>
										CONCAT('SYS-',
										(ISNULL(@CodApp,'DEVFORZADL')))	[TokenCreated],			--<TokenCreated, nvarchar(50),>
										GETDATE()							[DateCreated],			--<DateCreated, datetime,>
										NULL								[TokenUpdated],			--<TokenUpdated, nvarchar(50),>
										NULL								[DateUpdated]			--<DateUpdated, datetime,>
								from #GeneralRate DetailRate where DetailRate.CollectedRate>0


								


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
			print 'se guardo la transaccion'
		
		    declare @jsonResult as nvarchar(max)

		 set @jsonResult =( SELECT STUFF(( 
					select 
					',{"Title":"' + grate.Segment  + '",' +
					'"Service":"' + grate.ServiceName + '",' +
					'"ServiceDescription":"' + grate.Description + '",' +
					'"ServiceShortName":"' + grate.ServiceShortName + '",' +
						'"DeliveryDate":"' + Convert(varchar(24),@FechaCompra,120) + '",' +
						'"Price":"' + convert(varchar(20), convert(decimal(12,2), (grate.Rate +grate.FragileRate - grate.discount + grate.InsuranceRate + grate.CollectedRate +grate.CreditCardRate+ (grate.AditionalRate * ex.exceso)))) + '",' +
						'"Currency":"' + @Currency + '",' +
						'"Integration":[{"Description":"' + 'Servicio' + '",' +
						'"Price":"' +convert(varchar(20),  CONVERT(decimal(12,2),  grate.Rate /(1+(grate.TaxPorcent/100)))) + '",' +
						'"Currency":"' + @Currency + '"' +
						'}'+
						 iif(grate.FragileRate>0, ',{"Description":"' + 'Frágil' + '",' + 
						'"Price":"' +convert(varchar(20), convert(decimal(12,2),  grate.FragileRate/(1+(grate.TaxPorcent/100)))) + '",' +
						'"Currency":"' + @Currency + '"' +
						'}' ,' '  ) +
						 iif(grate.InsuranceRate>0, ',{"Description":"' + 'Seguro' + '",' + 
						'"Price":"' +convert(varchar(20), convert(decimal(12,2), grate.InsuranceRate/(1+(grate.TaxPorcent/100)))) + '",' +
						'"Currency":"' + @Currency + '"' +
						'}' ,' '  ) +
						 iif(grate.CollectedRate>0, ',{"Description":"' + 'Pago en Destino' + '",' + 
						'"Price":"' +convert(varchar(20), convert(decimal(12,2), grate.CollectedRate/(1+(grate.TaxPorcent/100)))) + '",' +
						'"Currency":"' + @Currency + '"' +
						'}' ,' '  ) +
						 iif((grate.AditionalRate * ex.exceso)>0, ',{"Description":"' + 'Recargo por Peso' + '",' + 
						'"Price":"' +convert(varchar(20), convert(decimal(12,2), (grate.AditionalRate * ex.exceso)/(1+(grate.TaxPorcent/100)))) + '",' +
						'"Currency":"' + @Currency + '"' +
						'}' ,' '  ) +
						iif((grate.CreditCardRate)>0, ',{"Description":"' + 'Recargo por pago con tarjeta' + '",' + 
						'"Price":"' + convert(varchar(20), CAST((grate.CreditCardRate /(1+(grate.TaxPorcent/100))  ) AS decimal(18, 2)) ) + '",' +
						'"Currency":"' + COALESCE(@Currency,'') + '"' +
						'}' ,' '  ) +


						iif((isnull(@Value,0))>0, 
							',{"Description":"' + isnull(@DiscountName,'') + '",' + 
							'"Price":"' + CONVERT(varchar, CAST(( isnull(grate.discount,0) *-1 /(1+(grate.TaxPorcent/100))  ) AS decimal(18, 2)) ) + '",'  +
							'"Currency":"' + COALESCE(@Currency,'') + '"' +
							'}' 
						,' '  ) +

						',{"Description":"' + 'IVA' + '",' +
						'"Price":"' +convert(varchar(20), convert(decimal(12,2), (((grate.Rate +grate.FragileRate - grate.discount +  grate.InsuranceRate + grate.CollectedRate + (grate.AditionalRate * ex.exceso) + grate.CreditCardRate)/(1+(grate.TaxPorcent/100))) * (grate.TaxPorcent/100))) ) + '",' +
						'"Currency":"' + @Currency + '"' +
						'}'+
						' ]}' 
						from #GeneralRate grate
						left join #Exceso ex on ex.IdService =  grate.IdService
						order by grate.Segment asc
			--	where us.UsrEmail = @UserName and us.UsrRowStatus = 1 
				FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'),1,1,''
						) )

					--	select * from #GeneralRate grate

	print @jsonResult

						select '[' + @jsonResult + ']'

			
			
	END TRY  
	BEGIN CATCH  
		SELECT   Cast(ERROR_NUMBER() as nvarchar) AS ErrorNumber  
				,Cast(ERROR_SEVERITY() as nvarchar) AS ErrorSeverity  
				,Cast(ERROR_STATE() as nvarchar) AS ErrorState  
				,Cast(ERROR_PROCEDURE() as nvarchar) AS ErrorProcedure  
				,Cast(ERROR_LINE() as nvarchar) AS ErrorLine  
				,Cast(ERROR_MESSAGE() as nvarchar) AS ErrorMessage;
		if @@trancount > 0
			ROLLBACK TRANSACTION;
	END CATCH;   
			
			IF OBJECT_ID('tempdb.dbo.#Ecommrce', 'U') IS NOT NULL DROP TABLE #Ecommrce;
			IF OBJECT_ID('tempdb.dbo.#HubSource', 'U') IS NOT NULL DROP TABLE #HubSource;
			IF OBJECT_ID('tempdb.dbo.#MonCurrency', 'U') IS NOT NULL DROP TABLE #MonCurrency;
			IF OBJECT_ID('tempdb.dbo.#HubDestiny', 'U') IS NOT NULL DROP TABLE #HubDestiny;
			IF OBJECT_ID('tempdb.dbo.#GeneralRate', 'U') IS NOT NULL DROP TABLE #GeneralRate;
			IF OBJECT_ID('tempdb.dbo.#Dicounts', 'U') IS NOT NULL DROP TABLE #Dicounts;


END