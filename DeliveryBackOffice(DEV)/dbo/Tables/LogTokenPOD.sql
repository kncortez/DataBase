CREATE TABLE [dbo].[LogTokenPOD] (
    [IdLogToken]   INT           IDENTITY (1, 1) NOT NULL,
    [LogTokenPOD]  VARCHAR (200) NULL,
    [IdCourierman] INT           NULL,
    [RowStatus]    BIT           NULL,
    [DateCreated]  DATETIME      NULL,
    [DateUpdate]   DATETIME      NULL,
    CONSTRAINT [PK_IdLogToken] PRIMARY KEY CLUSTERED ([IdLogToken] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IDX_LogTokenPOD]
    ON [dbo].[LogTokenPOD]([LogTokenPOD] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_IdCourierman]
    ON [dbo].[LogTokenPOD]([IdCourierman] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_IdCourierman_RowStatus_INCLUDE]
    ON [dbo].[LogTokenPOD]([IdCourierman] ASC, [RowStatus] ASC)
    INCLUDE([LogTokenPOD], [DateCreated]);

