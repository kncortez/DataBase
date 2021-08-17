USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_get_delivery_rate]    Script Date: 11/08/2021 11:01:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-04-28>
-- Description:	<Devuelve la opcion y precio shipping>
-- =============================================
ALTER PROCEDURE [dbo].[spws_get_delivery_rate]

@CodApp as nvarchar(50) = '' ,
@IdCustomerParams as int = 0, 
@HeaderCodeDestiny as varchar(10)  = '',
@HeaderCodeSource as varchar(10)  = '',
@Country as nvarchar(2)   = 'GT',
@CountPiecesParams as int = 1,
@IsFragile as bit  = 'FALSE',
@IsCollected as bit  = 'FALSE',
@IsInsurance as bit  = 'FALSE',
@WeigthParcels as nvarchar(MAX) ='0',
@InsuranceAmount as decimal (18,2) =0,
@IsCreditCardPayment as bit = 'false'
,@ParcelCode as nvarchar(max) = '0'
,@Zone as int =0
,@AddressParse as nvarchar(600)= ''
,@IdSettlementSource as int =0
,@IdSettlementDestiny as int =0
,@CodeOfReferenceSource as int =0
,@CodeOfReferenceDestiny as int =0
,@IdSalePipeLine as int=0
,@FormatResponse as nvarchar(10) ='DataTable'
,@CalculateTaxes bit = 'false'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdCustomer as int =0

	DECLARE  @FechaCompra AS DATETIME = GETDATE()
	declare @Time as time = convert(time,@FechaCompra)

------- determinar el cliente -----------------------------------------------------------------------------------------------
	If @IdCustomerParams <=0 -- si el id de client no viene en los parametros determinar via CODAPP
		begin
			set @IdCustomer =	(select  top 1 eco.IdCustomer
				from DeliveryBackOffice.[dbo].[Ecommerce] eco 
				where eco.UserKey = @CodApp --'SIFDCECOM300720201459'
				and eco.IdCountry = @Country
				and eco.EcommerceStatus = 'TRUE')
		end
	else
		begin
			set @IdCustomer = @IdCustomerParams
		end
------- fin determinar cliente ------------------------------------------------------------------------------------------------

------- determinar el Tarifario y tipo de tarifario que se va a aplicar -------------------------------------------------------

	DECLARE @IdRate as int
	DECLARE @IdTypeRate as int
	DECLARE @WeigthLimit as decimal(12,2) =0
	DECLARE @Currency AS varchar(10) = ''
	
	select @IdRate= RC.RbcIdRate
	,@IdTypeRate= RH.RateTypeId
	,@WeigthLimit = rh.WeightLimit
	,@Currency = dc.Currency_Symbol
	from dbo.RatebyCustomer rc
		left join dbo.RateHeader rh on rh.RheId = rc.RbcIdRate and rh.RheRowStatus ='true'
		left join dbo.DeliveryCurrency dc on dc.Currency_Id = rh.CurrencyId
	where rc.RbcIdCustomer = @IdCustomer
	and rc.RbcRowStatus = 'true'

	if @IdRate is null -- si el cliente no tiene una tarifa asociada determinar por canal de venta
	begin
		select  @IdRate= rh.RheId
		,@IdTypeRate= RH.RateTypeId
		,@WeigthLimit = rh.WeightLimit
		,@Currency = dc.Currency_Symbol
		from dbo.RateBySalePipeLine sp
			left join dbo.RateHeader rh on rh.RheId = sp.RateId and rh.RheRowStatus ='true'
			left join dbo.DeliveryCurrency dc on dc.Currency_Id = rh.CurrencyId
		where sp.RowStatus = 'true'
		and sp.SalePipeLineId = @IdSalePipeLine
		
	end
	
	if @IdRate is null -- si no se encuentra por canal de venta se determina por el valor default 
		begin
			select  @IdRate= rh.RheId
			,@IdTypeRate= RH.RateTypeId
			,@WeigthLimit = rh.WeightLimit
			,@Currency = dc.Currency_Symbol
			from dbo.RateHeader rh
				left join dbo.DeliveryCurrency dc on dc.Currency_Id = rh.CurrencyId
			where rh.RheRowStatus = 'true' 
			and rh.RheDefault ='true'
		end

