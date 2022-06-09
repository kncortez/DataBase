CREATE TABLE [dbo].[CatConditionOfPayment] (
    [IdConditionOfPayment]          INT            IDENTITY (1, 1) NOT NULL,
    [ConditionOfPayment]            NVARCHAR (50)  NOT NULL,
    [ConditionOfPaymenDescription]  NVARCHAR (200) NULL,
    [ConditionOfPaymenAbbreviation] NVARCHAR (20)  NULL,
    [RowStatus]                     BIT            CONSTRAINT [DF_CatConditionOfPayment_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]                  NVARCHAR (50)  NOT NULL,
    [DateCreated]                   DATETIME       NOT NULL,
    [TokenUpdated]                  NVARCHAR (50)  NULL,
    [DateUpdated]                   DATETIME       NULL,
    CONSTRAINT [PK_CatConditionOfPayment] PRIMARY KEY CLUSTERED ([IdConditionOfPayment] ASC)
);

