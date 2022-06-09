CREATE TABLE [dbo].[Incident] (
    [ID]          TINYINT        NOT NULL,
    [Description] NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_Incident] PRIMARY KEY CLUSTERED ([ID] ASC)
);

