-- INSERTS APO-102

INSERT INTO	[dbo].[CatLinehaulStatus]
			([StatusName], 
			 [StatusDescription],
			 [RowStatus], 
			 [TokenCreated], 
			 [DateCreated])
VALUES		('PREPARATION FOR TRANSFER',
			 'IN PREPARATION FOR TRANSFER',
			 1,
			 'SYS-JOCHOA',
			 SYSDATETIME());

INSERT INTO [dbo].[StatusOrder]
			([OrderDescription], 
			 [CatCheckpointTypeId])
VALUES		('En preparación de traslado',
			 (SELECT [CCT].[IdCatCheckpointType] FROM [CatCheckpointType] CCT WHERE [CCT].[CheckpointTypeDescription] = 'Checkpoint de proceso'));
