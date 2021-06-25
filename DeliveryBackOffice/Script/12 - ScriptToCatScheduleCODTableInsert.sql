USE [DeliveryBackOffice]

BEGIN TRAN

--INSERTAR LOS HORARIOS EN LOS QUE SE EJECUTARAN LOS PROCESOS
INSERT INTO [dbo].[CatScheduleCOD] 
			([Hour],[TokenCreated])
	VALUES	('08:00:00','AORTIZ')

INSERT INTO [dbo].[CatScheduleCOD] 
			([Hour],[TokenCreated])
	VALUES	('10:00:00','AORTIZ')

INSERT INTO [dbo].[CatScheduleCOD] 
			([Hour],[TokenCreated])
	VALUES	('12:00:00','AORTIZ')

INSERT INTO [dbo].[CatScheduleCOD] 
			([Hour],[TokenCreated])
	VALUES	('14:00:00','AORTIZ')

INSERT INTO [dbo].[CatScheduleCOD] 
			([Hour],[TokenCreated])
	VALUES	('16:00:00','AORTIZ')

INSERT INTO [dbo].[CatScheduleCOD] 
			([Hour],[TokenCreated])
	VALUES	('18:00:00','AORTIZ')

INSERT INTO [dbo].[CatScheduleCOD] 
			([Hour],[TokenCreated])
	VALUES	('20:00:00','AORTIZ')

INSERT INTO [dbo].[CatScheduleCOD] 
			([Hour],[TokenCreated])
	VALUES	('22:00:00','AORTIZ')

--COMMIT


