
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-11-03>
-- Description:	<Devuelve el nombre de los Visit Point registrados
--				basado en coincidencia de  rol>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_vpclient_by_rol]
	-- Add the parameters for the stored procedure here
	@IdRol as nvarchar(10) = '',
	@IdCountry as nvarchar(2) = 'GT'
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		select 
			 vp.CodeOfReference, vp.DescriptionOfClient, kvp.IdKindOfVPClient, kvp.KindOfVPName   , vp.IdSettlement
			from [DeliveryBackOffice].[dbo].[Delivery_DataRestrictionByRol] drol
				inner join [DeliveryBackOffice].[dbo].[VisitPointClient] vp on vp.CodeOfReference = drol.DRR_IdVisitPointClient
				inner join KindOfVPClient kvp on kvp.IdKindOfVPClient = vp.IdKindOfVPClient
			where vp.CountryId = @IdCountry
		and drol.DRR_IdRol = @IdRol
		
END
