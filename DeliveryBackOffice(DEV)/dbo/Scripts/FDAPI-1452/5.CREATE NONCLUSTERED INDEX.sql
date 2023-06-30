USE [DeliveryBackOffice]
GO

CREATE NONCLUSTERED INDEX [IDX_BatchDetailCOD_GetInvoicePaymentCommissionCOD] ON [dbo].[BatchDetailCOD]([CatConceptCODiD],[RowStatus],[Commission])
INCLUDE ([GuideSerie], [GuideNumber], [CreditDate], [Amount])

CREATE NONCLUSTERED INDEX [IDX_BillingProfile_GetInvoicePaymentCommissionCOD] ON [BillingProfile] ([BlpIdAccount], [BlpRowStatus])
INCLUDE ([BlpName], [BlpAddress], [BlpTaxId], [IsDefault])