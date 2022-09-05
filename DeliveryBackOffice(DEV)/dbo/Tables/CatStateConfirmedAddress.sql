CREATE TABLE [dbo].[CatStateConfirmedAddress] (
    [IdStatus]     INT           IDENTITY (1, 1) NOT NULL,
    [NameState]    NVARCHAR (50) NOT NULL,
    [TokenCreated] VARCHAR (50)  NOT NULL,
    [DateCreated]  DATETIME      NOT NULL,
    [TokenUpdate]  VARCHAR (50)  NULL,
    [DateUPdate]   DATETIME      NULL,
    [RowStatus]    BIT           NOT NULL,
    CONSTRAINT [PK_CatSateConfirmedAddress] PRIMARY KEY CLUSTERED ([IdStatus] ASC)
);

