-- =============================================
-- Author:      <Cristian, Azurdia>
-- Create date: <2025-01-09>
-- Description: <Retorna los datos de una partidas de facturas pagadas al contado>
-- =============================================
CREATE PROCEDURE [dbo].[GetVTSCountedForza]
    -- Add the parameters for the stored procedure here
    @DateInit DATETIME,
    @DateFinish DATETIME,
    @IdCountry NVARCHAR(4) = 'GT'
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

        SELECT RIGHT('000' + CAST(ibh.Establishment AS NVARCHAR(3)), 3) + '-' + RIGHT('000' + CAST(ibh.Emision_Point AS NVARCHAR(3)), 3) + '-' + RIGHT('000' + CAST(ibh.TypeDocument AS NVARCHAR(3)), 3) + '-' +  RIGHT('00000000' + CAST(ibh.InitialRange AS NVARCHAR(8)), 8) U_FACTURA_INI,
               RIGHT('000' + CAST(ibh.Establishment AS NVARCHAR(3)), 3) + '-' + RIGHT('000' + CAST(ibh.Emision_Point AS NVARCHAR(3)), 3) + '-' + RIGHT('000' + CAST(ibh.TypeDocument AS NVARCHAR(3)), 3) + '-' +  RIGHT('00000000' + CAST(ibh.FinalRange AS NVARCHAR(8)), 8) U_FACTURA_FIN,
               ibh.CAI U_CAI,
               ih.inv_certificationFEL U_NUMERO_DOCUMENTO,
               ih.inv_cli_nit U_FACNIT,
               ih.inv_amount U_DOCTOTAL
        FROM invoiceHeader ih
        INNER JOIN InvoiceBatchHeader ibh
            ON ih.inv_serieFEL = ibh.CAI
        WHERE CONVERT(date, ih.inv_date) >= @DateInit
          AND CONVERT(date, ih.inv_date) <= @DateFinish
          AND IdCountry = @IdCountry

END;
