/*  Nuevas Suscripciones */
  -- PAQUETE MICRO
  -- PAQUETE FLEXI
INSERT [dbo].[CatSubscription] ( [SubscriptionName], [SubscriptionDescription], [SubscriptionCost], [SubscriptionFixedValue], [SubscriptionMaxServiceFixedValue], [SubscriptionValidity], [SubscriptionWeight], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [Icon], [NextSalesPackageBanner], [RateHeaderId], [AlternativeRateHeaderId], [IncludedMembershipId], [CatTypeSubscriptionId], [CatProductCategoryId], [Tag], [Position], [IdCountry], [IdCatCurrencyCOD]) VALUES ( N'Paquete MICRO', N'15 envíos Q36.00 c/u', CAST(540.00 AS Decimal(18, 2)), 0, 15, 6, 5, 1, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL, N'hwa-planMicroIcon', N'bannerSubsPlan4.png', NULL, NULL, NULL, 2, 2, N'NOVEDADES', 1, N'GT', 1)



INSERT [dbo].[CatSubscription] ( [SubscriptionName], [SubscriptionDescription], [SubscriptionCost], [SubscriptionFixedValue], [SubscriptionMaxServiceFixedValue], [SubscriptionValidity], [SubscriptionWeight], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [Icon], [NextSalesPackageBanner], [RateHeaderId], [AlternativeRateHeaderId], [IncludedMembershipId], [CatTypeSubscriptionId], [CatProductCategoryId], [Tag], [Position], [IdCountry], [IdCatCurrencyCOD]) VALUES ( N'Paquete FLEXI', N'300 envíos Q26.00 c/u', CAST(7800.00 AS Decimal(18, 2)), 0, 300, 6, 5, 1, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL, N'hwa-planFlexiIcon', N'bannerSubsPlan4.png', NULL, NULL, NULL, 2, 2, N'NOVEDADES', 1, N'GT', 1)


/*  Nuevas Etiqueta por producto */
DECLARE @IdCatSubscriptionMICRO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete MICRO')
DECLARE @IdCatSubscriptionFLEXI INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete FLEXI')


INSERT [dbo].[MarketplaceTagsByProduct] ( [MarketplaceProductTagsId], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [CatSubscriptionId], [CatMembershipId], [Position]) VALUES (2, 1, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL, @IdCatSubscriptionMICRO, NULL, 6)

INSERT [dbo].[MarketplaceTagsByProduct] ([MarketplaceProductTagsId], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [CatSubscriptionId], [CatMembershipId], [Position]) VALUES (2, 1, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL, @IdCatSubscriptionFLEXI, NULL, 6)

INSERT [dbo].[MarketplaceTagsByProduct] ( [MarketplaceProductTagsId], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [CatSubscriptionId], [CatMembershipId], [Position]) VALUES (4, 1, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL, @IdCatSubscriptionMICRO, NULL, 2)

INSERT [dbo].[MarketplaceTagsByProduct] ([MarketplaceProductTagsId], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [CatSubscriptionId], [CatMembershipId], [Position]) VALUES (4, 1, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL, @IdCatSubscriptionFLEXI, NULL, 3)


/*Agregar imagenes*/

INSERT [dbo].[CatProductImage] ( [CatProductImageSmallImageURL], [CatProductImageLargeImageURL], [CatProductImageOrder], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [CatSubscriptionId], [CatMembershipId], [CatProductImageBigImageURL], [CatProductImageXXXLImageURL]) VALUES ( N'https://www.forzadelivery.com/images/Miniatura/micro-500-347.jpg', N'https://www.forzadelivery.com/images/Miniatura/micro-1200-722.jpg', 9, 1, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL, @IdCatSubscriptionMICRO, NULL, N'https://www.forzadelivery.com/images/Miniatura/micro-2103-521.jpg', NULL)

INSERT [dbo].[CatProductImage] ( [CatProductImageSmallImageURL], [CatProductImageLargeImageURL], [CatProductImageOrder], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [CatSubscriptionId], [CatMembershipId], [CatProductImageBigImageURL], [CatProductImageXXXLImageURL]) VALUES ( N'https://www.forzadelivery.com/images/Miniatura/flexi-500-347.jpg', N'https://www.forzadelivery.com/images/Miniatura/flexi-1200-722.jpg', 10, 1, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL, @IdCatSubscriptionFLEXI, NULL, N'https://www.forzadelivery.com/images/Miniatura/flexi-2103-521.jpg', NULL)

/*Agregar Atributos*/


INSERT [dbo].[CatSubscriptionAtribute] ( [CatSubscriptionId], [CatAttributeId], [SubscriptionAttributeValue], [SubscriptionAttributeDescription], [SubscriptionAttributePosition], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [SubscriptionAttributeDescriptionLong], [CatSubscriptionAttributeIcon]) VALUES ( @IdCatSubscriptionMICRO, 1, N'1', N'Vigencia de 6 meses.', 6, 0, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL, N'Vigencia de 6 meses.', N'fa fa-check-circle fa-2x')

