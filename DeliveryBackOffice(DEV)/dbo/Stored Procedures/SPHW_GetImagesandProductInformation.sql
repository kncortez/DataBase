
/* =================================================
   SP: SPHW_GetImagesandProductInformation
   Propósito: Carga de imágenes e información de un producto
              con manejo de moneda multipais
   Historia:  
   Fecha:    2023-11-30
================================================= */
/* === CHANGELOG ============================
2026-03-19 | Historia/épica: FDAPI-5847   | Autor: Pedro Macajol  | Corrección CASE moneda por JOIN dinámico multipais
2024-07-25 | Historia/épica: (pendiente)  | Autor: Cristian Suazo | Se agrega moneda correspondiente al país
2023-11-30 | Historia/épica: (pendiente)  | Autor: Edelman        | Creación inicial
=========================================== */

CREATE PROCEDURE [dbo].[SPHW_GetImagesandProductInformation]
    @IdCatProduct   INT,
    @ProductName    NVARCHAR(300)
AS
BEGIN

    -- Verificar si hay contenido
    IF (EXISTS(
        Select Top 1 1
        From [dbo].[CatSubscription] CP WITH (NOLOCK)
        WHERE CP.[IdCatSubscription] = @IdCatProduct AND CP.RowStatus = 1)
        OR
        EXISTS(
        Select Top 1 1
        From [dbo].[CatMembership] CP WITH (NOLOCK)
        WHERE CP.[IdCatMembership] = @IdCatProduct AND CP.RowStatus = 1)
    )
    BEGIN
        SELECT 200 [StatusCode], 'Proceso Exitoso' [Description]
    END
    ELSE
    BEGIN
        SELECT 201 [StatusCode], 'Sin Registros' [Description]
    END

    -- Tabla 1: Información del producto
    Select
        CP.IdCatSubscription        [IdCatProduct],
        CP.SubscriptionName         [CatProductName],
        CP.SubscriptionDescription  [CatProductDescription],
        CP.SubscriptionCost         [CatProductCost],
        ccc.Symbol                  AS CurrencySymbol,
        CP.SubscriptionFixedValue   [CatProductDiscountValue],
        CP.[CatProductCategoryId],
        CP.Tag,
        CAST(CP.SubscriptionValidity AS nvarchar) +' '+ 'Meses' [Validity]
    From DBO.[CatSubscription] CP WITH(NOLOCK)
    LEFT JOIN DeliveryCurrency dc WITH(NOLOCK)
        ON dc.Currency_IdCountry = CP.IdCountry
        AND dc.DefaultPerCountry = 1
    LEFT JOIN CatCurrencyCOD ccc WITH(NOLOCK)
        ON ccc.IdCatCurrencyCOD = dc.IdCurrencyCOD
    WHERE CP.IdCatSubscription = @IdCatProduct
    AND CP.RowStatus = 1
    AND CP.SubscriptionName = @ProductName
    UNION ALL
    Select
        CP.IdCatMembership          [IdCatProduct],
        CP.MembershipName           [CatProductName],
        CP.MembershipDescription    [CatProductDescription],
        CP.MembershipCost           [CatProductCost],
        ccc.Symbol                  AS CurrencySymbol,
        CP.MembershipFixedValue     [CatProductDiscountValue],
        CP.[CatProductCategoryId],
        CP.Tag,
        CAST(CP.MembershipValidity AS nvarchar) +' '+ 'Meses' [Validity]
    From [dbo].[CatMembership] CP WITH(NOLOCK)
    LEFT JOIN DeliveryCurrency dc WITH(NOLOCK)
        ON dc.Currency_IdCountry = CP.IdCountry
        AND dc.DefaultPerCountry = 1
    LEFT JOIN CatCurrencyCOD ccc WITH(NOLOCK)
        ON ccc.IdCatCurrencyCOD = dc.IdCurrencyCOD
    WHERE CP.IdCatMembership = @IdCatProduct
    AND CP.RowStatus = 1
    AND CP.MembershipName = @ProductName

    -- Tabla 2: Imágenes 
    SELECT
        CPI.[CatProductImageSmallImageURL],
        CPI.[CatProductImageLargeImageURL],
        ISNULL(CPI.CatSubscriptionId, CPI.CatMembershipId) [CatProductId],
        CPI.[CatProductImageBigImageURL]
    FROM DeliveryBackOffice.dbo.CatProductImage CPI WITH(NOLOCK)
    LEFT JOIN DeliveryBackOffice.dbo.CatSubscription CS WITH(NOLOCK)
        ON CS.IdCatSubscription = CPI.CatSubscriptionId
    WHERE CPI.RowStatus = 1
    AND CS.SubscriptionName = @ProductName
    AND CS.IdCatSubscription = @IdCatProduct
    UNION ALL
    SELECT
        CPI.[CatProductImageSmallImageURL],
        CPI.[CatProductImageLargeImageURL],
        ISNULL(CPI.CatSubscriptionId, CPI.CatMembershipId) [CatProductId],
        CPI.[CatProductImageBigImageURL]
    FROM DeliveryBackOffice.dbo.CatProductImage CPI WITH(NOLOCK)
    LEFT JOIN DeliveryBackOffice.dbo.CatMembership CM WITH(NOLOCK)
        ON CPI.CatMembershipId = CM.IdCatMembership
    WHERE CPI.RowStatus = 1
    AND CM.MembershipName = @ProductName
    AND CM.IdCatMembership = @IdCatProduct

    -- Tabla 3: Atributos
    Select
        CPA.SubscriptionAttributeDescription                    [CatProductAttributeDescription],
        ISNULL(CPA.SubscriptionAttributeDescriptionLong, 'N/D') [CatProductAttributeDescriptionLong],
        CPA.CatSubscriptionAttributeIcon                        [CatProductAttributeIcon],
        CPA.SubscriptionAttributePosition                       [CatProductAtributeOrder],
        CPA.CatSubscriptionId                                   [CatProductId]
    From [dbo].[CatSubscriptionAtribute] CPA WITH(NOLOCK)
    LEFT JOIN [dbo].[CatSubscription] CS WITH(NOLOCK)
        ON CPA.CatSubscriptionId = CS.IdCatSubscription
    WHERE CPA.CatSubscriptionId = @IdCatProduct
    AND CPA.RowStatus = 1
    AND CS.SubscriptionName = @ProductName
    UNION ALL
    Select
        CPA.MembershipAttributeDescription                      [CatProductAttributeDescription],
        ISNULL(CPA.MembershipAttributeDescriptionLong, 'N/D')   [CatProductAttributeDescriptionLong],
        CPA.CatMembershipAttributeIcon                          [CatProductAttributeIcon],
        CPA.MembershipAttributePosition                         [CatProductAtributeOrder],
        CPA.CatMembershipId                                     [CatProductId]
    From [dbo].[CatMembershipAttribute] CPA WITH(NOLOCK)
    LEFT JOIN [dbo].[CatMembership] CS WITH(NOLOCK)
        ON CPA.CatMembershipId = CS.IdCatMembership
    WHERE CPA.CatMembershipId = @IdCatProduct
    AND CPA.RowStatus = 1
    AND CS.MembershipName = @ProductName
    ORDER BY CPA.SubscriptionAttributePosition ASC

    -- Tabla 4: Descripciones
    Select
        CPD.Title               [CatProductDescriptionTitle],
        CPD.[Description]       [CatProductDescription],
        CPD.Position            [CatProductDescriptionOrder],
        CPD.CatSubscriptionId   [CatProductId]
    From CatSubscriptionDescription CPD WITH(NOLOCK)
    INNER JOIN CatSubscription CS WITH(NOLOCK)
        ON CPD.CatSubscriptionId = CS.IdCatSubscription
    Where CPD.CatSubscriptionId = @IdCatProduct
    AND CPD.RowStatus = 1
    AND CS.SubscriptionName = @ProductName
    UNION ALL
    Select
        CPD.Title                       [CatProductDescriptionTitle],
        CPD.[Description]               [CatProductDescription],
        CPD.Position                    [CatProductDescriptionOrder],
        CPD.IdCatMembershipDescription  [CatProductId]
    From CatMembershipDescription CPD WITH(NOLOCK)
    INNER JOIN CatMembership CM WITH(NOLOCK)
        ON CPD.CatMembershipId = CM.IdCatMembership
    Where CPD.CatMembershipId = @IdCatProduct
    AND CPD.RowStatus = 1
    AND CM.MembershipName = CM.MembershipName

END