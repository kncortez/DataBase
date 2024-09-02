INSERT INTO [dbo].[ConfigParams] ([Name], [Description], [Value], [Status], [CreateDate], [IdCountry], [IdCurrencyCOD])
     VALUES
           ('DiscountAmuountByCountry'
           ,'Descuento por envio para entregar en tienda en Guatemala'
           ,5.00
           ,1
           ,GETDATE()
           ,'GT'
           ,NULL)
GO
INSERT INTO [dbo].[ConfigParams] ([Name], [Description], [Value], [Status], [CreateDate], [IdCountry], [IdCurrencyCOD])
     VALUES
           ('DiscountAmuountByCountry'
           ,'Descuento por envio para entregar en tienda en Honduras'
           ,15.00
           ,1
           ,GETDATE()
           ,'HN'
           ,NULL)
GO
