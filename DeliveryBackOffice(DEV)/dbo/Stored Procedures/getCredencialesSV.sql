-- =============================================
-- Author:      Juan Ramirez
-- Create date: 2025/06/04
-- Description: <Sp para obtener los valores de Seller para facturar en el Salvador>
-- =============================================
CREATE PROCEDURE [dbo].[getCredencialesSV]
(
  @VpCodeOfReference as varchar(100) = '1162393'
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdCountry             AS NVARCHAR(2),
            @taxes                 AS NVARCHAR(50),
            @Address               AS NVARCHAR(500),
            @Phone                 AS NVARCHAR(15),
            @CodeISO               AS NVARCHAR(200),
            @IdTax                 AS NVARCHAR(200),
            @FELCorreo             AS NVARCHAR(200),
            @cmp_name              AS NVARCHAR(200),
            @Password              AS NVARCHAR(200),
            @Username              AS NVARCHAR(200),
            @TaxPercentage         AS NVARCHAR(30),
            @inv_cmp_nameComercial AS NVARCHAR(200),
            @inv_cmp_name          AS NVARCHAR(200),
            @dpf_FELUserName             AS NVARCHAR(200),
            @dpf_FELData3                AS NVARCHAR(200),
            @dpf_FELAsuntoCorreoFactura  AS NVARCHAR(200),
            @dpf_FELEstablecimiento      AS NVARCHAR(200);

     SELECT @Address = vpc.[Address], --@Address = 
            @IdCountry = vpc.[CountryId], --@IdCountry
            @Phone = vpc.[Phone]
       FROM VisitPointClient vpc WITH(NOLOCK)
      WHERE vpc.CodeOfReference = @VpCodeOfReference
        AND vpc.statusClient = 1

     SELECT @TaxPercentage = dpc.TaxPercentage
       FROM DefaultValuesPerCountry dpc WITH(NOLOCK)
      WHERE dpc.IdCountry = @IdCountry

     SELECT @CodeISO = cc.CodeISO
       FROM DeliveryCurrency dc WITH(NOLOCK)
            INNER JOIN CatCurrencyCOD cc WITH(NOLOCK) ON cc.IdCatCurrencyCOD = dc.IdCurrencyCOD
      WHERE dc.Currency_IdCountry = @IdCountry
        AND dc.DefaultPerCountry = 1

     SELECT @IdTax = dp.dpf_FELEntity,
            @FELCorreo = dp.dpf_FELCorreo,
            @cmp_name = dp.inv_cmp_name,
            @Password = dpf_FELRequestor,
            @Username = dpf_FELUser,
            @inv_cmp_name = [inv_cmp_name],
            @inv_cmp_nameComercial = [inv_cmp_nameComercial],
            @dpf_FELUserName            = dpf_FELUserName,
            @dpf_FELData3               = dpf_FELData3,
            @dpf_FELAsuntoCorreoFactura = dpf_FELAsuntoCorreoFactura,
            @dpf_FELEstablecimiento     = dpf_FELEstablecimiento
       FROM del_ParametrosFactura dp WITH(NOLOCK)
      WHERE dp.dpf_VpCodeOfReference = @VpCodeOfReference

      SELECT ISNULL(@Address  ,'')            AS [Address],
             ISNULL(@IdCountry,'')            AS IdCountry,
             ISNULL(@CodeISO  ,'')            AS CodeISO,
             ISNULL(@IdTax    ,'')            AS TaxID,
             ISNULL(@FELCorreo,'')            AS Email,
             ISNULL(@cmp_name ,'')            AS [Name],
             ISNULL(@Phone    ,'')            AS Phone,
             ISNULL(@Username ,'')            AS Username,
             ISNULL(@Password ,'')            AS [Password],
             ISNULL(@TaxPercentage ,'')       AS TaxPercentage,
             ISNULL(@inv_cmp_name ,'')        AS inv_cmp_name,
             ISNULL(@inv_cmp_nameComercial,'')AS inv_cmp_nameComercial,
             ISNULL(@dpf_FELUserName           ,'') AS dpf_FELUserName,
             ISNULL(@dpf_FELData3              ,'') AS dpf_FELData3,
             ISNULL(@dpf_FELAsuntoCorreoFactura,'') AS dpf_FELAsuntoCorreoFactura,
             ISNULL(@dpf_FELEstablecimiento    ,'') AS dpf_FELEstablecimiento


     SELECT CodeOfReference
            , aibc.[Node]
            , aibc.[Name]
            , ISNULL(aibc.[Data] ,'') as [Data]
            , ISNULL(aibc.[Value],'') AS [Value]
       FROM AddInfoByCodeOfReference aibc WITH(NOLOCK)
      WHERE aibc.CodeOfReference = @VpCodeOfReference
        AND aibc.RowStatus = 1
        AND LEN(aibc.[Node]) > 0
        AND LEN(aibc.[Name]) > 0
        AND EntityTypeByBillingSVId = 1

     SELECT  ISNULL(adbc.[Node] ,'') AS [Node]
            ,ISNULL(adbc.[Name] ,'') AS [Name]
            ,ISNULL(adbc.[Data] ,'') AS [Data]
            ,ISNULL(adbc.[Value],'') AS [Value]
       FROM addinfoByConfigSV adbc  WITH(NOLOCK)
      WHERE adbc.RowStatus = 1
        AND LEN(adbc.[Node]) > 0
        AND LEN(adbc.[Name]) > 0
END