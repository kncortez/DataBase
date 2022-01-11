USE [DeliveryBackOffice]

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Radio Dispatch'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Operaciones')
           ,'Submenu Radio Dispatch'
           ,'Submenu'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Recolecciones'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Operaciones')
           ,'Submenu Recolecciones'
           ,'Submenu'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Entregas'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Operaciones')
           ,'Submenu Entregas'
           ,'Submenu'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

UPDATE [dbo].[CatModule]
	SET ModIdModuleParent = (SELECT ModIdModule FROM CatModule WHERE ModName = 'Operaciones')
		,ModPath = 'Submenu COD'
		,ModDescription = 'Submenu'
		,ModTokenUpdated = 'SYS-OMORALES'
		,ModDateUpdated = GETDATE()
	WHERE ModIdModule = (SELECT ModIdModule FROM CatModule WHERE ModName = 'COD')

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Linehauls'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Operaciones')
           ,'Submenu Linehauls'
           ,'Submenu'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Centro de Distribución (CEDIS)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Operaciones')
           ,'Submenu Centro de Distribución (CEDIS)'
           ,'Submenu'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Gestión'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Operaciones')
           ,'Submenu Gestión Operaciones'
           ,'Submenu'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

UPDATE [dbo].[CatModule]
	SET ModIdModuleParent = (SELECT ModIdModule FROM CatModule WHERE ModName = 'Operaciones')
		,ModPath = 'Submenu Call Center Operativo'
		,ModDescription = 'Submenu'
		,ModTokenUpdated = 'SYS-OMORALES'
		,ModDateUpdated = GETDATE()
	WHERE ModIdModule = (SELECT ModIdModule FROM CatModule WHERE ModName = 'Call Center Operativo')



--Submenu Radio Dispatch
INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Monitoreo de Rutas'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Radio Dispatch')
           ,'RouteMonitor'
           ,'Form Monitoreo de Rutas'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Validación de Evidencias'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Radio Dispatch')
           ,'FormProofOnDelivery'
           ,'Form Validación de Evidencias'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Reversión de estados'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Radio Dispatch')
           ,'FrmReversalStatus'
           ,'Form Reversión de estados'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)


INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Coberturas'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Radio Dispatch')
           ,'FormCobertura'
           ,'Form Coberturas'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)


-- Submenú Recolecciones
INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Solicitudes (Recolecciones)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Recolecciones')
           ,'frmRoutePreparationPickUp'
           ,'Form Solicitudes (Recolecciones)'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)


INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Liquidación (Recolecciones)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Recolecciones')
           ,'frmLiquidPickUp'
           ,'Form Liquidación (Recolecciones)'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

-- Submenú Entregas
INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Preparación (Entregas)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Entregas')
           ,'frmRoutePreparation'
           ,'Form Preparación (Entregas)'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Despacho (Entregas)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Entregas')
           ,'frmCheckpoint'
           ,'Form Despacho (Entregas)'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Liquidación (Entregas)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Entregas')
           ,'frmRouteSettlement'
           ,'Form Liquidación (Entregas)'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Monitoreo de Rutas (Entregas)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Entregas')
           ,'frmRouteTracker'
           ,'Form Monitoreo de Rutas (Entregas)'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Confirmación de Entrega (Entregas)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Entregas')
           ,'frmConfirmationDelivery'
           ,'Form Confirmación de Entrega (Entregas)'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

-- Submenú Devolución
INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Preparación (Devoluciones)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Devoluciones')
           ,'RoutePreparationReturns'
           ,'Form Preparación (Devoluciones)'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Despacho (Devoluciones)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Devoluciones')
           ,'FrmCheckpointReturns'
           ,'Form Despacho (Devoluciones)'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Liquidación (Devoluciones)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Devoluciones')
           ,'SettlementByReturn'
           ,'Form Liquidación (Devoluciones)'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Confirmación de Devolución (Devoluciones)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Devoluciones')
           ,'ConfirmationOfReturns'
           ,'Form Confirmación de Devolución (Devoluciones)'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

-- Submenu COD

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Liquidación (COD)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'COD')
           ,'Submenu Liquidación (COD)'
           ,'Submenu'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

