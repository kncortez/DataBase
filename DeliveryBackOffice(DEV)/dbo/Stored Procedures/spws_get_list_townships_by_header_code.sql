
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-07-23>
-- Description:	<Obtiene el listado de todos los 
--               municipios de un departamento o 
--				 pais>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_list_townships_by_header_code]
	-- Add the parameters for the stored procedure here
	@IdHeaderCodeTownship as nvarchar(10)  = '-1', --all
	@IdHeaderCode as  nvarchar(2) = '-1', --all
	@IdCountry as nvarchar(2) = 'GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	 DECLARE @jsonResult NVARCHAR(MAX)

  SET @jsonResult = (
	 SELECT STUFF((
		SELECT  
	  ',{"HeaderCodeTownship":"' + isnull(mun.HeaderCode,'0101') + '",' +
	  '"HeaderCode":"' + isnull(depto.LocalCode,'01')  + '",' +
	  '"ProvinceName":"' + isnull(depto.ProvinceName,'')  + '",' +
	  '"Coutry":"' + isnull(depto.IdCountry,'GT')  + '",' +
	  '"TownshipName":"' + isnull(mun.TownshipName,'') + '",' +
	  '"IsTDA":"' +  (isnull((	SELECT top 1 iif( isnull(COV.TDA,0) =0,'false','true') FROM DBO.DumpServiceCoverage COV
						where COV.HeaderCode = mun.HeaderCode
						and COV.RowStatus = 1
						order by TDA desc),'false'))  + '",' +
	  	  '"IdTownship":"' + convert( varchar, isnull(mun.IdTownship,0))  
	  + '"}' 
	  	from DeliveryBackOffice.dbo.Township mun
			join DeliveryBackOffice.dbo.Province depto  on mun.IdProvince = depto.IdProvince AND depto.ProvinceStatus=1
		where  mun.TownshipStatus = 'TRUE'
	and depto.IdCountry = @IdCountry
	and (@IdHeaderCodeTownship = '-1' or  mun.HeaderCode = @IdHeaderCodeTownship)
	and (@IdHeaderCode = '-1' or depto.LocalCode = @IdHeaderCode)
	  FOR XML PATH(''), TYPE
	 ).value('.', 'varchar(max)'),1,1,''
				  ) 
)

select '['+ @jsonResult + ']' FormatJson

   
END
