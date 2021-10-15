USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sphdGetCatalog]    Script Date: 14/10/2021 17:36:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-04-20>
-- Description:	<Devuevlve el listado de items asociados a un catalogo especifico>
-- =============================================
ALTER PROCEDURE [dbo].[sphdGetCatalog]
	-- Add the parameters for the stored procedure here
	@IdCorrelative int  = -1,
	@Calalog as nvarchar(50) = 'all',
	@IdFilter as nvarchar(10) = 'GT' ,
	@IdModule as int = 19,
	@IdParentFilter as int = -1 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		SET @Calalog = UPPER(@Calalog);
		declare @NameOfCatalog as nvarchar(50) = ''

		IF OBJECT_ID('tempdb.dbo.#Catalogs', 'U') IS NOT NULL DROP TABLE #Catalogs;

		select ModuleID,
			   cbm.NameCatalog
				INTO #Catalogs 
		from CatalogbyModule cbm
		where cbm.ModuleID = @IdModule 
		and cbm.RowStatus = 'TRUE'
		and (@Calalog = 'ALL' OR  cbm.NameCatalog = @Calalog)

	    DECLARE @count INT;
		SET @count = 1;
		
		declare @IdMax as int = (SELECT COUNT(*) FROM #Catalogs)

		WHILE @count<= @IdMax
		BEGIN
			print @count
			
		   SELECT TOP 1  @NameOfCatalog = ctl.NameCatalog FROM #Catalogs ctl;
		   print @NameOfCatalog
		   IF (@NameOfCatalog = 'SaleAdvisor')
			BEGIN
	
					SELECT  [IdSaleAdvisor]										        [IdValue],
									'[' + [SaleAdvisorCode] + '] - ' +
									[SaleAdvisorDescription]							[NameValue],
									[SAPSellerID]										[Asssitant],
									[CountryID]											[IdFilter],
									'SaleAdvisor'									    [Catalog]
					FROM [DeliveryBackOffice].[dbo].[CatSaleAdvisor] csa
					WHERE csa.SaleAdvisorStatus = 'TRUE'
					AND (@IdCorrelative = -1 OR csa.IdSaleAdvisor = @IdCorrelative)
					AND (@IdFilter = '' OR csa.CountryID = @IdFilter)
					ORDER BY [SaleAdvisorDescription] ASC 
		   END 

		   IF (@NameOfCatalog = 'TypeOfBusiness')
		   BEGIN
				SELECT ctb.IdTypeOfBusiness   [IdValue],
					   ctb.TypeOfBusinessName [NameValue],
					   ctb.CountryID          [IdFilter],
					   'TypeOfBusiness'       [Catalog]
				FROM CatTypeOfBusiness ctb
				WHERE ctb.RowStatus = 'TRUE'
				AND (@IdCorrelative = -1 OR ctb.IdTypeOfBusiness = @IdCorrelative)
				AND (@IdFilter = '' OR ctb.CountryID = @IdFilter)
				ORDER BY ctb.TypeOfBusinessName
			END 

		   IF (@NameOfCatalog = 'BusinessSegment')
			BEGIN
				  SELECT CBS.[IdBusinessSegment]			[IdValue],
						 CBS.[BusinessSegmentName]				[NameValue],
						 CBS.BusinessSegmentDescription		[Description],
						 'BusinessSegment'								[Catalog]
				  FROM [DeliveryBackOffice].[dbo].[CatBusinessSegment] CBS
				  WHERE CBS.[RowStatus]  = 'TRUE'
				  AND (@IdCorrelative = -1 OR CBS.IdBusinessSegment = @IdCorrelative)
				  ORDER BY CBS.[BusinessSegmentName]
			END

           IF (@NameOfCatalog = 'BusinessActivity')
			BEGIN
					SELECT CBA.[IdBusinessActivity]        [IdValue],
						   CBA.[BusinessActivityName]	   [NameValue],
						   'BusinessActivity'       [Catalog]
					FROM [DeliveryBackOffice].[dbo].[CatBusinessActivity] CBA
					WHERE [RowStatus] = 'TRUE'
					AND (@IdCorrelative = -1 OR CBA.IdBusinessActivity = @IdCorrelative)
					ORDER BY CBA.[BusinessActivityName]
			END

	 	   IF (@NameOfCatalog = 'CommercialSegment')
			BEGIN
					SELECT [IdCommercialSegment]	[IdValue]
						  ,[CommercialSegmentName]	[NameValue]
						  ,'CommercialSegment'	[Catalog]
					FROM [DeliveryBackOffice].[dbo].[CatCommercialSegment] CCS
					WHERE CCS.RowStatus = 'TRUE'
					 AND (@IdCorrelative = -1 OR CCS.[IdCommercialSegment] = @IdCorrelative)
					ORDER BY CCS.[CommercialSegmentName]
			END

		   IF (@NameOfCatalog = 'ConditionOfPayment')
			BEGIN
				  SELECT CCP.[IdConditionOfPayment]				[IdValue],
						 CCP.[ConditionOfPayment]				[NameValue],
						 CCP.[ConditionOfPaymenDescription]		[Description],
						 CCP.[ConditionOfPaymenAbbreviation]	[Asssitant],
						 'ConditionOfPayment'				    [Catalog]
				  FROM [DeliveryBackOffice].[dbo].[CatConditionOfPayment] CCP
				  WHERE CCP.[RowStatus] = 'TRUE'
				  AND (@IdCorrelative = -1 OR CCP.IdConditionOfPayment = @IdCorrelative)
				  
			END

		   IF (@NameOfCatalog = 'DeliveryBank')
			BEGIN
				  SELECT 
						dbk.[Id_bank]		[IdValue],
						dbk.[Name]			[NameValue],
						dbk.[Description]	[Description],
						dbk.[Acronym]		[Asssitant],
						dbk.[URL_logo]		[URI], 
						dbk.[Id_country]	[IdFilter],
						'DeliveryBank'		[Catalog]
				  FROM [DeliveryBackOffice].[dbo].[DeliveryBank] dbk
				  WHERE dbk.[Id_status] = 1
				  AND   dbk.[Id_country] = @IdFilter
				  ORDER BY dbk.[Name]
			END

		   IF (@NameOfCatalog = 'DeliveryCurrency')
		   BEGIN
				SELECT curr.[Currency_Id]                [IdValue],
					   UPPER(curr.[Currency_Name])		 [NameValue],
					   curr.[Currency_IdCountry]         [IdFilter]
					  ,curr.[Currency_Symbol]	         [Asssitant],
					  'DeliveryCurrency'				 [Catalog]
				FROM [DeliveryBackOffice].[dbo].[DeliveryCurrency] curr
				WHERE [Currency_Status] = 1
				AND (@IdCorrelative = -1 OR curr.Currency_Id = @IdCorrelative)
				AND (@IdFilter = '' or curr.Currency_IdCountry = @IdFilter)
			END 

           IF (@NameOfCatalog = 'BankAccountType')
		   BEGIN
				SELECT CBA.[IdBankAccountType]  [IdValue],
					   CBA.[BankAccountType]	    [NameValue],
					  'BankAccountType'    [Catalog]
					FROM [DeliveryBackOffice].[dbo].[CatBankAccountType] CBA
					WHERE CBA.[RowStatus] = 'TRUE'
					AND (@IdCorrelative = -1 OR CBA.IdBankAccountType = @IdCorrelative)
		
			END 

		   IF (@NameOfCatalog = 'RateType')
		   BEGIN
				SELECT IdTypeRate    [IdValue],
					   UPPER(Name)	 [NameValue],
					  'RateType'	 [Catalog]
				from dbo.CatTypeRate  CTR
					WHERE RowStatus ='TRUE'
					AND (@IdCorrelative = -1 OR CTR.IdTypeRate = @IdCorrelative)
			END 

		   IF (@NameOfCatalog = 'RateCatalog')
		   BEGIN
				SELECT RheId			 [IdValue],
					   UPPER(RheName)	 [NameValue],
					   hr.RateTypeId	 [IdFilter],
					  'RateCatalog'	     [Catalog]
				from dbo.RateHeader hr
				where hr.RheRowStatus ='TRUE' 
				AND (@IdCorrelative = -1 OR hr.RheId  = @IdCorrelative)
				AND (@IdParentFilter = -1 OR hr.RateTypeId = @IdParentFilter)
				--AND hr.IsTemplate = 'TRUE' --no hay forma de mostrar cuando es clonable y cuando no es clonable
			END 

			IF (@NameOfCatalog = 'HubLogistics')
			BEGIN
				SELECT 

				hub.IdHubLogistic				[IdValue],
				UPPER(hub.HubName)				[NameValue],
				UPPER(hub.HubAbbreviation)		[Asssitant],
				hub.IdCountry					[IdFilter],
				'HubLogistics'					[Catalog]
				FROM HubLogistics hub
				WHERE hub.HubStatus = 'TRUE'
				AND (@IdCorrelative = -1 OR hub.IdHubLogistic = @IdCorrelative)
				AND (@IdFilter = '' OR hub.IdCountry = @IdFilter)
				ORDER BY hub.HubName 
			END 

			
			IF (@NameOfCatalog = 'TransportCompany')
			BEGIN
				SELECT 
				trans.IdTransportCompany			[IdValue],
				UPPER(trans.TransportCompanyName)	[NameValue],
				trans.TansportCompanyAbbreviation	[Asssitant],
				trans.CountryID						[IdFilter],
				'TransportCompany'					[Catalog]
				FROM CatTransportCompany trans
				WHERE trans.RowStatus = 'TRUE'
				AND (@IdCorrelative = -1 OR trans.IdTransportCompany = @IdCorrelative)
				AND (@IdFilter = '' OR trans.CountryID = @IdFilter)
				ORDER BY trans.TransportCompanyName 
			END 

			IF (@NameOfCatalog = 'Province')
			BEGIN
				SELECT 
				prov.IdProvince				[IdValue],
				UPPER(prov.ProvinceName)	[NameValue],
				prov.ProvinceAbbreviation	[Asssitant],
				prov.IdCountry				[IdFilter],
				'Province'					[Catalog]
				FROM  dbo.Province prov
				WHERE prov.ProvinceStatus  = 'TRUE'
				AND (@IdCorrelative = -1 OR prov.IdProvince = @IdCorrelative)
				AND (@IdFilter = '' OR prov.IdCountry = @IdFilter)
				ORDER BY prov.ProvinceName 
			END 
		   
			IF (@NameOfCatalog = 'Township')
			BEGIN
				SELECT 
				twn.IdTownship				[IdValue],
				UPPER(twn.TownshipName)		[NameValue],
				twn.IdProvince				[IdFilter],
				'Township'					[Catalog]
				FROM  dbo.Township twn
				WHERE twn.TownshipStatus  = 'TRUE'
				AND (@IdCorrelative = -1 or twn.IdTownship = @IdCorrelative)
				AND (@IdParentFilter = -1 OR twn.IdProvince = @IdParentFilter)
				ORDER BY twn.TownshipName
			END 

			IF (@NameOfCatalog = 'Settlement')
			BEGIN
				SELECT 
				setl.IdSettlement			[IdValue],
				UPPER(setl.Settlement)		[NameValue],
				setl.IdTownship				[IdFilter],
				'Settlement'				[Catalog]
				FROM  dbo.Settlement setl
				WHERE setl.SettlementSatus  = 'TRUE'
				AND (@IdCorrelative = -1 OR setl.IdSettlement = @IdCorrelative)
				AND (@IdParentFilter = -1 OR setl.IdTownship = @IdParentFilter)
				ORDER BY setl.Settlement
			END 

			IF (@NameOfCatalog = 'KindOfVPBusiness')
			BEGIN
				SELECT 
				kbs.IdKindOfVPBusiness				[IdValue],
				UPPER(kbs.KindOfVPNameBussiness)	[NameValue],
				'KindOfVPBusiness'					[Catalog]
				FROM  dbo.KindOfVPBusiness kbs
				WHERE kbs.StatusKindOfVPBusiness  = 'TRUE'
				AND (@IdCorrelative = -1 or kbs.IdKindOfVPBusiness = @IdCorrelative)
				
				ORDER BY KBS.KindOfVPNameBussiness 
			END 

			IF (@NameOfCatalog = 'KindOfVPClient')
			BEGIN
				SELECT 
				koc.IdKindOfVPClient		[IdValue],
				UPPER(koc.KindOfVPName)		[NameValue],
				'KindOfVPClient'			[Catalog]
				FROM  dbo.KindOfVPClient koc
				WHERE koc.KindOfVPStatus  = 'TRUE'
				AND (@IdCorrelative = -1 or koc.IdKindOfVPClient = @IdCorrelative)
				AND koc.IdKindOfVPClient not in (5) --estos son los puntos (bodegas dinamicas) que hace los clientes integrados
				--AND koc.DateCreated >= '2021-08-19'
				ORDER BY koc.KindOfVPName 
			END 

			IF (@NameOfCatalog = 'Route')
			BEGIN
				   SELECT crt.IdRoute        [IdValue],
				   UPPER(crt.CodeRoute)	     [NameValue],
				   crt.IdTypeRoute		     [IdFilter],
				   'Route'	     		     [Catalog]
				   FROM dbo.CatRoute crt
				   WHERE crt.RowStatus = 'TRUE'
				   AND (@IdCorrelative = -1 or crt.IdRoute = @IdCorrelative)
				   AND (@IdParentFilter = -1 OR crt.IdTypeRoute = @IdParentFilter)
			END


			IF (@NameOfCatalog = 'RateSegment')
			BEGIN
				SELECT csg.CrsId					[IdValue],
				       UPPER(csg.CrsName)			[NameValue],
					   UPPER(csg.CrsDescription)	[Description],
					   'RateSegment'				[Catalog]
				FROM dbo.CatRateSegment csg
				WHERE csg.CrsRowStatus = 'TRUE'
				 AND (@IdCorrelative = -1 or csg.CrsId = @IdCorrelative)
			END

			
		   IF (@NameOfCatalog = 'ArticleList')
		   BEGIN
			   SELECT ac.AbcId [IdValue]
					, CONCAT( ac.Code,'  -  ', ta.TarName,'-', ca.ArtName) [NameValue],
					@NameOfCatalog	 [Catalog]
				FROM dbo.ArticleByCustomer ac
					LEFT JOIN DBO.CatArticle ca ON ca.ArtId = ac.AbcIdArticle
					LEFT JOIN dbo.CatTypeArticle ta ON ta.TarId =ca.ArtIdTypeArticle
				WHERE ac.AbcRowStatus ='TRUE'
			END 

			IF (@NameOfCatalog = 'SalesChannel')
			BEGIN
				SELECT 
				CSC.IdSalesChannel		[IdValue],
				UPPER(CSC.Description)		[NameValue],
				'SalesChannel'			[Catalog]
				FROM  DeliveryBackOffice.dbo.CatSalesChannel CSC
				WHERE CSC.RowStatus  = 'TRUE'
				AND (@IdCorrelative = -1 or CSC.IdSalesChannel = @IdCorrelative)			
				ORDER BY CSC.Description
			END 

			IF (@NameOfCatalog = 'ExpressCenter')
			BEGIN
				SELECT vpc.CodeOfReference		[IdValue],
						vpc.DescriptionOfClient [NameValue],
						vpc.CountryId			[IdFilter],
						'ExpressCenter'		[Catalog]
				FROM dbo.VisitPointClient vpc
				WHERE vpc.StatusClient = 'TRUE'
				AND vpc.CustomerID = 81  --FD EXPRESS CENTER
				AND (@IdFilter = '' OR vpc.CountryId = @IdFilter)
				AND (@IdCorrelative = -1 or vpc.CodeOfReference  = @IdCorrelative)
				ORDER BY vpc.DescriptionOfClient
			END 
			----------------- catalogos nuevos CatBatchTypeCOD y CatBatchFrequencyCOD
			IF (@NameOfCatalog = 'BatchTypeCOD')
			BEGIN
				SELECT cbt.CatBatchTypeCODId		[IdValue],
						cbt.Name [NameValue],
						'BatchTypeCOD'		[Catalog]
				FROM DeliveryBackOffice.dbo.CatBatchTypeCOD cbt
        LEFT JOIN DeliveryBackOffice.dbo.Customer cu ON cu.CatBatchTypeCODId = cbt.CatBatchTypeCODId
        AND cbt.RowStatus = 1
				WHERE cbt.RowStatus = 'TRUE'
				AND (@IdCorrelative = -1 OR cu.IdCustomer = @IdCorrelative)
				ORDER BY cbt.Name

			END 

			IF (@NameOfCatalog = 'BatchFrequencyCOD')
			BEGIN
				SELECT cbf.CatBatchFrequencyCODId		[IdValue],
						cbf.Name [NameValue],
						'BatchFrequencyCOD'		[Catalog]
				FROM DeliveryBackOffice.dbo.CatBatchFrequencyCOD cbf
        LEFT JOIN DeliveryBackOffice.dbo.Customer cu ON cu.CatBatchFrequencyCODId = cbf.CatBatchFrequencyCODId
        AND cbf.RowStatus = 1
				WHERE cbf.RowStatus= 'TRUE'
        AND (@IdCorrelative = -1 OR cu.IdCustomer = @IdCorrelative)
				ORDER BY cbf.Name
			END 
			---------------------------------------------------------------------------

		   SET @count = @count + 1;
		   DELETE TOP (1) FROM #Catalogs
	END;



END
