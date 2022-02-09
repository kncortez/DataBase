USE [DeliveryBackOffice]

ALTER TABLE [dbo].[SchedulePickup]
ADD SchedulePickupStatus BIT NULL;

ALTER TABLE [dbo].[SchedulePickup] ADD CONSTRAINT [df_SchedulePickup_SchedulePickup] DEFAULT 1 FOR SchedulePickupStatus;
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Estado SchedulePickup 1=Habilitado 0=Cancelado.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SchedulePickup', @level2type=N'COLUMN',@level2name=N'SchedulePickupStatus'
GO