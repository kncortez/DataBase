/***
-- INSERCION DE VALORES EN LA TABLA DEFAULTVALUESPERCOUNTRY
***/

BEGIN TRANSACTION;
BEGIN TRY

    INSERT INTO DefaultValuesPerCountry  (IdCountry, UseMultiCountry,RowStatus,TokenCreated,DateCreated)
    VALUES('GT',1,1,'SYS-CAZURDIA',GETDATE())

    INSERT INTO DefaultValuesPerCountry (IdCountry, UseMultiCountry,RowStatus,TokenCreated,DateCreated)
    VALUES('SV',1,1,'SYS-CAZURDIA',GETDATE())

    INSERT INTO DefaultValuesPerCountry (IdCountry, UseMultiCountry,RowStatus,TokenCreated,DateCreated)
    VALUES('HN',1,1,'SYS-CAZURDIA',GETDATE())

    ROLLBACK TRANSACTION;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

END CATCH