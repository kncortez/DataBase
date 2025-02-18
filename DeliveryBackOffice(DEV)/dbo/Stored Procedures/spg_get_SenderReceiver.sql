
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-15>
-- Description:	<Devuelve todos los vehiculos disponibles>
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-05-28>
-- Description: <Se agrego filtro por pais, por defecto GT>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_SenderReceiver]
(
  @IdCountry  NVARCHAR(2) = 'GT'
)
AS
BEGIN
	SELECT sr.ID,
	CONCAT(sr.First_Name,' ', sr.Last_Name) as Name,
    Phone AS [Phone]
	FROM  [DeliveryBackOffice].[dbo].[SenderReceiver] as sr
   WHERE IIF(sr.IdCountry IS NULL, 'GT',sr.IdCountry) = @IdCountry
	order by [Name]
END