--Submenu Liquidación (COD)
INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Recolectoras (Liquidación (COD))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Liquidación (COD)')
           ,'RoutePickUpCODSettlement'
           ,'Form Recolectoras (Liquidación (COD))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)


INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('De última milla (Liquidación (COD))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Liquidación (COD)')
           ,'CODSettlement'
           ,'Form De última milla (Liquidación (COD))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)
------------------------------------------------------------------------
INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Guías por pagar COD (COD)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'COD')
           ,'FrmGuidesToPay'
           ,'Form Guías por pagar COD (COD)'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Modificación COD (COD)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'COD')
           ,'FrmAuthorizeWithoutCharge'
           ,'Form Modificación COD (COD)'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)
----------------------------------------------
--Submenú Reportes (COD)
INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Reportes (COD)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'COD')
           ,'Submenu Reportes (COD)'
           ,'Submenu'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)


INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Depósitos COD a clientes (Reportes (COD))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Reportes (COD)')
           ,'FrmCODDepositReport'
           ,'Form Depósitos COD a clientes (Reportes (COD))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Reporte modificación de montos COD (Reportes (COD))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Reportes (COD)')
           ,'FormDateGuide'
           ,'Form Reporte modificación de montos COD (Reportes (COD))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Liquidación por Hub (Reportes (COD))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Reportes (COD)')
           ,'FrmDateHubs'
           ,'Form Liquidación por Hub (Reportes (COD))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

--Submenu Linehauls
INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Despacho (Linehauls)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Linehauls')
           ,'LinehaulAssign'
           ,'Form Despacho (Linehauls)'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Liquidación (Linehauls)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Linehauls')
           ,'SettlementByLinehauls'
           ,'Form Liquidación (Linehauls)'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

-- Submenu Centro de Distribución (CEDIS)
INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Registro Ubicación (Centro de Distribución (CEDIS))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Centro de Distribución (CEDIS)')
           ,'FrmRegisterLocation'
           ,'Form Registro Ubicación (Centro de Distribución (CEDIS))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Registro de sobres (Centro de Distribución (CEDIS))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Centro de Distribución (CEDIS)')
           ,'FrmRegisterEnvelope'
           ,'Form Registro de sobres (Centro de Distribución (CEDIS))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Pesos y Dimensiones (Centro de Distribución (CEDIS))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Centro de Distribución (CEDIS)')
           ,'RegisterWeightDimensions'
           ,'Form Pesos y Dimensiones (Centro de Distribución (CEDIS))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

--Submenu Reportes (Centro de Distribución (CEDIS))
INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Reportes (Centro de Distribución (CEDIS))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Centro de Distribución (CEDIS)')
           ,'Submenu Reportes (Centro de Distribución (CEDIS))'
           ,'Submenu'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Informe de inventario por estado (Reportes (Centro de Distribución (CEDIS)))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Reportes (Centro de Distribución (CEDIS))')
           ,'Submenu Informe de inventario por estado (Reportes (Centro de Distribución (CEDIS)))'
           ,'Submenu'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Informe de arribo de piezas (Reportes (Centro de Distribución (CEDIS)))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Reportes (Centro de Distribución (CEDIS))')
           ,'Submenu Informe de arribo de piezas (Reportes (Centro de Distribución (CEDIS)))'
           ,'Submenu'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Producto vencido (Informe de inventario por estado (Reportes (Centro de Distribución (CEDIS))))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Informe de inventario por estado (Reportes (Centro de Distribución (CEDIS)))')
           ,'ProductoVencido'
           ,'Form Producto vencido (Informe de inventario por estado (Reportes (Centro de Distribución (CEDIS))))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Producto huérfano (Informe de inventario por estado (Reportes (Centro de Distribución (CEDIS))))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Informe de inventario por estado (Reportes (Centro de Distribución (CEDIS)))')
           ,'ProductoHuerfano'
           ,'Form Producto huérfano (Informe de inventario por estado (Reportes (Centro de Distribución (CEDIS))))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Inventario retorno a origen (Informe de inventario por estado (Reportes (Centro de Distribución (CEDIS))))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Informe de inventario por estado (Reportes (Centro de Distribución (CEDIS)))')
           ,'RetornoOrigen'
           ,'Form Inventario retorno a origen (Informe de inventario por estado (Reportes (Centro de Distribución (CEDIS))))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Producto vigente (Informe de inventario por estado (Reportes (Centro de Distribución (CEDIS))))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Informe de inventario por estado (Reportes (Centro de Distribución (CEDIS)))')
           ,'ProductoVigente'
           ,'Form Producto vigente (Informe de inventario por estado (Reportes (Centro de Distribución (CEDIS))))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Resumen por manifiesto declarado (Informe de arribo de piezas (Reportes (Centro de Distribución (CEDIS))))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Informe de arribo de piezas (Reportes (Centro de Distribución (CEDIS)))')
           ,'WarehouseReports/ManifestDeclared'
           ,'Form Resumen por manifiesto declarado (Informe de arribo de piezas (Reportes (Centro de Distribución (CEDIS))))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Guías declaradas no arribadas (Informe de arribo de piezas (Reportes (Centro de Distribución (CEDIS))))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Informe de arribo de piezas (Reportes (Centro de Distribución (CEDIS)))')
           ,'WarehouseReports/GuideDeclaredNotArrived'
           ,'Form Guías declaradas no arribadas (Informe de arribo de piezas (Reportes (Centro de Distribución (CEDIS))))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

