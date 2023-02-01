
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
CREATE PROCEDURE [dbo].[spws_get_bank_name_JRP]
    -- Add the parameters for the stored procedure here
    @ValName AS NVARCHAR(100),
    @IdCountry AS NVARCHAR(2) = 'GT'
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    DECLARE @JsonResponse NVARCHAR(MAX) = N'';
    SET NOCOUNT ON;



    SET @JsonResponse
        = N''
          +
          (
              SELECT STUFF(
                              (
                                  SELECT ',{' + '"Id_bank":"' + CONVERT(VARCHAR, [Id_bank]) +'",' 
										 + '"Name": "' + DB.[Name] +'",' 
										 + '"Acronym": "' + ISNULL(DB.[Acronym], '') +'",' 
										 + '"Description":"' + ISNULL(DB.[Description], '') +'",' 
										 + '"Id_country":"' + DB.[Id_country] +'",' 
										 + '"AccountValidators": ['
                                         +
                                         (
                                             SELECT STUFF(
                                                             (
                                                                 SELECT ',' + '{' + '"BankAccountType":"'
                                                                        + ISNULL(CBAT.BankAccountType, '"ND"') + '",'
                                                                        + '"Message ":'
                                                                        + CASE
                                                                              WHEN (
                                                                                       ABFR.MaximumLength IS NOT NULL
                                                                                       AND ABFR.MinimumLength IS NOT NULL
                                                                                   )
                                                                                   AND ABFR.StartsWith IS NULL THEN
                                                                                  '"El número de cuenta debe de tener mínimo : '
                                                                                  + CONVERT(VARCHAR, ABFR.MinimumLength)
                                                                                  + ' dígitos y un máximo de  '
                                                                                  + CONVERT(VARCHAR, ABFR.MaximumLength)
                                                                                  + ' dígitos"'
                                                                              WHEN (
                                                                                       ABFR.MaximumLength IS NULL
                                                                                       OR ABFR.MinimumLength IS NULL
                                                                                   )
                                                                                   AND ABFR.StartsWith IS NOT NULL THEN
                                                                                  '"El número de cuenta debe iniciar con los dígitos:  '
                                                                                  + ABFR.StartsWith + '"'
                                                                              WHEN (
                                                                                       ABFR.MaximumLength IS NOT NULL
                                                                                       AND ABFR.MinimumLength IS NOT NULL
                                                                                   )
                                                                                   AND ABFR.StartsWith IS NOT NULL THEN
                                                                                  '"El número de cuenta debe de tener minimo : '
                                                                                  + CONVERT(VARCHAR, ABFR.MinimumLength)
                                                                                  + ' dígitos y un máximo de  '
                                                                                  + CONVERT(VARCHAR, ABFR.MaximumLength)
                                                                                  + '   dígitos e iniciar con los números :  '
                                                                                  + ABFR.StartsWith + '"'
                                                                              WHEN (
                                                                                       ABFR.MaximumLength IS NULL
                                                                                       AND ABFR.MinimumLength IS NULL
                                                                                   )
                                                                                   AND ABFR.StartsWith IS NULL THEN
                                                                                  '"Sin Validación de estructura"'
                                                                              ELSE
                                                                                  '"Sin Validación de estructura de cuenta"'
                                                                          END + '}'
                                                                 FROM dbo.AccountBankFormatRule ABFR WITH (NOLOCK)
                                                                     INNER JOIN dbo.CatBankAccountType CBAT WITH (NOLOCK)
                                                                         ON ABFR.CatBankAccountTypeId = CBAT.IdBankAccountType
                                                                 WHERE ABFR.DeliveryBankId = DB.Id_bank
                                                                       AND ABFR.RowStatus = 1
                                                                 FOR XML PATH(''), TYPE
                                                             ).value('.', 'varchar(max)'),
                                                             1,
                                                             1,
                                                             ''
                                                         )
                                         ) + ']}'
                                  FROM DeliveryBackOffice.dbo.DeliveryBank DB WITH (NOLOCK)
                                  WHERE DB.Id_status = 1
                                        AND
                                        (
                                            Name LIKE '%' + @ValName + '%'
                                            OR @ValName = '-1'
                                        )
                                        AND DB.Id_country = 'GT'
                                        --AND DB.Acronym IS NOT NULL
                                        --AND DB.Description IS NOT NULL
                                  ORDER BY [Name] ASC
                                  FOR XML PATH(''), TYPE
                              ).value('.', 'varchar(max)'),
                              1,
                              1,
                              ''
                          )
          ) + N'';






    IF (@JsonResponse IS NULL OR @JsonResponse = '')
    BEGIN

        SET @JsonResponse =
        (
            SELECT STUFF(
                            (
                                SELECT '{{"IdResult":500,' + '"Message":"No se encontraron registros"}'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;
    SELECT ('[' + @JsonResponse + ']') JsonOutput;

END;