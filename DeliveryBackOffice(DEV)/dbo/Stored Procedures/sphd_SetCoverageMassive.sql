-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2021-11-16>
-- Description:	<Edita uno o varios campos de un grupo seleccionado de coberturas >
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-05-11>
-- Description:	< Adición de manejo de edición de ubicaciones de poblados >
-- =============================================
-- Author:		<Mario, Herrarte>
-- Create date: <2026-03-12>
-- Description:	<Se agrego el campo TypeSettlement para identificar poblados privados y publicos>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_SetCoverageMassive]
	@idHub          int = NULL,
	@idRoute        int =NULL,
	@TypeSettlement int = NULL,
	@SDD		    bit =NULL,
	@NDD		    bit =NULL,
	@TDA		    bit =NULL,
	@ConcatedCov    nvarchar(50)=NULL,
	@flag		    nvarchar(50), --Este campo indica si se van a editar todos los campos o si solo se quiere modificar uno en especifico
	--Para el parametro flag:
		--'HUB' editara el hub
		--'ROUTE' editara la ruta
		--'TYPESERVICE' editara el tipo de servicio (sdd,ndd,tda)
		--'COVERAGE' editara la cobertura
		--'ALL' editara todos los campos
	@dataToSet dbo.TblExtPlatTextParameterList READONLY,
	@userToken nvarchar(50),
	@LocationDataToSet TblPlaceLocation READONLY

AS
BEGIN
	DECLARE @hubcode nvarchar(50) = (select HubAbbreviation from HubLogistics where IdHubLogistic=@idHub  );
	DECLARE @routecode nvarchar(100) = (select CodeRoute from dbo.CatRoute where IdRoute=@idRoute);
	DECLARE @deliveryTime nvarchar(50)='';
	BEGIN TRANSACTION INI
	SAVE TRANSACTION POINT1
	
	BEGIN TRY

		IF (@TDA=1)
		BEGIN			
			SET @deliveryTime=SUBSTRING((select CtsDescription from dbo.CatTypeService where CtsShortName='TDA'),0,50);
			SET @SDD=0
			SET @NDD=0
		END
		ELSE IF (@NDD=1 AND @SDD=1)
		BEGIN
			SET @deliveryTime=(select  SUBSTRING( (SELECT STUFF((SELECT ' o ' + CtsDescription
                FROM DBO.CatTypeService 
                WHERE CtsShortName IN ('SDD','NDD')
                FOR XML PATH('')),1,3,'')),0,50) );
		END
		ELSE IF (@SDD=1)
		BEGIN
			SET @deliveryTime=SUBSTRING((select CtsDescription from dbo.CatTypeService where CtsShortName='SDD'),0,50);
		END
		ELSE IF (@NDD=1)
		BEGIN
			SET @deliveryTime=SUBSTRING((select CtsDescription from dbo.CatTypeService where CtsShortName='NDD'),0,50);
		END


		--START SAVE LOG
			INSERT INTO DBO.DumpServiceCoverageLog  (DumpFileName,DumpVersion,HeaderCode,IdSettlement,Coverage,DeliveryTime,Hub,RouteCode,SDD,NDD,TDA,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated)
				(SELECT 
				DumpFileName,DumpVersion,HeaderCode,IdSettlement,Coverage,DeliveryTime,Hub,RouteCode,SDD,NDD,TDA,RowStatus,TokenCreated,DateCreated,@userToken,GETDATE()
				FROM DBO.DumpServiceCoverage SERV
				INNER JOIN @dataToSet DS ON  SERV.IdDump= CAST(DS.TextParameter AS bigint))
		--END SAVE LOG
		--START SET NEW DATA
		UPDATE dsc SET 
            dsc.Hub=(case when (@flag in ('ALL','HUB')) then @hubcode else dsc.Hub end),
            dsc.RouteCode=(case when (@flag in ('ALL','ROUTE')) then @routecode else dsc.RouteCode end),
            dsc.SDD=(case when (@flag in ('ALL','TYPESERVICE')) then @SDD else dsc.SDD end),
            dsc.NDD=(case when (@flag in ('ALL','TYPESERVICE')) then @NDD else dsc.NDD end),
            dsc.TDA=(case when (@flag in ('ALL','TYPESERVICE')) then @TDA else dsc.TDA end), 
			dsc.DeliveryTime=(case when (@flag in ('ALL','TYPESERVICE')) then @deliveryTime else dsc.DeliveryTime end), 
            dsc.Coverage=(case when (@flag in ('ALL','COVERAGE')) then @ConcatedCov else dsc.Coverage end),			
			dsc.TokenUpdated=@userToken,
			dsc.DateUpdated=GETDATE()
			from DBO.DumpServiceCoverage dsc
			INNER JOIN @dataToSet dts
				ON dsc.IdDump = CAST(dts.TextParameter AS bigint);


            select 0,@hubcode,@routecode,@deliveryTime;
			
		IF ((SELECT COUNT(1) FROM @LocationDataToSet) > 0)
		BEGIN

			UPDATE
				Sttlmnt
			SET
				Sttlmnt.SettlementLatitud = CAST(IIF(LEN(LDTS.PlaceLatitude) > 9, SUBSTRING(LDTS.PlaceLatitude,1,9), LDTS.PlaceLatitude) AS DECIMAL(9,6))
				,Sttlmnt.SettlementLongitud = CAST(IIF(LEN(LDTS.PlaceLongitude) > 9, SUBSTRING(LDTS.PlaceLongitude,1,9), LDTS.PlaceLongitude) AS DECIMAL(9,6))
				,Sttlmnt.TypeSettlement = @TypeSettlement
				,Sttlmnt.TokenUpdated = @userToken
				,Sttlmnt.DateUpdated = GETDATE()
			FROM
				[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH(NOLOCK)
				INNER JOIN
					@LocationDataToSet LDTS
					ON
						DSC.IdDump = LDTS.PlaceIdentifierExtended
				INNER JOIN
					[DeliveryBackOffice].[dbo].[Settlement] Sttlmnt WITH(NOLOCK)
					ON
						DSC.IdSettlement = Sttlmnt.IdSettlement
			WHERE
				DSC.RowStatus = 1
				AND
				Sttlmnt.SettlementSatus = 1

		END

		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION POINT1
		select -1;
	END CATCH

END
