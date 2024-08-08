---# 1 Insert variables de monto minimo para COD multipaís ConfigParams

INSERT [dbo].[ConfigParams] ([ConfigParamsId], [Name], [Description], [Value], [Status], [CreateDate], [IdCountry], [IdCurrencyCOD])
VALUES (79, N'MinCODCommissionAmount', N'Monto de comision de COD minimo a descontar', N'12.14', 1, CAST(N'2024-07-17T22:47:22.007' AS DateTime), N'HN', NULL)

INSERT [dbo].[ConfigParams] ([ConfigParamsId], [Name], [Description], [Value], [Status], [CreateDate], [IdCountry], [IdCurrencyCOD])
VALUES (53, N'MinCODCommissionAmount', N'Monto de comision de COD minimo a descontar', N'3.8', 1, CAST(N'2023-12-17T22:47:22.007' AS DateTime), N'GT', NULL)