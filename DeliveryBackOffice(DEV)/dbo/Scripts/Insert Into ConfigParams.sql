Insert Into ConfigParams ([Name],	[Description],	[Value],	[Status],	CreateDate)
			VALUES('CCValidationHistory',
			       'Historial de validación de incidencias de control de calidad',
				   select 'http://'+cast(CONNECTIONPROPERTY('local_net_address')as varchar)+'/ReportServer/Pages/ReportViewer?/ForzaDelivery%2fCCValidationHistory',
				   1,	
				   GETDATE()
				   )