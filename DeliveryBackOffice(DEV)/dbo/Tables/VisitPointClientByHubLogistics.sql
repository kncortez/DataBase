CREATE TABLE [dbo].[VisitPointClientByHubLogistics] (
    [IdVpcHub]           INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [IdVisitPointClient] INT          NULL,
    [IdHublogistic]      INT          NULL,
    [StatusTownshipHub]  BIT          NULL,
    [TokenCreated]       VARCHAR (50) NULL,
    [DateCreated]        DATETIME     NULL,
    [TokenUpdate]        VARCHAR (50) NULL,
    [DateUpdated]        DATETIME     NULL,
    CONSTRAINT [PK_VpcByHubLogistic] PRIMARY KEY CLUSTERED ([IdVpcHub] ASC),
    CONSTRAINT [FK_VpcByHubLogistics_HubLogistics] FOREIGN KEY ([IdHublogistic]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FK_VpcByHubLogistics_Vpc] FOREIGN KEY ([IdVisitPointClient]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);

