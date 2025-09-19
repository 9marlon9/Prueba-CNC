* ************************************************************
* ARCHIVO: Angulo_Marlon_ejercicio_1.do
* PROYECTO: Prueba Técnica - Centro Nacional de Consultoría
* AUTOR: Marlon Angulo Ramos
* FECHA: 16/09/2025
* DESCRIPCIÓN: Análisis de datos educativos - Ejercicio 1
* ************************************************************
clear all

* Ejercicio 1: 

*1 Importar la base SEDES_DEF2022 a STATA
import excel using "https://github.com/9marlon9/Prueba-CNC/raw/main/SEDES_DEF2022.xlsx", firstrow clear

*1.2 Estandarizar texto en variables DEPARTAMENTO, SECRETARIA y MUNICIPIO
foreach var in DEPARTAMENTO SECRETARIA MUNICIPIO {
    * Convertir a mayúsculas y eliminar tildes específicas
    replace `var' = upper(`var')
    replace `var' = subinstr(`var', "Á", "A", .)
    replace `var' = subinstr(`var', "É", "E", .)
    replace `var' = subinstr(`var', "Í", "I", .)
    replace `var' = subinstr(`var', "Ó", "O", .)
    replace `var' = subinstr(`var', "Ú", "U", .)
    replace `var' = subinstr(`var', "Ñ", "N", .)
    replace `var' = subinstr(`var', "Ü", "U", .)
    replace `var' = subinstr(`var', "Ï", "I", .)
	
	replace `var' = subinstr(`var', "á", "A", .)
    replace `var' = subinstr(`var', "é", "E", .)
    replace `var' = subinstr(`var', "í", "I", .)
    replace `var' = subinstr(`var', "ó", "O", .)
    replace `var' = subinstr(`var', "ú", "U", .)
	replace `var' = subinstr(`var', "ü", "U", .)
    replace `var' = subinstr(`var', "ñ", "N", .)
    
    * Eliminar espacios adicionales y estandarizar
    replace `var' = strtrim(`var')
	replace `var' = subinstr(`var', "  ", " ", .)
    replace `var' = subinstr(`var', "   ", " ", .)
    replace `var' = subinstr(`var', ",", "", .)  // Eliminar comas
    replace `var' = subinstr(`var', ".", "", .)  // Eliminar puntos
}

* 1.3 Corregir nombre de Bogotá en variable DEPARTAMENTO
replace DEPARTAMENTO = "BOGOTA D.C." if DEPARTAMENTO == "CAPITAL BOGOTA DC" 
* 1.3.2 Corregir error específico de "ANTIOQUIAA" en variable DEPARTAMENTO
replace DEPARTAMENTO = "ANTIOQUIA" if DEPARTAMENTO == "ANTIOQUIAA"

*1.4 Filtrar colegios del sector oficial y determinar:

* Filtrar únicamente colegios del sector oficial
keep if SECTOR_ATENCION == "OFICIAL"

* Guardar la base filtrada en el repo
save "SEDES_DEF2022_OF.dta", replace
* ----------------------------
* 1.4.1) Departamento con más colegios únicos (EST_ID)
* ----------------------------
preserve
    * Crear una marca que identifique la primera ocurrencia de cada (DEPARTAMENTO, EST_ID)
    bysort DEPARTAMENTO EST_ID: gen tag_dep = _n == 1

    * Sumar las marcas por departamento => número de colegios únicos por departamento
    collapse (sum) n_colegios_dep = tag_dep, by(DEPARTAMENTO)

    * Ordenar y mostrar el top 1 (o top 5 si prefieres)
    gsort -n_colegios_dep
    di "Departamento con más colegios (top 1):"
    list DEPARTAMENTO n_colegios_dep in 1

    * Mostrar top 5 (opcional)
    di "Top 5 departamentos:"
    list DEPARTAMENTO n_colegios_dep in 1/5 
restore

* ----------------------------
* 1.4.2) Municipio con más colegios únicos (EST_ID)
* ----------------------------
preserve
    * Marca por (MUNICIPIO, EST_ID)
    bysort MUNICIPIO EST_ID: gen tag_mun = _n == 1

    * Sumar las marcas por municipio => número de colegios únicos por municipio
    collapse (sum) n_colegios_mun = tag_mun, by(MUNICIPIO)

    * Ordenar y mostrar el top
    gsort -n_colegios_mun
    di "Municipio con más colegios (top 1):"
    list MUNICIPIO n_colegios_mun in 1

    * Mostrar top 5 (opcional)
    di "Top 5 municipios:"
    list MUNICIPIO n_colegios_mun in 1/5

