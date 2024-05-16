
--Script para actualizar menu, validar Id del menu en QA 
UPDATE  [DeliveryBackOffice].[dbo].[CatModule]
SET ModName ='Canje de Beneficios',
    ModPath = '/affiliate/redeem-center',
	ModDescription='Centro de Canje',
	ModMetadata='fa fa-store fa-1x',
	ModTokenUpdated='sys-evasquez'	
	ModDateUpdated=GETDATE()
WHERE ModName = 'Mi Club Forza'
AND ModIdModule=94
