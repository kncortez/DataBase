CREATE TABLE [dbo].[AuthorizationLogCOD] (
    [IdAuthorizationLogCOD] BIGINT          IDENTITY (1, 1) NOT NULL,
    [GuideSerie]            VARCHAR (4)     NOT NULL,
    [GuideNumber]           INT             NOT NULL,
    [Voucher]               NVARCHAR (800)  NULL,
    [AuthorizedBy]          VARCHAR (MAX)   NOT NULL,
    [ReasonId]              BIGINT          NOT NULL,
    [OldCODAmount]          DECIMAL (14, 2) NOT NULL,
    [NewCODAmount]          DECIMAL (14, 2) NOT NULL,
    [RowStatus]             BIT             NOT NULL,
    [TokenCreated]          VARCHAR (50)    NOT NULL,
    [DateCreated]           DATETIME        NOT NULL,
    [TokenUpdated]          VARCHAR (50)    NULL,
    [DateUpdated]           DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdAuthorizationLogCOD] ASC)
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Voucher correspondiente a la guía a la cual se realiza cambio de precio COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuthorizationLogCOD', @level2type = N'COLUMN', @level2name = N'Voucher';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es el token de usuario con el que se actualizó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuthorizationLogCOD', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es el token de usuario con el que se insertó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuthorizationLogCOD', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es el estado del registro, para poder deshabilitarlo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuthorizationLogCOD', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del catálogo de razones por las que se realiza el cambio de precio COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuthorizationLogCOD', @level2type = N'COLUMN', @level2name = N'ReasonId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto anterior que se tenía de precio COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuthorizationLogCOD', @level2type = N'COLUMN', @level2name = N'OldCODAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nuevo monto que se registrará de precio COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuthorizationLogCOD', @level2type = N'COLUMN', @level2name = N'NewCODAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id para la tabla AuthorizationLogCOD ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuthorizationLogCOD', @level2type = N'COLUMN', @level2name = N'IdAuthorizationLogCOD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de guía a la cual se realiza cambio de precio COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuthorizationLogCOD', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía a la cual se realiza cambio de precio COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuthorizationLogCOD', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es la fecha en que se actualizó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuthorizationLogCOD', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es la fecha en la que se insertó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuthorizationLogCOD', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la persona que autoriza el cambio de cambio de precio COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuthorizationLogCOD', @level2type = N'COLUMN', @level2name = N'AuthorizedBy';


GO
CREATE NONCLUSTERED INDEX [IDX_GuideSerie_GuideSerie]
    ON [dbo].[AuthorizationLogCOD]([GuideSerie] ASC, [GuideNumber] ASC);

