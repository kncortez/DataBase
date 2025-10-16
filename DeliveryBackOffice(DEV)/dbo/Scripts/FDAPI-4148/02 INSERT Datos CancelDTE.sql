BEGIN TRY
    BEGIN TRANSACTION;

	INSERT INTO AddInfoByConfigSV VALUES ('CancelDTE', 'nombreResponsable',NULL, 'DELIVERY EXPRESS SV',1,GETDATE(),'SYS-BPEDROZA', NULL,NULL);
	INSERT INTO AddInfoByConfigSV VALUES ('CancelDTE', 'tipoDocumentoResponsable',NULL, '36',1,GETDATE(),'SYS-BPEDROZA', NULL,NULL);
	INSERT INTO AddInfoByConfigSV VALUES ('CancelDTE', 'numDocumentoResponsable',NULL, '06141501221044',1,GETDATE(),'SYS-BPEDROZA', NULL,NULL);
	INSERT INTO AddInfoByConfigSV VALUES ('CancelDTE', 'nombreSolicitante',NULL, 'DELIVERY EXPRESS SV',1,GETDATE(),'SYS-BPEDROZA', NULL,NULL);
	INSERT INTO AddInfoByConfigSV VALUES ('CancelDTE', 'tipoDocumentoSolicitante',NULL, '36',1,GETDATE(),'SYS-BPEDROZA', NULL,NULL);
	INSERT INTO AddInfoByConfigSV VALUES ('CancelDTE', 'numDocumentoSolitante',NULL, '06141501221044',1,GETDATE(),'SYS-BPEDROZA', NULL,NULL);

    COMMIT TRANSACTION;
    PRINT 'Inserciones realizadas correctamente.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT 'Ocurrió un error:';
    PRINT ERROR_MESSAGE();
    PRINT 'Número de error:';
    PRINT ERROR_NUMBER();
    PRINT 'Procedimiento:';
    PRINT ERROR_PROCEDURE();
    PRINT 'Línea:';
    PRINT ERROR_LINE();
END CATCH;
