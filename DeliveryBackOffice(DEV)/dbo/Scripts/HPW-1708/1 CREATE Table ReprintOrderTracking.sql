CREATE TABLE [dbo].[ReprintOrderTracking] (
    [IdRepOrdTra]          INT           IDENTITY (1, 1) NOT NULL,
    [GuideSerie]           NVARCHAR (2)  NOT NULL,
    [GuideNumber]          INT           NOT NULL,
    [System]               NVARCHAR (80) NULL,
    [User]                 NVARCHAR (80) NULL,
    [IsPendingReprint]     BIT           CONSTRAINT [DF_ReprintOrderTracking_IsPendingReprint] DEFAULT ((0)) NOT NULL,
    [RowStatus]            BIT           CONSTRAINT [DF_ReprintOrderTracking_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]         NVARCHAR (50) NOT NULL,
    [DateCreated]          DATETIME      NOT NULL,
    [TokenUpdated]         NVARCHAR (50) NULL,
    [DateUpdated]          DATETIME      NULL,
    CONSTRAINT [PK_ReprintOrderTracking] PRIMARY KEY ([IdRepOrdTra])
);


GO
CREATE NONCLUSTERED INDEX [IX_ReprintOrderTracking]
    ON [dbo].[ReprintOrderTracking]([GuideSerie] ASC, [GuideNumber] DESC);