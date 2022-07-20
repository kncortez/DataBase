CREATE TABLE [dbo].[CatMembership] (
    [IdCatMembership]                INT             IDENTITY (1, 1) NOT NULL,
    [MembershipName]                 NVARCHAR (50)   NOT NULL,
    [MembershipDescription]          NVARCHAR (300)  NOT NULL,
    [MembershipCost]                 DECIMAL (18, 2) NOT NULL,
    [MembershipFixedValue]           INT             NOT NULL,
    [MembershipMaxServiceFixedValue] INT             NOT NULL,
    [MembershipValidity]             INT             NOT NULL,
    [RowStatus]                      BIT             NOT NULL,
    [TokenCreated]                   NVARCHAR (50)   NOT NULL,
    [DateCreated]                    DATETIME        NOT NULL,
    [TokenUpdated]                   NVARCHAR (50)   NULL,
    [DateUpdated]                    DATETIME        NULL,
    CONSTRAINT [PK_CatMembership] PRIMARY KEY CLUSTERED ([IdCatMembership] ASC)
);

