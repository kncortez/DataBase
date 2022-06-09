
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-15>
-- Description:	<Devuelve todos los vehiculos disponibles>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_SenderReceiver]
AS
BEGIN
	SELECT sr.ID,
	CONCAT(sr.First_Name,' ', sr.Last_Name) as Name
	FROM  [DeliveryBackOffice].[dbo].[SenderReceiver] as sr
	--Where sr.Estatus = 1 
	order by [Name]
END