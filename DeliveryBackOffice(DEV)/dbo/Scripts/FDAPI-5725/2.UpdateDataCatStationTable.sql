/*
    Actualizar los municipios de las estaciones que tienen CodeOfReference
*/

SELECT c.TownshipId, vpc.IdTownship, c.CodeOfReference, vpc.Town, * 
-- UPDATE c SET townshipid = vpc.IdTownship
FROM dbo.CatStation c
    INNER JOIN dbo.VisitPointClient vpc WITH(NOLOCK)
        ON c.CodeOfReference = vpc.CodeOfReference
WHERE c.RowStatus = 1 
    AND c.CodeOfReference IS NOT NULL

/*
    Actualizar los municipios de las estaciones sin CodeOfReference

    VALIDAR si todos los registros tienen TownshipId
*/

UPDATE dbo.CatStation SET TownshipId = 73 WHERE IdStation =  98
UPDATE dbo.CatStation SET TownshipId = 161 WHERE IdStation =  99
UPDATE dbo.CatStation SET TownshipId = 325 WHERE IdStation =  100
UPDATE dbo.CatStation SET TownshipId = 297 WHERE IdStation =  101
UPDATE dbo.CatStation SET TownshipId = 63 WHERE IdStation =  102
UPDATE dbo.CatStation SET TownshipId = 317 WHERE IdStation =  103
UPDATE dbo.CatStation SET TownshipId = 8 WHERE IdStation =  104
UPDATE dbo.CatStation SET TownshipId = 112 WHERE IdStation =  105
UPDATE dbo.CatStation SET TownshipId = 116 WHERE IdStation =  106
UPDATE dbo.CatStation SET TownshipId = 232 WHERE IdStation =  107
UPDATE dbo.CatStation SET TownshipId = 135 WHERE IdStation =  108
UPDATE dbo.CatStation SET TownshipId = 37 WHERE IdStation =  109
UPDATE dbo.CatStation SET TownshipId = 249 WHERE IdStation =  110
UPDATE dbo.CatStation SET TownshipId = 259 WHERE IdStation =  111
UPDATE dbo.CatStation SET TownshipId = 43 WHERE IdStation =  112
UPDATE dbo.CatStation SET TownshipId = 43 WHERE IdStation =  15
UPDATE dbo.CatStation SET TownshipId = 119 WHERE IdStation =  113
UPDATE dbo.CatStation SET TownshipId = 194 WHERE IdStation =  114
UPDATE dbo.CatStation SET TownshipId = 201 WHERE IdStation =  115
UPDATE dbo.CatStation SET TownshipId = 73 WHERE IdStation =  116
UPDATE dbo.CatStation SET TownshipId = 268 WHERE IdStation =  117
UPDATE dbo.CatStation SET TownshipId = 159 WHERE IdStation =  118
UPDATE dbo.CatStation SET TownshipId = 228 WHERE IdStation =  120
UPDATE dbo.CatStation SET TownshipId = 64 WHERE IdStation =  121
UPDATE dbo.CatStation SET TownshipId = 97 WHERE IdStation =  122
UPDATE dbo.CatStation SET TownshipId = 89 WHERE IdStation =  123
UPDATE dbo.CatStation SET TownshipId = 135 WHERE IdStation =  124
UPDATE dbo.CatStation SET TownshipId = 67 WHERE IdStation =  125
UPDATE dbo.CatStation SET TownshipId = 4 WHERE IdStation =  126
UPDATE dbo.CatStation SET TownshipId = 25 WHERE IdStation =  127
UPDATE dbo.CatStation SET TownshipId = 49 WHERE IdStation =  128
UPDATE dbo.CatStation SET TownshipId = 126 WHERE IdStation =  129
UPDATE dbo.CatStation SET TownshipId = 73 WHERE IdStation =  197
UPDATE dbo.CatStation SET TownshipId = 73 WHERE IdStation =  198
UPDATE dbo.CatStation SET TownshipId = 60 WHERE IdStation =  227
UPDATE dbo.CatStation SET TownshipId = 117 WHERE IdStation =  268
UPDATE dbo.CatStation SET TownshipId = 86 WHERE IdStation =  271
UPDATE dbo.CatStation SET TownshipId = 325 WHERE IdStation =  270
UPDATE dbo.CatStation SET TownshipId = 73 WHERE IdStation =  274
UPDATE dbo.CatStation SET TownshipId = 84 WHERE IdStation =  275
UPDATE dbo.CatStation SET TownshipId = 420 WHERE IdStation =  277
UPDATE dbo.CatStation SET TownshipId = 364 WHERE IdStation =  278
UPDATE dbo.CatStation SET TownshipId = 438 WHERE IdStation =  279
UPDATE dbo.CatStation SET TownshipId = 573 WHERE IdStation =  280
UPDATE dbo.CatStation SET TownshipId = 346 WHERE IdStation =  281
UPDATE dbo.CatStation SET TownshipId = 408 WHERE IdStation =  282
UPDATE dbo.CatStation SET TownshipId = 385 WHERE IdStation =  283
UPDATE dbo.CatStation SET TownshipId = 381 WHERE IdStation =  284
UPDATE dbo.CatStation SET TownshipId = 455 WHERE IdStation =  285
UPDATE dbo.CatStation SET TownshipId = 362 WHERE IdStation =  286
UPDATE dbo.CatStation SET TownshipId = 73 WHERE IdStation =  339
UPDATE dbo.CatStation SET TownshipId = 895 WHERE IdStation =  357
UPDATE dbo.CatStation SET TownshipId = 862 WHERE IdStation =  358
UPDATE dbo.CatStation SET TownshipId = 842 WHERE IdStation =  359
UPDATE dbo.CatStation SET TownshipId = 757 WHERE IdStation =  360
UPDATE dbo.CatStation SET TownshipId = 408 WHERE IdStation =  402
UPDATE dbo.CatStation SET TownshipId = 161 WHERE IdStation =  403
UPDATE dbo.CatStation SET TownshipId = 60 WHERE IdStation =  436
UPDATE dbo.CatStation SET TownshipId = 112 WHERE IdStation =  437
UPDATE dbo.CatStation SET TownshipId = 250 WHERE IdStation =  438
UPDATE dbo.CatStation SET TownshipId = 154 WHERE IdStation =  439



