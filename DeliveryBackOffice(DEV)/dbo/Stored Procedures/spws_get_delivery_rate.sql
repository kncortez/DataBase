
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-04-28>
-- Description:	<Devuelve la opción y precio shipping según un punto de visita ó un cliente>
-- =============================================
-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2022-06-15>
-- Description:	<Logíca para implementar nuevo tarifario y tarifario de descuento si destino es Ex C>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-07-06>
-- Description:	< Corrección de cálculo de sobrepesos de nuevo esquema de tarifas >
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_delivery_rate]

@CodApp AS NVARCHAR(50) = '' ,
@IdCustomerParams AS INT = 0,
@HeaderCodeDestiny AS VARCHAR(10)  = '',
@HeaderCodeSource AS VARCHAR(10)  = '',
@Country AS NVARCHAR(2)   = 'GT',
@CountPiecesParams AS INT = 1,
@IsFragile AS BIT  = 'FALSE',
@IsCollected AS BIT  = 'FALSE',
@IsInsurance AS BIT  = 'FALSE',
@WeigthParcels AS NVARCHAR(MAX) ='0',
@InsuranceAmount AS DECIMAL (18,2) =0,
@IsCreditCardPayment AS BIT = 'false'
,@ParcelCode AS NVARCHAR(MAX) = '0'
,@Zone AS INT =0
,@AddressParse AS NVARCHAR(600)= ''
,@IdSettlementSource AS INT =0
,@IdSettlementDestiny AS INT =0
,@CodeOfReferenceSource AS INT =0
,@CodeOfReferenceDestiny AS INT =0
,@IdSalePipeLine AS INT=0
,@FormatResponse AS NVARCHAR(10) ='DataTable'
,@CalculateTaxes BIT = 'false'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdCustomer as int =0

	DECLARE  @FechaCompra AS DATETIME = GETDATE()
	DECLARE @Time AS time = convert(time,@FechaCompra)

------- determinar el cliente -----------------------------------------------------------------------------------------------
	If @IdCustomerParams <=0 -- si el id de client no viene en los parametros determinar via CODAPP
		begin
			set @IdCustomer =	(select  top 1 eco.IdCustomer
				from DeliveryBackOffice.[dbo].[Ecommerce] eco WITH(NOLOCK)
				where eco.UserKey = @CodApp --'SIFDCECOM300720201459'
				and eco.IdCountry = @Country
				and eco.EcommerceStatus = 'TRUE')
		end
	ELSE
		BEGIN
			SET @IdCustomer = @IdCustomerParams
		END
------- fin determinar cliente ------------------------------------------------------------------------------------------------
	
------- determinar el Tarifario y tipo de tarifario que se va a aplicar -------------------------------------------------------

	DECLARE @NewMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar' COLLATE Latin1_General_CI_AI);
	DECLARE @NewAlternativeRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario destinos express center' COLLATE Latin1_General_CI_AI);
	DECLARE @NewAutoSalesMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar autoventas' COLLATE Latin1_General_CI_AI);

	DECLARE @IdRate as int
	DECLARE @IdTypeRate as int
	DECLARE @WeigthLimit as decimal(12,2) =0
	DECLARE @Currency AS varchar(10) = ''
	DECLARE @PiecesIncluded AS DECIMAL(12,2) = 1
	
	IF EXISTS
	(
	    SELECT
			rbc.RbcIdRate
		FROM dbo.RateByCustomer rbc WITH(NOLOCK)
		WHERE rbc.RbcIdCustomer = @IdCustomer
		AND rbc.RbcRowStatus = 'TRUE'
		AND rbc.RbcCodeOfReference = @CodeOfReferenceSource
	)
		BEGIN
			SELECT
				@IdRate = rc.RbcIdRate
			   ,@IdTypeRate = RH.RateTypeId
			   ,@WeigthLimit = rh.WeightLimit
			   ,@Currency = dc.Currency_Symbol
			   ,@PiecesIncluded = rh.PiecesIncluded
			FROM dbo.RatebyCustomer rc WITH(NOLOCK)
			LEFT JOIN dbo.RateHeader rh WITH(NOLOCK)
				ON rh.RheId = rc.RbcIdRate
					AND rh.RheRowStatus = 'true' 
			LEFT JOIN dbo.DeliveryCurrency dc WITH(NOLOCK)
				ON dc.Currency_Id = rh.CurrencyId
			WHERE rc.RbcIdCustomer = @IdCustomer
			AND rc.RbcRowStatus = 'true'
			AND rc.RbcCodeOfReference = @CodeOfReferenceSource
		END
	ELSE
		BEGIN
			SELECT @IdRate= RC.RbcIdRate
			,@IdTypeRate= RH.RateTypeId
			,@WeigthLimit = rh.WeightLimit
			,@Currency = dc.Currency_Symbol
			,@PiecesIncluded = rh.PiecesIncluded
			FROM dbo.RatebyCustomer rc WITH(NOLOCK)
				LEFT JOIN dbo.RateHeader rh WITH(NOLOCK) ON rh.RheId = rc.RbcIdRate AND rh.RheRowStatus ='true'
				LEFT JOIN dbo.DeliveryCurrency dc WITH(NOLOCK) ON dc.Currency_Id = rh.CurrencyId
			WHERE rc.RbcIdCustomer = @IdCustomer
			AND rc.RbcRowStatus = 'true'
			AND rc.RbcCodeOfReference IS NULL
		END

	if @IdRate is null -- si el cliente no tiene una tarifa asociada determinar por canal de venta
	begin
		select  @IdRate= rh.RheId
		,@IdTypeRate= RH.RateTypeId
		,@WeigthLimit = rh.WeightLimit
		,@Currency = dc.Currency_Symbol
		,@PiecesIncluded = rh.PiecesIncluded
		from dbo.RateBySalePipeLine sp WITH(NOLOCK)
			left join dbo.RateHeader rh WITH(NOLOCK) on rh.RheId = sp.RateId and rh.RheRowStatus ='true'
			left join dbo.DeliveryCurrency dc WITH(NOLOCK) on dc.Currency_Id = rh.CurrencyId
		where sp.RowStatus = 'true'
		and sp.SalePipeLineId = @IdSalePipeLine
		
	end
	
	if @IdRate is null -- si no se encuentra por canal de venta se determina por el valor default 
		begin
			select  @IdRate= rh.RheId
			,@IdTypeRate= RH.RateTypeId
			,@WeigthLimit = rh.WeightLimit
			,@Currency = dc.Currency_Symbol
			,@PiecesIncluded = rh.PiecesIncluded
			from dbo.RateHeader rh WITH(NOLOCK)
				left join dbo.DeliveryCurrency dc WITH(NOLOCK)  on dc.Currency_Id = rh.CurrencyId
			where rh.RheRowStatus = 'true' 
			and rh.RheDefault ='true'
		end

