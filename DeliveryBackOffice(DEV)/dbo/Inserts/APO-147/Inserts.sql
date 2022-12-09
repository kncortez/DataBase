-- INSERT APO-147
INSERT INTO [dbo].[StatusOrder]
			([OrderDescription], 
			 [CatCheckpointTypeId], 
			 [CatStatusTypeId],
			 [RowStatus])
VALUES		('En escala',
			 (SELECT [IdCatCheckpointType] FROM [dbo].[CatCheckpointType] WHERE [CheckpointTypeDescription] = 'Checkpoint de proceso'),
			 (SELECT [IdCatStatusType] FROM [dbo].[CatStatusType] WHERE [StatusType] = 'Interno'),
			 1);