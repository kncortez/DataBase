USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.ArticleByCustomer  
   (AbcIdArticle int NOT NULL,
	AbcIdCustomer int NOT NULL,
	AbcRowStatus bit NOT NULL,
	AbcTokenCreated varchar(50)  NOT NULL,
	AbcDateCreated datetime  NOT NULL,
	AbcTokenUpdated varchar(50)   NULL,
	AbcDateUpdated datetime   NULL,
	 primary key (AbcIdArticle, AbcIdCustomer) ,
	CONSTRAINT FKArticleCustom FOREIGN KEY (AbcIdArticle) REFERENCES CatArticle(ArtId),
	CONSTRAINT FKCustomArticle FOREIGN KEY (AbcIdCustomer) REFERENCES  Customer(IdCustomer)
	)
GO  