-------- Fin determinar tarifa que se va usar ---------------------------------------------------------------------

------------------------- Determinar si el servico es TDA ------------------------------------------------------------------
		
	--DECLARE @Tsettlement table (IdSettlement bigint )
	Declare @IsTDA bit ='false'
	Declare @IsSDD bit ='false'

	IF OBJECT_ID('tempdb.dbo.#ItemAddress', 'U') IS NOT NULL DROP TABLE #ItemAddress;
	IF OBJECT_ID('tempdb.dbo.#SettlementList', 'U') IS NOT NULL DROP TABLE #SettlementList;

	PRINT 'TEST 1'
	-- Quitar Departamento y Municipio de la direccion para tener un mejor resultado en la coincidencia
	set @AddressParse = ( select REPLACE(REPLACE(REPLACE(REPLACE(@AddressParse, '&', 'y'),'&Quot;',''), twn.TownshipName, ''), prv.ProvinceName,'') from  Township twn 
		left join Province prv on prv.IdProvince = twn.IdProvince
	where twn.HeaderCode = @HeaderCodeDestiny AND twn.TownshipStatus ='true')

	PRINT 'TEST 2'

	DECLARE @IdSettlement bigint;

	PRINT '@IdSettlementDestiny'
	PRINT @IdSettlementDestiny

	if @IdSettlementDestiny<=0  --  no se envio el id settlement desde front por lo tanto intenta determinarlo con base a la dirección
	BEGIN
		PRINT 'entra @IdSettlementDestiny<=0'
		PRINT '@AddressParse'
		PRINT @AddressParse

		-- separar en un arrglo la direccion 
		select Item
		into #ItemAddress
		from DeliveryBackOffice.dbo.SplitUnlimited(@AddressParse,' ')

		PRINT 'FIN DE PARSERO DE DIRECCEION'
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
		begin  -- si trae zona verificar por zona 
			set @IdSettlement = (select top 1 st.IdSettlement
			from dbo.Township tw
				left join dbo.Settlement st on st.IdTownship = tw.IdTownship
			where tw.HeaderCode = @HeaderCodeDestiny 
			and st.Settlement like concat('%Zona ', @Zone ,'%')
			order by IdSettlement )

		end
		PRINT 'FIN IF DE LA ZONA'
		if @IdSettlement is null -- si no se puede identificar el settlement trae el primero del municipio proporcionado
		begin 
			set @IdSettlement =  (select top 1 st.IdSettlement
			from dbo.Township tw
			left join dbo.Settlement st on st.IdTownship = tw.IdTownship
			where tw.HeaderCode = @HeaderCodeDestiny 
			order by IdSettlement)
		END
        
		PRINT 'FIN DEL IF DEL SETTLEMENT'
	end
	else
	BEGIN
		PRINT 'ENTRA EN ELSE'
		PRINT '@IdSettlement'
		PRINT @IdSettlement
		PRINT '@IdSettlementDestiny'
		PRINT @IdSettlementDestiny
		set @IdSettlement = @IdSettlementDestiny
	end


	PRINT 'TEST 3'
	IF OBJECT_ID('tempdb.dbo.#ItemAddress', 'U') IS NOT NULL DROP TABLE #ItemAddress;
	IF OBJECT_ID('tempdb.dbo.#SettlementList', 'U') IS NOT NULL DROP TABLE #SettlementList;

	set @IsTDA = isnull( ( select top 1 iif(cov.TDA =0,'false','true') from dbo.DumpServiceCoverage cov
	where cov.IdSettlement =  @IdSettlement and cov.RowStatus = 1),'false')

	declare @IdRateGroup int = ( iif(@IsTDA ='false',1,(select top 1 RateGroup from dbo.CatTypeService  where CtsShortName = 'TDA' and CtsRowStatus = 1 )))


	---HOTFIX_SAMEDAY.INI	
	PRINT 'HOTFIX INI'
	set @IsSDD = isnull( ( select top 1 iif(cov.SDD =0,'false','true') from dbo.DumpServiceCoverage cov
	where cov.IdSettlement =  @IdSettlement and cov.RowStatus = 1),'false')

	declare @IdRateGroupSDD int = ( iif(@IsSDD ='false',1,(select top 1 RateGroup from dbo.CatTypeService  where CtsShortName = 'SDD' and CtsRowStatus = 1 )))
	PRINT 'HOTFIX FIN'
	---HOTFIX_SAMEDAY.FIN
		
