Insert Into ConfigParams ([Name],	[Description],	[Value],	[Status],	CreateDate)
			VALUES('CCValidationHistory',
			       'Historial de validación de incidencias de control de calidad',
				   'http://192.168.31.235/ReportServer/Pages/ReportViewer?/ForzaDelivery%2fCCValidationHistory',
				   1,	
				   GETDATE()
				   )