/***
-- INSERCION DE VALORES INVOICEAuthorizationHeader
-- PARA FACTURACIÓN EN EL SALVADOR
***/

BEGIN TRANSACTION;
BEGIN TRY

    INSERT INTO InvoiceAuthorizationHeader(
                [Authorization],
                [StartDate],
                [EndDate],
                [RowStatus],
                [TokenCreated],
                [DateCreated])

    VALUES('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VyIjoiU1YuMDYxNDIzMDgyMjEwMjUuVEVTVEZPUlpBREVMSSIsIkNvdW50cnkiOiJTViIsIkVudiI6IjIiLCJuYmYiOjE3NDY1Njg3MDksImV4cCI6MTc0OTE2MDcwOSwiaWF0IjoxNzQ2NTY4NzA5LCJpc3MiOiJodHRwczovL3d3dy5kaWdpZmFjdC5jb20uc3YiLCJhdWQiOiJodHRwczovL3N2dGVzdC5kaWdpZmFjdC5jb20uc3Yvc3YuY29tLmFwaW51YyJ9.Eeay3djzDwTXAeCyX1Mfjd1neKCoDBJxxvImbXkj8x4',
           '2025-05-06',
           '2025-06-05',
           '1',
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