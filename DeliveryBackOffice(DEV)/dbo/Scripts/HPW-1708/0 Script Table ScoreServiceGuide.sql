BEGIN TRY
    BEGIN TRANSACTION;

	CREATE TABLE ScoreServiceGuide (
		IdScoreGuide INT IDENTITY(1,1) PRIMARY KEY, -- Identificador único para la calificación de servicio
		Score DECIMAL(5,2) NOT NULL, -- Puntaje que se le estará dando de calificación al servicio
		GuideSerie NVARCHAR(4) NOT NULL, -- Serie de guía
		GuideNumber BIGINT NOT NULL, -- Número de guía
		Comment NVARCHAR(255) NULL, -- Comentario no obligatorio que el usuario desea dejar
		IdSystem INT NOT NULL, -- Sistema en el cual fue ingresado la calificación del servicio (FK de CatSystem)
		RowStatus BIT NOT NULL, -- Estado lógico
		UserCreated NVARCHAR(50) NOT NULL, -- Usuario de creación
		DateCreated DATETIME NOT NULL, -- Fecha de creación
		UserUpdated NVARCHAR(50) NULL, -- Usuario modificación
		DateUpdated DATETIME NULL, -- Fecha de modificación
		CONSTRAINT FK_ScoreServiceGuide_System FOREIGN KEY (IdSystem) 
		REFERENCES DeliveryBackOffice.dbo.CatSystem (SysIdSystem)
	);

	-- Agregar descripciones para cada columna
	EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que contiene el puntaje de calificación por el servicio de su guía.'
	, @level0type = N'SCHEMA', @level0name = 'dbo'
	, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide';

	EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único para la calificación de servicio.'
	, @level0type = N'SCHEMA', @level0name = 'dbo'
	, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
	, @level2type = N'COLUMN', @level2name = 'IdScoreGuide';

	EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Puntaje que se le estará dando de calificación al servicio.'
	, @level0type = N'SCHEMA', @level0name = 'dbo'
	, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
	, @level2type = N'COLUMN', @level2name = 'Score';

	EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de guía.'
	, @level0type = N'SCHEMA', @level0name = 'dbo'
	, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
	, @level2type = N'COLUMN', @level2name = 'GuideSerie';

	EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía.'
	, @level0type = N'SCHEMA', @level0name = 'dbo'
	, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
	, @level2type = N'COLUMN', @level2name = 'GuideNumber';

	EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Comentario no obligatorio que el usuario desea dejar.'
	, @level0type = N'SCHEMA', @level0name = 'dbo'
	, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
	, @level2type = N'COLUMN', @level2name = 'Comment';

	EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Sistema en el cual fue ingresado la calificación del servicio.'
	, @level0type = N'SCHEMA', @level0name = 'dbo'
	, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
	, @level2type = N'COLUMN', @level2name = 'IdSystem';

	EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico.'
	, @level0type = N'SCHEMA', @level0name = 'dbo'
	, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
	, @level2type = N'COLUMN', @level2name = 'RowStatus';

	EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación.'
	, @level0type = N'SCHEMA', @level0name = 'dbo'
	, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
	, @level2type = N'COLUMN', @level2name = 'UserCreated';

	EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.'
	, @level0type = N'SCHEMA', @level0name = 'dbo'
	, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
	, @level2type = N'COLUMN', @level2name = 'DateCreated';

	EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario modificación.'
	, @level0type = N'SCHEMA', @level0name = 'dbo'
	, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
	, @level2type = N'COLUMN', @level2name = 'UserUpdated';

	EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación.'
	, @level0type = N'SCHEMA', @level0name = 'dbo'
	, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
	, @level2type = N'COLUMN', @level2name = 'DateUpdated';


	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;