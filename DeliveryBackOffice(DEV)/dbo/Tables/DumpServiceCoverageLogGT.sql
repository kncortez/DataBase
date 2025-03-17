CREATE TABLE [dbo].[DumpServiceCoverageLogGT] (
    [IdDump]       BIGINT         NOT NULL,
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
    CONSTRAINT [PK_DumpServiceCoverageLogGT] PRIMARY KEY CLUSTERED ([IdDump] ASC)
);

