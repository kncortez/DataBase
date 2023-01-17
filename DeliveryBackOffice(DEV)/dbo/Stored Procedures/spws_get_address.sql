
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
							'"FullName":"' +  REPLACE(dbo.fnt_String_Escape(ua.UadFullName,'json') ,'"','')  + '",' +
							'"ContactName":"' +  REPLACE(dbo.fnt_String_Escape(ISNULL(vp.ContactName,''),'json') ,'"','')  + '",' +
							'"Address1":"' +  REPLACE(dbo.fnt_String_Escape(ua.UadAddress1,'json') ,'"','') + '",' +
							'"Address2":"' +  REPLACE(dbo.fnt_String_Escape(ua.UadAddress2,'json') ,'"','')  + '",' +
							'"NirPhone":"' +  REPLACE(dbo.fnt_String_Escape(ua.UadNirPhone,'json') ,'"','')  + '",' +
							'"Phone":"' + ua.UadPhone   + '",' +
							'"AdditionalInstructions":"' +  REPLACE(dbo.fnt_String_Escape(ua.UadAdditionalInstructions,'json') ,'"','')  + '",' +
							'"IdCountry":"' + ua.UadIdCountry  + '",' +
							'"Province":"' + prv.ProvinceName  + '",' +
							'"Township":"' + twn.TownshipName  + '",' +
							'"IdTownship":"' +  convert(varchar,ua.UadIdTownship)  + '",' +
							'"HeaderCode":"' + twn.HeaderCode   + '",' +
							'"CodeOfReference":"' + convert(varchar, ua.CodeOfReference)  + '",' +
							'"IdCityPlace":"' + convert(varchar, isnull(ua.IdCityPlace,31))+ '",' +
							'"CityPlace":"' + convert(varchar, ctp.CityPlace)   + '",' +
							--'"IdProvince":"' +  convert(varchar,prv.IdProvince)  + 
							'"IdProvince":"' +  convert(varchar,prv.IdProvince)  + '",' +							
							'"Latitude":"' +  ISNULL(vp.Latitude,'') + '",' +
							'"Longitude":"' +  ISNULL(vp.Longitude,'') +'",' +
							'"Zone":"' +  ISNULL(CAST(conf.Zone as varchar(2)),'')+'",' +
							'"Neighborhood":"' +  ISNULL(dbo.fn_ReplaceSpecialCharsForJSON(conf.Neighborhood),'') + '",' +
							'"IsOrigin":' +  CAST(ISNULL(vp.IsOriginVisitPoint,1) AS NVARCHAR) + ''
							+ '}'
					from dbo.RolByUserByAccount  rua WITH(NOLOCK)
						inner join dbo.UserAddress ua WITH(NOLOCK) on ua.UadIdAccount = rua.RuaIdAccount
						inner join dbo.Township twn WITH(NOLOCK) on twn.IdTownship = ua.UadIdTownship
						inner join dbo.Province prv WITH(NOLOCK) on prv.IdProvince = twn.IdProvince
						inner join dbo.CatCityPlace ctp WITH(NOLOCK) on ua.IdCityPlace = ctp.IdCityPlace and ctp.CityPlaceRowStatus = 'true'
						left join dbo.VisitPointClient vp WITH(NOLOCK) on vp.CodeOfReference=ua.CodeOfReference
						left join dbo.ConfirmedAddress conf WITH(NOLOCK) on 
								conf.NirPhone=ua.UadNirPhone
								AND conf.Phone=ua.UadPhone
								AND conf.TownshipId = VP.IdTownship
								AND conf.[Address] = VP.Address
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


