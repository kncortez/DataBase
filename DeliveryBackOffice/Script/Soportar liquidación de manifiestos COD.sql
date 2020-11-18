ALTER TABLE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] ADD Settlement_Collect_OnDelivery DECIMAL(14,2) NULL
ALTER TABLE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] ADD Guide_Settlement BIT NULL
ALTER TABLE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] ADD Guide_Discharged BIT NULL
ALTER TABLE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] ADD SettlementCollect_TokenCreated [nvarchar](50) NULL
ALTER TABLE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] ADD SettlementCollect_DateCreated [datetime] NULL
ALTER TABLE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] ADD GuideDischarged_TokenCreated [nvarchar](50) NULL
ALTER TABLE [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] ADD GuideDischarged_DateCreated [datetime] NULL