CREATE TABLE [dbo].[CatMembershipAttribute] (
    [IdCatMembershipAttribute]           INT            IDENTITY (1, 1) NOT NULL,
    [CatMembershipId]                    INT            NOT NULL,
    [CatAttributeId]                     INT            NOT NULL,
    [MembershipAttributeValue]           NVARCHAR (50)  NOT NULL,
    [MembershipAttributeDescription]     NVARCHAR (300) NULL,
    [MembershipAttributePosition]        INT            NOT NULL,
    [RowStatus]                          BIT            CONSTRAINT [DF_CatMembershipAttribute_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]                       NVARCHAR (50)  NOT NULL,
    [DateCreated]                        DATETIME       NOT NULL,
    [TokenUpdated]                       NVARCHAR (50)  NULL,
    [DateUpdated]                        DATETIME       NULL,
    [MembershipAttributeDescriptionLong] NVARCHAR (500) NULL,
    CONSTRAINT [PK_CatMembershipAttribute] PRIMARY KEY CLUSTERED ([IdCatMembershipAttribute] ASC),
    CONSTRAINT [FK_CatMembershipAttribute_CatAttribute] FOREIGN KEY ([CatAttributeId]) REFERENCES [dbo].[CatAttribute] ([IdCatAttribute]),
    CONSTRAINT [FK_CatMembershipAttribute_CatMembership] FOREIGN KEY ([CatMembershipId]) REFERENCES [dbo].[CatMembership] ([IdCatMembership])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción larga de membresía ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatMembershipAttribute', @level2type = N'COLUMN', @level2name = N'MembershipAttributeDescriptionLong';

