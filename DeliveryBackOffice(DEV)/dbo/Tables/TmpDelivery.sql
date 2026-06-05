CREATE TABLE [dbo].[TmpDelivery] (
    [Guide_Number] INT             NOT NULL,
    [BilledWeight] DECIMAL (12, 2) NULL,
    CONSTRAINT [PK_Guide_Number] PRIMARY KEY CLUSTERED ([Guide_Number] ASC)
);

