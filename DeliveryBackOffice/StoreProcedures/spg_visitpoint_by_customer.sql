USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_visitpoint_by_customer]    Script Date: 29/10/2020 11:13:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-10-29>
-- Description:	<Devuelve la información general del punto de venta>
-- =============================================
CREATE PROCEDURE [dbo].[spg_visitpoint_by_customer]
	@IdVisitPoint INT
AS
BEGIN

  SELECT [IdVisitPointClient]
      ,[CodeOfReference] AS Hermes_ID
      ,[DescriptionOfClient] as Hermes_Name
      ,[StatusClient] as Hermes_Status
      ,[CountryId] as Hermes_Country
      ,[VisitPointId] as Denarius_ID
      ,[CustomerID] as Hermes_Customer_ID
	  ,C.[Description] as Hermes_Customer_Name
      ,[Address] as Hermes_Address
      ,[Zone] as Hermes_Zone
      ,[Town] as Hermes_Town
      ,[Department] as Hermes_Department
      ,[Phone] as Hermes_Phone
      ,[ContactName] as Hermes_ContactName
  FROM [DeliveryBackOffice].[dbo].[VisitPointClient] V
  LEFT JOIN DeliveryBackOffice.dbo.Customer C ON C.IdCustomer = V.CustomerID
  WHERE CodeOfReference = @IdVisitPoint

END
GO


