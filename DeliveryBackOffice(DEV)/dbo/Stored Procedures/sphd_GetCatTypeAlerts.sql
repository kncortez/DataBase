
-- =============================================
-- Author:		<Alberto, Ixchop>
-- Create date: <2021-11-29>
-- Description:	<Devuelve el catalogo de los tipos de alertas>
-- =============================================
--
CREATE PROCEDURE [dbo].[sphd_GetCatTypeAlerts]
AS
BEGIN		
	SELECT 
	CTA.IdCatTypeAlert as  id,
	CTA.AlertName as name
	FROM DBO.CatTypeAlert CTA
	where RowStatus='TRUE';
END
