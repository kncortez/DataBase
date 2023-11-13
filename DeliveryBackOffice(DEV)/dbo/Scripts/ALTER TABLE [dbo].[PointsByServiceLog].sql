-- Primero, elimina la restricción actual
ALTER TABLE [dbo].[PointsByServiceLog] DROP CONSTRAINT [CHK_PointsByService_Points]

-- Luego, agrega la nueva restricción con las modificaciones que deseas
ALTER TABLE [dbo].[PointsByServiceLog] WITH CHECK ADD CONSTRAINT [CHK_PointsByService_Points] 
CHECK ((isnull([PointsReceived],(0))>=(0) AND isnull([PointsConsumed],(0))=(0) OR isnull([PointsReceived],(0))=(0) AND isnull([PointsConsumed],(0))>=(0))
