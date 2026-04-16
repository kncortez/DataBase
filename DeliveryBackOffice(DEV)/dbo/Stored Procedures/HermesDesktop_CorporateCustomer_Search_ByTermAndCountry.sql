/*
  Name    : HermesDesktop_CorporateCustomer_Search_ByTermAndCountry
  Summary : Busca socios de negocio corporativos por código Hermes, CardCode SAP o nombre.
            Retorna máximo 50 coincidencias para el autocomplete del módulo de
            Emisión de Facturas Corporativas (settlement-dbo).
  Inputs  :
    @SearchTerm nvarchar(100) -obligatorio- término de búsqueda (mín. 4 chars desde el front)
    @IdCountry  nvarchar(2)   -obligatorio- país del operador: GT | SV | HN
  Outputs :
    ResultSet1: IdCustomer (int), SAPCardCode (nvarchar), Name (nvarchar)  -- hasta 50 filas
  Notes   :
    - Solo clientes corporativos activos (IdCustomerType = 1, RowSatus = 1).
    - Orden: match exacto Hermes > prefijo CardCode > nombre parcial.
  Author <Hanss Espinoza> : | Created: 2026-04-14 | Module: Billing
  Ticket  : <FDAPI-5989>
  CHANGELOG:
    - 2026-04-14 <Hanss Espinoza> V1: creación
*/
CREATE PROCEDURE [dbo].[HermesDesktop_CorporateCustomer_Search_ByTermAndCountry]
    @SearchTerm NVARCHAR(100),
    @IdCountry  NVARCHAR(2)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH CTE AS (

        SELECT CS.IdCustomer,
               ISNULL(CS.SAPCardCode, '') AS SAPCardCode,
               CS.[Name],
               0 AS SortOrder
          FROM DeliveryBackOffice.dbo.Customer CS WITH(NOLOCK)
         WHERE CS.IdCustomerType = 1
           AND CS.RowSatus       = 1
           AND CS.CountryID      = @IdCountry
           AND ISNUMERIC(@SearchTerm) = 1
           AND CAST(CS.IdCustomer AS NVARCHAR) LIKE @SearchTerm + '%'

        UNION ALL

        SELECT CS.IdCustomer,
               ISNULL(CS.SAPCardCode, '') AS SAPCardCode,
               CS.[Name],
               1 AS SortOrder
          FROM DeliveryBackOffice.dbo.Customer CS WITH(NOLOCK)
         WHERE CS.IdCustomerType = 1
           AND CS.RowSatus       = 1
           AND CS.CountryID      = @IdCountry
           AND CS.SAPCardCode LIKE @SearchTerm + '%'

        UNION ALL

        SELECT CS.IdCustomer,
               ISNULL(CS.SAPCardCode, '') AS SAPCardCode,
               CS.[Name],
               2 AS SortOrder
          FROM DeliveryBackOffice.dbo.Customer CS WITH(NOLOCK)
         WHERE CS.IdCustomerType = 1
           AND CS.RowSatus       = 1
           AND CS.CountryID      = @IdCountry
           AND CS.[Name] LIKE '%' + @SearchTerm + '%'
    ),
    Ranked AS (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY IdCustomer ORDER BY SortOrder) AS rn
          FROM CTE
    )
    SELECT TOP 50
        IdCustomer,
        SAPCardCode,
        [Name]
      FROM Ranked
     WHERE rn = 1
     ORDER BY SortOrder, [Name] ASC;
END