--------------- Fin determinar si es TDA   -----------------------.-------------------------------------------------------------------------------------
---------------- Determinar HubOrigen y Destino --------------------------------------------------------------------------------------------------------

	DECLARE @IdHubSource int
	DECLARE @IdHubDestiny int

	select top 1 @IdHubSource=hb.IdHubLogistic 
	from dbo.DumpServiceCoverage cov 
		left join dbo.HubLogistics hb on hb.HubAbbreviation = cov.Hub
	where cov.HeaderCode = @HeaderCodeSource

	select top 1 @IdHubDestiny=hb.IdHubLogistic 
	from dbo.DumpServiceCoverage cov 
		left join dbo.HubLogistics hb on hb.HubAbbreviation = cov.Hub
	where cov.HeaderCode = @HeaderCodeDestiny

--------------- Fin determinar Hub Origen y Destino ---------------------------------------------------------------------------------------------------

---------------- Determinar Segmento LOC/MET/FOR-------------------------------------------------------------------------------------------------------

	if @CodeOfReferenceSource <=0 -- si no viene el codeOfReference tomar el primero de cada cliente
		begin
			select top 1 @CodeOfReferenceSource = vp.CodeOfReference from dbo.VisitPointClient vp
			where vp.CustomerID = @IdCustomer
		end
	DECLARE @IdSegment int

	select  top 1  @IdSegment = cov.SegmentId 
	from dbo.VisitPointCoverage cov
	where cov.RowStatus ='true'
	and cov.HublogisticId = @IdHubDestiny
	and cov.VisitPointId = @CodeOfReferenceSource

	if @IdSegment is null -- si no se encuentra una configuracion válida para determinar el segmento tomar el foraneo como predeterminado.
		begin
			select top 1   @IdSegment = sg.CrsId 
			from dbo.CatRateSegment sg where sg.CrsShortName ='FOR'
		end

--------------- Fin Determinar Segmento LOC/MET/FOR --- ---------------------------------------------------------------------------------------------------
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

---------------------Fin obtener descuento -------------------------------------------------------------------------------------
---------------------Determinar si existe exceso de libras ---------------------------------------------------------------------

	IF OBJECT_ID('tempdb.dbo.#ParceCode', 'U') IS NOT NULL DROP TABLE #ParceCode;
	IF OBJECT_ID('tempdb.dbo.#ParceWeigth', 'U') IS NOT NULL DROP TABLE #ParceWeigth;

	 SELECT Item,
       ROW_NUMBER() OVER(ORDER BY item) ID
	   into #ParceCode
	from DeliveryBackOffice.dbo.SplitUnlimited(@ParcelCode,',')

	 SELECT Item,
       ROW_NUMBER() OVER(ORDER BY item) ID
	    into #ParceWeigth
	from DeliveryBackOffice.dbo.SplitUnlimited(@WeigthParcels,',')

	declare @OverWeight decimal(12,2) =0

	set @OverWeight =( select sum(
					iif((w.Item - @WeigthLimit )<0,0,(w.Item - @WeigthLimit ))) as exeso
					from  #ParceWeigth w
					 left join #ParceCode p on p.ID = w.ID
					where p.Item ='0' or p.Item is null or p.Item ='')
	print 'exceso de peso'
	print @OverWeight

