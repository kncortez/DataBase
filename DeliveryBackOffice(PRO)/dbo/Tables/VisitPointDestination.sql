CREATE TABLE [dbo].[VisitPointDestination] (
    [IdVPSource]   INT           NOT NULL,
    [IDVPDestiny]  INT           NOT NULL,
    [IsGuard]      BIT           NULL,
    [IsTransit]    BIT           NULL,
    [IsDefault]    BIT           NULL,
    [RowStatus]    BIT           NULL,
    [TokenCreated] NVARCHAR (50) NULL,
    [DateCreated]  DATETIME      NULL,
    [TokenUpdated] NVARCHAR (50) NULL,
    [DateUpdated]  DATETIME      NULL,
    CONSTRAINT [PK_VisitPointDestination] PRIMARY KEY CLUSTERED ([IdVPSource] ASC, [IDVPDestiny] ASC),
    CONSTRAINT [FK_VisitPointDestination_VisitPointClientDestiny] FOREIGN KEY ([IDVPDestiny]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference]),
    CONSTRAINT [FK_VisitPointDestination_VisitPointClientSource] FOREIGN KEY ([IdVPSource]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);

