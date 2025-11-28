BEGIN TRY
    BEGIN TRANSACTION;
	DECLARE @CodeOfReference NVARCHAR(10) = 1162393;

UPDATE del_ParametrosFactura
SET dpf_FELUser = 'SV.06141501221044.TESTUSER',--'SV.06142308221025.TESTFORZADELI'
dpf_FELEntity = '06141501221044',--06142308221025
inv_cmp_name = 'DELIVERY EXPRESS EL SALVADOR S.A. DE C.V.',--'DIGIFACT SERVICIOS, SOCIEDAD ANONIMA DE CAPITAL VARIABLE'
dpf_FELRequestor = 'Digifact23*'
where dpf_VpCodeOfReference = @CodeOfReference

	UPDATE AddInfoByConfigSV
SET Value =  'TESTUSER'--'TESTFORZADELI'
WHERE Name = 'USERNAME'


UPDATE AddInfoByCodeOfReference
SET Value = '3111898' --3182701
where Name = 'NRC'
and CodeOfReference = @CodeOfReference

UPDATE AddInfoByCodeOfReference
SET Value = '52220' --62090
where Name = 'CodigoActividad'
and CodeOfReference = @CodeOfReference

UPDATE AddInfoByCodeOfReference
SET Value = 'Servicios para el transporte acuático' --Otras actividades de tecnología de información y servicios de computadora
where Name = 'DescActividad'
and CodeOfReference = @CodeOfReference

UPDATE AddInfoByCodeOfReference
SET Value = 'DELIVERY EXPRESS EL SALVADOR S.A. DE C.V.' --Digifact Servicios S.A
where Name = 'NombreComercial'
and CodeOfReference = @CodeOfReference


UPDATE AddInfoByCodeOfReference
SET Value = 'M001' --M001
where Name = 'CodEstablecimientoMH'
and CodeOfReference = @CodeOfReference


UPDATE AddInfoByCodeOfReference
SET Value = 'M001' --M001
where Name = 'CodEstablecimiento'
and CodeOfReference = @CodeOfReference


UPDATE AddInfoByCodeOfReference
SET Value = 'M001P001' --M001P001
where Name = 'CodEstPuntoV'
and CodeOfReference = @CodeOfReference

	
    COMMIT TRANSACTION;
    PRINT 'Actualización completada exitosamente.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT 'Se produjo un error en la ejecución.';
    PRINT 'Número de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Severidad: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
    PRINT 'Estado: ' + CAST(ERROR_STATE() AS VARCHAR(10));
    PRINT 'Procedimiento: ' + ISNULL(ERROR_PROCEDURE(), '-');
    PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR(10));
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
END CATCH;