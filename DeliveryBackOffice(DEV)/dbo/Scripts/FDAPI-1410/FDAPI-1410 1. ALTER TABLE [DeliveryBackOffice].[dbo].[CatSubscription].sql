USE [DeliveryBackOffice];
GO

ALTER TABLE [DeliveryBackOffice].[dbo].[CatSubscription]
ADD IncludedMembershipId INT NULL

ALTER TABLE [DeliveryBackOffice].[dbo].[CatSubscription]
ADD CONSTRAINT FK_CatSubscription_CatMembership FOREIGN KEY (IncludedMembershipId) REFERENCES CatMembership(IdCatMembership)

EXECUTE sp_addextendedproperty N'MS_Description', N'Indicativo si suscripción contiene una membresía incluida y cual membresía es de la tabla CatMembership', N'SCHEMA', N'dbo', N'TABLE', N'CatSubscription', N'COLUMN', N'IncludedMembershipId'
GO