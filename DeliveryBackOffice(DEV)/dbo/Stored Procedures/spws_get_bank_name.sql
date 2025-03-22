
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-10-27>
-- Description:	<Devuelve el nombre de un banco
--				basado en coincidencia de  nombre>
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2023-01-05>
-- Description:	<Ordenar nombre de bancos de forma Ascendente>
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2023-01-20>
-- Description:	<Agregar Campo tipo Cuenta, máximo caracteres, mínimo caracteres, dígitos de inicio y mensaje de estructura  de cuentas>
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2023-01-2>4
-- Description:	<Devolver tipo de cuenta y mensaje de estructura de cuenta en arreglo dentro del json>
-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-06-20>
-- Description: <Se agrega el filtro por pais, por defecto GT>
-- =============================================
-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2025-03-2024>
-- Description:	<Trasladar objetos de consultas para armar Json a nivel de API>
-- =============================================

CREATE PROCEDURE [dbo].[spws_get_bank_name]
    @ValName NVARCHAR(100)='-1',
    @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
    SET NOCOUNT ON;

    -- Primer conjunto de datos: Información de bancos
    SELECT DISTINCT
        DB.Id_bank,
        DB.Name,
        DB.Acronym,
        DB.Description,
        DB.Id_country
    FROM [DeliveryBackOffice].[dbo].[DeliveryBank] DB WITH (NOLOCK)
	    INNER JOIN 
		[DeliveryBackOffice].[dbo].[AccountBankFormatRule] ABFR WITH (NOLOCK)
		  ON DB.Id_bank = ABFR.DeliveryBankId  
    WHERE DB.Id_status = 1
        AND (DB.Name LIKE '%' + @ValName + '%' OR @ValName = '-1')
        AND DB.Id_country = @IdCountry
    ORDER BY DB.Name ASC;

    -- Segundo conjunto de datos: Validaciones de cuentas bancarias
    SELECT 
        ABFR.DeliveryBankId AS Id_bank,
        CBAT.BankAccountType,
        CASE
            WHEN ABFR.MaximumLength IS NOT NULL AND ABFR.MinimumLength IS NOT NULL AND ABFR.StartsWith IS NULL 
                THEN 'El número de cuenta debe de tener mínimo ' + CONVERT(VARCHAR, ABFR.MinimumLength) + 
                     ' dígitos y un máximo de ' + CONVERT(VARCHAR, ABFR.MaximumLength) + ' dígitos.'
            WHEN ABFR.MaximumLength IS NULL AND ABFR.MinimumLength IS NULL AND ABFR.StartsWith IS NOT NULL 
                THEN 'El número de cuenta debe iniciar con los dígitos: ' + ABFR.StartsWith
            WHEN ABFR.MaximumLength IS NOT NULL AND ABFR.MinimumLength IS NOT NULL AND ABFR.StartsWith IS NOT NULL 
                THEN 'El número de cuenta debe de tener mínimo ' + CONVERT(VARCHAR, ABFR.MinimumLength) + 
                     ' dígitos y un máximo de ' + CONVERT(VARCHAR, ABFR.MaximumLength) + 
                     ' dígitos e iniciar con los números: ' + ABFR.StartsWith
            ELSE 'Sin Validación de estructura'
        END AS Message
    FROM [DeliveryBackOffice].[dbo].[AccountBankFormatRule] ABFR WITH (NOLOCK)
    INNER JOIN [DeliveryBackOffice].[dbo].[CatBankAccountType] CBAT WITH (NOLOCK)
        ON ABFR.CatBankAccountTypeId = CBAT.IdBankAccountType
	INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryBank] DB WITH(NOLOCK)
	    ON ABFR.DeliveryBankId = DB.Id_bank
    WHERE ABFR.RowStatus = 1;
END;
