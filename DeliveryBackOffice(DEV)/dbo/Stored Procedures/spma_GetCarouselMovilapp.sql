-- =============================================
-- Author:		<Oscar,Rodriguez>
-- Create date: <2024-09-05>
-- Description:	<Devuelve el listado de imagenes por pais para el carrusel de aplicacion movil>
-- =============================================
CREATE PROCEDURE [dbo].[spma_GetCarouselMovilapp]
    -- Add the parameters for the stored procedure here
    @IdCountry AS VARCHAR(2) = 'GT',
    @TacName AS VARCHAR(100)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT		mai.IdCarouselImage [id],
				mai.SDImageURL		[SmallDimension],
				mai.MDImageURL		[MediumDimension],
				mai.LDImageURL		[LargeDimension],
				mai.ImageOrder		[Order],
				mai.IdCountry		[Country]
	FROM		DeliveryBackOffice.dbo.MovilAppCarouselImage	mai WITH(NOLOCK)
	LEFT JOIN	DeliveryBackOffice.dbo.CatTypeAccount			cta WITH(NOLOCK)	ON cta.TacIdTypeAccount = mai.IdTypeAccount
	WHERE		mai.IdCountry = @IdCountry
	AND			cta.TacName = @TacName
	AND			mai.RowStatus = 1
	ORDER BY	mai.ImageOrder asc;
END;

