/***********ACTUALIZACION DE PAIS, POR DEFAULT GT PARA LOS NULL*************************/
UPDATE SenderReceiver SET IdCountry = 'GT' 
WHERE IdCountry IS NULL 
AND Estatus = 1