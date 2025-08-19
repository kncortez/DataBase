-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-04-20>
-- Description:	<Devuevlve el listado de items asociados a un catalogo especifico>
-- =============================================
-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2023-03-28>
-- Description:	<agragar catalogo para opciones de tiempo de facturación y volument de facturación>
-- =============================================
-- =============================================
-- Author:		<Brandon, Pedroza>
-- Create date: <2024-06-03>
-- Description:	<se modifica para que utilice el parametro de pais para filtrar en los catalogos>
-- =============================================
-- =============================================
-- Modified:	<Brandon, Pedroza>
-- Create date: <2024-06-19>
-- Description:	<se modifica para obtener datos de la tabla CatCurrencyCOD>
-- =============================================
-- =============================================
-- Modified:	<Brandon, Pedroza>
-- Create date: <2025-06-12>
-- Description:	<Facturacion SV - Obtiene catalogos para facturacion de El Salvador>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetCatalog]
    -- Add the parameters for the stored procedure here
    @IdCorrelative INT = -1,
    @Calalog AS NVARCHAR(50) = 'all',
    @IdFilter AS NVARCHAR(10) = 'GT',
    @IdModule AS INT = 19,
    @IdParentFilter AS INT = -1
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SET @Calalog = UPPER(@Calalog);
    DECLARE @NameOfCatalog AS NVARCHAR(50) = N'';

    DECLARE @Catalogs TABLE
    (
        IdCatalog INT,
        NameCatalog VARCHAR(100)
    );

	INSERT INTO @Catalogs (IdCatalog,NameCatalog)
    SELECT ModuleID,
           cbm.NameCatalog
    FROM CatalogbyModule cbm
    WHERE cbm.ModuleID = @IdModule
          AND cbm.RowStatus = 'TRUE'
          AND
          (
              @Calalog = 'ALL'
              OR cbm.NameCatalog = @Calalog
          );

    DECLARE @count INT;
    SET @count = 1;

    DECLARE @IdMax AS INT =
            (
                SELECT COUNT(*)FROM @Catalogs
            );

    WHILE @count <= @IdMax
    BEGIN
        PRINT @count;

        SELECT TOP 1
               @NameOfCatalog = ctl.NameCatalog
        FROM @Catalogs ctl;
        PRINT @NameOfCatalog;
        IF (@NameOfCatalog = 'SaleAdvisor')
        BEGIN

            SELECT [IdSaleAdvisor] [IdValue],
                   '[' + [SaleAdvisorCode] + '] - ' + [SaleAdvisorDescription] [NameValue],
                   [SAPSellerID] [Asssitant],
                   [CountryID] [IdFilter],
                   'SaleAdvisor' [Catalog]
            FROM [DeliveryBackOffice].[dbo].[CatSaleAdvisor] csa
            WHERE csa.SaleAdvisorStatus = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR csa.IdSaleAdvisor = @IdCorrelative
                  )
                  AND
                  (
                      @IdFilter = ''
                      OR csa.CountryID = @IdFilter
                  )
            ORDER BY [SaleAdvisorDescription] ASC;
        END;

        IF (@NameOfCatalog = 'TypeOfBusiness')
        BEGIN
            SELECT ctb.IdTypeOfBusiness [IdValue],
                   ctb.TypeOfBusinessName [NameValue],
                   ctb.CountryID [IdFilter],
                   'TypeOfBusiness' [Catalog]
            FROM CatTypeOfBusiness ctb
            WHERE ctb.RowStatus = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR ctb.IdTypeOfBusiness = @IdCorrelative
                  )
                  AND
                  (
                      @IdFilter = ''
                      OR ctb.CountryID = @IdFilter
                  )
            ORDER BY ctb.TypeOfBusinessName;
        END;

        IF (@NameOfCatalog = 'BusinessSegment')
        BEGIN
            SELECT CBS.[IdBusinessSegment] [IdValue],
                   CBS.[BusinessSegmentName] [NameValue],
                   CBS.BusinessSegmentDescription [Description],
                   'BusinessSegment' [Catalog]
            FROM [DeliveryBackOffice].[dbo].[CatBusinessSegment] CBS
            WHERE CBS.[RowStatus] = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR CBS.IdBusinessSegment = @IdCorrelative
                  )
                  AND
                  (
                      @IdFilter = ''
                      OR ISNULL(CBS.IdCountry,'GT') = @IdFilter
                  )
            ORDER BY CBS.[BusinessSegmentName];
        END;

        IF (@NameOfCatalog = 'BusinessActivity')
        BEGIN
            SELECT CBA.[IdBusinessActivity] [IdValue],
                   CBA.[BusinessActivityName] [NameValue],
                   'BusinessActivity' [Catalog]
            FROM [DeliveryBackOffice].[dbo].[CatBusinessActivity] CBA
            WHERE [RowStatus] = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR CBA.IdBusinessActivity = @IdCorrelative
                  )
            ORDER BY CBA.[BusinessActivityName];
        END;

        IF (@NameOfCatalog = 'CommercialSegment')
        BEGIN
            SELECT [IdCommercialSegment] [IdValue],
                   [CommercialSegmentName] [NameValue],
                   'CommercialSegment' [Catalog]
            FROM [DeliveryBackOffice].[dbo].[CatCommercialSegment] CCS
            WHERE CCS.RowStatus = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR CCS.[IdCommercialSegment] = @IdCorrelative
                  )
            ORDER BY CCS.[CommercialSegmentName];
        END;

        IF (@NameOfCatalog = 'ConditionOfPayment')
        BEGIN
            SELECT CCP.[IdConditionOfPayment] [IdValue],
                   CCP.[ConditionOfPayment] [NameValue],
                   CCP.[ConditionOfPaymenDescription] [Description],
                   CCP.[ConditionOfPaymenAbbreviation] [Asssitant],
                   'ConditionOfPayment' [Catalog]
            FROM [DeliveryBackOffice].[dbo].[CatConditionOfPayment] CCP
            WHERE CCP.[RowStatus] = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR CCP.IdConditionOfPayment = @IdCorrelative
                  );

        END;

        IF (@NameOfCatalog = 'DeliveryBank')
        BEGIN
            SELECT dbk.[Id_bank] [IdValue],
                   dbk.[Name] [NameValue],
                   dbk.[Description] [Description],
                   dbk.[Acronym] [Asssitant],
                   dbk.[URL_logo] [URI],
                   dbk.[Id_country] [IdFilter],
                   'DeliveryBank' [Catalog]
            FROM [DeliveryBackOffice].[dbo].[DeliveryBank] dbk
            WHERE dbk.[Id_status] = 1
                  AND dbk.[Id_country] = @IdFilter
            ORDER BY dbk.[Name];
        END;

        IF (@NameOfCatalog = 'DeliveryCurrency')
        BEGIN
            SELECT CU.IdCatCurrencyCOD [IdValue],
                   UPPER(CU.Name) [NameValue],
                   curr.[Currency_IdCountry] [IdFilter],
                   curr.[Currency_Symbol] [Asssitant],
                   'DeliveryCurrency' [Catalog]
            FROM [DeliveryBackOffice].[dbo].[DeliveryCurrency] curr WITH(NOLOCK)
					INNER JOIN CatCurrencyCOD CU WITH (NOLOCK)
					ON curr.IdCurrencyCOD = CU.IdCatCurrencyCOD
            WHERE [Currency_Status] = 1
                  AND
                  (
                      @IdCorrelative = -1
                      OR curr.Currency_Id = @IdCorrelative
                  )
                  AND
                  (
                      @IdFilter = ''
                      OR curr.Currency_IdCountry = @IdFilter
                  );
        END;

        IF (@NameOfCatalog = 'BankAccountType')
        BEGIN
            SELECT CBA.[IdBankAccountType] [IdValue],
                   CBA.[BankAccountType] [NameValue],
                   'BankAccountType' [Catalog]
            FROM [DeliveryBackOffice].[dbo].[CatBankAccountType] CBA
            WHERE CBA.[RowStatus] = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR CBA.IdBankAccountType = @IdCorrelative
                  )
				  AND IIF(CBA.IdCountry IS NULL, 'GT',CBA.IdCountry) = @IdFilter;

        END;

        IF (@NameOfCatalog = 'RateType')
        BEGIN
            SELECT IdTypeRate [IdValue],
                   UPPER(Name) [NameValue],
                   'RateType' [Catalog]
            FROM dbo.CatTypeRate CTR
            WHERE RowStatus = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR CTR.IdTypeRate = @IdCorrelative
                  );
        END;

        IF (@NameOfCatalog = 'RateCatalog')
        BEGIN
            SELECT RheId [IdValue],
                   UPPER(RheName) [NameValue],
                   hr.RateTypeId [IdFilter],
				   hr.CatBusinessSegmentId [CatBusinessSegmentId],
                   'RateCatalog' [Catalog]
            FROM dbo.RateHeader hr
            WHERE hr.RheRowStatus = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR hr.RheId = @IdCorrelative
                  )
                  AND
                  (
                      @IdParentFilter = -1
                      OR hr.RateTypeId = @IdParentFilter
                  )
				  AND IIF(hr.CountryId IS NULL, 'GT',hr.CountryId) = @IdFilter;
        --AND hr.IsTemplate = 'TRUE' --no hay forma de mostrar cuando es clonable y cuando no es clonable
        END;

        IF (@NameOfCatalog = 'HubLogistics')
        BEGIN
            SELECT hub.IdHubLogistic [IdValue],
                   UPPER(hub.HubName) [NameValue],
                   UPPER(hub.HubAbbreviation) [Asssitant],
                   hub.IdCountry [IdFilter],
                   'HubLogistics' [Catalog]
            FROM HubLogistics hub
            WHERE hub.HubStatus = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR hub.IdHubLogistic = @IdCorrelative
                  )
                  AND
                  (
                      @IdFilter = ''
                      OR hub.IdCountry = @IdFilter
                  )
            ORDER BY hub.HubName;
        END;


        IF (@NameOfCatalog = 'TransportCompany')
        BEGIN
            SELECT trans.IdTransportCompany [IdValue],
                   UPPER(trans.TransportCompanyName) [NameValue],
                   trans.TansportCompanyAbbreviation [Asssitant],
                   trans.CountryID [IdFilter],
                   'TransportCompany' [Catalog]
            FROM CatTransportCompany trans
            WHERE trans.RowStatus = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR trans.IdTransportCompany = @IdCorrelative
                  )
                  AND
                  (
                      @IdFilter = ''
                      OR trans.CountryID = @IdFilter
                  )
            ORDER BY trans.TransportCompanyName;
        END;

        IF (@NameOfCatalog = 'Province')
        BEGIN
            SELECT prov.IdProvince [IdValue],
                   UPPER(prov.ProvinceName) [NameValue],
                   prov.ProvinceAbbreviation [Asssitant],
                   prov.IdCountry [IdFilter],
                   'Province' [Catalog]
            FROM dbo.Province prov 
            WHERE prov.ProvinceStatus = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR prov.IdProvince = @IdCorrelative
                  )
                  AND
                  (
                      @IdFilter = ''
                      OR prov.IdCountry = @IdFilter
                  )
            ORDER BY prov.ProvinceName;
        END;

        IF (@NameOfCatalog = 'Township')
        BEGIN
            SELECT twn.IdTownship [IdValue],
                   UPPER(twn.TownshipName) [NameValue],
                   twn.IdProvince [IdFilter],
                   'Township' [Catalog]
            FROM dbo.Township twn WITH(NOLOCK)
				INNER JOIN Province PR WITH(NOLOCK)
				ON twn.IdProvince = PR.IdProvince
            WHERE twn.TownshipStatus = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR twn.IdTownship = @IdCorrelative
                  )
                  AND
                  (
                      @IdParentFilter = -1
                      OR twn.IdProvince = @IdParentFilter
                  )
				  AND PR.IdCountry = @IdFilter
            ORDER BY twn.TownshipName;
        END;

        IF (@NameOfCatalog = 'Settlement')
        BEGIN
            SELECT setl.IdSettlement [IdValue],
                   UPPER(setl.Settlement) [NameValue],
                   setl.IdTownship [IdFilter],
                   'Settlement' [Catalog]
            FROM dbo.Settlement setl
            WHERE setl.SettlementSatus = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR setl.IdSettlement = @IdCorrelative
                  )
                  AND
                  (
                      @IdParentFilter = -1
                      OR setl.IdTownship = @IdParentFilter
                  )
                  AND setl.IdCountry = @IdFilter
            ORDER BY setl.Settlement;
        END;

        IF (@NameOfCatalog = 'KindOfVPBusiness')
        BEGIN
            SELECT kbs.IdKindOfVPBusiness [IdValue],
                   UPPER(kbs.KindOfVPNameBussiness) [NameValue],
                   'KindOfVPBusiness' [Catalog]
            FROM dbo.KindOfVPBusiness kbs
            WHERE kbs.StatusKindOfVPBusiness = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR kbs.IdKindOfVPBusiness = @IdCorrelative
                  )
				  AND IIF(kbs.IdCountry IS NULL, 'GT',kbs.IdCountry) = @IdFilter
            ORDER BY kbs.KindOfVPNameBussiness;
        END;

        IF (@NameOfCatalog = 'KindOfVPClient')
        BEGIN
            SELECT koc.IdKindOfVPClient [IdValue],
                   UPPER(koc.KindOfVPName) [NameValue],
                   'KindOfVPClient' [Catalog]
            FROM dbo.KindOfVPClient koc
            WHERE koc.KindOfVPStatus = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR koc.IdKindOfVPClient = @IdCorrelative
                  )
                  AND koc.IdKindOfVPClient NOT IN ( 5 ) --estos son los puntos (bodegas dinamicas) que hace los clientes integrados
            --AND koc.DateCreated >= '2021-08-19'
                  AND IIF(koc.IdCountry IS NULL, 'GT',koc.IdCountry) = @IdFilter
            ORDER BY koc.KindOfVPName;
        END;

        IF (@NameOfCatalog = 'Route')
        BEGIN
            SELECT crt.IdRoute [IdValue],
                   UPPER(crt.CodeRoute) [NameValue],
                   crt.IdTypeRoute [IdFilter],
                   'Route' [Catalog]
            FROM dbo.CatRoute crt WITH(NOLOCK)
			LEFT JOIN dbo.Township tw WITH(NOLOCK)
				ON crt.IdTownship = tw.IdTownship
			LEFT JOIN dbo.Province pr WITH(NOLOCK)
				ON tw.IdProvince = pr.IdProvince
            WHERE crt.RowStatus = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR crt.IdRoute = @IdCorrelative
                  )
                  AND
                  (
                      @IdParentFilter = -1
                      OR crt.IdTypeRoute = @IdParentFilter
                  )
                  AND IIF(pr.IdCountry IS NULL,'GT',pr.IdCountry) = @IdFilter;
        END;


        IF (@NameOfCatalog = 'RateSegment')
        BEGIN
            SELECT csg.CrsId [IdValue],
                   UPPER(csg.CrsName) [NameValue],
                   UPPER(csg.CrsDescription) [Description],
                   'RateSegment' [Catalog]
            FROM dbo.CatRateSegment csg
            WHERE csg.CrsRowStatus = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR csg.CrsId = @IdCorrelative
                  );
        END;


        IF (@NameOfCatalog = 'ArticleList')
        BEGIN
            SELECT ac.AbcId [IdValue],
                   CONCAT(ac.Code, '  -  ', ta.TarName, '-', ca.ArtName) [NameValue],
                   @NameOfCatalog [Catalog]
            FROM dbo.ArticleByCustomer ac
                LEFT JOIN dbo.CatArticle ca
                    ON ca.ArtId = ac.AbcIdArticle
                LEFT JOIN dbo.CatTypeArticle ta
                    ON ta.TarId = ca.ArtIdTypeArticle
            WHERE ac.AbcRowStatus = 'TRUE'
            AND IIF(ca.IdCountry IS NULL, 'GT',ca.IdCountry)= @IdFilter;
        END;

        IF (@NameOfCatalog = 'SalesChannel')
        BEGIN
            SELECT CSC.IdSalesChannel [IdValue],
                   UPPER(CSC.Description) [NameValue],
                   'SalesChannel' [Catalog]
            FROM DeliveryBackOffice.dbo.CatSalesChannel CSC
            WHERE CSC.RowStatus = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR CSC.IdSalesChannel = @IdCorrelative
                  )
				  --AND IIF(CSC.IdCountry IS NULL, 'GT',CSC.IdCountry)= @IdFilter
            ORDER BY CSC.Description;
        END;

        IF (@NameOfCatalog = 'ExpressCenter')
        BEGIN
            SELECT vpc.CodeOfReference [IdValue],
                   vpc.DescriptionOfClient [NameValue],
                   vpc.CountryId [IdFilter],
                   'ExpressCenter' [Catalog]
            FROM dbo.VisitPointClient vpc
            WHERE vpc.StatusClient = 'TRUE'
                  AND vpc.CustomerID = 81 --FD EXPRESS CENTER
                  AND
                  (
                      @IdFilter = ''
                      OR vpc.CountryId = @IdFilter
                  )
                  AND
                  (
                      @IdCorrelative = -1
                      OR vpc.CodeOfReference = @IdCorrelative
                  )
            ORDER BY vpc.DescriptionOfClient;
        END;
        ----------------- catalogos nuevos CatBatchTypeCOD y CatBatchFrequencyCOD
        IF (@NameOfCatalog = 'BatchTypeCOD')
        BEGIN
            SELECT cbt.CatBatchTypeCODId [IdValue],
                   UPPER(cbt.Name) [NameValue],
                   'BatchTypeCOD' [Catalog]
            FROM DeliveryBackOffice.dbo.CatBatchTypeCOD cbt
                LEFT JOIN DeliveryBackOffice.dbo.Customer cu
                    ON cu.CatBatchTypeCODId = cbt.CatBatchTypeCODId
                       AND cbt.RowStatus = 1
            WHERE cbt.RowStatus = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR cu.IdCustomer = @IdCorrelative
                  )
				  --AND IIF(cbt.IdCountry IS NULL, 'GT',cbt.IdCountry) = @IdFilter
            GROUP BY cbt.CatBatchTypeCODId,
                     cbt.Name
            ORDER BY cbt.Name;

        END;

        IF (@NameOfCatalog = 'BatchFrequencyCOD')
        BEGIN
            SELECT cbf.CatBatchFrequencyCODId [IdValue],
                   UPPER(cbf.Name) [NameValue],
                   'BatchFrequencyCOD' [Catalog]
            FROM DeliveryBackOffice.dbo.CatBatchFrequencyCOD cbf
                LEFT JOIN DeliveryBackOffice.dbo.Customer cu
                    ON cu.CatBatchFrequencyCODId = cbf.CatBatchFrequencyCODId
                       AND cbf.RowStatus = 1
            WHERE cbf.RowStatus = 'TRUE'
                  AND
                  (
                      @IdCorrelative = -1
                      OR cu.IdCustomer = @IdCorrelative
                  )
            GROUP BY cbf.CatBatchFrequencyCODId,
                     cbf.Name
            ORDER BY cbf.Name;
        END;
        ---------------------------------------------------------------------------

        --Reglas para la validación de cuentas de banco
        IF (@NameOfCatalog = 'AccountBankFormatRule')
        BEGIN
            SELECT db.Id_bank [DeliveryBankId],
                   abfr.CatBankAccountTypeId [CatBankAccountTypeId],
                   abfr.MinimumLength [MinimumLength],
                   abfr.MaximumLength [MaximumLength],
                   abfr.StartsWith [StartsWith],
                   abfr.Complete [Complete],
                   db.[Id_country] [IdFilter],
				   db.Id_bank [IdValue],
				   db.[Name] [NameValue],
                   'AccountBankFormatRule' [Catalog]
            FROM AccountBankFormatRule abfr
                INNER JOIN DeliveryBank db
                    ON db.Id_bank = abfr.DeliveryBankId
            WHERE db.[Id_status] = 1
                  AND db.[Id_country] = @IdFilter
                  AND abfr.RowStatus = 1;
        END;
		---------------------------------------------------------------------------

			--Rango de paquetes
			IF (@NameOfCatalog = 'PackagesRange')
			BEGIN
				SELECT
					cbs.IdBusinessSegment [IdBusinessSegment]
					,cbs.BusinessSegmentName [BusinessSegmentName]
					,pr.CatTypeRateId [IdTypeRate]
					,pr.IdPackagesRange [IdPackagesRange]
					,pr.[Range] [Range]
					,cts.CtsShortName [TypeService]
					,crs.CrsShortName [RateSegment]
					,pr.IsPercent [IsPercent]
					,prd.[Value] [Value]
					,crs2.CrsShortName [RateSegmentCOD]
					,prCOD.CODRate [CODRate]
					,prCOD.CODExempt [CODExempt]
					,pr.WeightLimit [WeightLimit]
					,pr.AdditionalWeightRate [AdditionalWeightRate]
					,pr.InsuranceRate [InsuranceRate]
					,pr.InsuranceExempt [InsuranceExempt]
					,pr.CreditCardRate [CreditCardRate]
					,pr.ReturnRate [ReturnRate]
					,pr.FragilRate [FragilRate]
					,pr.CollectRate [CollectRate]
					,pr.Attempt [Attempt]
					,pr.PiecesIncluded [PiecesIncluded]
					,cbs.IdBusinessSegment [IdValue]
					,cbs.BusinessSegmentName [NameValue]
                    ,ISNULL(pr.IdCurrency,1) [IdCurrency]--DEJA POR DEFECTO 1 -QUETZAL
					,'PackagesRange' [Catalog]
				FROM PackagesRange pr
				INNER JOIN PackagesRangeDetail prd
					ON pr.IdPackagesRange = prd.PackagesRangeId
				INNER JOIN CatBusinessSegment cbs
					ON pr.CatBusinessSegmentId = cbs.IdBusinessSegment
				INNER JOIN CatTypeService cts
					ON prd.CatTypeServiceId = cts.CtsId
				INNER JOIN CatRateSegment crs
					ON prd.CatRateSegmentId = crs.CrsId
				LEFT JOIN PackagesRangeCOD prCOD
					ON pr.IdPackagesRange = prCOD.PackagesRangeId
				LEFT JOIN CatRateSegment crs2
					ON prCOD.CatRateSegmentId = crs2.CrsId
				WHERE pr.RowStatus = 1
				AND prd.RowStatus = 1
                AND IIF(cbs.IdCountry IS NULL, 'GT', cbs.IdCountry) = @IdFilter
				ORDER BY cts.CtsShortName DESC, pr.[Order]
			END

        SET @count = @count + 1;
        DELETE TOP (1)
        FROM @Catalogs;
    END;



    SELECT BT.IdCatBillingTime [IdValue],
           BT.DescriptionBillingTime [NameValue],
           'BillingTime' [Catalog]
    FROM [dbo].[CatBillingTime] BT with (nolock)
    WHERE BT.RowStatus = 'TRUE'




    SELECT BV.IdCatBillingVolume [IdValue],
           BV.NameBillingVolume [NameValue],
           'BillingVolume' [Catalog]
    FROM [dbo].[CatBillingVolume] BV with (nolock)
    WHERE BV.RowStatus = 'TRUE'

	--facturacion El Salvador	
    -- Consulta de distritos
    SELECT 
		DS.Id [IdValue],
        DS.CodeDistrict, 
        DS.[Name] [NameValue],	
		DS.StateId [IdFilter],
        DS.StateCode,
        'DistrictByBillingSV' [Catalog]
    FROM DistrictByBillingSV DS WITH(NOLOCK)
    WHERE DS.RowStatus = 1;

    -- Consulta de estados
    SELECT 
		S.Id [IdValue],
        S.Code, 
        S.[Name] [NameValue],
        'StateByBillingSV' [Catalog]
    FROM StateByBillingSV S WITH(NOLOCK)
    WHERE S.RowStatus = 1;

    -- Consulta de actividades económicas
    SELECT 
		EA.Id [IdValue],
        EA.CodeActivity, 
        CONVERT(NVARCHAR(45),CONCAT(EA.[CodeActivity],' - ',EA.[Description])) [NameValue],
        'EconomiActivity' [Catalog]
    FROM CatEconomicActivityBySV EA WITH(NOLOCK)
    WHERE EA.RowStatus = 1;


END
