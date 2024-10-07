--screjecutado2
---# 1 Insert variables de monto minimo para COD multipaís ConfigParams

INSERT [dbo].[ConfigParams] ([Name], [Description], [Value], [Status], [CreateDate], [IdCountry], [IdCurrencyCOD])
VALUES (N'MinCODCommissionAmount', N'Monto de comision de COD minimo a descontar', N'12.14', 1, CAST(N'2024-07-17T22:47:22.007' AS DateTime), N'HN', NULL)



UPDATE [dbo].[ConfigParams]
SET IdCountry='GT'
where [Name]='MinCODCommissionAmount' AND [Value]='3.8'


INSERT [dbo].[ConfigParams] ([Name], [Description], [Value], [Status], [CreateDate], [IdCountry], [IdCurrencyCOD])
VALUES (N'MaximumCODAmount', N'Monto maximo de COD permitido en la generación de una guía', N'16000', 1, getdate(), N'HN', NULL)

UPDATE [dbo].[ConfigParams]
SET IdCountry='GT'
where [Name]='MaximumCODAmount' and IdCountry is NULL