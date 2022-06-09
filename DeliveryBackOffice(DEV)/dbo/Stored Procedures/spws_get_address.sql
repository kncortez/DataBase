
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-08>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================

CREATE PROCEDURE [dbo].[spws_get_address]
	-- Add the parameters for the stored procedure here
	@Token VARCHAR(200),
	@IdAccount bigint,
	@IdAddress bigint = -1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX) 

	DECLARE @IdUser bigint  = (SELECT TOP 1 RuaIdUser FROM dbo.RolByUserByAccount WHERE RuaIdAccount = @IdAccount)




	set @jsonResult = (SELECT STUFF(( 
							select  
							 ',{"IdAccount":"' +   convert(varchar,ua.UadIdAccount) + '",' +
							'"IdAddress":"' +  convert(varchar,ua.UadIdAddress)  + '",' +
							'"FullName":"' + dbo.fnt_String_Escape(REPLACE(ISNULL(ua.UadFullName,''),'"',''),'json')  + '",' +
							'"Address1":"' + dbo.fnt_String_Escape(REPLACE(ISNULL(ua.UadAddress1,''),'"',''),'json')  + '",' +
							'"Address2":"' + dbo.fnt_String_Escape(REPLACE(ISNULL(ua.UadAddress2,''),'"',''),'json')  + '",' +
							'"NirPhone":"' + ua.UadNirPhone  + '",' +
							'"Phone":"' + ua.UadPhone   + '",' +
							'"AdditionalInstructions":"' + dbo.fnt_String_Escape(REPLACE(ISNULL(ua.UadAdditionalInstructions,''),'"',''),'json')  + '",' +
							'"IdCountry":"' + ua.UadIdCountry  + '",' +
							'"Province":"' + prv.ProvinceName  + '",' +
							'"Township":"' + twn.TownshipName  + '",' +
							'"IdTownship":"' +  convert(varchar,ua.UadIdTownship)  + '",' +
							'"HeaderCode":"' + ISNULL(twn.HeaderCode,'')   + '",' +
							'"CodeOfReference":"' + convert(varchar, ua.CodeOfReference)  + '",' +
							'"IdCityPlace":"' + convert(varchar, isnull(ua.IdCityPlace,31))+ '",' +
							'"CityPlace":"' + convert(varchar, ctp.CityPlace)   + '",' +
							--'"IdProvince":"' +  convert(varchar,prv.IdProvince)  + 
							'"IdProvince":"' +  convert(varchar,prv.IdProvince)  + '",' +							
							'"Latitude":"' +  ISNULL(vp.Latitude,'') + '",' +
							'"Longitude":"' +  ISNULL(vp.Longitude,'') +
							+ '"}'

					from dbo.RolByUserByAccount  rua
						inner join dbo.UserAddress ua on ua.UadIdAccount = rua.RuaIdAccount
						join dbo.Township twn on twn.IdTownship = ua.UadIdTownship
						join dbo.Province prv on prv.IdProvince = twn.IdProvince
						join dbo.CatCityPlace ctp on ua.IdCityPlace = ctp.IdCityPlace and ctp.CityPlaceRowStatus = 'true'
						left join dbo.VisitPointClient vp on vp.CodeOfReference=ua.CodeOfReference
					where rua.RuaIdAccount = @IdAccount and rua.RuaIdUser = @IdUser and ua.UadRowStatus = 1
						and (ua.UadIdAddress = @IdAddress or @IdAddress = -1)
					FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
									) )

		-- retornar resultado en formato json
	If @jsonResult is null 
	begin


		set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{{"IdResult":500,' 
					+ '"Message":" No se econtraron registros"}' 
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
	end
	
		select ('[' + @jsonResult +  ']') jsonResult

	

END


