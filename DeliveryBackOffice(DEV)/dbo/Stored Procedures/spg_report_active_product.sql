
-- =============================================
-- Author:		<Carlos Cano>
-- Create date: <02/09/2020>
-- Description:	<Reporte de producto vigente>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <14/06/2024>
-- Description:	<Filtro de pais origen de la guia>
-- =============================================
CREATE PROCEDURE [dbo].[spg_report_active_product]
				@IdCountry NVARCHAR(2) = 'GT'
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

	SET NOCOUNT ON;

	SELECT * 
	FROM
	(
		select distinct
		w.Guide_Serie + cast(w.guide_number as varchar) as guide,
		isnull(do.Receiver_FirstName,'') + ' ' + isnull(do.Receiver_LastName,'') as receiver,
		(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(w.Guide_Serie,w.Guide_Number)) as [Ubicacion_Bodega],
		CONVERT(VARCHAR, w.DateCreated, 106) as Ingreso
		from DeliveryBackOffice.dbo.Warehouse w
		INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do with(nolock) on do.Guide_Serie = w.guide_serie and do.Guide_Number = w.guide_number
		where w.Active = 1
		AND IIF(do.SenderCountryId IS NULL, 'GT', do.SenderCountryId) = @IdCountry
		--AND w.DateCreated <=  GETDATE() - 1
	) AS SUBQ
	WHERE (SUBQ.Ubicacion_Bodega NOT LIKE '%(92)%' AND SUBQ.Ubicacion_Bodega NOT LIKE '%(93)%')
	ORDER BY SUBQ.Ingreso

END
