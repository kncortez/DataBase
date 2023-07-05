CREATE TABLE [dbo].[ExpressAccountServiceCartDetail] (
    [IdExpressAccountServiceCartDetail] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ExpressAccountServiceCartId]       BIGINT        NOT NULL,
    [GuideSerie]                        NVARCHAR (2)  NOT NULL,
    [GuideNumber]                       INT           NOT NULL,
    [RowStatus]                         BIT           CONSTRAINT [DF_ExpressAccountServiceCartDetail_RowStatus] DEFAULT ((1)) NOT NULL,
    [DateCreated]                       DATETIME      NOT NULL,
    [TokenCreated]                      NVARCHAR (50) NOT NULL,
    [DateUpdated]                       DATETIME      NULL,
    [TokenUpdated]                      NVARCHAR (50) NULL,
    CONSTRAINT [PK_ExpressAccountServiceCartDetail] PRIMARY KEY CLUSTERED ([IdExpressAccountServiceCartDetail] ASC),
    CONSTRAINT [FK_ExpressAccountServiceCartDetail_ExpressAccountServiceCart] FOREIGN KEY ([ExpressAccountServiceCartId]) REFERENCES [dbo].[ExpressAccountServiceCart] ([IdExpressAccountServiceCart])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'usuario que actualiza el usuario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCartDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'usuario de cración', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCartDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'indica que el registro est5a activo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCartDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificación de detalle de carrito ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCartDetail', @level2type = N'COLUMN', @level2name = N'IdExpressAccountServiceCartDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'serie de guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCartDetail', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'número de guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCartDetail', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de carrito de servicio de cuenta Express', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCartDetail', @level2type = N'COLUMN', @level2name = N'ExpressAccountServiceCartId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCartDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExpressAccountServiceCartDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';