restore

use "SEDES_DEF2022_OF.dta", clear



*1.5) Número total se estudiantes por nivel educativo

* Educación Primaria: grados 1° a 5° (PRIMERO a QUINTO)
gen PRIMARIA = PRIMERO + SEGUNDO + TERCERO + CUARTO + QUINTO
* Educación Secundaria grados 6° a 9° (SEXTO a NOVENO)
gen SECUNDARIA = SEXTO + SEPTIMO + OCTAVO + NOVENO
* Educación Media grados 10° a 11° (DECIMO a ONCE)
gen MEDIA = DECIMO + ONCE 

* Variables binarias de presencia de estudiantes por nivel
gen PRIMARIAB   = (PRIMERO > 0 | SEGUNDO > 0 | TERCERO > 0 | CUARTO > 0 | QUINTO > 0)
gen SECUNDARIAB = (SEXTO > 0 | SEPTIMO > 0 | OCTAVO > 0 | NOVENO > 0)
gen MEDIAB      = (DECIMO > 0 | ONCE > 0)

* Clasificación según combinaciones
gen categoria = .
replace categoria = 1 if PRIMARIAB==1 & SECUNDARIAB==0 & MEDIAB==0   // Solo primaria
replace categoria = 2 if PRIMARIAB==0 & SECUNDARIAB==1 & MEDIAB==0   // Solo secundaria
replace categoria = 3 if PRIMARIAB==0 & SECUNDARIAB==0 & MEDIAB==1   // Solo media
replace categoria = 4 if PRIMARIAB==1 & SECUNDARIAB==1 & MEDIAB==0   // Primaria ∩ Secundaria
replace categoria = 5 if PRIMARIAB==1 & SECUNDARIAB==0 & MEDIAB==1   // Primaria ∩ Media
replace categoria = 6 if PRIMARIAB==0 & SECUNDARIAB==1 & MEDIAB==1   // Secundaria ∩ Media
replace categoria = 7 if PRIMARIAB==1 & SECUNDARIAB==1 & MEDIAB==1   // Los tres niveles

* Crear etiquetas
label define categorias ///
    1 "Solo primaria" ///
    2 "Solo secundaria" ///
    3 "Solo media" ///
    4 "Primaria ∩ Secundaria" ///
    5 "Primaria ∩ Media" ///
    6 "Secundaria ∩ Media" ///
    7 "Primaria ∩ Secundaria ∩ Media"

* Asignar etiquetas a la variable
label values categoria categorias

* Verificar
tab categoria

save "SEDES_DEF2022_OF_RC.dta", replace

*1.6) Merge con lista de municipios

use "Listado_municipios_PDET.dta", clear

* Estandarizar nombre del municipio para hacer match
gen MUNICIPIO = upper(municipio)
replace MUNICIPIO = strtrim(MUNICIPIO)
replace MUNICIPIO = subinstr(MUNICIPIO, "Á", "A", .)
replace MUNICIPIO = subinstr(MUNICIPIO, "É", "E", .)
replace MUNICIPIO = subinstr(MUNICIPIO, "Í", "I", .)
replace MUNICIPIO = subinstr(MUNICIPIO, "Ó", "O", .)
replace MUNICIPIO = subinstr(MUNICIPIO, "Ú", "U", .)
replace MUNICIPIO = subinstr(MUNICIPIO, "Ñ", "N", .)
replace MUNICIPIO = subinstr(MUNICIPIO, "Ü", "U", .)

duplicates drop MUNICIPIO, force
*Base Pdet estandarizada
save "PDET_estandarizada.dta", replace

* Cargar base principal de sedes oficiales
use "SEDES_DEF2022_OF_RC.dta", clear
merge m:1 MUNICIPIO using "PDET_estandarizada.dta", gen(merge_pdet)

save "merge_Pdte_SEDES_DEF2022_OF.dta", replace

* 1. PROPORCIÓN DE COLEGIOS OFICIALES EN MUNICIPIOS PDET
preserve
    * Identificar colegios únicos (por EST_ID)
    bysort EST_ID: gen tag_colegio = _n == 1
    
    * Tabular colegios por condición PDET
    tabulate subregion_pdet if tag_colegio == 1
    
    * Calcular proporciones
    tabulate subregion_pdet if tag_colegio == 1, matcell(frecuencias)
    scalar total_colegios = frecuencias[1,1] + frecuencias[2,1]
    scalar prop_pdet_colegios = (frecuencias[2,1] / total_colegios) * 100
    scalar prop_no_pdet_colegios = (frecuencias[1,1] / total_colegios) * 100
    
    * Mostrar resultados
    di "TOTAL COLEGIOS OFICIALES: " total_colegios
    di "Colegios en municipios NO PDET: " frecuencias[1,1] " (" prop_no_pdet_colegios "%)"
    di "Colegios en municipios PDET: " frecuencias[2,1] " (" prop_pdet_colegios "%)"
