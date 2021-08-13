

CREATE TABLE TaskRelationshipWithGuide(
	TaskRelationshipWithGuidesId INT IDENTITY(1,1) NOT NULL,
	IdDeliveryTask INT NOT NULL,
	GuideSerie NVARCHAR(2) NOT NULL,
	GuideNumber INT NOT NULL,
	RowStatus INT NOT NULL,
	TokenCreated NVARCHAR(50) NOT NULL,
	DateCreated DATETIME NOT NULL,
	TokenUpdated NVARCHAR(50),
	DateUpdated DATETIME,
	PRIMARY KEY (TaskRelationshipWithGuidesId),
	CONSTRAINT TaskRelationshipWithGuide_IdDeliveryTask_FK FOREIGN KEY (IdDeliveryTask) REFERENCES DeliveryTask(DeliveryTaskId),
	CONSTRAINT TaskRelationshipWithGuide_Guide_FK FOREIGN KEY (GuideSerie, GuideNumber) REFERENCES DeliveryOrder(Guide_Serie, Guide_Number)
);