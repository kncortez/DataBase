
--exec sphw_generate_file_cod 31,0,1

CREATE PROCEDURE [dbo].[sphw_generate_file_cod_CRAS]
    @IdBank INT,
    @BatchCODId INT,
    @CatConceptCODId INT = 2
AS
BEGIN
    --DECLARE @IdBank INT = 3; -- 31 33 5 3
    --DECLARE @BatchCODId INT = 17; -- 19 20 18 17
    DECLARE @Excluded INT = 0;
    DECLARE @EnabledRow INT = 1;
    DECLARE @IdCountry NVARCHAR(2) = N'GT';
    DECLARE @CatConceptCODDeposit INT = 2;
    DECLARE @CommissionId INT;
    DECLARE @BatchTypeCOD_AC INT =
            (
                SELECT CatBatchTypeCODId FROM CatBatchTypeCOD WHERE Name = 'Acumulado'
            );
    DECLARE @BatchTypeCOD_DET INT =
            (
                SELECT CatBatchTypeCODId FROM CatBatchTypeCOD WHERE Name = 'Detallado'
            );
    DECLARE @CollectId INT;
    DECLARE @RecolectionId INT;

  --  -- FORMATO BAC ENVIOS Y COMISIONES
  --  IF @IdBank = 31
  --     AND @BatchCODId = -1
  --     AND @CatConceptCODId = 1
  --  BEGIN
  --      SELECT REPLACE(
  --                        REPLACE(
  --                                   REPLACE(
  --                                              REPLACE(
  --                                                         REPLACE(
  --                                                                    REPLACE(
  --                                                                               REPLACE(
  --                                                                                          REPLACE(
  --                                                                                                     cda.AccountNumber,
  --                                                                                                     ' ',
  --                                                                                                     ''
  --                                                                                                 ),
  --                                                                                          '-',
  --                                                                                          ''
  --                                                                                      ),
  --                                                                               CHAR(1),
  --                                                                               ''
  --                                                                           ),
  --                                                                    CHAR(2),
  --                                                                    ''
  --                                                                ),
  --                                                         CHAR(3),
  --                                                         ''
  --                                                     ),
  --                                              CHAR(9),
  --                                              ''
  --                                          ),
  --                                   CHAR(10),
  --                                   ''
  --                               ),
  --                        CHAR(13),
  --                        ''
  --                    ) 'CUENTA DEBITO',
  --             RTRIM(LTRIM(REPLACE(
  --                                    REPLACE(
  --                                               REPLACE(
  --                                                          REPLACE(
  --                                                                     REPLACE(
  --                                                                                REPLACE(
  --                                                                                           RTRIM(LTRIM(bd.AccountNumber)),
  --                                                                                           CHAR(1),
  --                                                                                           ''
  --                                                                                       ),
  --                                                                                CHAR(2),
  --                                                                                ''
  --                                                                            ),
  --                                                                     CHAR(3),
  --                                                                     ''
  --                                                                 ),
  --                                                          CHAR(9),
  --                                                          ''
  --                                                      ),
  --                                               CHAR(10),
  --                                               ''
  --                                           ),
  --                                    CHAR(13),
  --                                    ''
  --                                )
  --                        )
  --                  ) 'CUENTA CREDITO',
  --             FORMAT(MAX(bd.CreditDate), 'dd/MM/yyyy') 'FECHA',
  --             SUM(Amount) 'MONTO',
  --             MAX(Reference) 'REFERENCIA',
  --             RTRIM(LTRIM(REPLACE(
  --                                    REPLACE(
  --                                               REPLACE(
  --                                                          REPLACE(
  --                                                                     REPLACE(
  --                                                                                REPLACE(
  --                                                                                           REPLACE(
  --                                                                                                      RTRIM(LTRIM(bd.AccountName)),
  --                                                                                                      ',',
  --                                                                                                      ''
  --                                                                                                  ),
  --                                                                                           CHAR(1),
  --                                                                                           ''
  --                                                                                       ),
  --                                                                                CHAR(2),
  --                                                                                ''
  --                                                                            ),
  --                                                                     CHAR(3),
  --                                                                     ''
  --                                                                 ),
  --                                                          CHAR(9),
  --                                                          ''
  --                                                      ),
  --                                               CHAR(10),
  --                                               ''
  --                                           ),
  --                                    CHAR(13),
  --                                    ''
  --                                )
  --                        )
  --                  ) 'BENEFICIARIO',
  --             ctt.TransactionType 'TIPO DE TRANSACCION',
  --             cc.NumISO 'MONEDA ACH',
  --             db.ACHCode 'CODIGO BANCO ACH',
  --             cat.Description 'TIPO DE CUENTA OTRO BANCO',
  --             cco.Concept 'CONCEPTO',
  --             Password 'CONTRASEÑA'
  --      FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
  --          LEFT JOIN DeliveryBackOffice.dbo.ProcessedGuideCOD PGD
  --              ON PGD.GuideSerie = bd.GuideSerie
  --                 AND PGD.GuideNumber = bd.GuideNumber
  --                 AND PGD.RowStatus = 1
  --          LEFT JOIN DeliveryBackOffice.dbo.CatDebitAccountCOD cda
  --              ON cda.IdCatDebitAccountCOD = bd.CatDebitAccountCODId
  --                 AND cda.BankId = @IdBank
  --                 AND cda.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.CatTransactionTypeCOD ctt
  --              ON ctt.IdCatTransactionTypeCOD = bd.CatTransactionTypeCODId
  --                 AND ctt.BankId = @IdBank
  --                 AND ctt.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD cc
  --              ON cc.IdCatCurrencyCOD = bd.CatCurrencyCODId
  --                 AND cc.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank db
  --              ON db.Id_bank = bd.BankId
  --                 AND db.Id_status = @EnabledRow
  --                 AND db.Id_country = @IdCountry
  --          LEFT JOIN DeliveryBackOffice.dbo.CatAccountTypeCOD cat
  --              ON cat.IdCatAccountTypeCOD = bd.CatAccountTypeCODId
  --                 AND cat.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.CatConceptCOD cco
  --              ON cco.IdCatConceptCOD = bd.CatConceptCODId
  --                 AND cco.RowStatus = @EnabledRow
  --      WHERE PGD.RowStatus = 1
  --            AND bd.Excluded = @Excluded
  --            AND bd.CatConceptCODId = @CatConceptCODId
  --            AND ISNULL(bd.CommissionNotified, 0) = 0
  --            AND FORMAT(bd.CreditDate, 'dd/MM/yyyy') = FORMAT(GETDATE(), 'dd/MM/yyyy')
  --            --AND ISNULL(bd.CODBatch,'TRUE') = 'TRUE'
  --      GROUP BY cda.AccountNumber,
  --               bd.AccountNumber,
  --               bd.AccountName,
  --               ctt.TransactionType,
  --               cc.NumISO,
  --               db.ACHCode,
  --               cat.Description,
  --               cco.Concept,
  --               Password;
  --  END;
  --  --FORMATO BAC DETALLE INTERNO -ENVIOS Y COMISIONES
  --  IF @IdBank = 31
  --     AND @BatchCODId = 0
  --     AND @CatConceptCODId = 1
  --  BEGIN

  --      -- Se obtiene el siguiente Id de comisión
  --      SET @CommissionId = NEXT VALUE FOR DeliveryBackOffice.dbo.COD_CommissionId;

  --      -- Se guarda el Id de comisión y fecha en BatchDetailCOD de los servicios que se guardaran en el archivo
  --      UPDATE DeliveryBackOffice.dbo.BatchDetailCOD
  --      SET CommissionId = @CommissionId,
  --          CommissionDate = GETDATE()
  --      WHERE IdBatchDetailCOD IN
  --            (
  --                SELECT bd.IdBatchDetailCOD
  --                FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
		--		  INNER JOIN DeliveryBackOffice.dbo.ProcessedGuideCOD PGD 
		--		  ON BD.GuideSerie = PGD.GuideSerie AND BD.GuideNumber = PGD.GuideNumber
  --                WHERE
  --                    --bd.BatchCODId = @BatchCODId
  --                    --AND 
  --                    bd.Excluded = @Excluded
  --                    AND bd.CatConceptCODId = @CatConceptCODId
  --                    AND ISNULL(bd.CommissionNotified, 0) = 0
  --                    AND FORMAT(bd.CreditDate, 'dd/MM/yyyy') = FORMAT(GETDATE(), 'dd/MM/yyyy')
  --                    -- AND ISNULL(bd.CODBatch,'TRUE') = 'TRUE'
		--			  AND PGD.BatchCODId IS NOT NULL
		--			  AND PGD.BatchCODIdCommission IS NOT NULL
  --            );


  --      SELECT REPLACE(
  --                        REPLACE(
  --                                   REPLACE(
  --                                              REPLACE(
  --                                                         REPLACE(
  --                                                                    REPLACE(
  --                                                                               REPLACE(
  --                                                                                          REPLACE(
  --                                                                                                     cda.AccountNumber,
  --                                                                                                     ' ',
  --                                                                                                     ''
  --                                                                                                 ),
  --                                                                                          '-',
  --                                                                                          ''
  --                                                                                      ),
  --                                                                               CHAR(1),
  --                                                                               ''
  --                                                                           ),
  --                                                                    CHAR(2),
  --                                                                    ''
  --                                                                ),
  --                                                         CHAR(3),
  --                                                         ''
  --                                                     ),
  --                                              CHAR(9),
  --                                              ''
  --                                          ),
  --                                   CHAR(10),
  --                                   ''
  --                               ),
  --                        CHAR(13),
  --                        ''
  --                    ) 'CUENTA DEBITO',
  --             RTRIM(LTRIM(REPLACE(
  --                                    REPLACE(
  --                                               REPLACE(
  --                                                          REPLACE(
  --                                                                     REPLACE(
  --                                                                                REPLACE(
  --                                                                                           RTRIM(LTRIM(bd.AccountNumber)),
  --                                                                                           CHAR(1),
  --                                                                                           ''
  --                                                                                       ),
  --                                                                                CHAR(2),
  --                                                                                ''
  --                                                                            ),
  --                                                                     CHAR(3),
  --                                                                     ''
  --                                                                 ),
  --                                                          CHAR(9),
  --                                                          ''
  --                                                      ),
  --                                               CHAR(10),
  --                                               ''
  --                                           ),
  --                                    CHAR(13),
  --                                    ''
  --                                )
  --                        )
  --                  ) 'CUENTA CREDITO',
  --             FORMAT(bd.CreditDate, 'dd/MM/yyyy') 'FECHA',
  --             bd.Amount 'MONTO',
  --             bd.Reference 'REFERENCIA',
  --             RTRIM(LTRIM(REPLACE(
  --                                    REPLACE(
  --                                               REPLACE(
  --                                                          REPLACE(
  --                                                                     REPLACE(
  --                                                                                REPLACE(
  --                                                                                           REPLACE(
  --                                                                                                      RTRIM(LTRIM(bd.AccountName)),
  --                                                                                                      ',',
  --                                                                                                      ''
  --                                                                                                  ),
  --                                                                                           CHAR(1),
  --                                                                                           ''
  --                                                                                       ),
  --                                                                                CHAR(2),
  --                                                                                ''
  --                                                                            ),
  --                                                                     CHAR(3),
  --                                                                     ''
  --                                                                 ),
  --                                                          CHAR(9),
  --                                                          ''
  --                                                      ),
  --                                               CHAR(10),
  --                                               ''
  --                                           ),
  --                                    CHAR(13),
  --                                    ''
  --                                )
  --                        )
  --                  ) 'BENEFICIARIO',
  --             ctt.TransactionType 'TIPO DE TRANSACCION',
  --             cc.NumISO 'MONEDA ACH',
  --             db.ACHCode 'CODIGO BANCO ACH',
  --             cat.Description 'TIPO DE CUENTA OTRO BANCO',
  --             IIF(cco.IdCatConceptCOD = 1,
  --                 cco.Concept,
  --                 CONCAT(cco.Concept, ' ', bd.GuideSerie, bd.GuideNumber, ' Ref ', CAST(bd.BatchCODId AS VARCHAR(300)))) 'CONCEPTO',
  --             bd.Password 'CONTRASEÑA',
  --             CONCAT(bd.GuideSerie, bd.GuideNumber) 'GUIA',
  --             bd.BatchCODId 'LOTE',
  --             CONCAT(do.Sender_FirstName, ' ', do.Sender_LastName) 'NOMBRE CLIENTE',
  --             ISNULL(
  --                       RTRIM(LTRIM(REPLACE(
  --                                              REPLACE(
  --                                                         REPLACE(
  --                                                                    REPLACE(
  --                                                                               REPLACE(
  --                                                                                          REPLACE(
  --                                                                                                     REPLACE(
  --                                                                                                                RTRIM(LTRIM(bdc.AccountName)),
  --                                                                                                                ',',
  --                                                                                                                ''
  --                                                                                                            ),
  --                                                                                                     CHAR(1),
  --                                                                                                     ''
  --                                                                                                 ),
  --                                                                                          CHAR(2),
  --                                                                                          ''
  --                                                                                      ),
  --                                                                               CHAR(3),
  --                                                                               ''
  --                                                                           ),
  --                                                                    CHAR(9),
  --                                                                    ''
  --                                                                ),
  --                                                         CHAR(10),
  --                                                         ''
  --                                                     ),
  --                                              CHAR(13),
  --                                              ''
  --                                          )
  --                                  )
  --                            ),
  --                       ''
  --                   ) 'NOMBRE CUENTA CLIENTE',
  --             ISNULL(invh.inv_SAPDocEntry, 0) 'DOCUMENTO EN SAP (DocEntry)',
  --             ISNULL(invh.inv_serieFEL, '') 'SERIE FEL',
  --             ISNULL(invh.inv_numberFEL, '') 'NÚMERO FEL',
  --             ISNULL(invh.inv_certificationFEL, '') 'CERTIFIACDO FEL'
  --      FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
  --          LEFT JOIN DeliveryBackOffice.dbo.ProcessedGuideCOD PGD
  --              ON PGD.GuideSerie = bd.GuideSerie
  --                 AND PGD.GuideNumber = bd.GuideNumber
  --                 AND PGD.RowStatus = 1
  --          LEFT JOIN DeliveryBackOffice.dbo.CatDebitAccountCOD cda
  --              ON cda.IdCatDebitAccountCOD = bd.CatDebitAccountCODId
  --                 AND cda.BankId = @IdBank
  --                 AND cda.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.CatTransactionTypeCOD ctt
  --              ON ctt.IdCatTransactionTypeCOD = bd.CatTransactionTypeCODId
  --                 AND ctt.BankId = @IdBank
  --                 AND ctt.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD cc
  --              ON cc.IdCatCurrencyCOD = bd.CatCurrencyCODId
  --                 AND cc.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank db
  --              ON db.Id_bank = bd.BankId
  --                 AND db.Id_status = @EnabledRow
  --                 AND db.Id_country = @IdCountry
  --          LEFT JOIN DeliveryBackOffice.dbo.CatAccountTypeCOD cat
  --              ON cat.IdCatAccountTypeCOD = bd.CatAccountTypeCODId
  --                 AND cat.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.CatConceptCOD cco
  --              ON cco.IdCatConceptCOD = bd.CatConceptCODId
  --                 AND cco.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder do
  --              ON bd.GuideSerie = do.Guide_Serie
  --                 AND bd.GuideNumber = do.Guide_Number
  --          LEFT JOIN DeliveryBackOffice.dbo.BatchDetailCOD bdc
  --              ON bdc.GuideSerie = bd.GuideSerie
  --                 AND bdc.GuideNumber = bd.GuideNumber
  --                 AND bdc.BankId <> 31
  --          LEFT JOIN
  --          (
  --              SELECT MIN(fac.inv_SAPDocEntry) inv_SAPDocEntry,
  --                     MIN(fac.inv_serieFEL) inv_serieFEL,
  --                     MIN(fac.inv_numberFEL) inv_numberFEL,
  --                     MIN(fac.inv_certificationFEL) inv_certificationFEL,
  --                     invd.dti_fk_orderSerie dti_fk_orderSerie,
  --                     invd.dti_fk_orderNumber dti_fk_orderNumber
  --              FROM DeliveryBackOffice.dbo.invoiceDetail invd
  --                  JOIN DeliveryBackOffice.dbo.invoiceHeader fac
  --                      ON fac.inv_pk_id = invd.dti_fk_header
  --                         AND fac.inv_descriptionFEL = 'PROCESO REALIZADO'
  --                         AND fac.inv_invoiceOfCreditNote IS NOT NULL
  --                         AND fac.inv_creditNote IS NULL
  --              GROUP BY invd.dti_fk_orderSerie,
  --                       invd.dti_fk_orderNumber
  --          ) invh
  --              ON invh.dti_fk_orderSerie = bd.GuideSerie
  --                 AND invh.dti_fk_orderNumber = bd.GuideNumber
  --      WHERE PGD.RowStatus = 1
  --            AND
  --          --bd.BatchCODId = @BatchCODId
  --          --AND 
  --          bd.Excluded = @Excluded
  --            AND bd.CatConceptCODId = @CatConceptCODId
  --            AND ISNULL(bd.CommissionNotified, 0) = 0
  --            AND FORMAT(bd.CreditDate, 'dd/MM/yyyy') = FORMAT(GETDATE(), 'dd/MM/yyyy')
  --            --AND ISNULL(bd.CODBatch,'TRUE') = 'TRUE'
  --      ORDER BY bd.CreditDate DESC;
  --  END;
  --  --============================= FORMATO BAC ENVIOS COLLECT INICIO ====================================
  --  --====================================================================================================
  --  -- FORMATO BAC ENVIOS COLLECT
  --  IF @IdBank = 31
  --     AND @BatchCODId = -1
  --     AND
  --     (
  --         @CatConceptCODId = 3
  --         OR @CatConceptCODId = 4
  --     )
  --  BEGIN
  --      SELECT REPLACE(
  --                        REPLACE(
  --                                   REPLACE(
  --                                              REPLACE(
  --                                                         REPLACE(
  --                                                                    REPLACE(
  --                                                                               REPLACE(
  --                                                                                          REPLACE(
  --                                                                                                     cda.AccountNumber,
  --                                                                                                     ' ',
  --                                                                                                     ''
  --                                                                                                 ),
  --                                                                                          '-',
  --                                                                                          ''
  --                                                                                      ),
  --                                                                               CHAR(1),
  --                                                                               ''
  --                                                                           ),
  --                                                                    CHAR(2),
  --                                                                    ''
  --                                                                ),
  --                                                         CHAR(3),
  --                                                         ''
  --                                                     ),
  --                                              CHAR(9),
  --                                              ''
  --                                          ),
  --                                   CHAR(10),
  --                                   ''
  --                               ),
  --                        CHAR(13),
  --                        ''
  --                    ) 'CUENTA DEBITO',
  --             RTRIM(LTRIM(REPLACE(
  --                                    REPLACE(
  --                                               REPLACE(
  --                                                          REPLACE(
  --                                                                     REPLACE(
  --                                                                                REPLACE(
  --                                                                                           RTRIM(LTRIM(bd.AccountNumber)),
  --                                                                                           CHAR(1),
  --                                                                                           ''
  --                                                                                       ),
  --                                                                                CHAR(2),
  --                                                                                ''
  --                                                                            ),
  --                                                                     CHAR(3),
  --                                                                     ''
  --                                                                 ),
  --                                                          CHAR(9),
  --                                                          ''
  --                                                      ),
  --                                               CHAR(10),
  --                                               ''
  --                                           ),
  --                                    CHAR(13),
  --                                    ''
  --                                )
  --                        )
  --                  ) 'CUENTA CREDITO',
  --             FORMAT(MAX(bd.CreditDate), 'dd/MM/yyyy') 'FECHA',
  --             SUM(Amount) 'MONTO',
  --             MAX(Reference) 'REFERENCIA',
  --             RTRIM(LTRIM(REPLACE(
  --                                    REPLACE(
  --                                               REPLACE(
  --                                                          REPLACE(
  --                                                                     REPLACE(
  --                                                                                REPLACE(
  --                                                                                           REPLACE(
  --                                                                                                      RTRIM(LTRIM(bd.AccountName)),
  --                                                                                                      ',',
  --                                                                                                      ''
  --                                                                                                  ),
  --                                                                                           CHAR(1),
  --                                                                                           ''
  --                                                                                       ),
  --                                                                                CHAR(2),
  --                                                                                ''
  --                                                                            ),
  --                                                                     CHAR(3),
  --                                                                     ''
  --                                                                 ),
  --                                                          CHAR(9),
  --                                                          ''
  --                                                      ),
  --                                               CHAR(10),
  --                                               ''
  --                                           ),
  --                                    CHAR(13),
  --                                    ''
  --                                )
  --                        )
  --                  ) 'BENEFICIARIO',
  --             ctt.TransactionType 'TIPO DE TRANSACCION',
  --             cc.NumISO 'MONEDA ACH',
  --             db.ACHCode 'CODIGO BANCO ACH',
  --             cat.Description 'TIPO DE CUENTA OTRO BANCO',
  --             cco.Concept 'CONCEPTO',
  --             Password 'CONTRASEÑA'
  --      FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
  --          LEFT JOIN DeliveryBackOffice.dbo.ProcessedGuideCOD PGD
  --              ON PGD.GuideSerie = bd.GuideSerie
  --                 AND PGD.GuideNumber = bd.GuideNumber
  --                 AND PGD.RowStatus = 1
  --          LEFT JOIN DeliveryBackOffice.dbo.CatDebitAccountCOD cda
  --              ON cda.IdCatDebitAccountCOD = bd.CatDebitAccountCODId
  --                 AND cda.BankId = @IdBank
  --                 AND cda.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.CatTransactionTypeCOD ctt
  --              ON ctt.IdCatTransactionTypeCOD = bd.CatTransactionTypeCODId
  --                 AND ctt.BankId = @IdBank
  --                 AND ctt.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD cc
  --              ON cc.IdCatCurrencyCOD = bd.CatCurrencyCODId
  --                 AND cc.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank db
  --              ON db.Id_bank = bd.BankId
  --                 AND db.Id_status = @EnabledRow
  --                 AND db.Id_country = @IdCountry
  --          LEFT JOIN DeliveryBackOffice.dbo.CatAccountTypeCOD cat
  --              ON cat.IdCatAccountTypeCOD = bd.CatAccountTypeCODId
  --                 AND cat.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.CatConceptCOD cco
  --              ON cco.IdCatConceptCOD = bd.CatConceptCODId
  --                 AND cco.RowStatus = @EnabledRow
  --      WHERE PGD.RowStatus = 1
  --            AND bd.Excluded = @Excluded
  --            AND bd.CatConceptCODId = @CatConceptCODId
  --            AND ISNULL(bd.CommissionNotified, 0) = 0
  --            AND FORMAT(bd.CreditDate, 'dd/MM/yyyy') = FORMAT(GETDATE(), 'dd/MM/yyyy')
  --            --AND bd.CollectBatch = 'TRUE'
  --      GROUP BY cda.AccountNumber,
  --               bd.AccountNumber,
  --               bd.AccountName,
  --               ctt.TransactionType,
  --               cc.NumISO,
  --               db.ACHCode,
  --               cat.Description,
  --               cco.Concept,
  --               Password;
  --  END;
  --  --FORMATO BAC DETALLE INTERNO -ENVIOS COLLECT
  --  IF @IdBank = 31
  --     AND @BatchCODId = 0
  --     AND
  --     (
  --         @CatConceptCODId = 3
  --         OR @CatConceptCODId = 4
  --     )
  --  BEGIN
  --      IF @CatConceptCODId = 3
  --      BEGIN
  --          -- Se obtiene el siguiente Id de Collect
  --          SET @CollectId = NEXT VALUE FOR DeliveryBackOffice.dbo.COD_CollectId;

  --          -- Se guarda el Id de comisión y fecha en BatchDetailCOD de los servicios que se guardaran en el archivo
  --          UPDATE DeliveryBackOffice.dbo.BatchDetailCOD
  --          SET CollectId = @CollectId,
  --              CollectDate = GETDATE()
  --          WHERE IdBatchDetailCOD IN
  --                (
  --                    SELECT bd.IdBatchDetailCOD
  --                    FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
  --                    WHERE
  --                        --bd.BatchCODId = @BatchCODId
  --                        --AND 
  --                        bd.Excluded = @Excluded
  --                        AND bd.CatConceptCODId = @CatConceptCODId
  --                        AND ISNULL(bd.CommissionNotified, 0) = 0
  --                        AND FORMAT(bd.CreditDate, 'dd/MM/yyyy') = FORMAT(GETDATE(), 'dd/MM/yyyy')
  --                        --AND bd.CollectBatch = 'TRUE'
  --                );
  --      END;
  --      ELSE IF @CatConceptCODId = 4
  --      BEGIN
  --          -- Se obtiene el siguiente Id de RECOLECCIÓN
  --          SET @RecolectionId = NEXT VALUE FOR DeliveryBackOffice.dbo.COD_RecolectionId;

  --          -- Se guarda el Id de comisión y fecha en BatchDetailCOD de los servicios que se guardaran en el archivo
  --          UPDATE DeliveryBackOffice.dbo.BatchDetailCOD
  --          SET RecolectionId = @RecolectionId,
  --              RecolectionDate = GETDATE()
  --          WHERE IdBatchDetailCOD IN
  --                (
  --                    SELECT bd.IdBatchDetailCOD
  --                    FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
  --                    WHERE
  --                        --bd.BatchCODId = @BatchCODId
  --                        --AND 
  --                        bd.Excluded = @Excluded
  --                        AND bd.CatConceptCODId = @CatConceptCODId
  --                        AND ISNULL(bd.CommissionNotified, 0) = 0
  --                        AND FORMAT(bd.CreditDate, 'dd/MM/yyyy') = FORMAT(GETDATE(), 'dd/MM/yyyy')
  --                        --AND bd.RecolectionBatch = 'TRUE'
  --                );
  --      END;

  --      SELECT REPLACE(
  --                        REPLACE(
  --                                   REPLACE(
  --                                              REPLACE(
  --                                                         REPLACE(
  --                                                                    REPLACE(
  --                                                                               REPLACE(
  --                                                                                          REPLACE(
  --                                                                                                     cda.AccountNumber,
  --                                                                                                     ' ',
  --                                                                                                     ''
  --                                                                                                 ),
  --                                                                                          '-',
  --                                                                                          ''
  --                                                                                      ),
  --                                                                               CHAR(1),
  --                                                                               ''
  --                                                                           ),
  --                                                                    CHAR(2),
  --                                                                    ''
  --                                                                ),
  --                                                         CHAR(3),
  --                                                         ''
  --                                                     ),
  --                                              CHAR(9),
  --                                              ''
  --                                          ),
  --                                   CHAR(10),
  --                                   ''
  --                               ),
  --                        CHAR(13),
  --                        ''
  --                    ) 'CUENTA DEBITO',
  --             RTRIM(LTRIM(REPLACE(
  --                                    REPLACE(
  --                                               REPLACE(
  --                                                          REPLACE(
  --                                                                     REPLACE(
  --                                                                                REPLACE(
  --                                                                                           RTRIM(LTRIM(bd.AccountNumber)),
  --                                                                                           CHAR(1),
  --                                                                                           ''
  --                                                                                       ),
  --                                                                                CHAR(2),
  --                                                                                ''
  --                                                                            ),
  --                                                                     CHAR(3),
  --                                                                     ''
  --                                                                 ),
  --                                                          CHAR(9),
  --                                                          ''
  --                                                      ),
  --                                               CHAR(10),
  --                                               ''
  --                                           ),
  --                                    CHAR(13),
  --                                    ''
  --                                )
  --                        )
  --                  ) 'CUENTA CREDITO',
  --             FORMAT(bd.CreditDate, 'dd/MM/yyyy') 'FECHA',
  --             bd.Amount 'MONTO',
  --             CASE
  --                 WHEN @CatConceptCODId = 3 THEN
  --                     CONCAT(
  --                               'COLLECT ',
  --                               CAST(bd.GuideNumber AS VARCHAR(20)),
  --                               ' Ref ',
  --                               CAST(bd.CollectId AS VARCHAR(10))
  --                           )
  --                 WHEN @CatConceptCODId = 4 THEN
  --                     CONCAT(
  --                               'RECOLECCION ',
  --                               CAST(bd.GuideNumber AS VARCHAR(20)),
  --                               ' Ref ',
  --                               CAST(bd.RecolectionId AS VARCHAR(10))
  --                           )
  --             END 'REFERENCIA',
  --             RTRIM(LTRIM(REPLACE(
  --                                    REPLACE(
  --                                               REPLACE(
  --                                                          REPLACE(
  --                                                                     REPLACE(
  --                                                                                REPLACE(
  --                                                                                           REPLACE(
  --                                                                                                      RTRIM(LTRIM(bd.AccountName)),
  --                                                                                                      ',',
  --                                                                                                      ''
  --                                                                                                  ),
  --                                                                                           CHAR(1),
  --                                                                                           ''
  --                                                                                       ),
  --                                                                                CHAR(2),
  --                                                                                ''
  --                                                                            ),
  --                                                                     CHAR(3),
  --                                                                     ''
  --                                                                 ),
  --                                                          CHAR(9),
  --                                                          ''
  --                                                      ),
  --                                               CHAR(10),
  --                                               ''
  --                                           ),
  --                                    CHAR(13),
  --                                    ''
  --                                )
  --                        )
  --                  ) 'BENEFICIARIO',
  --             ctt.TransactionType 'TIPO DE TRANSACCION',
  --             cc.NumISO 'MONEDA ACH',
  --             db.ACHCode 'CODIGO BANCO ACH',
  --             cat.Description 'TIPO DE CUENTA OTRO BANCO',
  --             IIF(cco.IdCatConceptCOD = 1,
  --                 cco.Concept,
  --                 CONCAT(cco.Concept, ' ', bd.GuideSerie, bd.GuideNumber, ' Ref ', CAST(bd.BatchCODId AS VARCHAR(300)))) 'CONCEPTO',
  --             bd.Password 'CONTRASEÑA',
  --             CONCAT(bd.GuideSerie, bd.GuideNumber) 'GUIA',
  --             CASE
  --                 WHEN @CatConceptCODId = 3 THEN
  --                     bd.CollectId
  --                 WHEN @CatConceptCODId = 4 THEN
  --                     bd.RecolectionId
  --             END 'LOTE',
  --             CONCAT(do.Sender_FirstName, ' ', do.Sender_LastName) 'NOMBRE CLIENTE',
  --             ISNULL(
  --                       RTRIM(LTRIM(REPLACE(
  --                                              REPLACE(
  --                                                         REPLACE(
  --                                                                    REPLACE(
  --                                                                               REPLACE(
  --                                                                                          REPLACE(
  --                                                                                                     REPLACE(
  --                                                                                                                RTRIM(LTRIM(bdc.AccountName)),
  --                                                                                                                ',',
  --                                                                                                                ''
  --                                                                                                            ),
  --                                                                                                     CHAR(1),
  --                                                                                                     ''
  --                                                                                                 ),
  --                                                                                          CHAR(2),
  --                                                                                          ''
  --                                                                                      ),
  --                                                                               CHAR(3),
  --                                                                               ''
  --                                                                           ),
  --                                                                    CHAR(9),
  --                                                                    ''
  --                                                                ),
  --                                                         CHAR(10),
  --                                                         ''
  --                                                     ),
  --                                              CHAR(13),
  --                                              ''
  --                                          )
  --                                  )
  --                            ),
  --                       ''
  --                   ) 'NOMBRE CUENTA CLIENTE',
  --             ISNULL(invh.inv_SAPDocEntry, 0) 'DOCUMENTO EN SAP (DocEntry)',
  --             ISNULL(invh.inv_serieFEL, '') 'SERIE FEL',
  --             ISNULL(invh.inv_numberFEL, '') 'NÚMERO FEL',
  --             ISNULL(invh.inv_certificationFEL, '') 'CERTIFIACDO FEL'
  --      FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
  --          LEFT JOIN DeliveryBackOffice.dbo.ProcessedGuideCOD PGD
  --              ON PGD.GuideSerie = bd.GuideSerie
  --                 AND PGD.GuideNumber = bd.GuideNumber
  --                 AND PGD.RowStatus = 1
  --          LEFT JOIN DeliveryBackOffice.dbo.CatDebitAccountCOD cda
  --              ON cda.IdCatDebitAccountCOD = bd.CatDebitAccountCODId
  --                 AND cda.BankId = @IdBank
  --                 AND cda.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.CatTransactionTypeCOD ctt
  --              ON ctt.IdCatTransactionTypeCOD = bd.CatTransactionTypeCODId
  --                 AND ctt.BankId = @IdBank
  --                 AND ctt.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD cc
  --              ON cc.IdCatCurrencyCOD = bd.CatCurrencyCODId
  --                 AND cc.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank db
  --              ON db.Id_bank = bd.BankId
  --                 AND db.Id_status = @EnabledRow
  --                 AND db.Id_country = @IdCountry
  --          LEFT JOIN DeliveryBackOffice.dbo.CatAccountTypeCOD cat
  --              ON cat.IdCatAccountTypeCOD = bd.CatAccountTypeCODId
  --                 AND cat.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.CatConceptCOD cco
  --              ON cco.IdCatConceptCOD = bd.CatConceptCODId
  --                 AND cco.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder do
  --              ON bd.GuideSerie = do.Guide_Serie
  --                 AND bd.GuideNumber = do.Guide_Number
  --          LEFT JOIN DeliveryBackOffice.dbo.BatchDetailCOD bdc
  --              ON bdc.GuideSerie = bd.GuideSerie
  --                 AND bdc.GuideNumber = bd.GuideNumber
  --                 AND bdc.BankId <> 31
  --          LEFT JOIN
  --          (
  --              SELECT MIN(fac.inv_SAPDocEntry) inv_SAPDocEntry,
  --                     MIN(fac.inv_serieFEL) inv_serieFEL,
  --                     MIN(fac.inv_numberFEL) inv_numberFEL,
  --                     MIN(fac.inv_certificationFEL) inv_certificationFEL,
  --                     invd.dti_fk_orderSerie dti_fk_orderSerie,
  --                     invd.dti_fk_orderNumber dti_fk_orderNumber
  --              FROM DeliveryBackOffice.dbo.invoiceDetail invd
  --                  JOIN DeliveryBackOffice.dbo.invoiceHeader fac
  --                      ON fac.inv_pk_id = invd.dti_fk_header
  --                         AND fac.inv_descriptionFEL = 'PROCESO REALIZADO'
  --                         AND fac.inv_invoiceOfCreditNote IS NOT NULL
  --                         AND fac.inv_creditNote IS NULL
  --              GROUP BY invd.dti_fk_orderSerie,
  --                       invd.dti_fk_orderNumber
  --          ) invh
  --              ON invh.dti_fk_orderSerie = bd.GuideSerie
  --                 AND invh.dti_fk_orderNumber = bd.GuideNumber
  --      WHERE PGD.RowStatus = 1
  --            AND
  --          --bd.BatchCODId = @BatchCODId
  --          --AND 
  --          bd.Excluded = @Excluded
  --            AND bd.CatConceptCODId = @CatConceptCODId
  --            AND ISNULL(bd.CommissionNotified, 0) = 0
  --            AND FORMAT(bd.CreditDate, 'dd/MM/yyyy') = FORMAT(GETDATE(), 'dd/MM/yyyy')
  --            --AND
  --            --(
  --            --    bd.CollectBatch = 'TRUE'
  --            --    OR bd.RecolectionBatch = 'TRUE'
  --            --)
  --      ORDER BY bd.CreditDate DESC;
  --  END;
  --  --============================= FORMATO BAC ENVIOS COLLECT FIN =======================================
  --  --====================================================================================================

  --  --FORMATO BAC NORMAL
  --  IF @IdBank = 31
  --     AND @CatConceptCODId = 2
  --  BEGIN
  --      -------DETALLADO
  --      SELECT REPLACE(
  --                        REPLACE(
  --                                   REPLACE(
  --                                              REPLACE(
  --                                                         REPLACE(
  --                                                                    REPLACE(
  --                                                                               REPLACE(
  --                                                                                          REPLACE(
  --                                                                                                     cda.AccountNumber,
  --                                                                                                     ' ',
  --                                                                                                     ''
  --                                                                                                 ),
  --                                                                                          '-',
  --                                                                                          ''
  --                                                                                      ),
  --                                                                               CHAR(1),
  --                                                                               ''
  --                                                                           ),
  --                                                                    CHAR(2),
  --                                                                    ''
  --                                                                ),
  --                                                         CHAR(3),
  --                                                         ''
  --                                                     ),
  --                                              CHAR(9),
  --                                              ''
  --                                          ),
  --                                   CHAR(10),
  --                                   ''
  --                               ),
  --                        CHAR(13),
  --                        ''
  --                    ) 'CUENTA DEBITO',
  --             RTRIM(LTRIM(REPLACE(
  --                                    REPLACE(
  --                                               REPLACE(
  --                                                          REPLACE(
  --                                                                     REPLACE(
  --                                                                                REPLACE(
  --                                                                                           RTRIM(LTRIM(bd.AccountNumber)),
  --                                                                                           CHAR(1),
  --                                                                                           ''
  --                                                                                       ),
  --                                                                                CHAR(2),
  --                                                                                ''
  --                                                                            ),
  --                                                                     CHAR(3),
  --                                                                     ''
  --                                                                 ),
  --                                                          CHAR(9),
  --                                                          ''
  --                                                      ),
  --                                               CHAR(10),
  --                                               ''
  --                                           ),
  --                                    CHAR(13),
  --                                    ''
  --                                )
  --                        )
  --                  ) 'CUENTA CREDITO',
  --             FORMAT(bd.CreditDate, 'dd/MM/yyyy') 'FECHA',
  --             Amount 'MONTO',
  --             Reference 'REFERENCIA',
  --             RTRIM(LTRIM(REPLACE(
  --                                    REPLACE(
  --                                               REPLACE(
  --                                                          REPLACE(
  --                                                                     REPLACE(
  --                                                                                REPLACE(
  --                                                                                           REPLACE(
  --                                                                                                      RTRIM(LTRIM(bd.AccountName)),
  --                                                                                                      ',',
  --                                                                                                      ''
  --                                                                                                  ),
  --                                                                                           CHAR(1),
  --                                                                                           ''
  --                                                                                       ),
  --                                                                                CHAR(2),
  --                                                                                ''
  --                                                                            ),
  --                                                                     CHAR(3),
  --                                                                     ''
  --                                                                 ),
  --                                                          CHAR(9),
  --                                                          ''
  --                                                      ),
  --                                               CHAR(10),
  --                                               ''
  --                                           ),
  --                                    CHAR(13),
  --                                    ''
  --                                )
  --                        )
  --                  ) 'BENEFICIARIO',
  --             ctt.TransactionType 'TIPO DE TRANSACCION',
  --             cc.NumISO 'MONEDA ACH',
  --             db.ACHCode 'CODIGO BANCO ACH',
  --             cat.Description 'TIPO DE CUENTA OTRO BANCO',
  --             IIF(cco.IdCatConceptCOD = 1,
  --                 cco.Concept,
  --                 CONCAT(cco.Concept, ' ', bd.GuideSerie, bd.GuideNumber, ' Ref ', CAST(bd.BatchCODId AS VARCHAR(300)))) 'CONCEPTO',
  --             Password 'CONTRASEÑA'
  --      FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
  --          LEFT JOIN DeliveryBackOffice.dbo.CatDebitAccountCOD cda
  --              ON cda.IdCatDebitAccountCOD = bd.CatDebitAccountCODId
  --                 AND cda.BankId = @IdBank
  --                 AND cda.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.CatTransactionTypeCOD ctt
  --              ON ctt.IdCatTransactionTypeCOD = bd.CatTransactionTypeCODId
  --                 AND ctt.BankId = @IdBank
  --                 AND ctt.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD cc
  --              ON cc.IdCatCurrencyCOD = bd.CatCurrencyCODId
  --                 AND cc.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank db
  --              ON db.Id_bank = bd.BankId
  --                 AND db.Id_status = @EnabledRow
  --                 AND db.Id_country = @IdCountry
  --          LEFT JOIN DeliveryBackOffice.dbo.CatAccountTypeCOD cat
  --              ON cat.IdCatAccountTypeCOD = bd.CatAccountTypeCODId
  --                 AND cat.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.CatConceptCOD cco
  --              ON cco.IdCatConceptCOD = bd.CatConceptCODId
  --                 AND cco.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.ProcessedGuideCOD pgd
  --              ON bd.GuideSerie = pgd.GuideSerie
  --                 AND bd.GuideNumber = pgd.GuideNumber
  --                 AND bd.BatchCODId = pgd.BatchCODId
  --          LEFT JOIN DeliveryBackOffice.dbo.Customer cust
  --              ON pgd.CustomerId = cust.IdCustomer
  --                 AND cust.RowSatus = 1
  --      WHERE pgd.RowStatus = 1
  --            AND bd.BatchCODId = @BatchCODId
  --            AND bd.Excluded = @Excluded
  --            AND bd.CatConceptCODId = @CatConceptCODDeposit
  --            AND ISNULL(cust.CatBatchTypeCODId, @BatchTypeCOD_DET) = @BatchTypeCOD_DET
  --            --AND ISNULL(bd.CODBatch,'TRUE') = 'TRUE'
  --      UNION
  --      --------ACUMULADO
  --      SELECT REPLACE(
  --                        REPLACE(
  --                                   REPLACE(
  --                                              REPLACE(
  --                                                         REPLACE(
  --                                                                    REPLACE(
  --                                                                               REPLACE(
  --                                                                                          REPLACE(
  --                                                                                                     cda.AccountNumber,
  --                                                                                                     ' ',
  --                                                                                                     ''
  --                                                                                                 ),
  --                                                                                          '-',
  --                                                                                          ''
  --                                                                                      ),
  --                                                                               CHAR(1),
  --                                                                               ''
  --                                                                           ),
  --                                                                    CHAR(2),
  --                                                                    ''
  --                                                                ),
  --                                                         CHAR(3),
  --                                                         ''
  --                                                     ),
  --                                              CHAR(9),
  --                                              ''
  --                                          ),
  --                                   CHAR(10),
  --                                   ''
  --                               ),
  --                        CHAR(13),
  --                        ''
  --                    ) 'CUENTA DEBITO',
  --             RTRIM(LTRIM(REPLACE(
  --                                    REPLACE(
  --                                               REPLACE(
  --                                                          REPLACE(
  --                                                                     REPLACE(
  --                                                                                REPLACE(
  --                                                                                           RTRIM(LTRIM(bd.AccountNumber)),
  --                                                                                           CHAR(1),
  --                                                                                           ''
  --                                                                                       ),
  --                                                                                CHAR(2),
  --                                                                                ''
  --                                                                            ),
  --                                                                     CHAR(3),
  --                                                                     ''
  --                                                                 ),
  --                                                          CHAR(9),
  --                                                          ''
  --                                                      ),
  --                                               CHAR(10),
  --                                               ''
  --                                           ),
  --                                    CHAR(13),
  --                                    ''
  --                                )
  --                        )
  --                  ) 'CUENTA CREDITO',
  --             MAX(FORMAT(bd.CreditDate, 'dd/MM/yyyy')) 'FECHA',
  --             SUM(bd.Amount) 'MONTO',
  --             MAX(Reference) 'REFERENCIA',
  --             RTRIM(LTRIM(REPLACE(
  --                                    REPLACE(
  --                                               REPLACE(
  --                                                          REPLACE(
  --                                                                     REPLACE(
  --                                                                                REPLACE(
  --                                                                                           REPLACE(
  --                                                                                                      RTRIM(LTRIM(bd.AccountName)),
  --                                                                                                      ',',
  --                                                                                                      ''
  --                                                                                                  ),
  --                                                                                           CHAR(1),
  --                                                                                           ''
  --                                                                                       ),
  --                                                                                CHAR(2),
  --                                                                                ''
  --                                                                            ),
  --                                                                     CHAR(3),
  --                                                                     ''
  --                                                                 ),
  --                                                          CHAR(9),
  --                                                          ''
  --                                                      ),
  --                                               CHAR(10),
  --                                               ''
  --                                           ),
  --                                    CHAR(13),
  --                                    ''
  --                                )
  --                        )
  --                  ) 'BENEFICIARIO',
  --             ctt.TransactionType 'TIPO DE TRANSACCION',
  --             cc.NumISO 'MONEDA ACH',
  --             db.ACHCode 'CODIGO BANCO ACH',
  --             cat.Description 'TIPO DE CUENTA OTRO BANCO',
  --             MAX(IIF(cco.IdCatConceptCOD = 1,
  --                     cco.Concept,
  --                     CONCAT(
  --                               cco.Concept,
  --                               ' ',
  --                               bd.GuideSerie,
  --                               bd.GuideNumber,
  --                               ' Ref ',
  --                               CAST(bd.BatchCODId AS VARCHAR(300))
  --                           ))
  --                ) 'CONCEPTO',
  --             Password 'CONTRASEÑA'
  --      FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
  --          LEFT JOIN DeliveryBackOffice.dbo.CatDebitAccountCOD cda
  --              ON cda.IdCatDebitAccountCOD = bd.CatDebitAccountCODId
  --                 AND cda.BankId = @IdBank
  --                 AND cda.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.CatTransactionTypeCOD ctt
  --              ON ctt.IdCatTransactionTypeCOD = bd.CatTransactionTypeCODId
  --                 AND ctt.BankId = @IdBank
  --                 AND ctt.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD cc
  --              ON cc.IdCatCurrencyCOD = bd.CatCurrencyCODId
  --                 AND cc.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank db
  --              ON db.Id_bank = bd.BankId
  --                 AND db.Id_status = @EnabledRow
  --                 AND db.Id_country = @IdCountry
  --          LEFT JOIN DeliveryBackOffice.dbo.CatAccountTypeCOD cat
  --              ON cat.IdCatAccountTypeCOD = bd.CatAccountTypeCODId
  --                 AND cat.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.CatConceptCOD cco
  --              ON cco.IdCatConceptCOD = bd.CatConceptCODId
  --                 AND cco.RowStatus = @EnabledRow
  --          LEFT JOIN DeliveryBackOffice.dbo.ProcessedGuideCOD pgd
  --              ON bd.GuideSerie = pgd.GuideSerie
  --                 AND bd.GuideNumber = pgd.GuideNumber
  --                 AND bd.BatchCODId = pgd.BatchCODId
  --          LEFT JOIN DeliveryBackOffice.dbo.Customer cust
  --              ON pgd.CustomerId = cust.IdCustomer
  --                 AND cust.RowSatus = 1
  --      WHERE pgd.RowStatus = 1
  --            AND bd.BatchCODId = @BatchCODId
  --            AND bd.Excluded = @Excluded
  --            AND bd.CatConceptCODId = @CatConceptCODDeposit
  --            AND cust.CatBatchTypeCODId = @BatchTypeCOD_AC
  --            --AND ISNULL(bd.CODBatch,'TRUE') = 'TRUE'
  --      GROUP BY pgd.CustomerId,
  --               cda.AccountNumber,
  --               bd.AccountNumber,
  --               bd.AccountName,
  --               ctt.TransactionType,
  --               cc.NumISO,
  --               db.ACHCode,
  --               cat.Description,
  --               Password;

  --  END;

  --  -- FORMATO BANRURAL	
  --  IF @IdBank = 5
  --  BEGIN
  --      ------DETATALLADO
  --      SELECT btd.Reference 'REFERENCIA',
  --             RTRIM(LTRIM(REPLACE(
  --                                    REPLACE(
  --                                               REPLACE(
  --                                                          REPLACE(
  --                                                                     REPLACE(
  --                                                                                REPLACE(
  --                                                                                           RTRIM(LTRIM(btd.AccountNumber)),
  --                                                                                           CHAR(1),
  --                                                                                           ''
  --                                                                                       ),
  --                                                                                CHAR(2),
  --                                                                                ''
  --                                                                            ),
  --                                                                     CHAR(3),
  --                                                                     ''
  --                                                                 ),
  --                                                          CHAR(9),
  --                                                          ''
  --                                                      ),
  --                                               CHAR(10),
  --                                               ''
  --                                           ),
  --                                    CHAR(13),
  --                                    ''
  --                                )
  --                        )
  --                  ) 'CUENTA CREDITO',
  --             btd.Amount 'MONTO'
  --      FROM [dbo].[BatchDetailCOD] btd
	 --LEFT JOIN DeliveryBackOffice.dbo.CatConceptCOD cco
  --              ON cco.IdCatConceptCOD = bTd.CatConceptCODId
  --                 AND cco.RowStatus = 1
  --      LEFT JOIN [dbo].[BatchCOD] bt
  --          ON btd.[BatchCODId] = bt.[IdBatchCOD]
  --      LEFT JOIN [dbo].[DeliveryBank] db
  --          ON db.Id_bank = bt.BankId
  --      LEFT JOIN [dbo].[DeliveryOrder] do
  --          ON btd.[GuideSerie] = do.[Guide_Serie]
  --             AND btd.[GuideNumber] = do.[Guide_Number]
  --      LEFT JOIN [dbo].VisitPointClient vp
  --          ON vp.CodeOfReference = do.Sender_ID
  --      LEFT JOIN [dbo].[Customer] cu
  --          ON ISNULL(do.[IdCustomer], vp.CustomerID) = cu.[IdCustomer]
  --      LEFT JOIN [dbo].[Township] twn
  --          ON CASE
  --                 WHEN do.[ReceiverIdTownship] IS NULL THEN
  --                 (
  --                     SELECT TOP 1
  --                            [IdTownship]
  --                     FROM [dbo].[Township]
  --                     WHERE UPPER(do.[Receiver_Town])COLLATE Latin1_General_CI_AI = UPPER([TownshipName])COLLATE Latin1_General_CI_AI
  --                 )
  --                 ELSE
  --                     do.[ReceiverIdTownship]
  --             END = twn.[IdTownship]
		--	   	  LEFT JOIN [dbo].[Township] twnSender
  --          ON CASE
  --                 WHEN do.[SenderIdTownship] IS NULL THEN
  --                 (
  --                     SELECT TOP 1
  --                            [IdTownship]
  --                     FROM [dbo].[Township]
  --                     WHERE UPPER(do.[Sender_Town])COLLATE Latin1_General_CI_AI = UPPER([TownshipName])COLLATE Latin1_General_CI_AI
  --                 )
  --                 ELSE
  --                     do.[SenderIdTownship]
  --             END = twnSender.[IdTownship]
  --      LEFT JOIN [dbo].[ProcessedGuideCOD] pg
  --          ON btd.[GuideSerie] = pg.[GuideSerie]
  --             AND btd.[GuideNumber] = pg.[GuideNumber]
  --      LEFT JOIN [dbo].[SenderReceiver] sr
  --          ON pg.CourierManId = sr.ID
  --      LEFT JOIN [dbo].[BatchDetailCOD] btc
  --          ON btc.GuideSerie = btd.GuideSerie
  --             AND btc.GuideNumber = btd.GuideNumber
  --             AND btc.CatConceptCODId = @EnabledRow
		--	     LEFT JOIN DeliveryBackOffice.dbo.Customer cust
  --              ON pg.CustomerId = cust.IdCustomer
  --                 AND cust.RowSatus = @EnabledRow
  --      WHERE 
		--btd.CatConceptCODId IN (2)
		--AND bt.RowStatus = @EnabledRow
		--AND pg.RowStatus = @EnabledRow
		--AND BTD.RowStatus = @EnabledRow
		--AND btc.RowStatus = @EnabledRow
	 --   AND btd.BatchCODId = @BatchCODId
  --      AND btd.Excluded = @Excluded
  --      AND ISNULL(cust.CatBatchTypeCODId, @BatchTypeCOD_DET) = @BatchTypeCOD_DET
  --      UNION
  --      ------ACUMULADO
  --      SELECT MAX(btd.Reference) 'REFERENCIA',
  --             RTRIM(LTRIM(REPLACE(
  --                                    REPLACE(
  --                                               REPLACE(
  --                                                          REPLACE(
  --                                                                     REPLACE(
  --                                                                                REPLACE(
  --                                                                                           RTRIM(LTRIM(btd.AccountNumber)),
  --                                                                                           CHAR(1),
  --                                                                                           ''
  --                                                                                       ),
  --                                                                                CHAR(2),
  --                                                                                ''
  --                                                                            ),
  --                                                                     CHAR(3),
  --                                                                     ''
  --                                                                 ),
  --                                                          CHAR(9),
  --                                                          ''
  --                                                      ),
  --                                               CHAR(10),
  --                                               ''
  --                                           ),
  --                                    CHAR(13),
  --                                    ''
  --                                )
  --                        )
  --                  ) 'CUENTA CREDITO',
  --             SUM(btd.Amount) 'MONTO'
  --     FROM [dbo].[BatchDetailCOD] btd
	 --LEFT JOIN DeliveryBackOffice.dbo.CatConceptCOD cco
  --              ON cco.IdCatConceptCOD = bTd.CatConceptCODId
  --                 AND cco.RowStatus = 1
  --      LEFT JOIN [dbo].[BatchCOD] bt
  --          ON btd.[BatchCODId] = bt.[IdBatchCOD]
  --      LEFT JOIN [dbo].[DeliveryBank] db
  --          ON db.Id_bank = bt.BankId
  --      LEFT JOIN [dbo].[DeliveryOrder] do
  --          ON btd.[GuideSerie] = do.[Guide_Serie]
  --             AND btd.[GuideNumber] = do.[Guide_Number]
  --      LEFT JOIN [dbo].VisitPointClient vp
  --          ON vp.CodeOfReference = do.Sender_ID
  --      LEFT JOIN [dbo].[Customer] cu
  --          ON ISNULL(do.[IdCustomer], vp.CustomerID) = cu.[IdCustomer]
  --      LEFT JOIN [dbo].[Township] twn
  --          ON CASE
  --                 WHEN do.[ReceiverIdTownship] IS NULL THEN
  --                 (
  --                     SELECT TOP 1
  --                            [IdTownship]
  --                     FROM [dbo].[Township]
  --                     WHERE UPPER(do.[Receiver_Town])COLLATE Latin1_General_CI_AI = UPPER([TownshipName])COLLATE Latin1_General_CI_AI
  --                 )
  --                 ELSE
  --                     do.[ReceiverIdTownship]
  --             END = twn.[IdTownship]
		--	   	  LEFT JOIN [dbo].[Township] twnSender
  --          ON CASE
  --                 WHEN do.[SenderIdTownship] IS NULL THEN
  --                 (
  --                     SELECT TOP 1
  --                            [IdTownship]
  --                     FROM [dbo].[Township]
  --                     WHERE UPPER(do.[Sender_Town])COLLATE Latin1_General_CI_AI = UPPER([TownshipName])COLLATE Latin1_General_CI_AI
  --                 )
  --                 ELSE
  --                     do.[SenderIdTownship]
  --             END = twnSender.[IdTownship]
  --      LEFT JOIN [dbo].[ProcessedGuideCOD] pg
  --          ON btd.[GuideSerie] = pg.[GuideSerie]
  --             AND btd.[GuideNumber] = pg.[GuideNumber]
  --      LEFT JOIN [dbo].[SenderReceiver] sr
  --          ON pg.CourierManId = sr.ID
  --      LEFT JOIN [dbo].[BatchDetailCOD] btc
  --          ON btc.GuideSerie = btd.GuideSerie
  --             AND btc.GuideNumber = btd.GuideNumber
  --             AND btc.CatConceptCODId = @EnabledRow
		--	     LEFT JOIN DeliveryBackOffice.dbo.Customer cust
  --              ON pg.CustomerId = cust.IdCustomer
  --                 AND cust.RowSatus = @EnabledRow
  --  WHERE
        
		--btd.CatConceptCODId IN (2)
		--AND bt.RowStatus = @EnabledRow
		--AND pg.RowStatus = @EnabledRow
		--AND BTD.RowStatus = @EnabledRow
		--AND btc.RowStatus = @EnabledRow
		--AND BTD.BatchCODId = @BatchCODId
  --      AND btd.Excluded = @Excluded
  --      AND cust.CatBatchTypeCODId = @BatchTypeCOD_AC
  --      GROUP BY pg.CustomerId,
  --               btd.AccountNumber;
  --  END;

    -- FORMATO BI
    IF @IdBank = 33
    BEGIN
        --------DETALLADO
    SELECT btd.CatAccountTypeCODId 'TIPO DE CUENTA',
               RTRIM(LTRIM(REPLACE(
                                      REPLACE(
                                                 REPLACE(
                                                            REPLACE(
                                                                       REPLACE(
                                                                                  REPLACE(
                                                                                             RTRIM(LTRIM(btd.AccountNumber)),
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
               RTRIM(LTRIM(REPLACE(
                                      REPLACE(
                                                 REPLACE(
                                                            REPLACE(
                                                                       REPLACE(
                                                                                  REPLACE(
                                                                                             REPLACE(
                                                                                                        RTRIM(LTRIM(btd.AccountName)),
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
               btd.Amount 'MONTO',
               IIF(cco.IdCatConceptCOD = 1,
                   cco.Concept,
                   CONCAT(cco.Concept, ' ', btd.GuideSerie, btd.GuideNumber, ' Ref ', CAST(btd.BatchCODId AS VARCHAR(300)))) 'CONCEPTO'
    FROM [dbo].[BatchDetailCOD] btd
	 LEFT JOIN DeliveryBackOffice.dbo.CatConceptCOD cco
                ON cco.IdCatConceptCOD = bTd.CatConceptCODId
                   AND cco.RowStatus = 1
        LEFT JOIN [dbo].[BatchCOD] bt
            ON btd.[BatchCODId] = bt.[IdBatchCOD]
        LEFT JOIN [dbo].[DeliveryBank] db
            ON db.Id_bank = bt.BankId
        LEFT JOIN [dbo].[DeliveryOrder] do
            ON btd.[GuideSerie] = do.[Guide_Serie]
               AND btd.[GuideNumber] = do.[Guide_Number]
        LEFT JOIN [dbo].VisitPointClient vp
            ON vp.CodeOfReference = do.Sender_ID
        LEFT JOIN [dbo].[Customer] cu
            ON ISNULL(do.[IdCustomer], vp.CustomerID) = cu.[IdCustomer]
        LEFT JOIN [dbo].[Township] twn
            ON CASE
                   WHEN do.[ReceiverIdTownship] IS NULL THEN
                   (
                       SELECT TOP 1
                              [IdTownship]
                       FROM [dbo].[Township]
                       WHERE UPPER(do.[Receiver_Town])COLLATE Latin1_General_CI_AI = UPPER([TownshipName])COLLATE Latin1_General_CI_AI
                   )
                   ELSE
                       do.[ReceiverIdTownship]
               END = twn.[IdTownship]
			   	  LEFT JOIN [dbo].[Township] twnSender
            ON CASE
                   WHEN do.[SenderIdTownship] IS NULL THEN
                   (
                       SELECT TOP 1
                              [IdTownship]
                       FROM [dbo].[Township]
                       WHERE UPPER(do.[Sender_Town])COLLATE Latin1_General_CI_AI = UPPER([TownshipName])COLLATE Latin1_General_CI_AI
                   )
                   ELSE
                       do.[SenderIdTownship]
               END = twnSender.[IdTownship]
        LEFT JOIN [dbo].[ProcessedGuideCOD] pg
            ON btd.[GuideSerie] = pg.[GuideSerie]
               AND btd.[GuideNumber] = pg.[GuideNumber]
        LEFT JOIN [dbo].[SenderReceiver] sr
            ON pg.CourierManId = sr.ID
        LEFT JOIN [dbo].[BatchDetailCOD] btc
            ON btc.GuideSerie = btd.GuideSerie
               AND btc.GuideNumber = btd.GuideNumber
               AND btc.CatConceptCODId = @EnabledRow
			     LEFT JOIN DeliveryBackOffice.dbo.Customer cust
                ON pg.CustomerId = cust.IdCustomer
                   AND cust.RowSatus = @EnabledRow
    WHERE
        --AND db.[Id_bank] IN ( 5, 33,31,2 ) --Banrural y BI
        --CONVERT(DATE, bt.[Date]) = @Date
		--AND 
		btd.CatConceptCODId IN (2)
		AND bt.RowStatus = @EnabledRow
		AND pg.RowStatus = @EnabledRow
		AND BTD.RowStatus = @EnabledRow
		AND btc.RowStatus = @EnabledRow
	    AND btd.BatchCODId = @BatchCODId
        AND btd.Excluded = @Excluded
        AND ISNULL(cust.CatBatchTypeCODId, @BatchTypeCOD_DET) = @BatchTypeCOD_DET
       
     --   UNION
        ----------ACUMULADO
        SELECT btd.CatAccountTypeCODId 'TIPO DE CUENTA',
               RTRIM(LTRIM(REPLACE(
                                      REPLACE(
                                                 REPLACE(
                                                            REPLACE(
                                                                       REPLACE(
                                                                                  REPLACE(
                                                                                             RTRIM(LTRIM(btd.AccountNumber)),
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
               RTRIM(LTRIM(REPLACE(
                                      REPLACE(
                                                 REPLACE(
                                                            REPLACE(
                                                                       REPLACE(
                                                                                  REPLACE(
                                                                                             REPLACE(
                                                                                                        RTRIM(LTRIM(btd.AccountName)),
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
               SUM(btd.Amount) 'MONTO',
               MAX(IIF(cco.IdCatConceptCOD = 1,
                       cco.Concept,
                       CONCAT(
                                 cco.Concept,
                                 ' ',
                                 btd.GuideSerie,
                                 btd.GuideNumber,
                                 ' Ref ',
                                 CAST(btd.BatchCODId AS VARCHAR(300))
                             ))
                  ) 'CONCEPTO'
           FROM [dbo].[BatchDetailCOD] btd
	 LEFT JOIN DeliveryBackOffice.dbo.CatConceptCOD cco
                ON cco.IdCatConceptCOD = bTd.CatConceptCODId
                   AND cco.RowStatus = 1
        LEFT JOIN [dbo].[BatchCOD] bt
            ON btd.[BatchCODId] = bt.[IdBatchCOD]
        LEFT JOIN [dbo].[DeliveryBank] db
            ON db.Id_bank = bt.BankId
        LEFT JOIN [dbo].[DeliveryOrder] do
            ON btd.[GuideSerie] = do.[Guide_Serie]
               AND btd.[GuideNumber] = do.[Guide_Number]
        LEFT JOIN [dbo].VisitPointClient vp
            ON vp.CodeOfReference = do.Sender_ID
        LEFT JOIN [dbo].[Customer] cu
            ON ISNULL(do.[IdCustomer], vp.CustomerID) = cu.[IdCustomer]
        LEFT JOIN [dbo].[Township] twn
            ON CASE
                   WHEN do.[ReceiverIdTownship] IS NULL THEN
                   (
                       SELECT TOP 1
                              [IdTownship]
                       FROM [dbo].[Township]
                       WHERE UPPER(do.[Receiver_Town])COLLATE Latin1_General_CI_AI = UPPER([TownshipName])COLLATE Latin1_General_CI_AI
                   )
                   ELSE
                       do.[ReceiverIdTownship]
               END = twn.[IdTownship]
			   	  LEFT JOIN [dbo].[Township] twnSender
            ON CASE
                   WHEN do.[SenderIdTownship] IS NULL THEN
                   (
                       SELECT TOP 1
                              [IdTownship]
                       FROM [dbo].[Township]
                       WHERE UPPER(do.[Sender_Town])COLLATE Latin1_General_CI_AI = UPPER([TownshipName])COLLATE Latin1_General_CI_AI
                   )
                   ELSE
                       do.[SenderIdTownship]
               END = twnSender.[IdTownship]
        LEFT JOIN [dbo].[ProcessedGuideCOD] pg
            ON btd.[GuideSerie] = pg.[GuideSerie]
               AND btd.[GuideNumber] = pg.[GuideNumber]
        LEFT JOIN [dbo].[SenderReceiver] sr
            ON pg.CourierManId = sr.ID
        LEFT JOIN [dbo].[BatchDetailCOD] btc
            ON btc.GuideSerie = btd.GuideSerie
               AND btc.GuideNumber = btd.GuideNumber
               AND btc.CatConceptCODId = 2
			     LEFT JOIN DeliveryBackOffice.dbo.Customer cust
                ON pg.CustomerId = cust.IdCustomer
                   AND cust.RowSatus = @EnabledRow
    WHERE
        
		btd.CatConceptCODId IN (2)
		AND bt.RowStatus = @EnabledRow
		AND pg.RowStatus = @EnabledRow
		AND BTD.RowStatus = @EnabledRow
		AND btc.RowStatus = @EnabledRow
		AND 
		BTD.BatchCODId = @BatchCODId
        AND btd.Excluded = @Excluded
        AND cust.CatBatchTypeCODId = @BatchTypeCOD_AC
        
        GROUP BY pg.CustomerId,
                 btd.CatAccountTypeCODId,
                 btd.AccountNumber,
                 btd.AccountName;

    END;


	PRINT '@EnabledRow'
	PRINT @EnabledRow
	PRINT '@BatchTypeCOD_AC'
	PRINT @BatchTypeCOD_AC
	PRINT '@Excluded'
	PRINT @Excluded
	PRINT '@BatchCODId'
	PRINT @BatchCODId

	PRINT '@BatchTypeCOD_DET'
	PRINT @BatchTypeCOD_DET

    ---- FORMATO GYT
    --IF @IdBank = 3
    --BEGIN
    --    --------DETALLADO
    --    SELECT RIGHT('000'
    --                 + CAST(LTRIM(RTRIM(SUBSTRING(REPLACE(LTRIM(RTRIM(bd.AccountNumber)), '-', ''), 1, 3))) AS VARCHAR(3)), 3) AS 'Agencia',
    --           RIGHT('0000000'
    --                 + CAST(LTRIM(RTRIM(SUBSTRING(REPLACE(LTRIM(RTRIM(bd.AccountNumber)), '-', ''), 4, 7))) AS VARCHAR(7)), 7) AS 'Correlativo',
    --           RIGHT('0'
    --                 + CAST(LTRIM(RTRIM(SUBSTRING(REPLACE(LTRIM(RTRIM(bd.AccountNumber)), '-', ''), 11, 1))) AS VARCHAR(1)), 1) AS 'Digito',
    --           LEFT(IIF(cco.IdCatConceptCOD = 1,
    --                    cco.Concept,
    --                    CONCAT(
    --                              ' Ref ',
    --                              CAST(bd.BatchCODId AS VARCHAR(300)),
    --                              ' ',
    --                              cco.Concept,
    --                              ' ',
    --                              bd.GuideSerie,
    --                              bd.GuideNumber
    --                          )), 100) 'Concepto',
    --           Amount 'Valor Q.'
    --    FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
    --        LEFT JOIN DeliveryBackOffice.dbo.ProcessedGuideCOD pgd
    --            ON bd.GuideSerie = pgd.GuideSerie
    --               AND bd.GuideNumber = pgd.GuideNumber
    --               AND bd.BatchCODId = pgd.BatchCODId
    --        LEFT JOIN DeliveryBackOffice.dbo.Customer cust
    --            ON pgd.CustomerId = cust.IdCustomer
    --               AND cust.RowSatus = 1
    --        LEFT JOIN DeliveryBackOffice.dbo.CatConceptCOD cco
    --            ON cco.IdCatConceptCOD = bd.CatConceptCODId
    --               AND cco.RowStatus = @EnabledRow
    --    WHERE pgd.RowStatus = 1
    --          AND bd.BatchCODId = @BatchCODId
    --          AND bd.Excluded = @Excluded
    --          AND ISNULL(cust.CatBatchTypeCODId, @BatchTypeCOD_DET) = @BatchTypeCOD_DET
    --          --AND ISNULL(bd.CODBatch,'TRUE') = 'TRUE'
    --    UNION
    --    -----------ACUMULADO
    --    SELECT RIGHT('000'
    --                 + CAST(LTRIM(RTRIM(SUBSTRING(REPLACE(LTRIM(RTRIM(bd.AccountNumber)), '-', ''), 1, 3))) AS VARCHAR(3)), 3) AS 'Agencia',
    --           RIGHT('0000000'
    --                 + CAST(LTRIM(RTRIM(SUBSTRING(REPLACE(LTRIM(RTRIM(bd.AccountNumber)), '-', ''), 4, 7))) AS VARCHAR(7)), 7) AS 'Correlativo',
    --           RIGHT('0'
    --                 + CAST(LTRIM(RTRIM(SUBSTRING(REPLACE(LTRIM(RTRIM(bd.AccountNumber)), '-', ''), 11, 1))) AS VARCHAR(1)), 1) AS 'Digito',
    --           LEFT(MAX(IIF(cco.IdCatConceptCOD = 1,
    --                        cco.Concept,
    --                        CONCAT(' Ref ', CAST(bd.BatchCODId AS VARCHAR(300)), cco.Concept))
    --                   ), 100) 'Concepto',
    --           SUM(Amount) 'Valor Q.'
    --    FROM DeliveryBackOffice.dbo.BatchDetailCOD bd
    --        LEFT JOIN DeliveryBackOffice.dbo.ProcessedGuideCOD pgd
    --            ON bd.GuideSerie = pgd.GuideSerie
    --               AND bd.GuideNumber = pgd.GuideNumber
    --               AND bd.BatchCODId = pgd.BatchCODId
    --        LEFT JOIN DeliveryBackOffice.dbo.Customer cust
    --            ON pgd.CustomerId = cust.IdCustomer
    --               AND cust.RowSatus = 1
    --        LEFT JOIN DeliveryBackOffice.dbo.CatConceptCOD cco
    --            ON cco.IdCatConceptCOD = bd.CatConceptCODId
    --               AND cco.RowStatus = @EnabledRow
    --    WHERE pgd.RowStatus = 1
    --          AND bd.BatchCODId = @BatchCODId
    --          AND bd.Excluded = @Excluded
    --          AND cust.CatBatchTypeCODId = @BatchTypeCOD_AC
    --          --AND ISNULL(bd.CODBatch,'TRUE') = 'TRUE'
    --    GROUP BY pgd.CustomerId,
    --             bd.CatAccountTypeCODId,
    --             bd.AccountNumber,
    --             bd.AccountName,
    --             cco.IdCatConceptCOD,
    --             cco.Concept;
    --END;
END;
