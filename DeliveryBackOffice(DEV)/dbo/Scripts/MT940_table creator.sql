-- ============================================================
-- Tabla: EstadoCuenta_MT940
-- Descripción: Almacena transacciones parseadas de archivos MT940
-- ============================================================
DROP TABLE IF EXISTS dbo.StatementAccount_MT940;
CREATE TABLE dbo.StatementAccount_MT940
(
    -- Datos del extracto
    Account BIGINT NOT NULL,
    SequenceNumber VARCHAR(20) NOT NULL,
    Reference VARCHAR(50) NULL,
    Currency CHAR(3) NOT NULL,

    -- Datos de la transacción
    TransactionDate DATE NOT NULL,
    TransactionType CHAR(1) NOT NULL,
    TransactionAmount DECIMAL(18, 2) NOT NULL,
    TransactionOperationType VARCHAR(10) NULL,
    TransactionReference BIGINT NULL,
    TransactionDescription VARCHAR(255) NULL,

    -- Saldos del extracto
    OpeningBalance DECIMAL(18, 2) NOT NULL,
    OpeningBalanceType CHAR(1) NOT NULL,
    ClosingBalance DECIMAL(18, 2) NOT NULL,
    ClosingBalanceType CHAR(1) NOT NULL,

    -- Auditoría
    CreationDate DATETIME NOT NULL
        CONSTRAINT DF_MT940_CreationDate
        DEFAULT GETDATE(),
    CONSTRAINT CK_MT940_TransactionType CHECK (TransactionType IN ( 'C', 'D' )),
    CONSTRAINT CK_MT940_OpeningBalanceType CHECK (OpeningBalanceType IN ( 'C', 'D' )),
    CONSTRAINT CK_MT940_ClosingBalanceType CHECK (ClosingBalanceType IN ( 'C', 'D' )),
    CONSTRAINT CK_MT940_Currency CHECK (Currency LIKE '[A-Z][A-Z][A-Z]')
);
GO


-- ============================================================
-- Índices
-- ============================================================
-- Búsquedas frecuentes por cuenta y fecha
CREATE NONCLUSTERED INDEX IX_MT940_Cuenta_Fecha
ON dbo.StatementAccount_MT940
(
    Account,
    TransactionDate
);
GO

-- Búsquedas por número de extracto
CREATE NONCLUSTERED INDEX IX_MT940_SequenceNumber
ON dbo.StatementAccount_MT940 (SequenceNumber);
GO

-- Búsquedas por referencia de transacción
CREATE NONCLUSTERED INDEX IX_MT940_TransactionReference
ON dbo.StatementAccount_MT940 (TransactionReference)
WHERE TransactionReference IS NOT NULL;
GO