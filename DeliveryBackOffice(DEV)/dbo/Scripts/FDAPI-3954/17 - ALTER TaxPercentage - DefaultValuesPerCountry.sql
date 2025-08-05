
--Juan Ramirez
--Add TaxPercentage
 -------------------------------

ALTER TABLE DefaultValuesPerCountry
  ADD TaxPercentage NVARCHAR(20);

-------------------------------

   UPDATE DefaultValuesPerCountry
    SET TaxPercentage = '1.12'
 WHERE IdCountry IN ('GT');

 UPDATE DefaultValuesPerCountry
    SET TaxPercentage = '1.15'
 WHERE IdCountry IN ('HN'); 

 UPDATE DefaultValuesPerCountry
    SET TaxPercentage = '1.13'
 WHERE IdCountry IN ('SV'); 

 -------------------------------