-- Submenu Gestión (Operaciones)
INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Gestión (Operaciones)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Operaciones')
           ,'Submenu Gestión (Operaciones)'
           ,'Submenu'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Personal (Gestión (Operaciones))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Gestión (Operaciones)')
           ,'FrmSenderReceiver'
           ,'Form Personal (Gestión (Operaciones))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Flota (Gestión (Operaciones))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Gestión (Operaciones)')
           ,'FleetManagement'
           ,'Form Flota (Gestión (Operaciones))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Rutas (Gestión (Operaciones))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Gestión (Operaciones)')
           ,'frmRouteManagement'
           ,'Form Rutas (Gestión (Operaciones))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

-- Submenu Reportes (Gestión (Operaciones))
INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Reportes (Gestión (Operaciones))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Gestión (Operaciones)')
           ,'Submenu Reportes (Gestión (Operaciones))'
           ,'Submenu'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

-- Submenu Servicios por courier (Reportes (Gestión (Operaciones)))
INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Servicios por courier (Reportes (Gestión (Operaciones)))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Reportes (Gestión (Operaciones))')
           ,'Submenu Servicios por courier (Reportes (Gestión (Operaciones)))'
           ,'Submenu'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Entregas por courier (Servicios por courier (Reportes (Gestión (Operaciones))))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Servicios por courier (Reportes (Gestión (Operaciones)))')
           ,'WarehouseReports/DeliveryBySender'
           ,'Form Entregas por courier (Servicios por courier (Reportes (Gestión (Operaciones))))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Rutas Última Milla (Servicios por courier (Reportes (Gestión (Operaciones))))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Servicios por courier (Reportes (Gestión (Operaciones)))')
           ,'InformeRutasUltimaMilla'
           ,'Form Rutas Última Milla (Servicios por courier (Reportes (Gestión (Operaciones))))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

      
UPDATE CatModule 
SET ModName = 'Administrador de estados (Gestión (Operaciones))'
   ,ModIdModuleParent = (SELECT ModIdModule FROM CatModule WHERE ModName = 'Gestión (Operaciones)')
   ,ModDescription = 'Form Administrador de estados (Gestión (Operaciones))'
   ,ModTokenUpdated = 'SYS-OMORALES'
   ,ModDateUpdated = GETDATE()
WHERE ModPath = 'StatesAdmin';


-- Submenu Call Center Operativo (Operaciones)
UPDATE CatModule 
SET ModName = 'Call Center Operativo (Operaciones)'
   ,ModIdModuleParent = (SELECT ModIdModule FROM CatModule WHERE ModName = 'Operaciones')
   ,ModPath = 'Submenu Call Center Operativo (Operaciones)'
   ,ModDescription = 'Submenu'
   ,ModTokenUpdated = 'SYS-OMORALES'
   ,ModDateUpdated = GETDATE()
