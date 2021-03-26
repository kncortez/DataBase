USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatTypeArticle]
           ([TarIdPackage]
           ,[TarName]
           ,[TarRowStatus]
           ,[TarTokenCreated]
           ,[TarDateCreated])
     VALUES
           (3 -- Otros
           ,'Baños'
           ,1
           ,'SYS-CAQUINO'
           ,GETDATE())


declare @IdBaños int = SCOPE_IDENTITY()  

INSERT INTO [dbo].[CatTypeArticle]
           ([TarIdPackage]
           ,[TarName]
           ,[TarRowStatus]
           ,[TarTokenCreated]
           ,[TarDateCreated])
     VALUES
           (3 -- Otros
           ,'Construcción'
           ,1
           ,'SYS-CAQUINO'
           ,GETDATE())

declare @IdConstruccion int = SCOPE_IDENTITY()  

INSERT INTO [dbo].[CatTypeArticle]
           ([TarIdPackage]
           ,[TarName]
           ,[TarRowStatus]
           ,[TarTokenCreated]
           ,[TarDateCreated])
     VALUES
           (3 -- Otros
           ,'Jardín'
           ,1
           ,'SYS-CAQUINO'
           ,GETDATE())


declare @IdJardin int = SCOPE_IDENTITY() 


INSERT INTO [dbo].[CatArticle]
           ([ArtIdTypeArticle]
           ,[ArtName]
           ,[ArtShowDefault]
           ,[ArtRowStatus]
           ,[ArtTokenCreated]
           ,[ArtDateCreated])
     VALUES
           (@IdBaños,'Pila','false','true','SYS-CAQUINO',GETDATE())
DECLARE @IDPila  int = SCOPE_IDENTITY() 

INSERT INTO [dbo].[CatArticle]
           ([ArtIdTypeArticle]
           ,[ArtName]
           ,[ArtShowDefault]
           ,[ArtRowStatus]
           ,[ArtTokenCreated]
           ,[ArtDateCreated])
     VALUES
           (@IdBaños,'Calentador Eléctrico Cilindro','false','true','SYS-CAQUINO',GETDATE())
		   

DECLARE @IDCalentador1  int = SCOPE_IDENTITY() 


INSERT INTO [dbo].[CatArticle]
           ([ArtIdTypeArticle]
           ,[ArtName]
           ,[ArtShowDefault]
           ,[ArtRowStatus]
           ,[ArtTokenCreated]
           ,[ArtDateCreated])
     VALUES
           (@IdBaños,'Calentador Solar','false','true','SYS-CAQUINO',GETDATE())
		   

DECLARE @IDCalentador2  int = SCOPE_IDENTITY() 


INSERT INTO [dbo].[CatArticle]
           ([ArtIdTypeArticle]
           ,[ArtName]
           ,[ArtShowDefault]
           ,[ArtRowStatus]
           ,[ArtTokenCreated]
           ,[ArtDateCreated])
     VALUES
           (@IdBaños,'Tina','false','true','SYS-CAQUINO',GETDATE())
		   

DECLARE @Idtina  int = SCOPE_IDENTITY()


INSERT INTO [dbo].[CatArticle]
           ([ArtIdTypeArticle]
           ,[ArtName]
           ,[ArtShowDefault]
           ,[ArtRowStatus]
           ,[ArtTokenCreated]
           ,[ArtDateCreated])
     VALUES
           (@IdConstruccion,'Depósito Tricapa','false','true','SYS-CAQUINO',GETDATE())
		   

DECLARE @IdTricapa  int = SCOPE_IDENTITY() 

INSERT INTO [dbo].[CatArticle]
           ([ArtIdTypeArticle]
           ,[ArtName]
           ,[ArtShowDefault]
           ,[ArtRowStatus]
           ,[ArtTokenCreated]
           ,[ArtDateCreated])
     VALUES
           (@IdConstruccion,'Depósito Cisterna','false','true','SYS-CAQUINO',GETDATE())
		   

DECLARE @IdCisterna  int = SCOPE_IDENTITY() 

INSERT INTO [dbo].[CatArticle]
           ([ArtIdTypeArticle]
           ,[ArtName]
           ,[ArtShowDefault]
           ,[ArtRowStatus]
           ,[ArtTokenCreated]
           ,[ArtDateCreated])
     VALUES
           (@IdConstruccion,'Depósito Fosa Septica','false','true','SYS-CAQUINO',GETDATE())
		   

