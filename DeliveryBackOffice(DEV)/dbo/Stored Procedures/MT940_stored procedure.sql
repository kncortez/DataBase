-- ============================================================
-- Tabla de staging (misma estructura, sin constraints)
-- ============================================================
DROP TABLE IF EXISTS dbo.StatementAccount_MT940_Temp;
CREATE TABLE dbo.StatementAccount_MT940_Temp
(
    Account BIGINT NULL,
    SequenceNumber VARCHAR(20) NULL,
    Reference VARCHAR(50) NULL,
    Currency CHAR(3) NULL,
    TransactionDate DATE NULL,
    TransactionType CHAR(1) NULL,
    TransactionAmount DECIMAL(18, 2) NULL,
    TransactionOperationType VARCHAR(10) NULL,
    TransactionReference BIGINT NULL,
    TransactionDescription VARCHAR(255) NULL,
    OpeningBalance DECIMAL(18, 2) NULL,
    OpeningBalanceType CHAR(1) NULL,
    ClosingBalance DECIMAL(18, 2) NULL,
    ClosingBalanceType CHAR(1) NULL
);
GO

-- ============================================================
-- Store Procedure: transición Staging → tabla final
-- ============================================================
CREATE PROCEDURE dbo.sp_rpa_ImportStatementAccountMT940
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.StatementAccount_MT940
        (
            Account,
            SequenceNumber,
            Reference,
            Currency,
            TransactionDate,
            TransactionType,
            TransactionAmount,
            TransactionOperationType,
            TransactionReference,
            TransactionDescription,
            OpeningBalance,
            OpeningBalanceType,
            ClosingBalance,
            ClosingBalanceType
        )
        SELECT s.Account,
               s.SequenceNumber,
               s.Reference,
               s.Currency,
               s.TransactionDate,
               s.TransactionType,
               s.TransactionAmount,
               s.TransactionOperationType,
               s.TransactionReference,
               s.TransactionDescription,
               s.OpeningBalance,
               s.OpeningBalanceType,
               s.ClosingBalance,
               s.ClosingBalanceType
        FROM dbo.StatementAccount_MT940_Temp s
        WHERE s.Account IS NOT NULL
              AND s.TransactionDate IS NOT NULL
              AND s.TransactionType IN ( 'C', 'D' )
              -- Excluir registros que ya existen en la tabla final
              AND NOT EXISTS
        (
            SELECT 1
            FROM dbo.StatementAccount_MT940 t
            WHERE t.Account = s.Account
                  AND t.SequenceNumber = s.SequenceNumber
                  AND t.TransactionDate = s.TransactionDate
                  AND t.TransactionAmount = s.TransactionAmount
                  AND ISNULL(t.TransactionReference, -1) = ISNULL(s.TransactionReference, -1)
        );

        -- Limpiar staging después de la inserción
        TRUNCATE TABLE dbo.StatementAccount_MT940_Temp;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        THROW; -- Relanza el error hacia C#
    END CATCH
END;
GO