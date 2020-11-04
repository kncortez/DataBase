USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_customers_visitpoints]    Script Date: 3/11/2020 12:42:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-11-03>
-- Description:	<Devuelve la información general del cliente>
-- =============================================
CREATE PROCEDURE [dbo].[spg_customers_visitpoints]
	
AS
BEGIN

  SELECT 
	  [IdCustomer] as Customer_ID
      ,[Name] as Customer_Name
      ,[RegexSubject] as Customer_RegexSubject
      ,[RegexEmail] as Customer_RegexEmail
      ,[RegexFilename] as Customer_FileName
	  ,ISNULL(COD,0) AS Customer_COD
	  ,[IdVisitPointClient] as Visitpoint_RowID
      ,[CodeOfReference] as Visitpoint_ID
      ,[DescriptionOfClient] as VisitPoint_Name
      ,[StatusClient] as Visitpoint_Status
      ,[CountryId] as Visitpoint_Country
      ,[VisitPointId] as Visitpoint_Denarius_ID
      ,[Address] as Visitpoint_Address
      ,[Zone] as Visitpoint_Zone
      ,[Town] as Visitpoint_Town
      ,[Department] as Visitpoint_Department
      ,[Phone] as Visitpoint_Phone
  FROM [DeliveryBackOffice].[dbo].[Customer] C
  JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] V on V.CustomerID = C.IdCustomer

END
GO


