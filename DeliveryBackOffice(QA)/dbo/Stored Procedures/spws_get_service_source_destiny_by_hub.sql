

-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-08-05>
-- Description:	<Devuelve la opcion y precio shipping>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_service_source_destiny_by_hub]
	-- Add the parameters for the stored procedure here
		    @CodApp as nvarchar(50) = 'SIFDCECOM300720201459',
			@HeaderCodeDestiny as nvarchar(6)  = '0501',
			@HeaderCodeSource as nvarchar(6)  = '0102',
			@CodeOfReference as int = 0,
			@IdCustomer as int = null


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	
	BEGIN TRY  
			
		if @CodeOfReference <= 0 -- no enviaron visit point, intentea deducirlo
		begin
			select top 1
				0 IdSettlementSource, 
				'' SettlementSource,
				Cast(mun.IdTownship as varchar) IdTownShipSource, 
				mun.TownshipName TownshipNameSource, 
				Cast(mun.IdProvince as varchar) IdProvinceSource, 
				dep.ProvinceName IdProvinceNameSource, 
				dep.IdCountry  IdCountrySource,
				dep.ProvinceAbbreviation ProvinceAbrreviationSource,
				DSC3.Hub  HubAbbreviationSource,
				'0' SourceCodeOfReferenceID,
				''  SourceVPCName,
				''  SourceEXPCName,
				''  SouceVPCustomerID,
				'' AbbrvCustomerName,
				'' SourceVPCVisitPointId,
				'' DepotAddress
			from DeliveryBackOffice.dbo.Township mun WITH(NOLOCK)
				LEFT JOIN DeliveryBackOffice.dbo.Settlement pob WITH(NOLOCK)
					ON
					mun.IdTownship = pob.IdTownship
					AND
					mun.IdProvince = pob.IdProvince
					AND
					pob.SettlementSatus = 1
				LEFT JOIN (SELECT DISTINCT IdSettlement, Hub FROM DeliveryBackOffice.dbo.DumpServiceCoverage WITH(NOLOCK) WHERE RowStatus = 1) DSC3
					ON
					pob.IdSettlement = DSC3.IdSettlement 
				JOIN DeliveryBackOffice.dbo.Province dep  WITH(NOLOCK) ON	mun.IdProvince = dep.IdProvince and dep.ProvinceStatus = 'TRUE'
				LEFT JOIN DeliveryBackOffice.dbo.HubLogistics hub WITH(NOLOCK)on RTRIM(LTRIM(hub.HubAbbreviation)) = RTRIM(LTRIM(DSC3.Hub))
			where mun.HeaderCode = @HeaderCodeSource and mun.TownshipStatus = 'TRUE'
		end
		else
		begin
			select top 1
				0 IdSettlementSource, 
				'' SettlementSource,
				Cast(mun.IdTownship as varchar) IdTownShipSource, 
				mun.TownshipName TownshipNameSource, 
				Cast(mun.IdProvince as varchar) IdProvinceSource, 
				dep.ProvinceName IdProvinceNameSource, 
				dep.IdCountry  IdCountrySource,
				dep.ProvinceAbbreviation ProvinceAbrreviationSource,
				DSC3.Hub  HubAbbreviationSource,
				ISNULL(Cast(vpc.CodeOfReference as varchar), '') SourceCodeOfReferenceID,
				ISNULL(vpc.ContactName,'')  SourceVPCName,
				ISNULL(vpc.DescriptionOfClient,'')  SourceEXPCName,
				ISNULL(Cast(vpc.CustomerID as varchar), '')  SouceVPCustomerID,
				iif(@CodeOfReference > 0, ISNULL(UPPER(CASE WHEN  client.Abbreviation <> ' '  THEN client.Abbreviation ELSE client.Name END ), ' '), (select Abbreviation  from dbo.Customer where IdCustomer = @IdCustomer)) AbbrvCustomerName,
				ISNULL(Cast(vpc.VisitPointId as varchar), '') SourceVPCVisitPointId,
				'' DepotAddress
			from DeliveryBackOffice.dbo.Township mun WITH(NOLOCK)
				LEFT JOIN DeliveryBackOffice.dbo.Settlement pob WITH(NOLOCK)
					ON
					mun.IdTownship = pob.IdTownship
					AND
					mun.IdProvince = pob.IdProvince
					AND
					pob.SettlementSatus = 1
				LEFT JOIN (SELECT DISTINCT IdSettlement, Hub FROM DeliveryBackOffice.dbo.DumpServiceCoverage WITH(NOLOCK) WHERE RowStatus = 1) DSC3
					ON
					pob.IdSettlement = DSC3.IdSettlement
				JOIN DeliveryBackOffice.dbo.Province dep WITH(NOLOCK) on	mun.IdProvince = dep.IdProvince and dep.ProvinceStatus = 'TRUE'
				LEFT JOIN DeliveryBackOffice.dbo.HubLogistics hub WITH(NOLOCK) on RTRIM(LTRIM(hub.HubAbbreviation)) = RTRIM(LTRIM(DSC3.Hub))
				LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH(NOLOCK) on vpc.CodeOfReference =  @CodeOfReference --and vpc.IdKindOfVPClient = 6
				LEFT JOIN DeliveryBackOffice.dbo.Customer client WITH(NOLOCK) on vpc.CustomerID = client.IdCustomer
			where mun.HeaderCode = @HeaderCodeSource and mun.TownshipStatus = 'TRUE' 
		end
				
			

			--Devuelve en un cuarto select datos para el destino
			select  top 1
					0 IdSettlementDestiny, 
					'' SettlementDestiny,
					Cast(mun.IdTownship as varchar) IdTownShipDestiny, 
					mun.TownshipName TownshipNameDestiny, 
					Cast(mun.IdProvince as varchar)  IdProvinceDestiny, 
					dep.ProvinceName IdProvinceNameDestiny, 
					dep.IdCountry  IdCountryDestiny,
					dep.ProvinceAbbreviation ProvinceAbrreviationDestiny,
					DSC3.Hub  HubAbbreviationDestiny,
					ISNULL(Cast(vpc.CodeOfReference as varchar), '') DestinyCodeOfReferenceID,
					ISNULL(vpc.ContactName,'')  DestinyVPCName,
					ISNULL(Cast(vpc.CustomerID as varchar), '')  DestinyVPCustomerID,
					ISNULL(Cast(vpc.VisitPointId as varchar), '') DestinyVPCVisitPointId
			from DeliveryBackOffice.dbo.Township mun WITH(NOLOCK)
				LEFT JOIN DeliveryBackOffice.dbo.Settlement pob WITH(NOLOCK)
					ON
					mun.IdTownship = pob.IdTownship
					AND
					mun.IdProvince = pob.IdProvince
					AND
					pob.SettlementSatus = 1
				LEFT JOIN (SELECT DISTINCT IdSettlement, Hub FROM DeliveryBackOffice.dbo.DumpServiceCoverage WITH(NOLOCK)  WHERE RowStatus = 1) DSC3
					ON
					pob.IdSettlement = DSC3.IdSettlement
			JOIN DeliveryBackOffice.dbo.Province dep WITH(NOLOCK)  on	mun.IdProvince = dep.IdProvince and dep.ProvinceStatus = 'TRUE'
				LEFT JOIN DeliveryBackOffice.dbo.HubLogistics hub WITH(NOLOCK)  ON RTRIM(LTRIM(hub.HubAbbreviation)) = RTRIM(LTRIM(DSC3.Hub))
			left join DeliveryBackOffice.dbo.VisitPointClientByHubLogistics vhub WITH(NOLOCK) on vhub.IdHublogistic =  hub.IdHubLogistic 
			LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH(NOLOCK) on vpc.CodeOfReference =  vhub.IdVisitPointClient and vpc.IdKindOfVPClient = 6
			LEFT JOIN DeliveryBackOffice.dbo.Customer client  WITH(NOLOCK) ON vpc.CustomerID = client.IdCustomer
			where mun.HeaderCode = @HeaderCodeDestiny and mun.TownshipStatus = 'TRUE'
				


			
	END TRY  
	BEGIN CATCH  
		SELECT   Cast(ERROR_NUMBER() as nvarchar) AS ErrorNumber  
				,Cast(ERROR_SEVERITY() as nvarchar) AS ErrorSeverity  
				,Cast(ERROR_STATE() as nvarchar) AS ErrorState  
				,Cast(ERROR_PROCEDURE() as nvarchar) AS ErrorProcedure  
				,Cast(ERROR_LINE() as nvarchar) AS ErrorLine  
				,Cast(ERROR_MESSAGE() as nvarchar) AS ErrorMessage;
		
	END CATCH;   

END
