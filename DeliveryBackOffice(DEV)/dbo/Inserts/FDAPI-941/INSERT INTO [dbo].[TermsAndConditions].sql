USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[TermsAndConditions]
           ([Name]
           ,[Description]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Collection Services Terms and Conditions'
           ,'Términos y condiciones de servicios de recolección'
           ,1--<RowStatus, bit,>
           ,'SYS-AIXCHOP'
           ,GETDATE()--<DateCreated, datetime,>
           ,NULL
           ,NULL)

INSERT INTO [dbo].[TermsAndConditions]
           ([Name]
           ,[Description]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           ('Declaration no content of illegal products'
           ,'Declaración de envío sin contenido de productos ilegales'
           ,1--<RowStatus, bit,>
           ,'SYS-AIXCHOP'--<TokenCreated, varchar(50),>
           ,GETDATE()
           ,NULL
           ,NULL);
GO

