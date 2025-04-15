CREATE TABLE [dbo].[BatchDetailCODLog] (
    [IdBatchDetailCODLog] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [BatchCODId]          INT           NULL,
    [GuideSerie]          NVARCHAR (2)  NOT NULL,
    [GuideNumber]         INT           NOT NULL,
    [Excluded]            BIT           NOT NULL,
    [RowStatus]           BIT           NOT NULL,
    [TokenCreated]        NVARCHAR (50) NOT NULL,
    [DateCreated]         DATETIME      NOT NULL,
    [TokenUpdated]        NVARCHAR (50) NOT NULL,
    [DateUpdated]         DATETIME      NOT NULL,
    CONSTRAINT [PK_BatchDetailCODLog] PRIMARY KEY CLUSTERED ([IdBatchDetailCODLog] ASC)
);






GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id del lote COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCODLog', @level2type = N'COLUMN', @level2name = N'BatchCODId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCODLog', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Numero de guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCODLog', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si la guía fue excluida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCODLog', @level2type = N'COLUMN', @level2name = N'Excluded';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Registra la inclusión o exclusión de una guía en lotes de COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCODLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BatchDetailCODLog', @level2type = N'COLUMN', @level2name = N'IdBatchDetailCODLog';

