CREATE TABLE ZPLFilesStatusLog (
    [IdZPLFilesStatusLog]   INT IDENTITY(1,1) NOT FOR REPLICATION NOT NULL PRIMARY KEY,
    [IdCustomer]            INT NOT NULL,
    [TicketNumber]          NVARCHAR(150) NOT NULL,
    [FileName]              NVARCHAR(100) NOT NULL,
    [IsDeleted]             BIT NOT NULL DEFAULT 0,
    [IsProcessed]           BIT NOT NULL DEFAULT 0,
    [JobId]                 NVARCHAR(75) NOT NULL DEFAULT '',
    [GuideSerie]            NVARCHAR (2)    NOT NULL,
    [GuideNumber]           INT             NOT NULL,
    [DateCreatedQueue]      DATETIME NOT NULL DEFAULT SYSDATETIME(),
    [TokenCreated]          NVARCHAR(50) NOT NULL DEFAULT '',
    [DateCreated]           DATETIME NOT NULL DEFAULT SYSDATETIME(),
    [TokenUpdated]          NVARCHAR(50) NULL,
    [DateUpdated]           DATETIME NULL,
    CONSTRAINT FK_ZPLFilesStatusLog_Customer
        FOREIGN KEY (IdCustomer)
        REFERENCES Customer(IdCustomer)
        ON DELETE CASCADE,
    CONSTRAINT FK_ZPLFilesStatusLog_DeliveryOrder
        FOREIGN KEY (GuideSerie, GuideNumber)
        REFERENCES DeliveryOrder(Guide_Serie, Guide_Number)
        ON DELETE CASCADE
);

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ZPLFilesStatusLog', @level2type=N'COLUMN',@level2name=N'IdZPLFilesStatusLog'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador único del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ZPLFilesStatusLog', @level2type=N'COLUMN',@level2name=N'IdCustomer'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de ticket' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ZPLFilesStatusLog', @level2type=N'COLUMN',@level2name=N'TicketNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de archivo en S3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ZPLFilesStatusLog', @level2type=N'COLUMN',@level2name=N'FileName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fue eliminado de S3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ZPLFilesStatusLog', @level2type=N'COLUMN',@level2name=N'IsDeleted'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ya fue procesado en S3' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ZPLFilesStatusLog', @level2type=N'COLUMN',@level2name=N'IsProcessed'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de Job' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ZPLFilesStatusLog', @level2type=N'COLUMN',@level2name=N'JobId'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Serie de guía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ZPLFilesStatusLog', @level2type=N'COLUMN',@level2name=N'GuideSerie'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de guía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ZPLFilesStatusLog', @level2type=N'COLUMN',@level2name=N'GuideNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ingreso a cola SQS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ZPLFilesStatusLog', @level2type=N'COLUMN',@level2name=N'DateCreatedQueue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ZPLFilesStatusLog', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ZPLFilesStatusLog', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ZPLFilesStatusLog', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ZPLFilesStatusLog', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Registro histórico de archivos ZPL procesados' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ZPLFilesStatusLog'
GO

CREATE NONCLUSTERED INDEX IDX_ZPLFilesStatusLog_FileName
ON ZPLFilesStatusLog(Filename);

CREATE NONCLUSTERED INDEX IDX_ZPLFilesStatusLog_Guide
ON ZPLFilesStatusLog(GuideSerie, GuideNumber);