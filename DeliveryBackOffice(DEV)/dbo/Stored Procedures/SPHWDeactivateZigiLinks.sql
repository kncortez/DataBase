-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2025-09-12>
-- Description:	<Se desactivan los links de Zigi que se reciban como referencia, se desactivan los registros anidados en PaymentZigiMulti>
-- =============================================
CREATE PROCEDURE dbo.SPHWDeactivateZigiLinks
    @ZigiReferences NVARCHAR(MAX), -- Lista de referencias separadas por coma
    @TokenUpdated NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    -- Convertir la lista de referencias en una tabla
    DECLARE @Refs TABLE (ZigiReference NVARCHAR(100));
    DECLARE @pos INT = 0, @nextpos INT, @val NVARCHAR(100);

    SET @ZigiReferences = @ZigiReferences + ','; -- Asegura que el último valor se procese
    WHILE CHARINDEX(',', @ZigiReferences, @pos + 1) > 0
    BEGIN
        SET @nextpos = CHARINDEX(',', @ZigiReferences, @pos + 1);
        SET @val = LTRIM(RTRIM(SUBSTRING(@ZigiReferences, @pos + 1, @nextpos - @pos - 1)));
        IF @val <> ''
            INSERT INTO @Refs (ZigiReference) VALUES (@val);
        SET @pos = @nextpos;
    END

    -- Actualizar los links en PaymentZigi
    UPDATE PaymentZigi
    SET ZigiLinkStatus = 'CANCELLED',
        RowStatus = 0,
        DateUpdated = GETDATE(),
        TokenUpdated = @TokenUpdated
    WHERE ZigiReference IN (SELECT ZigiReference FROM @Refs);

    -- Actualizar PaymentZigiMulti usando los ZigiPaymentId afectados
    UPDATE PaymentZigiMulti
    SET RowStatus = 0
    WHERE Id_PaymentZigi IN (
        SELECT ZigiPaymentId
        FROM PaymentZigi
        WHERE ZigiReference IN (SELECT ZigiReference FROM @Refs)
          AND ZigiLinkStatus = 'CANCELLED'
          AND RowStatus = 0
    );

    -- Retornar los ZigiPaymentId desactivados
    SELECT ZigiPaymentId
    FROM PaymentZigi
    WHERE ZigiReference IN (SELECT ZigiReference FROM @Refs)
      AND ZigiLinkStatus = 'CANCELLED'
      AND RowStatus = 0;
END