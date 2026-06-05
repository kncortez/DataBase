
-- =============================================
-- Author:      <José Chuy>
-- Create date: <2025-12-09>
-- Description: < Busqueda avanzada de clientes buscando por una concidencia en puntos de visita >
-- =============================================
-- =============================================
-- Author:      <Andres, Ruiz>
-- Create date: <2022-05-12>
-- Description: < Re-diseño por performance >
-- =============================================
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-05-24>
-- Description: < Se agrego filtro para datos por pais, por defecto GT >
-- =============================================



CREATE PROCEDURE [dbo].[AdvancedGetCustomers_New] 
(
    @Filter NVARCHAR(100),
    @IdCountry NVARCHAR(2) = 'GT'
)
AS
BEGIN
	/*
	BASADO EN LA CARDINALIDAD DE LA INFORMACION
		[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)			1,973,641
		[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)					  104,441
		[DeliveryBackOffice].[dbo].[Account] Ac WITH(NOLOCK)					  107,660
		[DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA WITH(NOLOCK)		  107,659
		[DeliveryBackOffice].[dbo].[RegisterUser] RU WITH(NOLOCK)				  109,468
	*/


    SET NOCOUNT ON;
    
    -- Normalizar el filtro una sola vez
    DECLARE @NormalizedFilter NVARCHAR(100) = '%' + @Filter + '%';
    
    -- Estrategia optimizada basada en cardinalidad:
    -- VisitPointClient (1.9M) -> Customer (104K) -> Account (107K) -> RolByUserByAccount (107K) -> RegisterUser (109K)
    -- Filtrar primero en la tabla más grande y específica
    
    WITH FilteredVisitPoints AS
    (
        -- Primera filtración agresiva en la tabla más grande (1.9M registros)
        SELECT 
            VPC.CustomerID,
            VPC.IdVisitPointClient,
            VPC.DescriptionOfClient,
            VPC.Phone AS VisitPointPhone
        FROM [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK, INDEX(IX_VisitPointClient_Status_Country_Filter))
        WHERE VPC.StatusClient = 1
          AND ISNULL(VPC.CountryId, 'GT') = @IdCountry
          AND (
              VPC.DescriptionOfClient LIKE @NormalizedFilter COLLATE Latin1_General_CI_AI
              OR VPC.Phone LIKE @NormalizedFilter COLLATE Latin1_General_CI_AI
          )
    ),
    CustomerWithPhone AS
    (
        -- JOIN solo con registros filtrados (mucho menos de 1.9M)
        SELECT DISTINCT
            FVP.CustomerID,
            FVP.IdVisitPointClient,
            FVP.DescriptionOfClient,
            FVP.VisitPointPhone,
            Cu.Name,
            Cu.CommercialName,
            Cu.IdCustomerType,
            Cu.CustomerPhone,
            -- Pre-calcular teléfono normalizado del customer
            REPLACE(REPLACE(REPLACE(REPLACE(Cu.CustomerPhone, '(502)',''),'(504)',''),'-',''),' ','') AS CustomerPhoneNormalized
        FROM FilteredVisitPoints FVP
        INNER JOIN [DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
            ON Cu.IdCustomer = FVP.CustomerID
    ),
    CustomerWithUserInfo AS
    (
        -- LEFT JOIN opcional solo para IdCustomerType = 3 (optimización condicional)
        SELECT 
            CWP.*,
            -- Solo buscar info de usuario si es necesario
            CASE 
                WHEN CWP.IdCustomerType = 3 THEN RU.Phone
                ELSE NULL
            END AS UserPhone,
            CASE 
                WHEN CWP.IdCustomerType = 3 THEN RU.UsrEmail
                ELSE NULL
            END AS UsrEmail
        FROM CustomerWithPhone CWP
        LEFT JOIN [DeliveryBackOffice].[dbo].[Account] Ac WITH(NOLOCK)
            ON Ac.IdCustomer = CWP.CustomerID
            AND CWP.IdCustomerType = 3  -- Solo hacer JOIN si es tipo 3
        LEFT JOIN [DeliveryBackOffice].[dbo].[RolByUserByAccount] RBUBA WITH(NOLOCK)
            ON RBUBA.RuaIdAccount = Ac.AccIdAccount
            AND CWP.IdCustomerType = 3
        LEFT JOIN [DeliveryBackOffice].[dbo].[RegisterUser] RU WITH(NOLOCK)
            ON RU.UsrIdUser = RBUBA.RuaIdUser
            AND CWP.IdCustomerType = 3
    )
    SELECT DISTINCT
        RTRIM(CONCAT(
            '[', CustomerID, '] ',
            Name, ' ',
            IIF(CommercialName IS NOT NULL, CONCAT('[', CommercialName, '] '), ''),
            ISNULL(REPLACE(REPLACE(REPLACE(REPLACE(
                ISNULL(CustomerPhone, UserPhone),
                '(502)',''),'(504)',''),'-',''),' ',''), ''), ' ',
            IIF(IdCustomerType = 3, CONCAT(ISNULL(UsrEmail, ''), ' '), ''),
            '{', DescriptionOfClient, 
            IIF(VisitPointPhone IS NOT NULL, CONCAT('|', VisitPointPhone), ''),
            '}'
        )) AS Name,
        IdCustomerType,
        CustomerID AS IdCustomer,
        IdVisitPointClient,
        ISNULL(REPLACE(REPLACE(REPLACE(REPLACE(
            ISNULL(CustomerPhone, UserPhone),
            '(502)',''),'(504)',''),'-',''),' ',''), '') AS Phone
    FROM CustomerWithUserInfo
    ORDER BY CustomerID;
END