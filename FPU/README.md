# ALU-FP: Unidad Aritmética Lógica en Punto Flotante (RV32F - IEEE 754)

Este repositorio contiene el diseño y la verificación funcional de una **Unidad Aritmética Lógica en punto flotante (ALU-F)** desarrollada en SystemVerilog para ser integrada en un microcontrolador bajo la arquitectura **RISC-V con extensión RV32F**. La ALU opera en **precisión simple (binary32)** según el estándar **IEEE 754**, e implementa operaciones aritméticas, combinadas y de comparación, junto con el manejo adecuado de casos especiales como ceros con signo, subnormales, infinitos y valores NaN.

---

## Estructura del Proyecto

El proyecto está organizado en módulos independientes que permiten una fácil escalabilidad y verificación. A continuación, se describe cada carpeta del repositorio:

- `ALU_FP/`  
  Carpeta principal con el módulo de integración `fp_alu.sv` y el directorio `Testbench/` para verificación global.

- `Comparadores/`  
  Implementación de las operaciones de comparación: `feq.s`, `flt.s` y `fle.s`.

- `Operaciones_comb/`  
  Contiene los módulos para operaciones combinadas: `fmadd.s` y `fmsub.s`.

- `Sumador_restador/`  
  Implementa la lógica de suma y resta (`fp_adder.sv`, `fp_sub.sv`, etc.), con submódulos para normalización, alineación de exponentes y redondeo.

- `fp_unpack/`  
  Módulo encargado de desempaquetar los números flotantes (separación de signo, exponente y mantisa).

- `multiplicador/`  
  Contiene el multiplicador `fp_mul.sv` en punto flotante, reutilizado de un diseño previo.

> **Nota:** Cada carpeta incluye una subcarpeta `tb/` con un testbench específico para ese módulo. No obstante, todos los casos están cubiertos por el testbench principal en `ALU_FP/Testbench`.

---

## Compilación y Simulación

### Requisitos

- [Synopsys VCS](https://www.synopsys.com/verification/simulation/vcs.html)
- Git
- Bash (para ejecutar el script)

### Ejecución del testbench principal

Ubícate en el directorio `ALU_FP/Testbench/` y ejecuta:

```bash
bash fpalucommandvcs.sh
