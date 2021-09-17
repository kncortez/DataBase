--- Remover modulos que no usaran un usuario corporativo
SELECT * FROM RolByModuleBySystem

UPDATE RolByModuleBySystem
SET RmsRowStatus = 0
WHERE RmsIdRol =2 AND RmsIdModule=3;

UPDATE RolByModuleBySystem
SET RmsRowStatus = 0
WHERE RmsIdRol =2 AND RmsIdModule=4;

UPDATE RolByModuleBySystem
SET RmsRowStatus = 0
WHERE RmsIdRol =2 AND RmsIdModule=11;

UPDATE RolByModuleBySystem
SET RmsRowStatus = 0
WHERE RmsIdRol =2 AND RmsIdModule=14;
