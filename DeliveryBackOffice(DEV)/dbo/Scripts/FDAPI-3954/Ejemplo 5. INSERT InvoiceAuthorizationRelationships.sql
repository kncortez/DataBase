/***
-- INSERCION DE VALORES INVOICEAuthorizationRelationships
-- PARA FACTURACIÓN EN EL SALVADOR
***/

BEGIN TRANSACTION;
BEGIN TRY

    INSERT INTO InvoiceAuthorizationRelationships(
                [CodeOfReference],
                [InvoiceAuthorizationHeaderId],
                [RowStatus],
                [TokenCreated],
                [DateCreated])

    VALUES('1378846',
           12,
           1,
           'SYS-CAZURDIA',
           GETDATE());

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

END CATCH