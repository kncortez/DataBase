CREATE TABLE [dbo].[ClosureAccount] (
    [IdClosureAccount] BIGINT        IDENTITY (1, 1) NOT NULL,
    [AccountNumber]    VARCHAR (100) NOT NULL,
    [Name]             VARCHAR (100) NOT NULL,
    [Description]      VARCHAR (250) NOT NULL,
    [RowStatus]        BIT           NOT NULL,
    [TokenCreated]     VARCHAR (50)  NOT NULL,
    [DateCreated]      DATETIME      NOT NULL,
    [TokenUpdated]     VARCHAR (50)  NULL,
    [DateUpdated]      DATETIME      NULL,
    [IdCountry]        VARCHAR(2)   NULL,
    PRIMARY KEY CLUSTERED ([IdClosureAccount] ASC),
    CONSTRAINT [FK_ClosureAccount_CatCountry] FOREIGN KEY([IdCountry]) REFERENCES [dbo].[CatCountry] ([IdCountry])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar las cuentas que se utilizan para generar cierres en Express Center.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClosureAccount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla ClosureAccount.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClosureAccount', @level2type = N'COLUMN', @level2name = N'IdClosureAccount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de cuenta para los cierres.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClosureAccount', @level2type = N'COLUMN', @level2name = N'AccountNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la cuenta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClosureAccount', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de la cuenta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClosureAccount', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClosureAccount', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClosureAccount', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClosureAccount', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que modificó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClosureAccount', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se actualizó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ClosureAccount', @level2type = N'COLUMN', @level2name = N'DateUpdated';
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'País de las cuentas' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ClosureAccount', @level2type=N'COLUMN',@level2name=N'IdCountry'
GO