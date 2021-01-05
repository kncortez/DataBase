/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.Township SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.DeliveryOrder ADD
	SenderIdTownship int NULL,
	ReceiverIdTownship int NULL
GO
ALTER TABLE dbo.DeliveryOrder ADD CONSTRAINT
	FK_DeliveryOrder_SenderTownship FOREIGN KEY
	(
	SenderIdTownship
	) REFERENCES dbo.Township
	(
	IdTownship
	) ON UPDATE  NO ACTION
	 ON DELETE  NO ACTION
	
GO
ALTER TABLE dbo.DeliveryOrder ADD CONSTRAINT
	FK_DeliveryOrder_ReceiverTownship FOREIGN KEY
	(
	ReceiverIdTownship
	) REFERENCES dbo.Township
	(
	IdTownship
	) ON UPDATE  NO ACTION
	 ON DELETE  NO ACTION
	
GO
ALTER TABLE dbo.DeliveryOrder SET (LOCK_ESCALATION = TABLE)
GO
COMMIT (editado) 