DECLARE @IdFosa  int = SCOPE_IDENTITY() 


INSERT INTO [dbo].[CatArticle]
           ([ArtIdTypeArticle]
           ,[ArtName]
           ,[ArtShowDefault]
           ,[ArtRowStatus]
           ,[ArtTokenCreated]
           ,[ArtDateCreated])
     VALUES
           (@IdJardin,'Casa Plastica Jardin','false','true','SYS-CAQUINO',GETDATE())
		   

DECLARE @IdCasa  int = SCOPE_IDENTITY() 

INSERT INTO [dbo].[CatArticle]
           ([ArtIdTypeArticle]
           ,[ArtName]
           ,[ArtShowDefault]
           ,[ArtRowStatus]
           ,[ArtTokenCreated]
           ,[ArtDateCreated])
     VALUES
           (2,'Base Cama','false','true','SYS-CAQUINO',GETDATE())
		   

DECLARE @IdBaseCama  int = SCOPE_IDENTITY() 

INSERT INTO [dbo].[CatArticle]
           ([ArtIdTypeArticle]
           ,[ArtName]
           ,[ArtShowDefault]
           ,[ArtRowStatus]
           ,[ArtTokenCreated]
           ,[ArtDateCreated])
     VALUES
           (2,'Colchón Cama','false','true','SYS-CAQUINO',GETDATE())
		   

DECLARE @IdCama  int = SCOPE_IDENTITY() 

INSERT INTO [dbo].[ArticleByCustomer]
           ([AbcIdArticle]
           ,[AbcIdCustomer]
           ,[AbcRowStatus]
           ,[AbcTokenCreated]
           ,[AbcDateCreated]
           ,[Code]
           ,[PriceDefault])
     VALUES
           (@IdBaseCama,24,1,'SYS-CAQUINO',GETDATE(),'EPA001',130)
DECLARE @EPA001 INT =  SCOPE_IDENTITY() 

INSERT INTO [dbo].[ArticleByCustomer]
           ([AbcIdArticle]
           ,[AbcIdCustomer]
           ,[AbcRowStatus]
           ,[AbcTokenCreated]
           ,[AbcDateCreated]
           ,[Code]
           ,[PriceDefault])
     VALUES
           (@IdCama,24,1,'SYS-CAQUINO',GETDATE(),'EPA002',130)
DECLARE @EPA002 INT =  SCOPE_IDENTITY() 

INSERT INTO [dbo].[ArticleByCustomer]
           ([AbcIdArticle]
           ,[AbcIdCustomer]
           ,[AbcRowStatus]
           ,[AbcTokenCreated]
           ,[AbcDateCreated]
           ,[Code]
           ,[PriceDefault])
     VALUES
           (@IDPila,24,1,'SYS-CAQUINO',GETDATE(),'EPA003',250)
DECLARE @EPA003 INT =  SCOPE_IDENTITY() 

INSERT INTO [dbo].[ArticleByCustomer]
           ([AbcIdArticle]
           ,[AbcIdCustomer]
           ,[AbcRowStatus]
           ,[AbcTokenCreated]
           ,[AbcDateCreated]
           ,[Code]
           ,[PriceDefault])
     VALUES
           (@IdTricapa,24,1,'SYS-CAQUINO',GETDATE(),'EPA004',250)
DECLARE @EPA004 INT =  SCOPE_IDENTITY() 

INSERT INTO [dbo].[ArticleByCustomer]
           ([AbcIdArticle]
           ,[AbcIdCustomer]
           ,[AbcRowStatus]
           ,[AbcTokenCreated]
           ,[AbcDateCreated]
           ,[Code]
           ,[PriceDefault])
     VALUES
           (@IdCisterna,24,1,'SYS-CAQUINO',GETDATE(),'EPA005',390)
DECLARE @EPA005 INT =  SCOPE_IDENTITY() 

INSERT INTO [dbo].[ArticleByCustomer]
           ([AbcIdArticle]
           ,[AbcIdCustomer]
           ,[AbcRowStatus]
           ,[AbcTokenCreated]
           ,[AbcDateCreated]
           ,[Code]
           ,[PriceDefault])
     VALUES
           (@IdFosa,24,1,'SYS-CAQUINO',GETDATE(),'EPA006',390)
