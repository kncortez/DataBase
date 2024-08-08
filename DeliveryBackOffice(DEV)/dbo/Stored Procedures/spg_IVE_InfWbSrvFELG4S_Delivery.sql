-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 6 octubre 2020
-- Description:	Retorna credenciales de consumo web service FEL G4S
-- =============================================
-- Author:      Daniel Ramirez
-- Create date: 2024/06/28
-- Description: Retorna valor de configuracion para porcentaje de impuesto segun el pais de uso
-- =============================================
CREATE PROCEDURE [dbo].[spg_IVE_InfWbSrvFELG4S_Delivery]
	@VpCodeOfReference as varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @country AS VARCHAR(2),
            @taxes   AS VARCHAR(50);

	select @country = CountryId
	from VisitPointClient WITH(NOLOCK)
	where CodeOfReference = @VpCodeOfReference

    SELECT @taxes = [value]
      FROM ConfigParams WITH(NOLOCK)
     WHERE [name] = 'TaxPercentage'
       AND IdCountry = @country

				DECLARE @establecimiento as varchar(15),
				@correoCCO as varchar(200)

				select *, 
                       @taxes AS [TaxPercentage]
				from del_ParametrosFactura WITH(NOLOCK)
				where dpf_VpCodeOfReference = @VpCodeOfReference	


END
