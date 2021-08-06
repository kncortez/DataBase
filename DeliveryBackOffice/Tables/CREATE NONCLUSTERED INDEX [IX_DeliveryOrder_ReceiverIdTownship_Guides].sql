/*
Missing Index Details from ROLLBACK - ALTER PROCEDURE [dbo].[sps_set_status_order_by_guide_linehauls].sql - 192.168.31.57.DeliveryBackOffice (mjimenez (68))
The Query Processor estimates that implementing the following index could improve the query cost by 99.5666%.
*/


USE [DeliveryBackOffice]
GO
CREATE NONCLUSTERED INDEX [IX_DeliveryOrder_ReceiverIdTownship_Guides]
ON [dbo].[DeliveryOrder] ([ReceiverIdTownship])
INCLUDE ([Guide_Serie],[Guide_Number])
GO

