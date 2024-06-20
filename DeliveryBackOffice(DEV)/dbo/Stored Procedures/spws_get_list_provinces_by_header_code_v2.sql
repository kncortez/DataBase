
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-12-11>
-- Description:	<Devuelve una lista de departamentos asociados a un pais>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_list_provinces_by_header_code_v2]
	-- Add the parameters for the stored procedure here
	@IdHeaderCode as nvarchar(2) = '-1',
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
	  ',{"HeaderCode":"' + depto.LocalCode + '",' +
	  '"ProvinceName":"' + depto.ProvinceName  + '",' +
	  '"IdCountry":"' + depto.IdCountry + '"}' 
	  	from DeliveryBackOffice.dbo.Province depto WITH (NOLOCK) 
		where depto.ProvinceStatus = 'TRUE'
		and  (@IdHeaderCode = '-1' or depto.LocalCode = @IdHeaderCode)
		and depto.IdCountry = @IdCountry
	  FOR XML PATH(''), TYPE
	 ).value('.', 'varchar(max)'),1,1,''
				  ) 
)

select '['+ @jsonResult + ']' FormatJson

END