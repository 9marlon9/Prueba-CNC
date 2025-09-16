* ************************************************************
* ARCHIVO: Angulo_Marlon_ejercicio_1.do
* PROYECTO: Prueba Técnica - Centro Nacional de Consultoría
* AUTOR: Angulo Marlon
* FECHA: 16/09/2025
* DESCRIPCIÓN: Análisis de datos educativos - Ejercicio 1
* ************************************************************
clear all

* Ejercicio 1: 

*1.1Importar la base SEDES_DEF2022 a STATA
import excel using "https://github.com/9marlon9/Prueba-CNC/raw/main/SEDES_DEF2022.xlsx", firstrow clear

*1.2Estandarizar texto en variables DEPARTAMENTO, SECRETARIA y MUNICIPIO
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
* a) Departamento con mayor número de colegios oficiales
bysort DEPARTAMENTO: gen n_colegios = _N

* Ver resumen (cuántos colegios por DEPARTAMENTO, sin repeticiones)
bysort DEPARTAMENTO (n_colegios): keep if _n==1
sort -n_colegios
list DEPARTAMENTO n_colegios in 1/10   // muestra el top 10
* b) Municipio con mayor número de colegios oficiales  
egen conteo_mun = count(SEDE_ID), by(MUNICIPIO DEPARTAMENTO)  // Contar sedes por municipio
gsort -conteo_mun  // Ordenar de mayor a menor
list MUNICIPIO DEPARTAMENTO conteo_mun in 1/5, clean  // Mostrar top 5 municipios









