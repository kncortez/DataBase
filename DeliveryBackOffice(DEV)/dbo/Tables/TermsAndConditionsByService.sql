CREATE TABLE [dbo].[TermsAndConditionsByService] (
    [IdTermsAndConditionsByService] BIGINT       IDENTITY (1, 1) NOT NULL,
    [TermsAndConditionsId]          BIGINT       NOT NULL,
    [ServiceManagementId]           INT          NOT NULL,
    [IsAccepted]                    BIT          NOT NULL,
    [RowStatus]                     BIT          NOT NULL,
    [TokenCreated]                  VARCHAR (50) NOT NULL,
    [DateCreated]                   DATETIME     NOT NULL,
    [TokenUpdated]                  VARCHAR (50) NULL,
    [DateUpdated]                   DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([IdTermsAndConditionsByService] ASC),
    CONSTRAINT [FK_TACBYSERVICE_SERVICEM] FOREIGN KEY ([ServiceManagementId]) REFERENCES [dbo].[ServiceManagement] ([IdServiceManagement]),
    CONSTRAINT [FK_TACBYSERVICE_TAC] FOREIGN KEY ([TermsAndConditionsId]) REFERENCES [dbo].[TermsAndConditions] ([IdTAC])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en que se modifica el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByService', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que modifica el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByService', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByService', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByService', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByService', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Terminos y condiciones aceptadas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByService', @level2type = N'COLUMN', @level2name = N'IsAccepted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByService', @level2type = N'COLUMN', @level2name = N'ServiceManagementId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de los términos y condiciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByService', @level2type = N'COLUMN', @level2name = N'TermsAndConditionsId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de términos y condiciones por servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByService', @level2type = N'COLUMN', @level2name = N'IdTermsAndConditionsByService';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar términos y condiciones por servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TermsAndConditionsByService';

