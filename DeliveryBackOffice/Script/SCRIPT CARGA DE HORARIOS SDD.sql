    update dbo.CatTypeService
  set LimitHourDelivery ='21:00:00'
  , LimitHourPickup ='13:30:00'
  where CtsShortName = 'SDD'