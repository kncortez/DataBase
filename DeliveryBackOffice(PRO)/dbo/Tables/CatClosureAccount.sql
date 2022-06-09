CREATE TABLE [dbo].[CatClosureAccount] (
    [IdCatClosureAccount] BIGINT       IDENTITY (1, 1) NOT NULL,
    [ClosureAccountId]    BIGINT       NOT NULL,
    [TypeService]         INT          NOT NULL,
    [TypeOfInOutOfMoney]  INT          NOT NULL,
    [PayTime]             INT          NOT NULL,
    [RowStatus]           BIT          NOT NULL,
    [TokenCreated]        VARCHAR (50) NOT NULL,
    [DateCreated]         DATETIME     NOT NULL,
    [TokenUpdated]        VARCHAR (50) NULL,
    [DateUpdated]         DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([IdCatClosureAccount] ASC),
    FOREIGN KEY ([ClosureAccountId]) REFERENCES [dbo].[ClosureAccount] ([IdClosureAccount]),
    FOREIGN KEY ([PayTime]) REFERENCES [dbo].[CatPaymentTime] ([TimePlaId]),
    FOREIGN KEY ([TypeOfInOutOfMoney]) REFERENCES [dbo].[ctgTypeOfInOutOfMoney] ([tio_pk_id]),
    FOREIGN KEY ([TypeService]) REFERENCES [dbo].[CatTypeServiceClosure] ([IdTypeService])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar las cuentas de Express Center junto con el tipo de servicio y tipo de pago que reciben.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatClosureAccount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatClosureAccount.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatClosureAccount', @level2type = N'COLUMN', @level2name = N'IdCatClosureAccount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de de la tabla ClosureAccount.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatClosureAccount', @level2type = N'COLUMN', @level2name = N'ClosureAccountId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatTypeServiceClosure.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatClosureAccount', @level2type = N'COLUMN', @level2name = N'TypeService';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla ctgTypeOfInOutOfMoney.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatClosureAccount', @level2type = N'COLUMN', @level2name = N'TypeOfInOutOfMoney';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatPaymentTime.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatClosureAccount', @level2type = N'COLUMN', @level2name = N'PayTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatClosureAccount', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatClosureAccount', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatClosureAccount', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que modificó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatClosureAccount', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se actualizó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatClosureAccount', @level2type = N'COLUMN', @level2name = N'DateUpdated';