restore

gen total_matriculas= PRIMARIA + SECUNDARIA + MEDIA


* 2. PROPORCIÓN DE MATRÍCULA ESTUDIANTIL EN MUNICIPIOS PDET

* Calcular matrícula total por condición PDET
preserve
    * Colapsar para obtener la matrícula total según condición PDET
    collapse (sum) total_matriculas, by(subregion_pdet)
    
    * Calcular total nacional
    egen matricula_total = total(total_matriculas)
    
    * Calcular proporciones
    gen prop_matricula = (total_matriculas / matricula_total) * 100
    
    * Formatear para mejor presentación
    format prop_matricula %9.2f
    format total_matriculas %12.0fc
    
    * Mostrar resultados
    list subregion_pdet total_matriculas prop_matricula, clean noobs
    
    * Guardar valores en escalares para reportar
    scalar matricula_pdet = total_matriculas[2]  // Asumiendo que PDET es el valor 2
    scalar matricula_total_nacional = matricula_total[1]
    scalar prop_matricula_pdet = prop_matricula[2]
    
    di "MATRÍCULA TOTAL NACIONAL: " matricula_total_nacional
    di "Matrícula en municipios PDET: " matricula_pdet " (" prop_matricula_pdet "%)"
restore

*1.7 Identifica las cinco (5) sedes con mayor matricula total (tanto urbanas como rurales) en los municipios PDET 

* Filtrar solo municipios PDET (donde subregion_pdet no está vacío)
keep if !missing(subregion_pdet)


* Panel A: Sedes urbanas con mayor matrícula
preserve
    keep if ZONA == "URBANA"  // Ajustar según los valores exactos que muestra tab ZONA
    
    * Ordenar por matrícula descendente y mantener top 5
    gsort -total_matricula
    keep in 1/5
    
    * Mantener solo las variables necesarias para la tabla
    keep CODIGO_DANE_SEDE NOMBRE_SEDE MUNICIPIO SECRETARIA total_matricula
    
    * Mostrar resultados para Panel A
    di "PANEL A: SEDES URBANAS"
    list CODIGO_DANE_SEDE NOMBRE_SEDE MUNICIPIO SECRETARIA total_matricula, clean noobs sep(0)
    
restore

* Panel B: Sedes rurales con mayor matrícula
preserve
    keep if ZONA == "RURAL"  // Ajustar según los valores exactos que muestra tab ZONA
    
    * Ordenar por matrícula descendente y mantener top 5
    gsort -total_matricula
    keep in 1/5
    
    * Mantener solo las variables necesarias para la tabla
    keep CODIGO_DANE_SEDE NOMBRE_SEDE MUNICIPIO SECRETARIA total_matricula
    
    * Mostrar resultados para Panel B
    di "PANEL B: SEDES RURALES"
    list CODIGO_DANE_SEDE NOMBRE_SEDE MUNICIPIO SECRETARIA total_matricula, clean noobs sep(0)
    
restore


* 1.8 CONSERVAR VARIABLES SOLICITADAS Y GUARDAR BASE FINAL

* Conservar solo las variables solicitadas
keep DEPARTAMENTO SECRETARIA COD_DANE_MUNICIPIO MUNICIPIO ///
     CODIGO_DANE NOMBRE_ESTABLECIMIENTO SECTOR_ATENCION ///
     CODIGO_DANE_SEDE NOMBRE_SEDE ZONA total_matricula subregion_pdet

* Renombrar total_matricula a TOTAL_MATRICULA para coincidir con lo solicitado
rename total_matricula TOTAL_MATRICULA

* Guardar la base de datos resultante
save "SEDES_PDET_FINAL.dta", replace

*1.9 Cruce con la base "CONECTIVIDAD_2022" 

use "SEDES_PDET_FINAL.dta", clear

* Importar la base de conectividad
import excel using "https://github.com/9marlon9/Prueba-CNC/raw/main/Conectividad_2022.xlsx", firstrow clear

