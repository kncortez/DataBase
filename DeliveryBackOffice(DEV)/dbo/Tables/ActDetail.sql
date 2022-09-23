CREATE TABLE [dbo].[ActDetail] (
    [IdActDetail]         INT           IDENTITY (1, 1) NOT NULL,
    [ActId]               INT           NOT NULL,
    [GuideSerie]          NVARCHAR (2)  NOT NULL,
    [GuideNumber]         INT           NOT NULL,
    [GuideDryPieceTotal]  INT           NOT NULL,
    [GuideColdPieceTotal] INT           NOT NULL,
    [DryPieceQuantity]    INT           NOT NULL,
    [ColdPieceQuantity]   INT           NOT NULL,
    [RowStatus]           BIT           CONSTRAINT [DF__ActDetail__RowSt__481C70BE] DEFAULT ((1)) NOT NULL,
    [TokenCreated]        NVARCHAR (50) NOT NULL,
    [DateCreated]         DATETIME      NOT NULL,
    [TokenUpdated]        NVARCHAR (50) NULL,
    [DateUpdated]         DATETIME      NULL,
    CONSTRAINT [PK__ActDetai__97FDCB8BB3BA02E6] PRIMARY KEY CLUSTERED ([IdActDetail] ASC)
);

