ALTER TABLE VisitPointClient
	ADD 
	[LogLatitude]             NVARCHAR (20)  NULL,
    [LogLongitude]            NVARCHAR (20)  NULL

EXECUTE sp_addextendedproperty N'MS_Description', 'Ubicación (latitud) anterior o para revisión del punto de visita.', N'SCHEMA', N'dbo', N'TABLE', N'VisitPointClient', N'COLUMN', N'LogLatitude'
EXECUTE sp_addextendedproperty N'MS_Description', 'Ubicación (longitud) anterior o para revisión del punto de visita.', N'SCHEMA', N'dbo', N'TABLE', N'VisitPointClient', N'COLUMN', N'LogLongitude'