INSERT [dbo].[CatSubscriptionAtribute] ( [CatSubscriptionId], [CatAttributeId], [SubscriptionAttributeValue], [SubscriptionAttributeDescription], [SubscriptionAttributePosition], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [SubscriptionAttributeDescriptionLong], [CatSubscriptionAttributeIcon]) VALUES ( @IdCatSubscriptionFLEXI, 1, N'1', N'Vigencia de 6 meses.', 6, 0, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL, N'Vigencia de 6 meses.', N'fa fa-check-circle fa-2x')

INSERT [dbo].[CatSubscriptionAtribute] ([CatSubscriptionId], [CatAttributeId], [SubscriptionAttributeValue], [SubscriptionAttributeDescription], [SubscriptionAttributePosition], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [SubscriptionAttributeDescriptionLong], [CatSubscriptionAttributeIcon]) VALUES ( @IdCatSubscriptionMICRO, 1, N'1', N'15 guías a Q36 c/u.', 1, 1, N'SYS-EVASQUEZ',  GETDATE(), NULL, NULL, N'15 guías a Q36 c/u.', N'fa fa-check-circle fa-2x')

INSERT [dbo].[CatSubscriptionAtribute] ( [CatSubscriptionId], [CatAttributeId], [SubscriptionAttributeValue], [SubscriptionAttributeDescription], [SubscriptionAttributePosition], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [SubscriptionAttributeDescriptionLong], [CatSubscriptionAttributeIcon]) VALUES ( @IdCatSubscriptionFLEXI, 1, N'1', N'300 guías a Q26 c/u.', 1, 1, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL, N'300 guías a Q26 c/u.', N'fa fa-check-circle fa-2x')

INSERT [dbo].[CatSubscriptionAtribute] ([CatSubscriptionId], [CatAttributeId], [SubscriptionAttributeValue], [SubscriptionAttributeDescription], [SubscriptionAttributePosition], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [SubscriptionAttributeDescriptionLong], [CatSubscriptionAttributeIcon]) VALUES (@IdCatSubscriptionMICRO, 1, N'1', N'Tarifa única en todo el país.', 2, 1, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL, N'Tarifa única en todo el país.', N'fa fa-map fa-2x')

INSERT [dbo].[CatSubscriptionAtribute] ( [CatSubscriptionId], [CatAttributeId], [SubscriptionAttributeValue], [SubscriptionAttributeDescription], [SubscriptionAttributePosition], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [SubscriptionAttributeDescriptionLong], [CatSubscriptionAttributeIcon]) VALUES ( @IdCatSubscriptionFLEXI, 1, N'1', N'Tarifa única en todo el país.', 2, 1, N'SYS-AIXCHOP', GETDATE(), NULL, NULL, N'Tarifa única en todo el país.', N'fa fa-map fa-2x')

INSERT [dbo].[CatSubscriptionAtribute] ( [CatSubscriptionId], [CatAttributeId], [SubscriptionAttributeValue], [SubscriptionAttributeDescription], [SubscriptionAttributePosition], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [SubscriptionAttributeDescriptionLong], [CatSubscriptionAttributeIcon]) VALUES ( @IdCatSubscriptionMICRO, 1, N'1', N'Costo único para todos tus clientes.', 3, 1, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL, N'Costo único para todos tus clientes.', N'bi bi-cash fa-2x')

INSERT [dbo].[CatSubscriptionAtribute] ([CatSubscriptionId], [CatAttributeId], [SubscriptionAttributeValue], [SubscriptionAttributeDescription], [SubscriptionAttributePosition], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [SubscriptionAttributeDescriptionLong], [CatSubscriptionAttributeIcon]) VALUES ( @IdCatSubscriptionFLEXI, 1, N'1', N'Costo único para todos tus clientes.', 3, 1, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL, N'Costo único para todos tus clientes.', N'bi bi-cash fa-2x')

INSERT [dbo].[CatSubscriptionAtribute] ( [CatSubscriptionId], [CatAttributeId], [SubscriptionAttributeValue], [SubscriptionAttributeDescription], [SubscriptionAttributePosition], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [SubscriptionAttributeDescriptionLong], [CatSubscriptionAttributeIcon]) VALUES ( @IdCatSubscriptionMICRO, 1, N'1', N'Hasta 10 Libras.', 4, 1, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL, N'Hasta 10 Libras.', N'fa fa-archive fa-2x')

INSERT [dbo].[CatSubscriptionAtribute] ( [CatSubscriptionId], [CatAttributeId], [SubscriptionAttributeValue], [SubscriptionAttributeDescription], [SubscriptionAttributePosition], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated], [SubscriptionAttributeDescriptionLong], [CatSubscriptionAttributeIcon]) VALUES ( @IdCatSubscriptionFLEXI, 1, N'1', N'Hasta 10 Libras.', 4, 1, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL, N'Hasta 10 Libras.', N'fa fa-archive fa-2x')


/*Agregar Descripciones*/

