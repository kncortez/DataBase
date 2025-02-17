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
	
		SELECT TOP 1 
            200 AS StatusCode,
            'Registro encontrado' AS Description
			,dp.PathSignature AS SignaturePath
		FROM [dbo].[DeliveryProof] dp WITH (NOLOCK)
		WHERE dp.Guide_Serie = @GuideSerie
			AND dp.Guide_Number = @GuideNumber
			AND dp.PathSignature IS NOT NULL
		ORDER BY dp.ID DESC
        
        -- Si no se encontró ningún registro, devolver un código 404
        IF @@ROWCOUNT = 0
        BEGIN
            SELECT 404 AS StatusCode, 
                   'No se encontró registro' AS Description, 
                   '' AS SignaturePath;
        END  

    END TRY 
	BEGIN CATCH
	
        SELECT 
            500 AS StatusCode, 
            ERROR_MESSAGE() AS Description;
	
	END CATCH
END