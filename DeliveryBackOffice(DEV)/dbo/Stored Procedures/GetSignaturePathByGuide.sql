-- =============================================
-- Author:		<Tito García>
-- Create date: <19/08/2024>
-- Description:	<Retorna el path de la firma>
-- =============================================
CREATE PROCEDURE [dbo].[GetSignaturePathByGuide]
	@GuideSerie VARCHAR(2),
	@GuideNumber INT
AS
BEGIN

	SELECT TOP 1 dp.PathSignature AS [SignaturePath]
	FROM [dbo].[DeliveryProof] dp WITH (NOLOCK)
	WHERE dp.Guide_Serie = @GuideSerie
		AND dp.Guide_Number = @GuideNumber
		AND dp.PathSignature IS NOT NULL
	ORDER BY dp.ID DESC

END
