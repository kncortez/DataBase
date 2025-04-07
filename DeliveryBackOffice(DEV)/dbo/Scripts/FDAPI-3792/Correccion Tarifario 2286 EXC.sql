UPDATE RateData
set RateValue = RateValue - 5,
TokenUpdated = 'SYS-BPEDROZA',
DateUpdated = GETDATE()
where RateId =2286
and RowStatus = 1 
and TypeServiceId is not null
and TypeServiceId IN (5,6)