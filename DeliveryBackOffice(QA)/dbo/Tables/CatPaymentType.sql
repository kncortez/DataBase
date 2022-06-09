CREATE TABLE [dbo].[CatPaymentType] (
    [PayTypeId]           INT           IDENTITY (1, 1) NOT NULL,
    [PayTypeName]         VARCHAR (55)  NULL,
    [PayTypeDescriptions] VARCHAR (100) NULL,
    [PayTypeAbrev]        VARCHAR (10)  NULL,
    [PayTypeStatus]       INT           NULL,
    [TokenCreated]        VARCHAR (50)  NULL,
    [DateCreated]         DATETIME      NULL,
    [TokenUpdated]        VARCHAR (50)  NULL,
    [DateUpdated]         DATETIME      NULL,
    CONSTRAINT [PayTypeId] PRIMARY KEY CLUSTERED ([PayTypeId] ASC)
);