* Estandarizar el código DANE de la sede en ambas bases para asegurar match
* En base de conectividad (verificar el nombre exacto de la variable)
rename CodigoDaneSede CODIGO_DANE_SEDE  // Ajustar según nombre real
tostring COD_DANE_MUNICIPIO, replace format(%05.0f)  


* Guardar base de conectividad temporalmente
save "CONECTIVIDAD_2022_estandarizada.dta", replace

* Cargar nuestra base final
use "SEDES_PDET_FINAL.dta", clear

* Realizar el merge usando CODIGO_DANE_SEDE como llave
merge m:1 CODIGO_DANE_SEDE using "CONECTIVIDAD_2022_estandarizada.dta", gen(merge_conectividad)

* Calcular porcentaje de cruce
tab merge_conectividad


*1.10) Sedes que cuentan con información de conectividad. 
keep if merge_conectividad == 3
save "SEDES_PDET_CON_CONECTIVIDAD.dta", replace

*1.11) Estandarize la variable ANCHODEBANDACONSOLIDADOMbps (convierte todos los valores a Mbps ). 

* Extraer solo los valores numéricos y convertir a Mbps
gen bandwidth_num = real(substr(ANCHODEBANDACONSOLIDADOMbps, 1, strpos(ANCHODEBANDACONSOLIDADOMbps, " ")-1))
replace bandwidth_num = bandwidth_num * 1000 if bandwidth_num < 100
drop ANCHODEBANDACONSOLIDADOMbps
rename bandwidth_num ANCHODEBANDACONSOLIDADOMbps

*¿Cuál es el promedio de velocidad de internet en las sedes oficiales en Colombia? . 
sum ANCHODEBANDACONSOLIDADOMbps if ANCHODEBANDACONSOLIDADOMbps > 0
di "Promedio de velocidad: " r(mean) " Mbps"

* ¿Cuál es la Secretaría de Educación con el promedio de velocidad más alto? ¿Y cuál tiene el promedio más bajo? ¿Cuál es la diferencia en el promedio de velocidad entre ambas secretarias?

* Calcular promedio de velocidad por Secretaría (solo valores > 0)
collapse (mean) velocidad_prom = ANCHODEBANDACONSOLIDADOMbps if ANCHODEBANDACONSOLIDADOMbps > 0, by(SECRETARIA)

* Ordenar de mayor a menor
gsort -velocidad_prom

* Identificar secretaría con mayor y menor promedio
local max_secretaria = SECRETARIA[1]
local max_prom = velocidad_prom[1]
local min_secretaria = SECRETARIA[_N]
local min_prom = velocidad_prom[_N]
local diferencia = `max_prom' - `min_prom'

di "Mayor promedio: `max_secretaria' (" `max_prom' " Mbps)"
di "Menor promedio: `min_secretaria' (" `min_prom' " Mbps)"
di "Diferencia: " `diferencia' " Mbps"

*1.12) Número de estudiantes promedio por Computador a nivel nacional

use "SEDES_PDET_CON_CONECTIVIDAD.dta", clear

* Calcular ratio estudiantes por computador
gen ratio_estudiantes_computador = TOTAL_MATRICULA / TotalComputadoresPortatilF

* Calcular promedio nacional (solo donde hay computadores)
sum ratio_estudiantes_computador if TotalComputadoresPortatilF > 0 & !missing(TotalComputadoresPortatilF)
di "Promedio nacional de estudiantes por computador: " r(mean)

*1.13) calculo a nivel de Secretaría de Educación

* Calcular benchmark nacional
sum ratio_estudiantes_computador if TotalComputadoresPortatilF > 0
local benchmark = r(mean)

* Calcular promedio por Secretaría
preserve
collapse (mean) z_i = ratio_estudiantes_computador if TotalComputadoresPortatilF > 0, by(SECRETARIA)

* Calcular brecha
gen brecha_equipos = `benchmark' - z_i

* Ordenar por brecha
gsort -brecha_equipos

* Mostrar resultados
list SECRETARIA z_i brecha_equipos, clean noobs

* Guardar resultados
save "brecha_equipos_secretarias.dta", replace
restore

*¿Qué implica que una Secretaría de Educación tenga un valor negativo en esta variable?

*¿Cuales son las cinco (5) secretarias con la brecha más alta? ¿Considera que comparten algún rasgo en común? (Si/No) ¿Por qué?


* Identificar las 5 secretarías con mayor brecha
use "brecha_equipos_secretarias.dta", clear
gsort -brecha_equipos
list SECRETARIA brecha_equipos in 1/5, clean noobs




