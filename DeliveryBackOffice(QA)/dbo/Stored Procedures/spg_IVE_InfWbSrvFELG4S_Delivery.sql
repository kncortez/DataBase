-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 6 octubre 2020
-- Description:	Retorna credenciales de consumo web service FEL G4S
-- =============================================
CREATE PROCEDURE [dbo].[spg_IVE_InfWbSrvFELG4S_Delivery]
	@VpCodeOfReference as varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @country as varchar(2);

	select @country = CountryId
	from VisitPointClient
	where CodeOfReference = @VpCodeOfReference

				DECLARE @establecimiento as varchar(15),
				@correoCCO as varchar(200)

				select *
				from del_ParametrosFactura
				where dpf_VpCodeOfReference = @VpCodeOfReference	
END
