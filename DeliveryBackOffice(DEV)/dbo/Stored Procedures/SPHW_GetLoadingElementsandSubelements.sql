
/* =================================================
   SP: SPHW_GetLoadingElementsandSubelements
   Propósito: Obtener elementos y subelementos del sitio marketplace
              con filtro por país y moneda
   Historia:  
   Fecha:     2023-08-27
================================================= */
/* === CHANGELOG ============================
2026-03-19 | Historia/épica: FDAPI-5847   | Autor: Pedro Macajol  | Corrección ISNULL por filtro directo IdCountry y moneda dinámica por país
2024-07-24 | Historia/épica: (pendiente)  | Autor: Cristian Suazo | Se agrega filtro de país para todas las consultas
2024-01-15 | Historia/épica: (pendiente)  | Autor: Edelman        | Campo tag para etiquetar productos
2024-01-10 | Historia/épica: (pendiente)  | Autor: Edelman        | Integrar estructura BD Club Forza con marketplace
2023-08-27 | Historia/épica: (pendiente)  | Autor: Edelman        | Creación inicial
=========================================== */

CREATE PROCEDURE [dbo].[SPHW_GetLoadingElementsandSubelements]
    @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN

    /***************************** DETERMINAR SI HAY CONTENIDO O NO **********************************/
    IF (EXISTS(
        Select Top 1 1
        From [DeliveryBackOffice].[dbo].[CatSubscription] CP WITH (NOLOCK)
        Left JOIN [DeliveryBackOffice].[dbo].[CatSubscriptionDescription] CPD WITH (NOLOCK)
            ON CP.IdCatSubscription = CPD.CatSubscriptionId
        Left JOIN [DeliveryBackOffice].[dbo].[CatSubscriptionAtribute] CPA WITH(NOLOCK)
            ON CPA.CatSubscriptionId = CPD.CatSubscriptionId
        Left JOIN [DeliveryBackOffice].[dbo].[MarketplaceTagsByProduct] MTP WITH (NOLOCK)
            ON CP.IdCatSubscription = MTP.CatSubscriptionId
        Left JOIN [DeliveryBackOffice].[dbo].[MarketplaceProductTags] MPT WITH (NOLOCK)
            ON MTP.MarketplaceProductTagsId = MPT.IdMarketplaceProductTags
        WHERE CP.RowStatus = 1
        AND CP.IdCountry = @IdCountry  
    ))
    BEGIN
        SELECT 200 [StatusCode], 'Proceso Exitoso' [Description]
    END
    ELSE
    BEGIN
        SELECT 201 [StatusCode], 'Sin Registros' [Description]
    END

    /********************************************************************************
     ************************** CATEGORIA DE PRODUCTOS ******************************
     ********************************************************************************/
    SELECT [IdCatProductCategory],
           [CatProductCategoryName],
           [CatProductCategoryDescription],
           [CatProductCategoryOrder]
    FROM [dbo].[CatProductCategory] WITH (NOLOCK)
    WHERE Rowstatus = 1
    AND IdCountry = @IdCountry 
    AND IdCatProductCategory IN (
        Select CP.[CatProductCategoryId]
        From [DeliveryBackOffice].[dbo].[CatSubscription] CP WITH (NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[MarketplaceTagsByProduct] MTP WITH (NOLOCK)
            ON CP.IdCatSubscription = MTP.CatSubscriptionId
        INNER JOIN [DeliveryBackOffice].[dbo].[MarketplaceProductTags] MPT WITH (NOLOCK)
            ON MTP.MarketplaceProductTagsId = MPT.IdMarketplaceProductTags
        WHERE CP.RowStatus = 1 
        AND CP.IdCountry = @IdCountry  
    )
    UNION ALL
    SELECT [IdCatProductCategory],
           [CatProductCategoryName],
           [CatProductCategoryDescription],
           [CatProductCategoryOrder]
    FROM [DeliveryBackOffice].[dbo].[CatProductCategory] WITH (NOLOCK)
    WHERE Rowstatus = 1
    AND IdCountry = @IdCountry 
    AND IdCatProductCategory IN (
        Select CP.[CatProductCategoryId]
        From [DeliveryBackOffice].[dbo].[CatMembership] CP WITH (NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[MarketplaceTagsByProduct] MTP WITH (NOLOCK)
            ON CP.IdCatMembership = MTP.CatMembershipId
        INNER JOIN [DeliveryBackOffice].[dbo].[MarketplaceProductTags] MPT WITH (NOLOCK)
            ON MTP.MarketplaceProductTagsId = MPT.IdMarketplaceProductTags
        WHERE CP.RowStatus = 1 
        AND CP.IdCountry = @IdCountry 
    )

    /********************************************************************************
     *********************** ENCABEZADOS ********************************************
     ********************************************************************************/
    SELECT 
        MPT.[MarketplaceProductTagsName],
        MPT.[MarketplaceProductTagsDescription],
        MPT.IdMarketplaceProductTags
    FROM DeliveryBackOffice.[dbo].[MarketplaceProductTags] MPT WITH (NOLOCK)
    WHERE MPT.Rowstatus = 1   AND MPT.IdCountry = @IdCountry

    /********************************************************************************
     ************************ CONTENIDO *********************************************
     ********************************************************************************/
    SELECT 
        MTP.Position        [CatPosition],
        CP.IdCatSubscription [IdCatProduct],
        CP.SubscriptionName  [CatProductName],
        CONVERT(DECIMAL(18,2), CP.[SubscriptionCost]) [CatProductCost],
        dc_ccc.Symbol        AS CurrencySymbol, 
        CP.SubscriptionDescription [CatProductDescription],
        MPT.[MarketplaceProductTagsName],
        MPT.[MarketplaceProductTagsDescription],
        CP.[CatProductCategoryId],
        CP.Tag
    FROM DeliveryBackOffice.[dbo].[MarketplaceProductTags] MPT WITH (NOLOCK)
    RIGHT JOIN DeliveryBackOffice.[dbo].[MarketplaceTagsByProduct] MTP WITH (NOLOCK)
        ON MPT.IdMarketplaceProductTags = MTP.MarketplaceProductTagsId
    INNER JOIN [dbo].[CatSubscription] CP WITH (NOLOCK)
        ON MTP.CatSubscriptionId = CP.IdCatSubscription
    LEFT JOIN DeliveryCurrency dc WITH(NOLOCK) 
        ON dc.Currency_IdCountry = CP.IdCountry
        AND dc.DefaultPerCountry = 1
    LEFT JOIN CatCurrencyCOD dc_ccc WITH(NOLOCK)
        ON dc_ccc.IdCatCurrencyCOD = dc.IdCurrencyCOD
    WHERE CP.RowStatus = 1 
    AND CP.IdCountry = @IdCountry 
    UNION ALL
    SELECT 
        MTP.Position        [CatPosition],
        CP.IdCatMembership   [IdCatProduct],
        CP.MembershipName    [CatProductName],
        CONVERT(DECIMAL(18,2), CP.[MembershipCost]) [CatProductCost],
        dc_ccc.Symbol        AS CurrencySymbol,  
        CP.MembershipDescription [CatProductDescription],
        MPT.[MarketplaceProductTagsName],
        MPT.[MarketplaceProductTagsDescription],
        CP.[CatProductCategoryId],
        CP.Tag
    FROM [DeliveryBackOffice].[dbo].[CatMembership] CP WITH (NOLOCK)
    INNER JOIN [DeliveryBackOffice].[dbo].[MarketplaceTagsByProduct] MTP WITH (NOLOCK)
        ON CP.IdCatMembership = MTP.CatMembershipId
    INNER JOIN [DeliveryBackOffice].[dbo].[MarketplaceProductTags] MPT WITH (NOLOCK)
        ON MTP.MarketplaceProductTagsId = MPT.IdMarketplaceProductTags
    LEFT JOIN DeliveryBackOffice.[dbo].[DeliveryCurrency] dc WITH(NOLOCK) 
        ON dc.Currency_IdCountry = CP.IdCountry
        AND dc.DefaultPerCountry = 1
    LEFT JOIN DeliveryBackOffice.[dbo].[CatCurrencyCOD] dc_ccc WITH(NOLOCK)
        ON dc_ccc.IdCatCurrencyCOD = dc.IdCurrencyCOD
    WHERE CP.RowStatus = 1 
    AND CP.IdCountry = @IdCountry  
    ORDER BY MTP.[Position] ASC

    /********************************************************************************
     **************************** IMAGENES ******************************************
     ********************************************************************************/
    SELECT 
        CPI.[IdCatProductImage],
        ISNULL(CPI.CatSubscriptionId, CPI.CatMembershipId) [CatProductId],
        CPI.[CatProductImageSmallImageURL],
        CPI.[CatProductImageLargeImageURL],
        CPI.CatProductImageBigImageURL,
        CPI.[CatProductImageOrder]
    FROM DeliveryBackOffice.[dbo].[CatProductImage] CPI WITH (NOLOCK)
    INNER JOIN DeliveryBackOffice.[dbo].[CatSubscription] CP WITH (NOLOCK)
        ON CPI.CatSubscriptionId = CP.IdCatSubscription
    WHERE CPI.RowStatus = 1 
    AND CP.IdCountry = @IdCountry  
    UNION ALL
    SELECT 
        CPI.[IdCatProductImage],
        ISNULL(CPI.CatSubscriptionId, CPI.CatMembershipId) [CatProductId],
        CPI.[CatProductImageSmallImageURL],
        CPI.[CatProductImageLargeImageURL],
        CPI.CatProductImageBigImageURL,
        CPI.[CatProductImageOrder]
    FROM DeliveryBackOffice.[dbo].[CatProductImage] CPI WITH (NOLOCK)
    INNER JOIN DeliveryBackOffice.[dbo].[CatMembership] CTS WITH (NOLOCK)
        ON CPI.CatMembershipId = CTS.IdCatMembership
    WHERE CPI.RowStatus = 1 
    AND CTS.IdCountry = @IdCountry  

    /********************************************************************************
     ************************* DESCRIPCION ******************************************
     ********************************************************************************/
    Select 
        CPD.[Description]       [CatProductDescription],
        CPD.Title               [CatProductDescriptionTitle],
        CPD.Position            [CatProductDescriptionOrder],
        CPD.CatSubscriptionId   [CatProductId]
    From DeliveryBackOffice.[dbo].[CatSubscription] CP WITH (NOLOCK)
    INNER JOIN DeliveryBackOffice.[dbo].[CatSubscriptionDescription] CPD WITH (NOLOCK)
        ON CPD.CatSubscriptionId = CP.IdCatSubscription
    Where CPD.RowStatus = 1 
    AND CP.IdCountry = @IdCountry 
    UNION ALL
    Select 
        CPD.[Description]       [CatProductDescription],
        CPD.Title               [CatProductDescriptionTitle],
        CPD.Position            [CatProductDescriptionOrder],
        CPD.CatMembershipId     [CatProductId]
    From DeliveryBackOffice.[dbo].[CatMembership] CP WITH (NOLOCK)
    INNER JOIN DeliveryBackOffice.[dbo].[CatMembershipDescription] CPD WITH (NOLOCK)
        ON CPD.CatMembershipId = CP.IdCatMembership
    Where CPD.RowStatus = 1 
    AND CP.IdCountry = @IdCountry  

    /********************************************************************************
     ************************ ATRIBUTOS *********************************************
     ********************************************************************************/
    Select 
        CPA.SubscriptionAttributeDescription       [CatProductAttributeDescription],
        CPA.SubscriptionAttributeDescriptionLong   [CatProductAttributeDescriptionLong],
        CPA.CatSubscriptionId                      [CatProductId],
        CPA.SubscriptionAttributePosition          [CatProductAtributeOrder],
        CS.Icon                                    [CatProductAttributeIcon]
    From DeliveryBackOffice.[dbo].[CatSubscription] CS WITH(NOLOCK)
    INNER JOIN DeliveryBackOffice.[dbo].[CatSubscriptionAttribute]  CPA WITH(NOLOCK)
        ON CPA.CatSubscriptionId = CS.IdCatSubscription
    Where CPA.RowStatus = 1 
    AND CS.RowStatus = 1 
    AND CS.IdCountry = @IdCountry 
    UNION ALL
    Select 
        CPA.MembershipAttributeDescription                     [CatProductAttributeDescription],
        ISNULL(CPA.MembershipAttributeDescriptionLong, 'N/D')  [CatProductAttributeDescriptionLong],
        CPA.CatMembershipId                                    [CatProductId],
        CPA.MembershipAttributePosition                        [CatProductAtributeOrder],
        CS.Icon                                                [CatProductAttributeIcon]
    From DeliveryBackOffice.[dbo].[CatMembershipAttribute] CPA WITH(NOLOCK)
    INNER JOIN DeliveryBackOffice.[dbo].[CatMembership] CS WITH(NOLOCK)
        ON CPA.CatMembershipId = CS.IdCatMembership
    Where CPA.RowStatus = 1 
    AND CS.RowStatus = 1 
    AND CS.IdCountry = @IdCountry  
    ORDER BY CPA.SubscriptionAttributePosition ASC

END