CREATE FUNCTION FnRemoveAccents ( @String VARCHAR(MAX) )
RETURNS VARCHAR(MAX)
AS 
BEGIN
    RETURN 	
	REPLACE(REPLACE( /*vowel ÃÕ*/
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( /*vowel ÄËÏÖÜ*/
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( /*vowel ÂÊÎÔÛ*/
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( /*vowel ÀÈÌÒÙ*/
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( /*vowel ÁÉÍÓÚ*/
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( /*vowel ñÑçÇ  include blank space*/
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( /*vowel äëïöü*/
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( /*vowel âêîôû*/
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( /*vowel àèìòù*/
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( /*vowel áéíóú*/ @String, 'á', 'a'), 'é','e'), 'í', 'i'), 'ó', 'o'), 'ú','u')		
			,'à','a'),'è','e'),'ì','i'),'ò','o'),'ù','u')
			,'â','a'),'ê','e'),'î','i'),'ô','o'),'û','u')
			,'ä','a'),'ë','e'),'ï','i'),'ö','o'),'ü','u')
			,'ñ','n'),'Ñ','N'),'ç','c'),'Ç','C'),' ','')
			,'Á','A'),'É','E'),'Í','I'),'Ó','O'),'Ú','U') 
			,'À','A'),'È','E'),'Ì','I'),'Ò','O'),'Ù','U') 
			,'Â','A'),'Ê','E'),'Î','I'),'Ô','O'),'Û','U')
			,'Ä','A'),'Ë','E'),'Ï','I'),'Ö','O'),'Ü','U') 
			,'Ã','A'),'Õ','O')  
END