DECLARE @EPA006 INT =  SCOPE_IDENTITY() 

INSERT INTO [dbo].[ArticleByCustomer]
           ([AbcIdArticle]
           ,[AbcIdCustomer]
           ,[AbcRowStatus]
           ,[AbcTokenCreated]
           ,[AbcDateCreated]
           ,[Code]
           ,[PriceDefault])
     VALUES
           (@IDCalentador1,24,1,'SYS-CAQUINO',GETDATE(),'EPA007',390)
DECLARE @EPA007 INT =  SCOPE_IDENTITY()

INSERT INTO [dbo].[ArticleByCustomer]
           ([AbcIdArticle]
           ,[AbcIdCustomer]
           ,[AbcRowStatus]
           ,[AbcTokenCreated]
           ,[AbcDateCreated]
           ,[Code]
           ,[PriceDefault])
     VALUES
           (@IDCalentador2,24,1,'SYS-CAQUINO',GETDATE(),'EPA008',390)
DECLARE @EPA008 INT =  SCOPE_IDENTITY()

INSERT INTO [dbo].[ArticleByCustomer]
           ([AbcIdArticle]
           ,[AbcIdCustomer]
           ,[AbcRowStatus]
           ,[AbcTokenCreated]
           ,[AbcDateCreated]
           ,[Code]
           ,[PriceDefault])
     VALUES
           (@IdCasa,24,1,'SYS-CAQUINO',GETDATE(),'EPA009',360)
DECLARE @EPA009 INT =  SCOPE_IDENTITY() 

INSERT INTO [dbo].[ArticleByCustomer]
           ([AbcIdArticle]
           ,[AbcIdCustomer]
           ,[AbcRowStatus]
           ,[AbcTokenCreated]
           ,[AbcDateCreated]
           ,[Code]
           ,[PriceDefault])
     VALUES
           (@Idtina,24,1,'SYS-CAQUINO',GETDATE(),'EPA010',360)
DECLARE @EPA010 INT =  SCOPE_IDENTITY() 

INSERT INTO [dbo].[RateByArticuleByCustomer]
           ([ArticuleByCustomerId]
           ,[SegmetId]
           ,[Price]
           ,[RmsRowStatus]
           ,[TokenCreated]
           ,[DateCreated])
     VALUES
           (@EPA001,1,81,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA001,2,81,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA001,3,108,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA001,4,130,'TRUE','SYS-CAQUINO',GETDATE())

		   ,(@EPA002,1,81,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA002,2,81,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA002,3,108,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA002,4,130,'TRUE','SYS-CAQUINO',GETDATE())

		   ,(@EPA003,1,190,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA003,2,190,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA003,3,250,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA003,4,250,'TRUE','SYS-CAQUINO',GETDATE())

		   ,(@EPA004,1,190,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA004,2,190,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA004,3,250,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA004,4,250,'TRUE','SYS-CAQUINO',GETDATE())

		   ,(@EPA005,1,250,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA005,2,250,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA005,3,325,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA005,4,390,'TRUE','SYS-CAQUINO',GETDATE())

		   ,(@EPA006,1,250,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA006,2,250,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA006,3,325,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA006,4,390,'TRUE','SYS-CAQUINO',GETDATE())

		   ,(@EPA007,1,250,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA007,2,250,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA007,3,325,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA007,4,390,'TRUE','SYS-CAQUINO',GETDATE())

		   ,(@EPA008,1,250,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA008,2,250,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA008,3,325,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA008,4,390,'TRUE','SYS-CAQUINO',GETDATE())

		   ,(@EPA009,1,275,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA009,2,275,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA009,3,360,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA009,4,360,'TRUE','SYS-CAQUINO',GETDATE())

		   ,(@EPA010,1,275,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA010,2,275,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA010,3,360,'TRUE','SYS-CAQUINO',GETDATE())
		   ,(@EPA010,4,360,'TRUE','SYS-CAQUINO',GETDATE())

select * from dbo.CatTypeArticle --where TarIdPackage = 3
select * from dbo.CatArticle 
select * from dbo.ArticleByCustomer-- where AbcIdCustomer = 24

select * from dbo.RateByArticuleByCustomer