WHERE ModPath = 'Submenu Call Center Operativo';

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Confirmaciones (Call Center Operativo (Operaciones))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Call Center Operativo (Operaciones)')
           ,'GuideEdition'
           ,'Form Confirmaciones (Call Center Operativo (Operaciones))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Redirección de Paquetes a Express Center (Call Center Operativo (Operaciones))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Call Center Operativo (Operaciones)')
           ,'ConfirmationOfReturns'
           ,'Form Redirección de Paquetes a Express Center (Call Center Operativo (Operaciones))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

UPDATE CatModule 
SET ModName = 'Monitoreo de alertas (Call Center Operativo (Operaciones))'
   ,ModIdModuleParent = (SELECT ModIdModule FROM CatModule WHERE ModName = 'Call Center Operativo (Operaciones)')
   ,ModDescription = 'Form Monitoreo de alertas (Call Center Operativo (Operaciones))'
   ,ModTokenUpdated = 'SYS-OMORALES'
   ,ModDateUpdated = GETDATE()
WHERE ModPath = 'AlertedGuideMonitor';


-- Submenu Gestión (Comercial)
UPDATE CatModule 
SET ModName = 'Gestión (Comercial)'
   ,ModIdModuleParent = (SELECT ModIdModule FROM CatModule WHERE ModName = 'Comercial')
   ,ModPath = 'Submenu Gestión (Comercial)'
   ,ModDescription = 'Submenu'
   ,ModTokenUpdated = 'SYS-OMORALES'
   ,ModDateUpdated = GETDATE()
WHERE ModPath = 'Menu Gestion';


UPDATE CatModule 
SET ModName = 'Socios de Negocio (Gestión (Comercial))'
   ,ModIdModuleParent = (SELECT ModIdModule FROM CatModule WHERE ModName = 'Gestión (Comercial)')
   ,ModDescription = 'Form Socios de Negocio (Gestión (Comercial))'
   ,ModTokenUpdated = 'SYS-OMORALES'
   ,ModDateUpdated = GETDATE()
WHERE ModPath = 'FrmBusinessPartner';

UPDATE CatModule 
SET ModName = 'Puntos de Visita (Gestión (Comercial))'
   ,ModIdModuleParent = (SELECT ModIdModule FROM CatModule WHERE ModName = 'Gestión (Comercial)')
   ,ModDescription = 'Form Puntos de Visita (Gestión (Comercial))'
   ,ModTokenUpdated = 'SYS-OMORALES'
   ,ModDateUpdated = GETDATE()
WHERE ModPath = 'FrmVisitPoint';

UPDATE CatModule 
SET ModName = 'Tarifas (Gestión (Comercial))'
   ,ModIdModuleParent = (SELECT ModIdModule FROM CatModule WHERE ModName = 'Gestión (Comercial)')
   ,ModDescription = 'Form Tarifas (Gestión (Comercial))'
   ,ModTokenUpdated = 'SYS-OMORALES'
   ,ModDateUpdated = GETDATE()
WHERE ModPath = 'FrmRateTemplate';

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Piezas Irregulares (Gestión (Comercial))'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Gestión (Comercial)')
           ,'FrmIrregularPieces'
           ,'Form Piezas Irregulares (Gestión (Comercial))'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)

--  Facturación
UPDATE CatModule 
SET ModName = 'Emisión de Facturas (Facturación)'
   ,ModIdModuleParent = (SELECT ModIdModule FROM CatModule WHERE ModName = 'Facturación' AND ModPath = 'Menu Facturación')
   ,ModDescription = 'Form Emisión de Facturas (Facturación)'
   ,ModTokenUpdated = 'SYS-OMORALES'
   ,ModDateUpdated = GETDATE()
WHERE ModPath = 'FrmBilling';

INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated]
           ,[ModTokenUpdated]
           ,[ModDateUpdated])
     VALUES
           ('Documentos digitalizados (Facturación)'
           ,(SELECT ModIdModule FROM CatModule WHERE ModName = 'Facturación' AND ModPath = 'Menu Facturación')
           ,'frmScannedDocuments'
           ,'Form Documentos digitalizados (Facturación)'
           ,1
           ,NULL
           ,1
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,NULL
           ,NULL)