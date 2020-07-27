USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[Customer]
           ([Name]
           ,[Description]
           ,[Domain]
           ,[RegexSubject]
           ,[RegexEmail]
           ,[RegexFilename]
           ,[Abbreviation])
     VALUES
           ('EPA GUATEMALA'
           ,'EPA GUATEMALA'
           ,'@gt.epa.biz'
           ,''
           ,''
           ,'^envios_.*\.xls$'
           ,'EPA E-COMMERCE')
GO


select * from [dbo].[Customer]


