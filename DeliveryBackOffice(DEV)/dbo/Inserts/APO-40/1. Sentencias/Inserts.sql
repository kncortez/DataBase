-- APO-40
-- Table Linehaul Coverage
-- Change the 'CodeRoute' value to your preferred CodeRoute name
-- Change each 'CodeRoute' value to your preferred HUB Name
-- Change the 'ReportEmail' value to your preferred email address
INSERT INTO	 [dbo].[LinehaulCoverage]
			([CatRouteId],
			 [HubOriginId],
			 [HubDestinyId],
			 [ReportEmails],
			 [RowStatus],
			 [TokenCreated],
			 [DateCreated])
	VALUES  ((SELECT [CR].[IdRoute]
			 FROM [dbo].[CatRoute] CR
			 WHERE [CR].[CodeRoute] = 'LGUA01'),
			 (SELECT [HL].[IdHubLogistic]
			 FROM [dbo].[HubLogistics] HL
			 WHERE [HL].[HubName] = 'GUATEMALA'),
			 (SELECT [HL].[IdHubLogistic]
			 FROM [dbo].[HubLogistics] HL
			 WHERE [HL].[HubName] = 'MORALES'),
			 'email@forzadelivery.com',
			 1,
			 'SYS-ADMIN',
			 SYSDATETIME());

INSERT INTO	 [dbo].[LinehaulCoverage]
			([CatRouteId],
			 [HubOriginId],
			 [HubDestinyId],
			 [ReportEmails],
			 [RowStatus],
			 [TokenCreated],
			 [DateCreated])
	VALUES  ((SELECT [CR].[IdRoute]
			 FROM [dbo].[CatRoute] CR
			 WHERE [CR].[CodeRoute] = 'LGUA02'),
			 (SELECT [HL].[IdHubLogistic]
			 FROM [dbo].[HubLogistics] HL
			 WHERE [HL].[HubName] = 'GUATEMALA'),
			 (SELECT [HL].[IdHubLogistic]
			 FROM [dbo].[HubLogistics] HL
			 WHERE [HL].[HubName] = 'XELA'),
			 'email@forzadelivery.com',
			 1,
			 'SYS-ADMIN',
			 SYSDATETIME());

INSERT INTO	 [dbo].[LinehaulCoverage]
			([CatRouteId],
			 [HubOriginId],
			 [HubDestinyId],
			 [ReportEmails],
			 [RowStatus],
			 [TokenCreated],
			 [DateCreated])
	VALUES  ((SELECT [CR].[IdRoute]
			 FROM [dbo].[CatRoute] CR
			 WHERE [CR].[CodeRoute] = 'LGUA01'),
			 (SELECT [HL].[IdHubLogistic]
			 FROM [dbo].[HubLogistics] HL
			 WHERE [HL].[HubName] = 'GUATEMALA'),
			 (SELECT [HL].[IdHubLogistic]
			 FROM [dbo].[HubLogistics] HL
			 WHERE [HL].[HubName] = 'FLORES, PETEN'),
			 'email@forzadelivery.com',
			 1,
			 'SYS-ADMIN',
			 SYSDATETIME());