CREATE TABLE [dbo].[CatStateConfirmedAddress] (
    [IdStatus]     INT           IDENTITY (1, 1) NOT NULL,
    [NameState]    NVARCHAR (50) NOT NULL,
    [TokenCreated] VARCHAR (50)  NOT NULL,
    [DateCreated]  DATETIME      NOT NULL,
    [TokenUpdate]  VARCHAR (50)  NULL,
    [DateUpdate]   DATETIME      NULL,
    [RowStatus]    BIT           NOT NULL,
    CONSTRAINT [PK_CatSateConfirmedAddress] PRIMARY KEY CLUSTERED ([IdStatus] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Etado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStateConfirmedAddress', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en que se modifica el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStateConfirmedAddress', @level2type = N'COLUMN', @level2name = N'DateUpdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que modifica el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStateConfirmedAddress', @level2type = N'COLUMN', @level2name = N'TokenUpdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en que se creó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStateConfirmedAddress', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStateConfirmedAddress', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del estado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStateConfirmedAddress', @level2type = N'COLUMN', @level2name = N'NameState';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del registro de estado de una dirección confirmada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStateConfirmedAddress', @level2type = N'COLUMN', @level2name = N'IdStatus';

