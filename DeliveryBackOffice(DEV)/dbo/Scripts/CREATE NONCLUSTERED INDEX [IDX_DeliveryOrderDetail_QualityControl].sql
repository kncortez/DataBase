
CREATE NONCLUSTERED INDEX [IDX_DeliveryOrderDetail_QualityControl] 
	ON [dbo].[DeliveryOrderDetail]
(
	[Guide_Serie] ASC,
	[Guide_Number] ASC,
	[StatusOrderId] ASC,
	[DateCreatedInSystem] ASC,
	[SystemOrigin] ASC
)


