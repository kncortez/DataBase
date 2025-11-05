-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2025-09-03>
-- Description:	<Script que se utiliza para crear una tabla de User-Defined Table Type para proyecto Efectibox.>
-- =============================================

BEGIN TRY
    BEGIN TRANSACTION;
    
   -- Crear la tabla tipo deposit utilizada para Efectibox
	CREATE TYPE dbo.TblDeposit AS TABLE
	(
		TransactionNumber       BIGINT          NOT NULL,
		TransactionDate         DATETIME        NOT NULL,
		TransactionCode         INT             NOT NULL,
		Reference               NVARCHAR(15)    NOT NULL,
		Amount                  DECIMAL(19,4)   NOT NULL,
		Balance                 DECIMAL(19,4)   NOT NULL,
		UserIdDeposit           NVARCHAR(50)    NOT NULL,
		UserNameDeposit         NVARCHAR(50)    NOT NULL,
		UserNickNameDeposit     NVARCHAR(50)    NOT NULL,
		UserDocumentNumber      NVARCHAR(20)    NOT NULL,
		CurrencyISO             NVARCHAR(10)    NOT NULL,
		CurrencyIdExternal      INT             NOT NULL,
		ClientIdExternal        BIGINT          NOT NULL,
		ClientCardCode          NVARCHAR(15)    NOT NULL,
		ClientNameExternal      NVARCHAR(500)   NOT NULL,
		VisitPointIdExternal    BIGINT          NOT NULL,
		VisitPointName          NVARCHAR(100)   NOT NULL,
		BankIdExternal          INT             NOT NULL,
		BankCardCode            NVARCHAR(50)    NOT NULL,
		BankNameExternal        NVARCHAR(50)    NOT NULL,
		BankAccountNumber       NVARCHAR(50)    NOT NULL,
		BankAccountIsMak        BIT             NOT NULL,
		BankAccountIsIBAN       BIT             NOT NULL,
		BankAccountIsSWIFT      BIT             NOT NULL,
		TerminalId              INT             NOT NULL,
		TerminalSerie           NVARCHAR(50)    NOT NULL
	);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
