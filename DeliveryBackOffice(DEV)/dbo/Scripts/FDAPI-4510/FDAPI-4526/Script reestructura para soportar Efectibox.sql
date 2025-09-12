-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2025-09-03>
-- Description:	<Script que se utiliza para agregar nueva estructura de tablas para proyecto Efectibox>
-- =============================================
BEGIN TRY
    BEGIN TRANSACTION;

	-- DEPÓSITOS
	CREATE TABLE Deposit (
	  IdDeposit				BIGINT			IDENTITY PRIMARY KEY,
	  TransactionNumber		BIGINT			NOT NULL,
	  TransactionDate		DATETIME		NOT NULL,
	  TransactionCode		INT				NOT NULL,
	  Reference				NVARCHAR(15)	NOT NULL,
	  Amount				DECIMAL(19,4)	NOT NULL,
	  Balance				DECIMAL(19,4)	NOT NULL,
	  UserIdDeposit			NVARCHAR(50)	NOT NULL,
	  UserNameDeposit		NVARCHAR(50)	NOT NULL,
	  UserNickNameDeposit	NVARCHAR(50)	NOT NULL,
	  UserDocumentNumber	NVARCHAR(20)	NOT NULL,
	  CurrencyISO			NVARCHAR(10)	NOT NULL,
	  CurrencyIdExternal    INT				NOT NULL, 
	  ClientIdExternal      BIGINT			NOT NULL,
      ClientCardCode        NVARCHAR(15)	NOT NULL,
      ClientNameExternal    NVARCHAR(500)	NOT NULL,
	  VisitPointIdExternal  BIGINT			NOT NULL,
      VisitPointName        NVARCHAR(100)	NOT NULL,
	  BankIdExternal        INT				NOT NULL,     
      BankCardCode          NVARCHAR(50)	NOT NULL,     
      BankNameExternal      NVARCHAR(50)	NOT NULL,
      BankAccountNumber     NVARCHAR(50)	NOT NULL,
      BankAccountIsMak      BIT				NOT NULL,
      BankAccountIsIBAN     BIT				NOT NULL,
      BankAccountIsSWIFT    BIT				NOT NULL,
	  TerminalId            INT				NOT NULL,
	  TerminalSerie         NVARCHAR(50)	NOT NULL,
	  RowStatus				BIT				NOT NULL,
	  TokenCreated			NVARCHAR(100)	NOT NULL,
	  DateCreated			DATETIME		NOT NULL,
	  TokenUpdated			NVARCHAR(100)	NULL,
	  DateUpdated			DATETIME		NULL,
	);

    CREATE UNIQUE INDEX IX_Deposit_TransactionNumber ON dbo.Deposit(TransactionNumber);
	CREATE INDEX IX_Deposit_TraCode_TerSerie_TraDate ON dbo.Deposit (TransactionCode, TerminalSerie, TransactionDate);
	CREATE INDEX IX_Deposit_TerminalSerie ON dbo.Deposit (TerminalSerie);
	CREATE INDEX IX_Deposit_TransactionDate ON dbo.Deposit(TransactionDate);

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Registro de depósitos monetarios recibidos por Efectibox.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit';
	
	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del depósito (PK).',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'IdDeposit';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de transacción externo (único).',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'TransactionNumber';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha/hora del depósito.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'TransactionDate';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de la transacción de Efectibox (No necesariamente único).',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'TransactionCode';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referencia externa (routeCode).',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'Reference';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Importe total del depósito.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'Amount';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Saldo restante del depósito (Amount menos aplicaciones a manifiestos).',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'Balance';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID del usuario externo que registró el depósito.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'UserIdDeposit';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del usuario externo que registró el depósito.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'UserNameDeposit';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Alias del usuario externo que registró el depósito.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'UserNickNameDeposit';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificación del usuario externo que registró el depósito.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'UserDocumentNumber';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de moneda externo (idealmente ISO 4217).',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'CurrencyISO';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador externo de Efectibox de la moneda asociada al monto.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'CurrencyIdExternal';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del cliente/comercio externo.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'ClientIdExternal';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código/tarjeta del cliente externo (cardCode).',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'ClientCardCode';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del cliente/comercio externo.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'ClientNameExternal';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del punto de visita del cliente externo.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'VisitPointIdExternal';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del punto de visita externo.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'VisitPointName';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del banco externo.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'BankIdExternal';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código/tarjeta del banco externo.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'BankCardCode';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del banco externo.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'BankNameExternal';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de cuenta bancaria externa.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'BankAccountNumber';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indicador específico externo.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'BankAccountIsMak';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indicador externo booleano de si la cuenta utiliza formato IBAN.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'BankAccountIsIBAN';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indicador externo booleano de si la cuenta posee código SWIFT.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'BankAccountIsSWIFT';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador externo de la terminal donde se procesó la transacción.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'TerminalId';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie o etiqueta de la terminal.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'TerminalSerie';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico: 1=Activo, 0=Inactivo.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'RowStatus';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'TokenCreated';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha/hora de creación del registro.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'DateCreated';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de última actualización.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'TokenUpdated';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha/hora de la última actualización.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Deposit', @level2type=N'COLUMN',@level2name=N'DateUpdated';

	-- RELACIÓN N–a–N
	CREATE TABLE RelDepositManifest (
	  IdRelDepositManifest			BIGINT			IDENTITY PRIMARY KEY,
	  IdDeposit						BIGINT			NOT NULL,
	  DeliveryOrderBySettlementId	BIGINT			NOT NULL,
	  AmountApplied					DECIMAL(19,4)	NOT NULL,
	  RowStatus						BIT				NOT NULL,
	  TokenCreated					NVARCHAR(100)	NOT NULL,
	  DateCreated					DATETIME		NOT NULL,
	  TokenUpdated					NVARCHAR(100)	NULL,
	  DateUpdated					DATETIME		NULL,
	  CONSTRAINT FK_Rel_Deposit FOREIGN KEY (IdDeposit)
		REFERENCES DeliveryBackOffice.dbo.Deposit(IdDeposit),
	  CONSTRAINT FK_Rel_DOBSettlement FOREIGN KEY (DeliveryOrderBySettlementId)
		REFERENCES DeliveryBackOffice.dbo.DeliveryOrderBySettlement(ID)
	);

	CREATE INDEX IX_Rel_Settlement ON dbo.RelDepositManifest(DeliveryOrderBySettlementId);
    CREATE INDEX IX_Rel_Deposit_Settlement ON dbo.RelDepositManifest (IdDeposit, DeliveryOrderBySettlementId)
	INCLUDE (AmountApplied, RowStatus, DateCreated);

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla puente N–a–N entre depósitos y manifiestos.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de la relación (PK).',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest', @level2type=N'COLUMN',@level2name=N'IdRelDepositManifest';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'FK al depósito (Deposit.IdDeposit).',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest', @level2type=N'COLUMN',@level2name=N'IdDeposit';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'FK al manifiesto (DeliveryOrderBySettlement.ID).',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest', @level2type=N'COLUMN',@level2name=N'DeliveryOrderBySettlementId';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Importe del depósito aplicado al manifiesto.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest', @level2type=N'COLUMN',@level2name=N'AmountApplied';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado lógico: 1=Activo, 0=Inactivo.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest', @level2type=N'COLUMN',@level2name=N'RowStatus';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest', @level2type=N'COLUMN',@level2name=N'TokenCreated';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha/hora de creación del registro.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest', @level2type=N'COLUMN',@level2name=N'DateCreated';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de última actualización.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest', @level2type=N'COLUMN',@level2name=N'TokenUpdated';

	EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha/hora de la última actualización.',
	 @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelDepositManifest', @level2type=N'COLUMN',@level2name=N'DateUpdated';
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
