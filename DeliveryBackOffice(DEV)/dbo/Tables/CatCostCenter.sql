CREATE TABLE [dbo].[CatCostCenter] (
    [IdCatCostCenter]      INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Codigo]       NVARCHAR (10)   NOT NULL,
    [Descripcion]  NVARCHAR (100)  NOT NULL,
    [IdCountry]    VARCHAR (2)     NOT NULL,
    [RowStatus]    BIT             NOT NULL DEFAULT 1,
    [TokenCreated] NVARCHAR (100)      NULL,
    [DateCreated]  DATETIME            NULL,
    [TokenUpdated]    NVARCHAR (50)    NULL,
    [DateUpdated]     DATETIME         NULL, 
    CONSTRAINT [PK_CatCostCenter] PRIMARY KEY CLUSTERED ([IdCatCostCenter] ASC),
    CONSTRAINT [FK_CatCostCenter_CatCountry] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[CatCountry] ([IdCountry])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Centro de costos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCostCenter';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificación de centro de costos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCostCenter', @level2type = N'COLUMN', @level2name = N'IdCatCostCenter';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'codigo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCostCenter', @level2type = N'COLUMN', @level2name = N'Codigo';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del centro de costos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCostCenter', @level2type = N'COLUMN', @level2name = N'Descripcion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'País al que pertenece el centro de costos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCostCenter', @level2type = N'COLUMN', @level2name = N'IdCountry';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Activo o Inactivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCostCenter', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCostCenter', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCostCenter', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCostCenter', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCostCenter', @level2type = N'COLUMN', @level2name = N'DateUpdated';

