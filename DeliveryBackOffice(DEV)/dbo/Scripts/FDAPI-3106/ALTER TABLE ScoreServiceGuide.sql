ALTER TABLE [dbo].[ScoreServiceGuide]
ADD IsOnTime BIT NULL;

ALTER TABLE [dbo].[ScoreServiceGuide]
ADD IsGoodConditions BIT NULL;

ALTER TABLE [dbo].[ScoreServiceGuide]
ADD IsGoodSender BIT NULL;

ALTER TABLE [dbo].[ScoreServiceGuide]
ADD IsGoodCommunication BIT NULL;

ALTER TABLE [dbo].[ScoreServiceGuide]
ADD IsGoodReceiver BIT NULL;

ALTER TABLE [dbo].[ScoreServiceGuide]
ADD ScoreReceiver DECIMAL(5,2) NULL;

ALTER TABLE [dbo].[ScoreServiceGuide]
ALTER COLUMN Score DECIMAL(5,2) NULL;

-- Agregar descripciones para cada columna
EXEC sp_addextendedproperty 
    @name = N'MS_Description'
    , @value = N'Valida si el paquete llegó dentro del tiempo estimado'
	, @level0type = N'SCHEMA', @level0name = 'dbo'
	, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
	, @level2type = N'COLUMN', @level2name = 'IsOnTime';

EXEC sp_addextendedproperty 
    @name = N'MS_Description'
    , @value = N'Valida si el paquete llegó en buenas condiciones'
	, @level0type = N'SCHEMA', @level0name = 'dbo'
	, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
	, @level2type = N'COLUMN', @level2name = 'IsGoodConditions';

EXEC sp_addextendedproperty 
    @name = N'MS_Description'
    , @value = N'Valida si volvería a solicitarle otro paquete al remitente'
	, @level0type = N'SCHEMA', @level0name = 'dbo'
	, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
	, @level2type = N'COLUMN', @level2name = 'IsGoodSender';

EXEC sp_addextendedproperty 
    @name = N'MS_Description'
    , @value = N'Valida si la comunicación con el destinatario fue clara y rápida'
	, @level0type = N'SCHEMA', @level0name = 'dbo'
	, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
	, @level2type = N'COLUMN', @level2name = 'IsGoodCommunication';

EXEC sp_addextendedproperty 
    @name = N'MS_Description'
    , @value = N'Valida si repetiría el envío a este destinatario'
	, @level0type = N'SCHEMA', @level0name = 'dbo'
	, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
	, @level2type = N'COLUMN', @level2name = 'IsGoodReceiver';

EXEC sp_addextendedproperty 
    @name = N'MS_Description'
    , @value = N'Calificación del destinatario'
	, @level0type = N'SCHEMA', @level0name = 'dbo'
	, @level1type = N'TABLE', @level1name = 'ScoreServiceGuide'
	, @level2type = N'COLUMN', @level2name = 'ScoreReceiver';