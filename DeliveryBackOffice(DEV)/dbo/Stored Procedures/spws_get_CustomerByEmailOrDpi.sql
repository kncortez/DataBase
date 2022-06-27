-- =============================================
-- Author:		<Michael, Espinoza>
-- Create date: <2021-08-02>
-- Description:	<Devuelve el nombre de un cliente individual asi como su IdCustomer>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_CustomerByEmailOrDpi]
    -- Add the parameters for the stored procedure here
    --@StartDate DATETIME,
    --@EndDate DATETIME ,
    @Token VARCHAR(200) = '',
    @Email VARCHAR(50) = '',
    @DPI VARCHAR(50) = ''

AS

BEGIN

DECLARE @IdAccount INT;
DECLARE @IdUser INT;
DECLARE @jsonResult NVARCHAR(MAX);

IF (@Email='')

BEGIN

SELECT TOP 1 @IdAccount = rub.RuaIdAccount, @IdUser=UsrIdUser FROM dbo.Person 
JOIN dbo.RegisterUser ru ON ru.UsrIdPerson = PerIdPerson
JOIN dbo.RolByUserByAccount rub ON rub.RuaIdUser = UsrIdUser
WHERE PerIdentification= @DPI

END

ELSE

BEGIN

SELECT @IdAccount = rub.RuaIdAccount, @IdUser=UsrIdUser FROM dbo.RegisterUser 
JOIN dbo.RolByUserByAccount rub ON rub.RuaIdUser = UsrIdUser
WHERE UsrEmail = @Email

END

SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"IdAccount":"' + CONVERT(NVARCHAR,ISNULL(@IdAccount, '')) + '",'
										+'"IdUser":"' + CONVERT(NVARCHAR, ISNULL(@IdUser, '')) + '",'
										+'"IdCustomer":"' + CONVERT(NVARCHAR, ISNULL(cu.[IdCustomer], '')) + '",'
										+'"Name":"' + ISNULL(cu.[Name], '') + '",'
										+'"Email":"' + ISNULL(ru.[UsrEmail], '') + '",'
										+'"Phone":"' + ISNULL(ru.[Phone], '') + '",'
										+'"Addresses":[' + 
										ISNULL((SELECT STUFF(( 
													select  
													 ',{' +
													'"FullName":"' + ua.UadFullName  + '",' +
													'"Address1":"' + REPLACE(REPLACE(dbo.fnt_String_Escape(ISNULL(ua.UadAddress1,''),'json'),'\',' '),'"','') + '",' +
													'"Address2":"' + REPLACE(REPLACE(dbo.fnt_String_Escape(ISNULL(ua.UadAddress2,''),'json'),'\',' '),'"','') + '",' +
													'"NirPhone":"' + ua.UadNirPhone  + '",' +
													'"Phone":"' + ua.UadPhone   + '",' +
													'"AdditionalInstructions":"' + REPLACE(REPLACE(dbo.fnt_String_Escape(ISNULL(ua.UadAdditionalInstructions,''),'json'),'\',' '),'"','') + '",' +
													'"IdCountry":"' + ua.UadIdCountry  + '",' +
													'"Province":"' + prv.ProvinceName  + '",' +
													'"Township":"' + twn.TownshipName  + '",' +
													'"IdTownship":"' +  convert(varchar,ua.UadIdTownship)  + '",' +
													'"HeaderCode":"' + twn.HeaderCode   + '",' +
													'"CodeOfReference":"' + convert(varchar, ua.CodeOfReference)  + '",' +
													'"IdCityPlace":"' + convert(varchar, isnull(ua.IdCityPlace,31))+ '",' +
													'"CityPlace":"' + convert(varchar, ctp.CityPlace)   + '",' +
													'"IdProvince":"' +  convert(varchar,prv.IdProvince)  + 
													+ '"}'

													from dbo.RolByUserByAccount  rua
														inner join dbo.UserAddress ua on ua.UadIdAccount = rua.RuaIdAccount
														join dbo.Township twn on twn.IdTownship = ua.UadIdTownship
														join dbo.Province prv on prv.IdProvince = twn.IdProvince
														join dbo.CatCityPlace ctp on ua.IdCityPlace = ctp.IdCityPlace and ctp.CityPlaceRowStatus = 'true'
													where rua.RuaIdAccount = @IdAccount and rua.RuaIdUser = @IdUser and ua.UadRowStatus = 1
													FOR XML PATH(''), TYPE
															).value('.', 'varchar(max)'),1,1,''
																	) ), '{"Message": "No se encontraron resultados", "Code": 400}')
										+ ']'
                                        +'}'
                                FROM DeliveryBackOffice.dbo.Account ac 
								JOIN DeliveryBackOffice.dbo.Customer cu ON cu.IdCustomer = ac.IdCustomer
								JOIN DeliveryBackOffice.dbo.RegisterUser ru ON ru.UsrIdUser = @IdUser
								WHERE ac.AccIdAccount = @IdAccount
							
                                
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );

 SELECT ('[' + @jsonResult + ']') jsonResult;

END;
