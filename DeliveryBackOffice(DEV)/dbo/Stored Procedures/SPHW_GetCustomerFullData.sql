-- =============================================
-- Author:		<Edelman>
-- Create date: <2025-11-25>
-- Description:	<Obtener data de cliente para forzaPay>
-- =============================================
-- =============================================
-- Author:		<Marcelo Del Aguila>
-- Create date: <2026-03-06>
-- Description:	<Ajuste en nombre mostrado según tipo de cuenta>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetCustomerFullData]
    @IdCustomer INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. DATOS PRINCIPALES
    SELECT
    p.PerFirstName AS Nombres,
    p.PerLastName AS Apellidos,
    p.PerIdentification AS DPI,
    p.PerBirthdate AS FechaNacimiento,
    p.PerGender AS Genero,
    p.PerNationality AS Nacionalidad,
    c.Abbreviation AS SobreNombre,
    ru.PreFixCallingCode AS PrefijoTelefono,
    ru.Phone AS Telefono,
    CASE
        WHEN a.AccIdTypeAccount = 1
            THEN COALESCE(NULLIF(ru.UsrNickName, ''), ru.CommercialName)
        ELSE
            ru.CommercialName
    END AS NombreComercial,
    ru.UsrEmail AS Correo
FROM [DeliveryBackOffice].[dbo].[Customer] c WITH(NOLOCK)
INNER JOIN [DeliveryBackOffice].[dbo].[Account] a WITH(NOLOCK) ON a.IdCustomer = c.IdCustomer
INNER JOIN [DeliveryBackOffice].[dbo].[RolByUserByAccount] rua WITH(NOLOCK) ON rua.RuaIdAccount = a.AccIdAccount
INNER JOIN [DeliveryBackOffice].[dbo].[RegisterUser] ru WITH(NOLOCK) ON ru.UsrIdUser = rua.RuaIdUser
INNER JOIN [DeliveryBackOffice].[dbo].[Person] p WITH(NOLOCK) ON p.PerIdPerson = ru.UsrIdPerson
WHERE c.IdCustomer = @IdCustomer;

    -- 2. DATOS DE FACTURACIÓN
    SELECT DISTINCT
        bp.BlpTaxId AS NIT,
        bp.BlpName AS NombreFactura,
        bp.BlpAddress AS DireccionFactura
    FROM [DeliveryBackOffice].[dbo].[BillingProfile] bp WITH(NOLOCK)
    INNER JOIN [DeliveryBackOffice].[dbo].[Account] a WITH(NOLOCK) ON a.AccIdAccount = bp.BlpIdAccount
    INNER JOIN [DeliveryBackOffice].[dbo].[Customer] c WITH(NOLOCK) ON c.IdCustomer = a.IdCustomer
    WHERE c.IdCustomer = @IdCustomer;

    -- 3. CUENTAS BANCARIAS
    SELECT DISTINCT
        dfc.NameAccountFavCOD AS NombreCuenta,
        dfc.NumberAccFavCOD AS NumeroCuenta,
        dfc.TypeAccountFavCOD AS TipoCuenta,
        db.Acronym AS Banco
    FROM [DeliveryBackOffice].[dbo].[DeliveryFavCOD] dfc WITH(NOLOCK)
    INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryBank] db WITH(NOLOCK) ON db.Id_bank = dfc.IdBank
    INNER JOIN [DeliveryBackOffice].[dbo].[Account] a WITH(NOLOCK) ON a.AccIdAccount = dfc.IdAccountFavCOD
    WHERE a.IdCustomer = @IdCustomer;

    -- 4. DIRECCIONES FAVORITAS
    SELECT DISTINCT
        ua.UadFullName AS NombreDireccion,
        ua.UadAddress1 AS Direccion,
        ua.UadPhone AS TelefonoDireccion,
        a.AccDateCreated AS FechaCreacionCuenta
    FROM [DeliveryBackOffice].[dbo].[UserAddress] ua WITH(NOLOCK)
    INNER JOIN [DeliveryBackOffice].[dbo].[Account] a WITH(NOLOCK) ON a.AccIdAccount = ua.UadIdAccount
    WHERE a.IdCustomer = @IdCustomer;
END
