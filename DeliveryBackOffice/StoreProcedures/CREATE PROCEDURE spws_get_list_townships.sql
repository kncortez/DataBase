-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-07-23>
-- Description:	<Obtiene el listado de todos los 
--               municipios de un departamento o 
--				 pais>
-- =============================================
CREATE PROCEDURE spws_get_list_townships
	-- Add the parameters for the stored procedure here
	@IdTownship as int  = -1, --all
	@IdProvince as int = -1, --all
	@IdCountry as nvarchar(2) = 'GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select	mun.IdTownship [IdTownship], 
			mun.TownshipName [TownshipName], 
			depto.ProvinceName [ProvinceName], 
			ct.CNT_CountryName [CountryName]
	from DeliveryBackOffice.dbo.Township mun with(nolock)
			join DeliveryBackOffice.dbo.Province depto with(nolock) on mun.IdProvince = depto.IdProvince
			left join DenariusDesktop_Dev.dbo.prm_country ct with(nolock) on depto.IdCountry = ct.CNT_IdCountry
	where  mun.TownshipStatus = 'TRUE'
	and depto.IdCountry = @IdCountry
	and (@IdTownship = -1 or  mun.IdTownship = @IdTownship)
	and (@IdProvince = -1 or mun.IdProvince = @IdProvince)
END
GO