-------- Fin determinar tarifa que se va usar ---------------------------------------------------------------------
 
 ------------Validar Usuario Individual ó Ex C y Asignar nuevo tarifario-----------------------------------------------------------------------------------
 DECLARE @CustomerType INT
  DECLARE @RateId INT
		SELECT
			  @CustomerType = C.IdCustomerType  
		FROM DBO.Customer C 
		WHERE IdCustomer =@IdCustomer

   IF (@CustomerType IN (2,3)) --Validación si Usuario es Individual o Express center
    BEGIN

	   IF (EXISTS (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK) WHERE VPC.CodeOfReference = @CodeOfReferenceDestiny AND VPC.StatusClient = 1 AND VPC.DescriptionOfClient LIKE 'FD%EXC%' COLLATE Latin1_General_CI_AI))
		BEGIN
		
			  SELECT 
					 @RateId = ISNULL(ARC.RateId, @IdRate )
			  FROM [DeliveryBackOffice].[dbo].[AlternativeRatebyCustomer] ARC WITH(NOLOCK)
			  WHERE ARC.CustomerId = @IdCustomer AND ARC.RowStatus = 1  AND @IdRate IN (@NewMainRates,@NewAutoSalesMainRates)

				SET @IdRate = @RateId ;
   
		 END
     END

	IF( @IdCustomerParams = 0 AND @IdCustomer = 6)
	BEGIN

		SET @CalculateTaxes = 'false'

	END

