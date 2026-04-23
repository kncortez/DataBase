--**********************************************
--**********************************************

--NOTA:Abreviaciones consultadas en produccion

--**********************************************
--**********************************************

BEGIN TRY

	UPDATE CS SET CS.RackPositionDefault = '00#BAR000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='BAR'
	UPDATE CS SET CS.RackPositionDefault = '00#CDHUE000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='CDHUE'
	UPDATE CS SET CS.RackPositionDefault = '00#CDGUA000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='CDGUA'
	UPDATE CS SET CS.RackPositionDefault = '00#CDQUE000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='CDQUE'
	UPDATE CS SET CS.RackPositionDefault = '00#CDRAN000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='CDRAN'
	UPDATE CS SET CS.RackPositionDefault = '00#CHI000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='CHI'
	UPDATE CS SET CS.RackPositionDefault = '00#CHQ000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='CHQ'
	UPDATE CS SET CS.RackPositionDefault = '00#COA000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='COA'
	UPDATE CS SET CS.RackPositionDefault = '00#COB000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='COB'
	UPDATE CS SET CS.RackPositionDefault = '00#DEM000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='DEM'
	UPDATE CS SET CS.RackPositionDefault = '00#ESC000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='ESC'
	UPDATE CS SET CS.RackPositionDefault = '00#GTE000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='GTE'
	UPDATE CS SET CS.RackPositionDefault = '00#GTN000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='GTN'
	UPDATE CS SET CS.RackPositionDefault = '00#GTO000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='GTO'
	UPDATE CS SET CS.RackPositionDefault = '00#GTS000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='GTS'
	UPDATE CS SET CS.RackPositionDefault = '00#GUA000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='GUA'
	UPDATE CS SET CS.RackPositionDefault = '00#HUE000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='HUE'
	UPDATE CS SET CS.RackPositionDefault = '00#JAL000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='JAL'
	UPDATE CS SET CS.RackPositionDefault = '00#JUT000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='JUT'
	UPDATE CS SET CS.RackPositionDefault = '00#MAL000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='MAL'
	UPDATE CS SET CS.RackPositionDefault = '00#MAZ000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='MAZ'
	UPDATE CS SET CS.RackPositionDefault = '00#MOR000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='MOR'
	UPDATE CS SET CS.RackPositionDefault = '00#PET000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='PET'
	UPDATE CS SET CS.RackPositionDefault = '00#POP000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='POP'
	UPDATE CS SET CS.RackPositionDefault = '00#QUE000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='QUE'
	UPDATE CS SET CS.RackPositionDefault = '00#QUI000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='QUI'
	UPDATE CS SET CS.RackPositionDefault = '00#RAN000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='RAN'
	UPDATE CS SET CS.RackPositionDefault = '00#SAC000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='SAC'
	UPDATE CS SET CS.RackPositionDefault = '00#SAL000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='SAL'
	UPDATE CS SET CS.RackPositionDefault = '00#SLC000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='SLC'
	UPDATE CS SET CS.RackPositionDefault = '00#SLM000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='SLM'
	UPDATE CS SET CS.RackPositionDefault = '00#SMA000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='SMA'
	UPDATE CS SET CS.RackPositionDefault = '00#SOL000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='SOL'
	UPDATE CS SET CS.RackPositionDefault = '00#TEC000#BOX000' FROM DeliveryBackOffice.dbo.CatStation cs INNER JOIN DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) ON hb.IdHubLogistic = cs.HubLogisticId WHERE cs.StationType=1 AND hb.HubAbbreviation ='TEC'

	UPDATE CS SET CS.RackPositionDefault = '00#CHO000#BOX000' FROM DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) INNER JOIN DeliveryBackOffice.dbo.CatStation cs WITH(NOLOCK) on cs.IdStation = hb.IdStation where cs.StationType=1 AND hb.HubAbbreviation ='CHO'
	UPDATE CS SET CS.RackPositionDefault = '00#COM000#BOX000' FROM DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) INNER JOIN DeliveryBackOffice.dbo.CatStation cs WITH(NOLOCK) on cs.IdStation = hb.IdStation where cs.StationType=1 AND hb.HubAbbreviation ='COM'
	UPDATE CS SET CS.RackPositionDefault = '00#DAN000#BOX000' FROM DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) INNER JOIN DeliveryBackOffice.dbo.CatStation cs WITH(NOLOCK) on cs.IdStation = hb.IdStation where cs.StationType=1 AND hb.HubAbbreviation ='DAN'
	UPDATE CS SET CS.RackPositionDefault = '00#JTI000#BOX000' FROM DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) INNER JOIN DeliveryBackOffice.dbo.CatStation cs WITH(NOLOCK) on cs.IdStation = hb.IdStation where cs.StationType=1 AND hb.HubAbbreviation ='JTI'
	UPDATE CS SET CS.RackPositionDefault = '00#LCE000#BOX000' FROM DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) INNER JOIN DeliveryBackOffice.dbo.CatStation cs WITH(NOLOCK) on cs.IdStation = hb.IdStation where cs.StationType=1 AND hb.HubAbbreviation ='LCE'
	UPDATE CS SET CS.RackPositionDefault = '00#SAP000#BOX000' FROM DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) INNER JOIN DeliveryBackOffice.dbo.CatStation cs WITH(NOLOCK) on cs.IdStation = hb.IdStation where cs.StationType=1 AND hb.HubAbbreviation ='SAP'
	UPDATE CS SET CS.RackPositionDefault = '00#SIG000#BOX000' FROM DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) INNER JOIN DeliveryBackOffice.dbo.CatStation cs WITH(NOLOCK) on cs.IdStation = hb.IdStation where cs.StationType=1 AND hb.HubAbbreviation ='SIG'
	UPDATE CS SET CS.RackPositionDefault = '00#SRO000#BOX000' FROM DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) INNER JOIN DeliveryBackOffice.dbo.CatStation cs WITH(NOLOCK) on cs.IdStation = hb.IdStation where cs.StationType=1 AND hb.HubAbbreviation ='SRO'
	UPDATE CS SET CS.RackPositionDefault = '00#TGU000#BOX000' FROM DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) INNER JOIN DeliveryBackOffice.dbo.CatStation cs WITH(NOLOCK) on cs.IdStation = hb.IdStation where cs.StationType=1 AND hb.HubAbbreviation ='TGU'
	UPDATE CS SET CS.RackPositionDefault = '00#TOC000#BOX000' FROM DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) INNER JOIN DeliveryBackOffice.dbo.CatStation cs WITH(NOLOCK) on cs.IdStation = hb.IdStation where cs.StationType=1 AND hb.HubAbbreviation ='TOC'
	UPDATE CS SET CS.RackPositionDefault = '00#LLB000#BOX000' FROM DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) INNER JOIN DeliveryBackOffice.dbo.CatStation cs WITH(NOLOCK) on cs.IdStation = hb.IdStation where cs.StationType=1 AND hb.HubAbbreviation ='LLB'
	UPDATE CS SET CS.RackPositionDefault = '00#SMG000#BOX000' FROM DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) INNER JOIN DeliveryBackOffice.dbo.CatStation cs WITH(NOLOCK) on cs.IdStation = hb.IdStation where cs.StationType=1 AND hb.HubAbbreviation ='SMG'
	UPDATE CS SET CS.RackPositionDefault = '00#SNA000#BOX000' FROM DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) INNER JOIN DeliveryBackOffice.dbo.CatStation cs WITH(NOLOCK) on cs.IdStation = hb.IdStation where cs.StationType=1 AND hb.HubAbbreviation ='SNA'
	UPDATE CS SET CS.RackPositionDefault = '00#SSV000#BOX000' FROM DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) INNER JOIN DeliveryBackOffice.dbo.CatStation cs WITH(NOLOCK) on cs.IdStation = hb.IdStation where cs.StationType=1 AND hb.HubAbbreviation ='SSV'
	UPDATE CS SET CS.RackPositionDefault = '00#SSZ000#BOX000' FROM DeliveryBackOffice.dbo.HubLogistics hb WITH(NOLOCK) INNER JOIN DeliveryBackOffice.dbo.CatStation cs WITH(NOLOCK) on cs.IdStation = hb.IdStation where cs.StationType=1 AND hb.HubAbbreviation ='SSZ'



PRINT 'ACTUALIZACION REALIZADA CON EXITO!'
END TRY
BEGIN CATCH
	PRINT 'ERROR:'  + ERROR_MESSAGE();
	THROW;
END CATCH