----------------- Fin Determinar si existe exceso de libras --------------------------------------------------------------------
	DECLARE @CountPiece int =0 

----------------- Variable tipo tabla para almacenar tarifas --------------------------------------------------------------------

	DECLARE @TempRate TABLE(
	 TypeRate varchar (50)
	 ,Segment varchar (50)
	 ,Service varchar (50)
	 ,BaseRate decimal(12,2)
	 ,DiscountName varchar (100)
	 ,Discount decimal(12,2)
	 ,FragilRate decimal(12,2)
	 ,CollectedRate decimal(12,2)
	 ,InsuranceRate decimal(12,2)
	 ,CreditCardRate decimal(12,2)
	 ,OverWeightRate decimal(12,2)
	 ,IrregularPieceRate decimal(12,2)
	 ,ServiceName  varchar(100)
	 ,ServiceDescription  varchar(200)
	 ,ReturnRate decimal(12,2)
	 );

----------------- Fin Variable tipo tabla para almacenar tarifas --------------------------------------------------------------------


	if @IdTypeRate =1 -- tarifas estandar
		begin
			print 'aqui van las tarifas standar'
			 set @CountPiece = @CountPiecesParams
			
			if(@IsSDD = 'true') -----HOTFIX_SAMEDAY.INI	
			BEGIN
			
			insert into @TempRate
			select  isnull(cr.Name,'') TypeRate
			,isnull(sg.CrsShortName,'') Segment
			, isnull(sv.CtsShortName,'') Service
			,  (isnull(rd.RateValue,0) * @CountPiece )   BaseRate
			, isnull(@DiscountName,'') DiscountName
			, cast(( (isnull(rd.RateValue,0) * @CountPiece) * isnull(@Value,0)/ 100) as decimal(12,2)) DiscountValue
			, iif(@IsFragile ='true', isnull(rh.FragilRate,0),0) as fragilRate
			, iif(@IsCollected ='true', isnull(rh.CollectRate,0),0) as CollectedRate
			, iif (@IsInsurance ='true', ( iif( @InsuranceAmount> isnull(rh.InsuranceExempt,0) , cast((@InsuranceAmount * isnull(rh.InsuranceRate,0) /100 ) as decimal(12,2)) ,0)  ),0)  as InsuranceRate
			, iif(@IsCreditCardPayment ='true',isnull(rh.CreditCardRate,0) ,0 ) as CreditCardRate
			, iif(isnull(@OverWeight,0) > 0, isnull(@OverWeight,0) * isnull(rh.AdditionalWeightRate,0),0) OverWeightRate
			, 0 IrregularParcelRate
			, isnull(sv.CtsName ,'') as CstName
			, isnull(sv.CtsDescription,'') as CtsDescription
			, isnull(rh.ReturnRate,0) as ReturnRate
			from dbo.RateHeader rh
				 join dbo.RateData rd on rd.RateId = rh.RheId and rd.RowStatus ='true'
				 left join dbo.CatRateSegment sg on sg.CrsId = rd.TypeSegmentId
				 left join dbo.CatTypeService sv on sv.CtsId = rd.TypeServiceId
				 left join dbo.CatTypeRate cr on cr.IdTypeRate = rh.RateTypeId
			where rh.RheRowStatus = 'true'
				and rh.RheId = @IdRate
				and rd.ArticleId is null
				and  (rd.TypeServiceId in(select CtsId from dbo.CatTypeService  where RateGroup = @IdRateGroup and CtsRowStatus = 1) )
				and rd.HubSourceId = @IdHubSource
				and rd.HubDestinyId = @IdHubDestiny
				and  convert(datetime, @Time, 108)<=isnull(convert(datetime, ISNULL(rd.LimitHourPickup, sv.LimitHourPickup), 108) ,convert(datetime, '23:59:59', 108))

				END
				ELSE
				BEGIN
				
				insert into @TempRate
			select  isnull(cr.Name,'') TypeRate
			,isnull(sg.CrsShortName,'') Segment
			, isnull(sv.CtsShortName,'') Service
			,  (isnull(rd.RateValue,0) * @CountPiece )   BaseRate
			, isnull(@DiscountName,'') DiscountName
			, cast(( (isnull(rd.RateValue,0) * @CountPiece) * isnull(@Value,0)/ 100) as decimal(12,2)) DiscountValue
			, iif(@IsFragile ='true', isnull(rh.FragilRate,0),0) as fragilRate
			, iif(@IsCollected ='true', isnull(rh.CollectRate,0),0) as CollectedRate
			, iif (@IsInsurance ='true', ( iif( @InsuranceAmount> isnull(rh.InsuranceExempt,0) , cast((@InsuranceAmount * isnull(rh.InsuranceRate,0) /100 ) as decimal(12,2)) ,0)  ),0)  as InsuranceRate
			, iif(@IsCreditCardPayment ='true',isnull(rh.CreditCardRate,0) ,0 ) as CreditCardRate
			, iif(isnull(@OverWeight,0) > 0, isnull(@OverWeight,0) * isnull(rh.AdditionalWeightRate,0),0) OverWeightRate
			, 0 IrregularParcelRate
			, isnull(sv.CtsName ,'') as CstName
			, isnull(sv.CtsDescription,'') as CtsDescription
			, isnull(rh.ReturnRate,0) as ReturnRate
			from dbo.RateHeader rh
				 join dbo.RateData rd on rd.RateId = rh.RheId and rd.RowStatus ='true'
				 left join dbo.CatRateSegment sg on sg.CrsId = rd.TypeSegmentId
				 left join dbo.CatTypeService sv on sv.CtsId = rd.TypeServiceId
				 left join dbo.CatTypeRate cr on cr.IdTypeRate = rh.RateTypeId
			where rh.RheRowStatus = 'true'
				and rh.RheId = @IdRate
				and rd.ArticleId is null
				and  (rd.TypeServiceId in(select CtsId from dbo.CatTypeService  where RateGroup = @IdRateGroupSDD and CtsRowStatus = 1) )
				and rd.HubSourceId = @IdHubSource
				and rd.HubDestinyId = @IdHubDestiny
				and  convert(datetime, @Time, 108)<=isnull(convert(datetime, ISNULL(rd.LimitHourPickup, sv.LimitHourPickup), 108) ,convert(datetime, '23:59:59', 108))
				and sv.CtsShortName not in ( 'SDD')

				END -----HOTFIX_SAMEDAY.FIN

				print @IdRate
				print @IdHubSource
				print @IdHubDestiny

		end
	else if @IdTypeRate = 2 -- tarifas todo destino
		begin
			print 'aqui van las tarifas todo destino'
			print 'segmento'
			print  @IdSegment
			print 'grupo de servicios'
			
			--set @CountPiece = @CountPiecesParams
			set @CountPiece = 1
			print @IdRateGroup
			insert into @TempRate

			select isnull(cr.Name,'') TypeRate 
			, isnull(sg.CrsShortName,'') Segment
			, isnull(sv.CtsShortName,'') Service
			,  (isnull(rd.RateValue,0) * @CountPiece) BaseRate
			, '' DiscountName
			, 0 DiscountValue
			, iif(@IsFragile ='true', isnull(rh.FragilRate,0),0) as fragilRate
			, iif(@IsCollected ='true', isnull(rh.CollectRate,0),0) as CollectedRate
			, iif (@IsInsurance ='true', ( iif( @InsuranceAmount> isnull(rh.InsuranceExempt,0) , cast((@InsuranceAmount * isnull(rh.InsuranceRate,0) /100 ) as decimal(12,2)) ,0)  ),0)  as InsuranceRate
			, iif(@IsCreditCardPayment ='true',isnull(rh.CreditCardRate,0) ,0 ) as CreditCardRate
			, iif(@OverWeight > 0, @OverWeight * isnull(rh.AdditionalWeightRate,0),0) OverWeightRate
			, 0 IrregularParcelRate
			, isnull(sv.CtsName,'') as CstName 
			, isnull(sv.CtsDescription,'') as CstDescription
			, isnull(rh.ReturnRate,0) as ReturnRate
			from dbo.RateHeader rh
				 join dbo.RateData rd on rd.RateId = rh.RheId and rd.RowStatus ='true'
				 left join dbo.CatRateSegment sg on sg.CrsId = rd.TypeSegmentId
				 left join dbo.CatTypeService sv on sv.CtsId = rd.TypeServiceId
				 left join dbo.CatTypeRate cr on cr.IdTypeRate = rh.RateTypeId
			where rh.RheId = @IdRate
				and rd.ArticleId is null
				and rd.TypeSegmentId = @IdSegment
				and  (rd.TypeServiceId in(select CtsId from dbo.CatTypeService  where RateGroup = @IdRateGroup and CtsRowStatus = 1) )
				and  convert(datetime, @Time, 108)<=isnull(convert(datetime, ISNULL(rd.LimitHourPickup, sv.LimitHourPickup), 108) ,convert(datetime, '23:59:59', 108))
		end
	else if @IdTypeRate = 3 -- tarifas por articulo
		begin
			print 'aqui van las tarifas por articulo'
			-- cantidad de piezas regulares
			 set @CountPiece =( select  count(*) 
							from  #ParceWeigth w
								 left join #ParceCode p on p.ID = w.ID
							where p.Item ='0' or p.Item is null or p.Item ='' )
