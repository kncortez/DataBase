-- INSERTS APO-104
INSERT INTO [dbo].[StatusOrder]
			([OrderDescription], 
			 [CatCheckpointTypeId])
VALUES		('Trasladado a Hub',
			 (SELECT [CCT].[IdCatCheckpointType] FROM [CatCheckpointType] CCT WHERE [CCT].[CheckpointTypeDescription] = 'Checkpoint de proceso'));