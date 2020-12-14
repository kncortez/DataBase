USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_get_service_source_destiny]    Script Date: 4/12/2020 16:00:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-12-03>
-- Description:	<Devuelve la informacion del origen y el destino para generar una guia de trasporte>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_service_source_destiny]
	-- Add the parameters for the stored procedure here
		    @CodApp as nvarchar(50) = 'SIFDCECOM300720201459',
			@IdDestiny as bigint  = 1454,
			@IdSource as bigint = 518, --zona 12 Guatemala
			@IdMerchant as int = 6,
			@IdSellerDepot as int  = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdSettlement AS BIGINT = -1
	SET @IdSettlement = @IdDestiny;

	
	BEGIN TRY  
			

			print @IdSellerDepot 
			IF (@IdSellerDepot > 0 )
			BEGIN
				print 'Valida  IdKindOfVPClient = 5'
				IF ((select count(*)
					from SellerDepot sd
					inner join Seller sl on sd.IdSeller = sl.IdSeller and sl.IdCustomer =  @IdMerchant
					where sd.IdSellerDepot = @IdSellerDepot
					)>0 )
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
							ISNULL(Cast('' as varchar), '') SourceCodeOfReferenceID,
							ISNULL(bodega.ContactName,'')  SourceVPCName,
							ISNULL(bodega.DescriptionOfClient,'')  SourceEXPCName,
							ISNULL(Cast(seller.IdCustomer as varchar), '')  SouceVPCustomerID,
							ISNULL(UPPER(client.abbreviation), '') AbbrvCustomerName,
							ISNULL(Cast(vpc.CodeOfReference as varchar), '') SourceVPCVisitPointId,
							UPPER(bodega.Address) DepotAddress
					from DeliveryBackOffice.dbo.SellerDepot bodega 
					left join DeliveryBackOffice.dbo.Settlement pob on pob.IdSettlement = bodega.IdSettlement
						JOIN DeliveryBackOffice.dbo.Township mun on pob.IdTownship = mun.IdTownship
						JOIN DeliveryBackOffice.dbo.Province dep on	mun.IdProvince = dep.IdProvince and dep.ProvinceStatus = 'TRUE'
						JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbh on mun.IdTownship = tbh.IdTownship and tbh.StatustownshipHub = 'TRUE' AND tbh.TownshipHubDefault = 'TRUE'
						LEFT JOIN DeliveryBackOffice.dbo.HubLogistics hub on tbh.IdHublogistic = hub.IdHubLogistic
						left join DeliveryBackOffice.dbo.Seller seller on seller.IdSeller = bodega.IdSeller
						left join DeliveryBackOffice.dbo.Customer client on client.IdCustomer = seller.IdCustomer
						left join DeliveryBackOffice.dbo.VisitPointClient vpc on vpc.CodeOfReference = bodega.IdVisitPointClient
					where pob.SettlementSatus = 'TRUE'
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
						and vpc.CustomerID= @IdMerchant
					LEFT JOIN DeliveryBackOffice.dbo.Customer client
						on vpc.CustomerID = client.IdCustomer
						
				where pob.SettlementSatus = 'TRUE'
				and pob.IdSettlement = @IdSource
				
			END

			--Devuelve en un cuarto select datos para el destino
			select  Cast(pob.IdSettlement as varchar) IdSettlementDestiny, 
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
		
	END CATCH;   

END