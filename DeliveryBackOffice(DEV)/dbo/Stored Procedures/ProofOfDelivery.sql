/* =================================================
   SP:        [dbo].[ProofOfDelivery]
   Propósito: Retorna la evidencia de entrega de una guía dada su serie y número.
   Autor:     Mario Herrarte
   Historia:  <>
   Fecha:     2026-05-12

=== CHANGELOG ============================
YYYY-MM-DD | Historia/épica: <> | Autor:  |
=========================================== */
CREATE PROCEDURE [dbo].[ProofOfDelivery]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
        
        DECLARE @Proof NVARCHAR(300) = NULL;

        SELECT TOP 1
            @Proof = Path_Dry
        FROM [DeliveryBackOffice].[dbo].[DeliveryProof] WITH (NOLOCK)
        WHERE Guide_Serie = @GuideSerie
        AND Guide_Number = @GuideNumber
        ORDER BY ID DESC;

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT 0 AS Code, 
                'No se encontró evidencia de entrega para la guía proporcionada' AS Message,
                @Proof AS ProofUrl;
        END
        ELSE IF NULLIF(LTRIM(RTRIM(@Proof)), '') IS NULL
            SELECT 0 AS Code, 
                'La guía proporcionada no cuenta con evidencia de entrega registrada' AS Message,
                @Proof AS ProofUrl;
        ELSE
        BEGIN
            SELECT 1 AS Code, 
                'Operación realizada con éxito' AS Message,
                @Proof AS ProofUrl;
        END

	END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS Code,
            ERROR_MESSAGE() AS Message,
            NULL AS ProofUrl;
    END CATCH;
	
END
GO
