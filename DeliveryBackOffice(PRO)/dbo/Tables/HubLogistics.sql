CREATE TABLE [dbo].[HubLogistics] (
    [IdHubLogistic]   INT          IDENTITY (1, 1) NOT NULL,
    [HubName]         VARCHAR (50) NULL,
    [HubAbbreviation] VARCHAR (5)  NULL,
    [HubStatus]       BIT          NULL,
    [IdStation]       INT          NULL,
    [IdCountry]       VARCHAR (2)  NULL,
    [TokenCreated]    VARCHAR (50) NULL,
    [DateCreated]     DATETIME     NULL,
    [TokenUpdate]     VARCHAR (50) NULL,
    [DateUpdated]     DATETIME     NULL,
    [IsGateway]       BIT          NULL,
    CONSTRAINT [PK_HubLogistics] PRIMARY KEY CLUSTERED ([IdHubLogistic] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [NonClusteredIndex-HubAbbreviation]
    ON [dbo].[HubLogistics]([HubAbbreviation] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Gateway 1, Hub 0', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HubLogistics', @level2type = N'COLUMN', @level2name = N'IsGateway';

