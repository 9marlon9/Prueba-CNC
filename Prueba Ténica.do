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

tab DEPARTAMENTO if SECTOR_ATENCION == "OFICIAL", sort