INSERT [dbo].[CatSubscriptionDescription] ( [Title], [Description], [Position], [Type], [CatSubscriptionId], [RowStatus], [DateCreated], [TokenCreated], [DateUpdated], [TokenUpdated]) VALUES ( N'¿Qué es?', N'Nuestro paquete te ofrece 15 guías de envío prepagadas con Tarifa única a
todo el país, lo que significa que puedes enviar tus productos a cualquier
destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra
tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías
prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes
una gran cantidad de envíos de manera continua? Estas guías son ideales
para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una
tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos
sean más rentables y eficientes hoy mismo!', 1, N'PAQUETE PRO', @IdCatSubscriptionMICRO, 1, GETDATE(), N'SYS-EVASQUEZ', NULL, NULL)

INSERT [dbo].[CatSubscriptionDescription] ( [Title], [Description], [Position], [Type], [CatSubscriptionId], [RowStatus], [DateCreated], [TokenCreated], [DateUpdated], [TokenUpdated]) VALUES ( N'¿Cómo Funciona?', N'Compra en la tienda virtual y recibe las guías en tu correo electrónico.
Prepara tus paquetes, completa la información de envío y entrégalos en las
+90 agencias express center o puedes solicitar la recolección a tu casa u
oficina. Rastrea el progreso del envío con el número de guía proporcionado
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de
los detalles logísticos. Adquiere tu Paquete Micro y podrás obtener tus
guías prepagadas de 15 envíos con tarifa única a todo el país a Q36.00
c/u.', 2, N'PAQUETE PRO', @IdCatSubscriptionMICRO, 1, GETDATE(), N'SYS-EVASQUEZ', NULL, NULL)


INSERT [dbo].[CatSubscriptionDescription] ( [Title], [Description], [Position], [Type], [CatSubscriptionId], [RowStatus], [DateCreated], [TokenCreated], [DateUpdated], [TokenUpdated]) VALUES ( N'Aplican restricciones', N'En caso de que tu envío exceda el peso, +Q1.00 por libra adicional, consulta los términos y condiciones.', 3, N'PAQUETE PRO', @IdCatSubscriptionMICRO, 1, GETDATE(), N'SYS-EVASQUEZ', NULL, NULL)




INSERT [dbo].[CatSubscriptionDescription] ( [Title], [Description], [Position], [Type], [CatSubscriptionId], [RowStatus], [DateCreated], [TokenCreated], [DateUpdated], [TokenUpdated]) VALUES ( N'¿Qué es?', N'Nuestro paquete te ofrece 300 guías de envío prepagadas con Tarifa única
a todo el país, lo que significa que puedes enviar tus productos a cualquier
destino sin preocuparte por tarifas variables. Pero eso no es todo, ¡nuestra
tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías
prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes
una gran cantidad de envíos de manera continua? Estas guías son ideales
para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una
tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos
sean más rentables y eficientes hoy mismo!', 1, N'PAQUETE PRO', @IdCatSubscriptionFLEXI, 1, GETDATE(), N'SYS-EVASQUEZ', NULL, NULL)

INSERT [dbo].[CatSubscriptionDescription] ( [Title], [Description], [Position], [Type], [CatSubscriptionId], [RowStatus], [DateCreated], [TokenCreated], [DateUpdated], [TokenUpdated]) VALUES ( N'¿Cómo Funciona?', N'Compra en la tienda virtual y recibe las guías en tu correo electrónico.
Prepara tus paquetes, completa la información de envío y entrégalos en las
+90 agencias express center o puedes solicitar la recolección a tu casa u
oficina. Rastrea el progreso del envío con el número de guía proporcionado
para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al
centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de
los detalles logísticos. Adquiere tu Paquete Flexi y podrás obtener tus
guías prepagadas de 300 envíos con tarifa única a todo el país a Q26.00
c/u.', 2, N'PAQUETE PRO', @IdCatSubscriptionFLEXI, 1, GETDATE(), N'SYS-EVASQUEZ', NULL, NULL)

INSERT [dbo].[CatSubscriptionDescription] ( [Title], [Description], [Position], [Type], [CatSubscriptionId], [RowStatus], [DateCreated], [TokenCreated], [DateUpdated], [TokenUpdated]) VALUES ( N'Aplican restricciones', N'En caso de que tu envío exceda el peso, +Q1.00 por libra adicional, consulta los términos y condiciones.', 3, N'PAQUETE PRO', @IdCatSubscriptionFLEXI, 1, GETDATE(), N'SYS-EVASQUEZ', NULL, NULL)




INSERT [dbo].[CatSubscriptionDiscountRange] ( [CatSubscriptionId], [DiscountLowServiceRange], [DiscountTopServiceRange], [ValueTypeId], [DiscountValue], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated])
 VALUES ( @IdCatSubscriptionMICRO, 15, NULL, 1, CAST(0.00 AS Decimal(5, 2)), 1, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL)

INSERT [dbo].[CatSubscriptionDiscountRange] ( [CatSubscriptionId], [DiscountLowServiceRange], [DiscountTopServiceRange], [ValueTypeId], [DiscountValue], [RowStatus], [TokenCreated], [DateCreated], [TokenUpdated], [DateUpdated]) 
VALUES ( @IdCatSubscriptionFLEXI, 300, NULL, 1, CAST(0.00 AS Decimal(5, 2)), 1, N'SYS-EVASQUEZ', GETDATE(), NULL, NULL)