------------------------------------- verificar tarifas de piezas irregulares ---------------------------------------------------
		select item
		into #ListCode
		from DeliveryBackOffice.dbo.SplitUnlimited(@ParcelCode,',')
		
		--select * from #ListCode

		declare @ParcelPrice decimal(12,2) =(
		select sum( isnull( ra.RateValue , isnull(ar.PriceDefault ,0) )) 
		from #ListCode ls
			join dbo.ArticleByCustomer ar on ar.AbcIdCustomer = @IdCustomer and ar.Code = ls.Item
			join dbo.RateData ra on ra.ArticleId = ar.AbcId and ra.TypeSegmentId = @IdSegment
			)
		--select @ParcelPrice as price
-------------------------------------- fin verificar tarifas de piezas irregulares -----------------------------------------------
			insert into @TempRate
			select isnull(cr.Name,'') TypeRate 
			, isnull(sg.CrsShortName,'') Segment
			, isnull(sv.CtsShortName,'') Service
			, ( isnull(rd.RateValue,0) *@CountPiece  )   BaseRate
			, '' DiscountName
			, 0 DiscountValue
			, iif(@IsFragile ='true', isnull(rh.FragilRate,0),0) as fragilRate
			, iif(@IsCollected ='true', isnull(rh.CollectRate,0),0) as CollectedRate
			, iif (@IsInsurance ='true', ( iif( @InsuranceAmount> isnull(rh.InsuranceExempt,0) , cast((@InsuranceAmount * isnull(rh.InsuranceRate,0) /100 ) as decimal(12,2)) ,0)  ),0)  as InsuranceRate
			, iif(@IsCreditCardPayment ='true', isnull(rh.CreditCardRate,0) ,0 ) as CreditCardRate
			, iif(@OverWeight > 0, @OverWeight * isnull(rh.AdditionalWeightRate,0),0) OverWeightRate
			, isnull(@ParcelPrice,0) as IrregularParcelRate
			, isnull(sv.CtsName,'') as CtsName 
			, isnull(sv.CtsDescription,'') as CtsDescription
			, isnull(rh.ReturnRate,0) as ReturnRate
			from dbo.RateHeader rh
				 join dbo.RateData rd on rd.RateId = rh.RheId and rd.RowStatus ='true'
				 left join dbo.CatRateSegment sg on sg.CrsId = rd.TypeSegmentId
				 left join dbo.CatTypeService sv on sv.CtsId = rd.TypeServiceId
				 left join dbo.CatTypeRate cr on cr.IdTypeRate = rh.RateTypeId
			where rh.RheId = @IdRate
				and rd.ArticleId is null
				and rd.TypeSegmentId = @IdSegment
				and  (rd.TypeServiceId in(select CtsId from dbo.CatTypeService  where RateGroup = @IdRateGroup and CtsRowStatus = 1) )
				and  convert(datetime, @Time, 108)<=isnull(convert(datetime, ISNULL(rd.LimitHourPickup, sv.LimitHourPickup), 108) ,convert(datetime, '23:59:59', 108))
			print 'rate'
			print @IdRate
			print 'segment'
			print @IdSegment
			print 'grupo'
			print @IdRateGroup
		end
	else if @IdTypeRate = 4 -- tarifas especiales
		begin
			print 'aqui van las tarifas especiales'
		end
	else 
	begin
		print 'error no se encontro un tarifario'
	end

	print 'Respuesta desde tabla temporal'

	If @FormatResponse ='Json'
		begin
		declare @jsonResult as nvarchar(max)

		 set @jsonResult =( SELECT STUFF(( 
					select 
						',{"Title":"' + isnull(tr.ServiceName,'')  + '",' +
					'"Service":"' + isnull(tr.Segment,'') + '",' +
					'"ServiceDescription":"' + isnull(tr.ServiceDescription,'') + '",' +
					'"ServiceShortName":"' + isnull(tr.Service,'') + '",' +
						'"DeliveryDate":"' + Convert(varchar(24),@FechaCompra,120) + '",' +
						--'"Price":"' + convert(varchar(20), convert(decimal(12,1), (tr.BaseRate -  tr.Discount  + tr.FragilRate + tr.CollectedRate + tr.InsuranceRate  +tr.CreditCardRate + tr.OverWeightRate  + tr.IrregularPieceRate ))) + '",' +
						'"Price":"' + convert(varchar(20),  CONVERT(decimal(12,1), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.BaseRate + tr.IrregularPieceRate, 'false') ) +  CONVERT(decimal(12,1),(dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,(tr.Discount * -1),'false')  ) )  + convert(decimal(12,1),  dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.FragilRate,'false')) + convert(decimal(12,1), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.CollectedRate, 'false')) + convert(varchar(20), convert(decimal(12,1), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.InsuranceRate , 'false')))  + convert(varchar(20), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.CreditCardRate, 'false') ) + convert(varchar(20), convert(decimal(12,1), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.OverWeightRate, 'false'))) + convert(decimal(12,1), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' , (convert(decimal(12,1),tr.BaseRate) -  convert(decimal(12,1),tr.Discount)  + convert(decimal(12,1),tr.FragilRate) + convert(decimal(12,1),tr.CollectedRate) + convert(decimal(12,1),tr.InsuranceRate)  + convert(decimal(12,1),tr.CreditCardRate) + convert(decimal(12,1),tr.OverWeightRate)  + convert(decimal(12,1),tr.IrregularPieceRate) ), 'true')) ) + '",' +
						'"Currency":"' + @Currency + '",' +
						'"Integration":[{"Description":"' + 'Servicio' + '",' +
						'"Price":"' +convert(varchar(20),  CONVERT(decimal(12,1), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.BaseRate + tr.IrregularPieceRate, 'false') )) + '",' +
						'"Currency":"' + @Currency + '"' +
						'}'+
						 iif(tr.FragilRate>0, ',{"Description":"' + 'Frágil' + '",' + 
						'"Price":"' +convert(varchar(20), convert(decimal(12,1),  dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.FragilRate,'false'))) + '",' +
						'"Currency":"' + @Currency + '"' +
						'}' ,' '  ) +
						 iif(tr.InsuranceRate>0, ',{"Description":"' + 'Seguro' + '",' + 
						'"Price":"' +convert(varchar(20), convert(decimal(12,1), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.InsuranceRate , 'false'))) + '",' +
						'"Currency":"' + @Currency + '"' +
						'}' ,' '  ) +
						 iif(tr.CollectedRate>0, ',{"Description":"' + 'Pago en Destino' + '",' + 
						'"Price":"' +convert(varchar(20), convert(decimal(12,1), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.CollectedRate, 'false'))) + '",' +
						'"Currency":"' + @Currency + '"' +
						'}' ,' '  ) +
						 iif((tr.OverWeightRate)>0, ',{"Description":"' + 'Recargo por Peso' + '",' + 
						'"Price":"' +convert(varchar(20), convert(decimal(12,1), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.OverWeightRate, 'false'))) + '",' +
						'"Currency":"' + @Currency + '"' +
						'}' ,' '  ) +
						iif((tr.CreditCardRate)>0, ',{"Description":"' + 'Recargo por pago con tarjeta' + '",' + 
						'"Price":"' + convert(varchar(20), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.CreditCardRate, 'false') ) + '",' +
						'"Currency":"' + COALESCE(@Currency,'') + '"' +
						'}' ,' '  ) +


						iif((isnull(tr.Discount,0))>0, 
							',{"Description":"' + isnull(@DiscountName,'') + '",' + 
							'"Price":"' + CONVERT(varchar, CONVERT(decimal(12,1),(dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,(tr.Discount * -1),'false')  ))) + '",'  +
							'"Currency":"' + COALESCE(@Currency,'') + '"' +
							'}' 
						,' '  ) +

						',{"Description":"' + 'IVA' + '",' +
						'"Price":"' +convert(varchar(20), convert(decimal(12,1), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' , (convert(decimal(12,1),tr.BaseRate) -  convert(decimal(12,1),tr.Discount)  + convert(decimal(12,1),tr.FragilRate) + convert(decimal(12,1),tr.CollectedRate) + convert(decimal(12,1),tr.InsuranceRate)  + convert(decimal(12,1),tr.CreditCardRate) + convert(decimal(12,1),tr.OverWeightRate)  + convert(decimal(12,1),tr.IrregularPieceRate) ), 'true')) ) + '",' +
						'"Currency":"' + @Currency + '"' +
						'}'+
						' ]}' 
					from @TempRate tr
			--	where us.UsrEmail = @UserName and us.UsrRowStatus = 1 
				FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'),1,1,''
						) )

						select '[' + @jsonResult + ']'
		end
	else 
		begin
			select 
				tr.TypeRate
				,tr.Segment
				,tr.Service
				, (tr.BaseRate -  tr.Discount  + tr.FragilRate + tr.CollectedRate + tr.InsuranceRate  +tr.CreditCardRate + tr.OverWeightRate  + tr.IrregularPieceRate ) as Price
				, dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.BaseRate, 'false') as BaseRate
				, dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,(tr.Discount * -1),'false') as DiscountValue
				, tr.DiscountName
				, dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.FragilRate,'false')as FragilRate
				, dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.CollectedRate, 'false')  as CollectedRate
				,dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.InsuranceRate , 'false') as InsuranceRate
				, dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.OverWeightRate, 'false') as OverWeightRate
				, dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.IrregularPieceRate, 'false') as IrregularPieceRate
				, dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.CreditCardRate, 'false') as CreditCardRate
				 ,dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' , (tr.BaseRate -  tr.Discount  + tr.FragilRate + tr.CollectedRate + tr.InsuranceRate  +tr.CreditCardRate + tr.OverWeightRate  + tr.IrregularPieceRate ), 'true') as Iva
				 ,@FechaCompra [FechaCompra]
				 ,@Currency [Currency]
				 ,tr.ReturnRate [ReturnRate]
			from  @TempRate tr
		end
		

	PRINT 'precio'
	
END
