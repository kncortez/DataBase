CREATE TABLE [dbo].[LogTokenPOD] (
    [IdLogToken]   INT           IDENTITY (1, 1) NOT NULL,
    [LogTokenPOD]  VARCHAR (200) NULL,
    [IdCourierman] INT           NULL,
    [RowStatus]    BIT           NULL,
    [DateCreated]  DATETIME      NULL,
    [DateUpdate]   DATETIME      NULL,
    CONSTRAINT [PK_IdLogToken] PRIMARY KEY CLUSTERED ([IdLogToken] ASC)
);

