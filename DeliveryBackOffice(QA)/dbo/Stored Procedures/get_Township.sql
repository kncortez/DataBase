-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-03-19>
-- Description:	<Retorna los tipos de una ruta>
-- =============================================
CREATE PROCEDURE [dbo].[get_Township]
AS
BEGIN


	select IdTownship, TownshipName, IdProvince from Township
	where TownshipStatus = 1


END
