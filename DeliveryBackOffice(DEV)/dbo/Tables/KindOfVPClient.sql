CREATE TABLE [dbo].[KindOfVPClient] (
    [IdKindOfVPClient] INT           IDENTITY (1, 1) NOT NULL,
    [KindOfVPName]     NVARCHAR (50) NULL,
    [KindOfVPStatus]   BIT           NULL,
    [TokenCreated]     NVARCHAR (50) NULL,
    [DateCreated]      DATETIME      NULL,
    [TokenUpdate]      NVARCHAR (50) NULL,
    [DateUpdated]      DATETIME      NULL,
    [IdCountry]        VARCHAR (2)   NULL,
    CONSTRAINT [PK_KindOfVPClient] PRIMARY KEY CLUSTERED ([IdKindOfVPClient] ASC),
    CONSTRAINT [FK_KindOfVPClient_CatCountry] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[CatCountry] ([IdCountry])
);




GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del tipo de punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'KindOfVPClient', @level2type=N'COLUMN',@level2name=N'IdKindOfVPClient'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre del tipo de punto de visita' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'KindOfVPClient', @level2type=N'COLUMN',@level2name=N'KindOfVPName'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'1 activo, 2 inactivo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'KindOfVPClient', @level2type=N'COLUMN',@level2name=N'KindOfVPStatus'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'KindOfVPClient', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creacion de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'KindOfVPClient', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualizacion de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'KindOfVPClient', @level2type=N'COLUMN',@level2name=N'TokenUpdate'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualizacion de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'KindOfVPClient', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla que contiene la informacion del tipo de punto de visita del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'KindOfVPClient'
GO

