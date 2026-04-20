/* =================================================
   SP:        HermesDesktop_CorporateCustomer_Search_ByTermAndCountry
   Propósito: Busca socios de negocio corporativos por código Hermes, CardCode SAP o nombre.
   Autor:     Hanss Espinoza
   Historia:  <FDAPI-5989>
   Fecha:     2026-04-14
============================================
=== CHANGELOG ================================

=========================================== */
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
