
CREATE TABLE [dbo].[DefaultValuesPerCountry](
    [IdCountry] [nvarchar](4) NOT NULL,
    [UseMultiCountry] [bit] NOT NULL,
    [RowStatus] [bit] NOT NULL,
    [TokenCreated] [varchar](50) NOT NULL,
    [DateCreated] [datetime] NOT NULL,
    [TokenUpdated] [varchar](50) NULL,
    [DateUpdated] [datetime] NULL
) ON [PRIMARY];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de país ingresado a multipais', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'IdCountry';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bandera para determinar si el país esta activo o no para multipais', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'UseMultiCountry';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del país', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DefaultValuesPerCountry', @level2type = N'COLUMN', @level2name = N'DateUpdated';