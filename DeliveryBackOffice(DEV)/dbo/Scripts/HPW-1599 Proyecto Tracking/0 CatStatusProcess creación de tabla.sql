BEGIN TRY
    BEGIN TRANSACTION;

	-- Creación de la tabla CatStatusProcess
	CREATE TABLE CatStatusProcess (
		IdStatusProcess INT IDENTITY(1,1) PRIMARY KEY,  -- Identificador único autoincrementable
		NameStatusProcess NVARCHAR(50) NOT NULL,        -- Nombre del estado del proceso
		DescriptionStatusProcess NVARCHAR(200) NULL,    -- Descripción del estado
		RowStatus BIT NOT NULL,                         -- Estado lógico
		UserCreated NVARCHAR(50) NOT NULL,              -- Usuario que creó el registro
		DateCreated DATETIME NOT NULL,                  -- Fecha de creación del registro
		UserUpdated NVARCHAR(50) NULL,                  -- Usuario que actualizó el registro
		DateUpdated DATETIME NULL                       -- Fecha de actualización del registro
	);

	-- Agregar descripciones a las columnas usando extended properties
	EXEC sp_addextendedproperty 
	@name = N'MS_Description', 
	@value = N'Identificador único para los estados de proceso en tracking', 
	@level0type = N'SCHEMA', @level0name = 'dbo', 
	@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
	@level2type = N'COLUMN', @level2name = 'IdStatusProcess';

	EXEC sp_addextendedproperty 
	@name = N'MS_Description', 
	@value = N'Nombre del estado del proceso en tracking', 
	@level0type = N'SCHEMA', @level0name = 'dbo', 
	@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
	@level2type = N'COLUMN', @level2name = 'NameStatusProcess';

	EXEC sp_addextendedproperty 
	@name = N'MS_Description', 
	@value = N'Descripción del significado de cada uno de los estados en tracking', 
	@level0type = N'SCHEMA', @level0name = 'dbo', 
	@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
	@level2type = N'COLUMN', @level2name = 'DescriptionStatusProcess';

	EXEC sp_addextendedproperty 
	@name = N'MS_Description', 
	@value = N'Estado lógico (activo/inactivo)', 
	@level0type = N'SCHEMA', @level0name = 'dbo', 
	@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
	@level2type = N'COLUMN', @level2name = 'RowStatus';

	EXEC sp_addextendedproperty 
	@name = N'MS_Description', 
	@value = N'Usuario que creó el registro', 
	@level0type = N'SCHEMA', @level0name = 'dbo', 
	@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
	@level2type = N'COLUMN', @level2name = 'UserCreated';

	EXEC sp_addextendedproperty 
	@name = N'MS_Description', 
	@value = N'Fecha de creación del registro', 
	@level0type = N'SCHEMA', @level0name = 'dbo', 
	@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
	@level2type = N'COLUMN', @level2name = 'DateCreated';

	EXEC sp_addextendedproperty 
	@name = N'MS_Description', 
	@value = N'Usuario que actualizó el registro', 
	@level0type = N'SCHEMA', @level0name = 'dbo', 
	@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
	@level2type = N'COLUMN', @level2name = 'UserUpdated';

	EXEC sp_addextendedproperty 
	@name = N'MS_Description', 
	@value = N'Fecha de actualización del registro', 
	@level0type = N'SCHEMA', @level0name = 'dbo', 
	@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
	@level2type = N'COLUMN', @level2name = 'DateUpdated';

	-- Agregar descripción a la tabla CatStatusProcess
	EXEC sp_addextendedproperty 
	@name = N'MS_Description', 
	@value = N'Tabla que obtiene los nuevos estados de agrupación para proceso de seguimiento.', 
	@level0type = N'SCHEMA', @level0name = 'dbo', 
	@level1type = N'TABLE',  @level1name = 'CatStatusProcess';


	-- Inserción de valores de ejemplo
	INSERT INTO CatStatusProcess (NameStatusProcess, DescriptionStatusProcess, RowStatus, UserCreated, DateCreated)
	VALUES 
	('Creado', 'Estado que se usa cuando una guía se encuentra generada o solicitada.', 1, 'SYS-WOROZCO', GETDATE()),
	('En instalaciones', 'Estado que indica que el proceso está en ejecución.', 1, 'SYS-WOROZCO', GETDATE()),
	('En Ruta', 'El proceso está en transporte hacia su destino.', 1, 'SYS-WOROZCO', GETDATE()),
	('Entregado', 'El proceso ha llegado a su destino final.', 1, 'SYS-WOROZCO', GETDATE());

	-- Consulta de los datos insertados
	SELECT * FROM DeliveryBackOffice.dbo.CatStatusProcess;

	--Modificación de la tabla StatusOrder
	-- Agregar la columna StatusProcessId a la tabla StatusOrder
	ALTER TABLE DeliveryBackOffice.dbo.StatusOrder
	ADD CatStatusProcessId INT NULL;

	-- Agregar la clave foránea que referencia a la tabla CatStatusProcess
	ALTER TABLE DeliveryBackOffice.dbo.StatusOrder
	ADD CONSTRAINT FK_StatusOrder_StatusProcess
	FOREIGN KEY (CatStatusProcessId) REFERENCES CatStatusProcess(IdStatusProcess);

	-- Agregar descripción a la columna StatusProcessId en la tabla StatusOrder
	EXEC sp_addextendedproperty 
	@name = N'MS_Description', 
	@value = N'Relación de estado origen con estado de proceso en tracking.', 
	@level0type = N'SCHEMA', @level0name = 'dbo', 
	@level1type = N'TABLE',  @level1name = 'StatusOrder', 
	@level2type = N'COLUMN', @level2name = 'CatStatusProcessId';

	-- Actualizar StatusProcessId en la tabla StatusOrder para los valores dados
	UPDATE DeliveryBackOffice.dbo.StatusOrder
	SET CatStatusProcessId = (SELECT IdStatusProcess FROM DeliveryBackOffice.dbo.CatStatusProcess WHERE NameStatusProcess = 'Creado')
	WHERE OrderDescription IN ('Solicitado','Generado');

	UPDATE DeliveryBackOffice.dbo.StatusOrder
	SET CatStatusProcessId = (SELECT IdStatusProcess FROM DeliveryBackOffice.dbo.CatStatusProcess WHERE NameStatusProcess = 'En instalaciones')
	WHERE OrderDescription IN ('Recolectado', 'Programado para entrega', 'Retornado al origen', 
		'Paquete Retornado para Reproceso', 'Entrega parcial', 'En Inventario', 'Arribó a las instalaciones', 
		'Intento de entrega fallida', 'En Revisión', 'Programado para recolección', 'Programado para devolución', 
		'En Tránsito', 'Traslado a Express Center', 'Recibido En Express Center', 'Paquete Retenido', 
		'Paquete Extraviado', 'Retenido', 'Reenviado al Hub origen para devolución', 'En Inventario de devolución', 
		'Declarado para Devolución', 'Paquete retenido por autoridad', 'Paquete Dañado', 'Paquete Inspeccionado', 
		'Guía arribó con piezas incompletas', 'Guía Fuera De Ruta', 'Reclamo en proceso', 'Tiempo máximo de inventario', 
		'En preparación de traslado', 'Trasladado a Hub', 'Incidencia en ruta', 'En escala', 
		'Retraso en transporte', 'Guía revertida para entrega', 'Incidencia Validada');

	UPDATE DeliveryBackOffice.dbo.StatusOrder
	SET CatStatusProcessId = (SELECT IdStatusProcess FROM DeliveryBackOffice.dbo.CatStatusProcess WHERE NameStatusProcess = 'En Ruta')
	WHERE OrderDescription IN ('En ruta', 'En ruta para devolución');

	UPDATE DeliveryBackOffice.dbo.StatusOrder
	SET CatStatusProcessId = (SELECT IdStatusProcess FROM DeliveryBackOffice.dbo.CatStatusProcess WHERE NameStatusProcess = 'Entregado')
	WHERE OrderDescription IN ('Entregado', 'Anulado', 'Devuelto', 'Entregado En Express Center', 
		'Devuelto en Express Center', 'COD liquidado', 'COD pagado', 'Paquete destruido', 
		'Reclamo finalizado', 'Paquete Abandonado', 'Paquete liquidado por garantía');

	-- Consulta para verificar los cambios
	SELECT * FROM DeliveryBackOffice.dbo.StatusOrder;

	--Se agrega una nueva columna a la tabla CatStatusProcess
	ALTER TABLE DeliveryBackOffice.dbo.CatStatusProcess
	ADD Icon NVARCHAR(200) NULL;

	EXEC sp_addextendedproperty 
	@name = N'MS_Description', 
	@value = N'Icono para visualización en tracking', 
	@level0type = N'SCHEMA', @level0name = 'dbo', 
	@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
	@level2type = N'COLUMN', @level2name = 'Icon';

	-- Actualizar los valores de la columna Icon
	UPDATE DeliveryBackOffice.dbo.CatStatusProcess
	SET Icon = 'bi bi-record-circle'
	WHERE IdStatusProcess = 1;

	UPDATE DeliveryBackOffice.dbo.CatStatusProcess
	SET Icon = 'bi bi-house-door'
	WHERE IdStatusProcess = 2;

	UPDATE DeliveryBackOffice.dbo.CatStatusProcess
	SET Icon = 'bi bi-truck'
	WHERE IdStatusProcess = 3;

	UPDATE DeliveryBackOffice.dbo.CatStatusProcess
	SET Icon = 'bi bi-geo-alt'
	WHERE IdStatusProcess = 4;

	-- Consulta de los datos insertados
	SELECT * FROM DeliveryBackOffice.dbo.CatStatusProcess;

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;