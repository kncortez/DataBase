		DECLARE @IDMODULE AS INT =  0;
	SET @IDMODULE = (SELECT TOP 1 MDL_IdModule + 1 FROM LGN_Module ORDER BY MDL_IdModule DESC) ;


	INSERT INTO   [DenariusUser_Dev].[dbo].LGN_Module 
	VALUES(@IDMODULE, 
		'Administrador FD',
		NULL,
		'fec-admin',
		'Administrador de Facturas Express Center',
		NULL,
		'file.png',
		1);	