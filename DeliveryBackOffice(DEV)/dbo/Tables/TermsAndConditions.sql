CREATE TABLE [dbo].[TermsAndConditions] (
    [IdTAC]        BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]         VARCHAR (50)  NOT NULL,
    [Description]  VARCHAR (250) NOT NULL,
    [RowStatus]    BIT           NOT NULL,
    [TokenCreated] VARCHAR (50)  NOT NULL,
    [DateCreated]  DATETIME      NOT NULL,
    [TokenUpdated] VARCHAR (50)  NULL,
    [DateUpdated]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdTAC] ASC)
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar los cambios de los términos y condiciones de transporte de Forza Delivery Express.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditions';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que modificó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditions', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditions', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditions', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de los términos y condiciones.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditions', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla TermsAndConditions.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditions', @level2type = N'COLUMN', @level2name = N'IdTAC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de los términos y condiciones.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditions', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditions', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditions', @level2type = N'COLUMN', @level2name = N'DateCreated';

