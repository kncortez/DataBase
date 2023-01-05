CREATE TABLE [dbo].[MembershipDiscountRange] (
    [IdMembershipDiscountRange] INT            IDENTITY (1, 1) NOT NULL,
    [MembershipId]              INT            NOT NULL,
    [DiscountLowServiceRange]   INT            NOT NULL,
    [DiscountTopServiceRange]   INT            NULL,
    [ValueTypeId]               INT            NOT NULL,
    [DiscountValue]             DECIMAL (5, 2) NOT NULL,
    [RowStatus]                 BIT            CONSTRAINT [DF_MembershipDiscountRange_RowStatus] DEFAULT ((1)) NULL,
    [TokenCreated]              NVARCHAR (50)  NOT NULL,
    [DateCreated]               DATETIME       NOT NULL,
    [TokenUpdated]              NVARCHAR (50)  NULL,
    [DateUpdated]               DATETIME       NULL,
    CONSTRAINT [PK_MembershipDiscountRange] PRIMARY KEY CLUSTERED ([IdMembershipDiscountRange] ASC),
    CONSTRAINT [FK_MembershipDiscountRange_Membership] FOREIGN KEY ([MembershipId]) REFERENCES [dbo].[Membership] ([IdMembership]),
    CONSTRAINT [FK_MembershipDiscountRange_ValueType] FOREIGN KEY ([ValueTypeId]) REFERENCES [dbo].[CatValueType] ([IdCatValueType])
);

