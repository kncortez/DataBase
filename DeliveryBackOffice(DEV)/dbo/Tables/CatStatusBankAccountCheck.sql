CREATE TABLE [dbo].[CatStatusBankAccountCheck] (
    [IdCatStatusBankAccountCheck] INT           IDENTITY (1, 1) NOT NULL,
    [Description]                 VARCHAR (50)  NOT NULL,
    [TokenCreated]                NVARCHAR (50) NULL,
    [DateCreate]                  DATETIME      NULL,
    [TokenUpdate]                 NVARCHAR (50) NULL,
    [DateUpdate]                  DATETIME      NULL,
    [RowStatus]                   BIT           NULL,
    PRIMARY KEY CLUSTERED ([IdCatStatusBankAccountCheck] ASC)
);

