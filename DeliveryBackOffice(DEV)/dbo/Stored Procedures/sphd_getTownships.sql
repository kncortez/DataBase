
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-11-02>
-- Description: <Obtener informacion de los municipios activos por ID de departamento.>
-- =============================================
-- Modified:    <Pedroza,Brandon>
-- Create date: <2024-05-27>
-- Description: <Se agrega parametro para filtrar por pais>
-- =============================================
-- Modified:    <Pedroza,Brandon>
-- Create date: <2024-05-31>
-- Description: <Se quita parametro pais, ya que al consultar>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_getTownships]
    @ID AS INT
    --,@IdCountry AS NVARCHAR(2) = 'GT'
AS
BEGIN
    SELECT IdTownship, TownshipName
    FROM DeliveryBackOffice.[dbo].[Township] WITH(NOLOCK)
	INNER JOIN Province WITH(NOLOCK)
	ON Province.IdProvince= Township.IdProvince
    WHERE TownshipStatus = 1
    AND Township.IdProvince = @ID
	--AND Province.IdCountry = @IdCountry
END