CREATE TABLE [dbo].[CatTypeSenderReceiver] (
    [IdCatTypeSenderReceiver] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TypeName]                NVARCHAR (30) NOT NULL,
    [RowStatus]               BIT           NOT NULL,
    [TokenCreated]            NVARCHAR (50) NOT NULL,
    [DateCreated]             DATETIME      NOT NULL,
    [TokenUpdated]            NVARCHAR (50) NULL,
    [DateUpdated]             DATETIME      NULL,
    [IdCountry]               VARCHAR (2)   NULL,
    CONSTRAINT [PK_CatTypeSenderReceiver] PRIMARY KEY CLUSTERED ([IdCatTypeSenderReceiver] ASC),
    CONSTRAINT [FK_TypeSenderIdCountry_CountryIdCountry] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[CatCountry] ([IdCountry])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catálogo de tipos de piloto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeSenderReceiver';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeSenderReceiver', @level2type = N'COLUMN', @level2name = N'IdCatTypeSenderReceiver';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del tipo de piloto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeSenderReceiver', @level2type = N'COLUMN', @level2name = N'TypeName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeSenderReceiver', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeSenderReceiver', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeSenderReceiver', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeSenderReceiver', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeSenderReceiver', @level2type = N'COLUMN', @level2name = N'DateUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de pais', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeSenderReceiver', @level2type = N'COLUMN', @level2name = N'IdCountry';