------------------------- Determinar si el servico es TDA ------------------------------------------------------------------
		
	--DECLARE @Tsettlement table (IdSettlement bigint )
	Declare @IsTDA bit ='false'
	Declare @IsSDD bit ='false'

	IF OBJECT_ID('tempdb.dbo.#ItemAddress', 'U') IS NOT NULL DROP TABLE #ItemAddress;
	IF OBJECT_ID('tempdb.dbo.#SettlementList', 'U') IS NOT NULL DROP TABLE #SettlementList;

	--PRINT 'TEST 1'
	-- Quitar Departamento y Municipio de la direccion para tener un mejor resultado en la coincidencia
	SET @AddressParse = ( SELECT  TOP 1 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
								 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
								 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
								 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
								 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
								 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
								 REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
								 @AddressParse, 
								 '!', ''), '"', ''), '#', ''), '$', ''), '%', ''),
								 '&', 'y'), '''', ''), '*', ''), '+', ''), '/', ''),
								 '<', ''), '=', ''), '>', ''), '?', ''), '@', ''),
								 '[', ''), '\', ''), ']', ''), '^', ''), '_', ''),
								 '`', ''), '{', ''), '|', ''), '}', ''), '~', ''),
								 '¡', ''), '¿', ''), '°', ''), '¬', ''), '´', ''),
								 '¨', ''), '&Quot;', ''), CHAR(255), ''), twn.TownshipName, ''), prv.ProvinceName, '') 
						  FROM  Township twn  WITH(NOLOCK)
						  LEFT JOIN Province prv  WITH(NOLOCK)
							ON prv.IdProvince = twn.IdProvince
						  WHERE twn.HeaderCode = @HeaderCodeDestiny 
						  AND twn.TownshipStatus ='true')

	--PRINT 'TEST 2'

	DECLARE @IdSettlement BIGINT;

	--PRINT '@IdSettlementDestiny'
	--PRINT @IdSettlementDestiny

	IF @IdSettlementDestiny<=0  --  no se envio el id settlement desde front por lo tanto intenta determinarlo con base a la dirección
	BEGIN
		--PRINT 'entra @IdSettlementDestiny<=0'
		--PRINT '@AddressParse'
		--PRINT @AddressParse

		-- separar en un arrglo la direccion 
		SELECT Item
		INTO #ItemAddress
		FROM DeliveryBackOffice.dbo.SplitUnlimited(@AddressParse,' ')

		--PRINT 'FIN DE PARSERO DE DIRECCEION'
		IF @Zone =0 -- si no trae zona verificar por direccion
		BEGIN
			SELECT TOP 1 ST.IdSettlement  , COUNT(ST.IdSettlement) AS mas_popular, ST.Settlement
			INTO #SettlementList
			FROM #ItemAddress i
				LEFT JOIN dbo.Township tw WITH(NOLOCK) ON tw.HeaderCode = @HeaderCodeDestiny
				LEFT JOIN dbo.Settlement st WITH(NOLOCK) ON st.IdTownship = tw.IdTownship AND st.Settlement LIKE CONCAT('%', i.Item, '%')
			WHERE LEN(i.Item)>3 AND st.IdSettlement IS NOT NULL
			GROUP BY ST.IdSettlement, ST.Settlement
			ORDER BY 2 DESC
	
			CREATE NONCLUSTERED INDEX IX_SettlementList_ParcelCode ON #SettlementList(IdSettlement);

			SET @IdSettlement =(SELECT TOP 1 IdSettlement FROM #SettlementList)


		END
		ELSE
		BEGIN  -- si trae zona verificar por zona 
			SET @IdSettlement = (SELECT TOP 1 st.IdSettlement
			FROM dbo.Township tw WITH(NOLOCK)
				LEFT JOIN dbo.Settlement st WITH(NOLOCK) ON st.IdTownship = tw.IdTownship
			WHERE tw.HeaderCode = @HeaderCodeDestiny 
			AND st.Settlement LIKE CONCAT('%Zona ', @Zone ,'%')
			ORDER BY IdSettlement )

		end
		--PRINT 'FIN IF DE LA ZONA'
		if @IdSettlement is null -- si no se puede identificar el settlement trae el primero del municipio proporcionado
		begin 
			set @IdSettlement =  (select top 1 st.IdSettlement
			from dbo.Township tw WITH(NOLOCK)
			left join dbo.Settlement st  WITH(NOLOCK) ON st.IdTownship = tw.IdTownship
			where tw.HeaderCode = @HeaderCodeDestiny 
			order by IdSettlement)
		END
        
		--PRINT 'FIN DEL IF DEL SETTLEMENT'
	end
	else
	BEGIN
		--PRINT 'ENTRA EN ELSE'
		--PRINT '@IdSettlement'
		--PRINT @IdSettlement
		--PRINT '@IdSettlementDestiny'
		--PRINT @IdSettlementDestiny
		set @IdSettlement = @IdSettlementDestiny
	end


	--PRINT 'TEST 3'
	-- IF OBJECT_ID('tempdb.dbo.#ItemAddress', 'U') IS NOT NULL DROP TABLE #ItemAddress;
	-- IF OBJECT_ID('tempdb.dbo.#SettlementList', 'U') IS NOT NULL DROP TABLE #SettlementList;

	set @IsTDA = isnull( ( select top 1 iif(cov.TDA =0,'false','true') from dbo.DumpServiceCoverage cov WITH(NOLOCK)
	where cov.IdSettlement =  @IdSettlement and cov.RowStatus = 1),'false')

	declare @IdRateGroup int = ( iif(@IsTDA ='false',1,(select top 1 RateGroup from dbo.CatTypeService  WITH(NOLOCK) where CtsShortName = 'TDA' and CtsRowStatus = 1 )))


	---HOTFIX_SAMEDAY.INI	
	--PRINT 'HOTFIX INI'

	IF @IdRateGroup = 1
		BEGIN
			set @IsSDD = isnull( ( select top 1 iif(cov.SDD =0,'false','true') from dbo.DumpServiceCoverage cov WITH(NOLOCK)
			where cov.IdSettlement =  @IdSettlement and cov.RowStatus = 1),'false')

			declare @IdRateGroupSDD int = ( iif(@IsSDD ='false',1,(select top 1 RateGroup from dbo.CatTypeService WITH(NOLOCK) where CtsShortName = 'SDD' and CtsRowStatus = 1 )))
		end

	
	--PRINT 'HOTFIX FIN'
	---HOTFIX_SAMEDAY.FIN
		
--------------- Fin determinar si es TDA   -----------------------.-------------------------------------------------------------------------------------
---------------- Determinar HubOrigen y Destino --------------------------------------------------------------------------------------------------------

	DECLARE @IdHubSource int
	DECLARE @IdHubDestiny int

	select top 1 @IdHubSource=hb.IdHubLogistic 
	from dbo.DumpServiceCoverage cov  WITH(NOLOCK)
		left join dbo.HubLogistics hb WITH(NOLOCK) on hb.HubAbbreviation = cov.Hub
	where cov.HeaderCode = @HeaderCodeSource ORDER BY cov.Hub 

	select top 1 @IdHubDestiny=hb.IdHubLogistic 
	from dbo.DumpServiceCoverage cov WITH(NOLOCK)
		left join dbo.HubLogistics hb WITH(NOLOCK) ON hb.HubAbbreviation = cov.Hub
	where cov.HeaderCode = @HeaderCodeDestiny ORDER BY cov.Hub  DESC

--------------- Fin determinar Hub Origen y Destino ---------------------------------------------------------------------------------------------------

---------------- Determinar Segmento LOC/MET/FOR-------------------------------------------------------------------------------------------------------
--PRINT 'determinar segmento LOC/MET/FOR '
		if @CodeOfReferenceSource <=0 -- si no viene el codeOfReference tomar el primero de cada cliente
		begin
			select top 1 @CodeOfReferenceSource = vp.CodeOfReference from dbo.VisitPointClient vp WITH(NOLOCK)
			where vp.CustomerID = @IdCustomer
		end
	DECLARE @IdSegment int

	--PRINT 'CodeOfReference'
	--PRINT @CodeOfReferenceSource

	--PRINT '@IdHubDestiny'
	--PRINT @IdHubDestiny
	select  top 1  @IdSegment = cov.SegmentId 
	from dbo.VisitPointCoverage cov
	where cov.RowStatus ='true'
	and cov.HublogisticId = @IdHubDestiny
	and cov.VisitPointId = @CodeOfReferenceSource

	--PRINT 'segmento'
	--PRINT @IdSegment
	if @IdSegment is null -- si no se encuentra una configuracion válida para determinar el segmento tomar  LOCAL si el hub de origen es igual al hub de destino
		BEGIN
		--PRINT 'segmento nulo'
			IF @IdHubSource = @IdHubDestiny 
				BEGIN
				--PRINT 'hubs iguales'
					SELECT top 1   @IdSegment = sg.CrsId 
					FROM dbo.CatRateSegment sg  WITH(NOLOCK) WHERE sg.CrsShortName ='LOC'
				END
			ELSE 
				BEGIN
				--PRINT 'hubs default'
					select  top 1  @IdSegment = cov.SegmentId  -- si los hubs no son iguales verficar en la configuracion por default asignada el visit point 0
						from dbo.VisitPointCoverage cov WITH(NOLOCK)
					where cov.RowStatus ='true'
						and cov.HublogisticId = @IdHubDestiny
						and @IdHubSource IN(1,22)
				END
		END
        
		if @IdSegment is null -- si no se encuentra una configuracion válida para determinar el segmento tomar el foraneo como predeterminado.
		BEGIN
			
					SELECT top 1   @IdSegment = sg.CrsId 
			from dbo.CatRateSegment sg WITH(NOLOCK) where sg.CrsShortName ='FOR'
		END

--------------- Fin Determinar Segmento LOC/MET/FOR --- ---------------------------------------------------------------------------------------------------
-------------------------------Obtener descuento --------------------------------------------------------------------------

		declare @IdTypeCustomer int  =(select top 1 cus.IdCustomerType from dbo.Customer cus  WITH(NOLOCK) WHERE cus.IdCustomer = @IdCustomer)

		select Top 1
		ss.Name as DicountName
		,ss.IsGlobal  as IsGlobla
		,sd.UnitId as IdUnit
		,sd.Value as Value
		, unt.Prefix as Unit
		, sd.TypeDiscountId  as idTypeDiscount
		,tyd.ShortName as TypeDiscount
		into #Dicounts
		from dbo.SpecialSale ss WITH(NOLOCK)
			inner join dbo.SpecialSaleDetail sd  WITH(NOLOCK) ON sd.SpecialSaleId = ss.IdSpecialSale and sd.RowStatus =1
			left join dbo.Unit unt WITH(NOLOCK)  on unt.IdUnit = sd.UnitId
			left join dbo.CatTypeDiscount tyd  WITH(NOLOCK) ON tyd.IdCatTypeDiscount = sd.TypeDiscountId
			left join dbo.SpecialSaleTarget tgt WITH(NOLOCK) ON tgt.SpecialSaleId = ss.IdSpecialSale
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
	from DeliveryBackOffice.dbo.SplitUnlimited(RTRIM(LTRIM(@WeigthParcels)),',')

	declare @OverWeight decimal(12,2) =0
	declare @OverWeightchar NVARCHAR(100)
	
	set @OverWeightchar =( select sum(
					iif((w.Item - @WeigthLimit )<0,0,(w.Item - @WeigthLimit ))) as exeso
					from  #ParceWeigth w
					 left join #ParceCode p on p.ID = w.ID
					where p.Item ='0' or p.Item is null or p.Item ='')
	--PRINT @OverWeightchar

	set @OverWeight =( select sum(
					iif((w.Item - @WeigthLimit )<0,0,(w.Item - @WeigthLimit ))) as exeso
					from  #ParceWeigth w
					 left join #ParceCode p on p.ID = w.ID
					where p.Item ='0' or p.Item is null or p.Item ='')
	--print 'exceso de peso'
	--print @OverWeight

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
			--print 'aqui van las tarifas standar'
			DECLARE @CountPiecebyArticle INT = 0
			DECLARE @ParcelPrice2 decimal(12,2) = 0

			SET @CountPiecebyArticle = (SELECT
					COUNT(1)
				FROM #ParceWeigth pw
				INNER JOIN #ParceCode pc
					ON pc.ID = pw.ID
				WHERE pc.Item <> '0'
				AND pc.Item <> ''
				AND pc.item IS NOT NULL)

			SET @CountPiece = dbo.FnPiecesByPiecesIncluded(@CountPiecesParams,@PiecesIncluded) - @CountPiecebyArticle
			
			SELECT
				item INTO #ListCode2
			FROM DeliveryBackOffice.dbo.SplitUnlimited(@ParcelCode, ',')

			SET @ParcelPrice2 = ( SELECT
					SUM(ISNULL(ra.RateValue, ISNULL(ar.PriceDefault, 0)))
				FROM #ListCode2 ls
				INNER JOIN dbo.ArticleByCustomer ar
					ON ar.Code = ls.Item
				INNER JOIN dbo.RateData ra
					ON ra.ArticleId = ar.AbcId
					AND ra.TypeSegmentId = @IdSegment
					AND ra.RateId = @IdRate)

			if(@IsSDD = 'true'  AND @CountPiecebyArticle = 0) -----HOTFIX_SAMEDAY.INI	
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
			, isnull(@ParcelPrice2,0) IrregularParcelRate
			, isnull(sv.CtsName ,'') as CstName
			, isnull(sv.CtsDescription,'') as CtsDescription
			, isnull(rh.ReturnRate,0) as ReturnRate
			from dbo.RateHeader rh WITH(NOLOCK)
				 inner join dbo.RateData rd WITH(NOLOCK) on rd.RateId = rh.RheId and rd.RowStatus ='true'
				 left join dbo.CatRateSegment sg WITH(NOLOCK) on sg.CrsId = rd.TypeSegmentId
				 left join dbo.CatTypeService sv WITH(NOLOCK) ON sv.CtsId = rd.TypeServiceId
				 left join dbo.CatTypeRate cr WITH(NOLOCK) ON cr.IdTypeRate = rh.RateTypeId
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
			, isnull(@ParcelPrice2,0) IrregularParcelRate
			, isnull(sv.CtsName ,'') as CstName
			, isnull(sv.CtsDescription,'') as CtsDescription
			, isnull(rh.ReturnRate,0) as ReturnRate
			from dbo.RateHeader rh WITH(NOLOCK)
				 inner join dbo.RateData rd WITH(NOLOCK) on rd.RateId = rh.RheId and rd.RowStatus ='true'
				 left join dbo.CatRateSegment sg WITH(NOLOCK) ON sg.CrsId = rd.TypeSegmentId
				 left join dbo.CatTypeService sv WITH(NOLOCK) on sv.CtsId = rd.TypeServiceId
				 left join dbo.CatTypeRate cr WITH(NOLOCK) on cr.IdTypeRate = rh.RateTypeId
			where rh.RheRowStatus = 'true'
				and rh.RheId = @IdRate
				and rd.ArticleId is null
				and  (rd.TypeServiceId in(select CtsId from dbo.CatTypeService  where RateGroup = @IdRateGroup and CtsRowStatus = 1) )
				and rd.HubSourceId = @IdHubSource
				and rd.HubDestinyId = @IdHubDestiny
				and  convert(datetime, @Time, 108)<=isnull(convert(datetime, ISNULL(rd.LimitHourPickup, sv.LimitHourPickup), 108) ,convert(datetime, '23:59:59', 108))
				and sv.CtsShortName not in ( 'SDD')

				END -----HOTFIX_SAMEDAY.FIN


		end
	else if @IdTypeRate = 2 -- tarifas todo destino
		begin
			--print 'aqui van las tarifas todo destino'
			--print 'segmento'
			--print  @IdSegment
			--print 'grupo de servicios'
			
			--IF @IdCustomer = 1  -- el igss se cobra por guia no por pieza
			--	set @CountPiece = 1
			--ELSE
				set @CountPiece = dbo.FnPiecesByPiecesIncluded(@CountPiecesParams,@PiecesIncluded) -- todos los demas clientes se les cobra por pieza

			
			--
			--print @IdRateGroup
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
			from dbo.RateHeader rh WITH(NOLOCK)
				 inner join dbo.RateData rd WITH(NOLOCK) ON rd.RateId = rh.RheId and rd.RowStatus ='true'
				 left join dbo.CatRateSegment sg WITH(NOLOCK) ON sg.CrsId = rd.TypeSegmentId
				 left join dbo.CatTypeService sv WITH(NOLOCK) ON sv.CtsId = rd.TypeServiceId
				 left join dbo.CatTypeRate cr WITH(NOLOCK) on cr.IdTypeRate = rh.RateTypeId
			where rh.RheId = @IdRate
				and rd.ArticleId is null
				and rd.TypeSegmentId = @IdSegment
				and  (rd.TypeServiceId in(select CtsId from dbo.CatTypeService  where RateGroup = @IdRateGroup and CtsRowStatus = 1) )
				and  convert(datetime, @Time, 108)<=isnull(convert(datetime, ISNULL(rd.LimitHourPickup, sv.LimitHourPickup), 108) ,convert(datetime, '23:59:59', 108))
		end
	else if @IdTypeRate = 3 -- tarifas por articulo
		begin

			--print 'aqui van las tarifas por articulo'
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
        declare @ParcelPrice decimal(12,2) = 0

		IF(@IdRate IN (@NewMainRates, @NewAlternativeRates, @NewAutoSalesMainRates))
		BEGIN

			SET @IdSegment= NULL
				--PRINT 'ENTRO AL IF'
			IF(EXISTS (SELECT TOP 1 1 FROM #ListCode) AND LTRIM(RTRIM((SELECT TOP 1 Item FROM #ListCode))) <> '')
			BEGIN
				-- Cálculo de segmento - nuevas tarifas
				-- HeaderCodes Iguales - LOC
				IF(@HeaderCodeSource = @HeaderCodeDestiny)
				BEGIN
					SELECT 
						TOP 1 
							@IdSegment = sg.CrsId 
					FROM 
						dbo.CatRateSegment sg WITH(NOLOCK)
					WHERE 
						sg.CrsShortName ='LOC'
				END
				-- HeaderCodes diferentes - revisar tabla
				ELSE
				BEGIN
					SELECT
						TOP 1
							@IdSegment = RTC.SegmentTypeId
					FROM
						[DeliveryBackOffice].[dbo].[RateTownshipCoverage] RTC WITH(NOLOCK)
						INNER JOIN
							[DeliveryBackOffice].[dbo].[Township] TwnSource WITH(NOLOCK)
							ON
								RTC.TownshipSourceId = TwnSource.IdTownship
						INNER JOIN
							[DeliveryBackOffice].[dbo].[Township] TwnDestiny WITH(NOLOCK)
							ON
								RTC.TownshipDestinyId = TwnDestiny.IdTownship
					WHERE
						RTC.RateId = @IdRate
						AND
						(TwnSource.HeaderCode = @HeaderCodeSource)
						AND
						(TwnDestiny.HeaderCode = @HeaderCodeDestiny 
						)
						AND RTC.RowStatus = 1

				END

				IF(@IdSegment IS NULL)-- si no se encuentra una configuracion válida para determinar el segmento tomar el foraneo como predeterminado.
				BEGIN
					SELECT
						TOP 1 
							@IdSegment = sg.CrsId 
					FROM 
						[DeliveryBackOffice].dbo.CatRateSegment sg WITH(NOLOCK) 
					WHERE 
						sg.CrsShortName ='FOR' COLLATE Latin1_General_CI_AI
				END

				-- Cálculo de precios
				IF OBJECT_ID('tempdb.dbo.#ParcelAmountPerType', 'U') IS NOT NULL DROP TABLE #ParcelAmountPerType;
				IF OBJECT_ID('tempdb.dbo.#ParcelOverweightPerType', 'U') IS NOT NULL DROP TABLE #ParcelOverweightPerType;
				
				-- Servicios y segmentos
				SELECT
					CRS.CrsId 'SegmentType'
					,CTS.CtsId 'ServiceType'
					,CAST(0 AS DECIMAL(18,2)) 'TotalAmount'
				INTO #ParcelAmountPerType
				FROM
					[DeliveryBackOffice].[dbo].[CatRateSegment] CRS
					CROSS JOIN
						[DeliveryBackOffice].[dbo].[CatTypeService] CTS
				
				-- Paquetes con su peso indicado
				DECLARE @ExpectedWeight DECIMAL(12,2) = 0;

				SELECT
					p.ID 'RowNumber'
					,ABC.Code 'ParcelCode'
					,ABC.MassWeight 'ParcelWeight'
				INTO #ParcelOverweightPerType
				FROM
					#ParceCode p 
					INNER JOIN
						[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
						ON
							p.Item = ABC.Code COLLATE Latin1_General_CI_AI
							AND
							ABC.AbcRowStatus = 1

				SET @ExpectedWeight = (SELECT SUM(POPT.ParcelWeight) FROM #ParcelOverweightPerType POPT );

				BEGIN TRY

					SET @OverWeight = (SELECT SUM( CAST(ROUND(CAST(PW.Item AS DECIMAL(12,2)),0) AS INT) ) FROM  #ParceWeigth PW)

				END TRY
				BEGIN CATCH

					SET @OverWeight = @ExpectedWeight;

				END CATCH

				DECLARE @NewOverWeight DECIMAL(12,2) = 0;
				SET @NewOverWeight = (@OverWeight - @ExpectedWeight);

				-- Actualizar con los que esten dentro del tarifario por tipo de servicio y tipo de segmento
				UPDATE
					#ParcelAmountPerType
				SET
					TotalAmount = TotalAmount + AddedTotalAmount
				FROM
					(
						select 
							rd.TypeSegmentId AddedSegmentType
							,rd.TypeServiceId AddedServiceType
							,SUM(rd.RateValue) 'AddedTotalAmount'
						from dbo.RateHeader rh
							 inner join dbo.RateData rd on rd.RateId = rh.RheId and rd.RowStatus ='true'
							 inner join dbo.ArticleByCustomer abc on rd.ArticleId = abc.AbcId
							 inner join #ListCode LC on abc.Code = LC.Item
						where rh.RheId = @IdRate
							and rd.TypeSegmentId = @IdSegment
						GROUP BY
							rd.TypeSegmentId,
							rd.TypeServiceId
					) TempValues
				WHERE
					TempValues.AddedSegmentType = #ParcelAmountPerType.SegmentType
					AND
					TempValues.AddedServiceType = #ParcelAmountPerType.ServiceType

				-- Actualizar con los que NO esten dentro del tarifario por tipo de servicio y tipo de segmento
				UPDATE
					#ParcelAmountPerType
				SET
					TotalAmount = TotalAmount + AddedTotalAmount
				FROM
					(
						select 
							rd.TypeSegmentId AddedSegmentType
							,SUM(ISNULL(rd.RateValue, abc.PriceDefault)) 'AddedTotalAmount'
						from 
							#ListCode lc
							inner join dbo.ArticleByCustomer abc ON  abc.Code = lc.Item
							inner join dbo.RateData rd on rd.ArticleId = abc.AbcId
						WHERE
							rd.TypeServiceId IS NULL
							AND
							rd.TypeSegmentId = @IdSegment 
							AND 
							rd.RateId = @IdRate
						GROUP BY
							rd.TypeSegmentId
					) TempValues
				WHERE
					TempValues.AddedSegmentType = SegmentType

				-- Tarifas finales
				insert into @TempRate
				select DISTINCT
				isnull(cr.Name,'') TypeRate 
				, isnull(sg.CrsShortName,'') Segment
				, isnull(sv.CtsShortName,'') Service
				, ( isnull(rd.RateValue,0) *@CountPiece  )   BaseRate
				, '' DiscountName
				, 0 DiscountValue
				, iif(@IsFragile ='true', isnull(rh.FragilRate,0),0) as fragilRate
				, iif(@IsCollected ='true', isnull(rh.CollectRate,0),0) as CollectedRate
				, iif(@IsInsurance ='true', ( iif( @InsuranceAmount> isnull(rh.InsuranceExempt,0) , cast(( (@InsuranceAmount) * isnull(rh.InsuranceRate,0) /100 ) as decimal(12,2)) ,0)  ),0)  as InsuranceRate
				, iif(@IsCreditCardPayment ='true', isnull(rh.CreditCardRate,0) ,0 ) as CreditCardRate
				, iif(@NewOverWeight > 0, @NewOverWeight * isnull(rh.AdditionalWeightRate,0),0) OverWeightRate
				, isnull(papt.TotalAmount,0) as IrregularParcelRate
				, isnull(sv.CtsName,'') as CtsName 
				, isnull(sv.CtsDescription,'') as CtsDescription
				, isnull(rh.ReturnRate,0) as ReturnRate
				from dbo.RateHeader rh
					 inner join dbo.RateData rd on rd.RateId = rh.RheId and rd.RowStatus ='true'
					 inner join #ParcelAmountPerType papt on rd.TypeSegmentId = papt.SegmentType and rd.TypeServiceId = papt.ServiceType
					 left join dbo.CatRateSegment sg on sg.CrsId = rd.TypeSegmentId
					 left join dbo.CatTypeService sv on sv.CtsId = rd.TypeServiceId
					 left join dbo.CatTypeRate cr on cr.IdTypeRate = rh.RateTypeId
				where rh.RheId = @IdRate
					and rd.TypeSegmentId = @IdSegment
					and convert(datetime, @Time, 108)<=isnull(convert(datetime, ISNULL(rd.LimitHourPickup, sv.LimitHourPickup), 108) ,convert(datetime, '23:59:59', 108))
					
				IF OBJECT_ID('tempdb.dbo.#ParcelOverweightPerType', 'U') IS NOT NULL DROP TABLE #ParcelOverweightPerType;
				IF OBJECT_ID('tempdb.dbo.#ParcelAmountPerType', 'U') IS NOT NULL DROP TABLE #ParcelAmountPerType;
			END
		END
		ELSE
		BEGIN
        

			set @ParcelPrice =(
			select sum( isnull( ra.RateValue , isnull(ar.PriceDefault ,0) )) 
			from #ListCode ls
				inner join dbo.ArticleByCustomer ar WITH(NOLOCK) ON  ar.Code = ls.Item
				inner join dbo.RateData ra WITH(NOLOCK) ON ra.ArticleId = ar.AbcId and ra.TypeSegmentId = @IdSegment AND ra.RateId = @IdRate
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
				from dbo.RateHeader rh WITH(NOLOCK)
					 inner join dbo.RateData rd WITH(NOLOCK) ON rd.RateId = rh.RheId and rd.RowStatus ='true'
					 left join dbo.CatRateSegment sg WITH(NOLOCK) on sg.CrsId = rd.TypeSegmentId
					 left join dbo.CatTypeService sv WITH(NOLOCK) on sv.CtsId = rd.TypeServiceId
					 left join dbo.CatTypeRate cr WITH(NOLOCK) ON cr.IdTypeRate = rh.RateTypeId
				where rh.RheId = @IdRate
					and rd.ArticleId is null
					and rd.TypeSegmentId = @IdSegment
					and  (rd.TypeServiceId in(select CtsId from dbo.CatTypeService WITH(NOLOCK)  where RateGroup = @IdRateGroup and CtsRowStatus = 1) )
					and  convert(datetime, @Time, 108)<=isnull(convert(datetime, ISNULL(rd.LimitHourPickup, sv.LimitHourPickup), 108) ,convert(datetime, '23:59:59', 108))
			
        END
            --print 'rate'
			--print @IdRate
			--print 'segment'
			--print @IdSegment
			--print 'grupo'
			--print @IdRateGroup
		end
	else if @IdTypeRate = 4 -- tarifas especiales
		begin
			print 'aqui van las tarifas especiales'
		end
	-- FDD-671 INI
	ELSE IF @IdTypeRate = 5 -- tarifas por peso
	BEGIN
		--PRINT 'tarifas por peso'

		--Cálcular las piezas que no entran en rangos
		DECLARE @tblNotInRange AS TABLE (
			ID INT NULL,
			Weight DECIMAL(12,2) NULL,
			CatTypeServiceId INT NULL
		)
		
		INSERT INTO @tblNotInRange
			SELECT
				pw.ID
				,pw.Item
			   ,cts.CtsId
			FROM #ParceWeigth pw
				,CatTypeService cts
			WHERE NOT EXISTS (SELECT
					1
				FROM RateData
				WHERE RateId = @IdRate
				AND TypeSegmentId = @IdSegment
				AND TypeServiceId = cts.CtsId
				AND RowStatus = 1
				AND pw.Item BETWEEN WeightFrom AND WeightTo)
			AND cts.CtsRowStatus = 1
			AND cts.RateGroup = @IdRateGroup 
		
		INSERT INTO @TempRate
		SELECT
			TypeRate
		   ,Segment
		   ,Service
		   ,SUM(BaseRate) BaseRate
		   ,DiscountName
		   ,DiscountValue
		   ,fragilRate
		   ,CollectedRate
		   ,InsuranceRate
		   ,CreditCardRate
		   ,(SUM(OverWeightRate) + IIF(@OverWeight > 0, @OverWeight, 0)) * AdditionalWeightRate OverWeightRate
		   ,IrregularParcelRate
		   ,CtsName
		   ,CtsDescription
		   ,ReturnRate
		FROM (SELECT
				ISNULL(ctr.Name, '') TypeRate
			   ,ISNULL(crs.CrsShortName, '') Segment
			   ,ISNULL(cts.CtsShortName, '') Service
			   ,ISNULL(rd.RateValue, 0) BaseRate
			   ,'' DiscountName
			   ,0 DiscountValue
			   ,IIF(@IsFragile = 'true', ISNULL(rh.FragilRate, 0), 0) AS fragilRate
			   ,IIF(@IsCollected = 'true', ISNULL(rh.CollectRate, 0), 0) AS CollectedRate
			   ,IIF(@IsInsurance = 'true', (IIF(@InsuranceAmount > ISNULL(rh.InsuranceExempt, 0), CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2)), 0)), 0) AS InsuranceRate
			   ,IIF(@IsCreditCardPayment = 'true', ISNULL(rh.CreditCardRate, 0), 0) AS CreditCardRate
			   ,0 OverWeightRate
			   ,ISNULL(@ParcelPrice, 0) AS IrregularParcelRate
			   ,ISNULL(cts.CtsName, '') AS CtsName
			   ,ISNULL(cts.CtsDescription, '') AS CtsDescription
			   ,ISNULL(rh.ReturnRate, 0) AS ReturnRate
			   ,ISNULL(rh.AdditionalWeightRate, 0) AdditionalWeightRate
			FROM RateHeader rh
			inner JOIN RateData rd
				ON rd.RateId = rh.RheId
				AND rd.RowStatus = 1
			LEFT JOIN CatRateSegment crs
				ON crs.CrsId = rd.TypeSegmentId
			LEFT JOIN CatTypeService cts
				ON cts.CtsId = rd.TypeServiceId
			LEFT JOIN CatTypeRate ctr
				ON ctr.IdTypeRate = rh.RateTypeId
			inner JOIN #ParceWeigth pw
				ON pw.Item BETWEEN rd.WeightFrom AND rd.WeightTo
			WHERE rh.RheId = @IdRate
			AND rd.TypeSegmentId = @IdSegment
			AND (rd.TypeServiceId IN (SELECT
					CtsId
				FROM CatTypeService
				WHERE RateGroup = @IdRateGroup
				AND CtsRowStatus = 1)
			)
			AND CONVERT(DATETIME, @Time, 108) <= ISNULL(CONVERT(DATETIME, ISNULL(rd.LimitHourPickup, cts.LimitHourPickup), 108), CONVERT(DATETIME, '23:59:59', 108))
			UNION ALL
			SELECT
				ISNULL(ctr.Name, '') TypeRate
			   ,ISNULL(crs.CrsShortName, '') Segment
			   ,ISNULL(cts.CtsShortName, '') Service
			   ,ISNULL(rd.RateValue, 0) BaseRate
			   ,'' DiscountName
			   ,0 DiscountValue
			   ,IIF(@IsFragile = 'true', ISNULL(rh.FragilRate, 0), 0) AS fragilRate
			   ,IIF(@IsCollected = 'true', ISNULL(rh.CollectRate, 0), 0) AS CollectedRate
			   ,IIF(@IsInsurance = 'true', (IIF(@InsuranceAmount > ISNULL(rh.InsuranceExempt, 0), CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2)), 0)), 0) AS InsuranceRate
			   ,IIF(@IsCreditCardPayment = 'true', ISNULL(rh.CreditCardRate, 0), 0) AS CreditCardRate
			   ,IIF(pw.Weight <= @WeigthLimit, pw.Weight - rd.WeightTo, IIF(@WeigthLimit > rd.WeightTo, @WeigthLimit - rd.WeightTo, 0)) OverWeightRate
			   ,ISNULL(@ParcelPrice, 0) AS IrregularParcelRate
			   ,ISNULL(cts.CtsName, '') AS CtsName
			   ,ISNULL(cts.CtsDescription, '') AS CtsDescription
			   ,ISNULL(rh.ReturnRate, 0) AS ReturnRate
			   ,ISNULL(rh.AdditionalWeightRate, 0) AdditionalWeightRate
			FROM RateHeader rh
			inner JOIN RateData rd
				ON rd.RateId = rh.RheId
				AND rd.RowStatus = 1
			LEFT JOIN CatRateSegment crs
				ON crs.CrsId = rd.TypeSegmentId
			LEFT JOIN CatTypeService cts
				ON cts.CtsId = rd.TypeServiceId
			LEFT JOIN CatTypeRate ctr
				ON ctr.IdTypeRate = rh.RateTypeId
			inner JOIN @tblNotInRange pw
				ON pw.CatTypeServiceId = rd.TypeServiceId
				AND rd.IdRateData = (SELECT TOP 1
						IdRateData
					FROM RateData
					WHERE RateId = @IdRate
					AND TypeSegmentId = @IdSegment
					AND TypeServiceId = cts.CtsId
					AND RowStatus = 1
					ORDER BY WeightTo DESC)
			WHERE rh.RheId = @IdRate
			AND rd.TypeSegmentId = @IdSegment
			AND CONVERT(DATETIME, @Time, 108) <= ISNULL(CONVERT(DATETIME, ISNULL(rd.LimitHourPickup, cts.LimitHourPickup), 108), CONVERT(DATETIME, '23:59:59', 108))) X
		GROUP BY TypeRate
				,Segment
				,Service
				,DiscountName
				,DiscountValue
				,fragilRate
				,CollectedRate
				,InsuranceRate
				,CreditCardRate
				,IrregularParcelRate
				,CtsName
				,CtsDescription
				,ReturnRate
				,AdditionalWeightRate
	END
	-- FDD-671 FIN
	else 
	begin
		print 'error no se encontro un tarifario'
	end

	--print 'Respuesta desde tabla temporal'

	If @FormatResponse ='Json'
		begin
		declare @jsonResult as nvarchar(max)
		
		-- Desplegar valor base sin IVA
		IF(@IdRate IN (@NewMainRates, @NewAlternativeRates, @NewAutoSalesMainRates) AND @IdCustomerParams != 0)
			SET @CalculateTaxes = 'false';

		 set @jsonResult =( SELECT STUFF(( 
					select 
						',{"Title":"' + isnull(tr.ServiceName,'')  + '",' +
						'"Service":"' + IIF(@IdCustomerParams = 0 AND @IdCustomer = 6, isnull(tr.ServiceName,''), isnull(tr.Segment,'')) + '",' +
						'"ServiceDescription":"' + isnull(tr.ServiceDescription,'') + '",' +
						'"ServiceShortName":"' + isnull(tr.Service,'') + '",' +
						'"DeliveryDate":"' + Convert(varchar(24),@FechaCompra,120) + '",' +
						--'"Price":"' + convert(varchar(20), convert(decimal(12,1), (tr.BaseRate -  tr.Discount  + tr.FragilRate + tr.CollectedRate + tr.InsuranceRate  +tr.CreditCardRate + tr.OverWeightRate  + tr.IrregularPieceRate ))) + '",' +
						'"Price":"' + convert(varchar(20),  CONVERT(decimal(12,2), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.BaseRate + tr.IrregularPieceRate, 'false') ) +  CONVERT(decimal(12,2),(dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,(tr.Discount * -1),'false')  ) )  + convert(decimal(12,2),  dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.FragilRate,'false')) + convert(decimal(12,2), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.CollectedRate, 'false')) + convert(varchar(20), convert(decimal(12,2), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.InsuranceRate , 'false')))  + convert(varchar(20), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.CreditCardRate, 'false') ) + convert(varchar(20), convert(decimal(12,2), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.OverWeightRate, 'false'))) + convert(decimal(12,2), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' , (convert(decimal(12,2),tr.BaseRate) -  convert(decimal(12,2),tr.Discount)  + convert(decimal(12,2),tr.FragilRate) + convert(decimal(12,2),tr.CollectedRate) + convert(decimal(12,2),tr.InsuranceRate)  + convert(decimal(12,2),tr.CreditCardRate) + convert(decimal(12,2),tr.OverWeightRate)  + convert(decimal(12,2),tr.IrregularPieceRate) ), 'true')) ) + '",' +
						'"Currency":"' + @Currency + '",' +
						'"Integration":[{"Description":"' + 'Servicio' + '",' +
						'"Price":"' +convert(varchar(20),  CONVERT(decimal(12,2), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.BaseRate + tr.IrregularPieceRate, 'false') )) + '",' +
						'"Currency":"' + @Currency + '"' +
						'}'+
						 iif(tr.FragilRate>0, ',{"Description":"' + 'Frágil' + '",' + 
						'"Price":"' +convert(varchar(20), convert(decimal(12,2),  dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.FragilRate,'false'))) + '",' +
						'"Currency":"' + @Currency + '"' +
						'}' ,' '  ) +
						 iif(tr.InsuranceRate>0, ',{"Description":"' + 'Seguro' + '",' + 
						'"Price":"' +convert(varchar(20), convert(decimal(12,2), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.InsuranceRate , 'false'))) + '",' +
						'"Currency":"' + @Currency + '"' +
						'}' ,' '  ) +
						 iif(tr.CollectedRate>0, ',{"Description":"' + 'Pago en Destino' + '",' + 
						'"Price":"' +convert(varchar(20), convert(decimal(12,2), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.CollectedRate, 'false'))) + '",' +
						'"Currency":"' + @Currency + '"' +
						'}' ,' '  ) +
						 iif((tr.OverWeightRate)>0, ',{"Description":"' + 'Recargo por Peso' + '",' + 
						'"Price":"' +convert(varchar(20), convert(decimal(12,2), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.OverWeightRate, 'false'))) + '",' +
						'"Currency":"' + @Currency + '"' +
						'}' ,' '  ) +
						iif((tr.CreditCardRate)>0, ',{"Description":"' + 'Recargo por pago con tarjeta' + '",' + 
						'"Price":"' + convert(varchar(20), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,tr.CreditCardRate, 'false') ) + '",' +
						'"Currency":"' + COALESCE(@Currency,'') + '"' +
						'}' ,' '  ) +


						iif((isnull(tr.Discount,0))>0, 
							',{"Description":"' + isnull(@DiscountName,'') + '",' + 
							'"Price":"' + CONVERT(varchar, CONVERT(decimal(12,2),(dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' ,(tr.Discount * -1),'false')  ))) + '",'  +
							'"Currency":"' + COALESCE(@Currency,'') + '"' +
							'}' 
						,' '  ) +

						iif((isnull(dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' , (convert(decimal(12,2),tr.BaseRate) -  convert(decimal(12,2),tr.Discount)  + convert(decimal(12,2),tr.FragilRate) + convert(decimal(12,2),tr.CollectedRate) + convert(decimal(12,2),tr.InsuranceRate)  + convert(decimal(12,2),tr.CreditCardRate) + convert(decimal(12,2),tr.OverWeightRate)  + convert(decimal(12,2),tr.IrregularPieceRate) ), 'true'),0) ) > 0, 
						',{"Description":"' + 'IVA' + '",' +
						'"Price":"' +convert(varchar(20), convert(decimal(12,2), dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT' , (convert(decimal(12,2),tr.BaseRate) -  convert(decimal(12,2),tr.Discount)  + convert(decimal(12,2),tr.FragilRate) + convert(decimal(12,2),tr.CollectedRate) + convert(decimal(12,2),tr.InsuranceRate)  + convert(decimal(12,2),tr.CreditCardRate) + convert(decimal(12,2),tr.OverWeightRate)  + convert(decimal(12,2),tr.IrregularPieceRate) ), 'true')) ) + '",' +
						'"Currency":"' + @Currency + '"' +
						'}'
						, ' ' )+
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
			
			-- Desplegar valor base sin IVA
			IF(@IdRate IN (@NewMainRates, @NewAlternativeRates, @NewAutoSalesMainRates) AND @IdCustomerParams != 0)
				SET @CalculateTaxes = 'false';

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
		

	--PRINT 'precio'
	
END