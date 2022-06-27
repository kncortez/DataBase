

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_cod_amount]
	@ProductNumber Nvarchar(max)  
	,@Token varchar(50) 
	,@IdModule INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

			-- Insert statements for procedure here
		IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
		IF OBJECT_ID('tempdb.dbo.#TempData', 'U') IS NOT NULL DROP TABLE #TempData;
		IF OBJECT_ID('tempdb.dbo.#CODData', 'U') IS NOT NULL DROP TABLE #CODData;
		IF OBJECT_ID('tempdb.dbo.#RevalueGuides', 'U') IS NOT NULL DROP TABLE #RevalueGuides;

		 Select distinct SUBSTRING(Item, 1,2) ItemSerie,
				SUBSTRING(Item,3, iif(CHARINDEX('-',Item)=0, (len(item)) , (CHARINDEX('-',Item)- 3))) ItemNumber 
		into #listGuides
		from DeliveryBackOffice.dbo.SplitUnlimited(@ProductNumber,',');

		DECLARE @IdRateDefault int = (select top 1 rhd.RheId  from DBO.RateHeader rhd where rhd.RheRowStatus = 1 and rhd.RheDefault = 1)
		DECLARE @IdRate int

		DECLARE @CODRateDefault decimal(12,2) = (select CONVERT(decimal(12,2), isnull(cf.Value,'0')) val from dbo.ConfigParams cf where cf.Name ='CODRateDef' and Status =1)

		DECLARE @CODExemptDefault decimal(12,2) = (select CONVERT(decimal(12,2), isnull(cf.Value,'0')) val from dbo.ConfigParams cf where cf.Name ='CODExemptDef' and Status =1)

		---- Revalorizar guias que no tengan un precio asociado ---------------------------------------------

			select ord.Guide_Serie , ord.Guide_Number
			Into #RevalueGuides
			from #listGuides lst
				join dbo.DeliveryOrder ord on ord.Guide_Number = lst.ItemNumber and ord.Guide_Serie = lst.ItemSerie
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[PromoCoupon] PC WITH(NOLOCK)
					ON lst.ItemSerie = PC.GuideSerieDestination
						AND lst.ItemNumber = PC.GuideNumberDestination
						AND PC.RowStatus = 1
			where (ord.PriceShippment is null -- precion nulo
				or ord.PriceShippment  <=0  -- precio 0
				or ord.StatusOrderId = 14)  -- guias devuletas
				AND PC.IdPromoCoupon IS NULL

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
				  ,@CodeApp = ''
				  ,@Format = 'Non'
				  ,@CalculateTaxes ='true'
				  ,@IdModule = @IdModule
				  ,@SetUpdate ='true'
				  ,@Token = @Token
				  ,@IsReturn = 'false'
				SET @count = @count + 1;
				DELETE TOP (1) FROM #RevalueGuides
			END

			-----------------------------------------------------------------------------------------------------

		select lst.* 
			, ord.Sender_ID 
			, ord.Collect_OnDelivery
			, isnull(ord.IdCustomer, vpc.CustomerID) IDCUSTOMER
			, isnull(rc.RbcIdRate ,@idRateDefault) IdRate
			, iif( ord.TypeService ='EXP' ,'NDD', isnull(ord.TypeService,'NDD')) Serv
			, twn.HeaderCode
			, (select top 1 hb.IdHubLogistic from dbo.DumpServiceCoverage cv 
					 join dbo.HubLogistics hb on hb.HubAbbreviation = cv.Hub	
				where cv.HeaderCode =twn.HeaderCode ) Hub
			, csv.CtsId IdService
			, ord.DCBA_ID 
		Into #TempData
		from  #listGuides lst
			join dbo.DeliveryOrder ord on ord.Guide_Serie = lst.ItemSerie and ord.Guide_Number = lst.ItemNumber
			left join dbo.VisitPointClient vpc on vpc.CodeOfReference = ord.Sender_ID
			LEFT JOIN dbo.RatebyCustomer rc on rc.RbcIdCustomer =isnull(ord.IdCustomer, vpc.CustomerID) and rc.RbcRowStatus ='true'
			left join dbo.Township twn on twn.IdTownship =   isnull( isnull(isnull(ord.ReceiverIdTownship , vpc.IdTownship), (select  top 1 st.IdTownship from dbo.Settlement st where st.IdSettlement = vpc.IdSettlement)), (select top 1  IdTownship from dbo.Township twn where twn.TownshipName =ord.Receiver_Town and twn.TownshipStatus ='true') )
			--eft join dbo.DumpServiceCoverage dmp on dmp.HeaderCode = 
			left join dbo.CatTypeService csv on csv.CtsShortName = iif( ord.TypeService ='EXP' ,'NDD', isnull(ord.TypeService,'NDD')) and csv.CtsRowStatus ='true'
			--LEFT JOIN dbo.VisitPointCoverage vco on vco.VisitPointId = ord.Sender_ID 
			--left join dbo.RateCOD rco on rco.RateId = isnull(rc.RbcIdRate ,@idRateDefault)

			DECLARE @IdSegmentDefault int =( select TOP 1 CrsId from dbo.CatRateSegment where CrsShortName ='FOR' and CrsRowStatus  ='true')

			select td.*
			, isnull(cv.SegmentId,@IdSegmentDefault) IdSegment
			,isnull(rc.CODRate, @CODRateDefault) CODRate
			,isnull(rc.CODExempt, @CODExemptDefault) CODExempt
			,  convert(decimal(12,2), ( (isnull(td.Collect_OnDelivery,0) - isnull(rc.CODExempt, @CODExemptDefault)  )*  isnull(rc.CODRate, @CODRateDefault) /100   )) Commission
			into #CODData
			from #TempData td
				left join dbo.VisitPointCoverage cv on cv.VisitPointId = td.Sender_ID and cv.HubLogisticId = td.Hub  and cv.RowStatus  ='true'
				left join dbo.RateCOD rc on rc.RateId = td.IdRate and rc.TypeServiceId = td.IdService and rc.TypeSegmentId = isnull(cv.SegmentId,@IdSegmentDefault) and rc.RowStatus = 1
			ORDER BY td.IDCUSTOMER , td.ItemSerie , td.ItemNumber, td.Collect_OnDelivery

		--select * from dbo.RateCOD


			DECLARe @MaxPaymentTIme int = (select top 1 (pt.TimePlaId -1) from dbo.CatPaymentTime pt where pt.TimePlaStatus =1  and pt.TimeSequence = (select max(ps.TimeSequence) from dbo.CatPaymentTime ps where ps.TimePlaStatus = 1) )

			declare @PendingPaymentTemp as table
				(	GuideSerie			nvarchar (25) null,
					GuideNumber			INT,
					IsCollect			BIT,
					Price				decimal (14,2) null,
					COD					decimal (14,2) null,
					AmountPaid			decimal (14,2) null,
					CODPaid				decimal (14,2) null,
					CODIsPaid			BIT,
					PaymentTime			int null,
					TimeSequence		int null,
					FelNumber			nvarchar (50) null,
					IsPaid				BIT,
					IsCustomer			int null,
					ConditionPayment	VARCHAR(200),
					HaveCredit			BIT,
					CollectCOD			BIT,
					ReturnRate			decimal (14,2) null,
					AmountToPay			decimal (14,2) null,
					CODAmount			decimal (14,2) null,
					ReturnRates			decimal (14,2) null)
			INSERT INTO @PendingPaymentTemp (GuideSerie,GuideNumber,IsCollect,Price,COD,AmountPaid,CODPaid
				,CODIsPaid,PaymentTime,TimeSequence	,FelNumber,IsPaid,IsCustomer
				,ConditionPayment,HaveCredit,CollectCOD,ReturnRate,AmountToPay,CODAmount,ReturnRates)
			EXEC  [dbo].[spws_get_guide_pending_payment]
						@InGuides = @ProductNumber,
						@InTime = @MaxPaymentTIme,
						@IsReturn = 'false',
						@CodeApp = 'SIFDCECOM300720201459',
						@IdModule = @IdModule,
						@Token = @Token



			SELECT  DISTINCT tp.ItemSerie
				, tp.ItemNumber
				, tp.Collect_OnDelivery
				, tp.IDCUSTOMER 
				, tp.CODRate
				, tp.CODExempt
				, tp.Commission
				, pp.AmountToPay DeliveryPrice
				, pp.CODPaid
				, pp.ReturnRates
				, pp.CODIsPaid
				, bk.Id_bank
				, bk.Name
				, dc.DCBA_Id
				, dc.DCBA_Num_account
				, dc.DCBA_Nom_account
				, dc.DCBA_BankAccountType
				, dc.DCBA_Identification
				, op.Deposit_Number
				, iif(op.Deposit_Number is null,( tp.Collect_OnDelivery - tp.Commission - pp.AmountToPay - pp.ReturnRates  ), 0) as CODtoPay
				FROM #CODData tp
				left join @PendingPaymentTemp pp on pp.GuideSerie = tp.ItemSerie and pp.GuideNumber = tp.ItemNumber
				left join dbo.DeliveryOrderPaid op on op.Guide_Serie = tp.ItemSerie and op.Guide_Number = tp.ItemNumber
				left join dbo.DeliveryCustomerBankAccount dc on dc.DCBA_Id = tp.DCBA_ID
				left join dbo.DeliveryBank bk on bk.Id_bank = dc.DCBA_Bank_Id
			where tp.Collect_OnDelivery >0
			order by tp.IDCUSTOMER, tp.ItemSerie, tp.ItemNumber
END
