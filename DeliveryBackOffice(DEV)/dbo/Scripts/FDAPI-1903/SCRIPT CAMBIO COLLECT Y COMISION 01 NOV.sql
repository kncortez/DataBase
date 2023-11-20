
----- ******************* BACKUP ******************************************************************************

SELECT * FROM dbo.RateHeader

WHERE RheName IN ( 'Tarifario de servicio estandar', 'Tarifario destinos express center', 'Promo Mita Mita Exc'
                    , 'Promo Mita Mita Destinos Exc'
                    );

SELECT rd.* FROM dbo.RateHeader rh
	INNER JOIN dbo.RateCOD rd ON rd.RateId = rh.RheId
WHERE rh.RheName IN ( 'Tarifario de servicio estandar', 'Tarifario destinos express center', 'Promo Mita Mita Exc'
                    , 'Promo Mita Mita Destinos Exc'
                    );


SELECT * FROM dbo.ConfigParams
WHERE Name ='CODRateDef'

----- ******************* FIN  BACKUP ******************************************************************************


----- ******************* ACTUALIZACIÓN DE DATOS *******************************************************************

UPDATE dbo.RateHeader
SET	 CollectRate = 4
WHERE RheName IN ( 'Tarifario de servicio estandar', 'Tarifario destinos express center', 'Promo Mita Mita Exc'
                    , 'Promo Mita Mita Destinos Exc'
                    );


UPDATE rd
SET	rd.CODRate = 3.8
FROM dbo.RateHeader rh
	INNER JOIN dbo.RateCOD rd ON rd.RateId = rh.RheId
WHERE rh.RheName IN ( 'Tarifario de servicio estandar', 'Tarifario destinos express center', 'Promo Mita Mita Exc'
                    , 'Promo Mita Mita Destinos Exc'
                    );


UPDATE dbo.ConfigParams
SET	 Value ='3.8'
WHERE Name ='CODRateDef'



----- ******************* FIN ACTUALIZACIÓN DE DATOS *******************************************************************


----- ******************* NUEVOS  DATOS ********************************************************************************

SELECT * FROM dbo.RateHeader

WHERE RheName IN ( 'Tarifario de servicio estandar', 'Tarifario destinos express center', 'Promo Mita Mita Exc'
                    , 'Promo Mita Mita Destinos Exc'
                    );

SELECT rd.* FROM dbo.RateHeader rh
	INNER JOIN dbo.RateCOD rd ON rd.RateId = rh.RheId
WHERE rh.RheName IN ( 'Tarifario de servicio estandar', 'Tarifario destinos express center', 'Promo Mita Mita Exc'
                    , 'Promo Mita Mita Destinos Exc'
                    );


SELECT * FROM dbo.ConfigParams
WHERE Name ='CODRateDef'
----- *******************  FIN NUEVOS  DATOS ********************************************************************************