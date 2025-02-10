-- =============================================
-- Author:		<Tito García>
-- Create date: <2024-10-11>
-- Description:	<Se obtiene el path de la firma ingresada en la entrega en POD>
-- =============================================
CREATE PROCEDURE [dbo].[GetSignaturePathByGuide]
	@GuideSerie VARCHAR(2),
	@GuideNumber INT
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
	
		SELECT TOP 1 dp.PathSignature AS [SignaturePath]
		FROM [dbo].[DeliveryProof] dp WITH (NOLOCK)
		WHERE dp.Guide_Serie = @GuideSerie
			AND dp.Guide_Number = @GuideNumber
			AND dp.PathSignature IS NOT NULL
		ORDER BY dp.ID DESC

    END TRY 
	BEGIN CATCH

        SELECT 0 AS 'StatusCode', 
                ERROR_MESSAGE() AS 'Description' 
	
	END CATCH
END