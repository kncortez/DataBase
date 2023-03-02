ALTER TABLE [DeliveryBackOffice].[dbo].[MembershipUsageByAffiliate]
ADD RegisterUserId BIGINT NOT NULL

ALTER TABLE [DeliveryBackOffice].[dbo].[MembershipUsageByAffiliate]
ADD CONSTRAINT FK_MembershipUsageByAffiliate_RegisterUser FOREIGN KEY (RegisterUserId) REFERENCES RegisterUser (UsrIdUser)

EXECUTE sp_addextendedproperty N'MS_Description', 'Identificador del usuario que registro el uso de la tabla RegisterUser', N'SCHEMA', N'dbo', N'TABLE', N'MembershipUsageByAffiliate', N'COLUMN', N'RegisterUserId'
GO