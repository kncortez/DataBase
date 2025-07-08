--Version C  
--USE DeliveryBackOffice;  
create procedure analisis_recolecciones   
  
as   
begin  
  
SELECT tmp.IdServiceManagement                                           IdServiceManagement  
     , tmp.RequestDate                                                   RequestDate  
     , tmp.StartDate                                                     StartDate  
     , tmp.EndDate                                                       EndDate  
     , tmp.NameSystem                                                    NameSystem  
     , tmp.IdServiceStatus                                               IdServiceStatus  
     , tmp.Name                                                          Name  
     , tmp.Courier                                                       Courier  
     , tmp.TypeVehicle                                                   TypeVehicle  
     , tmp.PickupType                                                    PickupType  
     , tmp.SenderId                                                      SenderId  
     , tmp.SenderName                                                    SenderName  
     , tmp.IdCustomer                                                    IdCustomer  
     , tmp.CustomerName                                                  CustomerName  
     , MAX(tmp.IdIncidence)                                              IdIncidence  
     , MAX(tmp.DescriptionIncidence)                                     DescriptionIncidence  
     , tmp.IdHubLogistics                                                IdHubLogistics  
     , tmp.HubAbbreviation                                               HubAbbreviation  
     , tmp.CountGuides                                                   CountGuides  
     , tmp.PUSuccess                                                     PUSuccess  
     , tmp.RealPickupDate                                                RealPickupDate  
     , tmp.Latitude                                                      Latitude  
     , tmp.Longitude                                                     Longitude  
     , IIF(ABS(tmp.Latitude) > 0, 1, 0)                                  Georeference  
     , DATEDIFF(HOUR, tmp.StartDate, tmp.RealPickupDate)                 DifStartPickup  
     , IIF(DATEDIFF(HOUR, tmp.StartDate, tmp.RealPickupDate) <= 2, 1, 0) OnTime     -- cambio en el cálculo de 1 a 2 horas para el rango horario  
     , IIF(DATEPART(HOUR, tmp.RequestDate) > 16, 1, 0)                   AfterHour  
     , tmp.CountPieces                                                   CountPieces  
     , tmp.AssingDate                                                    AssingDate  
     , DATEDIFF(HOUR, tmp.RequestDate, tmp.AssingDate)                   DifRequestAssing  
     , DATENAME(WEEKDAY, tmp.StartDate)                                  StartDay  
     , IIF(DATEDIFF(DAY, tmp.StartDate, tmp.RealPickupDate) <= 1, 1, 0)  OnTimeDate -- nuevo cálculo de on time para el mismo día, obviando la hora  
  , tmp.IDtownsk  
