--screjecutado2
---# 1 Insert variables de monto minimo para COD multipaís ConfigParams

INSERT [dbo].[ConfigParams] ([Name], [Description], [Value], [Status], [CreateDate], [IdCountry], [IdCurrencyCOD])
VALUES (N'MinCODCommissionAmount', N'Monto de comision de COD minimo a descontar', N'12.14', 1, CAST(N'2024-07-17T22:47:22.007' AS DateTime), N'HN', NULL)



UPDATE [dbo].[ConfigParams]
SET IdCountry='GT'
where [Name]='MinCODCommissionAmount' AND [Value]='3.8'
