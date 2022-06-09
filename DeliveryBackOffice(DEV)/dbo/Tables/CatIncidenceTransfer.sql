CREATE TABLE [dbo].[CatIncidenceTransfer] (
    [IdCatIncidenceTransfer] INT           NOT NULL,
    [IncidenceName]          VARCHAR (50)  NOT NULL,
    [RowStatus]              BIT           DEFAULT ((1)) NULL,
    [TokenCreated]           NVARCHAR (50) NOT NULL,
    [DateCreated]            DATETIME      NOT NULL,
    [TokenUpdate]            NVARCHAR (50) NULL,
    [DateUpdate]             DATETIME      NULL,
    CONSTRAINT [Pk_CatIncidenceTransfer] PRIMARY KEY CLUSTERED ([IdCatIncidenceTransfer] ASC)
);

