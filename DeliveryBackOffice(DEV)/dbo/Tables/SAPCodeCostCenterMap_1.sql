CREATE TABLE [dbo].[SAPCodeCostCenterMap] (
    [IdSAPCodeCostCenterMap] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [SAPCode]                NVARCHAR (20)  NOT NULL,
    [Name]                   NVARCHAR (100) NOT NULL,
    [Description]            NVARCHAR (200) NOT NULL,
    [OcrCode2]               NVARCHAR (10)  DEFAULT ('400000') NOT NULL,
    [IdCountry]              VARCHAR (2)    NOT NULL,
    [RowStatus]              BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]           NVARCHAR (100) NULL,
    [DateCreated]            DATETIME       NULL,
    [TokenUpdated]           NVARCHAR (100) NULL,
    [DateUpdated]            DATETIME       NULL,
    CONSTRAINT [PK_SAPCodeCostCenterMap] PRIMARY KEY CLUSTERED ([IdSAPCodeCostCenterMap] ASC),
    CONSTRAINT [FK_SAPCodeCostCenterMap_CatCountry] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[CatCountry] ([IdCountry])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SAPCodeCostCenterMap', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SAPCodeCostCenterMap', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SAPCodeCostCenterMap', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SAPCodeCostCenterMap', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Activo o Inactivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SAPCodeCostCenterMap', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'País al que pertenece el centro de costos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SAPCodeCostCenterMap', @level2type = N'COLUMN', @level2name = N'IdCountry';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'codigo centro de costos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SAPCodeCostCenterMap', @level2type = N'COLUMN', @level2name = N'OcrCode2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del articulo SAP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SAPCodeCostCenterMap', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del articulo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SAPCodeCostCenterMap', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'codigo SAP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SAPCodeCostCenterMap', @level2type = N'COLUMN', @level2name = N'SAPCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificación del mapeo de códigos de centro de costos de SAP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SAPCodeCostCenterMap', @level2type = N'COLUMN', @level2name = N'IdSAPCodeCostCenterMap';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Mapeo de códigos de centro de costos de SAP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SAPCodeCostCenterMap';

