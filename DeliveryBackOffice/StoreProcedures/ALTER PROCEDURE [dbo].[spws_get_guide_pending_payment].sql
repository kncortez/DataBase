USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_get_guide_pending_payment]    Script Date: 17/06/2021 11:58:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-05-21>
-- Description:	<Devuleve el monto a cobrar >
-- =============================================

ALTER PROCEDURE [dbo].[spws_get_guide_pending_payment]
	@InGuides varchar(max)
	 ,@InTime  int 
	 ,@IsReturn bit
	 ,@CodeApp varchar(100)
	 ,@IdModule int
	 ,@Token varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @InSequenceTime int
	DECLARE @TimeShortName varchar(10)
	DECLARE @InCollectCOD bit

	DECLARE @MaxTime int 
	DECLARE @MaxSequenceTime int
	DECLARE @MinTime int 
	DECLARE @MinSequenceTime int

	select @InSequenceTime = ISNULL(cpt.TimeSequence,0)
		,@TimeShortName = ISNULL(cpt.TimePlaAbrev,'')
		,@InCollectCOD = isnull(cpt.CollectCOD,0)
	from dbo.CatPaymentTime cpt 
	where cpt.TimePlaId = @InTime

	select @MaxTime = ISNULL(cpt.TimePlaId,1) 
		,@MaxSequenceTime = ISNULL(cpt.TimeSequence,0)
	from dbo.CatPaymentTime cpt 
	where cpt.TimeSequence = (select  max(cpt.TimeSequence) from dbo.CatPaymentTime cpt )

	select @MinTime = ISNULL(cpt.TimePlaId,1) 
		,@MinSequenceTime = ISNULL(cpt.TimeSequence,0)
	from dbo.CatPaymentTime cpt 
	where cpt.TimeSequence = (select  min(cpt.TimeSequence) from dbo.CatPaymentTime cpt )


	IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
	IF OBJECT_ID('tempdb.dbo.#TempPrice', 'U') IS NOT NULL DROP TABLE #TempPrice;
	IF OBJECT_ID('tempdb.dbo.#RevalueGuides', 'U') IS NOT NULL DROP TABLE #RevalueGuides;

	select distinct SUBSTRING(Item, 1,2) ItemSerie,
		SUBSTRING(Item,3, iif(CHARINDEX('-',Item)=0, (len(item)) , (CHARINDEX('-',Item)- 3))) ItemNumber 
	into #listGuides
	from DeliveryBackOffice.dbo.SplitUnlimited(@InGuides,',')


	---- Revalorizar guias que no tengan un precio asociado ---------------------------------------------

	select ord.Guide_Serie , ord.Guide_Number
	Into #RevalueGuides
	from #listGuides lst
		join dbo.DeliveryOrder ord on ord.Guide_Number = lst.ItemNumber and ord.Guide_Serie = lst.ItemSerie
	where ord.PriceShippment is null or ord.PriceShippment <=0

	DECLARE @count INT;
	SET @count = 1;
	DECLARE @RevalueSerie varchar(10) 
	DECLARE @RevalueGuide int
		
	declare @IdMax as int = (SELECT COUNT(*) FROM #RevalueGuides)
	 declare @RC  int

	WHILE @count<= @IdMax
	BEGIN
		
		SELECT TOP 1 
			@RevalueSerie = rv.Guide_Serie
			,@RevalueGuide = rv.Guide_Number
		FROM #RevalueGuides rv;

EXECUTE @RC = [dbo].[spws_revalue_guide] 
		   @GuideSerie = @RevalueSerie
		  ,@GuideNumber =@RevalueGuide
		  ,@CodeApp = @CodeApp
		  ,@Format = 'Non'
		  ,@CalculateTaxes ='true'
		  ,@IdModule = @IdModule
		  ,@SetUpdate ='true'
		  ,@Token = @Token
		  ,@IsReturn = @IsReturn
		SET @count = @count + 1;
		DELETE TOP (1) FROM #RevalueGuides
	END


	

	-----------------------------------------------------------------------------------------------------


	select ord.Guide_Serie						[GuideSerie]
		, ord.Guide_Number						[GuideNumber]
		, ord.IsCollect							[IsCollect]
		, ord.PriceShippment					[Price]
		, ord.Collect_OnDelivery				[COD]
		, cst.TotalAmountPaid					[AmountPaid]
		, cst.CODAmount							[CODPaid]
		, IIF(cst.CODAmount is null,0,1)		[CODIsPaid]
		, ISNULL(pyt.TimePlaId, iif(cdp.ConditionOfPaymenAbbreviation is null, @MinTime , @MaxTime))	[PaymentTime]
		, ISNULL(tim.TimeSequence,iif(cdp.ConditionOfPaymenAbbreviation is null, @MinSequenceTime , @MaxSequenceTime) )	[TimeSequence]
		, inh.inv_certificationFEL				[FelNumber]
		, iif(inh.inv_certificationFEL is null, iif(isnull(cst.TotalAmountPaid,0) =0,0, 1)  ,1) [IsPaid]
		,  isnull( ord.IdCustomer, vpc.CustomerID)										[IsCustomer]
		,cdp.ConditionOfPaymenDescription							[ConditionPayment]
		, IIF(cdp.ConditionOfPaymenAbbreviation is null ,0,1)		[HaveCredit]
		, isnull(@InCollectCOD,0)			[CollectCOD]
		, isnull( isnull(rh.ReturnRate,rhd.ReturnRate),100) [ReturnRate]
	into #TempPrice
	from #listGuides lg
		join dbo.DeliveryOrder ord on ord.Guide_Serie = lg.ItemSerie and ord.Guide_Number = lg.ItemNumber
		left join dbo.Cost cst on cst.ProductNumber = concat(lg.ItemSerie , lg.ItemNumber)
		left join dbo.DeliveryOrderPaymentDetail pyt on  pyt.GuideSerie = lg.ItemSerie and pyt.GuideNumber = lg.ItemNumber
		left join dbo.InvoiceDetail ind on ind.dti_fk_orderSerie = lg.ItemSerie and ind.dti_fk_orderNumber = lg.ItemNumber
		left join dbo.CatPaymentTime tim on tim.TimePlaId = pyt.TimePlaId
		Left join dbo.invoiceHeader inh on inh.inv_pk_id = ind.dti_fk_header
		left join  dbo.VisitPointClient vpc on vpc.CodeOfReference = ord.Sender_ID
		left join dbo.Customer cus on cus.IdCustomer = isnull( ord.IdCustomer, vpc.CustomerID)	
		left join dbo.CatConditionOfPayment cdp on cdp.IdConditionOfPayment = cus.ConditionOfPaymentID and cdp.IdConditionOfPayment>1
		left join dbo.RatebyCustomer rc on rc.RbcIdCustomer = isnull( ord.IdCustomer, vpc.CustomerID)	
		left join dbo.RateHeader rh on rh.RheId = rc.RbcIdRate 
		left join dbo.RateHeader rhd on rhd.RheDefault = 'true' and RowSatus = 1
		order by lg.ItemSerie, lg.ItemNumber

--select top 10 * from dbo.InvoiceHeader
--where inv_creditNote is not null
--order by 1 desc

--select dti_fk_orderSerie , dti_fk_orderNumber,   count(*)  from dbo.InvoiceDetail
--group by dti_fk_orderSerie , dti_fk_orderNumber
--order by 3 desc


	select  tp.*,
		CASE tp.IsPaid
			when 1 then 0    -- esta pagado
			else  -- no esta pagado
				case when @IsReturn = 'false' then
					case tp.HaveCredit
						when 1 then --- cliente tiene credito
							case @TimeShortName 
								WHEN 'POST' THEN Tp.Price
							else
								0
							end
						else 		-- cliente no tiene credito
							case 
								when  tp.TimeSequence<=  @InSequenceTime then
									tp.Price
								else 0
							end
						end
				else
					tp.Price
				end
 			end [AmountToPay]
			--,@InTime
			--,@InSequenceTime
			--,@TimeShortName
			, iif(tp.CollectCOD ='true', tp.COD,0) [CODAmount]
			, convert(decimal(12,2),  iif(@IsReturn = 'true', ( tp.Price *(tp.ReturnRate/100)  ),0)) [ReturnRate]
	from #TempPrice tp
	---where tp.Price is null or tp.Price =0
	order by tp.IsCustomer, tp.GuideNumber

	
END