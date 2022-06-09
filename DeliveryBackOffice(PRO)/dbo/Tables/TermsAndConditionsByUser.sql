CREATE TABLE [dbo].[TermsAndConditionsByUser] (
    [IdTACByUser]  BIGINT       IDENTITY (1, 1) NOT NULL,
    [TACId]        BIGINT       NOT NULL,
    [IdAccount]    BIGINT       NOT NULL,
    [TAC]          BIT          NOT NULL,
    [RowStatus]    BIT          NOT NULL,
    [TokenCreated] VARCHAR (50) NOT NULL,
    [DateCreated]  DATETIME     NOT NULL,
    [TokenUpdated] VARCHAR (50) NULL,
    [DateUpdated]  DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([IdTACByUser] ASC),
    FOREIGN KEY ([IdAccount]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    FOREIGN KEY ([TACId]) REFERENCES [dbo].[TermsAndConditions] ([IdTAC])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar si un usuario ha aceptado los términos y condiciones de transporte de Forza Delivery Express', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla TermsAndConditionsByUser.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByUser', @level2type = N'COLUMN', @level2name = N'IdTACByUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla TermsAndConditions.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByUser', @level2type = N'COLUMN', @level2name = N'TACId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla Account.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByUser', @level2type = N'COLUMN', @level2name = N'IdAccount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado que indica si un usuario ya ha aceptado los términos y condiciones, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByUser', @level2type = N'COLUMN', @level2name = N'TAC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByUser', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByUser', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByUser', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que modificó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByUser', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByUser', @level2type = N'COLUMN', @level2name = N'DateUpdated';

