SET NOCOUNT ON;

BEGIN TRY
    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'APExecutionSchedule' AND schema_id = SCHEMA_ID('dbo'))
    BEGIN
		PRINT 'La tabla dbo.APExecutionSchedule ya existe.';
	END
	ELSE
	BEGIN
        CREATE TABLE [dbo].[APExecutionSchedule] (
        [IdAPExecutionSchedule]     INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
        [CountryCode]               NVARCHAR(2)     NOT NULL,
        [StartTime]                 TIME            NOT NULL,
        [Description]               NVARCHAR(100)   NULL,
        [AeroPostIdByCountry]       INT             NOT NULL,
		[CodeOfReference]           INT             NOT NULL,
        [RowStatus]                 BIT             DEFAULT ((1)) NOT NULL,
        [TokenCreated]              NVARCHAR (50)   NOT NULL,
        [DateCreated]               DATETIME        NOT NULL,
        [TokenUpdated]              NVARCHAR (50)   NULL,
        [DateUpdated]               DATETIME        NULL,
        PRIMARY KEY CLUSTERED ([IdAPExecutionSchedule] ASC),
        CONSTRAINT [FK_APExecutionSchedule_Customer] FOREIGN KEY ([AeroPostIdByCountry]) REFERENCES [dbo].[Customer] ([IdCustomer])
        );

        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que almacena los horarios de ejecución del servicio de creación de guías de Aeropost', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'IdAPExecutionSchedule';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código del país', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'CountryCode';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Horario de ejecución del servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'StartTime';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del horario de ejecución', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'Description';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'id de cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'AeroPostIdByCountry';
		EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'codigo de referencia del visit point', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'CodeOfReference';
		EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro (1=Activo, 0=Inactivo)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'RowStatus';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que creó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'TokenCreated';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro en el sistema', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'DateCreated';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que actualizó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'TokenUpdated';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de última actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'DateUpdated';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Registra el Id de Aeropost según el país', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionSchedule', @level2type = N'COLUMN', @level2name = N'AeroPostIdByCountry';
	END;

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'APExecutionServiceLog' AND schema_id = SCHEMA_ID('dbo'))
    BEGIN
		PRINT 'La tabla dbo.APExecutionServiceLog ya existe.';
	END
	ELSE
	BEGIN
        CREATE TABLE [dbo].[APExecutionServiceLog] (
        [IdAPExecutionServiceLog]   BIGINT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
        [APExecutionScheduleId]     INT             NOT NULL,
        [CountryCode]               NVARCHAR(2)     NOT NULL,
        [APServiceDate]             DATETIME        NOT NULL DEFAULT GETDATE(),
        [Status]                    NVARCHAR(20)    NOT NULL,
        [Message]                   NVARCHAR(500)   NULL,
        [DurationMs]                INT             NULL,
        [RowStatus]                 BIT             DEFAULT ((1)) NOT NULL,
        [TokenCreated]              NVARCHAR (50)   NOT NULL,
        [DateCreated]               DATETIME        NOT NULL,
        [TokenUpdated]              NVARCHAR (50)   NULL,
        [DateUpdated]               DATETIME        NULL,
        PRIMARY KEY CLUSTERED ([IdAPExecutionServiceLog] ASC),
        CONSTRAINT [FK_ExecutionLog_Schedule] FOREIGN KEY ([APExecutionScheduleId]) REFERENCES [dbo].[APExecutionSchedule] ([IdAPExecutionSchedule])
        );

        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que almacena las ejecuciones del servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'IdAPExecutionServiceLog';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID del schedule de ejecución relacionado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'APExecutionScheduleId';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de país (formato ISO 2 caracteres)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'CountryCode';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de ejecución del servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'APServiceDate';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la ejecución (Running, Success, Failed)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'Status';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Mensaje descriptivo del resultado de la ejecución', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'Message';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Duración de la ejecución en milisegundos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'DurationMs';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro (1=Activo, 0=Inactivo)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'RowStatus';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que creó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro en el sistema', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'DateCreated';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que actualizó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de última actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APExecutionServiceLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';
	END;

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'APGuidesControl' AND schema_id = SCHEMA_ID('dbo'))
    BEGIN
		PRINT 'La tabla dbo.APGuidesControl ya existe.';
	END
	ELSE
	BEGIN
        CREATE TABLE [dbo].[APGuidesControl] (
        [IdAPGuidesControl]         BIGINT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
        [ReferenceNumber]           NVARCHAR(50)    NOT NULL,
        [TrackingCode]              NVARCHAR(50)    NOT NULL,
        [Phone]                     NVARCHAR(20)    NULL,
        [FirstName]                 NVARCHAR(100)   NOT NULL,
        [LastName]                  NVARCHAR(100)   NOT NULL,
        [City]                      NVARCHAR(100)   NOT NULL,   
        [Region]                    NVARCHAR(100)   NOT NULL, 
        [Address]                   NVARCHAR(500)   NOT NULL,
        [AddressExtra]              NVARCHAR(500)   NULL,
        [HeaderCode]                NVARCHAR(5)     NULL, 
        [ReceiverIdTownship]        INT             NULL, 
        [ReceiverIdSettlement]      BIGINT          NULL, 
        [CountryCode]               CHAR(2)         NOT NULL,
        [PostalCode]                NVARCHAR(20)    NULL,
        [DeliveryInstructions]      NVARCHAR(500)   NULL,
        [GuideCreatedDate]          DATETIME        NULL,
        [GuideSerie]                NVARCHAR (2)    NULL,
        [GuideNumber]               INT             NULL,
        [APServiceDate]             DATE            NOT NULL,
        [Status]                    NVARCHAR(10)    NOT NULL,
        [APExecutionScheduleId]     INT             NOT NULL,
        [RowStatus]                 BIT             DEFAULT ((1)) NOT NULL,
        [TokenCreated]              NVARCHAR (50)   NOT NULL,
        [DateCreated]               DATETIME        NOT NULL,
        [TokenUpdated]              NVARCHAR (50)   NULL,
        [DateUpdated]               DATETIME        NULL,
        PRIMARY KEY CLUSTERED ([IdAPGuidesControl] ASC),
        CONSTRAINT [FK_APGuidesControl_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
        CONSTRAINT [FK_APGuidesControl_APExecutionSchedule] FOREIGN KEY ([APExecutionScheduleId]) REFERENCES [dbo].[APExecutionSchedule] ([IdAPExecutionSchedule]),
        CONSTRAINT [FK_APGuidesControl_Township] FOREIGN KEY ([ReceiverIdTownship]) REFERENCES [dbo].[Township] ([IdTownship]),
        CONSTRAINT [FK_APGuidesControl_Settlement] FOREIGN KEY ([ReceiverIdSettlement]) REFERENCES [dbo].[Settlement] ([IdSettlement])
        );

        CREATE NONCLUSTERED INDEX [IDX_APGuidesControl_TrackingCode]
            ON [dbo].[APGuidesControl]([TrackingCode] ASC);
        CREATE NONCLUSTERED INDEX [IDX_APGuidesControl_GuideCreatedDate]
            ON [dbo].[APGuidesControl]([GuideCreatedDate] ASC);  
        CREATE NONCLUSTERED INDEX [IDX_APGuidesControl_GuideSerie_GuideNumber] 
            ON [dbo].[APGuidesControl]([GuideSerie] ASC, [GuideNumber] ASC);

        CREATE NONCLUSTERED INDEX [IX_APGuidesControl_TrackingCode_CountryCode_APServiceDate] 
        ON [dbo].[APGuidesControl] 
        (
            [TrackingCode] ASC,
            [CountryCode] ASC,
            [APServiceDate] ASC
        )
        INCLUDE ([RowStatus])
        WHERE [RowStatus] = 1;

        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que almacena los servicios requeridos por Aeropost, lleva el control de las guías creadas en Hermes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'IdAPGuidesControl';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de referencia para Aeropost', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'ReferenceNumber';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de tracking de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'TrackingCode';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Teléfono del destinatario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'Phone';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del destinatario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'FirstName';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apellido del destinatario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'LastName';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ciudad de destino', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'City';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Departamento de destino', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'Region';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dirección de entrega', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'Address';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Información adicional de la dirección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'AddressExtra';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Header code del municipio de recepción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'HeaderCode';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del municipio de recepción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'ReceiverIdTownship';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del poblado de recepción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'ReceiverIdSettlement';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de país (ej: HN)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'CountryCode';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código postal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'PostalCode';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Instrucciones especiales de entrega', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'DeliveryInstructions';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación de la guía en Aeropost', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'GuideCreatedDate';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía (relacionada con DeliveryOrder)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'GuideSerie';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía (relacionada con DeliveryOrder)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'APServiceDate';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha del servicio de Aeropost', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'Status';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si la guía fue creada en Hermes. Pending, Processing, Processed,Failed', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'Status';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro 1=Activo, 0=Inactivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'RowStatus';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que creó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'TokenCreated';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro en el sistema', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'DateCreated';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que actualizó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'TokenUpdated';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de última actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'DateUpdated';
	END;

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'APGuidesControlLogs' AND schema_id = SCHEMA_ID('dbo'))
    BEGIN
		PRINT 'La tabla dbo.APGuidesControlLogs ya existe.';
	END
	ELSE
	BEGIN
        CREATE TABLE [dbo].[APGuidesControlLogs] (
        [IdAPGuidesControlLog]      BIGINT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
        [TrackingCode]              NVARCHAR(50)    NULL,
        [ProcessName]               NVARCHAR(100)   NOT NULL,
        [ErrorMessage]              NVARCHAR(1000)  NOT NULL,
        [ErrorDetails]              NVARCHAR(1000)  NULL,
        [RowStatus]                 BIT             DEFAULT ((1)) NOT NULL,
        [TokenCreated]              NVARCHAR (50)   NOT NULL,
        [DateCreated]               DATETIME        NOT NULL,
        PRIMARY KEY CLUSTERED ([IdAPGuidesControlLog] ASC)
        );

        CREATE NONCLUSTERED INDEX [IDX_APGuidesControlLogs_DateCreated]
            ON [dbo].[APGuidesControlLogs]([DateCreated] ASC);

        CREATE NONCLUSTERED INDEX [IDX_APGuidesControlLogs_ProcessName]
            ON [dbo].[APGuidesControlLogs]([ProcessName] ASC);

        CREATE NONCLUSTERED INDEX [IDX_APGuidesControlLogs_TrackingCode]
            ON [dbo].[APGuidesControlLogs]([TrackingCode] ASC);

        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que almacena los logs de errores del proceso de creación de guías de Aeropost', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro de log', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs', @level2type = N'COLUMN', @level2name = N'IdAPGuidesControlLog';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de tracking relacionado al error', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs', @level2type = N'COLUMN', @level2name = N'TrackingCode';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del proceso que generó el error', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs', @level2type = N'COLUMN', @level2name = N'ProcessName';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Mensaje de error descriptivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs', @level2type = N'COLUMN', @level2name = N'ErrorMessage';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Detalles técnicos del error (stack trace, etc.)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs', @level2type = N'COLUMN', @level2name = N'ErrorDetails';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro (1=Activo, 0=Inactivo)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs', @level2type = N'COLUMN', @level2name = N'RowStatus';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario/sistema que generó el log', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs', @level2type = N'COLUMN', @level2name = N'TokenCreated';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del log', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControlLogs', @level2type = N'COLUMN', @level2name = N'DateCreated';
	END;

    IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'APRegionGuides' AND schema_id = SCHEMA_ID('dbo'))
    BEGIN
		PRINT 'La tabla dbo.APRegionGuides ya existe.';
	END
	ELSE
	BEGIN
        CREATE TABLE [dbo].[APRegionGuides] (
        [IdAPRegionGuides]          INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
        [City]                      NVARCHAR(100)   NULL,
        [Region]                    NVARCHAR(100)   NULL,
        [CountryCode]               NVARCHAR(2)     NOT NULL,
        [IdTownship]                INT             NOT NULL,
        [HeaderCode]                VARCHAR(10)     NOT NULL,
        [RowStatus]                 BIT             DEFAULT ((1)) NOT NULL,
        [TokenCreated]              NVARCHAR (50)   NOT NULL,
        [DateCreated]               DATETIME        NOT NULL,
        [TokenUpdated]              NVARCHAR (50)   NULL,
        [DateUpdated]               DATETIME        NULL,
        PRIMARY KEY CLUSTERED ([IdAPRegionGuides] ASC),
        CONSTRAINT [FK_APRegionGuides_Township] FOREIGN KEY ([IdTownship]) REFERENCES [dbo].[Township] ([IdTownship])
        );

        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar los municipios (city) o departamentos (region) de Aeropost que no coincidan con los de Forza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'IdAPRegionGuides';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código del país', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'City';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código del país', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'Region';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código del país', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'CountryCode';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Horario de ejecución del servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'IdTownship';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del horario de ejecución', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'HeaderCode';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro (1=Activo, 0=Inactivo)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'RowStatus';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que creó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'TokenCreated';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro en el sistema', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'DateCreated';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que actualizó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'TokenUpdated';
        EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de última actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APRegionGuides', @level2type = N'COLUMN', @level2name = N'DateUpdated';
	END;

	   
    PRINT 'Creación de tablas completada exitosamente.';
END TRY
BEGIN CATCH
    DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
    SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
    RAISERROR('Error ejecutando el script: %s', @ErrSeverity, 1, @ErrMsg);
END CATCH;