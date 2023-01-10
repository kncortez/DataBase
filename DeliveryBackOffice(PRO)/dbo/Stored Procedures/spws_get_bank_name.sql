
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-10-27>
-- Description:	<Devuelve el nombre de un banco
--				basado en coincidencia de  nombre>
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2023-01-05>
-- Description:	<Ordenar nombre de bancos de forma Ascendente>
-- =============================================
CREATE PROCEDURE  [dbo].[spws_get_bank_name]
	-- Add the parameters for the stored procedure here
	@ValName as nvarchar(100),
	@IdCountry as nvarchar(2) = 'GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   select 
	[Id_bank]
	,[Name]
	,[Acronym]
	,[Description]
	,[Id_country]
	from DeliveryBackOffice.dbo.DeliveryBank
	where Id_status = 1 
	and (Name like '%' + @ValName + '%' or @ValName = '-1')
	and Id_country = @IdCountry
	and Id_status = 1
	ORDER BY [Name] ASC

END