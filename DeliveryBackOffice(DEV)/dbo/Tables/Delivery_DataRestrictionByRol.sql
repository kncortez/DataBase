CREATE TABLE [dbo].[Delivery_DataRestrictionByRol] (
    [DRR_IdRol]              INT         NOT NULL,
    [DRR_IdCountry]          VARCHAR (2) NOT NULL,
    [DRR_IdHubLogistic]      INT         NOT NULL,
    [DRR_IdModule]           INT         NOT NULL,
    [DRR_IdVisitPointClient] INT         NOT NULL,
    [DRR_Status]             BIT         NOT NULL,
    CONSTRAINT [PK_LGN_DataRestrictionByRol] PRIMARY KEY CLUSTERED ([DRR_IdRol] ASC, [DRR_IdCountry] ASC, [DRR_IdHubLogistic] ASC, [DRR_IdModule] ASC, [DRR_IdVisitPointClient] ASC)
);

