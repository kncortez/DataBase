CREATE TABLE [dbo].[DumpServiceCoverage] (
    [IdDump]       BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [DumpFileName] NVARCHAR (100) NULL,
    [DumpVersion]  NVARCHAR (50)  NULL,
    [HeaderCode]   VARCHAR (10)   NULL,
    [IdSettlement] BIGINT         NULL,
    [Coverage]     NVARCHAR (50)  NULL,
    [DeliveryTime] NVARCHAR (50)  NULL,
    [Hub]          NVARCHAR (50)  NULL,
    [RouteCode]    NVARCHAR (100) NULL,
    [SDD]          BIT            NULL,
    [NDD]          BIT            NULL,
    [TDA]          BIT            NULL,
    [RowStatus]    BIT            NULL,
    [TokenCreated] NVARCHAR (50)  NULL,
    [DateCreated]  DATETIME       NULL,
    [TokenUpdated] NVARCHAR (50)  NULL,
    [DateUpdated]  DATETIME       NULL,
    CONSTRAINT [PK_DumpServiceCoverage] PRIMARY KEY CLUSTERED ([IdDump] ASC)
);






GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-Hub]
    ON [dbo].[DumpServiceCoverage]([Hub] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-HeaderCode]
    ON [dbo].[DumpServiceCoverage]([HeaderCode] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-IdSettlement]
    ON [dbo].[DumpServiceCoverage]([IdSettlement] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DumpServiceCoverage_SettlementStatusList]
    ON [dbo].[DumpServiceCoverage]([IdSettlement] ASC, [RowStatus] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_RowStatus_include]
    ON [dbo].[DumpServiceCoverage]([RowStatus] ASC)
    INCLUDE([HeaderCode], [Hub]);

