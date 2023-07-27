-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2023-05-19>
-- Description:	<Description, Catálogo de Vehículosde rutas especiales TSE>
-- =============================================
CREATE PROCEDURE [dbo].[SpCatVehicleEspecial]


AS
BEGIN	
SET NOCOUNT ON;

	Select 
		IdVehicle,
		Plate
	From [dbo].[CatVehicle] RC WITH (NOLOCK)
	Where  RowStatus = 1
  
END