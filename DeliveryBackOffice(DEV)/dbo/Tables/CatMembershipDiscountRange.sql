CREATE TABLE [dbo].[CatMembershipDiscountRange] (
    [IdCatMembershipDiscountRange] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CatMembershipId]              INT            NOT NULL,
    [DiscountLowServiceRange]      INT            NOT NULL,
    [DiscountTopServiceRange]      INT            NULL,
    [ValueTypeId]                  INT            NOT NULL,
    [DiscountValue]                DECIMAL (5, 2) NOT NULL,
    [RowStatus]                    BIT            CONSTRAINT [DF_CatMembershipDiscountRange_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]                 NVARCHAR (50)  NOT NULL,
    [DateCreated]                  DATETIME       NOT NULL,
    [TokenUpdated]                 NVARCHAR (50)  NULL,
    [DateUpdated]                  DATETIME       NULL,
    CONSTRAINT [PK_CatMembershipDiscountRange] PRIMARY KEY CLUSTERED ([IdCatMembershipDiscountRange] ASC),
    CONSTRAINT [FK_CatMembershipDiscountRange_CatMembership] FOREIGN KEY ([CatMembershipId]) REFERENCES [dbo].[CatMembership] ([IdCatMembership]),
    CONSTRAINT [FK_CatMembershipDiscountRange_CatValueType] FOREIGN KEY ([ValueTypeId]) REFERENCES [dbo].[CatValueType] ([IdCatValueType])
);

