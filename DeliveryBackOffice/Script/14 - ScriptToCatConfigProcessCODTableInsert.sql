USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LAS CONFIGURACIONES DE HORARIOS EN LOS QUE SE EJECUTARAN LOS PROCESOS
INSERT INTO [dbo].[CatConfigProcessCOD] 
			([CatProcessCODId],[CatScheduleCODId],[TokenCreated])
	VALUES	(1,1,'AORTIZ')

INSERT INTO [dbo].[CatConfigProcessCOD] 
			([CatProcessCODId],[CatScheduleCODId],[TokenCreated])
	VALUES	(1,2,'AORTIZ')

INSERT INTO [dbo].[CatConfigProcessCOD] 
			([CatProcessCODId],[CatScheduleCODId],[TokenCreated])
	VALUES	(1,3,'AORTIZ')

INSERT INTO [dbo].[CatConfigProcessCOD] 
			([CatProcessCODId],[CatScheduleCODId],[TokenCreated])
	VALUES	(1,4,'AORTIZ')

INSERT INTO [dbo].[CatConfigProcessCOD] 
			([CatProcessCODId],[CatScheduleCODId],[TokenCreated])
	VALUES	(1,5,'AORTIZ')

INSERT INTO [dbo].[CatConfigProcessCOD] 
			([CatProcessCODId],[CatScheduleCODId],[TokenCreated])
	VALUES	(1,6,'AORTIZ')

INSERT INTO [dbo].[CatConfigProcessCOD] 
			([CatProcessCODId],[CatScheduleCODId],[TokenCreated])
	VALUES	(1,7,'AORTIZ')

INSERT INTO [dbo].[CatConfigProcessCOD] 
			([CatProcessCODId],[CatScheduleCODId],[TokenCreated])
	VALUES	(1,8,'AORTIZ')

--COMMIT


