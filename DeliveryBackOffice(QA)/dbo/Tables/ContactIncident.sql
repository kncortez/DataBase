CREATE TABLE [dbo].[ContactIncident] (
    [ID]   TINYINT       IDENTITY (1, 1) NOT NULL,
    [Name] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_ContactIncident] PRIMARY KEY CLUSTERED ([ID] ASC)
);

