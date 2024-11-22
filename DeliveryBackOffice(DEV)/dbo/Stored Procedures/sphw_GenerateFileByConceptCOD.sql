
-- =============================================
-- Author:		<Jimenez,Marco>
-- Create date: <2021-12-07>
-- Description:	<Generar archivos según el concepto COD>
-- =============================================
--EXEC sphw_GenerateFileByConceptCOD 1,3
CREATE PROCEDURE [dbo].[sphw_GenerateFileByConceptCOD]
    -- Add the parameters for the stored procedure here
    @Id INT,
    @ConceptId INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @Excluded INT = 0;
    DECLARE @EnabledRow INT = 1;
    DECLARE @IdCountry NVARCHAR(2) = N'GT';

    DECLARE @IdBank INT = 31;

    SELECT REPLACE(
                      REPLACE(
                                 REPLACE(
                                            REPLACE(
                                                       REPLACE(
                                                                  REPLACE(
                                                                             REPLACE(
                                                                                        REPLACE(
                                                                                                   cda.AccountNumber,
                                                                                                   ' ',
                                                                                                   ''
                                                                                               ),
                                                                                        '-',
                                                                                        ''
                                                                                    ),
                                                                             CHAR(1),
                                                                             ''
                                                                         ),
                                                                  CHAR(2),
                                                                  ''
                                                              ),
                                                       CHAR(3),
                                                       ''
                                                   ),
                                            CHAR(9),
                                            ''
                                        ),
                                 CHAR(10),
                                 ''
                             ),
                      CHAR(13),
                      ''
                  ) 'CUENTA DEBITO',
           RTRIM(LTRIM(REPLACE(
                                  REPLACE(
                                             REPLACE(
                                                        REPLACE(
                                                                   REPLACE(
                                                                              REPLACE(
                                                                                         RTRIM(LTRIM(bd.AccountNumber)),
                                                                                         CHAR(1),
                                                                                         ''
                                                                                     ),
                                                                              CHAR(2),
                                                                              ''
                                                                          ),
                                                                   CHAR(3),
                                                                   ''
                                                               ),
                                                        CHAR(9),
                                                        ''
                                                    ),
                                             CHAR(10),
                                             ''
                                         ),
                                  CHAR(13),
                                  ''
                              )
                      )
                ) 'CUENTA CREDITO',
           FORMAT(MAX(bd.CreditDate), 'dd/MM/yyyy') 'FECHA',
           SUM(Amount) 'MONTO',
           CASE
               WHEN @ConceptId = 3 THEN
                   MAX(CONCAT('COLLECT ', ' Ref ', CAST(bd.CollectId AS VARCHAR(10))))
               WHEN @ConceptId = 4 THEN
                   MAX(CONCAT('RECOLECCION ', ' Ref ', CAST(bd.RecolectionId AS VARCHAR(10))))
               ELSE
                   MAX(CAST(bd.Reference AS VARCHAR(10)))
           END 'REFERENCIA',
           RTRIM(LTRIM(REPLACE(
                                  REPLACE(
                                             REPLACE(
                                                        REPLACE(
                                                                   REPLACE(
                                                                              REPLACE(
                                                                                         REPLACE(
                                                                                                    RTRIM(LTRIM(bd.AccountName)),
                                                                                                    ',',
                                                                                                    ''
                                                                                                ),
                                                                                         CHAR(1),
                                                                                         ''
                                                                                     ),
                                                                              CHAR(2),
                                                                              ''
                                                                          ),
                                                                   CHAR(3),
                                                                   ''
                                                               ),
                                                        CHAR(9),
                                                        ''
                                                    ),
                                             CHAR(10),
                                             ''
                                         ),
                                  CHAR(13),
                                  ''
                              )
                      )
                ) 'BENEFICIARIO',
           ctt.TransactionType 'TIPO DE TRANSACCION',
           cc.NumISO 'MONEDA ACH',
           db.ACHCode 'CODIGO BANCO ACH',
           cat.Description 'TIPO DE CUENTA OTRO BANCO',
           cco.Concept 'CONCEPTO',
           Password 'CONTRASEÑA'
    FROM DeliveryBackOffice.dbo.BatchDetailCOD bd					WITH(NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.CatDebitAccountCOD cda		WITH(NOLOCK)
            ON cda.IdCatDebitAccountCOD = bd.CatDebitAccountCODId
               AND cda.BankId = @IdBank
               AND cda.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.CatTransactionTypeCOD ctt	WITH(NOLOCK)
            ON ctt.IdCatTransactionTypeCOD = bd.CatTransactionTypeCODId
               AND ctt.BankId = @IdBank
               AND ctt.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD cc			WITH(NOLOCK)
            ON cc.IdCatCurrencyCOD = bd.CatCurrencyCODId
               AND cc.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank db			WITH(NOLOCK)
            ON db.Id_bank = bd.BankId
               AND db.Id_status = @EnabledRow
               AND db.Id_country = @IdCountry
        LEFT JOIN DeliveryBackOffice.dbo.CatAccountTypeCOD cat		WITH(NOLOCK)
            ON cat.IdCatAccountTypeCOD = bd.CatAccountTypeCODId
               AND cat.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.CatConceptCOD cco			WITH(NOLOCK)
            ON cco.IdCatConceptCOD = bd.CatConceptCODId
               AND cco.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.ProcessedGuideCOD PGD		WITH(NOLOCK)
            ON PGD.GuideSerie = bd.GuideSerie
               AND PGD.GuideNumber = bd.GuideNumber
               AND PGD.RowStatus = 1
    WHERE PGD.RowStatus = 1
		  AND PGD.IsCompleted = 1
          AND bd.Excluded = @Excluded
		  AND bd.IsCompleted = 1
          AND bd.CatConceptCODId = @ConceptId
          AND
          (
              bd.CommissionId = @Id
              OR bd.CollectId = @Id
              OR bd.RecolectionId = @Id
          )
    GROUP BY cda.AccountNumber,
             bd.AccountNumber,
             bd.AccountName,
             ctt.TransactionType,
             cc.NumISO,
             db.ACHCode,
             cat.Description,
             cco.Concept,
             Password;

    SELECT REPLACE(
                      REPLACE(
                                 REPLACE(
                                            REPLACE(
                                                       REPLACE(
                                                                  REPLACE(
                                                                             REPLACE(
                                                                                        REPLACE(
                                                                                                   cda.AccountNumber,
                                                                                                   ' ',
                                                                                                   ''
                                                                                               ),
                                                                                        '-',
                                                                                        ''
                                                                                    ),
                                                                             CHAR(1),
                                                                             ''
                                                                         ),
                                                                  CHAR(2),
                                                                  ''
                                                              ),
                                                       CHAR(3),
                                                       ''
                                                   ),
                                            CHAR(9),
                                            ''
                                        ),
                                 CHAR(10),
                                 ''
                             ),
                      CHAR(13),
                      ''
                  ) 'CUENTA DEBITO',
           RTRIM(LTRIM(REPLACE(
                                  REPLACE(
                                             REPLACE(
                                                        REPLACE(
                                                                   REPLACE(
                                                                              REPLACE(
                                                                                         RTRIM(LTRIM(bd.AccountNumber)),
                                                                                         CHAR(1),
                                                                                         ''
                                                                                     ),
                                                                              CHAR(2),
                                                                              ''
                                                                          ),
                                                                   CHAR(3),
                                                                   ''
                                                               ),
                                                        CHAR(9),
                                                        ''
                                                    ),
                                             CHAR(10),
                                             ''
                                         ),
                                  CHAR(13),
                                  ''
                              )
                      )
                ) 'CUENTA CREDITO',
           FORMAT(bd.CreditDate, 'dd/MM/yyyy') 'FECHA',
           bd.Amount 'MONTO',
           CASE
               WHEN @ConceptId = 3 THEN
                   CONCAT('COLLECT ', bd.GuideNumber, ' Ref ', CAST(bd.CollectId AS VARCHAR(10)))
               WHEN @ConceptId = 4 THEN
                   CONCAT('RECOLECCION ', bd.GuideNumber, ' Ref ', CAST(bd.RecolectionId AS VARCHAR(10)))
               ELSE
                   CAST(bd.Reference AS VARCHAR(10))
           END 'REFERENCIA',
           RTRIM(LTRIM(REPLACE(
                                  REPLACE(
                                             REPLACE(
                                                        REPLACE(
                                                                   REPLACE(
                                                                              REPLACE(
                                                                                         REPLACE(
                                                                                                    RTRIM(LTRIM(bd.AccountName)),
                                                                                                    ',',
                                                                                                    ''
                                                                                                ),
                                                                                         CHAR(1),
                                                                                         ''
                                                                                     ),
                                                                              CHAR(2),
                                                                              ''
                                                                          ),
                                                                   CHAR(3),
                                                                   ''
                                                               ),
                                                        CHAR(9),
                                                        ''
                                                    ),
                                             CHAR(10),
                                             ''
                                         ),
                                  CHAR(13),
                                  ''
                              )
                      )
                ) 'BENEFICIARIO',
           ctt.TransactionType 'TIPO DE TRANSACCION',
           cc.NumISO 'MONEDA ACH',
           db.ACHCode 'CODIGO BANCO ACH',
           cat.Description 'TIPO DE CUENTA OTRO BANCO',
           CASE
               WHEN @ConceptId = 3 THEN
                   CONCAT('COLLECT ', bd.GuideNumber, ' Ref ', CAST(bd.CollectId AS VARCHAR(10)))
               WHEN @ConceptId = 4 THEN
                   CONCAT('RECOLECCION ', bd.GuideNumber, ' Ref ', CAST(bd.RecolectionId AS VARCHAR(10)))
               ELSE
                   CAST(bd.Reference AS VARCHAR(10))
           END 'CONCEPTO',
           bd.Password 'CONTRASEÑA',
           CONCAT(bd.GuideSerie, bd.GuideNumber) 'GUIA',
           @Id 'LOTE',
           CONCAT(do.Sender_FirstName, ' ', do.Sender_LastName) 'NOMBRE CLIENTE',
           ISNULL(
                     RTRIM(LTRIM(REPLACE(
                                            REPLACE(
                                                       REPLACE(
                                                                  REPLACE(
                                                                             REPLACE(
                                                                                        REPLACE(
                                                                                                   REPLACE(
                                                                                                              RTRIM(LTRIM(bdc.AccountName)),
                                                                                                              ',',
                                                                                                              ''
                                                                                                          ),
                                                                                                   CHAR(1),
                                                                                                   ''
                                                                                               ),
                                                                                        CHAR(2),
                                                                                        ''
                                                                                    ),
                                                                             CHAR(3),
                                                                             ''
                                                                         ),
                                                                  CHAR(9),
                                                                  ''
                                                              ),
                                                       CHAR(10),
                                                       ''
                                                   ),
                                            CHAR(13),
                                            ''
                                        )
                                )
                          ),
                     ''
                 ) 'NOMBRE CUENTA CLIENTE',
           ISNULL(invh.inv_SAPDocEntry, 0) 'DOCUMENTO EN SAP (DocEntry)',
           ISNULL(invh.inv_serieFEL, '') 'SERIE FEL',
           ISNULL(invh.inv_numberFEL, '') 'NÚMERO FEL',
           ISNULL(invh.inv_certificationFEL, '') 'CERTIFIACDO FEL'
    FROM DeliveryBackOffice.dbo.BatchDetailCOD bd					WITH(NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.ProcessedGuideCOD PGD		WITH(NOLOCK)
            ON PGD.GuideSerie = bd.GuideSerie
               AND PGD.GuideNumber = bd.GuideNumber
               AND PGD.RowStatus = 1
        LEFT JOIN DeliveryBackOffice.dbo.CatDebitAccountCOD cda		WITH(NOLOCK)
            ON cda.IdCatDebitAccountCOD = bd.CatDebitAccountCODId
               AND cda.BankId = @IdBank
               AND cda.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.CatTransactionTypeCOD ctt	WITH(NOLOCK)
            ON ctt.IdCatTransactionTypeCOD = bd.CatTransactionTypeCODId
               AND ctt.BankId = @IdBank
               AND ctt.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD cc			WITH(NOLOCK)
            ON cc.IdCatCurrencyCOD = bd.CatCurrencyCODId
               AND cc.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank db			WITH(NOLOCK)
            ON db.Id_bank = bd.BankId
               AND db.Id_status = @EnabledRow
               AND db.Id_country = @IdCountry
        LEFT JOIN DeliveryBackOffice.dbo.CatAccountTypeCOD cat		WITH(NOLOCK)
            ON cat.IdCatAccountTypeCOD = bd.CatAccountTypeCODId
               AND cat.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.CatConceptCOD cco			WITH(NOLOCK)
            ON cco.IdCatConceptCOD = bd.CatConceptCODId
               AND cco.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder do			WITH(NOLOCK)
            ON bd.GuideSerie = do.Guide_Serie
               AND bd.GuideNumber = do.Guide_Number
        LEFT JOIN DeliveryBackOffice.dbo.BatchDetailCOD bdc			WITH(NOLOCK)
            ON bdc.GuideSerie = bd.GuideSerie
               AND bdc.GuideNumber = bd.GuideNumber
               AND bdc.BankId <> 31
        LEFT JOIN
        (
            SELECT MIN(fac.inv_SAPDocEntry) inv_SAPDocEntry,
                   MIN(fac.inv_serieFEL) inv_serieFEL,
                   MIN(fac.inv_numberFEL) inv_numberFEL,
                   MIN(fac.inv_certificationFEL) inv_certificationFEL,
                   invd.dti_fk_orderSerie dti_fk_orderSerie,
                   invd.dti_fk_orderNumber dti_fk_orderNumber
            FROM DeliveryBackOffice.dbo.invoiceDetail invd			WITH(NOLOCK)
               inner JOIN DeliveryBackOffice.dbo.invoiceHeader fac	WITH(NOLOCK)
                    ON fac.inv_pk_id = invd.dti_fk_header
                       AND fac.inv_descriptionFEL = 'PROCESO REALIZADO'
                       AND fac.inv_invoiceOfCreditNote IS NOT NULL
                       AND fac.inv_creditNote IS NULL
            GROUP BY invd.dti_fk_orderSerie,
                     invd.dti_fk_orderNumber
        ) invh
            ON invh.dti_fk_orderSerie = bd.GuideSerie
               AND invh.dti_fk_orderNumber = bd.GuideNumber
    WHERE PGD.RowStatus = 1
          AND PGD.IsCompleted = 1
		  AND bd.Excluded = @Excluded
		  AND bd.IsCompleted = 1
          AND bd.CatConceptCODId = @ConceptId
          AND
          (
              bd.CommissionId = @Id
              OR bd.CollectId = @Id
              OR bd.RecolectionId = @Id
          )
		  AND bdc.IsCompleted = 1
    ORDER BY bd.CreditDate DESC;



    SET NOCOUNT OFF;
END;