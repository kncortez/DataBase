/* =================================================
   SP: GetProductsByCategory
   Propósito: Obtener productos por categoría 
   Historia:  
   Fecha:     
================================================= */
/* === CHANGELOG ============================
2026-03-19  | Historia/épica: FDAPI-5843   | Autor: Pedro Macajol  | Se agrega filtro por país @IdCountry y manejo de moneda multipais
(pendiente) | Historia/épica: (pendiente)  | Autor: Cristian Suazo | Se agrega moneda correspondiente
(pendiente) | Historia/épica: (pendiente)  | Autor: Edelman        | Modificación para incorporar estructura club forza
(pendiente) | Historia/épica: (pendiente)  | Autor: Bidcar Herrera | Creación inicial
=========================================== */
CREATE PROCEDURE [dbo].[GetProductsByCategory] 
    @IdCategory INT
AS
BEGIN
    SELECT           
        CS.[IdCatSubscription]       [IdCatProduct],
        CS.[SubscriptionName]        [CatProductName],
        CS.[SubscriptionCost]        [CatProductCost],
        ccc.Symbol                   [CurrencySymbol],  
        CS.[SubscriptionDescription] [CatProductDescription],
        CS.[CatProductCategoryId]    [CatProductCategoryId],
        CS.Tag,
        CS.Position
    FROM [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH (NOLOCK)
    LEFT JOIN DeliveryCurrency dc WITH(NOLOCK)
        ON dc.Currency_IdCountry = CS.IdCountry  
        AND dc.DefaultPerCountry = 1
    LEFT JOIN CatCurrencyCOD ccc WITH(NOLOCK)
        ON ccc.IdCatCurrencyCOD = dc.IdCurrencyCOD
    WHERE CS.RowStatus = 1
    AND CS.CatProductCategoryId = @IdCategory
    UNION ALL
    SELECT  
        CS.[IdCatMembership]         [IdCatProduct],
        CS.[MembershipName]          [CatProductName],
        CS.[MembershipCost]          [CatProductCost],
        ccc.Symbol                   [CurrencySymbol], 
        CS.[MembershipDescription]   [CatProductDescription],
        CS.[CatProductCategoryId]    [CatProductCategoryId],
        CS.Tag,
        CS.Position
    FROM [DeliveryBackOffice].[dbo].[CatMembership] CS WITH (NOLOCK)
    LEFT JOIN DeliveryCurrency dc WITH(NOLOCK)
        ON dc.Currency_IdCountry = CS.IdCountry
        AND dc.DefaultPerCountry = 1
    LEFT JOIN CatCurrencyCOD ccc WITH(NOLOCK)
        ON ccc.IdCatCurrencyCOD = dc.IdCurrencyCOD
    WHERE CS.RowStatus = 1
    AND CS.CatProductCategoryId = @IdCategory
    ORDER BY CS.Position ASC

    SELECT 
        CPI.[IdCatProductImage],
        CPI.CatSubscriptionId        [CatProductId],
        CPI.[CatProductImageSmallImageURL],
        CPI.[CatProductImageLargeImageURL],
        CPI.[CatProductImageOrder]
    FROM DeliveryBackOffice.dbo.CatProductImage CPI
    INNER JOIN DeliveryBackOffice.dbo.CatSubscription A2
        ON CPI.CatSubscriptionId = A2.IdCatSubscription
    WHERE CPI.RowStatus = 1
    AND A2.CatProductCategoryId = @IdCategory
    UNION ALL
    SELECT 
        CPI.[IdCatProductImage],
        CPI.CatMembershipId          [CatProductId],
        CPI.[CatProductImageSmallImageURL],
        CPI.[CatProductImageLargeImageURL],
        CPI.[CatProductImageOrder]
    FROM DeliveryBackOffice.dbo.CatProductImage CPI
    INNER JOIN DeliveryBackOffice.dbo.CatMembership A2
        ON A2.IdCatMembership = CPI.CatMembershipId
    WHERE CPI.RowStatus = 1
    AND A2.CatProductCategoryId = @IdCategory
    AND A2.RowStatus = 1
END
GO