-- APO-63
INSERT INTO [dbo].[CatLinehaulStatus]
				([StatusName],
				 [StatusDescription],
				 [RowStatus], 
				 [TokenCreated],
				 [DateCreated])
	VALUES ('STOPOVER', 
			'LINEHAUL IS IN STOPOVER', 
			1, 
			'SYS-JOCHOA', 
			SYSDATETIME());

INSERT INTO [dbo].[CatLinehaulStatus]
				([StatusName],
				 [StatusDescription],
				 [RowStatus], 
				 [TokenCreated],
				 [DateCreated])
	VALUES ('MISSING', 
			'PIECE MISSING', 
			1, 
			'SYS-JOCHOA', 
			SYSDATETIME());