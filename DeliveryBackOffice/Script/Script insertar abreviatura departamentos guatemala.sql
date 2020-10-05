

UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'AVZ' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 1
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'BVZ' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 2
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'CMO' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 3
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'CQM' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 4
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'PRO' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 5
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'ESC' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 6
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'GUA' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 7
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'HUE' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 8
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'IZA' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 9
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'JAL' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 10
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'JUT' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 11
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'PET' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 12
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'XEL' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 13
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'QUI' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 14
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'REU' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 15
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'SAC' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 16
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'SMC' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 17
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'SRO' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 18
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'SOL' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 19
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'SUC' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 20
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'TOT' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 21
UPDATE DeliveryBackOffice.dbo.Province set province.ProvinceAbbreviation = 'ZAC' , TokenUpdated = 'SYS-ERAMIREZ',DateUpdated= GETDATE()  where IdProvince = 22

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT prov.*
  FROM --[DeliveryBackOffice].[dbo].[Township] mun
   [DeliveryBackOffice].[dbo].[Province] prov
  --ON mun.IdProvince = prov.IdProvince
  WHERE 1 = 1--  mun.TownshipStatus = 'TRUE'
  AND prov.IdCountry = 'GT'
  AND prov.ProvinceStatus = 'TRUE'
  --AND prov.IdProvince = 1
