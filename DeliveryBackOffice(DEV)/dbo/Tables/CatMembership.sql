CREATE TABLE [dbo].[CatMembership] (
    [IdCatMembership]                INT             IDENTITY (1, 1) NOT NULL,
    [MembershipName]                 NVARCHAR (50)   NOT NULL,
    [MembershipDescription]          NVARCHAR (300)  NOT NULL,
    [MembershipCost]                 DECIMAL (18, 2) NOT NULL,
    [MembershipFixedValue]           INT             NOT NULL,
    [MembershipMaxServiceFixedValue] INT             NOT NULL,
    [MembershipValidity]             INT             NOT NULL,
    [RowStatus]                      BIT             NOT NULL,
    [TokenCreated]                   NVARCHAR (50)   NOT NULL,
    [DateCreated]                    DATETIME        NOT NULL,
    [TokenUpdated]                   NVARCHAR (50)   NULL,
    [DateUpdated]                    DATETIME        NULL,
    CONSTRAINT [PK_CatMembership] PRIMARY KEY CLUSTERED ([IdCatMembership] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembership', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembership', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembership', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembership', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembership', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tiempo, en días, que será valida la membresia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembership', @level2type = N'COLUMN', @level2name = N'MembershipValidity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad maxima de servicios los cuales tendran un monto fijo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembership', @level2type = N'COLUMN', @level2name = N'MembershipMaxServiceFixedValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto fijo de servicios de guía, limitado a una cantidad.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembership', @level2type = N'COLUMN', @level2name = N'MembershipFixedValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Costo monetario para comprar la membresia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembership', @level2type = N'COLUMN', @level2name = N'MembershipCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de la membresia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembership', @level2type = N'COLUMN', @level2name = N'MembershipDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la membresia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembership', @level2type = N'COLUMN', @level2name = N'MembershipName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembership', @level2type = N'COLUMN', @level2name = N'IdCatMembership';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de catalogo de membresias.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembership';

