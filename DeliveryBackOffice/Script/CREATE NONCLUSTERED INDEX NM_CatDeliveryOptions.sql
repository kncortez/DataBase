CREATE NONCLUSTERED INDEX NM_CatDeliveryOptions 
  ON CatDeliveryOptions(Name)
  INCLUDE (IdDeliveryOption)