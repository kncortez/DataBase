
-- =============================================
-- Author:		<Alberto, Ixchop>
-- Create date: <2021-11-29>
-- Description:	<Devuelve el catalogo de los tipos de servicio>
-- =============================================
--
CREATE PROCEDURE [dbo].[sphd_GetTypeServiceManagment]
AS
BEGIN	
	select 
		 IdSubTypeServiceManagment Id,
		Name Name 
	from dbo.SubTypeServiceManagment
	where RowStatus='TRUE' and Name in ('Recolección','Entrega')
END
