USE [DeliveryBackOffice]
GO
CREATE NONCLUSTERED INDEX [IDX_RusIdUser_RusRowStatus_INCLUDE]
ON [dbo].[RolByUserBySystem] ([RusIdUser],[RusRowStatus])
INCLUDE ([RusIdRol],[StationId])
GO