-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2021-11-16>
-- Description:	<Crea un nuevo poblado y crea una nueva cobertura para este poblado>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-05-11>
-- Description:	< Adición de ubicación a poblado >
-- =============================================
-- =============================================
-- Author:		<Brandon, Pedroza>
-- Create date: <2024-06-27>
-- Description:	<Se corrige valor de idcountry, el cual no se almacenaba en la tabla Settlement>
-- =============================================
-- Author:		<Mario, Herrarte>
-- Create date: <2026-03-11>
-- Description:	<Se agrega el campo TypeSettlement para saber si es privado o publico el poblado>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_CreateSettlementCoverage]
	@tokenUser         nvarchar(50),
	@nameNewSettlement nvarchar(100),
	@idTownShip        int,
	@idHub		       int,
	@IdRoute	       int,
	@TypeSettlement    int,
	@SDD		       bit,
	@NDD		       bit,
	@TDA		       bit,
	@ConcatedCov       nvarchar(50),
	@Latitude          NVARCHAR(20) = NULL,
	@Longitude         NVARCHAR(20) = NULL
AS
BEGIN

	BEGIN TRANSACTION INI
	SAVE TRANSACTION POINT1

	BEGIN TRY
		DECLARE @idprovince int ;
		DECLARE @headerCode varchar(10);
				
		DECLARE @idNewsetlement int=(SELECT IDENT_CURRENT('Settlement'))+1;
		DECLARE @routecode nvarchar(100) = (select CodeRoute from dbo.CatRoute where IdRoute=@IdRoute);
		
		DECLARE @deliveryTime nvarchar(50);

		select @idprovince=IdProvince,@headerCode=HeaderCode from dbo.Township twn where twn.IdTownship=@idTownShip
		--select * from HubLogistics;
		DECLARE @hubcode nvarchar(50) = (select HubAbbreviation from HubLogistics where IdHubLogistic=@idHub  );
		DECLARE @idcontry nvarchar(4) =(select IdCountry from dbo.Province prv where prv.IdProvince=@idprovince);
		IF (@TDA=1)
		BEGIN
			
			SET @deliveryTime=(select CtsDescription from dbo.CatTypeService where CtsShortName='TDA');
			SET @SDD=0
			SET @NDD=0
		END
		ELSE IF (@NDD=1 AND @SDD=1)
		BEGIN
			SET @deliveryTime= (SELECT STUFF((SELECT ' o ' + CtsDescription
                FROM DBO.CatTypeService 
                WHERE CtsShortName IN ('SDD','NDD')
                FOR XML PATH('')),1,3,''))
		END
		ELSE IF (@SDD=1)
		BEGIN
			SET @deliveryTime=(select CtsDescription from dbo.CatTypeService where CtsShortName='SDD');
		END
		ELSE IF (@NDD=1)
		BEGIN
			SET @deliveryTime=(select CtsDescription from dbo.CatTypeService where CtsShortName='NDD');
		END
		
		INSERT INTO dbo.Settlement 
				(Settlement,
				SettlementLatitud,
				SettlementLongitud,
				PostalCode,
				SettlementSatus,
				IdTownship,
				IdProvince,
				IdCountry,
				IsSpecial,
				TokenCreated,
				DateCreated,
				TokenUpdated,
				DateUpdated,
				TypeSettlement
				) values (
			@nameNewSettlement,
			CAST(IIF(LEN(@Latitude) > 9, SUBSTRING(@Latitude,1,9), @Latitude) AS DECIMAL(9,6)),
			CAST(IIF(LEN(@Longitude) > 9, SUBSTRING(@Longitude,1,9), @Longitude) AS DECIMAL(9,6)),
			NULL,
			1,
			@idTownShip,
			@idprovince,
			@idcontry,
			0,
			@tokenUser,
			GETDATE(),
			NULL,
			NULL,
			@TypeSettlement
		);
		--select * from dbo.DumpServiceCoverage

		INSERT INTO dbo.DumpServiceCoverage 
			(
				DumpFileName,
				DumpVersion,
				HeaderCode,
				IdSettlement,
				Coverage,
				DeliveryTime,
				Hub,
				RouteCode,
				SDD,
				NDD,
				TDA,
				RowStatus,
				TokenCreated,
				DateCreated,
				TokenUpdated,
				DateUpdated

			) values(
			'',
			'',
			@headerCode,
			@idNewsetlement,
			@ConcatedCov,
			@deliveryTime,
			--@idHub,
			@hubcode,
		    @routecode,
			@SDD,
			@NDD,
			@TDA,
			1,
			@tokenUser,
			GETDATE(),
			NULL,
			NULL			
		);

		COMMIT TRANSACTION
		select 0
	END TRY
	BEGIN CATCH
		select -1;
		
		ROLLBACK TRANSACTION POINT1
		
	END CATCH


END
