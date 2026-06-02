-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2026-04-13>
-- Description:	<Generar archivos de comisiones COD>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_generate_commission_cod_International]
    @CommissionId INT
AS
BEGIN

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
           MAX(Reference) 'REFERENCIA',
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
    FROM DeliveryBackOffice.dbo.BatchDetailCOD bd with (nolock)
        LEFT JOIN DeliveryBackOffice.dbo.CatDebitAccountCOD cda
            ON cda.IdCatDebitAccountCOD = bd.CatDebitAccountCODId
               AND cda.BankId = @IdBank
               AND cda.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.CatTransactionTypeCOD ctt
            ON ctt.IdCatTransactionTypeCOD = bd.CatTransactionTypeCODId
               AND ctt.BankId = @IdBank
               AND ctt.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD cc
            ON cc.IdCatCurrencyCOD = bd.CatCurrencyCODId
               AND cc.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank db
            ON db.Id_bank = bd.BankId
               AND db.Id_status = @EnabledRow
               AND db.Id_country = @IdCountry
        LEFT JOIN DeliveryBackOffice.dbo.CatAccountTypeCOD cat
            ON cat.IdCatAccountTypeCOD = bd.CatAccountTypeCODId
               AND cat.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.CatConceptCOD cco
            ON cco.IdCatConceptCOD = bd.CatConceptCODId
               AND cco.RowStatus = @EnabledRow
    WHERE bd.Excluded = @Excluded
          AND bd.CatConceptCODId = 1 
          AND bd.CommissionId = @CommissionId
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
           bd.Reference 'REFERENCIA',
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
           IIF(cco.IdCatConceptCOD = 1,
               cco.Concept,
               CONCAT(cco.Concept, ' ', bd.GuideSerie, bd.GuideNumber, ' Ref ', CAST(bd.BatchCODId AS VARCHAR(300)))) 'CONCEPTO',
           bd.Password 'CONTRASEÑA',
           CONCAT(bd.GuideSerie, bd.GuideNumber) 'GUIA',
           bd.BatchCODId 'LOTE',
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
           ISNULL(invd.inv_SAPDocEntry, 0) 'DOCUMENTO EN SAP (DocEntry)',
           ISNULL(invd.inv_serieFEL, '') 'SERIE FEL',
           ISNULL(invd.inv_numberFEL, '') 'NÚMERO FEL',
           ISNULL(invd.inv_certificationFEL, '') 'CERTIFIACDO FEL'
    FROM DeliveryBackOffice.dbo.BatchDetailCOD bd  with (nolock)
        LEFT JOIN DeliveryBackOffice.dbo.CatDebitAccountCOD cda
            ON cda.IdCatDebitAccountCOD = bd.CatDebitAccountCODId
               AND cda.BankId = @IdBank
               AND cda.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.CatTransactionTypeCOD ctt
            ON ctt.IdCatTransactionTypeCOD = bd.CatTransactionTypeCODId
               AND ctt.BankId = @IdBank
               AND ctt.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD cc
            ON cc.IdCatCurrencyCOD = bd.CatCurrencyCODId
               AND cc.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank db
            ON db.Id_bank = bd.BankId
               AND db.Id_status = @EnabledRow
               AND db.Id_country = @IdCountry
        LEFT JOIN DeliveryBackOffice.dbo.CatAccountTypeCOD cat
            ON cat.IdCatAccountTypeCOD = bd.CatAccountTypeCODId
               AND cat.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.CatConceptCOD cco
            ON cco.IdCatConceptCOD = bd.CatConceptCODId
               AND cco.RowStatus = @EnabledRow
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder do with (nolock)
            ON bd.GuideSerie = do.Guide_Serie
               AND bd.GuideNumber = do.Guide_Number
		LEFT JOIN [dbo].[Customer] cu WITH(NOLOCK)
            ON do.[IdCustomer] = cu.[IdCustomer]
        LEFT JOIN DeliveryBackOffice.dbo.BatchDetailCOD bdc  with (nolock)
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
            FROM DeliveryBackOffice.dbo.invoiceDetail invd with (nolock)
               Inner JOIN DeliveryBackOffice.dbo.invoiceHeader fac  with (nolock)
                    ON fac.inv_pk_id = invd.dti_fk_header
                       AND fac.inv_descriptionFEL = 'PROCESO REALIZADO'
                       AND fac.inv_invoiceOfCreditNote IS NOT NULL
                       AND fac.inv_creditNote IS NULL
            GROUP BY invd.dti_fk_orderSerie,
                     invd.dti_fk_orderNumber
        ) invd
            ON invd.dti_fk_orderSerie = bd.GuideSerie
               AND invd.dti_fk_orderNumber = bd.GuideNumber
    WHERE
        bd.Excluded = @Excluded
        AND bd.CatConceptCODId = 1 
        AND bd.CommissionId = @CommissionId
		AND cu.IsInternationalCustomer =1​
    GROUP BY cda.AccountNumber,
             bd.AccountNumber,
             bd.AccountName,
             ctt.TransactionType,
             cc.NumISO,
             db.ACHCode,
             cat.Description,
             cco.Concept,
             Guide_Number,
             bd.CreditDate,
             bd.Amount,
             bd.Reference,
             bd.BatchCODId,
             cco.IdCatConceptCOD,
             bd.GuideSerie,
             bd.GuideNumber,
             bd.Password,
             do.Sender_FirstName,
             do.Sender_LastName,
             bdc.AccountName,
             invd.inv_SAPDocEntry,
             invd.inv_serieFEL,
             invd.inv_numberFEL,
             invd.inv_certificationFEL
    ORDER BY bd.CreditDate DESC;

    SET NOCOUNT OFF;
END;