FROM  
(  
    SELECT SEM.IdServiceManagement  
         , SCP.DateCreated                                                                            'RequestDate'  
         , SCP.StartDate  
         , SCP.EndDate  
         , ISNULL(CS.SysNameSystem, 'Hermes Web')                                                     'NameSystem'  
         , CSS.IdServiceStatus  
         , CSS.Name  
         , SRE.First_Name + ' ' + SRE.Last_Name                                                       'Courier'  
         , CTV.Name                                                                                   'TypeVehicle'  
         , IIF(SCP.IsScheduled IS NULL, 'Demanda', IIF(SCP.IsScheduled = 0, 'Demanda', 'Programada')) 'PickupType'  
         , SCP.SenderId  
         , SCP.SenderName  
         , CTM.IdCustomer                                                                             IdCustomer  
         , CTM.Name                                                                                   'CustomerName'  
         , INS.IdIncidence  
         , INS.DescriptionIncidence  
         , SCP.IdHubLogistics  
         ,  ISNULL(conv.Hub, HBL.HubAbbreviation) HubAbbreviation  
   , conv.IdTownship [IDtownsk]  
         , (  
               SELECT COUNT(1)  
               FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DOP WITH (NOLOCK)  
               WHERE DOP.IdHeaderRecolection = SCP.SchedulePickupId  
           )                                                                                          'CountGuides'  
         , (  
               SELECT COUNT(1)  
               FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DOP WITH (NOLOCK)  
                   INNER JOIN dbo.DeliveryOrderPiece                  DPP WITH (NOLOCK)  
                       ON DPP.GuideSerie = DOP.GuideSerie  
                          AND DPP.GuideNumber = DOP.GuideNumber  
               WHERE DOP.IdHeaderRecolection = SCP.SchedulePickupId  
           )                                                                                          'CountPieces'  
         , IIF((  
                   SELECT TOP 1  
                          DOD.DateCreatedInSystem  
                   FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail    DOP WITH (NOLOCK)  
                       INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK)  
                           ON DOP.GuideNumber = DOD.Guide_Number  
                   WHERE DOP.IdHeaderRecolection = SCP.SchedulePickupId  
                         AND DOD.StatusOrderId IN ( 2, 11, 20 ) --Recolectado, arribo, traslado a Exc  
               ) IS NULL  
             , 0  
             , 1)                                                                                     PUSuccess  
         , (  
               SELECT TOP 1  
                      DOD.DateCreatedInSystem  
               FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail    DOP WITH (NOLOCK)  
                   INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderDetail DOD WITH (NOLOCK)  
                       ON DOP.GuideNumber = DOD.Guide_Number  
               WHERE DOP.IdHeaderRecolection = SCP.SchedulePickupId  
                     AND DOD.StatusOrderId IN ( 2, 11, 20 ) --Recolectado, arribo, traslado a Exc  
               ORDER BY DOD.StatusOrderId ASC  
           )                                                                                          RealPickupDate --Fecha real de recolección se tomara una de todas las guías relacionadas  
  
         , ISNULL((  
                      SELECT TOP 1  
                             ev.DateCreated  
                      FROM dbo.EventService ev WITH (NOLOCK)  
                      WHERE ev.ServiceStatusId = 2  
                            AND ev.ServiceManagementId = SEM.IdServiceManagement  
                      ORDER BY DateCreated DESC  
                  )  
                , SEM.DateCreated  
                 )                                                                                    AssingDate  
         , VPC.Latitude  
         , VPC.Longitude  
    FROM DeliveryBackOffice.dbo.SchedulePickup              SCP WITH (NOLOCK)  
        INNER JOIN DeliveryBackOffice.dbo.ServiceManagement SEM WITH (NOLOCK)  
            ON SEM.IdSchedulePickup = SCP.SchedulePickupId  
        INNER JOIN DeliveryBackOffice.dbo.CatServiceStatus  CSS WITH (NOLOCK)  
            ON CSS.IdServiceStatus = SEM.ServiceStatusId  
        INNER JOIN DeliveryBackOffice.dbo.SenderReceiver    SRE WITH (NOLOCK)  
            ON SRE.ID = SEM.IdPuCourrier  
        LEFT JOIN DeliveryBackOffice.dbo.CatTypeVehicle     CTV WITH (NOLOCK)  
            ON SCP.TypeVehicleId = CTV.IdTypeVehicle  
        LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient   VPC WITH (NOLOCK)  
            ON VPC.CodeOfReference = SCP.SenderId  
        LEFT JOIN DeliveryBackOffice.dbo.Customer           CTM WITH (NOLOCK)  
            ON CTM.IdCustomer = VPC.CustomerID  
        LEFT JOIN DeliveryBackOffice.dbo.IncidenceServices  INS WITH (NOLOCK)  
            ON INS.ServiceManagementId = SEM.IdServiceManagement  
        LEFT JOIN DeliveryBackOffice.dbo.HubLogistics       HBL WITH (NOLOCK)  
            ON HBL.IdHubLogistic = ISNULL(SCP.IdHubLogistics, sre.HubLogisticId)  
        LEFT JOIN DeliveryBackOffice.dbo.CatSystem          CS WITH (NOLOCK)  
            ON SCP.IdSourcePlataform = CS.SysIdSystem  
   OUTER APPLY (SELECT TOP 1 dpm.Hub , tn.IdTownship  FROM dbo.DumpServiceCoverage dpm WITH(NOLOCK)   
  
 INNER JOIN dbo.Township tn WITH(NOLOCK) ON tn.HeaderCode = dpm.HeaderCode  
 WHERE tn.IdTownship = COALESCE(SCP.TownshipId, vpc.IdTownship)  
 --ORDER BY  dmp.Hub  
 ) conv  
-- WHERE CONVERT(DATE,SCP.DateCreated) = CONVERT(DATE, GETDATE())  
) tmp  
WHERE CONVERT(DATE, tmp.RequestDate) >= '2024-01-01'  
GROUP BY tmp.IdServiceManagement  
       , tmp.RequestDate  
       , tmp.StartDate  
       , tmp.EndDate  
       , tmp.NameSystem  
       , tmp.IdServiceStatus  
       , tmp.Name  
       , tmp.Courier  
       , tmp.TypeVehicle  
       , tmp.PickupType  
       , tmp.SenderId  
       , tmp.SenderName  
       , tmp.IdCustomer  
       , tmp.CustomerName  
       , tmp.IdHubLogistics  
       , tmp.HubAbbreviation  
       , tmp.CountGuides  
       , tmp.PUSuccess  
       , tmp.RealPickupDate  
       , tmp.Latitude  
       , tmp.Longitude  
       , tmp.CountPieces  
       , tmp.AssingDate  
    , tmp.IDtownsk;  
  
end