-- =============================================
-- Author:		Bilkar Morataya
-- Create date: 2025-11-14
-- Description:	Insertar múltiples registros en PaymentZigiMulti para temas de multiguías
-- =============================================
CREATE PROCEDURE [dbo].[SPHWInsertPaymentZigiMultiBulk]
(
    @ValuesString NVARCHAR(1000)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @SQL NVARCHAR(MAX);

        SET @SQL = N'INSERT INTO PaymentZigiMulti
                    (Id_PaymentZigi, GuideSerie, GuideNumber, Amount, CODValue, CollectValue, exclude_COD, IsPay)
                    VALUES ' + @ValuesString;

        EXEC sp_executesql @SQL;

        -- Retornar número de registros insertados
        SELECT @@ROWCOUNT as RecordsInserted;

    END TRY
    BEGIN CATCH
        -- Manejo de errores
        THROW;
    END CATCH
END