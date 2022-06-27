CREATE TABLE [dbo].[Account] (
    [AccIdAccount]     BIGINT        IDENTITY (1, 1) NOT NULL,
    [AccName]          VARCHAR (100) NOT NULL,
    [AccIdTypeAccount] INT           NOT NULL,
    [AccRowStatus]     BIT           NOT NULL,
    [AccTokenCreated]  VARCHAR (50)  NOT NULL,
    [AccDateCreated]   DATETIME      NOT NULL,
    [AccTokenUpdated]  VARCHAR (50)  NULL,
    [AccDateUpdated]   DATETIME      NULL,
    [IdCustomer]       INT           NULL,
    [AccConfirm]       CHAR (1)      NULL,
    PRIMARY KEY CLUSTERED ([AccIdAccount] ASC),
    CONSTRAINT [FKAccountType] FOREIGN KEY ([AccIdTypeAccount]) REFERENCES [dbo].[CatTypeAccount] ([TacIdTypeAccount]),
    CONSTRAINT [FKIdCustumer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer])
);




GO
CREATE NONCLUSTERED INDEX [IDX_IdCustomer]
    ON [dbo].[Account]([IdCustomer] ASC);

