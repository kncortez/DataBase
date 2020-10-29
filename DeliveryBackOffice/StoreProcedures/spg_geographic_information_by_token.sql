USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_geographic_information_by_token]    Script Date: 29/10/2020 11:13:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-10-29>
-- Description:	<Devuelve información geográfica para asociar a un punto de venta durante su creación>
-- =============================================
CREATE PROCEDURE [dbo].[spg_geographic_information_by_token]
	@IdToken NVARCHAR(50)
AS
BEGIN

  DECLARE @IdCountry NVARCHAR(2)

  SET @IdCountry = (SELECT [SSN_IdCountry] FROM [DenariusUser_Dev].[dbo].[LGN_LogByToken] WHERE SSN_IdToken = @IdToken)

  SELECT [IdCountry] as Country_ID
	  ,P.[IdProvince] as Dept_ID
      ,[ProvinceName] as Depto_Name
      ,T.IdTownship as Munic_ID
	  ,T.TownshipName as Munic_Name
  FROM [DeliveryBackOffice].[dbo].[Province] P -- departamento
  JOIN [DeliveryBackOffice].[dbo].[Township] T ON T.IdProvince = P.IdProvince -- municipio
  WHERE IdCountry = @IdCountry
  AND ProvinceStatus = 1 AND TownshipStatus = 1

END
GO


