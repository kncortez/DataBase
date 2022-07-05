-- INSERTS APO-37
/************************************************************* CatLinehaulStatus -********************************************************/
INSERT INTO [dbo].[CatLinehaulStatus]
				([StatusName],
				 [StatusDescription],
				 [RowStatus], 
				 [TokenCreated],
				 [DateCreated])
	VALUES ('GENERATED',
			'LINEHAUL HAS BEEN GENERATED',
			1,
			'SYS-ADMIN',
			SYSDATETIME());

INSERT INTO [dbo].[CatLinehaulStatus]
				([StatusName],
				 [StatusDescription],
				 [RowStatus], 
				 [TokenCreated],
				 [DateCreated])
	VALUES ('IN TRANSIT', 
			'LINEHAUL IS IN TRANSIT TO DESTINATION', 
			1, 
			'SYS-JOCHOA', 
			SYSDATETIME());

INSERT INTO [dbo].[CatLinehaulStatus]
				([StatusName],
				 [StatusDescription],
				 [RowStatus], 
				 [TokenCreated],
				 [DateCreated])
	VALUES ('LIQUIDATED', 
			'LINEHAUL HAS BEEN LIQUIDATED', 
			1, 
			'SYS-JOCHOA', 
			SYSDATETIME());
