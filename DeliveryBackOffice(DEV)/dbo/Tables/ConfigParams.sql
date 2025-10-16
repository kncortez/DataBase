CREATE TABLE [dbo].[ConfigParams] (
    [ConfigParamsId] BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]           VARCHAR (500) NOT NULL,
    [Description]    VARCHAR (MAX) NULL,
    [Value]          VARCHAR (MAX) NOT NULL,
    [Status]         SMALLINT      NOT NULL,
    [CreateDate]     DATETIME      CONSTRAINT [DefaultDate] DEFAULT (getdate()) NOT NULL,
    [IdCountry]      VARCHAR (2)   NULL,
    [IdCurrencyCOD]  INT           NULL,
    CONSTRAINT [PK_ConfigParams] PRIMARY KEY CLUSTERED ([ConfigParamsId] ASC),
    FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[CatCountry] ([IdCountry]),
    FOREIGN KEY ([IdCurrencyCOD]) REFERENCES [dbo].[CatCurrencyCOD] ([IdCatCurrencyCOD])
);



GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre que se le atribuye al parámetro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConfigParams', @level2type=N'COLUMN',@level2name=N'Name'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Se encuentra la descripción que tendra el parámetro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConfigParams', @level2type=N'COLUMN',@level2name=N'Description'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'El valor con el que contara el parámetro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConfigParams', @level2type=N'COLUMN',@level2name=N'Value'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 Estado activo, 0 estado inactivo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConfigParams', @level2type=N'COLUMN',@level2name=N'Status'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación del parámetro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConfigParams', @level2type=N'COLUMN',@level2name=N'CreateDate'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del país al que pertenece el valor configurado del parámetro.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConfigParams', @level2type=N'COLUMN',@level2name=N'IdCountry'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del tipo de moneda que corresponde al valor del parámetro que contenga.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ConfigParams', @level2type=N'COLUMN',@level2name=N'IdCurrencyCOD'
GO
